% Image pixel coordinates
I = [30, 18, 30, 6, 8; 9, 10, 30, 12, 4; 8, 13, 15, 1, 14; 5, 7, 18, 5, 9; 2, 3, 2, 15, 20 ];
%Compute x and y derivatives at each pixel
Gdx = [-1 0 1; -2 0 2; 1 0 1]; % image derivatives
 Ix = imfilter(I, Gdx);
Gdy = [-1 -2 -1; 0 0 0; 1 2 1]; % image derivatives
 Iy = imfilter(I, Gdy);

% Calculating the gradient of the image Ix and Iy by computing products of
% derivatives at every pixel(square the derivatives)
%Ix * Ix
Ix2 = Ix.*Iy;
%Iy * Iy 
Iy2 = Iy.*Iy;
%Ix * Iy = Ixy
IxIy = Ix.*Iy;
%Compute second moment matrix M 
 [m, s]=size(Ix2);
Eign = zeros(m, s); % Compute matrix E
for i=2:1:m-1 
    for j=2:1:s-1
     Ix21=sum(sum(Ix2(i-1:i+1,j-1:j+1)));
     Iy21=sum(sum(Iy2(i-1:i+1,j-1:j+1)));
     IxIy1= sum(sum(IxIy(i-1:i+1,j-1:j+1)));
     M=[Ix21 IxIy1;IxIy1 Iy21]; %(1) Build autocorrelation matrix for every singe pixel considering a window of size 3x3
     Eign(i,j)=min(eig(M)); %(2)Compute Eigen value of the autocorrelation matrix and save the minimum eigenvalue as the desired value.
    end
end
%Compute corner response function R
[m, s]=size(Ix2);
R = zeros(m, s);
%constant or tunable parameter
k = 0.04;
for i=2:1:m-1
    for j=2:1:s-1
     Ix21=sum(sum(Ix2(i-1:i+1,j-1:j+1)));
     Iy21=sum(sum(Iy2(i-1:i+1,j-1:j+1)));
     IxIy1= sum(sum(IxIy(i-1:i+1,j-1:j+1)));
     M=[Ix21 IxIy1;IxIy1 Iy21];
     R(i,j)=det(M)-k*trace(M).^2; %(1) Build autocorrelation matrix for every singe pixel considering a window of size 3x3
    end
end