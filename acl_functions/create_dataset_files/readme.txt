steps for generating a custom dataset

1. create folders
	1.1 create a 'custom_data' folder under dataset directory (can be folder link)
	1.2 create a 'custom_data/images' and 'custom_data/bboxes'

2. generate dataset matfiles
	2.1 run faster_rcnn_Imagenet_ZF.m 
		2.1.1 set a break point just past line 31
		2.1.1 save the workspace (>>save imagenet)
	2.2 run script_faster_rcnn_VOC2007_ZF.m
		2.2.1 set a break point just past line 31
		2.2.2 save the workspace (>>save voc)

3. copy imagenet dataset into custom_dataset folder
	3.1 load imagenet.mat
	3.2 run Imagenet2Imagenet.m

4. convert VOC dataset to imagenet dataset format
	4.1 load voc.mat
	4.2 run voc2Imagenet.m

5. generate val.txt
	5.1 run writeVal.m


--------------------------------------------------------------
--- after combining ImageNet_val and VOC2007 (with flip) -----
--------------------------------------------------------------
%% desired_classes = [2;32;35;53;54;56;72;73;79;80;87;89;...
%%                     91; 95; 97; 114; 150; 171; 182; 188];
%% max_images_per_class = 800;
>> total 10362 images
--------------------------------------------------------------
--> want to detect 20 classes 
laptop 	 258 imgs 
bus 	 614 imgs 
helmet 	 792 imgs 
bench 	 308 imgs 
motorcycle 	 760 imgs 
computer-keyboard 	 408 imgs 
bicycle 	 812 imgs 
table 	 1746 imgs 
tv-or-monitor 	 912 imgs 
backpack 	 494 imgs 
flower-pot 	 832 imgs 
traffic-light 	 180 imgs 
lamp 	 674 imgs 
cup-or-mug 	 746 imgs 
dog 	 1248 imgs 
car 	 1216 imgs 
chair 	 1506 imgs 
bowl 	 830 imgs 
person 	 4578 imgs 
sofa 	 866 imgs 

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% max_images_per_class = 2000;
--> want to detect 20 classes 
laptop 	 258 imgs 
bus 	 614 imgs 
helmet 	 792 imgs 
bench 	 308 imgs 
motorcycle 	 760 imgs 
computer-keyboard 	 408 imgs 
bicycle 	 830 imgs 
table 	 2496 imgs 
tv-or-monitor 	 984 imgs 
backpack 	 494 imgs 
flower-pot 	 914 imgs 
traffic-light 	 180 imgs 
lamp 	 674 imgs 
cup-or-mug 	 746 imgs 
dog 	 2540 imgs 
car 	 2144 imgs 
chair 	 2404 imgs 
bowl 	 908 imgs 
person 	 6406 imgs 
sofa 	 954 imgs 


--------------------------------------------------------------
--- ImageNet_val (with flip) ---------------------------------
--------------------------------------------------------------
%% desired_classes = [2;32;35;53;54;56;72;73;79;80;87;89;...
%%                     91; 95; 97; 114; 150; 171; 182; 188];
%% max_images_per_class = 800;
>> total 7972 images
--------------------------------------------------------------
--> want to detect 20 classes 
laptop 	 258 imgs 
bus 	 242 imgs 
helmet 	 792 imgs 
bench 	 308 imgs 
motorcycle 	 270 imgs 
computer-keyboard 	 408 imgs 
bicycle 	 344 imgs 
table 	 1668 imgs 
tv-or-monitor 	 472 imgs 
backpack 	 494 imgs 
flower-pot 	 424 imgs 
traffic-light 	 180 imgs 
lamp 	 674 imgs 
cup-or-mug 	 746 imgs 
dog 	 1336 imgs 
car 	 876 imgs 
chair 	 1246 imgs 
bowl 	 838 imgs 
person 	 3594 imgs 
sofa 	 496 imgs 
