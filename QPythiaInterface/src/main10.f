C
C     SAMPLE MAIN FOR Q-PYTHIA.1.0.3.
C     
C...Double precision and integer declarations.
      IMPLICIT DOUBLE PRECISION(A-H, O-Z)
      INTEGER PYK,PYCHGE,PYCOMP
      INTEGER IDUM
      INTEGER MODEL,TAMOD
      integer today(3), now(3)
      real aaa(1)
      CHARACTER*80 CENT         ! centrality for 3D hydro
      CHARACTER*40 FILEINPUT, FILENAME

C...EXTERNAL statement links PYDATA on most machines.
      EXTERNAL PYDATA
      EXTERNAL readdata         ! 3D hydro data routine

C...Commonblocks.
      COMMON/PYJETS/N,NPAD,K(4000,5),P(4000,5),V(4000,5)
      COMMON/PYDAT1/MSTU(200),PARU(200),MSTJ(200),PARJ(200)
      COMMON/PYDAT2/KCHG(500,4),PMAS(500,4),PARF(2000),VCKM(4,4)
      COMMON/PYSUBS/MSEL,MSELPD,MSUB(500),KFIN(2,-40:40),CKIN(200)
      COMMON/PYPARS/MSTP(200),PARP(200),MSTI(200),PARI(200)
      COMMON/MODPAR/QHAT0,BETAX,BETAY,BETAZ,X0,Y0,Z0,TAU0
      COMMON/MODNO/MODEL
      COMMON/FILE/CENT          ! 3D hydro centrality common
      COMMON/NUCL/ANUCL,RA,BPAR,TAMOD
      common/flcoh/iflcoh ! 1.0.3
C
C      NARGS = IARGC()
C      IF(NARGS.NE.2) THEN
C         PRINT*,'NEED TO SPECIFY INPUT AND OUTPUT FILES!!!'
C         STOP
C      END IF
C     LIST OF ARGUMENTS TO BE GIVEN:
C     1: INPUT FILE
C     2: OUTPUT FILE
      FILEINPUT="input"
      FILENAME="output"
      OPEN(60,FILE=FILEINPUT,STATUS='unknown')
      READ(60,*) QHAT0
      READ(60,*) MODEL
      READ(60,*) ANUCL
      READ(60,*) BPAR
      READ(60,*) CENT
      READ(60,*) TAMOD
      READ(60,*) IFLCOH
      READ(60,*) NEV
      PRINT*, 'QHAT0, MODEL, ANUCL, BPAR, CENT, TAMOD, IFLCOH, NEV='
      PRINT*, QHAT0, MODEL, ANUCL, BPAR, CENT, TAMOD, IFLCOH, NEV
      CLOSE(60)
      OPEN(70,FILE=FILENAME,STATUS='unknown')
c

c     qhat0=5.0d0               ! qhat (for Bjorken mod qhat0) in [GeV**2/fm]
c      qhat0=14000.0d0           ! GeV**2 fm**3, qhat for PQM, approximate for <qhat>=1 
c      model=6                   ! type of medium (1: cylinder,2: Bjorken,3,4,5: 3D hydro, 6: PQM)
c
c      anucl=208.d0              ! atomic number
      ra=1.07d0*anucl**0.3333d0 ! nuclear radius
c      bpar=3.1d0                 ! impact parameter of AA collision 
c      cent='0-10'                ! centrality class (for hydro)
      if(model.ge.3 .and. model.le.5) call readdata ! Read and store hydro data table
c      tamod=2                   ! 1: particle prod from center, 2: nuclear overlap 
      call qpyini               ! initialize the jet prod array
