function F = nvt36_fea(ori_file)
%NVT36_FEA Summary of this function goes here
%   Detailed explanation goes here
[vertex_o, face_o] = read_off(ori_file);
vertex_o = vertex_o'; face_o = face_o';

fv1.vertices = vertex_o; fv1.faces = face_o;
fv_smooth = smoothpatch(fv1, 2, 1);
vertex_s = fv_smooth.vertices; 
face_s = fv_smooth.faces;

vertex_o = vertex_o';
vertex_s = vertex_s';

vertex_o = preprocess(vertex_o);
vertex_s = preprocess(vertex_s);

% difference of points
vertex_p = abs(vertex_o - vertex_s);
vertex_l = abs(sqrt(sum(vertex_o(:,:).^2)) - sqrt(sum(vertex_s(:,:).^2)));

% difference of points in Laplacian
w = triangulation2adjacency(face_o);
l_o = (diag(sum(w,2)) - w)*vertex_o'; l_o = l_o';
l_s = (diag(sum(w,2)) - w)*vertex_s'; l_s = l_s';
l_vertex_p = abs(l_o(:,:) - l_s(:,:));
l_vertex_l = abs(sqrt(sum(l_o(:,:).^2)) - sqrt(sum(l_s(:,:).^2)));

% angles between normals
[v_normals_o, f_normals_o] = compute_normal(vertex_o', face_o');
[v_normals_s, f_normals_s] = compute_normal(vertex_s', face_s');
f_normals_o = f_normals_o'; f_normals_s = f_normals_s';
v_normals_o = v_normals_o'; v_normals_s = v_normals_s';
diff_faces = vectorAngle3d(f_normals_o,f_normals_s);
diff_faces(isnan(diff_faces)) = eps;

% angles between the vertex normals 
diff_vertex_normals = vectorAngle3d(v_normals_o, v_normals_s);
diff_vertex_normals(isnan(diff_vertex_normals)) = eps;

% absolute differences of the dihedral angles
vertex_o = vertex_o'; vertex_s = vertex_s';
diff_dihedral = get_dihedral(vertex_o, vertex_s, face_o);

% nvt feature
[lambda_o1, lambda_o2, lambda_o3] = bnvt_feat(vertex_o', face_o, f_normals_o);
[lambda_s1, lambda_s2, lambda_s3] = bnvt_feat(vertex_s', face_s, f_normals_s);
diff_lambda1 = abs(lambda_o1 - lambda_s1);
diff_lambda2 = abs(lambda_o2 - lambda_s2);
diff_lambda3 = abs(lambda_o3 - lambda_s3);

lambda_o = bnvt_feat2(vertex_o', face_o, f_normals_o);
lambda_s = bnvt_feat2(vertex_s', face_s, f_normals_s);
diff_lambda12 = abs(lambda_o(1, :) - lambda_s(1, :));
diff_lambda22 = abs(lambda_o(2, :) - lambda_s(2, :));
diff_lambda32 = abs(lambda_o(3, :) - lambda_s(3, :));

lambda_o = bnvt_feat3(vertex_o', face_o, f_normals_o);
lambda_s = bnvt_feat3(vertex_s', face_s, f_normals_s);
diff_lambda13 = abs(lambda_o(1, :) - lambda_s(1, :));
diff_lambda23 = abs(lambda_o(2, :) - lambda_s(2, :));
diff_lambda33 = abs(lambda_o(3, :) - lambda_s(3, :));

% calculate the stastics of the vertors
F = zeros(1, 36);

F(1, 1:36) = [cal_moment(diff_lambda1), cal_moment(diff_lambda2), cal_moment(diff_lambda3), ...
    cal_moment(diff_lambda12), cal_moment(diff_lambda22), cal_moment(diff_lambda32), ...
    cal_moment(diff_lambda13), cal_moment(diff_lambda23), cal_moment(diff_lambda33)];
    
F(isnan(F)) = 0;

end

function y = cal_moment(x)
    x = log(x+eps);
    y = [mean(x), var(x), skewness(x), kurtosis(x)];
end
