function ptch = showsurface( voxels )
%SHOWSURFACE: draw a surface based on some voxels
%
%   SHOWSURFACE(VOXELS) tries to render the supplied voxel structure as a
%   surface using MATLAB's ISOSURFACE command.
%
%   PTCH = SHOWSURFACE(VOXELS) also returns handles to the patches
%   created.

%   Copyright 2005-2009 The MathWorks, Inc.
%  $Revision: 1.0 $    $Date: 2006/06/30 00:00:00 $

% First grid the data
ux = unique(voxels.x);
uy = unique(voxels.y);
uz = unique(voxels.z);

% Expand the model by one step in each direction
ux = [ux(1)-voxels.res; ux; ux(end)+voxels.res];
uy = [uy(1)-voxels.res; uy; uy(end)+voxels.res];
uz = [uz(1)-voxels.res; uz; uz(end)+voxels.res];

% Convert to a grid
[X,Y,Z] = meshgrid( ux, uy, uz );

% Create an empty voxel grid, then fill only those elements in voxels
V = zeros( size( X ) );
N = numel( voxels.x );
for ii=1:N
    ix = (ux == voxels.x(ii));
    iy = (uy == voxels.y(ii));
    iz = (uz == voxels.z(ii));
    V(iy,ix,iz) = voxels.data(ii);
end

% Now draw it
ptch = patch( isosurface( X, Y, Z, V, 0.5 ) );
isonormals( X, Y, Z, V, ptch )
set( ptch, 'FaceColor', 'g', 'EdgeColor', 'm' );

set(gca,'DataAspectRatio',[1 1 1]);
xlabel('X');
ylabel('Y');
zlabel('Z');
% view(-140,22)
lighting( 'gouraud' )
camlight( 'right' )
% axis( 'tight' )
