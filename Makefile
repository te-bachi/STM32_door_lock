
LOUD = 1

global_CFLAGS               = -Iinclude -pipe -std=gnu99 \
                              -ffunction-sections -fdata-sections -fms-extensions \
                              -Wall -Wmissing-prototypes -Wno-uninitialized -Wstrict-prototypes
global_LDFLAGS              = -g --gc-sections -static

debug_CFLAGS                = -ggdb
debug_LDFLAGS               = 

release_CFLAGS              = -flto -Os
release_LDFLAGS             = -flto -Os

### PROGRAMS ##################################################################

PROGRAMS                    = door_lock

### DOOR LOCK #################################################################

door_lock_LDSCRIPT        	= ldscripts/libs.ld \
                              ldscripts/mem.ld \
                              ldscripts/sections.ld
door_lock_CFLAGS            = 
door_lock_LDFLAGS           = 
door_lock_SOURCE            = main.c \
                              mfrc522.cpp \
                              bla.c

### LIBRARIES #################################################################

LIBRARIES_STATIC 			= cmsis.a

### CMSIS #####################################################################

cmsis.a_SOURCE				= 


include autogen.mk

