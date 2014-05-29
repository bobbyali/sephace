// NarrowBandLevelSet.cpp: implementation of the NarrowBandLevelSet class.
//
//////////////////////////////////////////////////////////////////////

#include "NarrowBandLevelSet.h"


//////////////////////////////////////////////////////////////////////
// Useful functions
//////////////////////////////////////////////////////////////////////

inline float max(float a, float b){
	return ( a > b )? (a) : (b);
}

inline float min(float a, float b){
	return ( a < b )? (a) : (b);
}

inline float max(float a, float b, float c){
	float d = max(a,b);
	return ( d > b )? (d) : (c);
}

inline float min(float a, float b, float c){
	float d = min(a,b);
	return ( d < c )? (d) : (c);
}

inline float signof(float a){
	return ( a < 0 )? (-1) : (1);
}

inline float positive(float a){
	return ( a < 0 )? (-a) : (a);
}


inline double max(double a, double b){
	return ( a > b )? (a) : (b);
}

inline double min(double a, double b){
	return ( a < b )? (a) : (b);
}

inline double max(double a, double b, double c){
	float d = max(a,b);
	return ( d > b )? (d) : (c);
}

inline double min(double a, double b, double c){
	double d = min(a,b);
	return ( d < c )? (d) : (c);
}

inline double signof(double a){
	return ( a < 0 )? (-1) : (1);
}

inline double positive(double a){
	return ( a < 0 )? (-a) : (a);
}

inline double pow(double a, double b){
    if (b == 2) {
       return a * a;
    } else if (b == 3) {
       return a * a * a;
    }
}
       

//this function must be changed to swap the data so that it can be used! DOH!!
inline void swap(Image a,Image b){
	Image c;
	int width=a.getWidth();
	int height=a.getHeight();
	c.SetImageSize(width,height);
	for(int i=0;i<width;i++){
		for(int j=0;j<height;j++){
			c.data[i][j]=b.data[i][j];
			b.data[i][j]=a.data[i][j];
			a.data[i][j]=c.data[i][j];
		}
	}
}

//returns a number in the range -1e10 to 1e10 excluding -1e-10 to 1e-10
inline double inrange(double a){
	double ans;
	ans=((a>=1e-10)||((a<=-1e-10)) ? a : 0);
	return ((ans<=1e+10)&&(ans>=-1e+10)) ? ans : ( (ans>1e10)?1e+10:-1e+10 );
}




//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

NarrowBandLevelSet::NarrowBandLevelSet(Image input,Image boundary,Image lo_image, bool initialMode, bool useAngle, double p_alpha, double p_beta, double p_gamma, double p_delta) //
{
	useOrient = useAngle;
	//alpha = 5;	
	//beta =1;
    alpha = p_alpha;
    beta = p_beta;
    gamma = p_gamma;
    delta = p_delta;
    
	TimeStep = 0.2;
	int height=input.getHeight();
	int width=input.getWidth();

	setUpArrays(width,height);
	initialise(boundary);
	
	for(int i=0;i<width;i++){
		for(int j=0;j<height;j++){
			mydata.data[i][j]=input.data[i][j];
			orientation.data[i][j]=(lo_image.data[i][j] * (2*PI/255));  // scale to 0-2*PI, and rotate 45 deg
			if (orientation.data[i][j] < 0) {
				orientation.data[i][j] = 2*PI + orientation.data[i][j]; // wrap around angles
			}
			if (orientation.data[i][j] > (2*PI)) {
				orientation.data[i][j] = orientation.data[i][j] - (2*PI);
			}
		}
	}

	cerr<<numberOfClasses<<endl;
	
	// moved out of "initialise" to constructor so that image mydata exists
	// (findFintImproved needs findHistograms to be Inboxcalled before it)
	reinitialisePhiZhao();
	findHistograms(); 
	findFintImproved();
}

NarrowBandLevelSet::~NarrowBandLevelSet()
{

}

/**************************************************************************************************/

