function valid_inds = findValidImages(dataset)

[~, num_img] = size(dataset.roidb_train{1,1}.rois);
valid_inds = [];
for i = 1:num_img
    if ~isempty(dataset.roidb_train{1,1}.rois(i).boxes)
        valid_inds = [valid_inds, i];
    end
end

end