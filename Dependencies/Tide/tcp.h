/*

  Copyright (c) 2015 Martin Sustrik

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"),
  to deal in the Software without restriction, including without limitation
  the rights to use, copy, modify, merge, publish, distribute, sublicense,
  and/or sell copies of the Software, and to permit persons to whom
  the Software is furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included
  in all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
  IN THE SOFTWARE.

*/

#ifndef TIDE_H_INCLUDED
#define TIDE_H_INCLUDED

#include <errno.h>
#include <stddef.h>
#include <stdint.h>

/******************************************************************************/
/*  Symbol visibility                                                         */
/******************************************************************************/

#if defined TIDE_NO_EXPORTS
#   define TIDE_EXPORT
#else
#   if defined _WIN32
#      if defined TIDE_EXPORTS
#          define TIDE_EXPORT __declspec(dllexport)
#      else
#          define TIDE_EXPORT __declspec(dllimport)
#      endif
#   else
#      if defined __SUNPRO_C
#          define TIDE_EXPORT __global
#      elif (defined __GNUC__ && __GNUC__ >= 4) || \
             defined __INTEL_COMPILER || defined __clang__
#          define TIDE_EXPORT __attribute__ ((visibility("default")))
#      else
#          define TIDE_EXPORT
#      endif
#   endif
#endif

/******************************************************************************/
/*  IP address library                                                        */
/******************************************************************************/

#define IPADDR_IPV4 1
#define IPADDR_IPV6 2
#define IPADDR_PREF_IPV4 3
#define IPADDR_PREF_IPV6 4

typedef struct {char data[32];} ipaddr;

TIDE_EXPORT ipaddr iplocal(const char *name, int port, int mode);
TIDE_EXPORT ipaddr ipremote(const char *name, int port, int mode);

/******************************************************************************/
/*  TCP library                                                               */
/******************************************************************************/

typedef struct tide_tcpsock *tcpsock;

TIDE_EXPORT tcpsock tcplisten(ipaddr addr, int backlog);
TIDE_EXPORT int tcpport(tcpsock s);
TIDE_EXPORT tcpsock tcpaccept(tcpsock s);
TIDE_EXPORT tcpsock tcpconnect(ipaddr addr);
TIDE_EXPORT size_t tcpsend(tcpsock s, const void *buf, size_t len);
TIDE_EXPORT void tcpflush(tcpsock s);
TIDE_EXPORT size_t tcprecv(tcpsock s, void *buf, size_t len);
TIDE_EXPORT size_t tcprecvuntil(tcpsock s, void *buf, size_t len, const char *delims, size_t delimcount);
TIDE_EXPORT void tcpclose(tcpsock s);
TIDE_EXPORT tcpsock tcpattach(int fd, int listening);
TIDE_EXPORT int tcpdetach(tcpsock s);
TIDE_EXPORT int tcpfd(tcpsock s);

#endif

