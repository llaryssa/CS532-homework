function spin = computeSpinImage(obj, ptidx, nbins, binsize)
    
    if ptidx == 0
        r1 = 1; r2 = length(obj.vertices);
        ptidx = round((r2-r1)*rand+r1);
%         disp(['point idx is: ' num2str(ptidx)]);
    end
    
    spin = zeros(nbins,nbins);
    norml = obj.normals(ptidx,:);
    
    for pt = 1:length(obj.vertices)
        xp = obj.vertices(pt,:) - obj.vertices(ptidx,:);
        
        beta = sum(norml.*xp,2);
        alpha = sqrt(sum(xp.*xp,2) - beta.^2);
    
        % back to zero
        beta = beta - nbins*binsize/2;
        
        b = floor(-beta/binsize) + 1;
        a = floor(alpha/binsize) + 1;
        
        if a > 0 && b > 0 && a <= nbins && b <= nbins
            spin(a,b) = spin(a,b) + 1;
        end
    end
    
    spin = spin(:)';
end