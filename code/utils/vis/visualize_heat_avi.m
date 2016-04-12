function visualize_heat_avi( out_avi, img_folder, feat_matrix, shift , resize_vis, bin_val_map,options)
%% Visualize heatmap on the frames. Fusion heat matrix over farmes with
% "shift" frames.
%   input:
%       - out_avi : output file address
%       - img_folder : folder contains .jpg frames
%       - feat_matrix : 3D matrix [X Y N], where [X Y] are heat matrix for 
%                       each frame, and N is totall number of heat maps.
%       - shift : to adjust beginig frame.
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% read frame folder and initialize video writer object
dispstat('','init');
dispstat('Creating video file...','keepthis');
dirlist = dir([img_folder, '***.jpg']);
aviobj1 = VideoWriter(out_avi);
aviobj1.FrameRate = 1;
open(aviobj1);

%% fusion heatmaps and frames
for sample_no=1:size(feat_matrix,3)
    dispstat(['writing frame ' num2str(sample_no) '/' num2str(size(feat_matrix,3)) ]);
    if sample_no==size(feat_matrix,3) && strcmp(options.feat_type,'dif_bin')
       break;
    end
    if strcmp(options.feat_type,'dif_bin')
        img_background= abs(feat_matrix(:,:,sample_no)-feat_matrix(:,:,sample_no+1));
    else
        img_background= feat_matrix(:,:,sample_no);
    end
    
    img_org_name = [img_folder dirlist(sample_no+shift).name];
    org_img= imread(img_org_name);
    %fusion = imfuse(img_background,org_img, 'falsecolor','Scaling','joint','ColorChannels',[2 0 1]);
    fusion = imfuse(img_background,org_img,'Scaling','independent','ColorChannels',[1 2 0]);
    %imagesc(img)
    %imagesc(fusion);
    h_th = floor(size(feat_matrix,1)/size(bin_val_map,1));
    w_th = floor(size(feat_matrix,2)/size(bin_val_map,2));
    fusion = imresize(fusion,resize_vis);
    for h_idx=1:size(bin_val_map,1)
        for w_idx=1:size(bin_val_map,2)
            position =  [(w_idx-1)*w_th*resize_vis (h_idx-1)*h_th*resize_vis+30];
            if strcmp(options.feat_type,'dif_bin')
                if options.hex
                    fusion = insertText(fusion,position,abs(bin_val_map(h_idx,w_idx,sample_no)-bin_val_map(h_idx,w_idx,sample_no+1)),'AnchorPoint','LeftBottom');
                else
                val1= de2bi( bin_val_map(h_idx,w_idx,sample_no), options.bin_size, 'left-msb');
                val2 = de2bi( bin_val_map(h_idx,w_idx,sample_no+1),options.bin_size, 'left-msb');
                %fusion = insertText(fusion,position,abs(val1-val2),'AnchorPoint','LeftBottom');
                fusion = insertText(fusion,position,pdist([val1 ; val2], 'minkowski',1),'AnchorPoint','LeftBottom');
                end
            else
                fusion = insertText(fusion,position,bin_val_map(h_idx,w_idx,sample_no),'AnchorPoint','LeftBottom');
            end
        end
    end
    imwrite(fusion,['../data/output/frms/' dirlist(sample_no+shift).name]);
    writeVideo(aviobj1,fusion);
    %w = waitforbuttonpress;
end
close(aviobj1);
end

