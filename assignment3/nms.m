function B = nms(A)

half_nms = 1;

for i = half_nms+1 : size(A,1)-half_nms
    for j = half_nms : size(A,2)-half_nms
%     for j = size(A,2)-half_nms : -1 : half_nms
%         [i j]
        if A(i,j) ~= 0
            window = A(i-half_nms:i+half_nms, j-half_nms:j+half_nms);
            window(2,2) = 0;
            if sum(sum(A(i,j) < window)) == 0
                
            else
                A(i,j) = 0;
            end
        end
    end
end

B = A;
    
end