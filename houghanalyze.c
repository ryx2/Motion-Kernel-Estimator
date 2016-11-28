/****************************************************************/
/*               Program houghanalyze                           */
/*          computes peaks for the Hough transform iamge        */
/* Syntax:                                                      */
/*        houghanalyze if=infile      [-v][-o]                  */
/****************************************************************/

#include "VisXV4.h"          /* VisionX structure include file       */
#include "Vutil.h"           /* VisionX utility header files         */

VXparam_t par[] =            /* command line structure               */
{
{    "if=",    0,   " input file"},
{    "of=",    0,   " output file "},
{    "-v",     0,   " visible flag"},
{    "-p",     0,   " print other max thetas"},
{     0,       0,    0}
};
#define  IVAL   par[0].val
#define  OVAL   par[1].val
#define  VFLAG  par[2].val
#define  OTHER  par[3].val

int
main(argc, argv)
int argc;
char *argv[];
{
Vfstruct (im);
Vfstruct (om);
int        x,y,z;               /* index counters                 */
int        xx,yy,zz;            /* window index counters          */
    VXparse(&argc, &argv, par); /* parse the command line         */

    Vfread( &im, IVAL);        /* read image                  */
   
    Vfembed(&om, &im,1,1,1,1); /* temp image copy with border */
    if(VFLAG){
       fprintf(stderr,"bbx is %f %f %f %f\n", im.bbx[0],
                 im.bbx[1],im.bbx[2],im.bbx[3]);
    }

int numbermaxs=20;
int currentmax;
int maxangle;
float maxs[numbermaxs];
float sortcopy[numbermaxs];
memset(maxs,0,numbermaxs*sizeof(float));
memset(sortcopy,0,numbermaxs*sizeof(float));
int c=1; // maxcounter

for (y = im.ylo; y <= im.yhi; y++){ //first take a 3x3 avg of all the pixels to reduce noise
  for (x=im.xlo; x <= im.xhi; x++){
    im.u[y][x]=(om.u[y][x]+om.u[y+1][x]+om.u[y-1][x]+om.u[y][x+1]+om.u[y][x-1]+om.u[y+1][x+1]+om.u[y+1][x-1]+om.u[y-1][x-1]+om.u[y-1][x+1])/9;
  }
}
for (c=0; c<=numbermaxs; c++){ // find some max's
  currentmax=0; maxangle=0;
      for (y = im.ylo; y <= im.yhi; y++) {
        for (x = im.xlo; x <= (im.xhi-im.xlo)*0.9+im.xlo; x++) {
          if(im.u[y][x]>currentmax){
            currentmax=im.u[y][x];
            maxangle=y;
            im.u[y][x]=0;
          }
        }
      }
      maxs[c]=(maxangle-im.ylo)/(float)(im.yhi-im.ylo);
      maxs[c]=maxs[c]*M_PI;
    }
    printf("theta=%f;\n",maxs[0] ); //print out the top max for the bash script
    if(OTHER){
      for (c=1; c<=numbermaxs; c++){
        printf("theta%i=%f;\n",c,maxs[c] );
      }
    }
   exit(0);

}
