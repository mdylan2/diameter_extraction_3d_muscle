from ipywidgets import widgets
import pandas as pd
import numpy as np
from .visualize import twodee_plot


class twodee_widgets:
    def __init__(self, images, spacing, **kwargs):
        '''
        Initializes the class. 
        Inputs:
            images: One 3D image or a list of images. Needs to be provided in list format. Images need to be 
                    numpy arrays in (z, y, x) shape
            spacing: voxel-spacing of the images provided as a list in [x-spacing, y-spacing, z-spacing] format
            **kwargs: 
                labels as a list of titles for each image
                cols as a number of columns for the image  
        '''
        assert isinstance(images, list), "Please provide the images in list format, even if you're using just one image"
        assert isinstance(images[0], np.ndarray), "Please provide the image in numpy array format"
        assert len(spacing) == 3, "Need spacing for the 3 dimensions"
        
        self.images = images
        self.labels = kwargs.get("labels", None)
        self.cols = kwargs.get("cols", 3)
        self.spacing = spacing
        self.zslider = widgets.IntSlider(value=0, min=0, max=images[0].shape[0] - 1, 
                                          step=1,description='Plane Number:',
                                          disabled=False, continuous_update=True,
                                          orientation='horizontal',readout=True)
        self.yslider = widgets.IntSlider(value=0, min=0, max=images[0].shape[1] - 1, 
                                          step=1,description='Plane Number:',
                                          disabled=False, continuous_update=True,
                                          orientation='horizontal',readout=True)
        self.xslider = widgets.IntSlider(value=0, min=0, max=images[0].shape[2] - 1, 
                                          step=1,description='Plane Number:',
                                          disabled=False, continuous_update=True,
                                          orientation='horizontal',readout=True)
        
    
    def z_plot(self, zslice):
        return twodee_plot(images=self.images, 
                           spacing=self.spacing, 
                           orientation='xy', 
                           slice_=zslice, 
                           labels = self.labels,
                           cols = self.cols)
    
    def y_plot(self, yslice):
        return twodee_plot(images=self.images, 
                           spacing=self.spacing, 
                           orientation='xz', 
                           slice_=yslice, 
                           labels = self.labels,
                           cols = self.cols)
    
    def x_plot(self, xslice):
        return twodee_plot(images=self.images, 
                           spacing=self.spacing, 
                           orientation='yz', 
                           slice_=xslice, 
                           labels = self.labels,
                           cols = self.cols)
    
    # Returns a widget with zslice slider at the top and the images at the respective zslice below
    def widget_xy(self):
        out = widgets.interactive_output(self.z_plot, {'zslice': self.zslider})
    
        vertical_box = widgets.VBox([widgets.VBox([self.zslider]), out])
        
        return vertical_box
    
    # Returns a widget with zslice slider at the top and the images at the respective zslice below
    def widget_xz(self, **kwargs):
        out = widgets.interactive_output(self.y_plot, {'yslice': self.yslider})
    
        vertical_box = widgets.VBox([widgets.VBox([self.yslider]), out])
        
        return vertical_box
    
    # Returns a widget with zslice slider at the top and the images at the respective zslice below
    def widget_yz(self):
        out = widgets.interactive_output(self.x_plot, {'xslice': self.xslider})
    
        vertical_box = widgets.VBox([widgets.VBox([self.xslider]), out])
        
        return vertical_box
        
    # Calculates dice coefficient between image1 and image2
    def similarity_of_images(self, image1, image2):
        image1 = image1.ravel()
        image2 = image2.ravel()
        return np.sum(image1 == image2)*2/(len(image1) + len(image2))   
    
    # Calculates a matrix of dice coefficients between images
    def dice_matrix(self):
        results = np.zeros((len(self.images), len(self.images)))
        
        for i, img1 in enumerate(self.images):
            for j, img2 in enumerate(self.images):
                if i > j:
                    continue
                dice = self.similarity_of_images(img1, img2)
                results[i,j] = dice
                results[j,i] = dice
        
        cols = self.labels
        idx = cols.copy()
        
        results = pd.DataFrame(data = results, index = idx, columns = cols)
        
        return results