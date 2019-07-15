function lambda = bnvt_feat2(vertex, face, f_normal)

area = meshSurfaceAreaList(vertex', face); area(isnan(area)) = 0;
f_normal = f_normal';

[conn, ~, ~] = neighborelem(face, max(max(face)));% Triangles adjacent to each vertex;

lambda = zeros(3, size(vertex, 2));

for k = 1:size(vertex, 2)
    indvaux02 = conn{k};% Elements containing current vertex
    cj = tricentroid(vertex', face(indvaux02, :));
    nc = size(cj);
    eij =  cj - repmat(vertex(:, k)', nc(1), 1);
    t1 = eij.*eij;
    t1 = sqrt(sum(t1, 2));
    t1 = exp(-t1/(1/3));
    
    t2 = area(indvaux02);
    t3 = t2/max(t2+eps).*t1;
    t4 = f_normal(:, indvaux02)';
    cov_mat = zeros(3, 3);
    for s = 1:nc(1)
        cov_mat = cov_mat + t3(s)*t4(s, :)'*t4(s, :);
    end
    [~, eig_val] = eig(cov_mat);
    [lambda(:, k), ind] = sort(diag(eig_val), 'descend');
end

    function [conn,connnum,count]=neighborelem(elem,nn)
        % [conn,connnum,count]=neighborelem(elem,nn)
        % neighborelem: create node neighbor list from a mesh
        % parameters:
        %    elem:  element table of a mesh
        %    nn  :  total node number of the mesh
        %    conn:  output, a cell structure of length nn, conn{n}
        %           contains a list of all neighboring elem ID for node n
        %    connnum: vector of length nn, denotes the neighbor number of each node
        %    count: total neighbor numbers
        conn=cell(nn,1);
        dim=size(elem);
        for i=1:dim(1)
            for j=1:dim(2)
                conn{elem(i,j)}=[conn{elem(i,j)},i];
            end
        end
        count=0;
        connnum=zeros(1,nn);
        for i=1:nn
            conn{i}=sort(conn{i});
            connnum(i)=length(conn{i});
            count=count+connnum(i);
        end
    end % neighborelem


    function out = tricentroid(v,tri)
        % Function to output the centroid of triangluar elements.
        % Note that the output will be of length(tri)x3
        % Input:    <v>     nx2 or 3: vertices referenced in tri
        %           <tri>   mx3: triangle indices
        % Version:      1
        % JOK 300509
        
        % I/O check
        [nv,mv]=size(v);
        [nt,mt]=size(tri);
        if mv==2
            v(:,3) = zeros(nv,1);
        elseif mt~=3
            tri=tri';
        end
        
        out(:,1) = 1/3*(v(tri(:,1),1)+v(tri(:,2),1)+v(tri(:,3),1));
        out(:,2) = 1/3*(v(tri(:,1),2)+v(tri(:,2),2)+v(tri(:,3),2));
        out(:,3) = 1/3*(v(tri(:,1),3)+v(tri(:,2),3)+v(tri(:,3),3));
    end% tricentroid


end