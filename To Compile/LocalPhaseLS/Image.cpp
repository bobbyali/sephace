// Image.cpp: implementation of the Image class.
//
// - modified by Rehan Ali, 15th October 2007
//////////////////////////////////////////////////////////////////////

#include "Image.h"

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

Image::Image(int w, int h){

	int i;
	height=h;
	width=w;
	data = new double* [width];
	for (i=0; i < width; i++)
		data[i] = new double[height];


}

Image::Image(){
	data=NULL;
}

void Image::SetImageSize(int w, int h){

	int i;
	height=h;
	width=w;
	data = new double* [width];
	for (i=0; i < width; i++)
		data[i] = new double[height];


}
 
Image::Image(Image const &im) {  // copy constructor (creates new image as copy of old)
	int i, j;
	this->height = im.height;
	this->width = im.width;
	// allocate memory
	this->data = new double*[this->width];
	for (i=0; i < this->width; i++)
		this->data[i] = new double[this->height];
	// Copy values.
	for (i=0; i < this->width; i++)
		for (j=0; j < this->height; j++)
			this->data[i][j] = im.data[i][j];
}


Image&  Image::operator=(Image const &im) {  // equals operator - sets image to another image (copy)
	int i, j;
	if (this != &im) {
		if ((this->height != im.height) || (this->width != im.width)) {
		//	if(data){
				// free memory.
				for (i=0; i < this->width; i++)
					delete[] this->data[i];
				delete[] this->data;
				this->height = im.height;
				this->width = im.width;
		//	} else {
		//		SetImageSize(im.width,im.height);
		//	}
			// allocate memory
			this->data = new double*[this->width];
			for (i=0; i< this->width; i++)
				this->data[i] = new double[this->height];
		}
		// Copy values.
		for (i=0; i < this->width; i++) 
			for (j=0; j< this->height; j++) {
				this->data[i][j] = im.data[i][j];
			//	cout << i << " " << j << " " << data[i][j] << endl;
			}
	}       // end of 'if (this != &im)'
	return *this;
}

double& Image::operator()(int x, int y){
	if ((x < 0) || (x >= this->width) || (y < 0) || (y >= this->height)){
		cerr << "Index ("<<x<<","<<y<<") out of bounds error in"<< " Image::operator()(int x, int y)"<<endl;
		exit(1);
    }
	return this->data[x][y];
}

double Image::operator()(int x, int y) const{
	if ((x < 0) || (x >= this->width) || (y < 0) || (y >= this->height)){
		cerr << "Index ("<<x<<","<<y<<") out of bounds error in"<< " Image::operator()(int x, int y)"<<endl;
		exit(1);
    }
	return this->data[x][y];
}


Image::~Image(){
	
	int i;
	// free memory.
	for (i=0; i < this->width; i++)
		delete [] this->data[i];
	delete [] this->data;
}



void Image::setData(double d, int x, int y){
	data[x][y]=d;
}


void Image::setData(int d, int x, int y){
   
	data[x][y]=(double) d;

}

double Image::getData(int x, int y){

	return data[x][y];

}



int Image::getHeight(){

	return height;

}

int Image::getWidth(){

	return width;

}

void Image::Zero() {
	int i, j;
	for (i=0; i < this->width; i++)
		for (j=0; j < this->height; j++)
			this->data[i][j] = 0;
}


