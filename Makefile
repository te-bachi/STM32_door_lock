
LOUD                        = 1
BUILD                       = debug

### COMPILER AND LINKER FLAGS #################################################
global_CFLAGS               = -Iinclude -pipe -std=gnu99 \
                              -ffunction-sections -fdata-sections -fms-extensions \
                              -Wall -Wmissing-prototypes -Wno-uninitialized -Wstrict-prototypes
global_CXXFLAGS             = -Iinclude -pipe \
                              -ffunction-sections -fdata-sections -fms-extensions \
                              -Wall -Wno-uninitialized
global_LDFLAGS              = -g --gc-sections -static

### BUILD TYPES ###############################################################
debug_CFLAGS                = -ggdb
debug_LDFLAGS               = 

release_CFLAGS              = -flto -Os
release_LDFLAGS             = -flto -Os

### PROGRAMS ##################################################################
PROGRAMS                    = door_lock


### LIBRARIES #################################################################
LIBRARIES_STATIC 			= cmsis.a


### DOOR LOCK #################################################################
door_lock_LDSCRIPT        	= ldscripts/libs.ld \
                              ldscripts/mem.ld \
                              ldscripts/sections.ld
door_lock_CFLAGS            = 
door_lock_LDFLAGS           = 
door_lock_LIBRARIES         = $(LIBRARIES_STATIC)
door_lock_SOURCE            = main.c \
                              mfrc522.cpp \
                              bla.c

                              
### CMSIS #####################################################################
cmsis.a_PATH                = system
cmsis.a_CFLAGS              = -Isystem/include/stm32f1-stdperiph \
                              -Isystem/include/cmsis \
                              -DDEBUG -DUSE_FULL_ASSERT -DTRACE \
                              -DOS_USE_TRACE_SEMIHOSTING_DEBUG -DSTM32F10X_MD \
                              -DUSE_STDPERIPH_DRIVER -DHSE_VALUE=8000000 
cmsis.a_SOURCE				= stm32f1-stdperiph/misc.c \
                              stm32f1-stdperiph/stm32f10x_adc.c \
                              stm32f1-stdperiph/stm32f10x_bkp.c


include autogen.mk

