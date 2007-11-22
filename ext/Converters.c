/*
* == Author
* Alex Gutteridge
*
* == Copyright
*Copyright (C) 2006 Alex Gutteridge
*
* The Original Code is the RPy python module.
*
* The Initial Developer of the Original Code is Walter Moreira.
* Portions created by the Initial Developer are Copyright (C) 2002
* the Initial Developer. All Rights Reserved.
*
* Contributor(s):
*    Gregory R. Warnes <greg@warnes.net> (RPy Maintainer)
*
*This library is free software; you can redistribute it and/or
*modify it under the terms of the GNU Lesser General Public
*License as published by the Free Software Foundation; either
*version 2.1 of the License, or (at your option) any later version.
*
*This library is distributed in the hope that it will be useful,
*but WITHOUT ANY WARRANTY; without even the implied warranty of
*MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
*Lesser General Public License for more details.
*
*You should have received a copy of the GNU Lesser General Public
*License along with this library; if not, write to the Free Software
*Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
*/

#include <rsruby.h>
#include "Converters.h"

// ************** Converters from Ruby to R *********//


SEXP ruby_to_R(VALUE obj)
{
  SEXP robj;
  VALUE str;
  char buf [100];

  //Return nil if object is nil
  if (obj == Qnil) {
    return R_NilValue;
  }

  //If object has 'as_r' then call it and use 
  //returned value subsequently
  if (rb_respond_to(obj, rb_intern("as_r"))){
    obj = rb_funcall(obj,rb_intern("as_r"),0);
    if (!obj)
      return NULL;
  }
  
  if (Robj_Check(obj))
    {
      Data_Get_Struct(obj, struct SEXPREC, robj);
      PROTECT(robj);
    }
  else if (obj == Qtrue || obj == Qfalse)
    {
      PROTECT(robj = NEW_LOGICAL(1));
      if (obj == Qtrue){
	LOGICAL_DATA(robj)[0] = TRUE;
      } else {
	LOGICAL_DATA(robj)[0] = FALSE;
      }
	  
    }
  else if (TYPE(obj) == T_FIXNUM || 
	   TYPE(obj) == T_BIGNUM)
    {
      PROTECT(robj = NEW_INTEGER(1));
      INTEGER_DATA(robj)[0] = NUM2LONG(obj);
    }
  else if (TYPE(obj) == T_FLOAT)
    {
      PROTECT(robj = NEW_NUMERIC(1));
      NUMERIC_DATA(robj)[0] = NUM2DBL(obj);
    }
  else if (RubyComplex_Check(obj)) 
    {
      PROTECT(robj = NEW_COMPLEX(1));
      COMPLEX_DATA(robj)[0].r = NUM2DBL(rb_funcall(obj,rb_intern("real"),0));
      COMPLEX_DATA(robj)[0].i = NUM2DBL(rb_funcall(obj,rb_intern("image"),0));
    }
  else if (!NIL_P(rb_check_string_type(obj))) 
    {
      PROTECT(robj = NEW_STRING(1));
      SET_STRING_ELT(robj, 0, COPY_TO_USER_STRING(RSTRING(obj)->ptr));
    }
  else if (!NIL_P(rb_check_array_type(obj))) 
    {
      PROTECT(robj = array_to_R(obj));
    }
  else if (TYPE(obj) == T_HASH) 
    {
      PROTECT(robj = hash_to_R(obj));
    }
  else 
    {
      str = rb_funcall(obj,rb_intern("inspect"),0);
      str = rb_funcall(str,rb_intern("slice"),2,INT2NUM(0),INT2NUM(60));
      sprintf(buf,"Unsupported object '%s' passed to R.\n",RSTRING(str)->ptr);
      rb_raise(rb_eArgError,buf);
      PROTECT(robj = NULL);       /* Protected to avoid stack inbalance */
    }

  UNPROTECT(1);
  return robj;
}

