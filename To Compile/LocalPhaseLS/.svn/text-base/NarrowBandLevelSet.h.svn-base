// NarrowBandLevelSet.h: interface for the NarrowBandLevelSet class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_NARROWBANDLEVELSET_H__052486F1_439E_4307_8531_082246541DAF__INCLUDED_)
#define AFX_NARROWBANDLEVELSET_H__052486F1_439E_4307_8531_082246541DAF__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include <cstdlib>
#include <iostream>
#include <fstream>
#include <deque>
//#include <string.h>
#include "Image.h"
#include "Point.h"
#include <sys/types.h> 
#include <sys/timeb.h>
#include "FastATan2.h"

#define PI              3.141592653589793238

using std::cerr;
using std::endl;
using std::cout;
//using std::string;

class NarrowBandLevelSet  
{
public:
	NarrowBandLevelSet(Image input,Image boundary,Image lo_image, bool initialMode, bool useAngle, double p_alpha, double p_beta, double p_gamma, double p_delta);  //
	virtual ~NarrowBandLevelSet();
	virtual void SetVariables(float a, float b);
	virtual Image RunLevelSet(int i);
	virtual Image GetPhi();

protected:
	virtual void findHistograms();
	virtual void initialise(Image initial);
	virtual void setUpArrays(int x,int y);
	
	virtual inline void gradient(Image* data, int x, int y, double &Gx, double &Gy);
	//virtual void findFintAngle();
	
	virtual void findFintImproved();
	virtual void reinitialisePhiZhao();
	virtual void thePengNarrowBand();
	virtual inline double reinitialisePhiPengCHECK(int i,int j, double deltaT);
	virtual inline double reinitialisePhiPeng(int i,int j, double deltaT, int width, int height);


private:
	Image mydata;
	Image phi;
	Image classes;
	Image sign;
	std::deque< float* > histogram;
	std::deque< float* > angle_N;		// normal angle of signed distance function
	std::deque< float* > angle_O;		// local orientation angle
	std::deque< float* > angle_diff;	// cos(difference between angle_N and angle_O)
	Image Fint;
	Image Fangle;
	Image DeltaPhi;
	Image mine; 

	Image gradx;
	Image grady;
	Image gradz;
	Image gradm;

	Image orientation;			//

	std::deque< Point<int> > narrowband;
	std::deque< Point<int> > zeroband;
	std::deque< Point<int> > surfband;
	std::deque< Point<int> > surfnotzeroband;
	std::deque< Point<int> > extensionband;

	std::deque< Point<int> > extensionbandINSIDE;
	std::deque< Point<int> > extensionbandEDGE;

	double TimeStep;
	char numberOfClasses;
	int  iterations;
	double *numberOfPoints;
	bool  useOrient;
	double alpha;  // param for local phase region term
	double beta;   // param for orientation term
	double gamma;  // param for curvature term
	double delta;  // param for repulsion term

};

#endif // !defined(AFX_NARROWBANDLEVELSET_H__052486F1_439E_4307_8531_082246541DAF__INCLUDED_)

