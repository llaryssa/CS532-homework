function [disparity,cost] = stereoMatching(lft,rgt, min_disp, max_disp, rank, window)
    height = size(lft, 1);
    width  = size(lft, 2);
    
    if rank > 0    
        rnklft = zeros(size(lft));
        rnkrgt = zeros(size(rgt));
        half_rnk = (rank-1)/2;

        for i = rank:height-rank
            for j = rank:width-rank  % all pixels       
                lims = [max(1,i-half_rnk); min(height, i+half_rnk);
                       max(1,j-half_rnk); min(width, j+half_rnk)];
                lftwin = double(lft(lims(1):lims(2), lims(3):lims(4)));
                rnklft(i,j) = sum(sum(lftwin < lft(i,j)));

                rgtwin = double(rgt(lims(1):lims(2), lims(3):lims(4)));
                rnkrgt(i,j) = sum(sum(rgtwin < rgt(i,j)));
            end
        end
    else
        rnklft = lft;
        rnkrgt = rgt;
    end
    
    half_win = (window-1)/2;
    disparity = ones(size(lft));
    cost = Inf(size(lft));

    for i = window:height-window
        for j = window:width-window  % all pixels
           curr_min_disp = inf(1,max_disp-min_disp+1);
           for d = min_disp:max_disp  % all disparities
               if (j-half_win-d) > 0
                    sumwin = sum(sum( ...
                        abs(double(rnklft(i-half_win:i+half_win,j-half_win:j+half_win)) - ...
                           double(rnkrgt(i-half_win:i+half_win,j-half_win-d:j+half_win-d)) ...
                             )));
                    curr_min_disp(d+1) = sumwin;
               else
                   break; % exit the for loop
               end
           end
           [c1, idx] = min(curr_min_disp);
           cost(i,j) = c1;
           disparity(i,j) = idx-1;
           
        end
    end
end

