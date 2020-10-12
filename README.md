# CSIPostProcess
BenzetimCSI is a post-process tool for numerical model CSI (Baykal et al., 2007). CSI model is an one-line model for shoreline change in the presence of a/various coastal structure. CSI produces numerical models in a straight shoreline. With this post-process tool, results can be superimposed on an arbitrary shoreline. BenzetimCSI.m takes an arbitrary shoreline coordinates (shoreline.txt for input format), it grids the shoreline with same amount of  increments and calculates shoreline orientation as degree in these mesh points. It takes CSI Output figure as input or x and y coordinates of CSI model output can be provided to the tool. It will add these results to the arbitrary bathymetry and results can be seen in more realistic environment. Required inputs are listed as follows;
- Original shoreline coordinates
- Start of x-coordinate corresponding in the original shoreline.
- Specification of input type, whether x and y coordinates or figure.
- Sample rate, default is set to 0.01, it can be changed if needed.
- Output filename
- Input filenames

For more information, please inspect BenzetimCSI.m's comments.

C. Özsoy
