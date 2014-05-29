/*
  Fast ATan2 function by larsbb 
  http://www.snippetcenter.org/en/a-fast-atan2-function-s346.aspx

*/


#include "FastATan2.h"

 
//****************************************************************** 
static void createTrigTBLS( double maxerr ) 
{ 
    // Calculate the number of table entries to ensure this maximum error 
    double nf = ::sqrt( MAX_SECOND_DERIV_IN_RANGE/(8*maxerr) ); 
    NUM_ATAN_ENTRIES = int( nf ) + 1; 
     
    // Build table 
    float y = 10.f; 
    float x; 
    pATanTBL[0] = 0.0f; 
    for(uint i=1; i <= NUM_ATAN_ENTRIES; i++) 
    { 
        x = (y / i) * NUM_ATAN_ENTRIES; 
        pATanTBL[i] = (float)::atan2(y, x); 
    } 
} 
     
static inline float interp( float r, float a, float b ) 
{ 
    return r*(b-a) + a; 
} 
    
static double calcAngle( float x, float y ) 
{ 
    float di = (y/x)*NUM_ATAN_ENTRIES; 
    uint i = int( di ); 
    if ( i>=NUM_ATAN_ENTRIES ) 
        return ::atan2( y, x ); 
    return interp( di-i, pATanTBL[i], pATanTBL[i+1] ); 
} 

//****************************************************************** 
inline float CheckReturnA(double Angle, double x) 
{ 
    #ifdef ASSERTS_ENABLED 
    static double maxerr = 0; 
        double err = ::fabs( Angle - x ); 
        if ( err>maxerr ) maxerr = err; 
    #endif 

    /* 
    const double ERROR_VALUE = 1e-4; 
    if (Angle < (x) - ERROR_VALUE || Angle > (x) + ERROR_VALUE) 
    throw "Incompatible values found at CheckReturn()"; 
    return float(x); 
    */ 
    return x; 
} 

//#define CheckReturn(x) { CheckReturnA(Angle,(x)); return float(x); } 
 
//****************************************************************** 
float fatan2(float y, float x) 
{ 
    #if ASSERTS_ENABLED 
        float Angle = (float)atan2(y,x); 
    #endif 
    
    if(y == 0.f) // the line is horizontal 
    { 
      if( x > 0.f) // towards the right 
      { 
          // the angle is 0 
          CheckReturn(0.f); 
      } 
      // toward the left 
      //CheckReturn(PI); 
      return float(PI); 
    } 
    
    // we now know that y is not 0 check x 
    if(x == 0.f) // the line is vertical 
    { 
        if( y > 0.f) 
        { 
            CheckReturn(PI/2.f); 
        } 
        CheckReturn(-PI/2.f); 
    } 
    
    // from here on we know that niether x nor y is 0 
    if( x > 0.f) 
    { 
        // we are in quadrant 1 or 4 
        if (y > 0.f) 
        { 
            // we are in quadrant 1 
            // now figure out which side of the 45 degree line 
            if(x > y) 
            { 
                CheckReturn(calcAngle(x,y)); 
            } 
            CheckReturn((PI/2.f) - calcAngle(y,x)); 
        } 
        // we are in quadrant 4 
        y = -y; 
        // now figure out which side of the 45 degree line 
        if( x > y) 
        { 
                CheckReturn(-calcAngle(x,y)); 
        } 
        CheckReturn(-(PI/2.f) + calcAngle(y,x)); 
    } 
    
    // we are in quadrant 2 or 3 
    x = -x; // flip x so we can use it as a positive 
    if ( y > 0) 
    { 
        // we are in quadrant 2 
        // now figure out which side of the 45 degree line 
        if ( x > y) 
        { 
                CheckReturn(PI - calcAngle(x,y)); 
        } 
        CheckReturn(PI/2.f + calcAngle(y,x)); 
    } 
    // we are in quadrant 3 
    y = -y; // flip y so we can use it as a positve 
    // now figure out which side of the 45 degree line 
    if( x > y) 
    { 
        CheckReturn(-PI + calcAngle(x,y)); 
    } 
    CheckReturn(-(PI/2.f) - calcAngle(y,x)); 
}
