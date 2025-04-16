function [X,Y] = ang2pix(angX,angY,edf)
% calculate the visual angle at x,y dimension separately between a dot and
% the x,y axis
% By: Linjing Jiang
% Date: 11/08/18
% Contact: linjing.jiang@stonybrook.edu

% Input: disp
   % disp.dist = distance from the screen center to the eye (in cm)
   % disp.parameter = [width height] (width or height of the screen in cm)
   % disp.res = [xResolution yResolution] (horizontal or vertical 
   % resolution of the display)
   % pixel = [xPixel yPixel;....] (pixels in x and y axis for
   % many pairs of two dots
   
% Output
   % ang = [angX,angY;...];
   
% Example
% disp.dist = 50;
% disp.parameter = [30 40];
% disp.res = [1024 768]
% pixel = [0 0 500 500]
% ang = pix2ang(disp,pixel)


   % actual size (cm) per pixel
   xSzPerPix = edf.screen.w/edf.screen.xres;
   ySzPerPix = edf.screen.h/edf.screen.yres;
   
xSz = tand(angX)*edf.screen.d;
ySz = tand(angY)*edf.screen.d;

X = xSz/xSzPerPix + edf.screen.xres/2;
Y = ySz/ySzPerPix + edf.screen.yres/2;

end