void NarrowBandLevelSet::findHistograms(){

	int i,j;
	int width =mydata.getWidth();
	int height = mydata.getHeight();
	//double *numberOfPoints;
	double mean;

	numberOfPoints = new double[numberOfClasses];

	for(i=0;i<numberOfClasses;i++){
		numberOfPoints[i]=0;
		for(j=0;j<256;j++){
			histogram.at(i)[j]=0;
		}
	}

	for(i=0;i<width;i++){
		for(j=0;j<height;j++){
			histogram.at((int)classes(i,j))[(int)mydata(i,j)]++;
			numberOfPoints[(int)classes(i,j)]++;
		}
	}

    // normalise histogram (divide by total number of values for particular class)
	for(i=0;i<numberOfClasses;i++){
		mean=0;
		for(j=0;j<256;j++){
			if(numberOfPoints[i]==0){
				histogram.at(i)[j]=0;
			}else{
				histogram.at(i)[j]/=numberOfPoints[i];
				mean+=histogram.at(i)[j]*j;
			}
		}
	}
	
}

/**************************************************************************************************/

void NarrowBandLevelSet::setUpArrays(int x,int y){
	
	mydata.SetImageSize(x,y);
	phi.SetImageSize(x,y);
	classes.SetImageSize(x,y);
	mine.SetImageSize(x,y);
	sign.SetImageSize(x,y);
	Fint.SetImageSize(x,y);
	Fangle.SetImageSize(x,y);
	DeltaPhi.SetImageSize(x,y);
	gradx.SetImageSize(x,y);
	grady.SetImageSize(x,y);
	gradz.SetImageSize(x,y);
	gradm.SetImageSize(x,y);
	orientation.SetImageSize(x,y); //
}

/**************************************************************************************************/

void NarrowBandLevelSet::initialise(Image initial){
	int width=classes.getWidth();
	int height=classes.getHeight();
	int i,j;
	float *temphist;

	numberOfClasses=2;	
	iterations = 1;
	
	for(i=0;i<width;i++){
		for(j=0;j<height;j++){
				
			initial.data[i][j]--; // set classes range from 0-x instead of 1-x+1
				
			if(initial.data[i][j]!=0){
				classes.data[i][j]=initial.data[i][j];
				sign.data[i][j]=-1;
				phi.data[i][j]=-1;
				if(classes.data[i][j]>numberOfClasses-1){
					numberOfClasses=(unsigned char)classes.data[i][j]+1;  // want to compare against new class range
				}
			}else{
				classes.data[i][j]=0;
				sign.data[i][j]=1;
				phi.data[i][j]=1;
			}
								
		}
		
	}

	histogram.clear();
	histogram.resize(0);

	//set up the histogram matix
	for(i=0;i<numberOfClasses;i++){
		temphist = new float[256];
		for(j=0;j<256;j++){
			temphist[j]=0;
		}
		histogram.push_back(temphist);
	}



}
/**************************************************************************************************/
void NarrowBandLevelSet::SetVariables(float a, float b){
     
     alpha =a;
     beta= b;
     
}

/**************************************************************************************************/

Image NarrowBandLevelSet::RunLevelSet(int i){
	


	int j;
	FILE *outFile = NULL;
	
	cerr<<"Running for "<<i<<" cycles"<<endl;

	for(j=0;j<(int)i;j++){

		if(j%10==0){
			findHistograms();
		}
		this->iterations++;
		thePengNarrowBand();
		phi.WriteSignedRaw("_out_phi.png");
		classes.WriteUnsignedRaw("_out_classes.png");
		cerr<<"interation "<<j<<" complete"<<endl;
		
		outFile = fopen("_out_iterations.txt","w");
		fprintf(outFile, "%d", j);
		fclose(outFile);
		
	}
	
	return classes;    
	
}

/**************************************************************************************************/
Image NarrowBandLevelSet::GetPhi() {
	return phi;
}

/**************************************************************************************************/

inline void NarrowBandLevelSet::gradient(Image* data, int x, int y, double &Gx, double &Gy) {
	
	// calculate gradient magnitude at a given image point
	
	int width=data->getWidth();
	int height=data->getHeight();
	
	if (x==0 | y == 0 | x == width-1 | y == height-1) {
		Gx = 0;
		Gy = 0;
	} else {
		// multiply by -1 as we want reverse of normal of phi (we want direction of 
		// growth, which points away from cell
		Gx = (data->data[x+1][y] - data->data[x-1][y]) / 2 * 1;
		Gy = (data->data[x][y+1] - data->data[x][y-1]) / 2 * 1;
	}
		
}

    
/**************************************************************************************************/


