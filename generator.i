/* File: generator.i */
%module generator

%include <std_string.i>
%include <math.i>

%{
   #define SWIG_FILE_WITH_INIT
   #include "generator.h"
%}


%include <numpy.i>
%init %{
import_array();
%}

%apply (double* ARGOUT_ARRAY1,int DIM1) {(double *arr, int fs)};
%include "generator.h"

