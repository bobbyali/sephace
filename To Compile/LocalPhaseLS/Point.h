// Point.h: interface for the Point class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_POINT_H__35B0A99C_8F9B_4106_AA9A_973A0F899EE7__INCLUDED_)
#define AFX_POINT_H__35B0A99C_8F9B_4106_AA9A_973A0F899EE7__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include <math.h>

/****************************************************************************************/
/*																						*/
/* CLASS	Point																		*/
/*																						*/
/*	This class implements the data type point as an object. So that points can be used  */
/*	in the same way as they are in Java.												*/
/*																						*/ 
/****************************************************************************************/

template <class Type>   //Dreaming one day of making this really useful.
class Point  
{
public:

	/********************************/
	/* CONSTRUCTORS AND DESTRUCTORS */
	/********************************/

	Point();
	virtual ~Point();
	Point(Type in_x,Type in_y);
	Point(Point const &p);
	Point& operator=(Point const &p);

	/********************************/
	/* VARIABLES					 */
	/********************************/
	Type x;
	Type y;

	/********************************/
	/* METHODS						*/
	/********************************/

	virtual Point clone();

	virtual double distance(long double px,long double py);
	virtual double distance(double px,double py);
	virtual double distance(float px,float py);
	virtual double distance(long int px,long int py);
	virtual double distance(int px,int py);
	virtual double distance(short int px,short int py);

	virtual double distance(long double p1x,long double p1y,long double p2x,long double p2y);
	virtual double distance(double p1x,double p1y,double p2x,double p2y);
	virtual double distance(float p1x,float p1y,float p2x,float p2y);
	virtual double distance(long int p1x,long int p1y,long int p2x,long int p2y);
	virtual double distance(int p1x,int p1y,int p2x,int p2y);
	virtual double distance(short int p1x,short int p1y,short int p2x,short int p2y);

	virtual double distance(Point p);

	virtual double distanceSq(long double px,long double py);		
	virtual double distanceSq(double px,double py);	
	virtual double distanceSq(float px,float py);
	virtual double distanceSq(long int px,long int py);
	virtual double distanceSq(int px,int py);
	virtual double distanceSq(short int px,short int py);

	virtual double distanceSq(long double p1x,long double p1y,long double p2x,long double p2y);
	virtual double distanceSq(double p1x,double p1y,double p2x,double p2y);
	virtual double distanceSq(float p1x,float p1y,float p2x,float p2y);
	virtual double distanceSq(long int p1x,long int p1y,long int p2x,long int p2y);
	virtual double distanceSq(int p1x,int p1y,int p2x,int p2y);
	virtual double distanceSq(short int p1x,short int p1y,short int p2x,short int p2y);

	virtual double distanceSq(Point p);

	virtual bool equals(Point p);

	virtual Point getLocation();

	virtual double getX();

	virtual double getY();

	virtual void move(long double in_x,long double in_y);
	virtual void move(double in_x,double in_y);
	virtual void move(float in_x,float in_y);
	virtual void move(long int in_x,long int in_y);
	virtual void move(int in_x,int in_y);
	virtual void move(short int in_x,short int in_y);
	
	virtual void move(Point p);
	
	virtual void setLocation(long double x,long double y);
	virtual void setLocation(double x,double y);
	virtual void setLocation(float x,float y);
	virtual void setLocation(long int x, long int y);
	virtual void setLocation(int x, int y);
	virtual void setLocation(short int x, short int y);
	
	virtual void setLocation(Point p);
	
	virtual char toString();
	
	virtual void translate(long double dx,long double dy);
	virtual void translate(double dx,double dy);
	virtual void translate(float dx,float dy);
	virtual void translate(long int dx, long int dy);
	virtual void translate(int dx, int dy);
	virtual void translate(short int dx, short int dy);
	
	virtual void translate(Point p);		


//protected:

//private:


};




// Point.cpp: implementation of the Point class.
//
//////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

template <class Type>
Point<Type>::Point(){
	x=0;
	y=0;
}

template <class Type>
Point<Type>::Point(Type in_x,Type in_y){
	x=in_x;
	y=in_y;
}

