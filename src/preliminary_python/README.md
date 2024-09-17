# Python Code Setup Instructions
Here are instructions for setting up your Python environment and using the functions within this folder. I adapted these instructions from [here](https://github.com/AllenInstitute/aics-segmentation/blob/master/docs/installation_windows.md). The instructions worked perfectly fine on my Windows Machine - you might need to adapt it for a Mac or Ubuntu.

<hr>

**Author:** Dylan Mendonca

**Last Edited:** 8-October-2020

<hr>

## Step 1: Install conda and git

*Go to Step 2 if you have anaconda or miniconda and git installed on your computer*

Go to [Install conda on Windows](https://docs.conda.io/projects/conda/en/latest/user-guide/install/windows.html), choose Anaconda Installer (for Python 3) and then follow the installation instructions.

Note: [What is conda and anaconda, and why we need this?](conda_why.md) Because conda can effectively manage environment and package installation, setting up conda will make the following steps straightforward and help avoid future problems (conda itself is also very easy to set up).

## Step 2: Setting Up Virtual Environment with Conda

### Step 2.1: Create a conda environment with Python version below (you can use whatever name, I used segmentation_env)
```
conda create -n segmentation_env python=3.6
```

### Step 2.2: Activate conda environment
```
conda activate segmentation_env
```

You can deactivate a conda environment by running:
```
conda deactivate
```


## Step 3: Installing Requirements
### Step 3.1: Install nb_conda (for easy conda environment management in jupyter notebook)

```
conda install nb_conda
```

#### Step 3.2: Install other requirements

```
pip install -r requirements.txt
```

## Step 4: Launch the Jupyter Notebook
Once you have the environment activated and all the above done, you should be able to launch your notebook environment properly. Just run:
```
jupyter notebook
```

This will take you to your default browser and launch Jupyter Notebook App within your browser. Open "notebooks/final_notebook.ipynb" and check if you can run the entire notebook from beginning to the end. 

> **Note:** You should have the conda environment activated before you do Step 4.

## Folder Structure

The folder contains the following sub-directories:

- `notebooks`: Contains the notebooks where you can get a tutorial on some of the functions I created and you can implement the preliminary pipeline
- `utilities`: Contains Python scripts with the functions that are used in the notebooks
- `requirements.txt`: Contains the packages that you need installed in your conda environment

## Questions/Comments

If you have any issues with setting up the environment or running the notebooks, please reach out to me at dylanmendonca@gmail.com and I'll do my best to help out.