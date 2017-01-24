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

#ifndef R_RUBY_CONVERTERS_H
#define R_RUBY_CONVERTERS_H

#include "rsruby.h"

//Converters for Ruby to R
SEXP ruby_to_R(VALUE val);
VALUE ruby_to_Robj(VALUE self,VALUE args);

SEXP array_to_R(VALUE obj);
SEXP hash_to_R(VALUE obj);
int type_to_int(VALUE obj);

//Converters for R to Ruby
VALUE to_ruby_with_mode(SEXP robj, int mode);

int to_ruby_basic(SEXP robj, VALUE *obj);
int to_ruby_vector(SEXP robj, VALUE *obj, int mode);
int to_ruby_proc(SEXP robj, VALUE *obj);
int to_ruby_class(SEXP robj, VALUE *obj);
int from_proc_table(SEXP robj, VALUE *fun);
VALUE from_class_table(SEXP robj);

VALUE call_proc(VALUE data);
VALUE reset_mode(VALUE mode);

VALUE to_ruby_hash(VALUE obj, SEXP names);
VALUE to_ruby_array(VALUE obj, SEXP robj);

VALUE ltranspose(VALUE list, int *dims, int *strides,
                 int pos, int shift, int len);

//Macros for quick checks
#define Robj_Check(v) (rb_obj_is_instance_of(v,rb_const_get(rb_cObject,rb_intern("RObj"))))
#define RubyComplex_Check(v) (rb_obj_is_instance_of(v,rb_const_get(rb_cObject,rb_intern("Complex"))))

/* These are auxiliaries for a state machine for converting Python
   list to the coarsest R vector type */
#define ANY_T 0
#define BOOL_T 1
#define INT_T 2
#define FLOAT_T 3
#define COMPLEX_T 4
#define STRING_T 5
#define ROBJ_T 6

#endif
