c###################################################################
c This is a sample program to call local thermodynamic variables
c and hydrodynamic flow velocity in Pb+Pb collisions at LHC from 
c full 3D ideal hydrodynamic simulations.
c
c In analysis of parton energy loss, J/psi suppression,
c heavy quark diffusion, and so on, a realistic space-time
c evolution of the matter created in collisions is needed.
c Here we are very happy to offer our hydrodynamic results
c to the community for these purposes.
c
c If you use these data for your publication, 
c you have to REFER TO the our papers mentioned below.
c If you have any questions and comments, you can contact to
c
c    hirano@sophia.ac.jp
c
c or
c
c    nara@aiu.co.jp
c
c
c##################################################################

         subroutine readdata

         implicit none
         double precision enedat,tdat,fdat,vxdat,vydat,yfdat
         double precision tau0,deltat,deltax,deltay,deltah
         integer maxt,maxx,maxy,maxh,it,ix,iy,ih
         
         double precision tau,x,y,eta,ene,t,f,vxx,vyy,yf
         double precision dummy1,dummy2,dummy3,dummy4
         integer leng

c...Mesh size of numerical data   
c         parameter(maxt=60,maxx=80,maxy=40,maxh=20)
         parameter(maxt=100,maxx=120,maxy=60,maxh=20)

         character*80 cent
         common/file/cent

         common/hydro1/ene(0:maxt,0:maxx,0:maxy,0:maxh)
         common/hydro2/t(0:maxt,0:maxx,0:maxy,0:maxh)
         common/hydro3/f(0:maxt,0:maxx,0:maxy,0:maxh)
         common/hydro4/vxx(0:maxt,0:maxx,0:maxy,0:maxh)
         common/hydro5/vyy(0:maxt,0:maxx,0:maxy,0:maxh)
         common/hydro6/yf(0:maxt,0:maxx,0:maxy,0:maxh)

         leng = index(cent,' ')-1

         open(unit=20,file='PbPb2760_'//cent(1:leng)//'.dat',
     &                                          status='old')

         tau0 = 0.6d0
         deltat = 0.3d0
         deltax = 0.3d0
         deltay = 0.3d0
         deltah = 0.3d0

         do 11 it=0,maxt
           do 21 ih=0,maxh
              do 31 iy=0,maxy
                 do 41 ix=0,maxx
                    ene(it,ix,iy,ih)= 0d0
                    t(it,ix,iy,ih) = 0d0
                    f(it,ix,iy,ih) = 0d0
                    vxx(it,ix,iy,ih) = 0d0
                    vyy(it,ix,iy,ih) = 0d0
                    yf(it,ix,iy,ih) = 0d0
 41              continue
 31           continue
 21        continue
 11     continue



        do 100

           read(20,*)tau,x,y,eta,enedat,tdat,fdat,vxdat,vydat,yfdat

           if (tau .lt. 0d0)then
              exit
           endif

c...Here we dare not to call getGridPoint
           it = int((tau+deltat/2-tau0)/deltat)
           ix = int((x+deltax*maxx/2.0+deltax/2.0)/deltax)
           iy = int((y+deltay/2)/deltay)
           ih = int((eta+deltah/2)/deltah)


           ene(it,ix,iy,ih)= enedat
           t(it,ix,iy,ih) = tdat
           f(it,ix,iy,ih) = fdat
           vxx(it,ix,iy,ih) = vxdat
           vyy(it,ix,iy,ih) = vydat
           yf(it,ix,iy,ih) = yfdat

 100    end do
         
        close (unit=20,status='keep')
         
        return
        
        end

c#############################################################

      subroutine getInitialPosition(b,tau0,x0,y0,eta0)

      implicit none
      double precision b,tau0,x0,y0,eta0
      double precision xmin,xmax,ymin,ymax,taa,taamax,d,ran2
      double precision getTAA
      integer is

      is = 7927

      eta0 = 0d0

      x0 = 0d0
      y0 = 0d0
      taamax = getTAA(x0,y0,b)

      xmin = -10d0
      xmax = 10d0
      ymin = -10d0
      ymax = 10d0

 100  x0 = ran2(is)*(xmax-xmin)+xmin
      y0 = ran2(is)*(ymax-ymin)+ymin

      taa = getTAA(x0,y0,b)
      
      d = ran2(is)

      if(d .gt. taa/taamax)then
         goto 100
      endif

      return
      end

