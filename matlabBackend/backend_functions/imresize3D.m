function [ R ] = imresize3D(I, newSize)
%
% Author: Matthias Dorfer @ CIR Lab (Medical University of Vienna)
% email:  matthias.dorfer@meduniwien.ac.at
%

[x y z] = ndgrid(linspace(1,size(I,1),newSize(1)),...
          linspace(1,size(I,2),newSize(2)),...
          linspace(1,size(I,3),newSize(3)));
      
R = interp3(I,x,y,z);
