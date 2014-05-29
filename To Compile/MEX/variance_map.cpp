#include "mex.h"

int coord(int i, int j, int cols);
void mexFunction (int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);

void mexFunction (int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
		
	double *image;			// input image	
	double *wptr;			// window size as pointer
	double w;				// window size
	double *varmap;			// output variance map
	double tempsum;			// temporary sum of pixels in window
	double tempprod;		// temporary product of pixels in window
	double mean;			// mean of pixel values in window
	double wn;				// num of pixels in window
	double variance;		// temp variance
	int m,n;				// size of input image (rows,cols)
	
	//There should be one output argument.
    if (nlhs > 1)
		mexErrMsgTxt ("Too many output arguments.");

    // There should be two input arguments.
    if (nrhs > 2)
		mexErrMsgTxt ("Too many input arguments.");
    if (nrhs < 2)
		mexErrMsgTxt ("Not enough input arguments.");
	
	// get image dimensions
	m = mxGetM(prhs[0]);	// rows
	n = mxGetN(prhs[0]);	// columns
	
	// set up inputs
	image   = mxGetPr(prhs[0]);	
	wptr 	= mxGetPr(prhs[1]);
	
	// get window parameters
	w		= wptr[0];	
	wn   	= (w*2)*(w*2);		// number of pixels in window used
	
	// set up output
	plhs[0] = mxCreateDoubleMatrix(m,n,mxREAL);
	varmap  = mxGetPr(plhs[0]);

	// loop through all pixels that are w away from border
	for (int i = w; i < m-w; i++) {
		for (int j = w; j < n-w; j++) {			
								
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
