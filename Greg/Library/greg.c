
#include "config.h"

#ifdef	HAVE_SIGNAL_H
#include <signal.h>
#endif
#ifdef	HAVE_SYS_FILE_H
#include <sys/file.h>
#endif
#ifdef	HAVE_SYS_FCNTL_H
#include <sys/fcntl.h>
#endif
#ifdef	HAVE_SYS_IOCTL_H
#include <sys/ioctl.h>
#endif
#ifdef	HAVE_SYS_WAIT_H
#include <sys/wait.h>
#endif

#include <libguile.h>

/*
 *	If we are on a streams based system, we need to include stropts.h
 *	for definitions needed to set up slave pseudo-terminal stream.
 */
#ifdef	HAVE_SYS_STROPTS_H
#include <sys/stropts.h>
#endif

#ifndef	MAX_OPEN
#define	MAX_OPEN	64
#endif

static int
pty_master(char* name, int len)
{
  int	master;

  /*
   *	If we have grantpt(), assume we are using sysv-style pseudo-terminals,
   *	otherwise assume bsd style.
   */
#ifdef	HAVE_GRANTPT
  master = open("/dev/ptmx", O_RDWR);
  if (master >= 0)
    {
      const char	*slave;

      grantpt(master);                   /* Change permission of slave.  */
      unlockpt(master);                  /* Unlock slave.        */
      slave = ptsname(master);
      if (slave == 0 || strlen(slave) >= len)
	{
	  close(master);
	  master = -1;
	}
      else
	{
	  strcpy(name, (char*)slave);
	}
    }
#else
  const char	*groups = "pqrstuvwxyzPQRSTUVWXYZ";

  master = -1;
  if (len > 10)
    {
      strcpy(name, "/dev/ptyXX");
      while (master < 0 && *groups != '\0')
	{
	  int	i;

	  name[8] = *groups++;
	  for (i = 0; i < 16; i++)
	    {
	      name[9] = "0123456789abcdef"[i];
	      master = open(name, O_RDWR);
	      if (master >= 0)
		{
		  name[5] = 't';
		  break;
		}
	    }
	}
    }
#endif
  return master;
}

static int
pty_slave(const char* name)
{
  int	slave;

  slave = open(name, O_RDWR);
#ifdef	HAVE_SYS_STROPTS_H
  if (ioctl(slave, I_PUSH, "ptem") < 0)
    {
      (void)close(slave);
      slave = -1;
    }
  if (ioctl(slave, I_PUSH, "ldterm") < 0)
    {
      (void)close(slave);
      slave = -1;
    }
#endif
  return slave;
}

static char	s_pty_child[] = "pty-child";

static SCM
scm_pty_child(SCM args)
{
  SCM	ans = SCM_EOL;
  SCM	prg;
  char	slave_name[32];
  int	master;

  prg = SCM_CAR(args);
  /*
   *	We permit this to be called either with multiple string arguments
   *	or with a list of arguments.
   */
  while (scm_list_p(prg) == SCM_BOOL_T && SCM_CDR(args) == SCM_EOL)
    {
      args = prg;
      prg = SCM_CAR(args);
    }
  SCM_ASSERT (SCM_NIMP(prg) && SCM_STRINGP(prg), prg, SCM_ARG1, s_pty_child);

  master = pty_master(slave_name, sizeof(slave_name));
  if (master >= 0)
    {
      int	p[2];
      int	pid;

      if (pipe(p) < 0)
	{
	  (void)close(master);
	  scm_misc_error("pty-child", "failed to open pipe", SCM_EOL);
	}
      pid = fork();
      if (pid < 0)
	{
	  (void)close(master);
	  (void)close(p[0]);
	  (void)close(p[1]);
	  scm_misc_error("pty-child", "failed to fork child pipe", SCM_EOL);
	}
      if (pid == 0)
	{
	  int	i;

	  for (i = 1; i < 32; i++)
	    {
	      signal(i, SIG_DFL);
	    }
	  if (p[1] != 3)
	    {
	      (void)dup2(p[1], 3);
	      p[1] = 3;
	    }
	  for (i = 0; i < MAX_OPEN; i++)
	    {
	      if (i != 2 && i != p[1])
		{
		  (void)close(i);
		}
	    }
	  i = -1;
#ifdef	HAVE_SETSID
	  i = setsid();
#endif
#ifdef	HAVE_SETPGID
	  if (i < 0)
	    {
	      i = getpid();
	      i = setpgid(i, i);
	    }
#endif
#ifdef	TIOCNOTTY
	  i = open("/dev/tty", O_RDWR);
	  if (i >= 0)
	    {
	      (void)ioctl(i, TIOCNOTTY, 0);
	      (void)close(i);
	    }
#endif
	  i = pty_slave(slave_name);
	  if (i < 0)
	    {
	      write(p[1], "-", 1);	/* Tell parent we failed.	*/
	      exit(1);			/* Failed to open slave!	*/
	    }
	  if (i != 0)
	    {
	      (void)dup2(i, 0);
	    }
	  if (i != 1)
	    {
	      (void)dup2(i, 1);
	    }
	  if (i > 1)
	    {
	      (void)close(i);
	    }
	  (void)write(p[1], "*", 1);	/* Tell parent we are ready.	*/
	  (void)close(p[1]);
	  (void)dup2(1, 2);
#if	HAVE_RECENT_GUILE
	  if (scm_string_equal_p(prg, gh_str02scm("")) != SCM_BOOL_T)
	    {
	      scm_execl(prg, args);
	      exit(1);
	    }
#else
	  if (scm_string_equal_p(prg, gh_str02scm("")) != SCM_BOOL_T)
	    {
	      scm_execl(scm_cons(prg, args));
	      exit(1);
	    }
#endif
	  else
	    {
	      /*
	       *	Program name is an empty string - don't exec a
	       *	child, just return a list containing 0 to mark
	       *	this as a success (but in the child process).
	       */
	      ans = scm_cons(SCM_MAKINUM(0), SCM_EOL);
	    }
	}
      else
	{
	  char	info;
	  int	len;
	  SCM	cpid;
	  SCM	rport;
	  SCM	wport;

	  (void)close(p[1]);
	  /*
	   *	Synchronize with child process - it should send us a byte
	   *	when everything is set up - immediately before the exec.
	   */
	  len = read(p[0], &info, 1);
	  (void)close(p[0]);
	  if (len != 1)
	    {
	      (void)close(master);
#ifdef HAVE_WAITPID
	      {
		int	status;
		int	opts = 0;
		(void)waitpid(pid, &status, opts);
	      }
#endif
	      scm_misc_error("pty-child", "failed to sync with child",
			SCM_EOL);
	    }
	  if (info == '-')
	    {
	      scm_misc_error("pty-child", "child failed to open pty",
			SCM_EOL);
	    }
	  cpid = SCM_MAKINUM(pid);
	  rport = scm_fdopen(SCM_MAKINUM(master), scm_makfrom0str("r"));
	  wport = scm_fdopen(SCM_MAKINUM(master), scm_makfrom0str("w"));
	  ans = scm_cons(rport, scm_cons(wport, scm_cons(cpid, SCM_EOL)));
	}
    }
  else
    {
      scm_misc_error("pty-child", "failed to get master pty", SCM_EOL);
    }
  return ans;
}

void
greg_init()
{
  scm_make_gsubr(s_pty_child, 0, 0, 1, scm_pty_child);
}

void
scm_init_greg_compiled_module()
{
  scm_register_module_xxx ("greg compiled", greg_init);
}

