import numpy as np
import matplotlib.pyplot as plt
from .format_helpers import array_to_image
from .planar_cuts import *
from itkwidgets import view

def two_dee_helper(orientation, spacing):
    '''
    Helper function for the twodee_plot function
    Inputs:
        orientation: specification of 'xy', 'xz' or 'yz' or reverse order
    '''
    assert len(spacing) == 3 and isinstance(spacing,list), "Please give spacing as a list of 3 integers [x-spacing, y-spacing, z-spacing]"
    assert set(orientation) in [set('xy'), set('xz'), set('yz')], "Please specify a correct orientation"
    
    if set(orientation) == {'x','y'}:
        return xy_plane, spacing[1], spacing[0], 0
    elif set(orientation) == {'x','z'}:
        return xz_plane, spacing[2], spacing[0], 1
    elif set(orientation) == {'y', 'z'}:
        return yz_plane, spacing[2], spacing[1], 2

    
def twodee_plot(images, spacing, orientation, slice_, **kwargs):
    '''
    Function that takes does a 2D plot for a specified orientation at a particular slice. Uses bilinear interpolation 
    for the aspect ratios. Bilinear because they're 2D plots
    Inputs:
        images: one 3D image or a list of images. Needs to be provided in list format. Images need to be numpy arrays in (z, y, x) shape
                spacing: spacing as a list in [x-size, y-size, z-size] format
        orientation: specification of 'xy', 'xz' or 'yz' or reverse order
        slice: the slice to plot
        **kwargs: 
            labels as a list of titles for each image
            cols as a number of columns for the image    
    Outputs:
        a 2D plot of the image or images side-by-side at the orientation and slice 
    '''
    assert isinstance(slice_, int), "Please provide an integer number for the slice"
    assert isinstance(images, list), "Please provide the images in list format, even if you're using just one image"
    assert isinstance(images[0], np.ndarray), "Please provide the image in numpy array format"
    
    fig = plt.figure(figsize=(16,8))
    no_of_subplots = len(images)
    COLS = kwargs.get("cols", 3)
    if COLS != 3:
        assert isinstance(COLS, int), "Please provide columns as an integer"
    ROWS = int(np.ceil(no_of_subplots/COLS))
    
    labels = kwargs.get("labels")
    if labels is not None:
        assert isinstance(labels, list), "Please provide labels as a list"
        assert isinstance(labels[0], str), "Please provide the plot titles in string format"
        assert len(labels) == len(images), "Please provide a title for all images"
        labels = [f"Image {labels[i]} at slice {slice_} in {orientation} plane" for i in range(no_of_subplots)]
    else:
        labels = [f"Image {i+1} at slice {slice_} in {orientation} plane" for i in range(no_of_subplots)]

    slice_fn, a, b, _ = two_dee_helper(orientation, spacing)
 
    for i in range(1, no_of_subplots+1):
        ax = fig.add_subplot(ROWS, COLS, i)
        ax.imshow(slice_fn(images[i-1], slice_), aspect=a/b, interpolation='bilinear')
        ax.set_title(labels[i-1])

        
def side_by_side_3dview(image1, image2, spacing):
    '''
    Method to view two images side-by-side. 
    # TODO need to check where image 1 and image 2 appear
    Inputs:
        image1: numpy array of image in (z,y,x)
        image2: numpy array of image in (z,y,x)
    Outputs:
        side-by-side 3D view
    '''
    space = np.zeros((image1.shape[0], image1.shape[1],int(image1.shape[2]/5)))
    combined = np.concatenate((image1,space, image2), axis=2)
    combined = array_to_image(combined, spacing = spacing)

    return view(combined)