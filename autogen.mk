
.SUFFIXES:

.PHONY: all clean mkdirs Makefile autogen.mk

CPU                 = cortex-m3
CODE_GEN            = thumb

COMPILER_PREFIX     = arm-none-eabi
CC                  = ${COMPILER_PREFIX}-gcc
CXX                 = ${COMPILER_PREFIX}-g++
LD                  = ${COMPILER_PREFIX}-ld
OBJCOPY             = ${COMPILER_PREFIX}-objcopy
OBJDUMP             = ${COMPILER_PREFIX}-objdump
BUILD               = debug release
ARCH                = -m$(CODE_GEN) -mcpu=$(CPU)

LIB_GCC_PATH        = ${shell ${CC} ${ARCH} ${CFLAGS} -print-libgcc-file-name}
LIBC_PATH           = ${shell ${CC} ${ARCH} ${CFLAGS} -print-file-name=libc.a}
LIBM_PATH           = ${shell ${CC} ${ARCH} ${CFLAGS} -print-file-name=libm.a}

global_CFLAGS      += 
global_LDFLAGS     += $(LIBM_PATH) $(LIBC_PATH) $(LIB_GCC_PATH)

OBJ_DIR             = obj
SRC_DIR             = src
BIN_DIR             = bin

ELF_SUFFIX          = .elf
HEX_SUFFIX          = .hex
BIN_SUFFIX          = .bin
LST_SUFFIX          = .lst

OBJCOPY_HEX_FLAGS   = -O ihex
OBJCOPY_BIN_FLAGS   = -O binary
OBJDUMP_FLAGS       = -S

C_SOURCE_FORMAT     = c
CXX_SOURCE_FORMAT   = cpp

### Quiet-mode
ifneq ($(LOUD),)
  SILENT = 
else
  SILENT = @
endif

### HELP ######################################################################
#
# target: dependencies
# [tab] system command
#
# target: normal-prerequisites | order-only-prerequisites
# [tab] recipe
#
# $(foreach var,list,text)      For each newly created variable 'var' in 'list',
#                               do whatever in 'text'
# $(call variable,param,...)    Call a defined subroutine
# $(1), $(2)                    Arguments of defined subroutines
# $(var:pattern=replacement)    Substitutes 'var' with 'replacement'
# $(eval var)                   Expand 'var' and parse as makefile syntax
# $(info var)                   Debug Makefile
# $(dir filename)               Extracts the directory-part of each filename
# $(addprefix prefix,names)     Add prefix to names, ex. $(addprefix src/,foo bar)
#                               Result: src/foo src/bar
# 

### FIRST TARGET: ALL #########################################################
all:
	@echo Use 'make debug' or 'make release'

### MKDIR FOR EVERY PROGRAM ###################################################
# $(1) = build type, ex. debug, release
# $(2) = program name

define DIRECTORY_template

DIRECTORIES += $(OBJ_DIR)/$(1)/$(2)

$(OBJ_DIR)/$(1)/$(2):
	@echo "[MKDIR] $$@"
	$(SILENT)mkdir -p $(OBJ_DIR)/$(1)/$(2)

endef

### SOURCE FOR EVERY PROGRAM ##################################################
# $(1) = build type, ex. debug, release
# $(2) = program name

define SOURCE_template

$(1)_$(2)_C_SOURCE   = $(filter %.$(C_SOURCE_FORMAT),$($(2)_SOURCE))
$(1)_$(2)_CXX_SOURCE = $(filter %.$(CXX_SOURCE_FORMAT),$($(2)_SOURCE))

endef


### OBJECT FOR EVERY PROGRAM ##################################################
# $(1) = build type, ex. debug, release
# $(2) = program name

define OBJECT_template

$(1)_$(2)_C_OBJECT   = $(addprefix obj/$(1)/$(2)/,$($(1)_$(2)_C_SOURCE:%.$(C_SOURCE_FORMAT)=%.o))
$(1)_$(2)_CXX_OBJECT = $(addprefix obj/$(1)/$(2)/,$($(1)_$(2)_CXX_SOURCE:%.$(CXX_SOURCE_FORMAT)=%.o))

# Create build directory to put objects into
$(foreach folder,$(addprefix $(2)/,$(sort $(dir $($(2)_SOURCE)))),$(eval $(call DIRECTORY_template,$(1),$(folder))))

endef

### COMPILE FOR EVERY SOURCE FILE ##############################################
# $(1) = build type, ex. debug, release
# $(2) = program name
# $(3) = source directory
# $(4) = one single source file
# $(5) = specific CFLAGS

#(info C_COMPILE)
#(info build type:             $(1))
#(info program name:           $(2))
#(info source directory:       $(3))
#(info one single source file: $($(4)))
#(info specific CFLAGS:        $($(5)))
#(info .)