c#############################################################

      subroutine getInitialMomentum(p0,phi0)

      implicit none
      double precision pi,ran2,sctr
      double precision p0,phi0,p0ini,p0fin,b,n,dndpt,dndptmax,d
      integer is

      is = 7927
      pi = 3.1415926d0
      sctr = 197.32d0

      phi0 = ran2(is)*2d0*pi

      p0ini = 2d0/sctr*1d3
      p0fin = 10d0/sctr*1d3

      b = 1.75d0
      n = 8d0
      dndptmax = 1.0/(p0ini+b)**n

 100  p0 = (p0fin-p0ini)*ran2(is)+p0ini

      dndpt = 1.0/(p0+b)**n

      d = ran2(is)

      if(d .gt. dndpt/dndptmax)then
         goto 100
      endif

      return

      end

c#############################################################

      double precision function getDensity(x,y,z)

      implicit none
      double precision x,y,z
      double precision mass,rad,dr,density0,r

      mass = 197d0 
      rad = 1.12d0*mass**(1d0/3d0)-0.86d0*mass**(-1d0/3d0)
      dr = 0.54d0
      density0 = 0.17d0

      r = sqrt(x*x+y*y+z*z)
      getDensity = density0/(1.0+exp((r-rad)/dr))

      return

      end
c#############################################################

      double precision function getTAA(x,y,b)

      implicit none
      double precision x,y,b
      double precision zmin,zmax,x1,x2,density1,density2
      double precision ta1,ta2
      double precision z(38),zw(38)
      double precision getDensity
      integer iz

      ta1 = 0d0
      ta2 = 0d0
      getTAA = 0d0
         
      zmin = -10.0d0
      zmax =  10.0d0

      call gauss38(zmin,zmax,z,zw)

      do 10 iz = 1,38 

         x1 = x-b/2d0
         x2 = x+b/2d0
         density1 = getDensity(x1,y,z(iz))
         density2 = getDensity(x2,y,z(iz))

         ta1 = ta1 + density1*zw(iz)
         ta2 = ta2 + density2*zw(iz)

 10   continue

      getTAA = ta1*ta2

      return

      end

c############################################################

      subroutine getGridPoint(tau,x,y,eta,
     &     dt,dx,dy,dh,it,ix,iy,ih)

      implicit none
      double precision tau,x,y,eta
      double precision tau0
      double precision dt,dx,dy,dh
      double precision deltat,deltax,deltay,deltah
      integer maxt,maxx,maxy,maxh,it,ix,iy,ih
c...Mesh size of numerical data   
c      parameter(maxt=60,maxx=80,maxy=40,maxh=20)
         parameter(maxt=100,maxx=120,maxy=60,maxh=20)

c...initial and final time of partonic phase
         tau0 = 0.6d0

c...time step of simulation and mesh size of a fluid element
         deltat=0.3d0 
         deltax=0.3d0
         deltay=0.3d0
         deltah=0.3d0

         it = int((tau-tau0)/deltat)
         dt = (tau - tau0-dble(it)*deltat)/deltat

         if(y .ge. 0d0)then
            iy = int(y/deltay)
            dy = (y - dble(iy)*deltay)/deltay
         else
            iy = int(-y/deltay)
            dy = (-y - dble(iy)*deltay)/deltay
         endif

         if (eta .ge. 0d0)then 
           if(x .ge. 0d0)then
            ix = int(x/deltax)+maxx/2
            dx = (x - dble(ix-maxx/2)*deltax)/deltax
           else
            ix = int(x/deltax)+maxx/2-1
            dx = (x - dble(ix-maxx/2)*deltax)/deltax
           endif
            ih = int(eta/deltah)
            dh = (eta - dble(ih)*deltah)/deltah
         else
           if(-x .ge. 0d0)then
            ix = int(-x/deltax)+maxx/2
            dx = (-x - dble(ix-maxx/2)*deltax)/deltax
           else
            ix = int(-x/deltax)+maxx/2-1
            dx = (-x - dble(ix-maxx/2)*deltax)/deltax
           endif
            ih = int(-eta/deltah)
            dh = (-eta-int(-eta/deltah)*deltah)/deltah
         endif

c         if((dx .lt. 0.0) .or. (dy .lt. 0.0) .or. (dh .lt. 0.0)
c     &        .or. (dt .lt. 0.0)) then
c            print *,dx,dy,dh,dt
c            stop
c         endif

         return

         end

