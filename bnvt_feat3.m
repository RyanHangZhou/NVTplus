function lambda = bnvt_feat3(vertex, face, f_normal)

area = meshSurfaceAreaList(vertex', face); area(isnan(area)) = 0;
f_normal = f_normal';
trineigh = trineighborelem(face);

lambda = zeros(3, size(face, 1));

for k = 1:size(face, 1)
    indvaux02 = trineigh{k};% Elements containing current face
    cj = tricentroid(vertex', face(indvaux02, :));
    nc = size(cj);
    zj = tricentroid(vertex', face(k, :));
    eij =  cj - repmat(zj, nc(1), 1);
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

    function trineigh=trineighborelem(elem)
        % [conn,connnum,count]=neighborelem(elem,nn)
        %
        % neighborelem: create node neighbor list from a mesh
        %
        % author: fangq (fangq<at> nmr.mgh.harvard.edu)
        % date: 2007/11/21
        %
        % parameters:
        %    elem:  element table of a mesh
        %    nn  :  total node number of the mesh
        %    conn:  output, a cell structure of length nn, conn{n}
        %           contains a list of all neighboring elem ID for node n
        %    connnum: vector of length nn, denotes the neighbor number of each node
        %    count: total neighbor numbers
        %
        % -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
        %
        nn = max(max(elem));
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
        
        % Now identify all the nodes in one triangle and get them all into one
        % array, so that all elements surrounding one element are listed
        trineigh = cell(dim(1),1);
        for i=1:dim(1)
            vind = elem(i,:); % Vertices for the i'th element
            aux01 = [conn{vind(1)},conn{vind(2)},conn{vind(3)}];
            aux02 = unique(aux01);
            trineigh{i} = aux02;
        end
    end%trineighborelem


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