<h1>Automatic Number Plate Detection</h1>


Vehicle nameplate detection is crucial for automated vehicle identification systems, widely used in traffic management and security applications. This report presents an effective method for detecting vehicle nameplates using image processing techniques.
<br>
<b>Methods:</b> Images were collected from the local area and then read and displayed in their original form. To simplify the image, it was converted from RGB to grayscale. The grayscale image was sharpened to highlight edge details, followed by the application of the Sobel operator for edge detection. The detected edges were further processed using image dilation with a specific structuring element. Edge processing was performed in both horizontal and vertical directions, utilizing histograms to identify significant edge information. Dynamic thresholding was then applied to filter out irrelevant edges, identifying likely candidates for the number plate based on histogram analysis.
<br>
This method enhances and detects edges in the vehicle image, facilitating the identification of regions with high edge intensity, typically corresponding to the nameplate area. The horizontal and vertical edge histograms indicate the plate’s position. The final processed image highlights the probable nameplate area with reduced noise and irrelevant edges.
<br>
<b>Results:</b> The combination of image sharpening, Sobel edge detection, and histogram-based edge processing effectively isolates the vehicle nameplate from the background. Dynamic thresholding ensures that only significant edges are retained, improving detection accuracy.
<br>
<b>Conclusion:</b> This approach demonstrates a robust method for vehicle nameplate detection using image processing techniques. The method’s capability to enhance and detect edges, combined with histogram analysis, provides a reliable solution for automated vehicle identification systems. Further improvements could be achieved by incorporating machine learning algorithms to enhance detection accuracy and adaptability to various image conditions.