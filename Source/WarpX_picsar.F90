#if (BL_SPACEDIM == 3)

#define WRPX_PXR_PUSH_BVEC               pxrpush_em3d_bvec
#define WRPX_PXR_PUSH_BVEC_NORDER        pxrpush_em3d_bvec_norder
#define WRPX_PXR_PUSH_EVEC               pxrpush_em3d_evec
#define WRPX_PXR_PUSH_EVEC_NORDER        pxrpush_em3d_evec_norder
#define WRPX_PXR_GETEB_ENERGY_CONSERVING geteb3d_energy_conserving

#elif (BL_SPACEDIM == 2)

#define WRPX_PXR_PUSH_BVEC               pxrpush_em2d_bvec
#define WRPX_PXR_PUSH_BVEC_NORDER        pxrpush_em2d_bvec_norder
#define WRPX_PXR_PUSH_EVEC               pxrpush_em2d_evec
#define WRPX_PXR_PUSH_EVEC_NORDER        pxrpush_em2d_evec_norder
#define WRPX_PXR_GETEB_ENERGY_CONSERVING geteb2dxz_energy_conserving

#endif

#define LVECT_CURRDEPO 8_c_long
#define LVECT_FIELDGATHE 64_c_long

! _________________________________________________________________
!
!> @brief
!> Module that contains subroutines to be called with Boxlib
!> and that uses subroutines of Picsar
!>
!> @details
!> This avoids the use of interface with bind in the core of Picsar
!> This enables the use of integer in Boxlib and Logical in Picsar
!> wihtout compatibility issue
!>
!> @author
!> Weiqun Zhang
!> Ann Almgren
!> Remi Lehe
!> Mathieu Lobet
!>
module warpx_to_pxr_module
! _________________________________________________________________

  use iso_c_binding
  use bl_fort_module, only : c_real

  implicit none

  integer, parameter :: pxr_logical = 8

contains

  ! _________________________________________________________________
  !>
  !> @brief
  !> Main subroutine for the field gathering process
  !>
  !> @param[in] np number of particles
  !> @param[in] xp,yp,zp particle position arrays
  !> @param[in] ex,ey,ez particle electric fields in each direction
  !> @param[in] bx,by,bz particle magnetic fields in each direction
  !> @param[in] xmin,ymin,zmin tile grid minimum position
  !> @param[in] dx,dy,dz space discretization steps
  !> @param[in] nx,ny,nz number of cells
  !> @param[in] nxguard,nyguard,nzguard number of guard cells
  !> @param[in] nox,noy,noz interpolation order
  !> @param[in] exg,eyg,ezg electric field grid arrays
  !> @param[in] bxg,byg,bzg electric field grid arrays
  !> @param[in] lvect vector length
  !>
  subroutine warpx_geteb_energy_conserving(np,xp,yp,zp, &
       ex,ey,ez,bx,by,bz,xmin,ymin,zmin,dx,dy,dz,nx,ny,nz,nxguard,nyguard,nzguard, &
       nox,noy,noz,exg,eyg,ezg,bxg,byg,bzg, &
       ll4symtry,l_lower_order_in_v, &  !!!!!!!
       lvect,&
       field_gathe_algo) &
       bind(C, name="warpx_geteb_energy_conserving")

    integer(c_long), intent(in) :: field_gathe_algo
    integer(c_long), intent(in) :: np,nx,ny,nz,nox,noy,noz,nxguard,nyguard,nzguard
    integer(c_int), intent(in)  :: ll4symtry,l_lower_order_in_v
    integer(c_long),intent(in)   :: lvect
    real(c_real), dimension(np) :: xp,yp,zp,ex,ey,ez,bx,by,bz
    real(c_real), intent(in)    :: xmin,ymin,zmin,dx,dy,dz
    real(c_real), dimension(-nxguard:nx+nxguard,-nyguard:ny+nyguard,-nzguard:nz+nzguard) :: exg,eyg,ezg
    real(c_real), dimension(-nxguard:nx+nxguard,-nyguard:ny+nyguard,-nzguard:nz+nzguard) :: bxg,byg,bzg

    logical(pxr_logical) :: pxr_ll4symtry, pxr_l_lower_order_in_v

    pxr_ll4symtry = ll4symtry .eq. 1
    pxr_l_lower_order_in_v = l_lower_order_in_v .eq. 1

    CALL WRPX_PXR_GETEB_ENERGY_CONSERVING(np,xp,yp,zp, &
         ex,ey,ez,bx,by,bz,xmin,ymin,zmin,dx,dy,dz,nx,ny,nz,nxguard,nyguard,nzguard, &
         nox,noy,noz,exg,eyg,ezg,bxg,byg,bzg, &
         pxr_ll4symtry, pxr_l_lower_order_in_v, &
         lvect, &
         field_gathe_algo)

  end subroutine warpx_geteb_energy_conserving

