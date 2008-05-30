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
#include <R_eval.h>

int interrupted = 0;

/* Abort the current R computation due to a SIGINT */
void interrupt_R(int signum)
{
  interrupted = 1;
  error("Interrupted");
}


/* Evaluate a SEXP. It must be constructed by hand. It raises a Ruby
   exception if an error ocurred in the evaluation */
SEXP do_eval_expr(SEXP e) {
  SEXP res;
  VALUE rb_eRException;
  int error = 0;

  signal(SIGINT, interrupt_R);
  interrupted = 0;

  res = R_tryEval(e, R_GlobalEnv, &error);

  if (error) {
    if (interrupted) {
      rb_raise(rb_eInterrupt,"RSRuby interrupted");
    }
    else {
      rb_eRException = rb_const_get(rb_cObject, 
				    rb_intern("RException"));
      rb_raise(rb_eRException, get_last_error_msg());
      return NULL;
    }
  }

  return res;

}

/* Evaluate a function given by a name (without arguments) */
SEXP do_eval_fun(char *name) {
  SEXP exp, fun, res;

  fun = get_fun_from_name(name);
  if (!fun)
    return NULL;

  PROTECT(fun);
  PROTECT(exp = allocVector(LANGSXP, 1));
  SETCAR(exp, fun);

  PROTECT(res = do_eval_expr(exp));
  UNPROTECT(3);
  return res;
}

/*
 * Get an R **function** object by its name. When not found, an exception is
 * raised. The checking of the length of the identifier is needed to
 * avoid R raising an error.
 */
SEXP get_fun_from_name(char *ident) {
  SEXP obj;

  /* For R not to throw an error, we must check the identifier is
     neither null nor greater than MAXIDSIZE */
  if (!*ident) {
    rb_raise(rb_eRuntimeError, "Attempt to use zero-length variable name");
    return NULL;
  }
  if (strlen(ident) > MAXIDSIZE) {
    rb_raise(rb_eRuntimeError, "symbol print-name too long");
    return NULL;
  }
  
#if R_VERSION < 0x20000
  obj = Rf_findVar(Rf_install(ident), R_GlobalEnv);
#else
  /*
   * For R-2.0.0 and later, it is necessary to use findFun to get
   * functions.  Unfortunately, calling findFun on an undefined name
   * causes a segfault!
   *
   * Solution:
   *
   * 1) Call findVar on the name
   *
   * 2) If something has the name, call findFun
   *
   * 3) Raise an error if either step 1 or 2 fails.
   */
  obj = Rf_findVar(Rf_install(ident), R_GlobalEnv);

  if (obj != R_UnboundValue)
      obj = Rf_findFun(Rf_install(ident), R_GlobalEnv);
#endif
  
  if (obj == R_UnboundValue) {
    rb_raise(rb_eNoMethodError, "R Function \"%s\" not found", ident);
    return NULL;
  }
  return obj;
}

/* Obtain the text of the last R error message */
char *get_last_error_msg() {
  SEXP msg;

  msg = do_eval_fun("geterrmessage");
  return CHARACTER_VALUE(msg);
}
