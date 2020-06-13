// File: generator.cxx
//
// Function to generate sinewave in C++

#include <stdio.h>
#include <math.h>
#include "generator.h"

#define PI 3.14159265


void wave (double *arr, int fs, float f)
{
  int i = 0;
  float b = float(fs);
  for (int i = 0; i < fs; i++)
    {
       float c = i/b;
       arr[i] = 100*sin(2*PI*f*c);
    }
}
