# Future of Parking
The Future of Parking is an application that simulates and visualizes parking utilization for passenger vehicles in hypothetical scenarios into the future.

![Future of Parking Simulation by Ira Winder](screenshots/Screen%20Shot%202018-03-05%20at%202.50.33%20PM.png?raw=true "Future of Parking Simulation by Ira Winder")

## How to Use

Clone the repo and open *FutureParking.pde* with [Processing3](https://processing.org/download/)

## Structure

Main Tab Map:

      "A_" denotes high layer of organization on par with FutureParking.pde
      FutureParking.pde - highest level layer containing most interdependencies and complexity
      A_Draw.pde        - might as well be in FutureParking.pde but placed in it's own tab for ease of editing
      A_Parking.pde     - might as well be in FutureParking.pde but placed in it's own tab for ease of editing
      Agent.pde, Camera.pde, Pathfinder.pde, Toolbar.pde - Primitive class modules with no interdependencies

Primary Classes:

      These are not necessarily inter-dependent

      Parking_System()     - Mathematically realated parameters to forcast vheicle and parking demand over time using logistic equations   
      Parking_Structures() - A portfolio of Parking Structures (Surface, Below Ground, and Above Ground)
      Agent()              - A force-based autonomous agent that can navigate along a series of waypoints that comprise a path
      Camera()             - The primary container for implementing and editing Camera parameters
      ToolBar()            - Toolbar that may implement ControlSlider(), Radio Button(), and TriSlider()

Data Input:
      
      A simulation is populated with the following structured data CSVs, usually exported from
      ArcGIS or QGIS from available OSM files:

      Vehicle Road Network CSV
      Comma separated values where each node in the road network 
      represented as a row with the following 3 columns of information (i.e. data/roads.csv):
        
          X (Lat), Y (Lon), Road_ID

      Parking Structure Nodes CSV
      Comma Separated values where each row describes a 
      parking structure (i.e. data/parking_nodes.csv):

          X (Lat), Y (Lon), Structure_ID, Structure_Type, Area [sqft], Num_Spaces

      Parking Structure Polygons CSV
      Comma Separated values where each row describes a 
      node of a parking structure polygon in the order that it is drawn (i.e. 
      data/parking_poly.csv):

          X (Lat), Y (Lon), Structure_ID, Structure_Type, Area [sqft], Num_Spaces
 
