import numpy as np

def xy_plane(image, z_axis):
    '''
    Return view along xy_plane for z_axis
    Inputs:
        z_axis: integer
    '''
    assert z_axis >=0 and z_axis < image.shape[0], f"The image has {image.shape[0]} z stacks. Python starts indexing at 0" 
    assert isinstance(z_axis, int), "Please provide an integer for the z_axis"
    
    return image[z_axis,:,:]     
    
def xz_plane(image, y_axis):
    '''
    Return view along xz_plane
    Inputs:
        y_axis: integer
    '''
    assert y_axis >=0 and y_axis < image.shape[1], f"The image has {image.shape[1]} y stacks. Python starts indexing at 0"
    assert isinstance(y_axis, int), "Please provide an integer for the z_axis"

    return image[:, y_axis, :]

def yz_plane(image, x_axis):
    '''
    Return view along yz_plane
    Inputs:
        x_axis: integer
    '''
    assert x_axis >=0 and x_axis < image.shape[2], f"The image has {image.shape[2]} x stacks. Python starts indexing at 0"
    assert isinstance(x_axis, int), "Please provide an integer for the z_axis"

    return image[:, :, x_axis]