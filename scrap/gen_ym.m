load data\EMISAR\C.mat img;
[Nx, Ny, Nc] = size(img);
[Ps, Pd, Pv, Pc, ~] = yamaguchi(reshape(img, [], Nc));
ym = cat(3, reshape(Pd, Nx, Ny), reshape(Pc, Nx, Ny), reshape(Ps, Nx, Ny), reshape(Pv, Nx, Ny));
save('data\EMISAR\Yamaguchi.mat', 'ym');

clear;

load data\psr_plr11_BOX\C.mat img;
[Nx, Ny, Nc] = size(img); 
C = multiLook(img, [4, 1], 'distinct');
[Ps, Pd, Pv, Pc, ~] = yamaguchi(reshape(C, [], Nc));
[Nx, Ny, Nc] = size(C);

ym = cat(3, reshape(Pd, Nx, Ny), reshape(Pc, Nx, Ny), reshape(Ps, Nx, Ny), reshape(Pv, Nx, Ny));
save('data\psr_plr11_BOX\C.mat', 'C');
save('data\psr_plr11_BOX\Yamaguchi.mat', 'ym');
clear;