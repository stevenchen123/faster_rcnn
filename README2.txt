This repo is forked from https://github.com/ShaoqingRen/faster_rcnn


1. Clone this repo
	1.1 git clone --recursive https://github.com/stevenchen123/faster_rcnn.git

2. Set up Cuda
	2.1 remember to add the following line to .bashrc (need to verify ".")
	    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/"cuda-7.5"/"lib64"

3. Compile Caffe
	3.1 may need to install (apt-get install) a few packages
	    good resources can be found here
		http://caffe.berkeleyvision.org/install_apt.html
	3.2 copy and configure Makefile.config
	3.3 cd external/caffe
	    make -j* all
	    make matcaffe

4. Compile Matlab scripts
	4.1 run startup.m
	4.2 faster_rcnn_build.m

5. Make folder links to image datasets
	5.1 inside dataset directory

6. Download training config files / model
	6.1 run scripts files in fetch_data directory

7. Correct Windows/Linux file directory problem
	ex. in models/fast_rcnn_prototxts/ZF directory, open solver_30k40k.prototxt
	change 1st line from ''' net: ".\\models\\fast_rcnn_prototxts\\ZF\\train_val.prototxt" '''
			to ''' net: "models/fast_rcnn_prototxts/ZF/train_val.prototxt" '''

8. Copy Config files for ImageNet dataset
	8.1 copy all files from "acl_functions/ImageNet_files" 
		into ImageNet dataset folder (folder linked)
	8.2 copy "val.txt" into ImageNet/ILSVRC2013_DET_val directory


