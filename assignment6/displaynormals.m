function fig = displaynormals(vertices, faces, normals)

    fig = figure;
    scatter3(vertices(:,1), vertices(:,2), vertices(:,3), '.', 'g');
    hold on;
    quiver3(vertices(:,1), vertices(:,2), vertices(:,3),...
            normals(:,1), normals(:,2), normals(:,3));
    set(gca, 'DataAspectRatio', [1 1 1]);

end

