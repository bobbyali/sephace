#include "mex.h"

int coord(int i, int j, int cols);
void mexFunction (int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);

// inputs are (1) ci0d image, (2) mask, (3) distance map. 
// outputs are (1) fitting parameter map.
void mexFunction (int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
		
	double *image;			// CID ci0d input image	
	double *mask;			// mask image
	double *distmap;		// distance map image
	double *fit;			// output fitting values
	double tempsum;			// temporary sum of pixels in window
	int count = 0;			// counter for output
	int m,n;				// size of input image (rows,cols)
	const double PI = std::atan(1.0)*4;	// define PI

	
	//There should be one output argument.
    if (nlhs > 1)
		mexErrMsgTxt ("Too many output arguments.");

    // There should be two input arguments.
    if (nrhs > 3)
		mexErrMsgTxt ("Too many input arguments.");
    if (nrhs < 3)
		mexErrMsgTxt ("Not enough input arguments.");
	
	// get image dimensions
	m = mxGetM(prhs[0]);	// rows
	n = mxGetN(prhs[0]);	// columns
	
	// set up inputs
	image   = mxGetPr(prhs[0]);	
	mask 	= mxGetPr(prhs[1]);
	varmap 	= mxGetPr(prhs[2]);
	
	// set up output
	plhs[0] = mxCreateDoubleMatrix(m*n*40*40*,6,mxREAL);
	fitmap  = mxGetPr(plhs[0]);

	// loop through all pixels that are w away from border
	for (int x = 1; x < m; x++) {
		for (int y = 1; y < n; y++) {			
			for (int a = 20; a < 60; a++) {
				for (int b = 20; b < 60; b++) {
					for (int t = 0; t < PI; a+(PI/8)) {
													
						/*
						tempsum = 0;			
						mean = 0;
						variance = 0;
						
						// find mean
						for (int p = i-w; p < i+w; p++) {
							for (int q = j-w; q < j+w; q++) {
								tempsum  += image[coord(p,q,m)];
							}
						}			
						mean = tempsum / wn;	
						
						// find variance
						for (int p = i-w; p < i+w; p++) {
							for (int q = j-w; q < j+w; q++) {
								tempprod = (image[coord(p,q,m)] - mean);
								tempprod = tempprod * tempprod;
								variance += tempprod;
							}
						}	
						
						variance = variance/(wn-1);

						varmap[coord(i,j,m)] = 1 - (1 / ( 1 + variance));    // based on texture
						//varmap[coord(i,j,m)] = variance;
						*/
					}
				}
			}
		}
	}
	
	
}

// returns value from linear matlab array using 2d indexing
// from http://www.mattfoster.clara.co.uk/files/image_mex.pdf
// ( see also http://www.mathworks.com/matlabcentral/newsreader/view_thread/258682
//   to convert to C 2D array using mxCalloc )
int coord(int i, int j, int cols) {
	//return j * cols + i;
	return j * cols + i;
}
