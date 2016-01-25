%--------------------------------------------------------------------------
function [rgb_frame] = make_rgb_frame(VSync, HSync, PixelData)

PixScale = 64;  % (6 bit shift)
                % because we have 10 bit per channel in input (DAC)
                % and 16 bit per channel in output (Matlab)
FrameSize = size(VSync);
rgb_frame = uint16(zeros([FrameSize 3]));

VSyncRGB = uint16(zeros([FrameSize 3]));
HSyncRGB = uint16(zeros([FrameSize 3]));

%-----------------------------------
VSyncRedChannel   = 0;
VSyncGreenChannel = 50000;
VSyncBlueChannel  = 0;

VSyncRGB(:,:,1) = uint16(VSync*VSyncRedChannel);
VSyncRGB(:,:,2) = uint16(VSync*VSyncGreenChannel);
VSyncRGB(:,:,3) = uint16(VSync*VSyncBlueChannel);

%-----------------------------------
HSyncRedChannel   = 0;
HSyncGreenChannel = 0;
HSyncBlueChannel  = 50000;

HSyncRGB(:,:,1) = uint16(HSync*HSyncRedChannel);
HSyncRGB(:,:,2) = uint16(HSync*HSyncGreenChannel);
HSyncRGB(:,:,3) = uint16(HSync*HSyncBlueChannel);

rgb_frame = rgb_frame + HSyncRGB + VSyncRGB + uint16(PixelData*PixScale);