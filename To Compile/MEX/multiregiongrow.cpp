#include "mex.h"
#include <vector>

using namespace std;

int  pt(int i, int j, int cols);
void mexFunction (int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);

void mexFunction (int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
		
	double *mask;			// input image: binary mask
	double *init;			// input image: initial label map
	double *final;			// output image: final label map
	int m,n;				// size of input image (rows,cols)
	double current;			// current label
	bool blnStop = 0;		// stopping term for region growing (1 = stop)	
	int x,y;				// temporary variables to store current x,y coords
	double l;				// temporary variable to store current label
	int count = 0;
	std::vector<int> list_x;
	std::vector<int> list_y;
	std::vector<double> list_l;
	std::vector<int> newlist_x;
	std::vector<int> newlist_y;
	std::vector<double> newlist_l;
	
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
	mask    = mxGetPr(prhs[0]);	
	init 	= mxGetPr(prhs[1]);
	
	// set up output
	plhs[0] = mxCreateDoubleMatrix(m,n,mxREAL);
	final   = mxGetPr(plhs[0]);
	
	// final label map starts off as initial label map
	//final   = init;
	for (int i = 1; i < m; i++) {
		for (int j = 1; j < n; j++) {
			final[pt(i,j,m)] = static_cast<int> (init[pt(i,j,m)]);
		}
	}
	
	// generate list of edge pixels
	for (int i = 2; i < m-1; i++) {
		for (int j = 2; j < n-1; j++) {
			
			current = final[pt(i,j,m)];
			
			if ((final[pt(i+1,j,m)] != current || final[pt(i-1,j,m)] != current || 
				final[pt(i,j+1,m)] != current || final[pt(i,j-1,m)] != current) &&
				current > 0) {						
					list_x.push_back(i);
					list_y.push_back(j);
					list_l.push_back(current);
			}						
		}
	}		
		
	// region growing algorithm
	while (blnStop == 0) {
		
		count = 0;
		
		for (int c = 1; c < list_x.size(); c++) {
			
			// get coords, label for current list item
			x = list_x[c];
			y = list_y[c];
			l = list_l[c];
	
			// check 3x3 window around current point - if neighbours are
			// background points and their mask values are 1 (i.e. growable 
			// regions), then grow the region out
			if (x > 1 && x < m && y > 1 && y < n) {
				
				if (final[pt(x-1,y,m)] == 0 && mask[pt(x-1,y,m)] > 0) {
					newlist_x.push_back(x-1);
					newlist_y.push_back(y);
					newlist_l.push_back(l);
					final[pt(x-1,y,m)] = l;
				}			
				
				if (final[pt(x+1,y,m)] == 0 && mask[pt(x+1,y,m)] > 0) {
					newlist_x.push_back(x+1);
					newlist_y.push_back(y);
					newlist_l.push_back(l);
					final[pt(x+1,y,m)] = l;
				}
				
				if (final[pt(x,y-1,m)] == 0 && mask[pt(x,y-1,m)] > 0) {
					newlist_x.push_back(x);
					newlist_y.push_back(y-1);
					newlist_l.push_back(l);
					final[pt(x,y-1,m)] = l;
				}
				
				if (final[pt(x,y+1,m)] == 0 && mask[pt(x,y+1,m)] > 0) {
					newlist_x.push_back(x);
					newlist_y.push_back(y+1);
					newlist_l.push_back(l);
					final[pt(x,y+1,m)] = l;
				}
								
				if (final[pt(x-1,y-1,m)] == 0 && mask[pt(x-1,y-1,m)] > 0) {
					newlist_x.push_back(x-1);
					newlist_y.push_back(y-1);
					newlist_l.push_back(l);
					final[pt(x-1,y-1,m)] = l;
				}
				
				if (final[pt(x-1,y+1,m)] == 0 && mask[pt(x-1,y+1,m)] > 0) {
					newlist_x.push_back(x-1);
					newlist_y.push_back(y+1);
					newlist_l.push_back(l);
					final[pt(x-1,y+1,m)] = l;
				}
				
				if (final[pt(x+1,y-1,m)] == 0 && mask[pt(x+1,y-1,m)] > 0) {
					newlist_x.push_back(x+1);
					newlist_y.push_back(y-1);
					newlist_l.push_back(l);
					final[pt(x+1,y-1,m)] = l;
				}
				
				if (final[pt(x+1,y+1,m)] == 0 && mask[pt(x+1,y+1,m)] > 0) {
					newlist_x.push_back(x+1);
					newlist_y.push_back(y+1);
					newlist_l.push_back(l);
					final[pt(x+1,y+1,m)] = l;
				}				
				
			}
		}	
		
		mexPrintf("New count = %d\n",newlist_x.size());
		
		// if the new list is empty then algorithm has grown
		// as far as it can - stop it.
		if (newlist_x.size() == 0) {
			blnStop = 1;
		} else {
			// clear the old list, copy over the new list, then
			// clear the new list
			list_x = newlist_x;
			list_y = newlist_y;
			list_l = newlist_l;
			newlist_x = vector<int>();
			newlist_y = vector<int>();
			newlist_l = vector<double>();			
		}
	}
	
	
}
	

	
// returns value from linear matlab array using 2d indexing
// from http://www.mattfoster.clara.co.uk/files/image_mex.pdf
// ( see also http://www.mathworks.com/matlabcentral/newsreader/view_thread/258682
//   to convert to C 2D array using mxCalloc )
int pt(int i, int j, int cols) {
	//return j * cols + i;
	return j * cols + i;
}
