import numpy as np
import pandas as pd
from sklearn import cluster
from scipy import ndimage as ndi
from ipywidgets import widgets
from skimage import measure
from tqdm.notebook import tqdm
import matplotlib.pyplot as plt
from matplotlib import cm


from .visualize import two_dee_helper

def DBSCAN_(processed_array_slice):
    '''
    NOTE: THERE MIGHT BE AN ERROR IN THIS IMPLEMENTATION. USE WITH CAUTION
    This function takes in a thresholded image slice with blobs and clusters different blobs using the DBSCAN algorithm
    Inputs:
        processed_array_slice: A 2D NumPy array of the slice of blobs which needs to be clustered. This slice is assumed
                               to be a thresholded slice with blobs
    Outputs:
        pas: A 2D NumPy array of labelled blobs. The background is labelled 0. It's important to note
             that any outliers by DBSCAN will be classified by background, even if they were in the 
             original segmented array slice
        no_of_labels: The number of unique blobs identified
    '''
    # Copy the array slice
    pas = processed_array_slice.copy().astype(np.uint8)
    
    # Cluster it using the DBSCAN algorithm
    k = cluster.DBSCAN(eps=np.sqrt(2))
    
    # Find the coordinates of the foreground (i.e. the blobs)
    z, x = np.where(pas == 1)
    
    # Concatenate the z coordinates together
    train = np.vstack((x,z)).T
    
    # Fit a DBSCAN model to the data
    k.fit(train)
    
    # Take the predictions 
    predictions = k.labels_.copy()
    no_of_labels = len(np.unique(predictions[predictions>-1]))
    pas[np.where(pas == 1)] = predictions + 1
    
    return pas, no_of_labels

def connectivityLabel(processed_array_slice):
    '''
    This function takes in a thresholded image slice with blobs and clusters different blobs based on connectivity
    Check this documentation for more information (https://docs.scipy.org/doc/scipy/reference/generated/scipy.ndimage.label.html)
    Inputs:
        processed_array_slice: A 2D NumPy array of the slice of blobs which needs to be clustered. This slice is assumed
                               to be a thresholded slice with blobs
    Outputs:
        label: An integer ndarray where each unique blob in input has a unique label in the returned array
        num_features: Number of labels found
        
    '''
    return ndi.label(processed_array_slice)


