clc;
clear all;
close all;

% Reading and displaying the original image:
originalImage = imread('Vehicle 1.jpg');
figure(1);
imshow(originalImage);
title('Original Image');

% Converting the RGB image to grayscale:
grayImage = rgb2gray(originalImage); 
figure(2);
imshow(grayImage);
title('Gray Image');

% Sharpen the image:
sharpenedImage = imsharpen(grayImage, 'Radius', 2, 'Amount', 1);
figure(3);
imshow(sharpenedImage);
title('Sharpened Image');

% Applying Sobel operator for edge detection:
sobelKernelX = [-1 0 1; -2 0 2; -1 0 1];
sobelKernelY = [-1 -2 -1; 0 0 0; 1 2 1];

edgesX = imfilter(double(sharpenedImage), sobelKernelX, 'replicate');
edgesY = imfilter(double(sharpenedImage), sobelKernelY, 'replicate');
edgeMagnitude = sqrt(edgesX.^2 + edgesY.^2);

figure(4);
imshow(edgeMagnitude, []);
title('Edge Detected Image using Sobel Operator');

% Proceeding with image dilation
dilatedEdges = edgeMagnitude;
structuringElement = strel('line', 3, 90);
dilatedEdges = imdilate(dilatedEdges, structuringElement);

figure(5);
imshow(dilatedEdges, []);
title('Dilated Image');

% Initializing variables for edge processing:
[imageRows, imageCols] = size(dilatedEdges);
difference = 0;
horizontalSum = 0;
totalHorizontalSum = 0;
difference = uint32(difference);

% Processing edges in the horizontal direction:
maxHorizontalSum = 0;
horizontalMaxIndex = 0;
horizontalEdgeHistogram1 = zeros(1, imageCols);
for col = 2:imageCols
    horizontalSum = 0;
    for row = 2:imageRows
        if(dilatedEdges(row, col) > dilatedEdges(row-1, col))
            difference = uint32(dilatedEdges(row, col) - dilatedEdges(row-1, col));
        else
            difference = uint32(dilatedEdges(row-1, col) - dilatedEdges(row, col));
        end
        if(difference > 20)
            horizontalSum = horizontalSum + difference;
        end
    end
    horizontalEdgeHistogram1(col) = horizontalSum;
    if(horizontalSum > maxHorizontalSum)
        horizontalMaxIndex = col;
        maxHorizontalSum = horizontalSum;
    end
    totalHorizontalSum = totalHorizontalSum + horizontalSum;
end

averageHorizontalSum = totalHorizontalSum / imageCols;
figure(6);
subplot(3,1,1);
plot(horizontalEdgeHistogram1);
title('Horizontal Edge Processing Histogram');
xlabel('Column Number ->');
ylabel('Difference ->');

% Smoothing the horizontal histogram using a low pass filter:
horizontalEdgeHistogram = horizontalEdgeHistogram1;
for col = 21:(imageCols-21)
    horizontalSum = 0;
    for j = (col-20):(col+20)
        horizontalSum = horizontalSum + horizontalEdgeHistogram1(j);
    end
    horizontalEdgeHistogram(col) = horizontalSum / 41;
end
subplot(3,1,2);
plot(horizontalEdgeHistogram);
title('Histogram after passing through Low Pass Filter');
xlabel('Column Number ->');
ylabel('Difference ->');

% Filtering out horizontal histogram values using dynamic threshold:
for col = 1:imageCols
    if(horizontalEdgeHistogram(col) < averageHorizontalSum)
        horizontalEdgeHistogram(col) = 0;
        for row = 1:imageRows
            dilatedEdges(row, col) = 0;
        end
    end
end
subplot(3,1,3);
plot(horizontalEdgeHistogram);
title('Histogram after Filtering');
xlabel('Column Number ->');
ylabel('Difference ->');

