%--------------------------------------------------------------------------
function  [I_frameRGB,I_frameAlpha] = tb4raw_GenI_frame(rawFrame)

I_frameAlpha = I_AlphaChannel(rawFrame);
I_frameRGB   = I_RGB(rawFrame);

%--------------------------------------------------------------------------
function  I_pixAlpha = I_AlphaChannel(I_pix)

PIX_COLOR_MASK = 15;  % 4'b1111
ALPHA_BIT_MASK = 128; % 8'b1000_0000

[rows cols] = size(I_pix);
pixClass    = class(I_pix);

I_pixAlpha = ones(rows, cols)*0.5; % semi-transparent by default

PixColorCode = bitand(I_pix, ones(rows, cols, pixClass)*PIX_COLOR_MASK);
AlphaMask    = bitand(I_pix, ones(rows, cols, pixClass)*ALPHA_BIT_MASK);

I_pixAlpha(AlphaMask == 0)    = 1.0;    % not-transparent
I_pixAlpha(PixColorCode == 0) = 0.0;    % full-transparent

%--------------------------------------------------------------------------
function  I_pixRGB = I_RGB(I_pix)

MAX_PIX_VALUE      = 1.0;
PIX_COLOR_MASK     = 15;  % 4'b1111
PIX_INTENSITY_MASK = 112; % 6'b1110000;
PIX_INTENSITY_DIV  = 16;

[rows cols] = size(I_pix);
pixClass    = class(I_pix);

I_pixIntensity = double(bitand(I_pix, ones(rows, cols, pixClass)*PIX_INTENSITY_MASK))/PIX_INTENSITY_DIV;
I_pixIntensityNZ_idx = (I_pixIntensity ~= 0);
I_pixIntensity(I_pixIntensityNZ_idx) = (I_pixIntensity(I_pixIntensityNZ_idx) + 1)/8;
I_pixColorIdx = bitand(I_pix, ones(rows, cols, pixClass)*PIX_COLOR_MASK);


I_pixRed   = zeros(rows, cols);
I_pixGreen = zeros(rows, cols);
I_pixBlue  = zeros(rows, cols);

%  1 - red
I_pixRed(I_pixColorIdx == 1)    = MAX_PIX_VALUE;           
% G
% B

%  2 - green
% R
I_pixGreen(I_pixColorIdx == 2)  = MAX_PIX_VALUE;           
% B

%  3 - blue
% R
% G
I_pixBlue(I_pixColorIdx == 3)   = MAX_PIX_VALUE;           

%  4 - yellow
I_pixRed(I_pixColorIdx == 4)    = MAX_PIX_VALUE;           
I_pixGreen(I_pixColorIdx == 4)  = MAX_PIX_VALUE;
% B

%  5 - magenta
I_pixRed(I_pixColorIdx == 5)    = MAX_PIX_VALUE;
% G
I_pixBlue(I_pixColorIdx == 5)   = MAX_PIX_VALUE;           

%  6 - cyan
% R
I_pixGreen(I_pixColorIdx == 6)  = MAX_PIX_VALUE;           
I_pixBlue(I_pixColorIdx == 6)   = MAX_PIX_VALUE;           

%  7 - white
I_pixRed(I_pixColorIdx == 7)    = MAX_PIX_VALUE;           
I_pixGreen(I_pixColorIdx == 7)  = MAX_PIX_VALUE;           
I_pixBlue(I_pixColorIdx == 7)   = MAX_PIX_VALUE;           

%  8 - light brown
I_pixRed(I_pixColorIdx == 8)    = MAX_PIX_VALUE;           
I_pixGreen(I_pixColorIdx == 8)  = MAX_PIX_VALUE/2;         
% B

%  9 - dark pink
I_pixRed(I_pixColorIdx == 9)    = MAX_PIX_VALUE;
% G
I_pixBlue(I_pixColorIdx == 9)   = MAX_PIX_VALUE/2;         

% 10 - dark blue
% R
I_pixGreen(I_pixColorIdx == 10) = MAX_PIX_VALUE/2;         
I_pixBlue(I_pixColorIdx == 10)  = MAX_PIX_VALUE;           

% 11 - purple
I_pixRed(I_pixColorIdx == 11)   = MAX_PIX_VALUE/2;         
% G
I_pixBlue(I_pixColorIdx == 11)  = MAX_PIX_VALUE;           

