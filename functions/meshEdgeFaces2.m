function edgeFaces = meshEdgeFaces2(faces)

edgeFaces = zeros(size(faces, 1)*3, 2);

edgeFaces(1:size(faces,1), :) = faces(:, 1:2);
edgeFaces(1+size(faces,1):size(faces,1)*2, :) = faces(:, 2:3);
edgeFaces(1+size(faces,1)*2:size(faces,1)*3, :) = [faces(:, 1), faces(:, 3)];

end