c############################################################
         double precision function getene(tau,x,y,eta)
         implicit none
         double precision tau,x,y,eta
         double precision tau0,tau1
         double precision dt,dx,dy,dh
         integer maxt,maxx,maxy,maxh,it,ix,iy,ih

c...Mesh size of numerical data   
c         parameter(maxt=60,maxx=80,maxy=40,maxh=20)
         parameter(maxt=100,maxx=120,maxy=60,maxh=20)

         double precision ene
         common/hydro1/ene(0:maxt,0:maxx,0:maxy,0:maxh)

c...initial and final time of partonic phase
         tau0 = 0.6d0
         tau1 = 24.6d0     

c...initialize
         getene=0d0

c...Check tau
         if (tau .lt. tau0)then
           write(6,*)'Still before thermalization (tau<0.6fm/c)'
           return
         else if (tau .gt. tau1)then
           write(6,*)'No data (tau > ',tau1,' fm/c)'
           return
         endif

         call getGridPoint(tau,x,y,eta,dt,dx,dy,dh,
     &                                 it,ix,iy,ih)

         if((ix .le. 0).or.(ix .ge. maxx)
     &        .or.(iy.ge.maxy).or.(ih.ge.maxh))then
            return
         endif

c...Interpolate in 4D
            getene=ene(it,ix,iy,ih)
     &           *(1d0-dt)*(1d0-dx)*(1d0-dy)*(1d0-dh)
            getene=getene+
     &           ene(it+1,ix,iy,ih)*dt*(1d0-dx)*(1d0-dy)*(1d0-dh)
            getene=getene+
     &           ene(it,ix+1,iy,ih)*(1d0-dt)*dx*(1d0-dy)*(1d0-dh)
            getene=getene+
     &           ene(it,ix,iy+1,ih)*(1d0-dt)*(1d0-dx)*dy*(1d0-dh)
            getene=getene+
     &           ene(it,ix,iy,ih+1)*(1d0-dt)*(1d0-dx)*(1d0-dy)*dh
            getene=getene+
     &           ene(it+1,ix+1,iy,ih)*dt*dx*(1d0-dy)*(1d0-dh)
            getene=getene+
     &           ene(it+1,ix,iy+1,ih)*dt*(1d0-dx)*dy*(1d0-dh)
            getene=getene+
     &           ene(it+1,ix,iy,ih+1)*dt*(1d0-dx)*(1d0-dy)*dh
            getene=getene+
     &           ene(it,ix+1,iy+1,ih)*(1d0-dt)*dx*dy*(1d0-dh)
            getene=getene+
     &           ene(it,ix+1,iy,ih+1)*(1d0-dt)*dx*(1d0-dy)*dh
            getene=getene+
     &           ene(it,ix,iy+1,ih+1)*(1d0-dt)*(1d0-dx)*dy*dh
            getene=getene+
     &           ene(it,ix+1,iy+1,ih+1)*(1d0-dt)*dx*dy*dh
            getene=getene+
     &           ene(it+1,ix,iy+1,ih+1)*dt*(1d0-dx)*dy*dh
            getene=getene+
     &           ene(it+1,ix+1,iy,ih+1)*dt*dx*(1d0-dy)*dh
            getene=getene+
     &           ene(it+1,ix+1,iy+1,ih)*dt*dx*dy*(1d0-dh)
            getene=getene+
     &           ene(it+1,ix+1,iy+1,ih+1)*dt*dx*dy*dh


         return
         
         end
c############################################################

         double precision function gettemp(tau,x,y,eta)
         implicit none

         double precision tau,x,y,eta
         double precision tau0,tau1
         double precision dt,dx,dy,dh

         integer maxt,maxx,maxy,maxh,it,ix,iy,ih

c...Mesh size of numerical data   
c         parameter(maxt=60,maxx=80,maxy=40,maxh=20)
         parameter(maxt=100,maxx=120,maxy=60,maxh=20)

         double precision t
         common/hydro2/t(0:maxt,0:maxx,0:maxy,0:maxh)


c...initial and final time of partonic phase
         tau0 = 0.6d0
         tau1 = 24.6d0
c...initialize
         gettemp=0d0