define C_COMPILE_template

obj/$(1)/$(2)/$($(4):%.$(C_SOURCE_FORMAT)=%.o): obj/$(1)/$(2)/$(dir $($(4))) $(3)/$($(4))
	@echo "[CC   ] $(3)/$($(4))"
	$(SILENT)$(CC) $(ARCH) -o $$@ -c $(3)/$($(4)) $(global_CFLAGS) $($(5)) $($(2)_CFLAGS)

endef

define CXX_COMPILE_template

obj/$(1)/$(2)/$($(4):%.$(CXX_SOURCE_FORMAT)=%.o): obj/$(1)/$(2)/$(dir $($(4))) $(3)/$($(4))
	@echo "[CXX  ] $(3)/$($(4))"
	$(SILENT)$(CXX) $(ARCH) -o $$@ -c $(3)/$($(4)) $(global_CFLAGS) $($(5)) $($(2)_CFLAGS)

endef

### PROGRAM ###################################################################
# $(1) = build type, ex. debug, release
# $(2) = program name
# $(3) = install directory
# $(4) = specific CFLAGS
# $(5) = specific LDFLAGS

define PROGRAM_template

$(foreach source,$($(1)_$(2)_C_SOURCE),$(eval $(call C_COMPILE_template,$(1),$(2),$(SRC_DIR),source,$(4))))
$(foreach source,$($(1)_$(2)_CXX_SOURCE),$(eval $(call CXX_COMPILE_template,$(1),$(2),$(SRC_DIR),source,$(4))))

$(3)/$(1)/$(2)$(ELF_SUFFIX): $($(1)_$(2)_C_OBJECT) $($(1)_$(2)_CXX_OBJECT)
	@mkdir -p $(3)/$(1)
	
	@echo "[LD   ] $(3)/$(1)/$(2)$(ELF_SUFFIX)"
	$(SILENT)$(LD) $(addprefix -T ,$($(2)_LDSCRIPT)) -o $(3)/$(1)/$(2)$(ELF_SUFFIX) $($(1)_$(2)_C_OBJECT) $($(1)_$(2)_CXX_OBJECT) $(global_LDFLAGS) $($(5)) $($(2)_LDFLAGS)
	
	@echo "[HEX  ] $(3)/$(1)/$(2)$(HEX_SUFFIX)"
	$(SILENT)$(OBJCOPY) $(OBJCOPY_HEX_FLAGS) $(3)/$(1)/$(2)$(ELF_SUFFIX) $(3)/$(1)/$(2)$(HEX_SUFFIX)
	
	@echo "[BIN  ] $(3)/$(1)/$(2)$(BIN_SUFFIX)"
	$(SILENT)$(OBJCOPY) $(OBJCOPY_BIN_FLAGS) $(3)/$(1)/$(2)$(ELF_SUFFIX) $(3)/$(1)/$(2)$(BIN_SUFFIX)
	
	@echo "[LST  ] $(3)/$(1)/$(2)$(LST_SUFFIX)"
	$(SILENT)$(OBJDUMP) $(OBJDUMP_FLAGS) $(3)/$(1)/$(2)$(ELF_SUFFIX) > $(3)/$(1)/$(2)$(LST_SUFFIX)

$(1)_$(2)_clean:
	@echo "[CLEAR $(2)]"
	@$(SILENT)rm -rf $(2) $($(1)_$(2)_C_OBJECT) $($(1)_$(2)_CXX_OBJECT) obj/$(2)

endef

### BUILD #####################################################################
# $(1) = build type, ex. debug, release

define BUILD_template

# add prefix, ex. bin/debug to all PROGRAMS: prog.elf
$(1): $(foreach prog, $(PROGRAMS), $(addprefix $(BIN_DIR)/$(1),/$(prog)$(ELF_SUFFIX)))
	@echo [DONE ]

$(foreach prog, $(PROGRAMS), $(eval $(call SOURCE_template,$(1),$(prog),$(addprefix $(1),_CFLAGS))))
$(foreach prog, $(PROGRAMS), $(eval $(call OBJECT_template,$(1),$(prog),$(addprefix $(1),_CFLAGS))))
$(foreach prog, $(PROGRAMS), $(eval $(call PROGRAM_template,$(1),$(prog),bin,$(addprefix $(1),_CFLAGS),$(addprefix $(1),_LDFLAGS))))


endef

### MAIN ######################################################################
# Iterate over BUILD: debug, release

$(foreach build, $(BUILD), $(eval $(call BUILD_template,$(build))))

clean:
	@echo "[CLEAN]"
	@rm -rf bin obj
