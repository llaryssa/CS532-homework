clc; clear all;

lft = double(imread('teddyL.pgm'));
rgt = double(imread('teddyR.pgm'));

height = size(lft, 1);
width  = size(lft, 2);

deriv = [-1 0 1
         -1 0 1
         -1 0 1];
     
lIx = conv2(lft, deriv, 'same');
lIy = conv2(lft, deriv', 'same');
rIx = conv2(rgt, deriv, 'same');
rIy = conv2(rgt, deriv', 'same');

% Ix = zeros(size(lft));
% Iy = zeros(size(lft));
% for i = 2:height-1
%     for j = 2:width-1
%         window = lft(i-1:i+1, j-1:j+1);
%         Ix(i,j) = sum(window(:,3) - window(:,1));
%         Iy(i,j) = sum(window(3,:) - window(1,:));             
%     end
% end

lIxy = lIx.*lIy;
rIxy = rIx.*rIy;

% % % mean filter
% win_filter = 5;
% half_filter = (win_filter - 1)/2;
% filtered = zeros(size(lft));
% for i = win_filter:height-win_filter
%     for j = win_filter:width-win_filter
%         window = lft(i-half_filter:i+half_filter, j-half_filter:j+half_filter);     
%        	filtered(i,j) = uint8(sum(sum(window))/(win_filter*win_filter));
%     end
% end

win_gauss = 5;
half_gauss = (win_gauss - 1)/2;
sig = 1.5;
[x,y] = meshgrid(-half_gauss:half_gauss, -half_gauss:half_gauss);
G = exp(-(x.^2 + y.^2)/(2*sig^2));
G = G./sum(G(:));

lIx2g = conv2(lIx.^2, G, 'same');
lIy2g = conv2(lIy.^2, G, 'same');
lIxyg = conv2(lIxy, G, 'same');

rIx2g = conv2(rIx.^2, G, 'same');
rIy2g = conv2(rIy.^2, G, 'same');
rIxyg = conv2(rIxy, G, 'same');

win_harris = 5; % Matlab default
half_harris = (win_harris - 1)/2;
thresh = 120000;

flft = zeros(size(lft));
frgt = zeros(size(rgt));

for i = half_harris+1:height-half_harris-1
    for j = half_harris+1:width-half_harris-1
        lSx2 = sum(sum(lIx2g(i-half_harris:i+half_harris, j-half_harris:j+half_harris)));
        lSy2 = sum(sum(lIy2g(i-half_harris:i+half_harris, j-half_harris:j+half_harris))); 
        lSxy = sum(sum(lIxyg(i-half_harris:i+half_harris, j-half_harris:j+half_harris)));
        flft(i,j) = (lSx2*lSy2 - lSxy*lSxy)/(lSx2+lSy2);
        
        rSx2 = sum(sum(rIx2g(i-half_harris:i+half_harris, j-half_harris:j+half_harris)));
        rSy2 = sum(sum(rIy2g(i-half_harris:i+half_harris, j-half_harris:j+half_harris))); 
        rSxy = sum(sum(rIxyg(i-half_harris:i+half_harris, j-half_harris:j+half_harris)));
        frgt(i,j) = (rSx2*rSy2 - rSxy*rSxy)/(rSx2+rSy2);   
    end
end

flft(flft < thresh) = 0;
frgt(frgt < thresh) = 0;

cnt1 = 1;
cnt2 = 1;

half_nms = 1;

% non max suppresion, 3x3 window
for i = half_nms+1:size(lft,1)-half_nms-1
    for j = size(lft,2)-half_nms-1:-1:half_nms+1
%     for j = half_nms+1:size(lft,2)-half_nms-1
        if flft(i,j) ~= 0
            window = flft(i-half_nms:i+half_nms, j-half_nms:j+half_nms);
            if sum(sum(flft(i,j) < window)) == 0
                corlft(cnt1,:) = [flft(i,j) i j];
                cnt1 = cnt1+1;
            else
                flft(i,j) = 0;
            end
        end
        
        if frgt(i,j) ~= 0
            window = frgt(i-half_nms:i+half_nms, j-half_nms:j+half_nms);
            if sum(sum(frgt(i,j) < window)) == 0
                corrgt(cnt2,:) = [frgt(i,j) i j];
                cnt2 = cnt2+1;
            else
                frgt(i,j) = 0;
            end
        end
    end
end

% figure;
% subplot(1,2,1), subimage(lft, [min(lft(:)) max(lft(:))]);
% hold on; scatter(corlft(:,3), corlft(:,2), 'MarkerFaceColor', 'y');
% subplot(1,2,2), subimage(rgt, [min(rgt(:)) max(rgt(:))]);
% hold on; scatter(corrgt(:,3), corrgt(:,2), 'MarkerFaceColor', 'y');

im = [lft rgt];
ff = figure;
imshow(im, [min(im(:)) max(im(:))]);
hold on; scatter(corlft(:,3), corlft(:,2), 'MarkerFaceColor', 'm');
hold on; scatter(width+corrgt(:,3), corrgt(:,2), 'MarkerFaceColor', 'g');

disp('number of corners:')
disp(length(corlft))
disp(length(corrgt))

cnt = 1;

half_sad = 1;
% SAD 3x3 ?????
for i = 1:length(corlft)
    for j = 1:length(corrgt)
            xl = corlft(i,2);
            yl = corlft(i,3);
            xr = corrgt(j,2);
            yr = corrgt(j,3);
            windowl = lft(xl-half_sad:xl+half_sad, yl-half_sad:yl+half_sad);
            windowr = rgt(xr-half_sad:xr+half_sad, yr-half_sad:yr+half_sad);
            if (xl==xr)
                aa = yl-yr; % have to save this so I can compare with groundtruth
            else
                aa = Inf;
            end
            distances(cnt,:) = [sum(sum(abs(windowl-windowr))) aa i j];
            cnt = cnt+1;
    end
end

for k = 5:5:5

    n = ceil((k/100)*length(distances));
    dd = sortrows(distances);
    dd = dd(1:n,:);


    XX = [corlft(dd(:,3),2)'; corrgt(dd(:,4),2)'];
    YY = [corlft(dd(:,3),3)'; width+corrgt(dd(:,4),3)'];
    figure(ff); hold on;
    line(YY(:,1:25),XX(:,1:25), 'Color', [1 0 0]);

    gt = imread('disp2.pgm');
    gt = ceil(double(gt)./4);

    correct = 0;

    for i = 1:length(dd)
        d = dd(i,4);
        dgt = gt(corlft(dd(i,3),2), corlft(dd(i,3),3));

        if abs(d-dgt) <= 1
            correct = correct + 1;
        end
    end

    % disp('error rate:');
    % disp([1 - correct/length(dd)]);
    % disp('correct/wrong correspondences: ')
    % disp([correct length(dd)-correct])

    disp(['\item{' num2str(k) '\% most likely correspondences} \\ Correct: ' ...
        num2str(correct) '\\ Wrong: ' num2str(length(dd)-correct)])

end