c...Check tau
         if (tau .lt. tau0)then
           write(6,*)'Still before thermalization (tau<0.6fm/c)'
           return
         else if (tau .gt. tau1)then
           write(6,*)'No data (tau > ',tau1,' fm/c)'
           return
         endif

         call getGridPoint(tau,x,y,eta,dt,dx,dy,dh,
     &                                 it,ix,iy,ih)

         if((ix .le. 0).or.(ix .ge. maxx)
     &        .or.(iy.ge.maxy).or.(ih.ge.maxh))then
            return
         endif

c...Interpolate in 4D
            gettemp=t(it,ix,iy,ih)
     &           *(1d0-dt)*(1d0-dx)*(1d0-dy)*(1d0-dh)
            gettemp=gettemp+
     &           t(it+1,ix,iy,ih)*dt*(1d0-dx)*(1d0-dy)*(1d0-dh)
            gettemp=gettemp+
     &           t(it,ix+1,iy,ih)*(1d0-dt)*dx*(1d0-dy)*(1d0-dh)
            gettemp=gettemp+
     &           t(it,ix,iy+1,ih)*(1d0-dt)*(1d0-dx)*dy*(1d0-dh)
            gettemp=gettemp+
     &           t(it,ix,iy,ih+1)*(1d0-dt)*(1d0-dx)*(1d0-dy)*dh
            gettemp=gettemp+
     &           t(it+1,ix+1,iy,ih)*dt*dx*(1d0-dy)*(1d0-dh)
            gettemp=gettemp+
     &           t(it+1,ix,iy+1,ih)*dt*(1d0-dx)*dy*(1d0-dh)
            gettemp=gettemp+
     &           t(it+1,ix,iy,ih+1)*dt*(1d0-dx)*(1d0-dy)*dh
            gettemp=gettemp+
     &           t(it,ix+1,iy+1,ih)*(1d0-dt)*dx*dy*(1d0-dh)
            gettemp=gettemp+
     &           t(it,ix+1,iy,ih+1)*(1d0-dt)*dx*(1d0-dy)*dh
            gettemp=gettemp+
     &           t(it,ix,iy+1,ih+1)*(1d0-dt)*(1d0-dx)*dy*dh
            gettemp=gettemp+
     &           t(it,ix+1,iy+1,ih+1)*(1d0-dt)*dx*dy*dh
            gettemp=gettemp+
     &           t(it+1,ix,iy+1,ih+1)*dt*(1d0-dx)*dy*dh
            gettemp=gettemp+
     &           t(it+1,ix+1,iy,ih+1)*dt*dx*(1d0-dy)*dh
            gettemp=gettemp+
     &           t(it+1,ix+1,iy+1,ih)*dt*dx*dy*(1d0-dh)
            gettemp=gettemp+
     &           t(it+1,ix+1,iy+1,ih+1)*dt*dx*dy*dh

         return

         end
c############################################################

         double precision function getfrac(tau,x,y,eta)
         implicit none

         double precision tau,x,y,eta
         double precision tau0,tau1
         double precision dt,dx,dy,dh

         integer maxt,maxx,maxy,maxh,it,ix,iy,ih

c...Mesh size of numerical data   
c         parameter(maxt=60,maxx=80,maxy=40,maxh=20)
         parameter(maxt=100,maxx=120,maxy=60,maxh=20)

         double precision f
         common/hydro3/f(0:maxt,0:maxx,0:maxy,0:maxh)


c...initial and final time of partonic phase
         tau0 = 0.6d0
         tau1 = 24.6d0
c...initialize
         getfrac=0d0

c...Check tau
         if (tau .lt. tau0)then
           write(6,*)'Still before thermalization (tau<0.6fm/c)'
           return
         else if (tau .gt. tau1)then
           write(6,*)'No data (tau > ',tau1,' fm/c)'
           return
         endif

         call getGridPoint(tau,x,y,eta,dt,dx,dy,dh,
     &                                 it,ix,iy,ih)

         if((ix .le. 0).or.(ix .ge. maxx)
     &        .or.(iy.ge.maxy).or.(ih.ge.maxh))then
            return
         endif

