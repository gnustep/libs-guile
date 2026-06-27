#ifndef GNUSTEP_GUILE_GH_COMPAT_H
#define GNUSTEP_GUILE_GH_COMPAT_H

#include <stdlib.h>
#include <string.h>
#include <libguile.h>

typedef SCM (*gh_eval_t) (char *);

#ifndef SCM_STRINGP
#define SCM_STRINGP(x) scm_is_string (x)
#endif

#ifndef SCM_INUMP
#define SCM_INUMP(x) scm_is_integer (x)
#endif

#ifndef SCM_CHARS
#define SCM_CHARS(x) scm_to_locale_string (x)
#endif

#ifndef SCM_LENGTH
#define SCM_LENGTH(x) scm_c_string_length (x)
#endif

#ifndef scm_makfrom0str
#define scm_makfrom0str(x) scm_from_locale_string (x)
#endif

#ifndef scm_protect_object
#define scm_protect_object(x) scm_gc_protect_object (x)
#endif

#ifndef scm_unprotect_object
#define scm_unprotect_object(x) scm_gc_unprotect_object (x)
#endif

#ifndef SCM_NEWCELL
#define SCM_NEWCELL(x) ((x) = scm_cons (SCM_UNDEFINED, SCM_UNDEFINED))
#endif

#ifndef SCM_SETGC8MARK
#define SCM_SETGC8MARK(x) ((void)0)
#endif

#ifndef SCM_GC8MARKP
#define SCM_GC8MARKP(x) (0)
#endif

#ifdef scm_sizet
#undef scm_sizet
#endif
typedef size_t scm_sizet;

static inline SCM gh_bool2scm (int x) { return scm_from_bool (x); }
static inline SCM gh_char2scm (char x) { return scm_from_char (x); }
static inline SCM gh_int2scm (int x) { return scm_from_int (x); }
static inline SCM gh_long2scm (long x) { return scm_from_long (x); }
static inline SCM gh_ulong2scm (unsigned long x) { return scm_from_ulong (x); }
static inline SCM gh_double2scm (double x) { return scm_from_double (x); }
static inline SCM gh_str02scm (char *x) { return scm_from_locale_string (x ? x : ""); }
static inline SCM gh_str2scm (char *x, size_t len) { return scm_from_locale_stringn (x, len); }
static inline SCM gh_symbol2scm (char *x) { return scm_from_locale_symbol (x); }

static inline int gh_scm2bool (SCM x) { return scm_to_bool (x); }
static inline char gh_scm2char (SCM x) { return scm_to_char (x); }
static inline int gh_scm2int (SCM x) { return scm_to_int (x); }
static inline long gh_scm2long (SCM x) { return scm_to_long (x); }
static inline unsigned long gh_scm2ulong (SCM x) { return scm_to_ulong (x); }
static inline double gh_scm2double (SCM x) { return scm_to_double (x); }
static inline char *gh_scm2newstr (SCM x, size_t *lenp) { return scm_to_locale_stringn (x, lenp); }
static inline char *gh_symbol2newstr (SCM x, size_t *lenp) { return scm_to_locale_stringn (scm_symbol_to_string (x), lenp); }

static inline int gh_boolean_p (SCM x) { return scm_is_bool (x); }
static inline int gh_symbol_p (SCM x) { return scm_is_symbol (x); }
static inline int gh_char_p (SCM x) { return SCM_CHARP (x); }
static inline int gh_vector_p (SCM x) { return scm_is_vector (x); }
static inline int gh_pair_p (SCM x) { return scm_is_pair (x); }
static inline int gh_number_p (SCM x) { return scm_is_number (x); }
static inline int gh_string_p (SCM x) { return scm_is_string (x); }
static inline int gh_procedure_p (SCM x) { return scm_is_true (scm_procedure_p (x)); }
static inline int gh_list_p (SCM x) { return scm_is_true (scm_list_p (x)); }
static inline int gh_inexact_p (SCM x) { return scm_is_true (scm_inexact_p (x)); }
static inline int gh_exact_p (SCM x) { return scm_is_true (scm_exact_p (x)); }
static inline int gh_null_p (SCM x) { return scm_is_null (x); }

