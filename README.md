# Person Specific Gesture Set Selection Algorithm Comparison

----
## Intro
Code to support my work on selecting the best movements/gestures for an individual from a pool to optimise gesture classification from Electromyography (EMG) signals.

* Based on data from the [open source NINAPRO database 1](http://ninapro.hevs.ch/) which is not included in this repository but can be obtained via the link
    - 27 subjects
    - 53 movements (52 + "rest")
    - 10 repetitions of each (except "rest")

* My results are included however for perusal

* Distributed under a modified MIT Licence
    - For academic works please reference with the following key information: A. Hartwell (2016), "Person-Specific Gesture Set Selection Software"

* Associated paper will be available via 2016 38th Annual International Conference of the IEEE Engineering in Medicine and Biology Society (EMBC) entitled "Person-Specific Gesture Set Selection for Optimised Movement
Classification from EMG Signals"
    * This paper should be consulted for in-depth details on the processes used and result analysis

----
## Results
If you just want to review my results usage is simple:

* The selection of movements by each algorithm for each subject can be found in the "gestureOrders" folder
    - Format is "rest" movement followed by the next most differentiable movement then the next movement that is most differentiable from the first two and so on
    - Algorithms are:
        - Arbitary order to serve as baseline: computational overhead is high therefore the movements are picked in the order they were acquired for the database [they were acquired for the database](http://ninapro.hevs.ch/)
        - Maximisation of minimum euclidian distance between movement means
        - Maximisation of minimum symmetric Kullback-Leibler Divergence between movements
        - Selection of superset highest performance movements i.e. when classifying all 53 movments simultaneously take the order from highest to lowest performance on individual movements (still taking "rest" first)
    - getGestureOrders.m will generate these orderings for each subject except for superset ordering which is provided based on previous results

* The "results" folder contains .mat files with predictions based on the five classifiers trained for each selection algorithm on each subject for each number of movements
    - Movements pools covered are from 2-53 movements
    - The associated correct outputs are included in each file
    - The only feature under consideration is the Mean Absolute Value calculated across 40 sample windows
    - The classifiers used are:
        - K Nearest Neighbours (KNN)
            - 10 Neighbours
            - Euclidian distance
        - Linear Discriminant Analysis (LDA)
            - Pseudo-linear fitting
        - Support  Vector  Machine  with  Radial  Basis  Function Kernel (SVM-RBF)
            - One vs All
            - Sequential Minimal Optimisation
            - Box constraint of 1
            - Heuristic kernel scaling
        - Support Vector Machine with Linear Kernel (SVM-L)
            - One vs one
            - Sequential Minimal Optimisation
            - Heuristic kernel scaling
        - Decision Tree (DT)
            - Maximum number of decision splits: 150
            - Gini's Diversity Index
            - Prior probability from class frequency
    - Total time taken to train classifiers is also included in the files for reference

* Performance metric used is the Average Accuracy per subject and then the average across the 27 subjects


----
## Reproduction
Should you wish to reproduce my results :
1. Download all the files from [NINAPRO database 1](http://ninapro.hevs.ch/) into the "db1" folder

2. Run "extractFeatures.m" which will extract the Mean Absolute Value feature in 40 sample windows across the whole dataset for every subject and save the results into the folder "db1_feat"

3. Run "extractGesture.m" which will extract arrays indicating which movement is going on in a window using both the latest sample in a window and majority vote into the "gesture" folder

4. Run "extractRepetition.m" which will extract an array representing the repetition taking place into the folder "repetition", note that this array is used for training and testing split and so it will also provide a dead zone around each movement and label "rest" movements as belonging to the proceeding repetition

5. Optionally run "getGestureOrders.m" although the necessary files are provided

6. Run the four "trainClassifiersGestureSet..." scripts will train classifiers for the different algorithically selected movements sets using movement pools of 2-53 movements and save the predictions into the "results" folder, this will take a long time to run ~10mins for 2 movements and ~8-9hours for 53 movements also note this will overwrite the current contents of the "results" folder

7. Run "compileResults.m" and then "plotGraphs.m" to calculate Average Accuracy of classifiers and then average across subjects plus plot a nice graph