% 12 - acid
I_pixRed(I_pixColorIdx == 12)   = MAX_PIX_VALUE/2;         
I_pixGreen(I_pixColorIdx == 12) = MAX_PIX_VALUE;
% B

% 13 - light green
% R
I_pixGreen(I_pixColorIdx == 13) = MAX_PIX_VALUE;           
I_pixBlue(I_pixColorIdx == 13)  = MAX_PIX_VALUE/2;         

I_pixRGB = cat(3, I_pixRed, I_pixGreen, I_pixBlue);

I_pixRGB = I_pixRGB.*repmat(I_pixIntensity, [1 1 3]);

%--------------------------------------------------------------------------
% function  I_pixAlpha = I_AlphaChannelPixel(I_pix)
% 
% PIX_COLOR_MASK = 15;  % 4'b1111
% ALPHA_BIT_MASK = 128; % 8'b1000_0000
% 
% if(bitand(I_pix, PIX_COLOR_MASK) == 0)
%     I_pixAlpha = 0; % full-transparent
%     return;
% end    
% 
% if(bitand(I_pix, ALPHA_BIT_MASK))
%     I_pixAlpha = 0.5; % semi-transparent
% else    
%     I_pixAlpha = 1.0; % not-transparent
% end    

%--------------------------------------------------------------------------
% function  I_pixRGB = I_RGB_Pixel(I_pix)
% 
% MAX_PIX_VALUE      = 1.0;
% PIX_COLOR_MASK     = 15;  % 4'b1111
% PIX_INTENSITY_MAX  = 112; % 6'b1110000;
% PIX_INTENSITY_DIV  = 16;
% 
% I_pixIntensity = double(bitand(I_pix, PIX_INTENSITY_MAX))/PIX_INTENSITY_DIV;
% 
% if(I_pixIntensity == 0)
%     I_pixRGB = [0 0 0];
%     return;
% end
% 
% I_pixColorIdx = bitand(I_pix, PIX_COLOR_MASK);
% switch I_pixColorIdx
%     case 0 
%         I_pixRGB = [              0               0               0]; % transparent (!), see I_AlphaChannel function
%     case 1 
%         I_pixRGB = [  MAX_PIX_VALUE               0               0]; % red
%     case 2 
%         I_pixRGB = [              0   MAX_PIX_VALUE               0]; % green
%     case 3 
%         I_pixRGB = [              0               0   MAX_PIX_VALUE]; % blue
%     case 4 
%         I_pixRGB = [  MAX_PIX_VALUE   MAX_PIX_VALUE               0]; % yellow
%     case 5 
%         I_pixRGB = [  MAX_PIX_VALUE               0   MAX_PIX_VALUE]; % magenta
%     case 6 
%         I_pixRGB = [              0   MAX_PIX_VALUE   MAX_PIX_VALUE]; % cyan
%     case 7 
%         I_pixRGB = [  MAX_PIX_VALUE   MAX_PIX_VALUE   MAX_PIX_VALUE]; % white
%     case 8 
%         I_pixRGB = [  MAX_PIX_VALUE MAX_PIX_VALUE/2               0]; % light brown
%     case 9 
%         I_pixRGB = [  MAX_PIX_VALUE               0 MAX_PIX_VALUE/2]; % dark pink
%     case 10 
%         I_pixRGB = [              0 MAX_PIX_VALUE/2   MAX_PIX_VALUE]; % dark blue
%     case 11 
%         I_pixRGB = [MAX_PIX_VALUE/2               0   MAX_PIX_VALUE]; % purple
%     case 12 
%         I_pixRGB = [MAX_PIX_VALUE/2   MAX_PIX_VALUE               0]; % acid
%     case 13 
%         I_pixRGB = [              0   MAX_PIX_VALUE MAX_PIX_VALUE/2]; % light green
%     case 14 
%         I_pixRGB = [              0               0               0]; % reserved
%     case 15 
%         I_pixRGB = [              0               0               0]; % reserved
%     otherwise    
%         I_pixRGB = [0 0 0];
% end    
% 
% I_pixIntensity = (I_pixIntensity + 1)/8;
% I_pixRGB = I_pixRGB*I_pixIntensity;
