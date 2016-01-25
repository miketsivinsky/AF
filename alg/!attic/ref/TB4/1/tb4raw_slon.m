clear classes;
clc;

% %----------------
% % test 1
% i_size = 200;
% a_val = 20000;
% b_val = 50000;
% A = ones(i_size,i_size,3)*a_val;
% A(:,:,1) = 0;
% B = ones(i_size,i_size,3)*b_val;
% B(:,:,2) = 0;
% alpha = ones(i_size,i_size)*0;
% AlphaBlender = video.AlphaBlender('OpacitySource','Input port');
% Y = step(AlphaBlender,A,B,alpha);
% Y = uint16(Y);
% imwrite(Y,'slon.png','Comment','slonick');
% imfinfo('slon.png')
% Z = imread('slon.png');
% hImg = imshow(Z);
% hPixelInfoPanel = impixelinfo(hImg);
% hDrangePanel = imdisplayrange(hImg);
% return;
% %----------------

% %----------------
% % test 2
% a = ones(2,2,3);
% b = ones(2,2)*0.1;
% a.*repmat(b,[1 1 3])
% return
% %----------------

% vidObj = VideoWriter('slon.avi');
% open(vidObj);
% for k = 1:100
%     h = ones(100,100)*(1 - k/100);
%     writeVideo(vidObj,h);
% end
% close(vidObj);

%---
% M = 4; N = 6; Z = 2;
% N2 = N*Z;
% M2 = M*Z;
% 
% A  = floor(rand(M,N)*100);
% RZ = zeros(N,N2);
% 
% h11 = ones(Z,1)*[1:N];
% h1 = reshape(h11, 1, N2)
% h2 = [1:N2];
% LI = sub2ind(size(RZ),h1,h2);
% RZ(LI) = 1;
% 
% LZ = zeros(M,M2);
% h11 = ones(Z,1)*[1:M];
% h1 = reshape(h11, 1, M2)
% h2 = [1:M2];
% LI = sub2ind(size(LZ),h1,h2);
% LZ(LI) = 1;
% LZ = LZ';
% 
% A
% LZ*A*RZ











