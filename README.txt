README for sephaCe

sephaCe is a Matlab/C-based application for automatically segmenting biological cell boundaries and nuclei using only brightfield microscopy image data. The official Github repo is at https://github.com/bobbyali/sephace

The main application is in the Main folder. To start, load the "segment_tool.m" script in Matlab. Full instructions are in the "README.TXT" file. Note that the main application has several dependencies on 3rd party and compiled C code. It was developed and tested on a 32 bit Windows XP laptop. If you need to run it on a different platform, you'll need to recompile the binaries in the "To Compile" folder, and obtain binaries for the 3rd party libraries in the "3rd Party Libs" folder.

A quicker option to get going is to use the Minimal code versions, which are simple scripts that don't include the GUI. These are in the "Minimal Code" folder. There are two versions, one that simply performs the automatic cell detection (in "Init only"; run the "sephace.m" script) and only requires Matlab, and another that performs the cell detection and boundary segmentation (in "Init and LS"; run the "sephace.m" script) which executes the level set boundary segmentation as well, but which may require some pre-compiling before it'll work on your system (unless you're using 32bit Windows). (There isn't currently a minimal form that includes the nucleus segmentation, but this is coming shortly.)

Some sample Z-stacks are in the "Data" folder.

At some point I'll rewrite the local phase level set in MEX and remove the dependencies on 3rd party libraries. Definitely on my to-do list!

- Rehan Ali

