f = 1;
A = magic(5);
A = A(:);
while f <= length(A)
    if (A(f) < 10)
        A(f) = [];
    else
        f = f+1;
    end
end