c
C...Number of events.
c      NEV=1
c
c   switches (default refers to PYTHIA-6.4.18 defaults).
c
c   MSTJ(47) and MSTJ(50) are fixed this way because we are running a
c   single parton which does not come from any hard scattering.
c
c   MSTJ(41) is fixed this way because we are only interested in QCD radiation.
c
c   MSTJ(41) must NOT be 11 or 12, as then FSR may go through PYPTFS
c   (kt-ordered cascade) in which medium effects have not been introduced.
c
c      MSTJ(41)=1 ! QCD radiation only (default=2)
c      MSTJ(42)=2 ! 2: angular ordering (default), 1: no angular ordering
c      MSTJ(44)=2 ! options to run alphas (default=2)
c      MSTJ(47)=0 ! no correction back to hard scattering element (default=3)
c      MSTJ(50)=0 ! no coherence in first branching (default=3)
c      PARJ(82)=1.D0 ! GeV, cut off for parton showers (default=1 GeV)
c
c     LHA for jet definition
      mstj(22)=2
      parj(71)=3.d0
c     QCD jets, large pt demanded
      MSEL=1
      CKIN(3)=80.d0
c     
c     DW tune, hep-ph/0610012
      MSTP(51)=7 ! CTEQ5L
      MSTP(81)=1 ! multiple interactions on
      MSTP(82)=4 ! varying impact parameter, double gaussian for multiple int.
      PARP(82)=1.9d0 ! regularization of transverse momentum for multiple int.
      PARP(83)=0.5d0 ! parameters of the double gaussian overlap
      PARP(84)=0.4d0 ! parameters of the double gaussian overlap
      PARP(85)=1.0d0 ! probability of additional two gluons in mutiple int.
      PARP(86)=1.d0  ! probability of additional two gluons in mutiple int.
      PARP(89)=1800.d0 ! reference energy scale
      PARP(90)=0.25d0 ! power of energy rescaling of parp(82)
      PARP(62)=1.25d0 ! cut-off for space-like parton showers
      PARP(64)=0.2d0 ! scale for alphas evaluation in space-like parton showers
      PARP(67)=2.5d0 ! scale for maximum virtuality on space-like parton showers
      MSTP(91)=1 ! Gaussian primordial kt distribution in hadron
      PARP(91)=2.1d0 ! width of Gaussian primordial kt
      PARP(93)=15.0d0 ! upper cut-off for primordial kt in the hadron
c
c     to ensure different generations at each time.
      call idate(today)
      call itime(now)
      CALL RLUXGO(4,today(1),0,0)
      call ranlux(aaa,1)
      dx1=dble(aaa(1))
      CALL RLUXGO(4,today(2),0,0)
      call ranlux(aaa,1)
      dx2=dble(aaa(1))
      CALL RLUXGO(4,today(3),0,0)
      call ranlux(aaa,1)
      dx3=dble(aaa(1))
      CALL RLUXGO(4,now(1),0,0)
      call ranlux(aaa,1)
      dx4=dble(aaa(1))
      CALL RLUXGO(4,now(2),0,0)
      call ranlux(aaa,1)
      dx5=dble(aaa(1))
      CALL RLUXGO(4,now(3),0,0)
      call ranlux(aaa,1)
      dx6=dble(aaa(1))
      isss=int(2147483647*(dx1+dx2+dx3+dx4+dx5+dx6)/6.d0)
      CALL RLUXGO(3,isss,0,0)
      print*, 'SEED FOR RANLUX=', ISSS

C************INITIALIZATION *************
      call PYINIT('CMS','p','p',2.76d+3) ! LHC collisions

C...Event loop. List first few events.
      write(70,*) nev
      DO 1 IEV=1,NEV
      call genevent
 1    CONTINUE
c
      CLOSE(70)
c
C...Final statistics and histograms.
c      CALL PYSTAT(1)
c
      STOP
      END

C     Initialization of a nucleus-nucleus collision geometry
      SUBROUTINE QPYINI
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)   
      INTEGER I,J,TAMOD
      EXTERNAL RHOA
      COMMON/NUCL/ANUCL,RA,BPAR,TAMOD
      COMMON/RHO/BB
      COMMON/OVERLAPW/WTAA(100,100),XM,YM
      COMMON/PROFILE/BARR(100),TARR(100)

c     for z-integration of WS densities
      z2=4.d0*ra
      z1=-1.d0*z2

