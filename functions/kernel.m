function G = kernel(U, V)

%% Gaussian kernel
% gamma = 5*10^4;
% G = exp(-gamma*U*V');

%% Homogeneous Kernel Map
v = vl_homkermap(V', 3);
u = vl_homkermap(U', 3);
G = v'*u;
% G = vl_alldist(V', U', 'kchi2');

end