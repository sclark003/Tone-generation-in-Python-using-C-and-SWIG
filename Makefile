##############################################
#Variables to change depending on programmes:

#Module name
MODULE := generator

#Sources
LIBSRCS := generator.cxx

#Output file extension
LIBEXT := so

#Compiler flags
CXX = g++
CXXFLAGS += -fPIC
LDFLAGS += -shared
SWIG += swig
SWIGFLAGS = -c++ -python

#File paths for the include files provided by Python and NumPy
PYTHON_INCLUDES := $$(python3-config --includes)
NUMPY_INCLUDES := -I/usr/lib/python3/dist-packages/numpy/core/include

##############################################
#Set up

#Specify link flags for Python extension
PYTHON_LIBS := $$(python3-config --libs)

#Object Dirctory
OBJDIR := obj

#Object files for shared library and test programme
LIBOBJs := $(LIBSRCS:%.cxx=$(OBJDIR/%.o)

#Swig Wrapper
WRAPPER := $(MODULE)_wrap.cxx
WRAPOBJ := $(OBJDIR)/$(MODULE)_wrap.o

SRCS := $(LIBSRCS) $(WRAPPER)

#Output files from build
OUTPUT := _$(MODULE).$(LIBEXT)
PYTHON_MODULE := $(MODULE).py

##############################################
#Set-up auto-dependency generation

#Place dependency files into a subdirectory of object directory named .dep
DEPDIR := $(OBJDIR)/.deps
SWIGDEPS := $(DEPDIR)/$(MODULE).swigdeps.d

#Compiler flags to convince the compiler to generate the dependecy file
DEPFLAGS = -MT $@ -MMD -MP -MF $(DEPDIR)/$(*F).d
SWIGDEPFLAGS := -MM

#Object file compile rule
COMPILE.cxx = $(CXX) $(DEPFLAGS) $(CXXFLAGS) -c

##############################################
#Compile

#Name files to 'make'
all:: $(OUTPUT) $(PYTHON_MODULE)

#Create SWIG wrapper
# SWIG generates two output files: the C++ wrapper and Python module which loads it.
# By using the &: separator instead of just :, make knows that this rule generates both the C++ wrapper program and the python module: it won't invoke the rule twice if both need rebuilding.
# Prerequisites following the | are "order prerequisites". That means DEPDIR will get built before the targets, but if DEPDIR is modified subsequently that won't force the wrapper and .py file also to be rebuit.
$(WRAPPER) $(PYTHON_MODULE) &: $(MODULE).i | $(SWIGDEPS) $(DEPDIR)
	@echo Target: $@
	@#echo Stem: $*
	@echo Unsatisfied Prerequisites: $?
	$(SWIG) -c++ $(SWIGDEPFLAGS) $< > $(SWIGDEPS)
	$(SWIG) $(SWIGFLAGS) $<

#Create shared library
$(OUTPUT): $(WRAPOBJ) $(LIBOBJS)
	@echo Target: $@
	@#echo Stem: $*
	@echo Unsatisfied Prerequisites: $?
	$(CXX) $(LDFLAGS) $(WRAPOBJ) $(LIBOBJS) -o $@ $(PYTHON_LIBS)

#Create swig wrapper object
$(WRAPOBJ): $(WRAPPER) $(DEPDIR)/$(WRAPPER:%.cxx=%.d) | $(DEPDIR)
	@echo Wrapper.
	@echo Target: $@
	@#echo Stem: $*
	@echo Unsatisfied Prerequisites: $?
	$(COMPILE.cxx) $(PYTHON_INCLUDES) $(NUMPY_INCLUDES) -o $@ $<

################
#%.o : %.cxx = Delete the built-in rules for building object files from .cxx files, so that our rule is used instead
#$(DEPDIR)/%.d = Declare the generated dependency file as a prerequisite of the target, so that if it's missing the target will be rebuilt
#| $(DEPDIR) = Declare the dependency directory as an order only prerequisite of the target, so that it will be created when needed.
$(OBJDIR)/%.o : %.cxx $(DEPDIR)/%.d | $(DEPDIR)
	@echo A C++ file
	@echo Target: $@
	@#echo Stem: $*
	@echo Unsatisfied Prerequisites: $?	
	$(COMPILE.cxx) -o $@ $<

#Declare a rule for creating the dependency directory if it doesn't exist
$(DEPDIR): ; @mkdir -p $@

#Generate a list of all the dependency files that could exist
DEPFILES := $(SRCS:%.cxx=$(DEPDIR)/%.d) $(SWIGDEPS)

#Mention each dependency file as a target, so that 'make' won't fail if the file doesn't exist
$(DEPFILES):

clean::
	@printf "Removing Object and Depend files...\n"
	@if [ "x`realpath $(OBJDIR)`x" = "x`realpath .`x" ] ; then \
		printf "\n*** Don't set OBJDIR to .\n\n" ; \
		$(RM) $(LIBOBJS) $(TESTOBJS) ; \
		$(RM) -r $(DEPDIR) ; \
	else \
		$(RM) -r $(OBJDIR) ; \
	fi
	$(RM) $(SONAME) $(WRAPPER) $(PYTHON_MODULE) $(TESTPRG)


#Include the dependency files that exist. Use 'wildcard' to avoid failing on non-existent files
include $(wildcard $(DEPFILES))