! _________________________________________________________________
!>
!> @brief
!> Main subroutine for the charge deposition
!>
!> @details
!> This subroutines enable to controle the interpolation order
!> via the parameters nox,noy,noz and the type of algorithm via
!> the parameter charge_depo_algo
!
!> @param[inout] rho charge array
!> @param[in] np number of particles
!> @param[in] xp,yp,zp particle position arrays
!> @param[in] w particle weight arrays
!> @param[in] q particle species charge
!> @param[in] xmin,ymin,zmin tile grid minimum position
!> @param[in] dx,dy,dz space discretization steps
!> @param[in] nx,ny,nz number of cells
!> @param[in] nxguard,nyguard,nzguard number of guard cells
!> @param[in] nox,noy,noz interpolation order
!> @param[in] lvect vector length
!> @param[in] charge_depo_algo algorithm choice for the charge deposition
!>
subroutine warpx_charge_deposition(rho,np,xp,yp,zp,w,q,xmin,ymin,zmin,dx,dy,dz,nx,ny,nz,&
   nxguard,nyguard,nzguard,nox,noy,noz,lvect,charge_depo_algo) &
  bind(C, name="warpx_charge_deposition")

  integer(c_long), intent(IN)                                  :: np
  integer(c_long), intent(IN)                                  :: nx,ny,nz
  integer(c_long), intent(IN)                                  :: nxguard,nyguard,nzguard
  integer(c_long), intent(IN)                                  :: nox,noy,noz
  real(c_real), intent(IN OUT), dimension(-nxguard:nx+nxguard,&
       &                                  -nyguard:ny+nyguard,&
       &                                  -nzguard:nz+nzguard) :: rho
  real(c_real), intent(IN)                                     :: q
  real(c_real), intent(IN)                                     :: dx,dy,dz
  real(c_real), intent(IN)                                     :: xmin,ymin,zmin
  real(c_real), dimension(np)                                  :: xp,yp,zp,w
  integer(c_long), intent(IN)                                  :: lvect
  integer(c_long), intent(IN)                                  :: charge_depo_algo


  ! Dimension 3