c...Interpolate in 4D
            getfrac=f(it,ix,iy,ih)
     &           *(1d0-dt)*(1d0-dx)*(1d0-dy)*(1d0-dh)
            getfrac=getfrac+
     &           f(it+1,ix,iy,ih)*dt*(1d0-dx)*(1d0-dy)*(1d0-dh)
            getfrac=getfrac+
     &           f(it,ix+1,iy,ih)*(1d0-dt)*dx*(1d0-dy)*(1d0-dh)
            getfrac=getfrac+
     &           f(it,ix,iy+1,ih)*(1d0-dt)*(1d0-dx)*dy*(1d0-dh)
            getfrac=getfrac+
     &           f(it,ix,iy,ih+1)*(1d0-dt)*(1d0-dx)*(1d0-dy)*dh
            getfrac=getfrac+
     &           f(it+1,ix+1,iy,ih)*dt*dx*(1d0-dy)*(1d0-dh)
            getfrac=getfrac+
     &           f(it+1,ix,iy+1,ih)*dt*(1d0-dx)*dy*(1d0-dh)
            getfrac=getfrac+
     &           f(it+1,ix,iy,ih+1)*dt*(1d0-dx)*(1d0-dy)*dh
            getfrac=getfrac+
     &           f(it,ix+1,iy+1,ih)*(1d0-dt)*dx*dy*(1d0-dh)
            getfrac=getfrac+
     &           f(it,ix+1,iy,ih+1)*(1d0-dt)*dx*(1d0-dy)*dh
            getfrac=getfrac+
     &           f(it,ix,iy+1,ih+1)*(1d0-dt)*(1d0-dx)*dy*dh
            getfrac=getfrac+
     &           f(it,ix+1,iy+1,ih+1)*(1d0-dt)*dx*dy*dh
            getfrac=getfrac+
     &           f(it+1,ix,iy+1,ih+1)*dt*(1d0-dx)*dy*dh
            getfrac=getfrac+
     &           f(it+1,ix+1,iy,ih+1)*dt*dx*(1d0-dy)*dh
            getfrac=getfrac+
     &           f(it+1,ix+1,iy+1,ih)*dt*dx*dy*(1d0-dh)
            getfrac=getfrac+
     &           f(it+1,ix+1,iy+1,ih+1)*dt*dx*dy*dh

         return

         end
c############################################################

         double precision function getvx(tau,x,y,eta)
         implicit none

         double precision tau,x,y,eta
         double precision tau0,tau1
         double precision dt,dx,dy,dh

         integer maxt,maxx,maxy,maxh,it,ix,iy,ih

c...Mesh size of numerical data   
c         parameter(maxt=60,maxx=80,maxy=40,maxh=20)
         parameter(maxt=100,maxx=120,maxy=60,maxh=20)

         double precision vxx
         common/hydro4/vxx(0:maxt,0:maxx,0:maxy,0:maxh)

c...initial and final time of partonic phase
         tau0 = 0.6d0
         tau1 = 24.6d0
c...initialize
         getvx=0d0

c...Check tau
         if (tau .lt. tau0)then
           write(6,*)'Still before thermalization (tau<0.6fm/c)'
           return
         else if (tau .gt. tau1)then
           write(6,*)'No data (tau > ',tau1,' fm/c)'
           return
         endif

         call getGridPoint(tau,x,y,eta,dt,dx,dy,dh,
     &                                 it,ix,iy,ih)


         if((ix .le. 0).or.(ix .ge. maxx)
     &        .or.(iy.ge.maxy).or.(ih.ge.maxh))then
            return
         endif