/* Make a R list or vector from a Ruby array */
SEXP array_to_R(VALUE obj)
{
  VALUE it;
  SEXP robj, rit;
  int i, state;

  /* This matrix defines what mode a vector should take given what
     it already contains and a new item
  
     E.g. Row 0 indicates that if we've seen an any, the vector will
     always remain an any.  Row 3 indicates that if we've seen a
     float, then seeing an boolean, integer, or float will preserve
     the vector as a float vector, while seeing a string or an Robj will
     convert it into an any vector.
  */
  int fsm[7][7] = {
    {0, 0, 0, 0, 0, 0, 0}, // any
    {0, 1, 2, 3, 4, 0, 0}, // bool
    {0, 2, 2, 3, 4, 0, 0}, // int
    {0, 3, 3, 3, 4, 0, 0}, // float
    {0, 4, 4, 4, 4, 0, 0}, // complex
    {0, 0, 0, 0, 0, 5, 0}, // string
    {0, 0, 0, 0, 0, 0, 6}  // RObj
  };
  
  //Probably unnessecary but just in case
  obj = rb_check_array_type(obj);

  if (RARRAY(obj)->len == 0)
    return R_NilValue;

  PROTECT(robj = NEW_LIST(RARRAY(obj)->len));

  state = -1;
  for (i=0; i<RARRAY(obj)->len; i++) {

    it = rb_ary_entry(obj, i);

    if (state < 0)
      state = type_to_int(it);
    else
      state = fsm[state][type_to_int(it)];

    if (!(rit = ruby_to_R(it)))
      goto exception;
    
    SET_VECTOR_ELT(robj, i, rit);
  }

  switch(state)
    {
    case INT_T:
      robj = AS_INTEGER(robj);
      break;
    case BOOL_T:
      robj = AS_LOGICAL(robj);
      break;
    case FLOAT_T:
      robj = AS_NUMERIC(robj);
      break;
    case COMPLEX_T:
      robj = AS_COMPLEX(robj);
      break;
    case STRING_T:
      robj = AS_CHARACTER(robj);
      break;
    default:;
      /* Otherwise, it's either an ANY_T or ROBJ_T - we want ANY */
    }

  UNPROTECT(1);
  return robj;

exception:
  UNPROTECT(1);
  rb_raise(rb_eArgError,"Error converting Array to R\n");
  return NULL;
}

/* Make a R named list or vector from a Ruby Hash */
SEXP
hash_to_R(VALUE obj)
{
  VALUE keys, values;
  SEXP robj, names;

  //TODO - Baffling. Not sure what's wrong with these functions?
  //rb_hash_keys(proc_table);
  //rb_hash_values(proc_table);
  //rb_hash_size(proc_table);
  //compiles, but complains they are undefined symbols when run...

  if (FIX2INT(rb_funcall(obj,rb_intern("size"),0)) == 0)
    return R_NilValue;

  /* If 'keys' succeed and 'values' fails this leaks */
  if (!(keys = rb_funcall(obj,rb_intern("keys"),0)))
    return NULL;
  if (!(values = rb_funcall(obj,rb_intern("values"),0)))
    return NULL;
  
  if (!(robj  = array_to_R(values)))
    goto fail;
  if (!(names = array_to_R(keys)))
    goto fail;

  PROTECT(robj);
  SET_NAMES(robj, names);
  UNPROTECT(1);

  return robj;

 fail:
  return NULL;
}

int
type_to_int(VALUE obj)
{
  if (obj == Qtrue || obj == Qfalse)
    return BOOL_T;
  else if (TYPE(obj) == T_FIXNUM || 
	   TYPE(obj) == T_BIGNUM)
    return INT_T;
  else if (TYPE(obj) == T_FLOAT)
    return FLOAT_T;
  else if (RubyComplex_Check(obj))
    return COMPLEX_T;
  //NB (TODO): This line means that objects are coerced into
  //String form if possible rather than leaving them as RObj
  else if (!NIL_P(rb_check_string_type(obj)))
    return STRING_T;
  else if (Robj_Check(obj))
    return ROBJ_T;
  else
    return ANY_T;
}

// ************** Converters from R to Ruby *********//

