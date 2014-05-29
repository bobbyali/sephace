// Image.h: interface for the Image class.
//
// - modified by Rehan Ali, 15th October 2007
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_IMAGE_H__96F0F2F9_4EE8_45BB_AE1C_8657B8CB1F81__INCLUDED_)
#define AFX_IMAGE_H__96F0F2F9_4EE8_45BB_AE1C_8657B8CB1F81__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include <cstdlib>
#include <iostream>
#include <string>
#include <fstream>
//#include <stdlib.h>
//#include <EasyBMP.h>
#include <png.h>

using std::cerr;
using std::endl;
using std::cout;

/****************************************************************************************/
/*																						*/
/* CLASS	Image																		*/
/*																						*/
/* Class Image is the object which stores the image. The image is stored as a double    */
/* so that the operation on the data are more accurate before being returned as needed. */
/*																						*/ 
/****************************************************************************************/


class Image  
{

/****************************************************************************************/
/*																						*/
/* PUBLIC ITEMS																			*/
/*																						*/
/* All the data within this class is protected to avoid it being changed accidentally.  */
/* This means that to access any data it must be done through a number of classes.      */
/* These are:																			*/
/*																						*/
/*		Image(Image copy) - This is a construction which duplicates the parameter.	*/
/*		void setSize(int h,int w) - This sets the image array to the correct size.		*/							
/*		void setData(double d, int x, int y) - This	sets the array to d at point (x,y).	*/
/*		void setData(int d, int x, int y) - This sets the array to d at point (x,y).	*/
/*		void setData(int d, int i) - This sets the array to d at point i.				*/
/*		double getData(int x, int y) - This returns the data at (x,y).					*/
/*		int getWidth() - This returns the width.										*/
/*		int getHeight()	- This returns the height.										*/
/*																						*/
/****************************************************************************************/


public:
	Image();
	Image(int w,int h);
	virtual ~Image();
	Image(Image const &im);
	virtual Image& operator=(Image const &im);
	virtual double& operator()(int x, int y);
    virtual double operator()(int x, int y) const;
	virtual void SetImageSize(int w,int h);
	virtual void setData(double d, int x, int y);
	virtual void setData(int d, int x, int y);
	virtual double getData(int x, int y);
	virtual int getWidth();
	virtual int getHeight();
	double **data;
	virtual void Zero();
	int ReadPNG(char *cpPath);
    int WritePNG(char *cpPath);
    int WriteSignedRaw(char *cpPath);
    int WriteUnsignedRaw(char *cpPath);

/****************************************************************************************/
/*																						*/
/* PROTECTED ITEMS																		*/
/*																						*/
/* All the data within this class and any class specific methods are protected. These 	*/
/* are:																					*/
/*																						*/
/*		double *data - The array of image data.											*/
/*		int height - The image height.													*/
/*		int width - The image width.													*/
/*																						*/
/****************************************************************************************/


protected:
	int height;
	int width;


};

#endif // !defined(AFX_IMAGE_H__96F0F2F9_4EE8_45BB_AE1C_8657B8CB1F81__INCLUDED_)