c...Interpolate in 4D
            getvx=vxx(it,ix,iy,ih)
     &           *(1d0-dt)*(1d0-dx)*(1d0-dy)*(1d0-dh)
            getvx=getvx+
     &           vxx(it+1,ix,iy,ih)*dt*(1d0-dx)*(1d0-dy)*(1d0-dh)
            getvx=getvx+
     &           vxx(it,ix+1,iy,ih)*(1d0-dt)*dx*(1d0-dy)*(1d0-dh)
            getvx=getvx+
     &           vxx(it,ix,iy+1,ih)*(1d0-dt)*(1d0-dx)*dy*(1d0-dh)
            getvx=getvx+
     &           vxx(it,ix,iy,ih+1)*(1d0-dt)*(1d0-dx)*(1d0-dy)*dh
            getvx=getvx+
     &           vxx(it+1,ix+1,iy,ih)*dt*dx*(1d0-dy)*(1d0-dh)
            getvx=getvx+
     &           vxx(it+1,ix,iy+1,ih)*dt*(1d0-dx)*dy*(1d0-dh)
            getvx=getvx+
     &           vxx(it+1,ix,iy,ih+1)*dt*(1d0-dx)*(1d0-dy)*dh
            getvx=getvx+
     &           vxx(it,ix+1,iy+1,ih)*(1d0-dt)*dx*dy*(1d0-dh)
            getvx=getvx+
     &           vxx(it,ix+1,iy,ih+1)*(1d0-dt)*dx*(1d0-dy)*dh
            getvx=getvx+
     &           vxx(it,ix,iy+1,ih+1)*(1d0-dt)*(1d0-dx)*dy*dh
            getvx=getvx+
     &           vxx(it,ix+1,iy+1,ih+1)*(1d0-dt)*dx*dy*dh
            getvx=getvx+
     &           vxx(it+1,ix,iy+1,ih+1)*dt*(1d0-dx)*dy*dh
            getvx=getvx+
     &           vxx(it+1,ix+1,iy,ih+1)*dt*dx*(1d0-dy)*dh
            getvx=getvx+
     &           vxx(it+1,ix+1,iy+1,ih)*dt*dx*dy*(1d0-dh)
            getvx=getvx+
     &           vxx(it+1,ix+1,iy+1,ih+1)*dt*dx*dy*dh

         if(eta .lt. 0d0) then
           getvx=-getvx
         endif

         return

         end

c############################################################

         double precision function getvy(tau,x,y,eta)
         implicit none

         double precision tau,x,y,eta
         double precision tau0,tau1
         double precision dt,dx,dy,dh

         integer maxt,maxx,maxy,maxh,it,ix,iy,ih

c...Mesh size of numerical data   
c         parameter(maxt=60,maxx=80,maxy=40,maxh=20)
         parameter(maxt=100,maxx=120,maxy=60,maxh=20)

         double precision vyy
         common/hydro5/vyy(0:maxt,0:maxx,0:maxy,0:maxh)

c...initial and final time of partonic phase
         tau0 = 0.6d0
         tau1 = 24.6d0
c...initialize
         getvy=0d0


c...Check tau
         if (tau .lt. tau0)then
           write(6,*)'Still before thermalization (tau<0.6fm/c)'
           return
         else if (tau .gt. tau1)then
           write(6,*)'No data (tau > ',tau1,' fm/c)'
           return
         endif

         call getGridPoint(tau,x,y,eta,dt,dx,dy,dh,
     &                                 it,ix,iy,ih)

         if((ix .le. 0).or.(ix .ge. maxx)
     &        .or.(iy.ge.maxy).or.(ih.ge.maxh))then
            return
         endif

c...Interpolate in 4D
            getvy=vyy(it,ix,iy,ih)
     &           *(1d0-dt)*(1d0-dx)*(1d0-dy)*(1d0-dh)
            getvy=getvy+
     &           vyy(it+1,ix,iy,ih)*dt*(1d0-dx)*(1d0-dy)*(1d0-dh)
            getvy=getvy+
     &           vyy(it,ix+1,iy,ih)*(1d0-dt)*dx*(1d0-dy)*(1d0-dh)
            getvy=getvy+
     &           vyy(it,ix,iy+1,ih)*(1d0-dt)*(1d0-dx)*dy*(1d0-dh)
            getvy=getvy+
     &           vyy(it,ix,iy,ih+1)*(1d0-dt)*(1d0-dx)*(1d0-dy)*dh
            getvy=getvy+
     &           vyy(it+1,ix+1,iy,ih)*dt*dx*(1d0-dy)*(1d0-dh)
            getvy=getvy+
     &           vyy(it+1,ix,iy+1,ih)*dt*(1d0-dx)*dy*(1d0-dh)
            getvy=getvy+
     &           vyy(it+1,ix,iy,ih+1)*dt*(1d0-dx)*(1d0-dy)*dh
            getvy=getvy+
     &           vyy(it,ix+1,iy+1,ih)*(1d0-dt)*dx*dy*(1d0-dh)
            getvy=getvy+
     &           vyy(it,ix+1,iy,ih+1)*(1d0-dt)*dx*(1d0-dy)*dh
            getvy=getvy+
     &           vyy(it,ix,iy+1,ih+1)*(1d0-dt)*(1d0-dx)*dy*dh
            getvy=getvy+
     &           vyy(it,ix+1,iy+1,ih+1)*(1d0-dt)*dx*dy*dh
            getvy=getvy+
     &           vyy(it+1,ix,iy+1,ih+1)*dt*(1d0-dx)*dy*dh
            getvy=getvy+
     &           vyy(it+1,ix+1,iy,ih+1)*dt*dx*(1d0-dy)*dh
            getvy=getvy+
     &           vyy(it+1,ix+1,iy+1,ih)*dt*dx*dy*(1d0-dh)
            getvy=getvy+
     &           vyy(it+1,ix+1,iy+1,ih+1)*dt*dx*dy*dh

         if(y .lt. 0d0) then
           getvy=-getvy
         endif

         return

         end