VALUE to_ruby_with_mode(SEXP robj, int mode)
{
  VALUE obj;
  int i;

  switch (mode)
    {
    case PROC_CONVERSION:
      i = to_ruby_proc(robj, &obj);
      if (i<0) return Qnil;
      if (i==1) break;
    case CLASS_CONVERSION:
      i = to_ruby_class(robj, &obj);
      if (i<0) return Qnil;
      if (i==1) break;
    case BASIC_CONVERSION:
      i = to_ruby_basic(robj, &obj);
      if (i<0) return Qnil;
      if (i==1) break;
    case VECTOR_CONVERSION:
      i = to_ruby_vector(robj, &obj, mode=VECTOR_CONVERSION);
      if (i<0) return Qnil;
      if (i==1) break;
    default:
      obj = Data_Wrap_Struct(rb_const_get(rb_cObject, 
					  rb_intern("RObj")), 0, 0, robj);
      rb_iv_set(obj,"@conversion",INT2FIX(TOP_MODE));
      rb_iv_set(obj,"@wrap",Qfalse);
  }

  return obj;
}

/* Convert an R object to a 'basic' Ruby object (mode 2) */
/* NOTE: R vectors of length 1 will yield a Ruby scalar */
int
to_ruby_basic(SEXP robj, VALUE *obj)
{
  int status;
  VALUE tmp;

  status = to_ruby_vector(robj, &tmp, BASIC_CONVERSION);

  if(status==1 && TYPE(tmp) == T_ARRAY && RARRAY(tmp)->len == 1)
    {
      *obj = rb_ary_entry(tmp, 0);
    }
  else
    *obj = tmp;

  return status;
}


/* Convert an R object to a 'vector' Ruby object (mode 1) */
/* NOTE: R vectors of length 1 will yield a Ruby array of length 1*/
int
to_ruby_vector(SEXP robj, VALUE *obj, int mode)
{
  VALUE it, tmp;
  VALUE params[2];
  SEXP names, dim;
  int len, *integers, i, type;
  char *strings, *thislevel;
  double *reals;
  Rcomplex *complexes;

  if (!robj)
    return -1;                  /* error */

  if (robj == R_NilValue) {
    *obj = Qnil;
    return 1;                   /* succeed */
  }

  len = GET_LENGTH(robj);
  tmp = rb_ary_new2(len);
  type = TYPEOF(robj);
  
  for (i=0; i<len; i++) {
    switch (type)
      {
      case LGLSXP:
	integers = INTEGER(robj);
	if(integers[i]==NA_INTEGER) /* watch out for NA's */
	  {
	    if (!(it = INT2NUM(integers[i])))
	      return -1;
	  }
	//TODO - not sure of the conversion here.
	else if (integers[i] != 0){
	  it = Qtrue;
	} else if (integers[i] == 0){
	  it = Qfalse;
	} else {
	  return -1;
	}
	break;
      case INTSXP:
        integers = INTEGER(robj);
        if(isFactor(robj)) {
          /* Watch for NA's! */
          if(integers[i]==NA_INTEGER)
            it = rb_str_new2(CHAR(NA_STRING));
          else
            {
              thislevel = CHAR(STRING_ELT(GET_LEVELS(robj), integers[i]-1));
              if (!(it = rb_str_new2(thislevel)))
                return -1;
            }
        }
        else {
          if (!(it = LONG2NUM(integers[i])))
            return -1;
        }
        break;
      case REALSXP:
        reals = REAL(robj);
        if (!(it = rb_float_new(reals[i])))
          return -1;
        break;
      case CPLXSXP:
        complexes = COMPLEX(robj);

	params[0] = rb_float_new(complexes[i].r);
	params[1] = rb_float_new(complexes[i].i);

        if (!(it = rb_class_new_instance(2, params, rb_const_get(rb_cObject, rb_intern("Complex")))))

          return -1;
        break;
      case STRSXP:
        if(STRING_ELT(robj, i)==R_NaString)
          it = rb_str_new2(CHAR(NA_STRING));
        else
          {
            strings = CHAR(STRING_ELT(robj, i));
            if (!(it = rb_str_new2(strings)))
              return -1;
          }
        break;
      case LISTSXP:
        if (!(it = to_ruby_with_mode(elt(robj, i), mode)))
          return -1;
        break;
      case VECSXP:
        if (!(it = to_ruby_with_mode(VECTOR_ELT(robj, i), mode)))
          return -1;
        break;
      default:
        return 0;                 /* failed */
    }
    rb_ary_store(tmp, i, it);
  }

  dim = GET_DIM(robj);
  if (dim != R_NilValue) {
    len = GET_LENGTH(dim);
    *obj = to_ruby_array(tmp, INTEGER(dim), len);
    return 1;
  }

  names = GET_NAMES(robj);
  if (names == R_NilValue)
    *obj = tmp;
  else {
    *obj = to_ruby_hash(tmp, names);
  }

  return 1;
}

