
#include <BoxLib.H>
#include <BLProfiler.H>

#include <WarpXWrappers.h>
#include <WarpX.H>

extern "C"
{
    void boxlib_init (int argc, char* argv[])
    {
	BoxLib::Initialize(argc,argv);
    }

    void boxlib_init_with_inited_mpi (int argc, char* argv[], MPI_Comm mpicomm)
    {
	BoxLib::Initialize(argc,argv,true,mpicomm);	
    }

    void boxlib_finalize (int finalize_mpi)
    {
	BoxLib::Finalize(finalize_mpi);
    }

    void warpx_init ()
    {
	WarpX& warpx = WarpX::GetInstance();
	warpx.InitData();
    }

    void warpx_finalize ()
    {
	WarpX::ResetInstance();
    }

    void warpx_evolve (int numsteps)
    {
	WarpX& warpx = WarpX::GetInstance();
	warpx.Evolve(numsteps);
    }
}

