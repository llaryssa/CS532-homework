function normals = estimateNormals(obj, sig, k)

    den = 2 * sig^2;

    pts = obj.vertices;
    [idx,dist] = knnsearch(pts, pts, 'k', k);

    normals = [];
    for i = 1:length(pts)
        % compute centroid
        centr = mean(pts(idx(i,:),:));
        % init weights
        w = exp(-dist.^2./den);
        cc = zeros(3,3);
        for j = 1:k
            xj = pts(idx(i,j),:);
            cc = cc + (xj - centr)' * (xj - centr) .* w(i,j);        
        end
        C = cc./sum(w(i,:));
        [V,~] = eig(C);
        normals(i,:) = V(:,1)';
    end

    flip = sign(dot(normals',-pts'))';
    normals = [flip flip flip].*normals;
end
