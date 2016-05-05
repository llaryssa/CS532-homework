function obj = readply(filename)
    file = fopen(filename, 'rt');
    
    fgetl(file);
    fgetl(file);
    fgetl(file);
    
    nvert = fgetl(file);
    idx1 = find(nvert==' ');
    nvert = str2double(nvert(idx1(end):end));
    
    fgetl(file);
    fgetl(file);
    fgetl(file);
    
    prop = fgetl(file);
    idxp = find(prop==' ');
    prop = prop(idxp(end)+1:end);
    if strcmp(prop,'confidence')
        flagnormals = false;
        fgetl(file);
    elseif strcmp(prop,'intensity')
        flagnormals = false;
    elseif strcmp(prop,'nx')
        flagnormals = true;
        fgetl(file);
        fgetl(file);
    else
        flagnormals = false;
    end
        
        
    nface = fgetl(file);
    idx2 = find(nface==' ');
    nface = str2double(nface(idx2(end):end));
    
    fgetl(file);
    fgetl(file);
    
    if flagnormals
        for i = 1:nvert
            buff = fscanf(file,'%f',[1 6]);
            pts(i,:) = buff(1:3);
            normals(i,:) = buff(4:6);
        end  
    else
        for i = 1:nvert
            buff = fscanf(file,'%f',[1 4]);
            pts(i,:) = buff(1:3);
        end
        normals = [];   
    end
    
    fac = [];
    for i = 1:nface
        count = fscanf(file,'%d',1);
        buff = fscanf(file,'%d',[1 count]);
        fac(i,:) = buff+1;  % count 0 in ply file
    end
    
    obj.vertices = pts;
    obj.faces = fac;
    obj.normals = normals;
    
end

