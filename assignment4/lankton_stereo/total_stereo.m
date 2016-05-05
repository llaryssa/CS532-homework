%-----------------------------------------------------------------
% function [dsp pixel_dsp segs labels] = total_stereo...
%          (i1,i2, hs,hr,M,mins, maxs, segs, labels)
%
% A first take at 3D from stereo.  This function takes a stereo pair
% (that should already be registered so the only difference is in the
% 'x' dimension), and produces a 'disparity map.'  The output here is
% pixel disparity, which can be converted to actual distance from the
% cameras if information about the camera geometry is known.
% 
% The output here does show which objects are closer and 'segments'
% by distance to camera.
%
% EXAMPLE:
% i1 = imread('tsuL.jpg');
% i2 = imread('tsuR.jpg');
% [d p s l] = total_stereo(i1,i2,10,7,30,1,20);
%
% dsp       = final disparity map
% pixel_dsp = pixel disparities before final filtering
% segs      = segmented image from msseg
% labels    = labemap from msseg
%
% i1     = right image
% i2     = left image
% hs     = spacial bandwidth (for msseg)      (usually 10)
% hr     = range(color) bandwidth (for msseg) (usually 7)
% M      = minimum segment size (for msseg)   (usually 30)
% mins   = minimum shift                      (usually 1)
% maxs   = maximum shift                      (depends on images)
% segs   = segments (if you have them pre-computed)
% labels = labelmap (if you have it pre-computed)
%
% Algorithm adapted from: "Segment-Based Stereo Matching Using 
% Belief Propogation and Self-Adapting Dissimilarity Measure" by
% Klaus, Sormann, and Karner.
% 
% (The algorithm in the paper is better, and more complete.  The
% codes here are inspired by these guys, and parts are original)
%
% Coded by Shawn Lankton (http://www.shawnlankton.com) Dec. 2007
%-----------------------------------------------------------------


function [dsp pixel_dsp segs labels] = total_stereo...
         (i1,i2, hs,hr,M,mins, maxs, segs, labels)
  
  win_size = 5;  %-- larger for less textured surfaces
  tolerance = 0; %-- larger for less textured surfaces
  
  [dimy dimx c] = size(i1);
  [xx yy] = meshgrid(1:size(i1,2),1:size(i1,1));
  
  dsp  = ones(size(i1,1),size(i1,2));
  
  %--segment reference image
  if(nargin<9)
    [segs labels] = msseg(i1,hs,hr,M);  %-- mean shift segmentation
  end
  
  %--determine pixel correspondence Right-to-Left
  [disparity1 mindiff1] = slide_images(i1,i2, mins, maxs, win_size);

  %--determine pixel correspondence Left-to-Right
  [disparity2 mindiff2] = slide_images(i2,i1, -mins, -maxs, win_size);
  disparity2 = abs(disparity2); %-- disprities will be negative

  %--create high-confidence disparity map
  pixel_dsp = winner_take_all(disparity1, mindiff1, disparity2, mindiff2);

  %--filter with segmented image
  for(i = 0:length(unique(labels))-1)
    lab_idx = find((labels == i));
    inf_idx = find(labels == i & pixel_dsp<inf);
    dsp(lab_idx) = median(pixel_dsp(inf_idx));
  end
  
  %--I think this looks cleaner, but it doesn't really serve a purpose
  pixel_dsp(pixel_dsp==inf)=NaN;

  
%%----- HELPER FUNCTIONS

%-- slides images across each other to get disparity estimate
function [disparity mindiff] = slide_images(i1,i2,mins,maxs,win_size)
  [dimy,dimx,c] = size(i1);
  disparity = zeros(dimy,dimx);     %-- init outputs
  mindiff = inf(dimy,dimx);    
  w = 5;                            %-- weight of CSAD vs CGRAD
  hx = [-1 0 1]; hy = [-1 0 1]';    %-- gradient filter
  h = 1/win_size.^2*ones(win_size); %-- averaging filter

  g1x = sum(imfilter(i1,hx).^2,3);  %-- get gradient for each image
  g1y = sum(imfilter(i1,hy).^2,3);  %-- used to compute CGRAD
  g2x = sum(imfilter(i2,hx).^2,3);
  g2y = sum(imfilter(i2,hy).^2,3);
  
  step = sign(maxs-mins);             %-- adjusts to reverse slide
  for(i=mins:step:maxs)
    s  = shift_image(i2,i);         %-- shift image and derivs
    sx = shift_image(g2x,i);
    sy = shift_image(g2y,i);

    %--CSAD  is Cost from Sum of Absolute Differences
    %--CGRAD is Cost from Gradient of Absolute Differences
    diffs = sum(abs(i1-s),3);       %-- get CSAD and CGRAD
    CSAD  = imfilter(diffs,h);
    gdiff = w * (sum(abs(g1x-sx),3)+sum(abs(g1y-sy),3));
    CGRAD = imfilter(gdiff,h);
    d = CSAD+CGRAD;                 %-- total 'difference' score
    
    idx = find(d<mindiff);          %-- put corresponding disarity
    disparity(idx) = i;             %   into correct place in image
    mindiff(idx) = d(idx);
  end
  
%-- reconsiles two noisy disparity estimates
function [pd] = winner_take_all(d1,m1,d2,m2,tolerance)
  if(~exist('tolerance','var')) tolerance = 0; end
  [dimy dimx] = size(d1);
  d3 = zeros(size(d1));
  m3 = zeros(size(d1));

  %-- scoot L-R disparity (this should make disprities line up
  %   between the refernce image(left) and the other image(right)
  for(i=1:max(d2(:)))               
    [yy xx] = find(d2==i);          %-- get all disprities 'i'
    idx2 = sub2ind([dimy, dimx],yy,xx); 
    xx = xx+i-1;                    %-- figure out new position
    xx(xx>dimx)=dimx;               %-- check boundary
    idx3 = sub2ind([dimy dimx],yy,xx);
    d3(idx3)=d2(idx2);              %-- move disparities and
    m3(idx3)=m2(idx2);              %-- diffs to the right spot
  end

  %-- keep the best ones and mark the bad ones
  pd = d3;                          %-- start with shifted L-R
  idx = find(m1<m3);                %-- find where m1 is better
  pd(idx) = d1(idx);                %-- use disp from R-L there
  diff(idx) = m1(idx);              %-- use L-R mindiff's too
  idx = find(m1==m3);               %-- find where its a tie
  pd(idx) = round(d1(idx)+d3(idx))/2; %-- split the difference
  
  pd(abs(d1-d3)>tolerance) = inf;   %-- mark points that are 
                                    %   likley wrong

%-- Shift an image
function I = shift_image(I,shift)
  dimx = size(I,2);
  if(shift > 0)
    I(:,shift:dimx,:) = I(:,1:dimx-shift+1,:);
    I(:,1:shift-1,:) = 0;
  else 
    if(shift<0)
      I(:,1:dimx+shift+1,:) = I(:,-shift:dimx,:);
      I(:,dimx+shift+1:dimx,:) = 0;
    end  
  end
  
  
  
