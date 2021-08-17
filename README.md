# Feature-Preserving Tensor Voting Model for Mesh Steganalysis
Created by [Hang Zhou](http://home.ustc.edu.cn/~zh2991/), [Kejiang Chen](http://home.ustc.edu.cn/~chenkj/), [Weiming Zhang](http://staff.ustc.edu.cn/~zhangwm/index.html), [Chuan Qin](https://scholar.google.com/citations?user=872LJo0AAAAJ&hl=en&oi=ao), [Nenghai Yu](http://staff.ustc.edu.cn/~ynh/).

Introduction
--
This work is published on Visualization and Computer Graphics (TVCG), 2019. 

We propose a neighborhood-level representation-guided tensor voting model for 3D mesh steganalysis. Specifically, we utilize a tensor voting model to reveal the artifacts caused by embedding data. The normal voting tensor (NVT) operation is performed on original mesh faces and smoothed mesh faces separately. Then, the absolute values of the differences between the eigenvalues of the two tensors (from the original face and the smoothed face) are regarded as features that capture intricate relationships among the vertices. Subsequently, the extracted features are processed with a nonlinear mapping to boost the feature effectiveness. 


Usage
--


    Download "geom3d", a 3D geometry toolbox from "https://github.com/mattools/matGeom"; 
    Download "smoothpatch", a toolbox for smoothing patches/triangles from "https://www.mathworks.com/matlabcentral/fileexchange/26710-smooth-triangulated-mesh"; 
    And download "toolbox_graph" from "https://www.mathworks.com/matlabcentral/fileexchange/5355-toolbox-graph", a public toolbox for 3D mesh processing. 
    Put them in the "functions/" directory.
    Put cover and stego 3D meshes in the "data/" directory, respectively;
    Start from main.m.


Citation
--
If you find our work useful in your research, please consider citing:

    @article{zhou2019feature,
     title={Feature-Preserving Tensor Voting Model for Mesh Steganalysis},
     author={Zhou, Hang and Chen, Kejiang and Zhang, Weiming and Qin, Chuan and Yu, Nenghai},
     journal={IEEE Transactions on Visualization and Computer Graphics},
     year={2019},
     publisher={IEEE}
    }

License
--
