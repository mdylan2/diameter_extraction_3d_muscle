def pick_object(labelled_image, label, thresh = 0):
    '''
    Function that takes in a labelled image and returns a boolean where the labelled image equals the label
    Inputs:
        labelled_image: Numpy array of 3D image with labels
        label: integer of the label number of interest
        thresh: 
            a threshold to apply to the other fibrous material that does not belong to the label
            If thresh is 0, you will only see the fiber of the label of interest
    Outputs:
        Array where background stays 0, label becomes 1, every other label becomes thresholded to the value specified
    '''
    assert isinstance(labelled_image, np.ndarray) and isinstance(label, int), "Please provide an image as a NumPy array and a label as integer"
    assert label in np.unique(labelled_image), "Label not in the labelled image!"
    
    a = np.where((labelled_image != 0)  & (labelled_image != label), thresh, labelled_image)
    
    return np.where(a > thresh, 1, a)

def view_object(labelled_image, label, spacing, thresh = 0):
    '''
    Function that takes a labelled image and a label and gives a 3D view of the label of interest
    Inputs:
        labelled_image: Numpy array of 3D image with labels
        label: integer of the label number of interest
        spacing: voxel spacing of the image provided as a list of [x-spacing, y-spacing, z-spacing]
    Outputs:
        3D view of the label with the other parts very faintly viewable
    '''
    return view(array_to_image(pick_object(labelled_image, label, thresh), spacing = spacing))