int Image::ReadPNG(char *cpPath)
{
   FILE *fp;
   png_byte header[4];
   png_structp PngPtr;
   png_infop InfoPtr;
   png_uint_32 wWidth, wHeight;
   int iBitDepth, iColorType, iInterlaceType;
   unsigned i,j;


   // Open the file and check that it is a PNG file
   if(!(fp = fopen(cpPath, "rb"))
      || fread(header, 1, 4, fp) != 4
      || png_sig_cmp(header, 0, 4))
      return -1;

   // Read the info header
   if(!(PngPtr = png_create_read_struct(PNG_LIBPNG_VER_STRING,
					 NULL, NULL, NULL))
      || !(InfoPtr = png_create_info_struct(PngPtr)))
   {
      if(PngPtr)
	 png_destroy_read_struct(&PngPtr, png_infopp_NULL, png_infopp_NULL);

      fclose(fp);
      return -1;
   }

   if(setjmp(png_jmpbuf(PngPtr)))
   {
      png_destroy_read_struct(&PngPtr, &InfoPtr, png_infopp_NULL);
      fclose(fp);
      return -1;
   }

   png_init_io(PngPtr, fp);
   png_set_sig_bytes(PngPtr, 4);
   png_read_info(PngPtr, InfoPtr);
   png_get_IHDR(PngPtr, InfoPtr, &wWidth, &wHeight, &iBitDepth, &iColorType,
		&iInterlaceType, int_p_NULL, int_p_NULL);
   
   // Set reading to convert to 8-bit grayscale, ignoring alpha   
   png_set_strip_16(PngPtr);
   png_set_strip_alpha(PngPtr);

   if(iColorType == PNG_COLOR_TYPE_RGB
      || iColorType == PNG_COLOR_TYPE_RGB_ALPHA)
      png_set_rgb_to_gray_fixed(PngPtr, 1, 21268, 71514);
   
   if(iColorType == PNG_COLOR_TYPE_GRAY && iBitDepth < 8)
      png_set_gray_1_2_4_to_8(PngPtr);

   png_set_interlace_handling(PngPtr);
   png_read_update_info(PngPtr, InfoPtr);
   
   // Allocate image memory and read the image
   png_bytep RowPtrs[wHeight];

   for (j = 0; j < wHeight; j++)
      RowPtrs[j] = new png_byte[png_get_rowbytes(PngPtr, InfoPtr)];

   png_read_image(PngPtr, RowPtrs);
   
   // Done reading the file
   png_destroy_read_struct(&PngPtr, &InfoPtr, png_infopp_NULL);
   fclose(fp);
   
   // Convert the image byte data to double data
   SetImageSize(wWidth, wHeight);
   
   for(j = 0; j < wHeight; j++)
      for(i = 0; i < wWidth; i++)
      	//m_dpData[j + i*m_wHeight] = ((double)RowPtrs[j][i])/255.0;
		this->data[i][j] = ((double)RowPtrs[j][i]);

   // Free the byte data
   for (j = 0; j < wHeight; j++)
      delete [] RowPtrs[j];
   
   return 0;
}


int Image::WritePNG(char *cpPath)
{
   FILE *fp;
   
   int m_wWidth = this->width;  // set to class width, height
   int m_wHeight = this->height;
   
   png_structp PngPtr;
   png_infop InfoPtr;
   png_bytep RowPtrs[m_wHeight];
   double dValue;
   unsigned i,j;
   png_byte image[m_wHeight*m_wWidth];
   png_byte *bypPos = image - 1;
   png_byte byValue;
   
   // Open the file
   if(!(fp = fopen(cpPath, "wb")))
      return -1;
     
   if(!(PngPtr = png_create_write_struct(PNG_LIBPNG_VER_STRING,
					  NULL, NULL, NULL))
      || !(InfoPtr = png_create_info_struct(PngPtr)))
   {
      fclose(fp);

      if(PngPtr)
	 png_destroy_write_struct(&PngPtr,  png_infopp_NULL);
      
      return -1;
   }
      
   if (setjmp(png_jmpbuf(PngPtr)))
   {
      fclose(fp);
      png_destroy_write_struct(&PngPtr, &InfoPtr);
      return -1;
   }

   // Configure output for 8-bit RGB color data
   png_init_io(PngPtr, fp);
   png_set_IHDR(PngPtr, InfoPtr, m_wWidth, m_wHeight, 8, PNG_COLOR_TYPE_GRAY,
		PNG_INTERLACE_NONE, PNG_COMPRESSION_TYPE_BASE,
		PNG_FILTER_TYPE_BASE);
   png_write_info(PngPtr, InfoPtr);      

   for(j = 0; j < m_wHeight; j++)
      for(i = 0; i < m_wWidth; i++)
      {
	 	dValue = this->data[i][j]/255.0;
	 
	    byValue = (dValue > 1.0)?255:(
	       (dValue < 0.0)?0:(png_byte)(dValue*255.0) );

	    // output a grayscale pixel
	    *(++bypPos) = byValue;
	    //*(++bypPos) = byValue;
	    //*(++bypPos) = byValue;
      }
   
   for(j = 0; j < m_wHeight; j++)
      RowPtrs[j] = image + j*m_wWidth;

   // Write the file
   png_write_image(PngPtr, RowPtrs);
   png_write_end(PngPtr, InfoPtr);
   fclose(fp);

   return 0;
}





