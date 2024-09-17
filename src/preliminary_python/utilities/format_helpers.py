import itk
import numpy as np

def array_to_image(numpy_array, spacing):
    '''
    Function to convert from a NumPy array to an ITK image to account for spacing
    Given the above, spacing needs to be provided in [z-spacing, y-spacing, x-spacing]
    You can get the spacing by dividing each length of the image captured by the 
    number of stacks in each length. Or, you could just look through the metadata on
    ImageJ under the Image > Show Info menu item
    Inputs:
        numpy_array: NumPy array of 3D stacked image
        spacing: list of [x-spacing, y-spacing, z-spacing]
    Outputs:
        ITK Image
    '''    
    # Casting the array object to float format in case its True/False
    processed_array = numpy_array.astype(np.float)
    # Converting array to itk format
    img_output = itk.image_from_array(processed_array)
    # Setting spacing of array    
    img_output.SetSpacing(spacing)
    
    return img_output


def image_to_array(itk_image):
    '''
    Function to convert from an ITK image to a NumPy array
    Inputs:
        itk_image: ITK Image
    Outputs:
        NumPy array of image
    '''
    return itk.array_from_image(itk_image)