#if (BL_SPACEDIM==3)

  SELECT CASE(charge_depo_algo)

  ! Scalar classical current deposition subroutines
  CASE(1)
    IF ((nox.eq.1).and.(noy.eq.1).and.(noz.eq.1)) THEN

      CALL depose_rho_scalar_1_1_1(rho,np,xp,yp,zp,w,q,xmin,ymin,zmin,dx,dy,dz,nx,ny,nz,&
    nxguard,nyguard,nzguard,lvect)

    ELSE IF ((nox.eq.2).and.(noy.eq.2).and.(noz.eq.2)) THEN

      CALL depose_rho_scalar_2_2_2(rho,np,xp,yp,zp,w,q,xmin,ymin,zmin,dx,dy,dz,nx,ny,nz,&
    nxguard,nyguard,nzguard,lvect)

    ELSE IF ((nox.eq.3).and.(noy.eq.3).and.(noz.eq.3)) THEN

      CALL depose_rho_scalar_3_3_3(rho,np,xp,yp,zp,w,q,xmin,ymin,zmin,dx,dy,dz,nx,ny,nz,&
    nxguard,nyguard,nzguard,lvect)

    ELSE
      CALL pxr_depose_rho_n(rho,np,xp,yp,zp,w,q,xmin,ymin,zmin,dx,dy,dz,nx,ny,nz,&
                  nxguard,nyguard,nzguard,nox,noy,noz, &
                  .TRUE._c_long,.FALSE._c_long)
    ENDIF

  ! Optimized subroutines
  CASE DEFAULT

    IF ((nox.eq.1).and.(noy.eq.1).and.(noz.eq.1)) THEN
      CALL depose_rho_vecHVv2_1_1_1(rho,np,xp,yp,zp,w,q,xmin,ymin,zmin,dx,dy,dz,nx,ny,nz,&
               nxguard,nyguard,nzguard,lvect)
    ELSE
      CALL pxr_depose_rho_n(rho,np,xp,yp,zp,w,q,xmin,ymin,zmin,dx,dy,dz,nx,ny,nz,&
                  nxguard,nyguard,nzguard,nox,noy,noz, &
                  .TRUE._c_long,.FALSE._c_long)
    ENDIF
  END SELECT

  ! Dimension 2
#elif (BL_SPACEDIM==2)


#endif

 end subroutine warpx_charge_deposition

  ! _________________________________________________________________
  !>
  !> @brief
  !> Main subroutine for the current deposition
  !>
  !> @details
  !> This subroutines enable to controle the interpolation order
  !> via the parameters nox,noy,noz and the type of algorithm via
  !> the parameter current_depo_algo
  !
  !> @param[inout] jx,jy,jz current arrays
  !> @param[in] np number of particles
  !> @param[in] xp,yp,zp particle position arrays
  !> @param[in] uxp,uyp,uzp particle momentum arrays
  !> @param[in] gaminv inverve of the particle Lorentz factor (array)
  !> @param[in] w particle weight arrays
  !> @param[in] q particle species charge
  !> @param[in] xmin,ymin,zmin tile grid minimum position
  !> @param[in] dx,dy,dz space discretization steps
  !> @param[in] nx,ny,nz number of cells
  !> @param[in] nxguard,nyguard,nzguard number of guard cells
  !> @param[in] nox,noy,noz interpolation order
  !> @param[in] lvect vector length
  !> @param[in] charge_depo_algo algorithm choice for the charge deposition
  !>
  subroutine warpx_current_deposition(jx,jy,jz,np,xp,yp,zp,uxp,uyp,uzp,gaminv,&
                                      w,q,xmin,ymin,zmin,dt,dx,dy,dz,nx,ny,nz,&
                                      nxguard,nyguard,nzguard,nox,noy,noz,&
                                      lvect,current_depo_algo) &
                                      bind(C, name="warpx_current_deposition")

    integer(c_long), intent(IN)                                  :: np
    integer(c_long), intent(IN)                                  :: nx,ny,nz
    integer(c_long), intent(IN)                                  :: nxguard,nyguard,nzguard
    integer(c_long), intent(IN)                                  :: nox,noy,noz
    real(c_real), intent(IN OUT), dimension(-nxguard:nx+nxguard,&
         &                                  -nyguard:ny+nyguard,&
         &                                  -nzguard:nz+nzguard) :: jx,jy,jz
    real(c_real), intent(IN)                                     :: q
    real(c_real), intent(IN)                                     :: dx,dy,dz
    real(c_real), intent(IN)                                     :: dt
    real(c_real), intent(IN)                                     :: xmin,ymin,zmin
    real(c_real), dimension(np)                                  :: xp,yp,zp,w
    real(c_real), dimension(np)                                  :: uxp,uyp,uzp
    real(c_real), dimension(np)                                  :: gaminv
    integer(c_int), intent(IN)                                   :: lvect
    integer(c_int), intent(IN)                                   :: current_depo_algo

    ! Dimension 3