c############################################################

         double precision function getyf(tau,x,y,eta)
         implicit none

         double precision tau,x,y,eta
         double precision tau0,tau1
         double precision dt,dx,dy,dh

         integer maxt,maxx,maxy,maxh,it,ix,iy,ih

c...Mesh size of numerical data   
c         parameter(maxt=60,maxx=80,maxy=40,maxh=20)
         parameter(maxt=100,maxx=120,maxy=60,maxh=20)

         double precision yf
         common/hydro6/yf(0:maxt,0:maxx,0:maxy,0:maxh)

c...initial and final time of partonic phase
         tau0 = 0.6d0
         tau1 = 24.6d0
c...initialize
         getyf=0d0

c...Check tau
         if (tau .lt. tau0)then
           write(6,*)'Still before thermalization (tau<0.6fm/c)'
           return
         else if (tau .gt. tau1)then
           write(6,*)'No data (tau > ',tau1,' fm/c)'
           return
         endif

         call getGridPoint(tau,x,y,eta,dt,dx,dy,dh,
     &                                 it,ix,iy,ih)

         if((ix .le. 0).or.(ix .ge. maxx)
     &        .or.(iy.ge.maxy).or.(ih.ge.maxh))then
            return
         endif


c...Interpolate in 4D
            getyf=yf(it,ix,iy,ih)
     &           *(1d0-dt)*(1d0-dx)*(1d0-dy)*(1d0-dh)
            getyf=getyf+
     &           yf(it+1,ix,iy,ih)*dt*(1d0-dx)*(1d0-dy)*(1d0-dh)
            getyf=getyf+
     &           yf(it,ix+1,iy,ih)*(1d0-dt)*dx*(1d0-dy)*(1d0-dh)
            getyf=getyf+
     &           yf(it,ix,iy+1,ih)*(1d0-dt)*(1d0-dx)*dy*(1d0-dh)
            getyf=getyf+
     &           yf(it,ix,iy,ih+1)*(1d0-dt)*(1d0-dx)*(1d0-dy)*dh
            getyf=getyf+
     &           yf(it+1,ix+1,iy,ih)*dt*dx*(1d0-dy)*(1d0-dh)
            getyf=getyf+
     &           yf(it+1,ix,iy+1,ih)*dt*(1d0-dx)*dy*(1d0-dh)
            getyf=getyf+
     &           yf(it+1,ix,iy,ih+1)*dt*(1d0-dx)*(1d0-dy)*dh
            getyf=getyf+
     &           yf(it,ix+1,iy+1,ih)*(1d0-dt)*dx*dy*(1d0-dh)
            getyf=getyf+
     &           yf(it,ix+1,iy,ih+1)*(1d0-dt)*dx*(1d0-dy)*dh
            getyf=getyf+
     &           yf(it,ix,iy+1,ih+1)*(1d0-dt)*(1d0-dx)*dy*dh
            getyf=getyf+
     &           yf(it,ix+1,iy+1,ih+1)*(1d0-dt)*dx*dy*dh
            getyf=getyf+
     &           yf(it+1,ix,iy+1,ih+1)*dt*(1d0-dx)*dy*dh
            getyf=getyf+
     &           yf(it+1,ix+1,iy,ih+1)*dt*dx*(1d0-dy)*dh
            getyf=getyf+
     &           yf(it+1,ix+1,iy+1,ih)*dt*dx*dy*(1d0-dh)
            getyf=getyf+
     &           yf(it+1,ix+1,iy+1,ih+1)*dt*dx*dy*dh

         if(eta .lt. 0d0) then
           getyf=-getyf
         endif

         return

         end
