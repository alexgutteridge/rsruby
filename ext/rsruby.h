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

#ifndef R_RUBY_MAIN
#define R_RUBY_MAIN

#include "ruby.h"

#include "R.h"
#include "Rdefines.h"
#include "Rinternals.h"
#include "Rdefines.h"
#include "Rdevices.h"

#include "signal.h"

#include "R_eval.h"
#include "Converters.h"

#define MAXIDSIZE 256

#define NO_CONVERSION 0
#define VECTOR_CONVERSION 1
#define BASIC_CONVERSION 2
#define CLASS_CONVERSION 3
#define PROC_CONVERSION 4

#define TOP_MODE 4

#define RSRUBY rb_funcall(rb_const_get(rb_cObject,rb_intern("RSRuby")),rb_intern("instance"),0)

/* Missing definitions from Rinterface.h or RStartup.h */
# define CleanEd Rf_CleanEd
extern int Rf_initEmbeddedR(int argc, char **argv);
extern void CleanEd(void);
extern int R_CollectWarnings; 
# define PrintWarnings Rf_PrintWarnings
extern void PrintWarnings(void);

void Init_rsruby();

void init_R(int argc, char *argv[0]);
void r_finalize(void);

SEXP RecursiveRelease(SEXP obj, SEXP list);
//static void Robj_dealloc(VALUE self);

VALUE rs_shutdown(VALUE self);
VALUE get_fun(VALUE self, VALUE name);
VALUE rr_init(VALUE self);

VALUE RObj_lcall(VALUE self, VALUE args);
VALUE RObj_init_lcall(VALUE self, VALUE args);
VALUE RObj_to_ruby(VALUE self, VALUE args);
int make_argl(VALUE args, SEXP *e);
#endif
