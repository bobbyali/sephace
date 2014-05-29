==============  sephaCe  ===================
       Interface for Phase-Based 
     Brightfield Cell Segmentation 
============================================
    Rehan Ali and Dr Mark Gooding
    Wolfson Medical Vision Lab, 
    Department of Engineering Sciences, 
    University of Oxford

    http://www.sephace.com

sephaCe is a graphical interface for phase-based brightfield cell 
segmentation, using the algorithm shown in [Ali et al, 2008].
To find out more about it, or to obtain a copy of the manuscript, contact
Rehan Ali at bobby@robots.ox.ac.uk

sephaCe accurately segments cell boundaries using the monogenic signal
[Felsberg and Sommer, 2001] combined with a novel region and orientation
level set contour evolution scheme based on [Gooding et al, 2007].

sephaCe requires two brightfield images (equal distance +/- in-focus image).
A fluorescence image can also be provided to compare against the segmentation 
results.

See the enclosed LICENSE.TXT file for license and copyright information.

============================================
INSTALLATION
============================================

To run sephaCe you need the following:
1. Matlab 7 or above (not tested on earlier versions)
2. Matlab Image Processing Toolbox
3. A C++ compiler (not necessary for Windows)

Unzip the archive into a directory of your choice. 

sephaCe consists of a MatLab GUI and a C++ level set application. These files 
have been tested on Ubuntu 7.04 (Feisty) and Windows XP. 

If you're using a non-Windows O/S, you will need to recompile the level
set code, using a C++ compiler such as GCC (or MinGW GCC in Windows).

============================================
INSTRUCTIONS
============================================

1. To run sephaCe, load Matlab, browse to the directory where the files 
are stored, and type in "segment_tool". The sephaCe GUI will then appear.

2. Click on "Load Images" to load some images to process. The file
browser window will appear.

3. The minimum requirement to perform a segmentation is two brightfield
microscope images, of equal distance above and below the focal plane.
A defocus distance of 5 um worked for us. If the defocus distance is
too small, the segmentation result will be patchy, but if it's too large, 
the final result will be smoothed out as you lose cell resolution. 

To load the positively defocused image, select the image in the listbox 
control, then click on Ip. To load the negatively defocused image, 
select the image and click on Im. 

You can also load a fluorescence image, the in-focus image, and a manual
segmentation binary image to compare the segmentation result against. 

Once you've loaded all the images you need, close the image browser window.

3. Click on the "Crop" button and select a region of the images which 
contains the cells you wish to process.

4. Click on the "Pick Cells" button and click once on each cell in the
image. Left-click on most of the cells, but make sure you RIGHT-CLICK
on the last cell, to stop the Matlab GUI looking for any more inputs. 
This helps sephaCe break apart any large clusters of cells in the 
initialisation step.

5. Click on "Pre-Process" to perform various pre-processing tasks, including
computing the monogenic signal transform, and splitting any clusters of 
cells apart. This may take 1-2 minutes depending on the size of your image.
When this finishes, you can view various pre-processing results from a 
drop-down box.

7. Click on "Run Level Set" to start the level set contour evolution. This
runs the level set for 50 iterations in the background. Click on "Show Results"
to show the latest contour. 

Once the level set has completed, the output is saved in a new date-stamped
directory in the "data" directory. The out_regions.png file can be used as
a mask in your own applications.

8. A sample application of the segmentation is built into sephaCe. 
You can use the result to extract a fluorescence timeseries from a set of 
images by clicking on "Fluorescence".

9. If you want to extract a fluorescence timeseries, the "Fluorescence" 
button will bring up a Fluorscence Extracter window. Use this to browse
to the directory with your timeseries images. Enter a prefix that identifies
the part of the image filename before the time at which the image was taken.

e.g. image_LysoTracker_14Oct07_1543.bmp
     image_LysoTracker_14Oct07_1548.bmp
     image_LysoTracker_14Oct07_1558.bmp

	A usable prefix is "14Oct07_"

Click on "Add images" to analyse all the files with this prefix string.
Click on "Plot" to extract a sum of the intensities within each segmentation
result region from each timeseries image, and plot them on the graph.

============================================
VERSION HISTORY
============================================

v0.1 28/12/2007
* Initial screen created, with pre-processing and 
processing controls, based on GUIDE template.

v0.3 03/01/2008
* Revised with new file browser window, and main
interface is tidied up with several improvements.
 *Outputs results into a new folder and provides 
sufficient information for future analysis of 
results.

v0.4 04/01/2008
* Added ability to reload earlier dataset
* Save out local energy file
* Fixed bug - cropped image sometimes appears small in 
top-right corner
* Added fluorescence timeseries extracter.

v0.5 08/01/2008
* Fixed bug where resetting image resulted in not setting 
newly loaded images to double, which messed up the LP.
* On reset, now disable all the processing buttons.

v0.6 11/01/2008
* Modified image browser to allow addition of in-focus and
manual segmentation images.
* Added new validation functionality that compares user-specified
segmentation regions against specific manual seg regions, and 
computes the true positive statistics
* Modified fluorescence extracter to import files automatically
based on file prefix
* Made superimposed contour on fluorescence extracter screen
easier to see

v0.7 12/01/2008
* Allowed queueing of large jobs into a "queue.bat" file
* Allowed loading of different ground truth masks
* Improved pre-processing to strip out non-selected regions
  that appear after thresholding

v0.8 16/01/2008
* Added fix for local bg noise phase - use variance mask, 
  threshold value 0.95
* (looking into MI registration...)
* Fixed presentation of LP,LE,LO from saved datasets

v1.0 07/05/2008
* Added tweakable parameters for level set.
* Removed manual validation options (only required for testing).
* Tidied interface and code.

============================================
TROUBLESHOOTING
============================================

Q. I get the error message "Undefined function or method 
'segment_tool' for input arguments of type 'struct'."

A. Not sure what's causing this yet. The only fix is to close
sephaCe and restart.

Q. When I push the "Run Level Set" button, and then click on
"Show Results", nothing happens / the wrong contour appears,
even after a long wait.

A. This happens if sephaCe isn't run from its installation
directory. Close it, browse in Matlab to the install folder, and
restart.

Q. When I load a previously saved dataset, the images don't
appear properly.

A. This feature is still under development. For now, it's good
for looking at a previous segmentation result, but if you need
to reprocess the image, you should hit "Reset".

Q. How is sephaCe supposed to be spelt?

A. "see-phase" - as in "see phase object". "sepha" is an anagram
of phase, and Ce is short for Cell. 

Q. I get the following error when I run the queue.bat file:

terminate called after throwing an instance of 'std::out_of_range'
  what():  deque::_M_range_check

A. Something's going wrong with the Level Set code. Send the details to
bobby@robots.ox.ac.uk or post them on the sephaCe forum, and we'll look 
into the problem.

============================================
REFERENCES
============================================
Ali et al, 2008
  "Advanced Phase-Based Segmentation of Multiple Cells from
   Brightfield Microscopy Images"
   R Ali, M Gooding, M Christlieb, JM Brady
   Submitted to IEEE Symposium on Biomedical Imaging 2008
   http://www.rehanali.co.uk

Felsberg and Sommer, 2001
  "The Monogenic Signal"
   M Felsberg and G Sommer
   IEEE Trans Sig Proc 49(2001):12,pp3136-3144

Gooding et al, 2007
  "Volume segmentation and reconstruction from freehand 3D 
   ultrasound data with application to ovarian follicle
   measurement"
   M Gooding, S Kennedy and J Noble
   Ultrasound Med Biol, 2007, accepted
   http://www.robots.ox.ac.uk/~gooding/