#if (BL_SPACEDIM==3)

    SELECT CASE(current_depo_algo)

    ! Scalar classical current deposition subroutines
    CASE(3)

      IF ((nox.eq.1).and.(noy.eq.1).and.(noz.eq.1)) THEN
        CALL depose_jxjyjz_scalar_1_1_1(jx,jy,jz,np,xp,yp,zp,uxp,uyp,uzp,gaminv,w,q,xmin,ymin,zmin, &
             dt,dx,dy,dz,nx,ny,nz,nxguard,nyguard,nzguard)
      ELSE IF ((nox.eq.2).and.(noy.eq.2).and.(noz.eq.2)) THEN
        CALL depose_jxjyjz_scalar_2_2_2(jx,jy,jz,np,xp,yp,zp,uxp,uyp,uzp,gaminv,w,q,xmin,ymin,zmin, &
             dt,dx,dy,dz,nx,ny,nz,nxguard,nyguard,nzguard)
      ELSE IF ((nox.eq.3).and.(noy.eq.3).and.(noz.eq.3)) THEN
        CALL depose_jxjyjz_scalar_3_3_3(jx,jy,jz,np,xp,yp,zp,uxp,uyp,uzp,gaminv,w,q,xmin,ymin,zmin, &
             dt,dx,dy,dz,nx,ny,nz,nxguard,nyguard,nzguard)
      ELSE
        CALL pxr_depose_jxjyjz_esirkepov_n(jx,jy,jz,np,xp,yp,zp,uxp,uyp,uzp,gaminv,w,q,xmin,ymin,zmin, &
             dt,dx,dy,dz,nx,ny,nz,nxguard,nyguard,nzguard, &
             nox,noy,noz,.TRUE._c_long,.FALSE._c_long)
      ENDIF

    ! Optimized classical current deposition
    CASE(2)

      IF ((nox.eq.1).and.(noy.eq.1).and.(noz.eq.1)) THEN
        CALL depose_jxjyjz_vecHVv2_1_1_1(jx,jy,jz,np,xp,yp,zp,uxp,uyp,uzp,gaminv,w,q,xmin,ymin,zmin, &
                 dt,dx,dy,dz,nx,ny,nz,nxguard,nyguard,nzguard)
      ELSE IF ((nox.eq.2).and.(noy.eq.2).and.(noz.eq.2)) THEN
        CALL depose_jxjyjz_vecHVv2_2_2_2(jx,jy,jz,np,xp,yp,zp,uxp,uyp,uzp,gaminv,w,q,xmin,ymin,zmin, &
                 dt,dx,dy,dz,nx,ny,nz,nxguard,nyguard,nzguard)
      ELSE IF ((nox.eq.3).and.(noy.eq.3).and.(noz.eq.3)) THEN
        CALL depose_jxjyjz_vecHVv3_3_3_3(jx,jy,jz,np,xp,yp,zp,uxp,uyp,uzp,gaminv,w,q,xmin,ymin,zmin, &
                 dt,dx,dy,dz,nx,ny,nz,nxguard,nyguard,nzguard)
      ELSE
        CALL pxr_depose_jxjyjz_esirkepov_n(jx,jy,jz,np,xp,yp,zp,uxp,uyp,uzp,gaminv,w,q,xmin,ymin,zmin, &
             dt,dx,dy,dz,nx,ny,nz,nxguard,nyguard,nzguard, &
             nox,noy,noz,.TRUE._c_long,.FALSE._c_long)
      ENDIF

    ! Esirkepov non optimized
    CASE(1)

        CALL pxr_depose_jxjyjz_esirkepov_n(jx,jy,jz,np,xp,yp,zp,uxp,uyp,uzp,gaminv,w,q,xmin,ymin,zmin, &
             dt,dx,dy,dz,nx,ny,nz,nxguard,nyguard,nzguard, &
             nox,noy,noz,.TRUE._c_long,.FALSE._c_long)

    ! Optimized Esirkepov
    CASE DEFAULT

      IF ((nox.eq.1).and.(noy.eq.1).and.(noz.eq.1)) THEN
        CALL depose_jxjyjz_esirkepov_1_1_1(jx,jy,jz,np,xp,yp,zp,uxp,uyp,uzp,gaminv,w,q,xmin,ymin,zmin, &
                                            dt,dx,dy,dz,nx,ny,nz,nxguard,nyguard,nzguard, &
                                            nox,noy,noz,.TRUE._c_long,.FALSE._c_long)
      ELSE IF ((nox.eq.2).and.(noy.eq.2).and.(noz.eq.2)) THEN
        CALL depose_jxjyjz_esirkepov_2_2_2(jx,jy,jz,np,xp,yp,zp,uxp,uyp,uzp,gaminv,w,q,xmin,ymin,zmin, &
                                            dt,dx,dy,dz,nx,ny,nz,nxguard,nyguard,nzguard, &
                                            nox,noy,noz,.TRUE._c_long,.FALSE._c_long)
      ELSE IF ((nox.eq.3).and.(noy.eq.3).and.(noz.eq.3)) THEN
        CALL depose_jxjyjz_esirkepov_3_3_3(jx,jy,jz,np,xp,yp,zp,uxp,uyp,uzp,gaminv,w,q,xmin,ymin,zmin, &
                                            dt,dx,dy,dz,nx,ny,nz,nxguard,nyguard,nzguard, &
                                            nox,noy,noz,.TRUE._c_long,.FALSE._c_long)
      ELSE
        CALL pxr_depose_jxjyjz_esirkepov_n(jx,jy,jz,np,xp,yp,zp,uxp,uyp,uzp,gaminv,w,q,xmin,ymin,zmin, &
             dt,dx,dy,dz,nx,ny,nz,nxguard,nyguard,nzguard, &
             nox,noy,noz,.TRUE._c_long,.FALSE._c_long)
      ENDIF

    END SELECT

    ! Dimension 2
