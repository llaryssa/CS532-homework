clear all; clc;
n = 10;
points = [10*rand(1,n); 10*rand(1,n)];
points0 = points;

figure,
scatter(points(1,:), points(2,:), '.', 'r');
set(gca, 'DataAspectRatio', [1 1 1]);
hold on;

[~,minidx] = min(points(2,:));

p0 = [-10; points(2,minidx)];

% scatter(p0(1), p0(2), '*', 'm');
scatter(points(1,minidx), points(2,minidx), '*', 'm');

final = [p0 points(:,minidx)];

for i = 1:length(points)
    if ~ismember(points(:,i), final)
        a = final(:,end-1);
        b = final(:,end);
        c = points(:,i);        
        mat = [1 a'; 1 b'; 1 c'];
        if det(mat) > 0
            if ismember(p0,final)
                final = final(:,2:end);
            end
            final(:,2) = points(:,i);
        end
    end
end

% plotting p1 to p2
a = final(:,end-1);
b = final(:,end);
plot([a(1) b(1)], [a(2) b(2)], 'm');


final(:,3) = points(:,1);

u = a - b;
for i = 1:length(points)
    if ~ismember(points(:,i), final)
        a = final(:,end-1);
        b = final(:,end);
        c = points(:,i);
       
        pl1 = plot([b(1) a(1)], [b(2) a(2)]);
        pl2 = plot([b(1) c(1)], [b(2) c(2)]);
        
        mat = [1 a'; 1 b'; 1 c'];
        if det(mat) < 0
            final(:,3) = points(:,i);
        end
        
        delete(pl1); delete(pl2);
    end
end

a = final(:,end);
b = final(:,end-1);
pl = plot([a(1) b(1)], [a(2) b(2)], 'm');


