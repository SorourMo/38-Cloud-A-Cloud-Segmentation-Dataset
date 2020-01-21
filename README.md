# 38-Cloud: A Cloud Segmentation Dataset
This dataset contains 38 [Landsat 8](https://www.usgs.gov/land-resources/nli/landsat/landsat-8?qt-science_support_page_related_con=0#qt-science_support_page_related_con) scene images and their manually extracted pixel-level ground truths for cloud detection. 38-Cloud dataset is introduced in [[1]](https://arxiv.org/pdf/1901.10077.pdf), yet it is a modification of the dataset in [[2]](https://ieeexplore.ieee.org/document/8547095).  
The entire images of these scenes are cropped into multiple 384*384 patches to be proper for deep learning-based semantic segmentation algorithms. There are 8400 patches for training and 9201 patches for testing.
Each patch has 4 corresponding spectral channels which are Red (band 4), Green (band 3), Blue (band 2), and Near Infrared (band 5). Unlike other computer vision images, these channels are not combined together. Instead, they are in their correspondig directories. 

The directory tree of this dataset is as follows:
  
├──38-Cloud_training  
│------------├──train_red  
│------------├──train_green  
│------------├──train_blue  
│------------├──train_nir  
│------------├──train_gt  
│------------├──Natural_False_Color  
│------------├──Entire_scene_gts  
│------------├──training_patches_38-Cloud.csv  
│------------├──training_sceneids_38-Cloud.csv  
├──38-Cloud_test     
│------------├──test_red  
│------------├──test_green  
│------------├──test_blue  
│------------├──test_nir  
│------------├──Natural_False_Color  
│------------├──Entire_scene_gts  
│------------├──test_patches_38-Cloud.csv  
│------------├──test_sceneids_38-Cloud.csv    
  
    
#### *Click [here](https://goo.gl/683SHf) for downloading the "entire dataset".*
#### *Click [here](https://vault.sfu.ca/index.php/s/VRzcxMyoQlBMT2D) for downloading the "test set" separately.*
#### *Click [here](https://vault.sfu.ca/index.php/s/90HKcQv3wSMO0gD) for downloading the "training set" separately.*
#### *Click [here](https://www.kaggle.com/sorour/38cloud-cloud-segmentation-in-satellite-images) for downloading the "entire dataset" through Kaggle.*

### Landsat 8 Spectral Ranges:<br>  

| Band #  | Name | Spectral Range (nm) |
| ------------- | ------------- |------|
| 2  | Blue  | 450-515|
| 3  | Green  | 520-600|
| 4  | Red  | 630-680|
| 5  | NIR  |845-885|

### Example Images:
Below is an example of a 384*384 training patch:  

<div>
  <img src="./sample/red_patch_192_10_by_12_LC08_L1TP_002053_20160520_20170324_01_T1.jpg" width="120" height="120" hspace=5 > 
  <img src="./sample/green_patch_192_10_by_12_LC08_L1TP_002053_20160520_20170324_01_T1.jpg" width="120" height="120"hspace=5 > 
  <img src="./sample/blue_patch_192_10_by_12_LC08_L1TP_002053_20160520_20170324_01_T1.jpg" width="120" height="120" hspace=5 > 
  <img src="./sample/nir_patch_192_10_by_12_LC08_L1TP_002053_20160520_20170324_01_T1.jpg" width="120" height="120" hspace=5 > 
  <img src="./sample/truecolor_patch_192_10_by_12_LC08_L1TP_002053_20160520_20170324_01_T1.jpg" width="120" height="120" hspace=5 > 
  <img src="./sample/gt_patch_192_10_by_12_LC08_L1TP_002053_20160520_20170324_01_T1.jpg" width="120" height="120" hspace=5 > 
</div>

&emsp;&emsp;&emsp;Red &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; Green &emsp;&emsp;&emsp;&emsp;&emsp;&nbsp;&nbsp; Blue &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; NIR &emsp;&emsp;&emsp;&emsp;&emsp; False color&emsp;&emsp;&emsp;Ground truth
  
### Some Important Points:
1. Thin clouds (haze) are also considered as clouds (as well as thick clouds).
2. Natural color images are false color images used for further visualization purposes. They have not been used in the training and test phase of \[1] and \[2]\.  
3. Some of the patches do not have useful information (0 pixel values) in them. That is because of the black margins around the Landsat 8 images.
#### 4. The code for Cloud-Net model for training and test on 38-Cloud dataset can be found [here](https://github.com/SorourMo/Cloud-Net-A-semantic-segmentation-CNN-for-cloud-detection/tree/6c30ad6482847c855337baa5f17c24adaf5e5cda).

## Evaluation over 38-Cloud Dataset:
We have prepared a simple Matlab code to help researchers evaluate their results obtained by this dataset. You can find it in the "evaluation" directory. Please note that for the sake of consistency we have not provided users with ground truths of each 384*384 test patch, but with the ground truth of the entire Landsat 8 scenes. In order to generate a complete cloud mask from small patch masks and compare it with ground truths, please follow these instructions:

1- Preparing a directory for the predicted patch masks same as below:

├──preds_folder_root

│------------├──preds_folder


2- In "preds_folder" there should be all of the obtained patch masks from the test patches. Therefore, "pred_folder" consists of 9201 patches of 384*384. These should be pixel-level probabilities (for example the direct output of the sigmoid (or softmax) activation function in the last layer of a CNN model). The provided code will binarize the probabilities to generate binary masks.

3- The outputs of the mfile are an Excel file and a txt file. The reported numbers in Table 1 of \[1] is the txt file.

4- Please note that the evaluation metrics will be calculated for each "complete scene" and then averaged over 20 of the scenes in 38-Cloud test set.

5- Name of the patches play an important role to find the exact correct location of patches in a complete scene mask. Please avoid renaming test and predicted patches.


**************************************
If you found this dataset useful for your research please cite these two papers:    

```  
@INPROCEEDINGS{38-cloud-1,
  author={S. {Mohajerani} and P. {Saeedi}},
  booktitle={IGARSS 2019 - 2019 IEEE International Geoscience and Remote Sensing Symposium},
  title={Cloud-Net: An End-To-End Cloud Detection Algorithm for Landsat 8 Imagery},
  year={2019},
  volume={},
  number={},
  pages={1029-1032},
  doi={10.1109/IGARSS.2019.8898776},
  ISSN={2153-6996},
  month={July},
}

@INPROCEEDINGS{38-cloud-2,   
  author={S. Mohajerani and T. A. Krammer and P. Saeedi},   
  booktitle={2018 IEEE 20th International Workshop on Multimedia Signal Processing (MMSP)},   
  title={{"A Cloud Detection Algorithm for Remote Sensing Images Using Fully Convolutional Neural Networks"}},   
  year={2018},    
  pages={1-5},   
  doi={10.1109/MMSP.2018.8547095},   
  ISSN={2473-3628},   
  month={Aug},  
}
```
---- 
[1] S. Mohajerani, T. A. Krammer and P. Saeedi, "A Cloud Detection Algorithm for Remote Sensing Images Using Fully Convolutional Neural Networks," 2018 IEEE 20th International Workshop on Multimedia Signal Processing (MMSP), Vancouver, BC, 2018, pp. 1-5.
doi: 10.1109/MMSP.2018.8547095
URL: http://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=8547095&isnumber=8547039  

[2] S. Mohajerani and P. Saeedi, "Cloud-Net: An End-To-End Cloud Detection Algorithm for Landsat 8 Imagery," IGARSS 2019 - 2019 IEEE International Geoscience and Remote Sensing Symposium, Yokohama, Japan, 2019, pp. 1029-1032.
doi: 10.1109/IGARSS.2019.8898776.
Arxive URL: https://arxiv.org/pdf/1901.10077.pdf, 
IEEE URL: URL: http://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=8898776&isnumber=8897702
