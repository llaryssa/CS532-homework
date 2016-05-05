function proj = projectInCamera(cloud, c, focal_length)
    proj = cloud - repmat(c,1,length(cloud));
    proj(1,:) = focal_length*proj(1,:)./proj(3,:);
    proj(2,:) = focal_length*proj(2,:)./proj(3,:);
end
