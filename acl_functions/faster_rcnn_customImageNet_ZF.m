function faster_rcnn_customImageNet_ZF()
% script_faster_rcnn_VOC2007_ZF()
% Faster rcnn training and testing with Zeiler & Fergus model
% --------------------------------------------------------
% Faster R-CNN
% Copyright (c) 2015, Shaoqing Ren
% Licensed under The MIT License [see LICENSE for details]
% --------------------------------------------------------

clc;
clear mex;
clear is_valid_handle; % to clear init_key

%% -------------------- CONFIG --------------------
opts.caffe_version          = 'caffe_faster_rcnn';
opts.gpu_id                 = auto_select_gpu;
active_caffe_mex(opts.gpu_id, opts.caffe_version);
% do validation, or not 
opts.do_val                 = false; 
% model
model                       = generateModel(fullfile(pwd, 'models', 'CaffeNet'));

% cache base
cache_base_proposal         = 'faster_rcnn_customImageNet_CaffeNet';
cache_base_fast_rcnn        = '';
% train/test data
dataset                     = [];
use_flip                = true;

dataset.imdb_train    = { imdb_from_customImageNet(use_flip) };
dataset.roidb_train   = cellfun(@(x) roidb_from_customImageNet(x), dataset.imdb_train, 'UniformOutput', false);

% downsampling the dataset to only include images of certain classes

% 20 classes
desired_classes = [2;32;35;53;54;56;72;73;79;80;87;89;...
                     91; 95; 97; 114; 150; 171; 182; 188];
% 3 classes for debugging
% desired_classes = [79; 182; 188];
% !!! need to remove log in output folder
max_images_per_class = 2000;
tmp_imdb_train = dataset.imdb_train{1,1}; 
tmp_roidb_train = dataset.roidb_train{1,1}; 
[dataset.imdb_train{1,1}, dataset.roidb_train{1,1}] = ...
    reduceClasses(tmp_imdb_train, tmp_roidb_train, ...
                  desired_classes, max_images_per_class, 'train');
[dataset.imdb_test, dataset.roidb_test] = ...
    reduceClasses(tmp_imdb_train, tmp_roidb_train, ...
                  desired_classes, max_images_per_class, 'test');
% for i = 1:numel(dataset.roidb_train{1,1}.rois)
%   showDataPic(dataset.imdb_train{1,1}, dataset.roidb_train{1,1}, i);
% end
%showDataPic(dataset.imdb_train{1,1}, dataset.roidb_train{1,1}, 1)
%showDataPic(dataset.imdb_test, dataset.roidb_test, 1);
clearvars tmp_imdb_train tmp_roidb_train


%% -------------------- TRAIN --------------------
% conf
conf_proposal               = proposal_config('image_means', model.mean_image, 'feat_stride', model.feat_stride);
conf_fast_rcnn              = fast_rcnn_config('image_means', model.mean_image);
% set cache folder for each stage
model                       = Faster_RCNN_Train.set_cache_folder(cache_base_proposal, cache_base_fast_rcnn, model);
% generate anchors and pre-calculate output size of rpn network 
[conf_proposal.anchors, conf_proposal.output_width_map, conf_proposal.output_height_map] ...
                            = proposal_prepare_anchors(conf_proposal, model.stage1_rpn.cache_name, model.stage1_rpn.test_net_def_file);

%%  stage one proposal
fprintf('\n***************\nstage one proposal \n***************\n');
% train
model.stage1_rpn            = Faster_RCNN_Train.do_proposal_train(conf_proposal, dataset, model.stage1_rpn, opts.do_val);
% test
dataset.roidb_train        	= cellfun(@(x, y) Faster_RCNN_Train.do_proposal_test(conf_proposal, model.stage1_rpn, x, y), dataset.imdb_train, dataset.roidb_train, 'UniformOutput', false);
dataset.roidb_test        	= Faster_RCNN_Train.do_proposal_test(conf_proposal, model.stage1_rpn, dataset.imdb_test, dataset.roidb_test);
%dataset.roidb_train{1,1}         = pruneAllBoxes(dataset.imdb_train{1,1}, dataset.roidb_train{1,1});
%dataset.roidb_test          = pruneAllBoxes(dataset.imdb_test, dataset.roidb_test);
%%  stage one fast rcnn
fprintf('\n***************\nstage one fast rcnn\n***************\n');
% train
fprintf('stage one fast rcnn train \n');
model.stage1_fast_rcnn      = Faster_RCNN_Train.do_fast_rcnn_train(conf_fast_rcnn, dataset, model.stage1_fast_rcnn, opts.do_val);
% test
fprintf('stage one fast rcnn test \n');
opts.mAP                    = Faster_RCNN_Train.do_fast_rcnn_test(conf_fast_rcnn, model.stage1_fast_rcnn, dataset.imdb_test, dataset.roidb_test);

%%  stage two proposal
% net proposal
fprintf('\n***************\nstage two proposal\n***************\n');
% train
model.stage2_rpn.init_net_file = model.stage1_fast_rcnn.output_model_file;
model.stage2_rpn            = Faster_RCNN_Train.do_proposal_train(conf_proposal, dataset, model.stage2_rpn, opts.do_val);
% test
dataset.roidb_train       	= cellfun(@(x, y) Faster_RCNN_Train.do_proposal_test(conf_proposal, model.stage2_rpn, x, y), dataset.imdb_train, dataset.roidb_train, 'UniformOutput', false);
dataset.roidb_test       	= Faster_RCNN_Train.do_proposal_test(conf_proposal, model.stage2_rpn, dataset.imdb_test, dataset.roidb_test);

