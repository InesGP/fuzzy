# Makefile for the instrumented shared library

CC = verificarlo-c 
TRACER_FLAGS = --tracer --tracer-debug-mode --tracer-level=temporary
DEBUG_FLAGS = --save-temps --verbose -g
CFLAGS = -Wall -fPIC --verbose  # C flags
LDFLAGS = -shared -ldl # linking flags
LIBS= -ldl
RM = rm -f 

TARGET_LIB = libmath.so  # target lib

SRCS = src/wrapping_script.c  # source files
OBJS = $(SRCS:.c=.o)
ROOT = $(PWD)

ifdef CONSERVATIVE
CFLAGS += --conservative
endif

.PHONY: tracer

$(TARGET_LIB): $(OBJS)
	$(CC) ${LDFLAGS} ${CFLAGS} ${LIBS} -o $@ $^

tracer:
	$(CC) ${TRACER_FLAGS} ${CFLAGS} ${LDFLAGS} ${LIBS} -o ${TARGET_LIB} $(SRCS)

clean:
	-${RM} ${TARGET_LIB} ${OBJS} $(SRCS:.c=.d) .vfcwrapper*

