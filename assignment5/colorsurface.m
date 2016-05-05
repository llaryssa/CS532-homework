function colorsurface( ptch, P,C,N,img)


vertices = get( ptch, 'Vertices' );
normals = get( ptch, 'VertexNormals' );
num_vertices = size( vertices, 1 );

% Get the view vector for each camera
num_cameras = numel(size(P,3));
for ii=1:num_cameras
    cam_normals(:,ii) = N(:,ii);
end

% For each vertex, use the normal to find the best camera and then lookup
% the value.
vertexcdata = zeros( num_vertices, 3 );
for ii=1:num_vertices
    % Use the dot product to find the best camera
    angles = normals(ii,:)*cam_normals./norm(normals(ii,:));
    [~,cam_idx] = min( angles );
    % Now project the vertex into the chosen camera
    
    cam = P(:,:,cam_idx);
    im = img(:,:,:,cam_idx);
    vxp = cam*[vertices(ii,1) vertices(ii,2) vertices(ii,3) 1]';
    imx = ceil(vxp(1)./vxp(3));
    imy = ceil(vxp(2)./vxp(3));

    vertexcdata(ii,:) = double(im(round(imy),round(imx),:) )/255;
end

% Set it into the patch
set( ptch, 'FaceVertexCData', vertexcdata, 'FaceColor', 'interp' );