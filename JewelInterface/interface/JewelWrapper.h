#ifndef GeneratorInterface_JewelInterface_JewelWrapper
#define GeneratorInterface_JewelInterface_JewelWrapper

/*
 * Wrapper for FORTRAN version of JEWEL
 */

#define _MAXNUMPARTICLE_ 130000

extern "C" {
  double getcentrality_();
}
#define GETCENTRALITY getcentrality_

extern "C" {
  void init_();
}
#define INIT init_

extern "C" {
  void genevent_(int j);
}
#define GENEVENT genevent_

/*
extern "C" {
  extern struct{ 
    int natt;
    int eatt;
    int jatt;
    int nt;
    int np;
    int n0;
    int n01;
    int n10;
    int n11;
  }himain1_;
}
#define himain1 himain1_
*/


extern "C" {
  extern struct{ 
     int katt[4][_MAXNUMPARTICLE_];
     float patt[4][_MAXNUMPARTICLE_];
     float vatt[4][_MAXNUMPARTICLE_];
  }himain2_;
}
#define himain2 himain2_

extern "C" {
  extern struct{ 
    float  hipr1[100];
    int    ihpr2[50];
    float  hint1[100];
    int    ihnt2[50];
  }hiparnt_;
}
#define hiparnt hiparnt_




#endif