/* Search a conversion procedure from the proc table */
int
from_proc_table(SEXP robj, VALUE *fun)
{
  VALUE proc_table, procs, proc, funs, res, obj, mode;
  VALUE args[2];
  int i, l, error;

  proc_table = rb_iv_get(RSRUBY,"@proc_table");

  proc  = Qnil;

  //TODO - Baffling. Not sure what's wrong with these functions?
  //procs = rb_hash_keys(proc_table);
  //funs  = rb_hash_values(proc_table);
  //l     = FIX2INT(rb_hash_size(proc_table));

  procs = rb_funcall(proc_table,rb_intern("keys"),0);
  funs  = rb_funcall(proc_table,rb_intern("values"),0);
  l     = FIX2INT(rb_funcall(proc_table,rb_intern("size"),0));

  obj = Data_Wrap_Struct(rb_const_get(rb_cObject, 
				      rb_intern("RObj")), 0, 0, robj);
  rb_iv_set(obj,"@conversion",INT2FIX(TOP_MODE));
  rb_iv_set(obj,"@wrap",Qfalse);
  
  error = 0;
  for (i=0; i<l; i++) {
    proc = rb_ary_entry(procs, i);

    mode = rb_iv_get(RSRUBY,"@default_mode");
    rb_iv_set(RSRUBY,
	      "@default_mode",
	      INT2FIX(BASIC_CONVERSION));

    //New safe code
    args[0] = proc;
    args[1] = obj;
    res = rb_ensure(call_proc,(VALUE) &args[0],reset_mode,mode);

    if (RTEST(res)) {
      *fun = rb_ary_entry(funs, i);
      break;
    }
  }

  return error;
}

VALUE call_proc(VALUE data){
  VALUE *args = (VALUE *) data;
  return rb_funcall(args[0], rb_intern("call"), 1, args[1]);
}

VALUE reset_mode(VALUE mode){

  rb_iv_set(RSRUBY,
	    "@default_mode",
	    mode); 

  return Qnil;

}

int
to_ruby_proc(SEXP robj, VALUE *obj)
{
  VALUE fun=Qnil, tmp, mode;
  VALUE args[2];
  int i;

  //Find function from proc table. integer is returned
  //to indicate success/failure

  i = from_proc_table(robj, &fun);

  if (i < 0)
    return -1;                  /* an error occurred */

  if (fun==Qnil)
    return 0;                   /* conversion failed */

  //Create new object based on robj and call the function
  //found above with it as argument
  tmp = Data_Wrap_Struct(rb_const_get(rb_cObject, 
				      rb_intern("RObj")), 0, 0, robj);
  rb_iv_set(tmp,"@conversion",INT2FIX(TOP_MODE));
  rb_iv_set(tmp,"@wrap",Qfalse);

  //Again set conversion mode to basic to prevent recursion
  mode = rb_iv_get(RSRUBY,"@default_mode");
  rb_iv_set(RSRUBY, "@default_mode", INT2FIX(BASIC_CONVERSION));

  //New safe code
  args[0] = fun;
  args[1] = tmp;
  *obj = rb_ensure(call_proc,(VALUE) &args[0],reset_mode,mode);

  return 1;                     /* conversion succeed */
}

