function [lambda1, lambda2, lambda3] = bnvt_feat(vertex, face, f_normal)

face_adj = trimeshEdgeFaces(face);

area = meshSurfaceAreaList(vertex', face); area(isnan(area)) = 0;
f_normal2 = f_normal;
f_normal = f_normal';

lambda = zeros(3, size(face, 1));
lambda = NaN(size(face, 1), 3);

for k = 1:size(face, 1)
    f_ad = [find(face_adj(:, 1)==k); find(face_adj(:, 2)==k)];
    
    if(numel(f_ad)==3)
        % indexes of 3 adjacent faces
        f_ad1 = setdiff(face_adj(f_ad(1), :), k); 
        f_ad1 = setdiff(f_ad1, 0);
        f_ad2 = setdiff(face_adj(f_ad(2), :), k); 
        f_ad2 = setdiff(f_ad2, 0);
        f_ad3 = setdiff(face_adj(f_ad(3), :), k); 
        f_ad3 = setdiff(f_ad3, 0);
        if(numel(f_ad1)==1 && f_ad1>0)
            vote1 = area(f_ad1)*f_normal(:, f_ad1)*f_normal(:, f_ad1)';
            w_vote1 = area(f_ad1);
        else
            vote1 = zeros(3, 3);
            w_vote1 = 0;
        end
        if(numel(f_ad2)==1 && f_ad2>0)
            vote2 = area(f_ad2)*f_normal(:, f_ad2)*f_normal(:, f_ad2)';
            w_vote2 = area(f_ad2);
        else
            vote2 = zeros(3, 3);
            w_vote2 = 0;
        end
        if(numel(f_ad3)==1 && f_ad3>0)
            vote3 = area(f_ad3)*f_normal(:, f_ad3)*f_normal(:, f_ad3)';
            w_vote3 = area(f_ad3);
        else
            vote3 = zeros(3, 3);
            w_vote3 = 0;
        end
        cov_mat = (vote1+vote2+vote3)/(w_vote1+w_vote2+w_vote3+eps);
        
        [~, eig_val] = eig(cov_mat);
        [temp_lambda, ~] = sort(diag(eig_val), 'descend');
        lambda(k, 1) = temp_lambda(1);
        lambda(k, 2) = temp_lambda(2);
        lambda(k, 3) = temp_lambda(3);
    end
end

lambda1 = lambda(:, 1);
lambda2 = lambda(:, 2);
lambda3 = lambda(:, 3);

end