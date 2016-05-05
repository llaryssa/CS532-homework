function pp = ajeitar (p)

    for i = 1:length(p)
        pp(:,i) = p(:,i)./p(3,i);
    end

end