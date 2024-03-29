# You must select the correct terminal control system to be used to
# turn character echo off when reading passwords.  There a 5 systems
# SGTTY   - the old BSD system
# TERMIO  - most system V boxes
# TERMIOS - SGI (ala IRIX).
# VMS     - the DEC operating system
# MSDOS   - we all know what it is :-)
# read_pwd.c makes a reasonable guess at what is correct.

# Targets
# make 		- twidle the options yourself :-)
# make cc	- standard cc options
# make gcc	- standard gcc options
# make x86-elf	- linux-elf etc
# make x86-out	- linux-a.out, FreeBSD etc
# make x86-solaris
# make x86-bdsi

# If you are on a DEC Alpha, edit des.h and change the DES_LONG
# define to 'unsigned int'.  I have seen this give a %20 speedup.

OPTS0= -DRAND -DTERMIO #-DNOCONST

# Version 1.94 has changed the strings_to_key function so that it is
# now compatible with MITs when the string is longer than 8 characters.
# If you wish to keep the old version, uncomment the following line.
# This will affect the -E/-D options on des(1).
#OPTS1= -DOLD_STR_TO_KEY

# There are 4 possible performance options
# -DDES_PTR
# -DDES_RISC1
# -DDES_RISC2 (only one of DES_RISC1 and DES_RISC2)
# -DDES_UNROLL
# after the initial build, run 'des_opts' to see which options are best
# for your platform.  There are some listed in options.txt
#OPTS2= -DDES_PTR
#OPTS3= -DDES_RISC1 # or DES_RISC2
#OPTS4= -DDES_UNROLL

OPTS= $(OPTS0) $(OPTS1) $(OPTS2) $(OPTS3) $(OPTS4)

CC=cc
CFLAGS= -D_HPUX_SOURCE -Aa +O2 $(OPTS) $(CFLAG)

#CC=gcc
#CFLAGS= -O3 -fomit-frame-pointer $(OPTS) $(CFLAG)

CPP=$(CC) -E

DES_ENC=des_enc.o	# normal C version
#DES_ENC=asm/dx86-elf.o	# elf format x86
#DES_ENC=asm/dx86-out.o	# a.out format x86
#DES_ENC=asm/dx86-sol.o	# solaris format x86
#DES_ENC=asm/dx86bsdi.o	# bsdi format x86

LIBDIR=/usr/local/lib
BINDIR=/usr/local/bin
INCDIR=/usr/local/include
MANDIR=/usr/local/man
MAN1=1
MAN3=3
SHELL=/bin/sh
OBJS=	cbc3_enc.o cbc_cksm.o cbc_enc.o ncbc_enc.o pcbc_enc.o qud_cksm.o \
	cfb64ede.o cfb64enc.o cfb_enc.o ecb3_enc.o ecb_enc.o  ede_enc.o  \
	enc_read.o enc_writ.o fcrypt.o  ofb64ede.o ofb64enc.o ofb_enc.o  \
	rand_key.o read_pwd.o set_key.o rpc_enc.o  str2key.o supp.o \
	$(DES_ENC) xcbc_enc.o

GENERAL=$(GENERAL_LIT) FILES Imakefile times vms.com KERBEROS MODES.DES \
	GNUmakefile des.man DES.pm DES.pod DES.xs Makefile.PL \
	Makefile.uni typemap t Makefile.ssl makefile.bc Makefile.lit \
	des.org des_locl.org
DES=	des.c
TESTING=rpw.c $(TESTING_LIT)
HEADERS= $(HEADERS_LIT) rpc_des.h
LIBDES= cbc_cksm.c pcbc_enc.c qud_cksm.c \
	cfb64ede.c cfb64enc.c cfb_enc.c ecb3_enc.c  cbc3_enc.c  \
	enc_read.c enc_writ.c ofb64ede.c ofb64enc.c ofb_enc.c  \
	rand_key.c rpc_enc.c  str2key.c  supp.c \
	xcbc_enc.c $(LIBDES_LIT) read_pwd.c

TESTING_LIT=destest.c speed.c des_opts.c
GENERAL_LIT=COPYRIGHT INSTALL README VERSION Makefile des_crypt.man \
	des.doc options.txt asm
HEADERS_LIT=des_ver.h des.h des_locl.h podd.h sk.h spr.h
LIBDES_LIT=ede_enc.c cbc_enc.c ncbc_enc.c ecb_enc.c fcrypt.c set_key.c des_enc.c

PERL=	des.pl testdes.pl doIP doPC1 doPC2 PC1 PC2 shifts.pl

ALL=	$(GENERAL) $(DES) $(TESTING) $(LIBDES) $(PERL) $(HEADERS)

DLIB=	libdes.a

all: $(DLIB) destest rpw des speed des_opts

cc:
	make CC=cc CFLAGS="-O $(OPTS) $(CFLAG)" all

gcc:
	make CC=gcc CFLAGS="-O3 -fomit-frame-pointer $(OPTS) $(CFLAG)" all

x86-elf:
	make DES_ENC=asm/dx86-elf.o CC=gcc CFLAGS="-DELF -O3 -fomit-frame-pointer $(OPTS) $(CFLAG)" all

