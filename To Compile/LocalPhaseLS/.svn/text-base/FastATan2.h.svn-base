/*
  Fast ATan2 function by larsbb 
  http://www.snippetcenter.org/en/a-fast-atan2-function-s346.aspx

*/

#define ASSERTS_ENABLED 1 

#include <cmath> 
 
//****************************************************************** 
static const unsigned int NUM_ATAN_ENTRIES_INIT = 0; // ??? 
static unsigned int NUM_ATAN_ENTRIES = 0; 
static float pATanTBL[NUM_ATAN_ENTRIES_INIT+1]; // ??? will this get messed up later?
typedef unsigned int uint; 
const double PI = 4*atan(1.0); 
const double MAX_SECOND_DERIV_IN_RANGE = 0.6495; 
 
//****************************************************************** 
static void createTrigTBLS( double maxerr );
static inline float interp( float r, float a, float b );
static double calcAngle( float x, float y );
inline float CheckReturnA(double Angle, double x);
#define CheckReturn(x) { CheckReturnA(Angle,(x)); return float(x); };
float fatan2(float y, float x);