c     creating a regular grid for nuclear overlap
c     NOTE: only a quarter of the overlap is covered
      xmin=0.d0
      xmax=ra-bpar/2.d0
      xm=xmax
      if(xmax.lt.xmin) then
         PRINT*,'Too large impact parameter: b/2>RA!'
c         STOP
      end if
      ymin=0.d0
      ymax=dsqrt(ra**2-bpar**2/4.d0) ! only for b/2 < ra
      ym=ymax
      xdel=(xmax-xmin)/99.d0
      ydel=(ymax-ymin)/99.d0
      
      wtaasum=0.d0
      do i=1,100
         x=xmin+(i-1)*xdel
         do j=1,100
            y=ymin+(j-1)*ydel
            
            r=dsqrt(x**2+y**2)
            if(r.eq.0.d0) then 
               theta=0.d0
            else theta=acos(x/r)
            endif
            
c     distances from centra of the two nuclei
            bb=dsqrt(abs(r*r+bpar*bpar/4.d0+r*bpar*dcos(theta)))
            ta1=dgauss2(rhoa,z1,z2,1.d-4)
            bb=dsqrt(abs(r*r+bpar*bpar/4.d0-r*bpar*dcos(theta)))
            ta2=dgauss2(rhoa,z1,z2,1.d-4)

            wtaa(j,i)=ta1*ta2
            wtaasum=wtaasum+wtaa(j,i)
         end do
      end do

c     normalize the weights
      do i=1,100
         do j=1,100
            wtaa(j,i)=wtaa(j,i)/wtaasum
         end do
      end do

c     profile up to 2*ra
      deltaprof=2.d0*ra/99.d0
      checknprof=0.d0
      do i=1, 100, 1
         bb=dble(i-1)*deltaprof
         barr(i)=bb
         ttarr=dgauss2(rhoa,z1,z2,1.d-4)
         tarr(i)=ttarr
         if (i .gt. 1) checknprof=checknprof+
     >                deltaprof*2.d0*dacos(-1.d0)*barr(i)*tarr(i)
c         print*,bb,tarr(i)
      enddo
      print*, 'normalization of profile=', checknprof
c      
      RETURN
      END
c
      FUNCTION RHOA(Z)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      INTEGER TAMOD
      COMMON/NUCL/ANUCL,RA,BPAR,TAMOD
      COMMON/RHO/BB
      PARAMETER(DF=0.545d0, PI=3.141593d0)
c
      r=dsqrt(bb**2+z**2)
      rho0=3.d0/(4.d0*pi*ra**3)/(1.d0+(pi*df/ra)**2)
      rhoa=rho0/(1.d0+dexp((r-ra)/df))
c
      RETURN
      END
c
      FUNCTION PROFA(XB)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)   
      COMMON/PROFILE/BARR(100),TARR(100)
      PROFA=DDIVDIF(TARR,BARR,100,XB,1)
      RETURN
      END






      SUBROUTINE genevent()
      IMPLICIT DOUBLE PRECISION(A-H, O-Z)
      INTEGER PYK,PYCHGE,PYCOMP
      INTEGER IDUM
      INTEGER MODEL,TAMOD
      integer today(3), now(3)
      real aaa(1)
      CHARACTER*80 CENT         ! centrality for 3D hydro
      CHARACTER*40 FILEINPUT, FILENAME

C...EXTERNAL statement links PYDATA on most machines.
      EXTERNAL PYDATA
      EXTERNAL readdata         ! 3D hydro data routine

C...Commonblocks.
      COMMON/PYJETS/N,NPAD,K(4000,5),P(4000,5),V(4000,5)
      COMMON/PYDAT1/MSTU(200),PARU(200),MSTJ(200),PARJ(200)
      COMMON/PYDAT2/KCHG(500,4),PMAS(500,4),PARF(2000),VCKM(4,4)
      COMMON/PYSUBS/MSEL,MSELPD,MSUB(500),KFIN(2,-40:40),CKIN(200)
      COMMON/PYPARS/MSTP(200),PARP(200),MSTI(200),PARI(200)
      COMMON/MODPAR/QHAT0,BETAX,BETAY,BETAZ,X0,Y0,Z0,TAU0
      COMMON/MODNO/MODEL
      COMMON/FILE/CENT          ! 3D hydro centrality common
      COMMON/NUCL/ANUCL,RA,BPAR,TAMOD
      common/flcoh/iflcoh ! 1.0.3