void NarrowBandLevelSet::findFintImproved(){

    //very crude way to find the data-based driving force for the level set.
    //Assumes zeroband and narrowband are known first;
    
    int i,j,l,m,n,c;
    int r,s;
    double prob=0;
    int windowSize = 5;
    int bgWindowSize = 40;
    Point<int> pt;
    Point<int> pt1;
    unsigned char neighbourClass, currentClass;
    double* windowPDF = new double[256];
    double* backgroundPDF = new double[256];
    double realx,realy;
    bool* havenotcheckedclass = new bool[numberOfClasses];
    bool nearborder = false;
    int numberOfPixels;
    int width=Fint.getWidth();
	int height=Fint.getHeight();
	
    for(i=0;i<width;i++){
        for(j=0;j<height;j++){
        	Fint.data[i][j] = 0;        
        }
    }
	
	

    double Gx, Gy;
    double normPhi, diffAngle;
        
    // initialise angular speed term image
    if(useOrient) {
    	for(i=0;i<width;i++){
	        for(j=0;j<height;j++){
        		Fangle.data[i][j] = 0;        
        	}
    	}   
    }
	
	// set up Fint across zero level set
    for(l=0;l<(int)zeroband.size();l++){
        pt=zeroband.at(l);
        i=pt.x;
        j=pt.y;
		
		if(useOrient) {
			
			gradient(&phi,i,j, Gx, Gy);
			normPhi = fatan2(Gy,Gx); // testing a faster atan2 function
			
			diffAngle = fabs(normPhi - orientation.data[i][j]);
			Fangle.data[i][j] = cos(diffAngle);		
			
		}
		
        currentClass=(unsigned char)classes.data[i][j];
		numberOfPixels = (int)numberOfPoints[(int) currentClass];
		
		
        if(numberOfPixels<100){  // if small object, shrink it out
            Fint.data[i][j]=-1;
        }else{        
        	//clear histogram
        	for(c=0;c<256;c++){
        		windowPDF[c]=0;
        		backgroundPDF[c]=0;  // new background PDF
        	}
        	
        	//build histogram for window PDF around current point
        	if ((i-windowSize>1) && (j-windowSize>1) && (i+windowSize<width) && (j+windowSize<height)) {
        		for (r=i-windowSize; r<=i+windowSize; r++) {
        			for (s=j-windowSize; s<=j+windowSize; s++) {
        				windowPDF[(int)mydata.data[r][s]]++;
        			}
        		}
        	}
        	        	
            //perform sqrt for battacyara distance
            for(c=0;c<256;c++){
                windowPDF[c]=sqrt(windowPDF[c]);
            }

            for(c=0;c<numberOfClasses;c++){
                havenotcheckedclass[c]=true;
            }
            
            // Check 3x3 window around current point, test for other neighbouring classes j. 
            // For each different class, compute pdfv(W)*pdfv(j). Take the maximum value.
            // This corresponds to dominant neighbour class in window (either another cell or b/g).
            Fint(i,j)=0;
            for(m=-1;m<=1;m++){
                for(n=-1;n<=1;n++){
					if((i+m>=0)&&(i+m<width)&&(j+n>=0)&&(j+n<height)){
						neighbourClass=(unsigned char)classes.data[i+m][j+n];
						if((neighbourClass!=currentClass)&&(havenotcheckedclass[neighbourClass])){
							
							prob = 0;
							for(c=0;c<256;c++){
								prob+=histogram.at(neighbourClass)[c]*windowPDF[c];
							}
							// take maximum prob value for neighbour class
							if(prob>Fint.data[i][j]){
								Fint.data[i][j]=prob;
							}
						}
					}
                }
            }
            
            // Compute pdfv(W)*pdfv(i) for current class i.            
            prob=0;
            for(c=0;c<256;c++){
                prob+=histogram.at(currentClass)[c]*windowPDF[c]; //note sqrts for batt dist
            }
            Fint.data[i][j]-=prob;  // difference between PDF distances: (neighbour v window) - (current v window)
            Fint.data[i][j]*=(double)sign.data[i][j];
            Fint.data[i][j]*=alpha;  // scale region term by alpha parameter;
            
            if(useOrient) {
            	Fint.data[i][j]+=(beta*Fangle.data[i][j]);  // multiply by beta-scaled orientation term
            }
        }
    
    }
	
    delete [] havenotcheckedclass;
    delete [] windowPDF;
    
}