int Image::WriteUnsignedRaw(char *cpPath)
{
   FILE *fp;
   
   int m_wWidth = this->width;  // set to class width, height
   int m_wHeight = this->height;
   
   png_structp PngPtr;
   png_infop InfoPtr;
   png_bytep RowPtrs[m_wHeight];
   double dValue;
   unsigned i,j;
   png_byte image[m_wHeight*m_wWidth];
   png_byte *bypPos = image - 1;
   png_byte byValue;
   
   // Open the file
   if(!(fp = fopen(cpPath, "wb")))
      return -1;
     
   if(!(PngPtr = png_create_write_struct(PNG_LIBPNG_VER_STRING,
					  NULL, NULL, NULL))
      || !(InfoPtr = png_create_info_struct(PngPtr)))
   {
      fclose(fp);

      if(PngPtr)
	 png_destroy_write_struct(&PngPtr,  png_infopp_NULL);
      
      return -1;
   }
      
   if (setjmp(png_jmpbuf(PngPtr)))
   {
      fclose(fp);
      png_destroy_write_struct(&PngPtr, &InfoPtr);
      return -1;
   }

   // Configure output for 8-bit RGB color data
   png_init_io(PngPtr, fp);
   png_set_IHDR(PngPtr, InfoPtr, m_wWidth, m_wHeight, 8, PNG_COLOR_TYPE_GRAY,
		PNG_INTERLACE_NONE, PNG_COMPRESSION_TYPE_BASE,
		PNG_FILTER_TYPE_BASE);
   png_write_info(PngPtr, InfoPtr);      

   for(j = 0; j < m_wHeight; j++)
      for(i = 0; i < m_wWidth; i++)
      {
	 	dValue = this->data[i][j];
	 
	    //byValue = (dValue > 1.0)?255:(
	    //   (dValue < 0.0)?0:(png_byte)(dValue*255.0) );

	    // output a grayscale pixel
	    *(++bypPos) = (unsigned char) dValue;
	    //*(++bypPos) = byValue;
	    //*(++bypPos) = byValue;
      }
   
   for(j = 0; j < m_wHeight; j++)
      RowPtrs[j] = image + j*m_wWidth;

   // Write the file
   png_write_image(PngPtr, RowPtrs);
   png_write_end(PngPtr, InfoPtr);
   fclose(fp);

   return 0;
}

int Image::WriteSignedRaw(char *cpPath)
{
   FILE *fp;
   
   int m_wWidth = this->width;  // set to class width, height
   int m_wHeight = this->height;
   
   png_structp PngPtr;
   png_infop InfoPtr;
   png_bytep RowPtrs[m_wHeight];
   double dValue;
   unsigned i,j;
   png_byte image[m_wHeight*m_wWidth];
   png_byte *bypPos = image - 1;
   png_byte byValue;
   
   // Open the file
   if(!(fp = fopen(cpPath, "wb")))
      return -1;
     
   if(!(PngPtr = png_create_write_struct(PNG_LIBPNG_VER_STRING,
					  NULL, NULL, NULL))
      || !(InfoPtr = png_create_info_struct(PngPtr)))
   {
      fclose(fp);

      if(PngPtr)
	 png_destroy_write_struct(&PngPtr,  png_infopp_NULL);
      
      return -1;
   }
      
   if (setjmp(png_jmpbuf(PngPtr)))
   {
      fclose(fp);
      png_destroy_write_struct(&PngPtr, &InfoPtr);
      return -1;
   }

   // Configure output for 8-bit RGB color data
   png_init_io(PngPtr, fp);
   png_set_IHDR(PngPtr, InfoPtr, m_wWidth, m_wHeight, 8, PNG_COLOR_TYPE_GRAY,
		PNG_INTERLACE_NONE, PNG_COMPRESSION_TYPE_BASE,
		PNG_FILTER_TYPE_BASE);
   png_write_info(PngPtr, InfoPtr);      

   for(j = 0; j < m_wHeight; j++)
      for(i = 0; i < m_wWidth; i++)
      {
	 	dValue = this->data[i][j];
	 
	    //byValue = (dValue > 1.0)?255:(
	    //   (dValue < 0.0)?0:(png_byte)(dValue*255.0) );

	    // output a grayscale pixel
	    *(++bypPos) = (unsigned char) (dValue/2)+128;
	    //*(++bypPos) = byValue;
	    //*(++bypPos) = byValue;
      }
   
   for(j = 0; j < m_wHeight; j++)
      RowPtrs[j] = image + j*m_wWidth;

   // Write the file
   png_write_image(PngPtr, RowPtrs);
   png_write_end(PngPtr, InfoPtr);
   fclose(fp);

   return 0;
}
