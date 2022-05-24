% Image Coordinates
I = [212, 195, 167, 202, 182; 221, 198, 164, 121, 44; 137, 62, 22, 132, 38; 220, 184, 134, 218, 185; 190, 172, 134, 187, 105 ];
%Noise reduction , filters out any noise by using the Gaussian filter of
%kernel size 5 x5
K = [2, 4, 5, 4, 2; 4, 9, 12, 9, 4;5, 12, 15, 12, 5;4, 9, 12, 9, 4;2, 4, 5, 4, 2 ];
%multiply the kernel size by 1/159
K = 1/159.* K;
% Compute the covolution of image by the Gaussian filter with the kernel
% size and the image coordinates
M=conv2(I, K);
%Calculate the graident
%Apply a pair of convolution masks in the x and y directions by using the sobel operator that is based on 3 x 3 filter 
A = [135.3082, 139.5283, 115.5975, 80.8050, 40.6226; 121.3899, 127.1321, 108.8428, 77.3836, 39.5660; 93.5786, 99.8428, 86.6667, 62.6981, 32.3774; 53.4591, 57.2767, 49.1635, 34.8679, 18.0440; 11.9119, 16.9560, 14.0566, 9.6918, 4.9937 ];
[Gx, Gy] = imgradient(A);
% Compute the gradient strength to find the magnitude of the verticle and
% horizontal filter
magnitude = sqrt(A);
% Find the gradient direction for the vertical and hoirzontal filter
DirGy = [71.2304, 147.6135, 172.6037, 177.1485, 177.6167; 82.4103, 109.0194, 149.3749, 164.6755, 163.6608; 85.3852, 96.5442, 122.2917, 141.4989, 37.1122; 86.6934, 92.3900, 107.6096, 121.3685, 116.9328; 83.4469, 89.2211, 108.0406, 120.6215, 115.6709 ];
DirGx = [57.1926, 84.8823, 227.8140, 294.5662, 158.5019; 166.3315, 158.6948, 227.0316, 277.6913, 152.2888; 274.5378, 269.0741, 274.1264, 267.0278, 157.3424; 328.4337, 320.3291, 294.9340, 241.2712, 151.6002; 166.0472, 157.3100, 142.7275, 114.4725, 71.3715 ];
direction = DirGy./DirGx;
Gd = atand(direction);
weig = size(A,1);
knl = size(A,2);
for i=1:weig
    for j=1:knl
        if (direction(i,j)<0) 
            direction(i,j)=360+direction(i,j);
        end
    end
end
Gdirection=zeros(weig, knl);
%Adjusting directions to nearest 0, 45, 90, or 135 degree to find the
%maxima
for i = 1  : weig
    for j = 1 : knl
        if ((direction(i, j) >= 0 ) && (direction(i, j) < 22.5) || (direciton(i, j) >= 157.5) && (direction(i, j) < 202.5) || (direction(i, j) >= 337.5) && (direction(i, j) <= 360))
            Gdirection(i, j) = 0;
        elseif ((arah(i, j) >= 22.5) && (direction(i, j) < 67.5) || (direction(i, j) >= 202.5) && (direction(i, j) < 247.5))
            Gdirection(i, j) = 45;
        elseif ((direction(i, j) >= 67.5 && direction(i, j) < 112.5) || (direction(i, j) >= 247.5 && direction(i, j) < 292.5))
            Gdirection(i, j) = 90;
        elseif ((direction(i, j) >= 112.5 && direction(i, j) < 157.5) || (direction(i, j) >= 292.5 && direction(i, j) < 337.5))
            Gdirection(i, j) = 135;
        end
    end
end
gradImax = zeros (weig, knl);

%Compute the Non-Maximum Supression initalize the matrix to 0 and use the
%angle matrix
for i=2:weig-1
    for j=2:knl-1
        if (Gdirection(i,j)==0)
            gradImax(i,j) = (magnitude(i,j) == max([magnitude(i,j), magnitude(i,j+1), magnitude(i,j-1)]));
        elseif (Gdirection(i,j)==45)
            gradImax(i,j) = (magnitude(i,j) == max([magnitude(i,j), magnitude(i+1,j-1), magnitude(i-1,j+1)]));
        elseif (gradImax(i,j)==90)
            gradImax(i,j) = (magnitude(i,j) == max([magnitude(i,j), magnitude(i+1,j), magnitude(i-1,j)]));
        elseif (Gdirection(i,j)==135)
            gradImax(i,j) = (magnitude(i,j) == max([magnitude(i,j), magnitude(i+1,j+1), magnitude(i-1,j-1)]));
        end
    end
end
gradImax = gradImax.*magnitude;

%Threshold Values
Threshold_low = 0.075;
Threshold_high = 0.175;

%Compute Hysteresis Thresholding 
Threshold_low = Threshold_low * max(max(gradImax));
Threshold_high = Threshold_high * max(max(gradImax));

%Intalize the zeros and find the maximum in the pixel from each edge
%direction
Threshold_matrix = zeros(weig, knl);

for i = 1  : weig
    for j = 1 : knl
        if (gradImax(i, j) < Threshold_low)
            Threshold_matrix(i, j) = 0;
        elseif (gradImax(i, j) > Threshold_high)
            Threshold_matrix(i, j) = 1;
        %Using 8-connected components
        elseif ( gradImax(i+1,j)>Threshold_high || gradImax(i-1,j)>Threshold_high || GradImax(i,j+1)>Threshold_high || gradImax(i,j-1)> Threshold_high|| gradImax(i-1, j-1)>Threshold_high || gradImax(i-1, j+1)>Threshold_high || gradImax(i+1, j+1)>Threshold_high || gradImax(i+1, j-1)>Threshold_high)
            Threshold_matrix(i,j) = 1;
        end
    end
end
edge_final = uint8(Threshold_matrix.*255);
