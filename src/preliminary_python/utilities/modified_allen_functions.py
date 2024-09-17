import itk 
import numpy as np

def edge_preserving_smoothing_3d(struct_img, spacing = [1,1,1], numberOfIterations=5, conductance=1.2, timeStep=0.05):
    '''
    Returns a smoothed image using the Perona Malik anisotropic diffusion smoothing
    Inputs:
        image: Image to be smoothed as a numpy array
        spacing: Spacing of the image provided as a list of [x-spacing, y-spacing, z-spacing]
        numberOfIterations: number of iterations to run smoothing
        conductance: parameter for smoothing. Controls how much the diffusion happens
        timeStep: parameter for diffusion equation. Should be kept below (pixelspacing)/2^(N+1) according to ITK documentation
    '''
    
    itk_img = itk.GetImageFromArray(struct_img.astype(np.float32))
    itk_img.SetSpacing(spacing)

    gradientAnisotropicDiffusionFilter = itk.GradientAnisotropicDiffusionImageFilter.New(itk_img)
    gradientAnisotropicDiffusionFilter.SetNumberOfIterations(numberOfIterations)
    gradientAnisotropicDiffusionFilter.SetTimeStep(timeStep)
    gradientAnisotropicDiffusionFilter.SetConductanceParameter(conductance)
    gradientAnisotropicDiffusionFilter.Update()

    itk_img_smooth = gradientAnisotropicDiffusionFilter.GetOutput()

    img_smooth_ag = itk.GetArrayFromImage(itk_img_smooth)
    
    return img_smooth_ag