static inline SCM gh_car (SCM x) { return scm_car (x); }
static inline SCM gh_cdr (SCM x)
{
  if (scm_is_pair (x))
    return scm_cdr (x);
  return (SCM)SCM_SMOB_DATA (x);
}
static inline SCM gh_caar (SCM x) { return scm_caar (x); }
static inline SCM gh_cadr (SCM x) { return scm_cadr (x); }
static inline SCM gh_cdar (SCM x) { return scm_cdar (x); }
static inline SCM gh_caddr (SCM x) { return scm_caddr (x); }
static inline SCM gh_cadar (SCM x) { return scm_cadar (x); }
static inline SCM gh_cddar (SCM x) { return scm_cddar (x); }
static inline SCM gh_cons (SCM x, SCM y) { return scm_cons (x, y); }
static inline SCM gh_reverse (SCM x) { return scm_reverse (x); }
static inline SCM gh_append (SCM x) { return scm_append (x); }
static inline SCM gh_append2 (SCM a, SCM b) { return scm_append_x (scm_list_2 (a, b)); }
static inline SCM gh_append3 (SCM a, SCM b, SCM c) { return scm_append_x (scm_list_3 (a, b, c)); }
static inline SCM gh_append4 (SCM a, SCM b, SCM c, SCM d) { return scm_append_x (scm_list_4 (a, b, c, d)); }
static inline SCM gh_memq (SCM x, SCM y) { return scm_memq (x, y); }
static inline SCM gh_assq (SCM x, SCM y) { return scm_assq (x, y); }
static inline SCM gh_assv (SCM x, SCM y) { return scm_assv (x, y); }
static inline SCM gh_assoc (SCM x, SCM y) { return scm_assoc (x, y); }
static inline SCM gh_list_tail (SCM x, SCM k) { return scm_list_tail (x, k); }
static inline SCM gh_list_ref (SCM x, SCM k) { return scm_list_ref (x, k); }
static inline SCM gh_length (SCM x) { return scm_length (x); }

static inline int gh_eq_p (SCM x, SCM y) { return scm_is_eq (x, y); }
static inline int gh_eqv_p (SCM x, SCM y) { return scm_is_true (scm_eqv_p (x, y)); }
static inline int gh_equal_p (SCM x, SCM y) { return scm_is_true (scm_equal_p (x, y)); }
static inline int gh_string_equal_p (SCM x, SCM y) { return scm_is_true (scm_string_equal_p (x, y)); }

static inline SCM gh_eval_str (char *x) { return scm_c_eval_string (x); }
static inline SCM gh_eval_file (char *x) { return scm_c_primitive_load (x); }
static inline SCM gh_define (char *name, SCM value) { return scm_c_define (name, value); }
static inline SCM gh_lookup (char *name) { return scm_variable_ref (scm_c_lookup (name)); }
static inline SCM gh_call1 (SCM proc, SCM a) { return scm_call_1 (proc, a); }
static inline SCM gh_call3 (SCM proc, SCM a, SCM b, SCM c) { return scm_call_3 (proc, a, b, c); }
static inline SCM gh_apply (SCM proc, SCM args) { return scm_apply_0 (proc, args); }
static inline void gh_display (SCM x) { scm_display (x, scm_current_output_port ()); }
static inline void gh_write (SCM x) { scm_write (x, scm_current_output_port ()); }
static inline void gh_newline (void) { scm_newline (scm_current_output_port ()); }

static inline SCM gh_get_substr (SCM str, char *dst, int start, int len)
{
  char *src = scm_to_locale_string (str);
  memcpy (dst, src + start, len);
  free (src);
  return SCM_UNSPECIFIED;
}

static inline void gh_defer_ints (void) {}
static inline void gh_allow_ints (void) {}

static inline SCM gh_catch (SCM tag, scm_t_catch_body body, void *body_data,
                            scm_t_catch_handler handler, void *handler_data)
{
  return scm_c_catch (tag, body, body_data, handler, handler_data, NULL, NULL);
}

struct gh_enter_data {
  int argc;
  char **argv;
  void (*main_func) (int, char **);
};

static inline void *gh_enter_trampoline (void *data)
{
  struct gh_enter_data *enter_data = (struct gh_enter_data *) data;
  enter_data->main_func (enter_data->argc, enter_data->argv);
  return NULL;
}

static inline void gh_enter (int argc, char **argv, void (*main_func) (int, char **))
{
  struct gh_enter_data data = { argc, argv, main_func };
  scm_with_guile (gh_enter_trampoline, &data);
}

#endif
