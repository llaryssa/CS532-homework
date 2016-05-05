clear all;
clc;

k = 50;
sig = 20;
knn = 30;

ap1 = readply('hw7/apple_1.ply');
ap2 = readply('hw7/apple_2.ply');
ap3 = readply('hw7/apple_3.ply');
ap4 = readply('hw7/apple_4.ply');

ban1 = readply('hw7/banana_1.ply');
ban2 = readply('hw7/banana_2.ply');
ban3 = readply('hw7/banana_3.ply');
ban4 = readply('hw7/banana_4.ply');

lem1 = readply('hw7/lemon_1.ply');
lem2 = readply('hw7/lemon_2.ply');
lem3 = readply('hw7/lemon_3.ply');
lem4 = readply('hw7/lemon_4.ply');

ap1.normals = estimateNormals(ap1, sig, k);
ap2.normals = estimateNormals(ap2, sig, k);
ap3.normals = estimateNormals(ap3, sig, k);
ap4.normals = estimateNormals(ap4, sig, k);

ban1.normals = estimateNormals(ban1, sig, k);
ban2.normals = estimateNormals(ban2, sig, k);
ban3.normals = estimateNormals(ban3, sig, k);
ban4.normals = estimateNormals(ban4, sig, k);

lem1.normals = estimateNormals(lem1, sig, k);
lem2.normals = estimateNormals(lem2, sig, k);
lem3.normals = estimateNormals(lem3, sig, k);
lem4.normals = estimateNormals(lem4, sig, k);

train = [];
test = [];

cnt = 1;

for i = 1:30
%    spap1(:,:,i) = computeSpinImage(ap1, 0, 11, 3);
%    spap2(:,:,i) = computeSpinImage(ap2, 0, 11, 3);
%    spap3(:,:,i) = computeSpinImage(ap3, 0, 11, 3);
%    spap4(:,:,i) = computeSpinImage(ap4, 0, 11, 3);
%    spban1(:,:,i) = computeSpinImage(ban1, 0, 11, 3);
%    spban2(:,:,i) = computeSpinImage(ban2, 0, 11, 3); 
%    spban3(:,:,i) = computeSpinImage(ban3, 0, 11, 3); 
%    spban4(:,:,i) = computeSpinImage(ban4, 0, 11, 3); 
%    splem1(:,:,i) = computeSpinImage(lem1, 0, 11, 3); 
%    splem2(:,:,i) = computeSpinImage(lem2, 0, 11, 3);
%    splem3(:,:,i) = computeSpinImage(lem3, 0, 11, 3);
%    splem4(:,:,i) = computeSpinImage(lem4, 0, 11, 3);
   
   train(cnt, :) = [1 computeSpinImage(ap1, 0, 11, 3)];
   train(cnt+1, :) = [1 computeSpinImage(ap2, 0, 11, 3)];
   train(cnt+2, :) = [2 computeSpinImage(ban1, 0, 11, 3)];
   train(cnt+3, :) = [2 computeSpinImage(ban2, 0, 11, 3)];
   train(cnt+4, :) = [3 computeSpinImage(lem1, 0, 11, 3)];
   train(cnt+5, :) = [3 computeSpinImage(lem2, 0, 11, 3)];
   
   test(cnt, :) = [1 computeSpinImage(ap3, 0, 11, 3)];
   test(cnt+1, :) = [1 computeSpinImage(ap4, 0, 11, 3)];
   test(cnt+2, :) = [2 computeSpinImage(ban3, 0, 11, 3)];
   test(cnt+3, :) = [2 computeSpinImage(ban4, 0, 11, 3)];
   test(cnt+4, :) = [3 computeSpinImage(lem3, 0, 11, 3)];
   test(cnt+5, :) = [3 computeSpinImage(lem4, 0, 11, 3)];
   
   cnt = cnt+6; 
end

train_lbl = train(:,1);
train_data = train(:,2:end);

test_lbl = test(:,1);
test_data = test(:,2:end);

correct = 0;

for i = 1:size(test,1)
    sample = test_data(i,:);
    idx = knnsearch(train_data, sample, 'K', knn); 
    votes = zeros(3,1);
    for j = 1:knn
       votes(train_lbl(idx(j))) = votes(train_lbl(idx(j))) + 1;
    end
    [~,lbl] = max(votes);
    
    if lbl == test_lbl(i)
        correct = correct + 1;
    end 
end

disp(['accuracy: ' num2str(correct/size(test_data,1))])