x86-out:
	make DES_ENC=asm/dx86-out.o CC=gcc CFLAGS="-DOUT -O3 -fomit-frame-pointer $(OPTS) $(CFLAG)" all

x86-solaris:
	make DES_ENC=asm/dx86-sol.o CFLAGS="-DSOL -O  $(OPTS) $(CFLAG)" all

x86-bsdi:
	make DES_ENC=asm/dx86bsdi.o CC=gcc CFLAGS="-DBSDI -O3 -fomit-frame-pointer $(OPTS) $(CFLAG)" all

asm/dx86-elf.o: asm/dx86-cpp.s asm/dx86unix.cpp
	$(CPP) -DELF asm/dx86unix.cpp | as -o asm/dx86-elf.o

asm/dx86-sol.o: asm/dx86-cpp.s asm/dx86unix.cpp
	$(CPP) -DSOL asm/dx86unix.cpp | as -o asm/dx86-sol.o

asm/dx86-out.o: asm/dx86-cpp.s asm/dx86unix.cpp
	$(CPP) -DOUT asm/dx86unix.cpp | as -o asm/dx86-out.o

asm/dx86bsdi.o: asm/dx86-cpp.s asm/dx86unix.cpp
	$(CPP) -DBSDI asm/dx86unix.cpp | as -o asm/dx86bsdi.o

test:	all
	./destest

$(DLIB): $(OBJS)
	/bin/rm -f $(DLIB)
	ar cr $(DLIB) $(OBJS)
	-if test -s /bin/ranlib; then /bin/ranlib $(DLIB); \
	else if test -s /usr/bin/ranlib; then /usr/bin/ranlib $(DLIB); \
	else exit 0; fi; fi

des_opts: des_opts.o libdes.a
	$(CC) $(CFLAGS) -o des_opts des_opts.o libdes.a

destest: destest.o libdes.a
	$(CC) $(CFLAGS) -o destest destest.o libdes.a

rpw: rpw.o libdes.a
	$(CC) $(CFLAGS) -o rpw rpw.o libdes.a

speed: speed.o libdes.a
	$(CC) $(CFLAGS) -o speed speed.o libdes.a

des: des.o libdes.a
	$(CC) $(CFLAGS) -o des des.o libdes.a

tags:
	ctags $(DES) $(TESTING) $(LIBDES)

tar_lit:
	/bin/mv Makefile Makefile.tmp
	/bin/cp Makefile.lit Makefile
	tar chf libdes-l.tar $(LIBDES_LIT) $(HEADERS_LIT) \
		$(GENERAL_LIT) $(TESTING_LIT)
	/bin/rm -f Makefile
	/bin/mv Makefile.tmp Makefile

tar:
	tar chf libdes.tar $(ALL)

shar:
	shar $(ALL) >libdes.shar

depend:
	makedepend $(LIBDES) $(DES) $(TESTING)

clean:
	/bin/rm -f *.o tags core rpw destest des speed $(DLIB) .nfs* *.old \
	*.bak destest rpw des_opts asm/*.o

dclean:
	sed -e '/^# DO NOT DELETE THIS LINE/ q' Makefile >Makefile.new
	mv -f Makefile.new Makefile

# Eric is probably going to choke when he next looks at this --tjh
install: $(DLIB) des
	if test $(INSTALLTOP); then \
	    echo SSL style install; \
	    cp $(DLIB) $(INSTALLTOP)/lib; \
	    if test -s /bin/ranlib; then \
	        /bin/ranlib $(INSTALLTOP)/lib/$(DLIB); \
	    else \
		if test -s /usr/bin/ranlib; then \
		/usr/bin/ranlib $(INSTALLTOP)/lib/$(DLIB); \
	    fi; fi; \
	    chmod 644 $(INSTALLTOP)/lib/$(DLIB); \
	    cp des.h $(INSTALLTOP)/include; \
	    chmod 644 $(INSTALLTOP)/include/des.h; \
	    cp des $(INSTALLTOP)/bin; \
	    chmod 755 $(INSTALLTOP)/bin/des; \
	else \
	    echo Standalone install; \
	    cp $(DLIB) $(LIBDIR)/$(DLIB); \
	    if test -s /bin/ranlib; then \
	      /bin/ranlib $(LIBDIR)/$(DLIB); \
	    else \
	      if test -s /usr/bin/ranlib; then \
		/usr/bin/ranlib $(LIBDIR)/$(DLIB); \
	      fi; \
	    fi; \
	    chmod 644 $(LIBDIR)/$(DLIB); \
	    cp des $(BINDIR)/des; \
	    chmod 711 $(BINDIR)/des; \
	    cp des_crypt.man $(MANDIR)/man$(MAN3)/des_crypt.$(MAN3); \
	    chmod 644 $(MANDIR)/man$(MAN3)/des_crypt.$(MAN3); \
	    cp des.man $(MANDIR)/man$(MAN1)/des.$(MAN1); \
	    chmod 644 $(MANDIR)/man$(MAN1)/des.$(MAN1); \
	    cp des.h $(INCDIR)/des.h; \
	    chmod 644 $(INCDIR)/des.h; \
	fi
# DO NOT DELETE THIS LINE -- make depend depends on it.