/**************************************************************************************************/


void NarrowBandLevelSet::reinitialisePhiZhao(){
	
	//function is based on "Fast sweeping method for eikonal equations 1: Distance function, H.K.Zhao, not published"

	int i,j,l,s1,s2;
	double ax,ay,a1,a2,ans,newphi;
	int width=phi.getWidth();
	int height=phi.getHeight();
	Point< int > pt;
	narrowband.clear();
	narrowband.resize(0);
	zeroband.clear();
	zeroband.resize(0);
	extensionbandINSIDE.clear();
	extensionbandINSIDE.resize(0);
	extensionbandEDGE.clear();
	extensionbandEDGE.resize(0);

	//reset phi
	for(i=0;i<width;i++){
		for(j=0;j<height;j++){
			phi.data[i][j]=99999;
			mine.data[i][j]=0;
		}
	}

	//set zero phi
	for(i=1;i<width-1;i++){
		for(j=1;j<height-1;j++){
			pt.move(i,j);
			if(classes.data[i][j]!=0){
				if( (classes.data[i][j]!=classes.data[i+1][j])||(classes.data[i][j]!=classes.data[i-1][j])||(classes.data[i][j]!=classes.data[i][j+1])||(classes.data[i][j]!=classes.data[i][j-1]) ){
					zeroband.push_back(pt);
					phi.data[i][j]=0;
				}
			}
		}
	}

	for(s1=-1;s1<=1;s1+=2)
		for(s2=-1;s2<=1;s2+=2)
			for(i=(s1<0?width-1:0);(s1<0?i>=0:i<width);i+=s1)
					for(j=(s2<0?height-1:0);(s2<0?j>=0:j<height);j+=s2){
						if(i==width-1){
							ax=phi.data[i-1][j];
						}else if(i==0){
							ax=phi.data[i+1][j];
						}else{
							ax=min(phi.data[i+1][j],phi.data[i-1][j]);	
						}
								
						if(j==height-1){
							ay=phi.data[i][j-1];
						}else if(j==0){
							ay=phi.data[i][j+1];
						}else{
							ay=min(phi.data[i][j+1],phi.data[i][j-1]);	
						}
								
						a1=min(ax,ay);
						a2=max(ax,ay);
						
						ans=a1+1;
						if(ans>a2){
							ans=(a1+a2+sqrt( 2-(pow((a1-a2),2)) ))/2;
						}
						newphi=min(phi.data[i][j],ans);	
						phi.data[i][j]=newphi;
								
					}			

	//reset phi
	for(i=0;i<width;i++){
		for(j=0;j<height;j++){
			pt.move(i,j);
			mine.data[i][j]=0;
			if(phi.data[i][j]<8){
				extensionband.push_back(pt);
				if((i==0)||(j==0)||(i==width-1)||(j==height-1)){
					extensionbandEDGE.push_back(pt);
				}else{
					extensionbandINSIDE.push_back(pt);
				}
				if(phi.data[i][j]<6){
					surfband.push_back(pt);
					mine.data[i][j]=1;
					if(phi.data[i][j]<4){
						narrowband.push_back(pt);
					}
				}	
			}	
			phi.data[i][j]*=sign.data[i][j];
		}
	}	
	for(l=0;l<zeroband.size();l++){
		pt=zeroband.at(l);
		mine.data[pt.x][pt.y]=0;
	}
	for(i=0;i<width;i++){
		for(j=0;j<height;j++){
			if(mine.data[i][j]==1){
				pt.move(i,j);
				surfnotzeroband.push_back(pt);	
			}
		}
	}

}

/**************************************************************************************************/

