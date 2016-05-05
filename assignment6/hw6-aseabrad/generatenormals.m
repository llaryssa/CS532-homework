filename = ('gargoyle/gargoyle.ply');
mesh = readply(filename);

nfaces = length(mesh.faces);

normals = Inf(length(mesh.vertices),3);

cnt = 0;

for i = 1:nfaces
    face = mesh.faces(i,:);
    v1 = mesh.vertices(face(2),:) - mesh.vertices(face(1),:);
    v2 = mesh.vertices(face(3),:) - mesh.vertices(face(1),:);
    
    if (norm(cross(v2,v1)) >= 0)
        nn = cross(v2,v1);
        nn = nn./norm(nn);
    else
        nn = cross(v1,v2);
        nn = nn./norm(nn);
        cnt = cnt + 1;
    end
    
    for j = 1:3
        if (isinf(normals(face(j),:)))
            normals(face(j),:) = nn;
        else
            temp = normals(face(j),:) + nn;
            temp = temp./2;
            temp = temp./norm(temp);
            normals(face(j),:) = temp;
        end
    end
end

fid = fopen('normals.txt', 'w');
fprintf(fid, '%f %f %f\n',normals');
fclose(fid);


% writeplynormals(mesh.vertices,normals,(mesh.faces-ones(size(mesh.faces))),'teste3.ply');