#elif (BL_SPACEDIM==2)

      IF ((nox.eq.1).and.(noz.eq.1)) THEN
        CALL pxr_depose_jxjyjz_esirkepov2d_1_1(jx,jy,jz,np,xp,zp,uxp,uyp,uzp, &
	     	gaminv,w,q,xmin,zmin,dt,dx,dz,nx,nz,nxguard,nzguard, &
        	nox,noz,LVECT,.TRUE._c_long,.FALSE._c_long,.FALSE._c_long,&
		.FALSE._c_long)
      ELSE IF ((nox.eq.2).and.(noz.eq.2)) THEN
        CALL pxr_depose_jxjyjz_esirkepov2d_2_2(jx,jy,jz,np,xp,zp,uxp,uyp,uzp, &
	     	gaminv,w,q,xmin,zmin,dt,dx,dz,nx,nz,nxguard,nzguard, &
        	nox,noz,LVECT,.TRUE._c_long,.FALSE._c_long,.FALSE._c_long,&
		.FALSE._c_long)
      ELSE IF ((nox.eq.3).and.(noz.eq.3)) THEN
        CALL pxr_depose_jxjyjz_esirkepov2d_3_3(jx,jy,jz,np,xp,zp,uxp,uyp,uzp, &
	     	gaminv,w,q,xmin,zmin,dt,dx,dz,nx,nz,nxguard,nzguard, &
        	nox,noz,LVECT,.TRUE._c_long,.FALSE._c_long,.FALSE._c_long,&
		.FALSE._c_long)
      ELSE
        CALL pxr_depose_jxjyjz_esirkepov2d_n(jx,jy,jz,np,xp,yp,zp,uxp,uyp,uzp,&
	     gaminv,w,q,xmin,zmin,dt,dx,dz,nx,nz,nxguard,nzguard, &
             nox,noz,.TRUE._c_long,.FALSE._c_long)
      ENDIF

