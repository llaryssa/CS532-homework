function writeply(points, rgb, filename)

    file = fopen(filename,'w');
    
    text = sprintf(['ply\n' ...
                    'format ascii 1.0\n' ...
                    'element vertex %s\n' ...
                    'property float x\n' ...
                    'property float y\n' ...
                    'property float z\n' ...
                    'property uchar red\n' ...
                    'property uchar green\n' ...
                    'property uchar blue\n' ...
                    'element face 0\n'...
                    'end_header\n'], num2str(size(points,1)));
     fprintf(file, text);
     
     data = [points round(rgb)];
%      ss = sprintf('%f %f %f %f %f %f\n', data);
     dlmwrite(filename,num2str(data),'-append','delimiter','')
%      fprintf(file, num2str(data));
     
     fclose(file);
%      dlmwrite(filename,[points double(rgb)],'-append','delimiter','\t','precision','%.4f')
end