/* Search a conversion procedure from the class attribute */
VALUE from_class_table(SEXP robj)
{
  SEXP rclass;
  VALUE key, fun, class_table;
  int i;

  class_table = rb_iv_get(RSRUBY, "@class_table");

  PROTECT(rclass = GET_CLASS(robj));

  fun = Qnil;
  if (rclass != R_NilValue) {

    //key may be an array or string depending on
    //the class specification
    key = to_ruby_with_mode(rclass, BASIC_CONVERSION);
    fun = rb_hash_aref(class_table, key);

    //If we haven't found a function then go through
    //each class in rclass and look for a match
    if (fun==Qnil) {

      for (i=0; i<GET_LENGTH(rclass); i++){
	fun = rb_hash_aref(class_table,
			   rb_str_new2(CHAR(STRING_ELT(rclass, i))));
	if (fun != Qnil){
          break;
	}
      }
    }
  }
  UNPROTECT(1);
  return fun;
}

/* Convert a Robj to a Ruby object via the class table (mode 3) */
/* See the docs for conversion rules */
int
to_ruby_class(SEXP robj, VALUE *obj)
{
  VALUE fun, tmp, mode;
  VALUE args[2];

  fun = from_class_table(robj);
  
  if (fun==Qnil)
    return 0;                   /* conversion failed */
  
  tmp = Data_Wrap_Struct(rb_const_get(rb_cObject, 
				      rb_intern("RObj")), 0, 0, robj);
  rb_iv_set(tmp,"@conversion",INT2FIX(TOP_MODE));  
  rb_iv_set(tmp,"@wrap",Qfalse);

  //Again set conversion mode to basic to prevent recursion
  mode = rb_iv_get(RSRUBY, "@default_mode");
  rb_iv_set(RSRUBY, "@default_mode", INT2FIX(BASIC_CONVERSION));

  //New safe code
  args[0] = fun;
  args[1] = tmp;
  *obj = rb_ensure(call_proc,(VALUE) &args[0],reset_mode,mode);
  //*obj = rb_funcall(fun, rb_intern("call"), 1, tmp);

  return 1;                     /* conversion succeed */
}

/* Convert a R named vector or list to a Ruby Hash */
VALUE to_ruby_hash(VALUE obj, SEXP names)
{
  int len, i;
  VALUE it, hash;
  char *name;

  if ((len = RARRAY(obj)->len) < 0)
    return Qnil;

  hash = rb_hash_new();
  for (i=0; i<len; i++) {
    it = rb_ary_entry(obj, i);
    name = CHAR(STRING_ELT(names, i));
    rb_hash_aset(hash, rb_str_new2(name), it);
  }
  
  return hash;
}

/* We need to transpose the list because R makes array by the
 * fastest index */
VALUE ltranspose(VALUE list, int *dims, int *strides,
			int pos, int shift, int len)
{
  VALUE nl, it;
  int i;

  if (!(nl = rb_ary_new2(dims[pos])))
    return Qnil;

  if (pos == len-1) {
    for (i=0; i<dims[pos]; i++) {
      if (!(it = rb_ary_entry(list, i*strides[pos]+shift)))
        return Qnil;
      rb_ary_store(nl, i, it);     
    }
    return nl;
  }

  for (i=0; i<dims[pos]; i++) {
    if (!(it = ltranspose(list, dims, strides, pos+1, shift, len)))
      return Qnil;
    rb_ary_store(nl, i, it);
    shift += strides[pos];
  }

  return nl;
}
      
/* Convert a R Array to a Ruby Array (in the form of
 * array of arrays of ...) */
VALUE to_ruby_array(VALUE obj, int *dims, int l)
{
  VALUE list;
  int i, c, *strides;

  strides = (int *)ALLOC_N(int,l);
  if (!strides)
    rb_raise(rb_eRuntimeError,"Could not allocate memory for array\n");

  c = 1;
  for (i=0; i<l; i++) {
    strides[i] = c;
    c *= dims[i];
  }

  list = ltranspose(obj, dims, strides, 0, 0, l);
  free(strides);

  return list;
}