%%  stage two fast rcnn
fprintf('\n***************\nstage two fast rcnn\n***************\n');
% train
model.stage2_fast_rcnn.init_net_file = model.stage1_fast_rcnn.output_model_file;
model.stage2_fast_rcnn      = Faster_RCNN_Train.do_fast_rcnn_train(conf_fast_rcnn, dataset, model.stage2_fast_rcnn, opts.do_val);

%% final test
fprintf('\n***************\nfinal test\n***************\n');
     
model.stage2_rpn.nms        = model.final_test.nms;
dataset.roidb_test       	= Faster_RCNN_Train.do_proposal_test(conf_proposal, model.stage2_rpn, dataset.imdb_test, dataset.roidb_test);
opts.final_mAP              = Faster_RCNN_Train.do_fast_rcnn_test(conf_fast_rcnn, model.stage2_fast_rcnn, dataset.imdb_test, dataset.roidb_test);

% save final models, for outside tester
Faster_RCNN_Train.gather_rpn_fast_rcnn_models(conf_proposal, conf_fast_rcnn, model, dataset);
end

function [anchors, output_width_map, output_height_map] = proposal_prepare_anchors(conf, cache_name, test_net_def_file)
    [output_width_map, output_height_map] ...                           
                                = proposal_calc_output_size(conf, test_net_def_file);
    anchors                = proposal_generate_anchors(cache_name, ...
                                    'scales',  2.^[3:5]);
end

function model = generateModel(model_dir)
model.mean_image                                = fullfile(pwd, 'models', 'pre_trained_models', 'ZF', 'mean_image');
model.pre_trained_net_file                      = fullfile(pwd, 'models', 'pre_trained_models', 'ZF', 'ZF.caffemodel');
% Stride in input image pixels at the last conv layer
model.feat_stride                               = 16;

%% stage 1 rpn, inited from pre-trained network
model.stage1_rpn.solver_def_file                = fullfile(pwd, 'models', 'rpn_prototxts', 'ZF', 'solver_60k80k.prototxt');
model.stage1_rpn.test_net_def_file              = fullfile(pwd, 'models', 'rpn_prototxts', 'ZF', 'test.prototxt');
model.stage1_rpn.init_net_file                  = model.pre_trained_net_file;

% rpn test setting
model.stage1_rpn.nms.per_nms_topN              	= -1;
model.stage1_rpn.nms.nms_overlap_thres        	= 0.7;
model.stage1_rpn.nms.after_nms_topN           	= 2000;
% model.stage1_rpn.nms.after_nms_topN           	= 200;

%% stage 1 fast rcnn, inited from pre-trained network
model.stage1_fast_rcnn.solver_def_file          = fullfile(pwd, 'models', 'fast_rcnn_prototxts', 'ZF', 'solver_30k40k.prototxt');
model.stage1_fast_rcnn.test_net_def_file        = fullfile(pwd, 'models', 'fast_rcnn_prototxts', 'ZF', 'test.prototxt');
model.stage1_fast_rcnn.init_net_file            = model.pre_trained_net_file;

%% stage 2 rpn, only finetune fc layers
model.stage2_rpn.solver_def_file                = fullfile(pwd, 'models', 'rpn_prototxts', 'ZF_fc6', 'solver_60k80k.prototxt');
model.stage2_rpn.test_net_def_file              = fullfile(pwd, 'models', 'rpn_prototxts', 'ZF_fc6', 'test.prototxt');

% rpn test setting
model.stage2_rpn.nms.per_nms_topN             	= -1;
model.stage2_rpn.nms.nms_overlap_thres       	= 0.7;
model.stage2_rpn.nms.after_nms_topN           	= 2000;
% model.stage2_rpn.nms.after_nms_topN           	= 200;

%% stage 2 fast rcnn, only finetune fc layers
model.stage2_fast_rcnn.solver_def_file          = fullfile(pwd, 'models', 'fast_rcnn_prototxts', 'ZF_fc6', 'solver_30k40k.prototxt');
model.stage2_fast_rcnn.test_net_def_file        = fullfile(pwd, 'models', 'fast_rcnn_prototxts', 'ZF_fc6', 'test.prototxt');

%% final test
model.final_test.nms.per_nms_topN            	= 6000; % to speed up nms
model.final_test.nms.nms_overlap_thres       	= 0.7;
model.final_test.nms.after_nms_topN          	= 300;
end

function roidb = pruneAllBoxes(imdb, roidb)
    for i = 1:numel(roidb.rois)
        pic_size = imdb.sizes(i,:);
        roidb.rois(i).boxes = forceBnd(roidb.rois(i).boxes, pic_size);
    end
end

function boxes = forceBnd(boxes, pic_size)
%lower bound
boxes = max(boxes,2);

% upper bound
boxes(:,1) = min(boxes(:,1), pic_size(2)-1);
boxes(:,2) = min(boxes(:,2), pic_size(1)-1);
boxes(:,3) = min(boxes(:,3), pic_size(2)-1);
boxes(:,4) = min(boxes(:,4), pic_size(1)-1);

% checking
% [num_boxes, ~] = size(boxes);
% assert(sum(boxes(:,1) <= pic_size(2)) == num_boxes);
% assert(sum(boxes(:,2) <= pic_size(1)) == num_boxes);
% assert(sum(boxes(:,3) <= pic_size(2)) == num_boxes);
% assert(sum(boxes(:,4) <= pic_size(1)) == num_boxes);
end