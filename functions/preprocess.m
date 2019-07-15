function [vertex_new] = preprocess( vertex )
%PREPROCESS Summary of this function goes here
%   Detailed explanation goes here

%transform the coordinate by pca
trans=pca(vertex');
% vertex_new=trans*vertex;
vertex_new = vertex'*trans;%add
vertex_new = vertex_new';%add

%scale the model in to unit cube 
[range_up]=max(vertex_new');
[range_low]=min(vertex_new');
range=range_up-range_low;
[range_max,axis]=max(range);

for i=1:3   
    vertex_new(i,:) = (vertex_new(i,:)-range_low(i)*ones(1,length(vertex_new)))/range_max;
end

end