#endif


  end subroutine

  ! _________________________________________________________________
  !>
  !> @brief
  !> Main subroutine for the particle pusher
  !>
  !> @param[in] np number of super-particles
  !> @param[in] xp,yp,zp particle position arrays
  !> @param[in] uxp,uyp,uzp normalized momentum in each direction
  !> @param[in] gaminv particle Lorentz factors
  !> @param[in] ex,ey,ez particle electric fields in each direction
  !> @param[in] bx,by,bz particle magnetic fields in each direction
  !> @param[in] q charge
  !> @param[in] m masse
  !> @param[in] dt time step
  !> @param[in] particle_pusher_algo Particle pusher algorithm
  subroutine warpx_particle_pusher(np,xp,yp,zp,uxp,uyp,uzp, &
                                  gaminv,&
                                  ex,ey,ez,bx,by,bz,q,m,dt, &
                                  particle_pusher_algo) &
       bind(C, name="warpx_particle_pusher")

    INTEGER(c_long), INTENT(IN)   :: np
    REAL(c_real),INTENT(INOUT)    :: gaminv(np)
    REAL(c_real),INTENT(INOUT)    :: xp(np),yp(np),zp(np)
    REAL(c_real),INTENT(INOUT)    :: uxp(np),uyp(np),uzp(np)
    REAL(c_real),INTENT(IN)       :: ex(np),ey(np),ez(np)
    REAL(c_real),INTENT(IN)       :: bx(np),by(np),bz(np)
    REAL(c_real),INTENT(IN)       :: q,m,dt
    INTEGER(c_long), INTENT(IN)   :: particle_pusher_algo

    SELECT CASE (particle_pusher_algo)

    !! Vay pusher -- Full push
    CASE (1_c_long)
#if (BL_SPACEDIM == 3)
      CALL pxr_ebcancelpush3d(np,uxp,uyp,uzp,gaminv, &
                                 ex,ey,ez,  &
                                 bx,by,bz,q,m,dt,0_c_long)
#else
      call bl_error("Is there a 2d Vay pusher implemented?")
#endif
    CASE DEFAULT

      !! --- Push velocity with E half step
      CALL pxr_epush_v(np,uxp,uyp,uzp,      &
                      ex,ey,ez,q,m,dt*0.5_c_real)
      !! --- Set gamma of particles
      CALL pxr_set_gamma(np,uxp,uyp,uzp,gaminv)
      !! --- Push velocity with B
      CALL pxr_bpush_v(np,uxp,uyp,uzp,gaminv,      &
                      bx,by,bz,q,m,dt)
      !!! --- Push velocity with E half step
      CALL pxr_epush_v(np,uxp,uyp,uzp,      &
                      ex,ey,ez,q,m,dt*0.5_c_real)
      !! --- Set gamma of particles
      CALL pxr_set_gamma(np,uxp,uyp,uzp,gaminv)
    END SELECT

    !!!! --- push particle species positions a time step
#if (BL_SPACEDIM == 3)    
    CALL pxr_pushxyz(np,xp,yp,zp,uxp,uyp,uzp,gaminv,dt)
#elif (BL_SPACEDIM == 2)
    CALL pxr_pushxz(np,xp,zp,uxp,uzp,gaminv,dt)
