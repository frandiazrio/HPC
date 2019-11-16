c---------------------------------------------------------------------
c---------------------------------------------------------------------
c---  lu_data module
c---------------------------------------------------------------------
c---------------------------------------------------------------------

      module lu_data

c---------------------------------------------------------------------
c   npbparams.h defines parameters that depend on the class and 
c   number of nodes
c---------------------------------------------------------------------

      include 'npbparams.h'

c---------------------------------------------------------------------
c   parameters which can be overridden in runtime config file
c   (in addition to size of problem - isiz01,02,03 give the maximum size)
c   ipr = 1 to print out verbose information
c   omega = 2.0 is correct for all classes
c   tolrsd is tolerance levels for steady state residuals
c---------------------------------------------------------------------
      integer ipr_default
      parameter (ipr_default = 1)
      double precision omega_default
      parameter (omega_default = 1.2d0)
      double precision tolrsd1_def, tolrsd2_def, tolrsd3_def, 
     >                 tolrsd4_def, tolrsd5_def
      parameter (tolrsd1_def=1.0e-08, 
     >          tolrsd2_def=1.0e-08, tolrsd3_def=1.0e-08, 
     >          tolrsd4_def=1.0e-08, tolrsd5_def=1.0e-08)

      double precision c1, c2, c3, c4, c5
      parameter( c1 = 1.40d+00, c2 = 0.40d+00,
     >           c3 = 1.00d-01, c4 = 1.00d+00,
     >           c5 = 1.40d+00 )

c---------------------------------------------------------------------
c   grid
c---------------------------------------------------------------------
      integer nx, ny, nz
      integer nx0, ny0, nz0
      integer ipt, ist, iend
      integer jpt, jst, jend
      integer ii1, ii2
      integer ji1, ji2
      integer ki1, ki2
      double precision  dxi, deta, dzeta
      double precision  tx1, tx2, tx3
      double precision  ty1, ty2, ty3
      double precision  tz1, tz2, tz3

c---------------------------------------------------------------------
c   dissipation
c---------------------------------------------------------------------
      double precision dx1, dx2, dx3, dx4, dx5
      double precision dy1, dy2, dy3, dy4, dy5
      double precision dz1, dz2, dz3, dz4, dz5
      double precision dssp

c---------------------------------------------------------------------
c   field variables and residuals
c---------------------------------------------------------------------
      double precision, allocatable ::
     >       u   (:,:,:,:),
     >       rsd (:,:,:,:),
     >       frct(:,:,:,:),
     >       flux(:,:,:,:)


c---------------------------------------------------------------------
c   output control parameters
c---------------------------------------------------------------------
      integer ipr, inorm

c---------------------------------------------------------------------
c   newton-raphson iteration control parameters
c---------------------------------------------------------------------
      integer itmax, invert
      double precision  dt, omega, tolrsd(5),
     >        rsdnm(5), errnm(5), frc, ttotal

      double precision, allocatable ::
     >       a(:,:,:),
     >       b(:,:,:),
     >       c(:,:,:),
     >       d(:,:,:)

c---------------------------------------------------------------------
c   coefficients of the exact solution
c---------------------------------------------------------------------
      double precision ce(5,13)

c---------------------------------------------------------------------
c   working arrays for surface integral
c---------------------------------------------------------------------
      double precision, allocatable ::
     >       phi1(:,:),
     >       phi2(:,:)

c---------------------------------------------------------------------
c   multi-processor parameters
c---------------------------------------------------------------------
      integer id, ndim, num, xdim, ydim, row, col

      integer north,south,east,west

      integer from_s,from_n,from_e,from_w
      parameter (from_s=1,from_n=2,from_e=3,from_w=4)

      double precision, allocatable ::
     >       buf (:,:),
     >       buf1(:,:)

c sub-domain array size
      integer isiz1, isiz2, isiz3, nnodes_xdim


      end module lu_data


c---------------------------------------------------------------------
c---------------------------------------------------------------------
c---  timing module
c---------------------------------------------------------------------
c---------------------------------------------------------------------

      module timing

      integer t_total, t_rhs, t_blts, t_buts, t_jacld, t_jacu,
     >        t_exch, t_lcomm, t_ucomm, t_rcomm, t_last
      parameter (t_total=1, t_rhs=2, t_blts=3, t_buts=4, t_jacld=5, 
     >        t_jacu=6, t_exch=7, t_lcomm=8, t_ucomm=9, t_rcomm=10, 
     >        t_last=10)

      double precision maxtime
      logical timeron

      end module timing


c---------------------------------------------------------------------
c---------------------------------------------------------------------

      subroutine alloc_space

c---------------------------------------------------------------------
c---------------------------------------------------------------------

c---------------------------------------------------------------------
c allocate space dynamically for data arrays
c---------------------------------------------------------------------

      use lu_data
      use mpinpb

      implicit none

      integer ios, ierr

c---------------------------------------------------------------------
c parameters (isiz1, isiz2, isiz3) are set in proc_grid
c---------------------------------------------------------------------
      allocate (
     >       u   (5, -1:isiz1+2, -1:isiz2+2, isiz3),
     >       rsd (5, -1:isiz1+2, -1:isiz2+2, isiz3),
     >       frct(5, -1:isiz1+2, -1:isiz2+2, isiz3),
     >       flux(5,  0:isiz1+1,  0:isiz2+1, isiz3),
     >       stat = ios)

      if (ios .eq. 0) allocate (
     >       a(5, 5, isiz1),
     >       b(5, 5, isiz1),
     >       c(5, 5, isiz1),
     >       d(5, 5, isiz1),
     >       phi1(0:isiz2+1, 0:isiz3+1),
     >       phi2(0:isiz2+1, 0:isiz3+1),
     >       stat = ios)

      if (ios .eq. 0) allocate (
     >       buf (5, 2*isiz2*isiz3),
     >       buf1(5, 2*isiz2*isiz3),
     >       stat = ios)

      if (ios .ne. 0) then
         write(*,*) 'Error encountered in allocating space'
         call MPI_Abort(MPI_COMM_WORLD, MPI_ERR_OTHER, ierr)
         stop
      endif

      return
      end