void NarrowBandLevelSet::thePengNarrowBand(){

	Point <int> pt;
	double gradPx,gradPy;
	double s,c;
	double deltaT=0.05,t;	
	double gradPxx,gradPyy,gradPxy;
	double gradPm,modphi;
	double DplusX,DplusY,DminusX,DminusY;
	double DelPlus,DelMinus;
	double curvature;
	double dphicurve;
	int width=phi.getWidth();
	int height=phi.getHeight();
	int i,j,l,o,p;
	double BETA=4,GAMMA=6;
	Image tempphi; 	
	tempphi.SetImageSize(width,height);
	bool hasneighbour;

	double avegrad;

	//SET TO INITIAL VALUES
	int volume=0;
	int oldvolume=0;

	DeltaPhi.Zero();
	gradx.Zero();
	grady.Zero();
	gradm.Zero();

	//FIND ZERO LS and gradients
	zeroband.clear();
	zeroband.resize(0);
	
	for(i=1;i<width-1;i++){
		for(j=1;j<height-1;j++){
			pt.move(i,j);
			if( (classes.data[i][j]!=classes.data[i+1][j])||(classes.data[i][j]!=classes.data[i-1][j])||(classes.data[i][j]!=classes.data[i][j+1])||(classes.data[i][j]!=classes.data[i][j-1]) ){
				zeroband.push_back(pt);
			}
			gradx.data[i][j]=(phi.data[i+1][j]-phi.data[i-1][j])/2;
			grady.data[i][j]=(phi.data[i][j+1]-phi.data[i][j-1])/2;
			gradm.data[i][j]=sqrt( (pow(gradx.data[i][j],2)+pow(grady.data[i][j],2) ) );
		}
	}

	//find the speed term
	findFintImproved();
	
	//calculate speed on the zero level set
	for(l=0;l<zeroband.size();l++){
		pt=zeroband.at(l);
		i=pt.x;
		j=pt.y;
		hasneighbour=false;

		for(o=-2;o<3;o++){
			for(p=-2;p<3;p++){
				if( ( (o!=0)||(p!=0) )&&((i+o>0)&&(j+p>0)&&(i+o<width-1)&&(j+p<height-1))){
					if((sign.data[i][j]==-1)&&(sign.data[i+o][j+p]==-1)&&(classes.data[i][j]!=classes.data[i+o][j+p])){
						hasneighbour=true;
					}			
				}
			}
		}
				
		if(!hasneighbour){

			DplusX = phi.data[i+1][j]-phi.data[i][j];
			DminusX = phi.data[i][j]-phi.data[i-1][j];
			DplusY = phi.data[i][j+1]-phi.data[i][j];
			DminusY = phi.data[i][j]-phi.data[i][j-1];

			DelPlus = sqrt( ( pow( max(DminusX,0),2 ) + pow( min(DplusX,0),2 ) + pow( max(DminusY,0),2 ) + pow( min(DplusY,0),2 )  ) );
			DelMinus = sqrt( ( pow( min(DminusX,0),2 ) + pow( max(DplusX,0),2 ) + pow( min(DminusY,0),2 ) + pow( max(DplusY,0),2 )  ) );

			gradPxx=(phi.data[i+1][j]-phi.data[i][j])-(phi.data[i][j]-phi.data[i-1][j]);
			gradPyy=(phi.data[i][j+1]-phi.data[i][j])-(phi.data[i][j]-phi.data[i][j-1]);
			gradPxy=(phi.data[i+1][j+1]+phi.data[i-1][j-1]-phi.data[i+1][j-1]-phi.data[i-1][j+1])/4;

			gradPx=gradx.data[i][j];
			gradPy=grady.data[i][j];
			gradPm=gradm.data[i][j];
			if(gradPm<0.000000001){
				gradPm=0.000000001;
			}

			curvature=((gradPx*gradPx*gradPyy+gradPy*gradPy*gradPxx-2*gradPx*gradPy*gradPxy)/pow(gradPm,3));
					
			dphicurve = ( (max(curvature,0)*DelPlus) + (min(curvature,0)*DelMinus) );

			DeltaPhi.data[i][j]= inrange(Fint.data[i][j]*gradPm) - inrange(gamma*dphicurve);
		}else{
			DeltaPhi.data[i][j]= -1 * delta;
		}
	}

	avegrad=0;
	for(l=0;l<surfnotzeroband.size();l++){ //narrowband.size()
		pt=surfnotzeroband.at(l);
		i=pt.x;
		j=pt.y;
		avegrad+=DeltaPhi.data[i][j];
	}
	
	//extend the speed to the band
	double tempx,tempy,phisq,phirt,phisqp,sumtemps;
	tempphi=DeltaPhi;

	deltaT=0.1;
	for(t=0;t<5;t+=deltaT){
		for(l=0;l<surfnotzeroband.size();l++){
			pt=surfnotzeroband.at(l);
			i=pt.x;
			j=pt.y;

			phisq=pow(phi.data[i][j],2);
			phisqp=phisq+0.01;
			phirt=sqrt(phisqp);
		
			s=phi.data[i][j]/phirt;
			
			if(gradm.data[i][j]<0.000000001)
				gradm.data[i][j]=0.000000001;
		
			tempx=s*gradx.data[i][j]/gradm.data[i][j];
			tempy=s*grady.data[i][j]/gradm.data[i][j];
	
			if((i-1>0)&&(i+1<width)&&(j-1>0)&&(j+1<height)){
				if(tempx>0){
					tempx*=(DeltaPhi.data[i][j]-DeltaPhi.data[i-1][j]);
				}else{
					tempx*=(DeltaPhi.data[i+1][j]-DeltaPhi.data[i][j]);
				}

				if(tempy>0){
					tempy*=(DeltaPhi.data[i][j]-DeltaPhi.data[i][j-1]);
				}else{
					tempy*=(DeltaPhi.data[i][j+1]-DeltaPhi.data[i][j]);
				}
			}
			
			sumtemps=tempx+tempy;
			
			tempphi.data[i][j]=DeltaPhi.data[i][j] - deltaT*sumtemps;
		}
		swap(DeltaPhi,tempphi);
		DeltaPhi=tempphi;
	}

	avegrad=0;
	for(l=0;l<surfnotzeroband.size();l++){ //narrowband.size()
		pt=surfnotzeroband.at(l);
		i=pt.x;
		j=pt.y;
		avegrad+=DeltaPhi.data[i][j];
	}

	//implemement a smooth cut-off band, then update phi
	for(l=0;l<surfband.size();l++){
		pt=surfband.at(l);
		i=pt.x;
		j=pt.y;
		modphi=sqrt( pow(phi.data[i][j],2));
		if( modphi<BETA ){
			c=1;
		}else if( modphi>GAMMA ){
			c=0;
		}else{
			c=pow( modphi-GAMMA ,2)*(2*modphi+GAMMA-3*BETA)/(pow(GAMMA-BETA,3)); 
		}
		DeltaPhi.data[i][j] *= c;

		phi.data[i][j]-=TimeStep*DeltaPhi.data[i][j];
	}

	avegrad=0;
	for(l=0;l<surfnotzeroband.size();l++){ //narrowband.size()
		pt=surfnotzeroband.at(l);
		i=pt.x;
		j=pt.y;
		avegrad+=DeltaPhi.data[i][j];
	}


	//reinitialize to signdist function
   	tempphi=phi;

	if(extensionbandEDGE.size()==0){
		deltaT=0.1;
		for(t=0;t<5;t+=deltaT){								//number of reinitialisation loops
			for(l=0;l<extensionbandINSIDE.size();l++){
				pt=extensionbandINSIDE.at(l);
				i=pt.x;
				j=pt.y;
				tempphi.data[i][j]=reinitialisePhiPeng(i,j,deltaT,width,height);
			}
			phi=tempphi;
		}
	}else{
		deltaT=0.1;
		for(t=0;t<5;t+=deltaT){   
			for(l=0;l<extensionbandINSIDE.size();l++){
				pt=extensionbandINSIDE.at(l);
				i=pt.x;
				j=pt.y;
				tempphi.data[i][j]=reinitialisePhiPeng(i,j,deltaT,width,height);
			}
			phi=tempphi;
			for(l=0;l<extensionbandEDGE.size();l++){
				pt=extensionbandEDGE.at(l);
				i=pt.x;
				j=pt.y;
				tempphi.data[i][j]=reinitialisePhiPengCHECK(i,j,deltaT);
			}	
			phi=tempphi;
		}
	}
	
	//find new bands, update classes
	narrowband.clear();
	narrowband.resize(0);
	surfband.clear();
	surfband.resize(0);
	extensionband.clear();
	extensionband.resize(0);
	extensionbandINSIDE.clear();
	extensionbandINSIDE.resize(0);
	extensionbandEDGE.clear();
	extensionbandEDGE.resize(0);
	zeroband.clear();
	zeroband.resize(0);
	surfnotzeroband.clear();
	surfnotzeroband.resize(0);

	for(i=0;i<width;i++){
		for(j=0;j<height;j++){
			sign.data[i][j]=signof(phi.data[i][j]);
			modphi=sqrt( pow(phi.data[i][j],2));
			if(modphi<GAMMA){
				pt.move(i,j);
				surfband.push_back(pt);
				if(modphi<=BETA){
					narrowband.push_back(pt);
				}
			}else{
				phi.data[i][j]=GAMMA*sign.data[i][j];
			}
			if((sign.data[i][j]==-1)&&(classes.data[i][j]==0)){
				for(o=-1;o<2;o+=2)
					for(p=-1;p<2;p+=2){
						if((i+o>0)&&(i+o<width)&&(j+p>0)&&(j+p<height))
							if((sign.data[i+o][j+p]==-1)&&(classes.data[i+o][j+p]!=0)){
								sign.data[i][j]=sign.data[i+o][j+p];
								classes.data[i][j]=classes.data[i+o][j+p];
							}						
					}				
			}else if(sign.data[i][j]==1){
				classes.data[i][j]=0;
			}

			mine.data[i][j]=0;
			
		}
	}
	for(l=0;l<surfband.size();l++){
		pt=surfband.at(l);
		i=pt.x;
		j=pt.y;
		for(o=-2;o<3;o++){
			for(p=-2;p<3;p++){
				if((i+o>0)&&(i+o<width)&&(j+p>0)&&(j+p<height)){
					mine.data[i+o][j+p]=1;
				}
			}
		}
	}	
	
	for(i=0;i<width;i++){
		for(j=0;j<height;j++){
			if(mine.data[i][j]==1){
				pt.move(i,j);
				extensionband.push_back(pt);
				if((i==0)||(j==0)||(i==width-1)||(j==height-1)){
					extensionbandEDGE.push_back(pt);
				}else{
					extensionbandINSIDE.push_back(pt);
				}
			}
		}
	}
	for(i=1;i<width-1;i++){
		for(j=1;j<height-1;j++){
			if( (classes.data[i][j]!=classes.data[i+1][j])||(classes.data[i][j]!=classes.data[i-1][j])||(classes.data[i][j]!=classes.data[i][j+1])||(classes.data[i][j]!=classes.data[i][j-1]) ){
				pt.move(i,j);
				zeroband.push_back(pt);
			}
		}
	}
	for(i=0;i<width;i++){
		for(j=0;j<height;j++){
			mine.data[i][j]=0;
		}
	}
	for(l=0;l<surfband.size();l++){
		pt=surfband.at(l);
		mine.data[pt.x][pt.y]=1;
	}
	for(l=0;l<zeroband.size();l++){
		pt=zeroband.at(l);
		mine.data[pt.x][pt.y]=0;
	}
	oldvolume = volume;
	for(i=0;i<width;i++){
		for(j=0;j<height;j++){
			if(mine.data[i][j]==1){
				pt.move(i,j);
				surfnotzeroband.push_back(pt);	
			}
			if(sign.data[i][j]==-1){
				volume++;
			}
		}
	}

    FILE *outFile = NULL;
    outFile = fopen("_out_volume.txt","a");
    fprintf(outFile, "%d\n", volume);
    fclose(outFile);

}

