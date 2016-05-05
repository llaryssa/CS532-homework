function spin = computeSpinImage(obj, ptidx, nbins, binsize)
    
    if ptidx == 0
        r1 = 1; r2 = length(obj.vertices);
        ptidx = round((r2-r1)*rand+r1);
        disp(['point idx is: ' num2str(ptidx)]);
    end

    normals = -obj.normals;
    pts = obj.vertices;
    
    xp = pts - repmat(pts(ptidx,:),length(pts),1);
    
    beta = sum(normals.*xp,2);
    alpha = sqrt(sum(xp.*xp,2) - beta.^2);
    
    i = floor((nbins/2 - beta)./binsize);
    j = floor(alpha./binsize);
    
    idx = j >= 1 & j <= nbins-1 & i >= 1 & i <= nbins-1;
    
    a = alpha(idx) - i(idx)*binsize;
    b = beta(idx) - j(idx)*binsize;
    i = i(idx);
    j = j(idx);
       
    spin = zeros(nbins,nbins);
    
    for k = 1:length(i)
       spin(i(k),j(k)) = spin(i(k),j(k)) + (1-a(k))*(1-b(k));
       spin(i(k)+1,j(k)) = spin(i(k)+1,j(k)) + a(k)*(1-b(k));
       spin(i(k),j(k)+1) = spin(i(k),1+j(k)) + (1-a(k))*b(k);
       spin(i(k)+1,j(k)+1) = spin(i(k)+1,j(k)+1) + a(k)*b(k);
    end 
    
    spin = spin(:)';
end