C

c
         call qpygin0 ! generate initial nucleon-nucleon position.
c
         IF(MOD(IEV,100).eq.0) PRINT*,"Loop # ",IEV
c
         call PYEVNT ! Generate one PYTHIA event.
c    LHA for jet definition
         CALL PYEDIT(1)
c
         IF(IEV.LE.5) CALL PYLIST(1)
c
         WRITE(70,*) IEV, N
         DO 2 Iqq=1, N, 1
c          if(k(iqq,2).ge.111) then      !writes only mesons and baryons
c            WRITE(70,*) K(iqq,2), P(Iqq,1), P(Iqq,2), P(Iqq,3),
c     >                  P(Iqq,4), P(Iqq,5)
c          endif  
 2         CONTINUE
c     
      END SUBROUTINE


      SUBROUTINE INIT
      IMPLICIT DOUBLE PRECISION(A-H, O-Z)
      INTEGER PYK,PYCHGE,PYCOMP
      INTEGER IDUM
      INTEGER MODEL,TAMOD
      integer today(3), now(3)
      real aaa(1)
      CHARACTER*80 CENT         ! centrality for 3D hydro
      CHARACTER*40 FILEINPUT, FILENAME

C...EXTERNAL statement links PYDATA on most machines.
      EXTERNAL PYDATA
      EXTERNAL readdata         ! 3D hydro data routine

C...Commonblocks.
      COMMON/PYJETS/N,NPAD,K(4000,5),P(4000,5),V(4000,5)
      COMMON/PYDAT1/MSTU(200),PARU(200),MSTJ(200),PARJ(200)
      COMMON/PYDAT2/KCHG(500,4),PMAS(500,4),PARF(2000),VCKM(4,4)
      COMMON/PYSUBS/MSEL,MSELPD,MSUB(500),KFIN(2,-40:40),CKIN(200)
      COMMON/PYPARS/MSTP(200),PARP(200),MSTI(200),PARI(200)
      COMMON/MODPAR/QHAT0,BETAX,BETAY,BETAZ,X0,Y0,Z0,TAU0
      COMMON/MODNO/MODEL
      COMMON/FILE/CENT          ! 3D hydro centrality common
      COMMON/NUCL/ANUCL,RA,BPAR,TAMOD
      common/flcoh/iflcoh ! 1.0.3
C
      FILEINPUT="input"
      FILENAME="output"
C     LIST OF ARGUMENTS TO BE GIVEN:
C     1: INPUT FILE
C     2: OUTPUT FILE
      CALL GETARG(1,FILEINPUT)
      CALL GETARG(2,FILENAME)
      OPEN(60,FILE="input",STATUS='unknown')
      READ(60,*) QHAT0
      READ(60,*) MODEL
      READ(60,*) ANUCL
      READ(60,*) BPAR
      READ(60,*) CENT
      READ(60,*) TAMOD
      READ(60,*) IFLCOH
      READ(60,*) NEV
      PRINT*, 'QHAT0, MODEL, ANUCL, BPAR, CENT, TAMOD, IFLCOH, NEV='
      PRINT*, QHAT0, MODEL, ANUCL, BPAR, CENT, TAMOD, IFLCOH, NEV
      CLOSE(60)
      OPEN(70,FILE="output",STATUS='unknown')
c

c     qhat0=5.0d0               ! qhat (for Bjorken mod qhat0) in [GeV**2/fm]
c      qhat0=14000.0d0           ! GeV**2 fm**3, qhat for PQM, approximate for <qhat>=1 
c      model=6                   ! type of medium (1: cylinder,2: Bjorken,3,4,5: 3D hydro, 6: PQM)
c
c      anucl=208.d0              ! atomic number
      ra=1.07d0*anucl**0.3333d0 ! nuclear radius
