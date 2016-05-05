function d = ddist(vox, c)
%     c = c(1:3)';
%     vv = vox - repmat(c,size(vox,1),1);
%     vv = vv.^2;
%     vv = sum(vv,2);
%     d = sqrt(vv);

    d = vox.*repmat(c', size(vox,1),1);
    d = sum(d,2);

end

