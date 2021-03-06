CFILEROOT = ${abspath ../../}
UTEROOT   = ${abspath ../../../../UnitTestEngine}
SRCROOT   = ${abspath ../../../../../../src}
RBROOT    = ${abspath ../../../../../../libs/rb_tree}
SQROOT    = ${abspath ../../../../../../libs/squashfs_compressor}
YAMLROOT  = ${abspath ../../../../../../libs/yaml}

INC  = -I./inc -I${CFILEROOT}/inc -I${CFILEROOT}/src -I${UTEROOT}/inc -I${SRCROOT}
INC += -I${RBROOT} -I${YAMLROOT}/include
LIBS  = -L ${RBROOT} -lrb_tree
LIBS += -L ${SQROOT} -lsquashfs_compressor
LIBS += -L ${YAMLROOT} -lyamlaxfs

CFLAGS = -fPIC -Wall -g -O2

ifeq ($(firstword $(shell uname -a)),Linux)
	#Extras required for GNUstep on Ubuntu not for Mac where I did most dev work
	INC += -I/usr/local/include/GNUstep
	INC += -I/usr/include/GNUstep
	LIBS += -L /usr/lib/GNUstep -lgnustep-base -lobjc -lm -lc
	CFLAGS += -MMD -MP -DGNUSTEP -DGNUSTEP_BASE_LIBRARY=1 -DGNU_GUI_LIBRARY=1 -DGNU_RUNTIME=1 -DGNUSTEP_BASE_LIBRARY=1 -fno-strict-aliasing -fexceptions -fobjc-exceptions -D_NATIVE_OBJC_EXCEPTIONS -DGSWARN -DGSDIAGNOSE -Wno-import -fgnu-runtime -fconstant-string-class=NSConstantString
else
	LIBS += -framework Foundation
endif

.SUFFIXES: .o .m
.m.o:

all:
	${CC} ${CFLAGS} ${INC} -c ../../src/wrapper.m -o ../../src/wrapper.o
	${CC} -shared -lc -g -o ../../src/libtest.so ../../src/wrapper.o ${LIBS}

clean:
	rm -rf ../../src/*.o ../../src/lib*.* 
	rm -rf ./Makefile~ ./core

clobber: clean