template <class Type>
Point<Type>::Point(Point const &p){
	x=p.x;
	y=p.y;
}


template <class Type>
Point<Type>& Point<Type>::operator=(Point const &p){
	if(this != &p){
		this->x=p.x;
		this->y=p.y;
	}
	return *this;
}

template <class Type>
Point<Type>::~Point(){
}


template <class Type>
Point<Type> Point<Type>::clone(){
	Point newpoint(x,y);
	return newpoint;
}

template <class Type>
double Point<Type>::distance(long double px,long double py){
	return (sqrt(pow((x-px),2)+pow((y-py),2)));
}

template <class Type>
double Point<Type>::distance(double px,double py){
	return (sqrt(pow((x-px),2)+pow((y-py),2)));
}

template <class Type>
double Point<Type>::distance(float px,float py){
	return (sqrt(pow((x-px),2)+pow((y-py),2)));
}

template <class Type>
double Point<Type>::distance(long int px,long int py){
	return (sqrt(pow((x-px),2)+pow((y-py),2)));
}

template <class Type>
double Point<Type>::distance(int px,int py){
	return (sqrt(pow((x-px),2)+pow((y-py),2)));
}

template <class Type>
double Point<Type>::distance(short int px,short int py){
	return (sqrt(pow((x-px),2)+pow((y-py),2)));
}

template <class Type>
double Point<Type>::distance(long double p1x,long double p1y,long double p2x,long double p2y){
	return (sqrt(pow((p1x-p2x),2)+pow((p1y-p2y),2)));
}

template <class Type>
double Point<Type>::distance(double p1x,double p1y,double p2x,double p2y){
	return (sqrt(pow((p1x-p2x),2)+pow((p1y-p2y),2)));
}

template <class Type>
double Point<Type>::distance(float p1x,float p1y,float p2x,float p2y){
	return (sqrt(pow((p1x-p2x),2)+pow((p1y-p2y),2)));
}

template <class Type>
double Point<Type>::distance(long int p1x,long int p1y,long int p2x,long int p2y){
	return (sqrt(pow((p1x-p2x),2)+pow((p1y-p2y),2)));
}

template <class Type>
double Point<Type>::distance(int p1x,int p1y,int p2x,int p2y){
	return (sqrt(pow((p1x-p2x),2)+pow((p1y-p2y),2)));
}

template <class Type>
double Point<Type>::distance(short int p1x,short int p1y,short int p2x,short int p2y){
	return (sqrt(pow((p1x-p2x),2)+pow((p1y-p2y),2)));
}


template <class Type>
double Point<Type>::distance(Point p){
	return (sqrt(pow((x-p.x),2)+pow((y-p.y),2)));
}

template <class Type>
double Point<Type>::distanceSq(long double px,long double py){
	return (pow((x-px),2)+pow((y-py),2));
}

template <class Type>
double Point<Type>::distanceSq(double px,double py){
	return (pow((x-px),2)+pow((y-py),2));
}

template <class Type>
double Point<Type>::distanceSq(float px,float py){
	return (pow((x-px),2)+pow((y-py),2));
}

template <class Type>
double Point<Type>::distanceSq(long int px,long int py){
	return (pow((x-px),2)+pow((y-py),2));
}

template <class Type>
double Point<Type>::distanceSq(int px,int py){
	return (pow((x-px),2)+pow((y-py),2));
}

template <class Type>
double Point<Type>::distanceSq(short int px,short int py){
	return (pow((x-px),2)+pow((y-py),2));
}

template <class Type>
double Point<Type>::distanceSq(long double p1x,long double p1y,long double p2x,long double p2y){
	return (pow((p1x-p2x),2)+pow((p1y-p2y),2));
}

template <class Type>
double Point<Type>::distanceSq(double p1x,double p1y,double p2x,double p2y){
	return (pow((p1x-p2x),2)+pow((p1y-p2y),2));
}

template <class Type>
double Point<Type>::distanceSq(float p1x,float p1y,float p2x,float p2y){
	return (pow((p1x-p2x),2)+pow((p1y-p2y),2));
}

template <class Type>
double Point<Type>::distanceSq(long int p1x,long int p1y,long int p2x,long int p2y){
	return (pow((p1x-p2x),2)+pow((p1y-p2y),2));
}

