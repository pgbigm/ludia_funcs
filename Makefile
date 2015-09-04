MODULE_big = ludia_funcs
OBJS = ludia_funcs.o ludia_tp.o

EXTENSION = ludia_funcs
DATA = ludia_funcs--1.0.sql

REGRESS = ludia_funcs

EXTRA_CLEAN = sql/textporter.sql expected/textporter.out

SENNA_CFG = senna-cfg
SENNA_LIBS = $(shell $(SENNA_CFG) --libs)
SENNA_LIBPATH := $(patsubst -L%,%,$(filter -L%,$(SENNA_LIBS)))
SENNA_CFLAGS = $(shell $(SENNA_CFG) --cflags)
SENNA_VERSION := $(subst .,,$(shell $(SENNA_CFG) --version))

PG_CPPFLAGS += -DSENNA_VERSION=$(SENNA_VERSION) $(SENNA_CFLAGS)
SHLIB_LINK += -Wl,-rpath,'$(SENNA_LIBPATH)' $(SENNA_LIBS)

ifdef TEXTPORTER
PG_CPPFLAGS += -DDMC_LINUX_X86_64 -DTEXTPORTER -I$(TEXTPORTER)/Include
SHLIB_LINK += -L$(TEXTPORTER)/Lib -ldmc_txif
REGRESS += textporter
endif

ifdef PGS2_DEBUG
PG_CPPFLAGS += -DPGS2_DEBUG
REGRESS += pgs2-debug
endif

ifdef USE_PGXS
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
else
subdir = contrib/ludia_funcs
top_builddir = ../..
include $(top_builddir)/src/Makefile.global
include $(top_srcdir)/contrib/contrib-global.mk
endif

installcheck-bigm:
	$(pg_regress_installcheck) $(REGRESS_OPTS) pg_bigm