#endif

  end subroutine


  ! _________________________________________________________________
  !>
  !> @brief
  !> Main function in warpx for evolving the electric field
  !>
  subroutine warpx_push_evec(ex,ey,ez,bx,by,bz,jx,jy,jz,mudt,    &
       dtsdx,dtsdy,dtsdz,nx,ny,nz,   &
       norderx,nordery,norderz,             &
       nxguard,nyguard,nzguard,nxs,nys,nzs, &
       l_nodalgrid) &  !!!!!
       bind(C, name="warpx_push_evec")

    integer(c_long) :: nx,ny,nz,nxguard,nyguard,nzguard,nxs,nys,nzs,norderx,nordery,norderz
    real(c_real), intent(IN OUT), dimension(-nxguard:nx+nxguard,&
         &                                  -nyguard:ny+nyguard,&
         &                                  -nzguard:nz+nzguard) :: ex,ey,ez,bx,by,bz
    real(c_real), intent(IN), dimension(-nxguard:nx+nxguard,&
         &                              -nyguard:ny+nyguard,&
         &                              -nzguard:nz+nzguard) :: jx, jy, jz
    real(c_real), intent(IN) :: mudt,dtsdx(norderx/2),dtsdy(nordery/2),dtsdz(norderz/2)
    integer(c_int)           :: l_nodalgrid
    logical(pxr_logical)     :: pxr_l_nodalgrid

    pxr_l_nodalgrid = l_nodalgrid .eq. 1

    if ((norderx.eq.2).and.(nordery.eq.2).and.(norderz.eq.2)) then

      call WRPX_PXR_PUSH_EVEC(ex,ey,ez,bx,by,bz,jx,jy,jz,mudt, &
           dtsdx,dtsdy,dtsdz,nx,ny,nz,   &
           nxguard,nyguard,nzguard,nxs,nys,nzs, &
           pxr_l_nodalgrid)

    else

     call WRPX_PXR_PUSH_EVEC_NORDER(ex,ey,ez,bx,by,bz,jx,jy,jz,mudt, &
          dtsdx,dtsdy,dtsdz,nx,ny,nz,   &
          norderx,nordery,norderz,             &
          nxguard,nyguard,nzguard,nxs,nys,nzs, &
          pxr_l_nodalgrid)

   end if

 end subroutine warpx_push_evec

  ! _________________________________________________________________
  !>
  !> @brief
  !> Main function in warpx for evolving the magnetic field
  !>
  subroutine warpx_push_bvec(ex,ey,ez,bx,by,bz,                  &
       dtsdx,dtsdy,dtsdz,nx,ny,nz,          &
       norderx,nordery,norderz,             &
       nxguard,nyguard,nzguard,nxs,nys,nzs, &
       l_nodalgrid) &  !!!!!
       bind(C, name="warpx_push_bvec")

    integer(c_long) :: nx,ny,nz,nxguard,nyguard,nzguard,nxs,nys,nzs,norderx,nordery,norderz
    real(c_real), intent(IN OUT), dimension(-nxguard:nx+nxguard,&
         &                                  -nyguard:ny+nyguard,&
         &                                  -nzguard:nz+nzguard) :: ex,ey,ez,bx,by,bz
    real(c_real), intent(IN) :: dtsdx(norderx/2),dtsdy(nordery/2),dtsdz(norderz/2)
    integer(c_int)           :: l_nodalgrid
    logical(pxr_logical)     :: pxr_l_nodalgrid

    pxr_l_nodalgrid = l_nodalgrid .eq. 1

    if ((norderx.eq.2).and.(nordery.eq.2).and.(norderz.eq.2)) then

      call WRPX_PXR_PUSH_BVEC(ex,ey,ez,bx,by,bz,                  &
           dtsdx,dtsdy,dtsdz,nx,ny,nz,          &
           nxguard,nyguard,nzguard,nxs,nys,nzs, &
           pxr_l_nodalgrid)

    else

      call WRPX_PXR_PUSH_BVEC_NORDER(ex,ey,ez,bx,by,bz,                  &
           dtsdx,dtsdy,dtsdz,nx,ny,nz,          &
           norderx,nordery,norderz,             &
           nxguard,nyguard,nzguard,nxs,nys,nzs, &
           pxr_l_nodalgrid)

    endif


  end subroutine warpx_push_bvec

end module warpx_to_pxr_module
