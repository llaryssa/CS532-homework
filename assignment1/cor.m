function cor (color)
    A = zeros(100,100,3);
    A(:,:,1) = color(1);
    A(:,:,2) = color(2);
    A(:,:,3) = color(3);
    figure, imshow(A);
end