class SliceBySliceSegmenter():
    '''
    Object that takes a 3D image and does planar cuts on the image along a dimension specified. The Python object
    labels and measures various features of the blobs for each planar cut. It outputs its results in a final 
    labelled object and stores the other data in a Pandas dataframe
    '''
    def __init__(self, object_, orientation, spacing, func_name):
        '''
        Function to initialize the object
        Inputs:
            object_: A 3D image of the thresholded fiber image
            orientation: The orientation of the plane. Either xz or yz (z is assumed to be the height)
            spacing: The spacing of the image input as [spacing_x, spacing_y, spacing_z]
            func_name: The function to cluster blobs on a plane. Either 'DBSCAN' or 'Connectivity'
        '''
        function_dict = {'DBSCAN': DBSCAN_, 'Connectivity': connectivityLabel}
        self.object_ = object_.copy()
        self.orientation = orientation
        self.spacing = spacing
        self.zoomed_object = ndi.zoom(object_, spacing[::-1])
        self.slicing_fn, self.a, self.b, self.dim = two_dee_helper(orientation, spacing)
        self.slider = widgets.IntSlider(value=0, min=0, max=self.zoomed_object.shape[self.dim] - 1, 
                                  step=1,description='Plane Number:',
                                  disabled=False, continuous_update=True,
                                  orientation='horizontal',readout=True) 
        self.func = function_dict[func_name]
        self.properties = ('convex_image','label', 'bbox', 'area', 'bbox_area', 'centroid', 'convex_area', 'eccentricity', 
                           'equivalent_diameter', 'major_axis_length', 'minor_axis_length', 'perimeter', 'solidity')
        self.slice_info, self.labelled_object = self.process_object()
        self.colors = cm.rainbow(np.linspace(0, 1, self.slice_info['no_of_objects'].max() + 1))
    
    def process_object(self):
        '''
        This function creates a dataframe of features from the labelled slices
        '''
        df = pd.DataFrame()
        
        for slice_ in tqdm(range(self.zoomed_object.shape[self.dim])):
            array_slice = self.slicing_fn(self.zoomed_object, slice_)
            labelled_slice, no_of_objects = self.LabelsForSlice(array_slice)
            contours = self.ContoursForSlice(labelled_slice)
            
            if no_of_objects == 0:
                extra_data = pd.DataFrame({'slice': [slice_], 'no_of_objects': [0]})
                df = pd.concat([df, extra_data], sort=True)
            else:
                extra_data = pd.DataFrame(measure.regionprops_table(labelled_slice, properties = self.properties))
                extra_data['convex_perimeter'] = self.ConvexPerimeters(extra_data['convex_image'].values)
                extra_data['slice'] = [slice_]*len(extra_data)
                extra_data['no_of_objects'] = [no_of_objects]*len(extra_data)
                df = pd.concat([df, extra_data], sort=True)
                
            if slice_ == 0:
                labelled_3d_object = np.expand_dims(labelled_slice, axis=self.dim)
            else:
                labelled_3d_object = np.concatenate((labelled_3d_object, np.expand_dims(labelled_slice, axis=self.dim)), 
                                                    axis = self.dim)
        
        df['convexity_per'] = df['convex_perimeter']/df['perimeter']
        df['convexity_area'] = df['convex_area']/df['area']
        df['roundness'] = (4*np.pi*df['area'])/(df['convex_perimeter'])**2
        
        return df.reset_index(drop=True), labelled_3d_object
    
    def LabelsForSlice(self, processed_array_slice):
        '''
        This function labels the slices
        '''
        objects, no_of_objects = self.func(processed_array_slice)
        assert len(np.unique(objects)) - 1 == no_of_objects, f'''Issue with Labelling Function'''
        
        return objects, no_of_objects
    
    def ContoursForSlice(self, processed_array_slice):
        '''
        This function draws contours around unique blobs
        '''
        contours = []
        for i in range(1,len(np.unique(processed_array_slice))):
            cont = measure.find_contours(processed_array_slice == i, 0.5)
            
            if len(cont) > 1:
                pers = list(map(lambda x: len(x), cont))
                ind = pers.index(max(pers))
                cont = [cont[ind]]
                
            contours.extend(cont)
            
        return contours
    
    def ConvexPerimeters(self, convex_images):    
        '''
        This function finds the perimeter of convex images
        '''
        return list(map(lambda x: measure.perimeter(x, neighbourhood=4), convex_images))
        
    
    def plotSliceOverlay(self, slice_):
        '''
        This function returns a 3x1 subplot of the planar cuts
        '''
        
        fig, ax = plt.subplots(3,1, figsize=(16,12))
        object_to_show = self.slicing_fn(self.zoomed_object, slice_)
        ax[1].imshow(object_to_show)
        slice_info = self.slice_info[self.slice_info['slice'] == slice_]
        for i, (_, row) in enumerate(slice_info.iterrows()):
            ax[1].scatter(row['centroid-1'], row['centroid-0'], color=self.colors[i], marker='x', label=row['label'])
            ax[1].annotate(f"DF_index: {_}|Label: {row['label']}",
                           (row['centroid-1'] + 2, row['centroid-0'] - 2),
                           color='red')

        ax[1].set_title("Slice with Centroids Overlayed")
        
        labels_to_show = self.slicing_fn(self.labelled_object, slice_)
        ax[2].imshow(labels_to_show)
        ax[2].set_title(f"Labelled Slice. {slice_info.no_of_objects.unique()[0]} Objects Detected")
        contours = measure.find_contours(labels_to_show, 0.5)
        for n, contour in enumerate(contours):
            ax[2].plot(contour[:, 1], contour[:, 0], linewidth=2)
        
        ax[0].imshow(object_to_show)
        ax[0].set_title("Slice Without Overlay")
        
        return ax
    
    def widget(self):
        '''
        This function outputs the widget
        '''
        out = widgets.interactive_output(self.plotSliceOverlay, {'slice_': self.slider})
    
        vertical_box = widgets.VBox([widgets.VBox([self.slider]), out])
        
        return vertical_box