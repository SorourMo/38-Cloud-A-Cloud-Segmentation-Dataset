# 38-Cloud: A Cloud Segmentation Dataset
This dataset includes 38 [Landsat 8](https://www.usgs.gov/land-resources/nli/landsat/landsat-8?qt-science_support_page_related_con=0#qt-science_support_page_related_con) scene images and their manually extracted pixel-level ground truths for cloud detection.
The entire images of these scenes are cropped into multiple 384*384 patches to be proper for deep learning based semantic segmentation.

Each patch has 4 corresponding spectral channels which are Red (band 4), Green (band 3), Blue (band 2), and Near Infrared (band 5). Unlike other computer vision images, these channels are not combined together. Instead, they are in their correspondig directories. The following the directory tree of this dataset is as follows:

-38-Cloud_training
   -train_red
   -train_green
   -train_blue
   -train_nir
   -train_gt
   -Natural_False_Color
   -Entire_scene_gts
   -training_patches_38-Cloud.csv
   -training_sceneids_38-Cloud.csv
   
-38-Cloud_test   
   -test_red
   -test_green
   -test_blue
   -test_nir
   -Natural_False_Color
   -Entire_scene_gts
   -test_patches_38-Cloud.csv
   -test_sceneids_38-Cloud.csv
 
   
   



