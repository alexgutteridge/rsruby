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

#include "rsruby.h"

/* Methods for the 'Robj' type */

/* Explicitly call an R object with a list containing (name, value) *
 * argument pairs.  'name' can be None or '' to provide unnamed
 * arguments.  This function is necessary when the *order* of named
 * arguments needs to be preserved.
 */

VALUE RObj_lcall(VALUE self, VALUE args){
  SEXP  exp, e, res;
  SEXP  r_obj;
  int conv, default_mode;
  VALUE obj;

  //Ensure we have an array
  args = rb_check_array_type(args);

  // A SEXP with the function to call and the arguments
  PROTECT(exp = allocVector(LANGSXP, RARRAY_LEN(args)+1));
  e = exp;

  Data_Get_Struct(self, struct SEXPREC, r_obj);

  SETCAR(e, r_obj);
  e = CDR(e);

  // Add the arguments to the SEXP
  if (!make_argl(args, &e)) {
    UNPROTECT(1);
    return Qnil;
  }

  // Evaluate
  PROTECT(res = do_eval_expr(exp));
  if (!res) {
    UNPROTECT(2);
    return Qnil;
  }

  default_mode = NUM2INT(rb_iv_get(RSRUBY,"@default_mode"));

  // Convert
  if (default_mode < 0){
    conv = NUM2INT(rb_iv_get(self,"@conversion"));
  } else {
    conv = default_mode;
  }

  obj = to_ruby_with_mode(res, conv);

  UNPROTECT(2);

  return obj;
}


//lcall method that is safe to call during RSRuby initialisation
VALUE RObj_init_lcall(VALUE self, VALUE args){
  SEXP  exp, e, res;
  SEXP  r_obj;
  VALUE obj;

  //Ensure we have an array
  args = rb_check_array_type(args);

  // A SEXP with the function to call and the arguments
  PROTECT(exp = allocVector(LANGSXP, RARRAY_LEN(args)+1));
  e = exp;

  Data_Get_Struct(self, struct SEXPREC, r_obj);

  SETCAR(e, r_obj);
  e = CDR(e);

  // Add the arguments to the SEXP
  if (!make_argl(args, &e)) {
    UNPROTECT(1);
    return Qnil;
  }

  // Evaluate
  PROTECT(res = do_eval_expr(exp));
  if (!res) {
    UNPROTECT(2);
    return Qnil;
  }

  obj = to_ruby_with_mode(res, BASIC_CONVERSION);

  UNPROTECT(2);

  return obj;
}

/* Convert a sequence of (name, value) pairs to arguments to an R
   function call */
int
make_argl(VALUE args, SEXP *e)
{
  SEXP rvalue;
  int i;
  VALUE pair, name, value;

  //Ensure we have an array
  args = rb_check_array_type(args);
  
  for (i=0; i<RARRAY_LEN(args); i++) {
    pair = rb_ary_entry(args, i);
    pair = rb_check_array_type(pair);
    if(RARRAY_LEN(pair) != 2)
      rb_raise(rb_eArgError,"Misformed argument in lcall\n");

    /* Name must be a string. If it is empty string '' then no name*/
    name = rb_ary_entry(pair, 0);
    name = StringValue(name);
    name = rb_funcall(rb_const_get(rb_cObject, 
				   rb_intern("RSRuby")),
		      rb_intern("convert_method_name"),1,name);

    /* Value can be anything. */
    value  = rb_ary_entry(pair, 1);
    rvalue = ruby_to_R(value);

    /* Add parameter value to call */
    SETCAR(*e, rvalue);

    /* Add name (if present) */
    if (RSTRING_LEN(name) > 0) 
      {
        SET_TAG(*e, Rf_install(RSTRING_PTR(name)));
      }

    /* Move index to new end of call */
    *e = CDR(*e);
  }
  return 1;
}

VALUE RObj_to_ruby(VALUE self, VALUE args){

  int conv;
  VALUE obj;
  SEXP robj;

  args = rb_check_array_type(args);

  if (RARRAY_LEN(args) > 1){
    rb_raise(rb_eArgError,"Too many arguments in to_ruby\n");
  }

  if (RARRAY_LEN(args) == 0){
    conv = NUM2INT(rb_iv_get(RSRUBY,"@default_mode"));
  } else {
    conv = NUM2INT(rb_ary_entry(args,0));
  }

  if (conv <= -2 || conv > TOP_MODE) {
    rb_raise(rb_eArgError, "Wrong mode\n");
    return Qnil;
  }

  if (conv < 0)
    conv = TOP_MODE;

  Data_Get_Struct(self, struct SEXPREC, robj);

  obj = to_ruby_with_mode(robj, conv);
  return obj;

}


