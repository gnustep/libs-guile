/* greg.c
   Copyright (C) 1998 Free Software Foundation, Inc.
   
   Written by:  Richard frith-Macdonald <rfm@gnu.org>
   Date: 1998
   
   This file is part of the Greg package - part of the GNUstep project.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.
   
   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.
   
   You should have received a copy of the GNU Lesser General Public
   License along with this library; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
   */ 

#include "config.h"

#if	HAVE_SIGNAL_H
#include <signal.h>
#endif
#if	HAVE_SYS_FILE_H
#include <sys/file.h>
#endif
#if	HAVE_SYS_FCNTL_H
#include <sys/fcntl.h>
#endif
#if	HAVE_SYS_IOCTL_H
#include <sys/ioctl.h>
#endif
#if	HAVE_SYS_WAIT_H
#include <sys/wait.h>
#endif

#include <libguile.h>

/*
 *	If we are on a streams based system, we need to include stropts.h
 *	for definitions needed to set up slave pseudo-terminal stream.
 */
#if	HAVE_SYS_STROPTS_H
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
#if	HAVE_GRANTPT
  master = open("/dev/ptmx", O_RDWR);
  if (master >= 0)
    {
      const char	*slave;

      grantpt(master);                   /* Change permission of slave.  */
      unlockpt(master);                  /* Unlock slave.        */
      slave = (const char*)ptsname(master);
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
  else
#endif
    {
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
    }
  return master;
}

static int
pty_slave(const char* name)
{
  int	slave;

  slave = open(name, O_RDWR);
#if	HAVE_SYS_STROPTS_H
#if	HAVE_PTS_STREAM_MODULES
  if (slave >= 0 && isastream(slave))
    {
      if (ioctl(slave, I_PUSH, "ptem") < 0)
	{
	  perror("unable to push 'ptem' streams module");
	}
      else if (ioctl(slave, I_PUSH, "ldterm") < 0)
	{
	  perror("unable to push 'ldterm' streams module");
	}
    }
#endif
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
	  int	s;

	  for (i = 1; i < 32; i++)
	    {
	      signal(i, SIG_DFL);
	    }

	  s = pty_slave(slave_name);
	  if (s < 0)
	    {
	      extern int	errno;
	      char		buf[256];
	      int		len;
#if	HAVE_STRERROR
	      const char	*msg = strerror(errno);
#else
	      char		msg[32];

	      sprintf(msg, "system error %d", errno);
#endif

	      len = strlen(msg);
	      if (len > 255)
		len = 255;
	      buf[0] = len;
	      memcpy(&buf[1], msg, len);
	      write(p[1], buf, len+1);	/* Tell parent we failed.	*/
	      exit(1);			/* Failed to open slave!	*/
	    }

	  for (i = 0; i < MAX_OPEN; i++)
	    {
	      if (i != s && i != 2 && i != p[1])
		{
		  (void)close(i);
		}
	    }

	  i = -1;
#if	HAVE_SETSID
	  i = setsid();
#endif
#if	HAVE_SETPGID
	  if (i < 0)
	    {
	      i = getpid();
	      i = setpgid(i, i);
	    }
#endif
#if	TIOCNOTTY
	  i = open("/dev/tty", O_RDWR);
	  if (i >= 0)
	    {
	      (void)ioctl(i, TIOCNOTTY, 0);
	      (void)close(i);
	    }
#endif

	  /*
	   * Make sure pty operates on stdin and stdout.
	   * If the pipe to our parent is on stdin or stdout, duplicate
	   * it so that it doesn't get closed prematurely.
           */
	  if (s != 0)
	    {
	      if (p[1] == 0)
		p[1] = dup(p[1]);
	      (void)dup2(s, 0);
	    }
	  if (s != 1)
	    {
	      if (p[1] == 1)
		p[1] = dup(p[1]);
	      (void)dup2(s, 1);
	    }

	  /*
	   * Discard original descriptor - we no longer need it.
	   */
	  if (s > 1)
	    {
	      (void)close(s);
	    }

	  (void)write(p[1], "", 1);	/* Tell parent we are ready.	*/
	  (void)close(p[1]);
	  (void)dup2(1, 2);		/* Send stderr to pty.		*/

	  if (scm_string_equal_p(prg, gh_str02scm("")) != SCM_BOOL_T)
	    {
	      scm_execl(prg, args);
	      exit(1);
	    }
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
	  unsigned char	info;
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
	  if (len != 1)
	    {
	      (void)close(p[0]);
	      (void)close(master);
#if	HAVE_WAITPID
	      {
		int	status;
		int	opts = 0;
		(void)waitpid(pid, &status, opts);
	      }
#endif
	      scm_misc_error("pty-child", "failed to sync with child",
			SCM_EOL);
	    }
	  if (info == '\0')
	    {
	      (void)close(p[0]);
	    }
	  else
	    {
	      char	buf[1024];
	      int	base;

	      sprintf(buf, "child failed to open %s: ", slave_name);
	      base = strlen(buf);
	
	      len = read(p[0], &buf[base], (int)info);
	      if (len > 0)
		{
		  buf[base+len] = '\0';
		}
	      else
		{
		  strcat(buf, "unknown error");
		}
	      (void)close(p[0]);
	      scm_misc_error("pty-child", buf, SCM_EOL);
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
scm_init_greg()
{
  scm_make_gsubr(s_pty_child, 0, 0, 1, scm_pty_child);
  scm_add_feature("greg-pty");
}

