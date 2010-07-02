function try_this(how)
nodes = {'polestar','node-13','node-12'};
eval(MPI_Run('test_mpi',3,nodes));
fprintf('Results obtained');