/**************************************************************************************************/

inline double NarrowBandLevelSet::reinitialisePhiPeng(int i,int j, double deltaT, int width, int height){

		double a,b,c,d,s;
		double gradPx,gradPy,gradPmSq,phiSq;
		double temptotal,tempa,tempb,tempc,tempd;
	
		gradPx=(phi.data[i+1][j]-phi.data[i-1][j])/2;
		gradPy=(phi.data[i][j+1]-phi.data[i][j-1])/2;

		a=phi.data[i][j]-phi.data[i-1][j];
		b=phi.data[i+1][j]-phi.data[i][j];
		c=phi.data[i][j]-phi.data[i][j-1];
		d=phi.data[i][j+1]-phi.data[i][j];

		tempa=gradPx*gradPx;
		tempb=gradPy*gradPy;

		phiSq=phi.data[i][j]*phi.data[i][j];

		gradPmSq=tempa+tempb;

		tempa = phiSq+gradPmSq;
		tempb=sqrt(tempa);

		s=phi.data[i][j]/( sqrt( (phiSq + gradPmSq) )  ); //deltaX=1!
	
		tempa=0;
		tempb=0;
		tempc=0;
		tempd=0;
		if(s>0){
			if(a>0){
				tempa=a*a;
			}
			if(b<0){
				tempb=b*b;
			}
			if(c>0){
				tempc=c*c;
			}
			if(d<0){
				tempd=d*d;
			}
		}else{
			if(a<0){
				tempa=a*a;
			}
			if(b>0){
				tempb=b*b;
			}
			if(c<0){
				tempc=c*c;
			}
			if(d>0){
				tempd=d*d;
			}
		}
		tempa+=tempb;
		tempc+=tempd;
		tempa+=tempc;
		temptotal=sqrt( tempa );
		temptotal--;

		//Engwuist-Osher's scheme
		//return phi(i,j,k) - deltaT*( max(s,0)*(sqrt( pow(max(a,0),2)+pow(min(b,0),2)+pow(max(c,0),2)+pow(min(d,0),2)+pow(max(e,0),2)+pow(min(f,0),2) )-1) + min(s,0)*(sqrt( pow(min(a,0),2)+pow(max(b,0),2)+pow(min(c,0),2)+pow(max(d,0),2)+pow(min(e,0),2)+pow(max(f,0),2) )-1) ); 
		return phi.data[i][j] - deltaT*s*temptotal;
		//Godunov's scheme
//		return phi(i,j,k) - deltaT*( max(s,0)*(sqrt( max(pow(max(a,0),2),pow(min(b,0),2))+min(pow(max(c,0),2),pow(min(d,0),2)) )-1)+ min(s,0)*(sqrt( max(pow(min(a,0),2),pow(max(b,0),2))+min(pow(min(c,0),2),pow(max(d,0),2)) )-1) );
	
}