C**********************************************************************
C                                                                     *
C       GAUSS 38                                                      *
C                                                                     *
C**********************************************************************
       SUBROUTINE GAUSS38(XINI,XFIN,XN,WN)
       DOUBLE PRECISION  XN(38),WN(38) ,XINI,XFIN
       DOUBLE PRECISION  X(38), W(38)
       INTEGER I
C     ..........................................
C     ..........................................
C       DATA NO YOMIKOMI
C     ..........................................
C
       DATA   X(38)/9.980499305357E-01 /,
     +   X(37)/9.897394542664E-01/,
     +   X(36)/9.748463285902E-01 /,
     +   X(35)/9.534663309335E-01 /,
     +   X(34)/9.257413320486E-01 /,
     +   X(33)/8.918557390046E-01 /,
     +   X(32)/8.520350219324E-01 /,
     +   X(31)/8.065441676053E-01 /,
     +   X(30)/7.556859037540E-01 /,
     +   X(29)/6.997986803792E-01 /,
     +   X(28)/6.392544158297E-01 /,
     +   X(27)/5.744560210478E-01 /,
     +   X(26)/5.058347179279E-01 /,
     +   X(25)/4.338471694324E-01 /,
     +   X(24)/3.589724404794E-01 /,
     +   X(23)/2.817088097902E-01 /,
     +   X(22)/2.025704538921E-01 /,
     +   X(21)/1.220840253379E-01 /,
     +   X(20)/4.078514790458E-2 /
C    ....................................
C    .....   WEIGHT       ...........
C
       DATA   W(38)/5.002880749632E-3 /,
     +   W(37)/1.161344471647E-2/,
     +   W(36)/1.815657770961E-2/,
     +   W(35)/2.457973973823E-2/,
     +   W(34)/3.083950054518E-2/,
     +   W(33)/3.689408159400E-2/,
     +   W(32)/4.270315850467E-2/,
     +   W(31)/4.822806186076E-2/,
     +   W(30)/5.343201991033E-2/,
     +   W(29)/5.828039914700E-2/,
     +   W(28)/6.274093339213E-2/,
     +   W(27)/6.678393797914E-2/,
     +   W(26)/7.038250706690E-2/,
     +   W(25)/7.351269258474E-2/,
     +   W(24)/7.615366354845E-2/,
     +   W(23)/7.828784465821E-2/,
     +   W(22)/7.990103324353E-2/,
     +   W(21)/8.098249377060E-2/,
     +   W(20)/8.152502928039E-2/
C
C
       DO 100 I = 1 ,19
       X(I)= -X(39 - I)
       W(I)= W( 39 - I )
 100   CONTINUE
       DO 120 I = 1 ,38
         XN(I) =(XFIN-XINI)*X(I)/2+(XINI+XFIN)/2
         WN(I) =(XFIN-XINI)*W(I)/2
 120   CONTINUE
       RETURN
       END
c################################################################
c...Random number
c...Taken from Numerical Recipe

      function ran2(idum)
      integer idum,im1,im2,imm1,ia1,ia2,iq1,iq2,ir1,ir2,ntab,ndiv
      double precision ran2,am,eps,rnmx
      parameter (im1=2147483563,im2=2147483399,am=1./im1,imm1=im1-1,
     *ia1=40014,ia2=40692,iq1=53668,iq2=52774,ir1=12211,ir2=3791,
     *ntab=32,ndiv=1+imm1/ntab,eps=1.2e-7,rnmx=1.-eps)
      integer idum2,j,k,iv(ntab),iy
      save iv,iy,idum2
      data idum2/123456789/, iv/ntab*0/, iy/0/
       if (idum.le.0) then
        idum=max(-idum,1)
        idum2=idum
        do 11 j=ntab+8,1,-1
        k=idum/iq1
        idum=ia1*(idum-k*iq1)-k*ir1
        if (idum.lt.0) idum=idum+im1
        if (j.le.ntab) iv(j)=idum
 11    continue
        iy=iv(1)
        endif
        k=idum/iq1
        idum=ia1*(idum-k*iq1)-k*ir1
        if (idum.lt.0) idum=idum+im1
        k=idum2/iq2
        idum2=ia2*(idum2-k*iq2)-k*ir2
        if (idum2.lt.0) idum2=idum2+im2
        j=1+iy/ndiv
        iy=iv(j)-idum2
        iv(j)=idum
        if(iy.lt.1)iy=iy+imm1
        ran2=min(am*iy,rnmx)
        return
        end
