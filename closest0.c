/****************************************************************/
/*               Program closest0                               */
/*          computes closest 0 to the origin of the image       */
/* Syntax:                                                      */
/*        closest0 if=infile      [-v][-o]                      */
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
int        x,y,z;               /* index counters                 */
int        xx,yy,zz;            /* window index counters          */
    VXparse(&argc, &argv, par); /* parse the command line         */

    Vfread( &im, IVAL);        /* read image                  */
    if(VFLAG){
       fprintf(stderr,"bbx is %f %f %f %f\n", im.bbx[0],
                 im.bbx[1],im.bbx[2],im.bbx[3]);
    }

int range=0;
int found=0;
float distance;
int originx=(im.xlo+im.xhi)/2;
int originy=(im.ylo+im.yhi)/2;
//  printf("originx+range is %i, originy+range is %i,im.xhi is %i, im.yhi is %i \n",originx+range,originy+range, im.xhi,im.yhi );
while (found==0||((originx+range)>im.xhi)||((originy+range)>im.yhi)){
  for(y=originy-range;y<=originy+range;y++){
    if(im.u[y][originx-range]==0){found=1;distance=sqrt(pow(y,2)+pow(originx-range,2));}
    if(im.u[y][originx+range]==0){found=1;distance=sqrt(pow(y,2)+pow(originx+range,2));}
  }
  for(x=originx-range;x<=originx+range;x++){
    if(im.u[originy-range][x]==0){found=1;distance=sqrt(pow(originy-range,2)+pow(x,2));}
    if(im.u[originy+range][x]==0){found=1;distance=sqrt(pow(originy+range,2)+pow(x,2));}
  }
  range++;
}
range=range-1;

printf("kernellength=%i\n",range );
   exit(0);

}