template <class Type>
double Point<Type>::distanceSq(int p1x,int p1y,int p2x,int p2y){
	return (pow((p1x-p2x),2)+pow((p1y-p2y),2));
}

template <class Type>
double Point<Type>::distanceSq(short int p1x,short int p1y,short int p2x,short int p2y){
	return (pow((p1x-p2x),2)+pow((p1y-p2y),2));
}

template <class Type>
double Point<Type>::distanceSq(Point p){
	return (pow((x-p.x),2)+pow((y-p.y),2));
}

template <class Type>
bool Point<Type>::equals(Point p){
	if ((x==p.x)&&(y==p.y))
		return true;
	else
		return false;
}

template <class Type>
Point<Type> Point<Type>::getLocation(){
	Point newpoint(x,y);
	return newpoint;
}

template <class Type>
double Point<Type>::getX(){
	return (double) x;
}

template <class Type>
double Point<Type>::getY(){
	return (double) y;
}

template <class Type>
void Point<Type>::move(long double in_x,long double in_y){
	x=(Type) in_x;
	y=(Type) in_y;
}

template <class Type>
void Point<Type>::move(double in_x,double in_y){
	x=(Type) in_x;
	y=(Type) in_y;
}

template <class Type>
void Point<Type>::move(float in_x,float in_y){
	x=(Type) in_x;
	y=(Type) in_y;
}

template <class Type>
void Point<Type>::move(long int in_x,long int in_y){
	x=(Type) in_x;
	y=(Type) in_y;
}

template <class Type>
void Point<Type>::move(int in_x,int in_y){
	x=(Type) in_x;
	y=(Type) in_y;
}

template <class Type>
void Point<Type>::move(short int in_x,short int in_y){
	x=(Type) in_x;
	y=(Type) in_y;
}

template <class Type>
void Point<Type>::move(Point p){
	x=(Type) p.x;
	y=(Type) p.y;
}

template <class Type>
void Point<Type>::setLocation(long double in_x,long double in_y){
	x=(Type) in_x;
	y=(Type) in_y;
}

template <class Type>
void Point<Type>::setLocation(double in_x,double in_y){
	x=(Type) in_x;
	y=(Type) in_y;
}

template <class Type>
void Point<Type>::setLocation(float in_x,float in_y){
	x=(Type) in_x;
	y=(Type) in_y;
}

template <class Type>
void Point<Type>::setLocation(long int in_x,long int in_y){
	x=(Type) in_x;
	y=(Type) in_y;
}

template <class Type>
void Point<Type>::setLocation(int in_x,int in_y){
	x=(Type) in_x;
	y=(Type) in_y;
}

template <class Type>
void Point<Type>::setLocation(short int in_x,short int in_y){
	x=(Type) in_x;
	y=(Type) in_y;
}

template <class Type>
void Point<Type>::setLocation(Point p){
	x=(Type) p.x;
	y=(Type) p.y;
}

template <class Type>
char Point<Type>::toString(){
	return ("%d %d",x,y);
}

template <class Type>
void Point<Type>::translate(long double dx,long double dy){
	x+=(Type) dx;
	y+=(Type) dy;
}

template <class Type>
void Point<Type>::translate(double dx,double dy){
	x+=(Type) dx;
	y+=(Type) dy;
}

template <class Type>
void Point<Type>::translate(float dx,float dy){
	x+=(Type) dx;
	y+=(Type) dy;
}

template <class Type>
void Point<Type>::translate(long int dx,long int dy){
	x+=(Type) dx;
	y+=(Type) dy;
}

template <class Type>
void Point<Type>::translate(int dx,int dy){
	x+=(Type) dx;
	y+=(Type) dy;
}

template <class Type>
void Point<Type>::translate(short int dx,short int dy){
	x+=(Type) dx;
	y+=(Type) dy;
}

template <class Type>
void Point<Type>::translate(Point p){
	x+=(Type) p.x;
	y+=(Type) p.y;
}


#endif // !defined(AFX_POINT_H__35B0A99C_8F9B_4106_AA9A_973A0F899EE7__INCLUDED_)
