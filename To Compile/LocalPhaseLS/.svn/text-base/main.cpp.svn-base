/*
  Multi-Object Level Set for Phase-Based Brightfield 
  Microscopy Cell Segmentation  
	- Optimised
	- Windows version

  Rehan Ali, April 2008
  Based on code by Dr Mark Gooding, http://www.robots.ox.ac.uk/~gooding/

  Input:

      segment <input_phase.bmp> <input_start.bmp> <input_orient.bmp> 
			<output_classes.bmp> <output_phi.bmp> <iterations> <mode>
			<alpha> <beta> <gamma> <delta>

		input_phase.bmp  		-  Input local phase image
		input_start.bmp			-  Input original intensity image
		input_orient.bmp		-  Input local orientation image
		output_classes.bmp		-  Output labelled image of final region classes
		output_phi.bmp			-  Output signed distance function
		iterations				-  Number of iterations e.g. 50
		mode					-  1 = use local orientation term
								   0 = don't use local orientation term
        alpha                   -  Tuning parameter for local phase region term (normal is 5)
        beta                    -  Tuning parameter for local orientation term (normal is 2.5)
        gamma                   -  Tuning parameter for curvature term (normal is 1)
        delta                   -  Tuning parameter for repulsion term (0 = off, 5 = normal) (gets multiplied by -1)

  This program uses the LibPNG libraries.

  ======================================================================================
*/
#include <cstdlib>
#include "Image.h"
#include "NarrowBandLevelSet.h"
#include "Point.h"

using std::cout;
using std::endl;


int main(int argc, char *argv[])
{
   int i,j;

   if( argc < 12 )
        {
        std::cerr << "Usage: " << argv[0];
        std::cerr << " [1] input LocalPhaseImage [2] input OriginalIntensityImage ";
    	std::cerr << " [3] input LocalOrientationImage [4] output FinalRegionMap ";
    	std::cerr << " [5] output FinalPhi [6] NumIterations [7] UseOrientation ";
    	std::cerr << " [8] alpha LocalPhaseTerm [9] beta LocalOrientationTerm ";
        std::cerr << " [10] gamma CurvatureTerm [11] delta RepulsionTerm";
        std::cerr << std::endl;  
        return EXIT_FAILURE;
   }
      
   // open the input (local phase) image
   Image I, b, p;
   if(I.ReadPNG(argv[1]))
   {
      printf("Unable to open input (local phase) image file, \"%s\".\n",argv[1]);
      return 1;
   } 
   cout << "Opened file 1" << endl;
   
   // open the input class label image
   if(b.ReadPNG(argv[2]))
   {
      printf("Unable to open initial label map, \"%s\".\n",argv[2]);
      return 1;
   } 
   cout << "Opened file 2" << endl;
   
   // open the input local orientation image
   if(p.ReadPNG(argv[3]))
   {
      printf("Unable to open local orientation image, \"%s\".\n",argv[3]);
      return 1;
   } 
   cout << "Opened file 3" << endl;
      
   cout << "About to start LS" << endl;
      
   // segment stuff
   int width  = I.getWidth();
   int height = I.getHeight();
   Image classes;  // set up the final class file
   classes.SetImageSize(width, height);
   
   bool useAngle;
   if (atoi(argv[7]) > 0) {
   		useAngle = 1;
   } else {
   		useAngle = 0;
   }
   
   double alpha = atof(argv[8]);
   double beta = atof(argv[9]);
   double gamma = atof(argv[10]);
   double delta = atof(argv[11]);
   		
   NarrowBandLevelSet LS(I,b,p,0,useAngle,alpha,beta,gamma,delta);
   	
   classes = LS.RunLevelSet(atoi(argv[6]));
   
   cout << "Finished running LS" << endl;
   
   // set classes to range 1-x so that it can be written out
   for (int i = 0; i < classes.getWidth(); i++) {
   		for (int j = 0; j < classes.getHeight(); j++) {
   			classes(i,j)++;
   		}
   }
   
   
   // write out stuff
   classes.WritePNG(argv[4]);
   cout << "Saved final class file" << endl;
   
   Image phi;
   phi.SetImageSize(width,height);
   phi = LS.GetPhi();
   phi.WriteSignedRaw(argv[5]);
   cout << "Saved final signed distance file (+128)" << endl;
   
   //*/ 
   
   
   return 0;
   
}