% Processing edges in the vertical direction:
difference = 0;
totalVerticalSum = 0;
difference = uint32(difference);
maxVerticalSum = 0;
verticalMaxIndex = 0;
verticalEdgeHistogram1 = zeros(1, imageRows);
for row = 2:imageRows
    verticalSum = 0;
    for col = 2:imageCols
        if(dilatedEdges(row, col) > dilatedEdges(row, col-1))
            difference = uint32(dilatedEdges(row, col) - dilatedEdges(row, col-1));
        else
            difference = uint32(dilatedEdges(row, col-1) - dilatedEdges(row, col));
        end
        if(difference > 20)
            verticalSum = verticalSum + difference;
        end
    end
    verticalEdgeHistogram1(row) = verticalSum;
    if(verticalSum > maxVerticalSum)
        verticalMaxIndex = row;
        maxVerticalSum = verticalSum;
    end
    totalVerticalSum = totalVerticalSum + verticalSum;
end

averageVerticalSum = totalVerticalSum / imageRows;
figure(7);
subplot(3,1,1);
plot(verticalEdgeHistogram1);
title('Vertical Edge Processing Histogram');
xlabel('Row Number ->');
ylabel('Difference ->');

% Smoothing the vertical histogram using a low pass filter:
verticalEdgeHistogram = verticalEdgeHistogram1;
for row = 21:(imageRows-21)
    verticalSum = 0;
    for j = (row-20):(row+20)
        verticalSum = verticalSum + verticalEdgeHistogram1(j);
    end
    verticalEdgeHistogram(row) = verticalSum / 41;
end
subplot(3,1,2);
plot(verticalEdgeHistogram);
title('Histogram after passing through Low Pass Filter');
xlabel('Row Number ->');
ylabel('Difference ->');

% Filtering out vertical histogram values using dynamic threshold:
for row = 1:imageRows
    if(verticalEdgeHistogram(row) < averageVerticalSum)
        verticalEdgeHistogram(row) = 0;
        for col = 1:imageCols
            dilatedEdges(row, col) = 0;
        end
    end
end
subplot(3,1,3);
plot(verticalEdgeHistogram);
title('Histogram after Filtering');
xlabel('Row Number ->');
ylabel('Difference ->');

% Displaying the final processed image:
figure(8);
imshow(dilatedEdges, []);
title('Final Processed Image');

% Finding probable candidates for the number plate:
probableColumns = [];
probableRows = [];
index = 1;
for col = 2:imageCols-2
    if(horizontalEdgeHistogram(col) ~= 0 && horizontalEdgeHistogram(col-1) == 0 && horizontalEdgeHistogram(col+1) == 0)
        probableColumns(index) = col;
        probableColumns(index+1) = col;
        index = index + 2;
    elseif((horizontalEdgeHistogram(col) ~= 0 && horizontalEdgeHistogram(col-1) == 0) || (horizontalEdgeHistogram(col) ~= 0 && horizontalEdgeHistogram(col+1) == 0))
        probableColumns(index) = col;
        index = index+1;
    end
end
index = 1;
for row = 2:imageRows-2
    if(verticalEdgeHistogram(row) ~= 0 && verticalEdgeHistogram(row-1) == 0 && verticalEdgeHistogram(row+1) == 0)
        probableRows(index) = row;
        probableRows(index+1) = row;
        index = index + 2;
    elseif((verticalEdgeHistogram(row) ~= 0 && verticalEdgeHistogram(row-1) == 0) || (verticalEdgeHistogram(row) ~= 0 && verticalEdgeHistogram(row+1) == 0))
        probableRows(index) = row;
        index = index+1;
    end
end

[temp, columnCount] = size(probableColumns);
if(mod(columnCount, 2))
    probableColumns(columnCount+1) = imageCols;
end
[temp, rowCount] = size(probableRows);
if(mod(rowCount, 2))
    probableRows(rowCount+1) = imageRows;
end

% Interest Extraction:
for row = 1:2:rowCount
    for col = 1:2:columnCount
        if(~((horizontalMaxIndex >= probableColumns(col) && horizontalMaxIndex <= probableColumns(col+1)) && (verticalMaxIndex >= probableRows(row) && verticalMaxIndex <= probableRows(row+1))))
            for r = probableRows(row):probableRows(row+1)
                for c = probableColumns(col):probableColumns(col+1)
                    dilatedEdges(r, c) = 0;
                end
            end
        end
    end
end
figure(9);
imshow(dilatedEdges, []);
title('Final Image');