c      bpar=3.1d0                 ! impact parameter of AA collision 
c      cent='0-10'                ! centrality class (for hydro)
      if(model.ge.3 .and. model.le.5) call readdata ! Read and store hydro data table
c      tamod=2                   ! 1: particle prod from center, 2: nuclear overlap 
      call qpyini               ! initialize the jet prod array
c
C...Number of events.
c      NEV=1
c
c   switches (default refers to PYTHIA-6.4.18 defaults).
c
c   MSTJ(47) and MSTJ(50) are fixed this way because we are running a
c   single parton which does not come from any hard scattering.
c
c   MSTJ(41) is fixed this way because we are only interested in QCD radiation.
c
c   MSTJ(41) must NOT be 11 or 12, as then FSR may go through PYPTFS
c   (kt-ordered cascade) in which medium effects have not been introduced.
c
c      MSTJ(41)=1 ! QCD radiation only (default=2)
c      MSTJ(42)=2 ! 2: angular ordering (default), 1: no angular ordering
c      MSTJ(44)=2 ! options to run alphas (default=2)
c      MSTJ(47)=0 ! no correction back to hard scattering element (default=3)
c      MSTJ(50)=0 ! no coherence in first branching (default=3)
c      PARJ(82)=1.D0 ! GeV, cut off for parton showers (default=1 GeV)
c
c     LHA for jet definition
      mstj(22)=2
      parj(71)=3.d0
c     QCD jets, large pt demanded
      MSEL=1
      CKIN(3)=80.d0
c     
c     DW tune, hep-ph/0610012
      MSTP(51)=7 ! CTEQ5L
      MSTP(81)=1 ! multiple interactions on
      MSTP(82)=4 ! varying impact parameter, double gaussian for multiple int.
      PARP(82)=1.9d0 ! regularization of transverse momentum for multiple int.
      PARP(83)=0.5d0 ! parameters of the double gaussian overlap
      PARP(84)=0.4d0 ! parameters of the double gaussian overlap
      PARP(85)=1.0d0 ! probability of additional two gluons in mutiple int.
      PARP(86)=1.d0  ! probability of additional two gluons in mutiple int.
      PARP(89)=1800.d0 ! reference energy scale
      PARP(90)=0.25d0 ! power of energy rescaling of parp(82)
      PARP(62)=1.25d0 ! cut-off for space-like parton showers
      PARP(64)=0.2d0 ! scale for alphas evaluation in space-like parton showers
      PARP(67)=2.5d0 ! scale for maximum virtuality on space-like parton showers
      MSTP(91)=1 ! Gaussian primordial kt distribution in hadron
      PARP(91)=2.1d0 ! width of Gaussian primordial kt
      PARP(93)=15.0d0 ! upper cut-off for primordial kt in the hadron
c
c     to ensure different generations at each time.
      call idate(today)
      call itime(now)
      CALL RLUXGO(4,today(1),0,0)
      call ranlux(aaa,1)
      dx1=dble(aaa(1))
      CALL RLUXGO(4,today(2),0,0)
      call ranlux(aaa,1)
      dx2=dble(aaa(1))
      CALL RLUXGO(4,today(3),0,0)
      call ranlux(aaa,1)
      dx3=dble(aaa(1))
      CALL RLUXGO(4,now(1),0,0)
      call ranlux(aaa,1)
      dx4=dble(aaa(1))
      CALL RLUXGO(4,now(2),0,0)
      call ranlux(aaa,1)
      dx5=dble(aaa(1))
      CALL RLUXGO(4,now(3),0,0)
      call ranlux(aaa,1)
      dx6=dble(aaa(1))
      isss=int(2147483647*(dx1+dx2+dx3+dx4+dx5+dx6)/6.d0)
      CALL RLUXGO(3,isss,0,0)
      print*, 'SEED FOR RANLUX=', ISSS

C************INITIALIZATION *************
      call PYINIT('CMS','p','p',2.76d+3) ! LHC collisions
      END SUBROUTINE
