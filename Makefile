######################################################################################
# GNU GCC ARM Embeded Toolchain base directories and binaries 
######################################################################################
#GCC_BASE = /home/dan/dev/arm/opt/crosstool/gcc-3.4.4-glibc-2.3.2/arm-linux/
#GCC_BASE = /home/dan/dev/arm/crosstool/gcc3/arm-linux/
#GCC_BASE = /home/dan/dev/ts-7200/gcc-3.4.4-glibc-2.3.2/arm-linux/
GCC_BASE = $(CROSS_COMPILE)
#GCC_BASE = /home/dan/dev/arm/crosstool/gcc3/arm-linux/
GCC_BIN  = $(GCC_BASE)bin/
GCC_LIB  = $(GCC_BASE)arm-linux/lib/
GCC_INC  = $(GCC_BASE)arm-linux/include/
AS       = $(GCC_BIN)arm-linux-as
CC       = $(GCC_BIN)arm-linux-gcc
CPP      = $(GCC_BIN)arm-linux-g++
LD       = $(GCC_BIN)arm-linux-gcc
OBJCOPY  = $(GCC_BIN)arm-linux-objcopy

#TS-7200_CC_FLAGS = -mcpu=arm920t -march=armv5t
#TS-7200_CC_FLAGS = -mcpu=arm920t -mapcs-32 -mthumb-interwork
#TS-7200_CC_FLAGS = -mcpu=arm920t
TS-7200_CC_FLAGS = -mcpu=arm920t -mapcs-32 -mthumb-interwork
ASM_FLAGS = -almns=listing.txt
PROJECT_INC_LIB = -I$(PORT) -I$(SOURCE)

# to debug use: make print-<variable_name>
# e.g. make print-GCC_BASE
print-%:
	@echo '$*=$($*)'
#	@echo $(.SOURCE)
#	@echo $(.TARGET)

######################################################################################
# Main makefile project configuration
#    PROJECT      = <name of the target to be built>
#    MCU_CC_FLAGS = <one of the CC_FLAGS above>
#    MCU_LIB_PATH = <one of the LIB_PATH above>
#    OPTIMIZE_FOR = < SIZE or nothing >
#    DEBUG_LEVEL  = < -g compiler option or nothing >
#    OPTIM_LEVEL  = < -O compiler option or nothing >
######################################################################################
PROJECT           = main
MCU_CC_FLAGS      = $(TS-7200_CC_FLAGS)
MCU_LIB_PATH      = $(TS-7200_LIB_PATH)
OPTIMIZE_FOR      = 
DEBUG_LEVEL       = 
OPTIM_LEVEL       = 
PROJECT_OBJECTS   = main.o
PROJECT_LIB_PATHS = -L.
PROJECT_LIBRARIES =
PROJECT_SYMBOLS   = -DTOOLCHAIN_GCC_ARM -DNO_RELOC='0'  

######################################################################################
# Main makefile system configuration
######################################################################################
SYS_OBJECTS = 
SYS_LIB_PATHS = -L$(MCU_LIB_PATH)
ifeq (OPTIMIZE_FOR, SIZE)
SYS_LIBRARIES = -lstdc++_s -lsupc++_s -lm -lc_s -lg_s -lnosys
SYS_LD_FLAGS  = --specs=nano.specs -u _printf_float -u _scanf_float
else 
SYS_LIBRARIES = -lstdc++ -lsupc++ -lm -lc -lg -lnosys
SYS_LD_FLAGS  = 
endif

############################################################################### 
# Command line building
###############################################################################
ifdef DEBUG_LEVEL
CC_DEBUG_FLAGS = -g$(DEBUG_LEVEL)
CC_SYMBOLS = -DDEBUG $(PROJECT_SYMBOLS)
else
CC_DEBUG_FLAGS =
CC_SYMBOLS = -DNODEBUG $(PROJECT_SYMBOLS)
endif 

ifdef OPTIM_LEVEL
CC_OPTIM_FLAGS = -O$(OPTIM_LEVEL)
else 
CC_OPTIM_FLAGS = 
endif

INCLUDE_PATHS = -I.$(GCC_INC)
LIBRARY_PATHS = $(PROJECT_LIB_LIB) $(SYS_LIB_PATHS)
CC_FLAGS = $(MCU_CC_FLAGS) $(CC_OPTIM_FLAGS) $(CC_DEBUG_FLAGS) -Wall -fno-exceptions -ffunction-sections -fdata-sections 
#-pthread -static-libgcc
# use -static-libgcc instead of -static to get rid of warning: "Using getprotobyname in statically linked apps requires
# at runtime the shared libraries from the glibc version used for linking"
LD_FLAGS = $(MCU_CC_FLAGS) -Wl,--gc-sections $(SYS_LD_FLAGS) -Wl,-Map=$(PROJECT).map 
LD_SYS_LIBS = $(SYS_LIBRARIES)

#GNUCFLAGS = -g -ansi -Wstrict-prototypes	doesn't compile "// ..comments.."
#CC_FLAGS = -static -g -Wstrict-prototypes -mcpu=arm920t -mapcs-32 -mthumb-interwork -DMAKE_TARGET
CC_FLAGS = -Wstrict-prototypes -mcpu=arm920t -DMAKE_TARGET
CC_FLAGS2 = -Wstrict-prototypes -mcpu=arm920t
GNULDFLAGS_T = ${GNULDFLAGS} -pthread
#CC_FLAGST = ${CC_FLAGS} + GNULDFLAGS_T
GNUSFLAGS = -D_SVID_SOURCE -D_XOPEN_SOURCE
GNUNOANSI = -g -gnu99 -Wstrict-prototypes

#####################################################
#CFLAGS = ${GNUCFLAGS}
#LDFLAGS = ${GNULDFLAGS}

BULD_TARGET = $(PROJECT)

all : lcd_msg lcd_func lcd_func2

lcdmesg.o: lcdmesg.c
	${CC} ${CC_FLAGS} ${INCLUDE_PATHS} -c lcdmesg.c

lcd_func.o: lcd_func.c lcd_func.h
	${CC} ${CC_FLAGS2} ${INCLUDE_PATHS} -c lcd_func.c

lcd_func2.o: lcd_func2.c lcd_func.h
	${CC} ${CC_FLAGS2} ${INCLUDE_PATHS} -c lcd_func2.c

lcd_msg: lcdmesg.o
#	${CC} -static lcdmesg.o -o lcd_msg
	${CC} lcdmesg.o -o lcd_msg

lcd_func: lcd_func.o
#	${CC} -static lcdmesg.o -o lcd_msg
	${CC} lcd_func.o -o lcd_func

lcd_func2: lcd_func2.o
#	${CC} -static lcdmesg.o -o lcd_msg
	${CC} lcd_func2.o -o lcd_func2

clean :
	rm -f *.o *~ *# core lcd_msg lcd_func