/**************************************************************************************************/

inline double NarrowBandLevelSet::reinitialisePhiPengCHECK(int i,int j, double deltaT){
		double a,b,c,d,s;
		double gradPx,gradPy,gradPmSq;
		int width=phi.getWidth();
		int height=phi.getHeight();

		if(i==0){
			gradPx=phi.data[i+1][j]-phi.data[i][j];
			a=phi.data[i+1][j]-phi.data[i][j];
			b=a;
		}else if(i==width-1){
			gradPx=phi.data[i][j]-phi.data[i-1][j];
			a=phi.data[i][j]-phi.data[i-1][j];
			b=a;
		}else{
			gradPx=(phi.data[i+1][j]-phi.data[i-1][j])/2;
			a=phi.data[i][j]-phi.data[i-1][j];
			b=phi.data[i+1][j]-phi.data[i][j];
		}

		if(j==0){
			gradPy=phi.data[i][j+1]-phi.data[i][j];
			c=phi.data[i][j+1]-phi.data[i][j];
			d=c;
		}else if(j==height-1){
			gradPy=phi.data[i][j]-phi.data[i][j-1];
			c=phi.data[i][j]-phi.data[i][j-1];
			d=c;
		}else{
			gradPy=(phi.data[i][j+1]-phi.data[i][j-1])/2;
			c=phi.data[i][j]-phi.data[i][j-1];
			d=phi.data[i][j+1]-phi.data[i][j];
		}
		
		gradPmSq=(pow(gradPx,2)+pow(gradPy,2));
		s=phi.data[i][j]/( sqrt( (pow(phi.data[i][j],2) + gradPmSq) )  );  ; //deltaX=1!
	
		//Engwuist-Osher's scheme
		return phi.data[i][j] - deltaT*( max(s,0)*(sqrt( pow(max(a,0),2)+pow(min(b,0),2)+pow(max(c,0),2)+pow(min(d,0),2) )-1) + min(s,0)*(sqrt( pow(min(a,0),2)+pow(max(b,0),2)+pow(min(c,0),2)+pow(max(d,0),2) )-1) ); 
		//Godunov's scheme
//		return phi(i,j,k) - deltaT*( max(s,0)*(sqrt( max(pow(max(a,0),2),pow(min(b,0),2))+min(pow(max(c,0),2),pow(min(d,0),2)) )-1)+ min(s,0)*(sqrt( max(pow(min(a,0),2),pow(max(b,0),2))+min(pow(min(c,0),2),pow(max(d,0),2)) )-1) );


}

