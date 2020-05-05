# UIBuilder application

Read this file to understand the nitty-gritty and inner working of the app

## Demo

A guide on the workflow as well as a demo of the code can be found [here](https://youtu.be/d4p888eFUxg).

## Important Note on Application
Currently, the apiStubs.swift file holds an encoding and decoding method that only applies to the beatBox user story. To truly make use of this app beyond that user story, the apiStubs functions must be replaced with a full encoder and decoder method

## iPhone Application

The iphone application should allow you to scan peripheral devices that comply to our protocol and choose
which one to connect to. 

- Turn on the "Start Scanning" button in order to scan for peripherals. 
- Tap on a device you would like to connect to 
- A red tick should appear on the far right of the device name. This signifies an attempt to connect to the device. 
- A continual red tick means the system is struggling to create a connection with the device. The connection can
be automatically dropped, or you can drop it yourself. 
- If a connection is successful, a green tick should appear, and a popup window with your device user interface should be presented. 
- Labels should automatically update, but switches and volume can only send data once you tap the refresh button
located on the naviagtion bar. 
- VERY IMPORTANT THING TO NOTE: If a connection takes too long to be successful, drop it and try to connect again. The refresh button only sends slider and switch value changes. It's good practice to move switches and sliders even if you bring them back to their original values in the beginning. We do this to make sure the peripheral has the values you see on the iPhone app. If a peripheral volume starts at 50 and the app popup has an initial volume of 0, if you do not move the volume, the peripheral will keep the 50 because we only send values if there are changes. 

- You can also change the connection to a different device, even if you have been controling another. 
- Please note that there are lags in value updates on the peripheral device. It is not automatic. 


## iPad Application

The iPad workflow starts from the project menu where you must select or add a new project from which to work in. Once you do that, you will transistion to the master-detail view that allows you to drag and drop UI items onto the iPhone outline. Only drops within the screen of the iPhone are permitted. 

After an initial drop, the item should appear with a red box around it which symbolizes that it is not initialized. In order to initialize or delete the object, just tap on the item and a small popup will show "Edit" or "Delete" options. 

Within editing, the label field represents the text for the label to be added to the item you selected on the screen. The name field is not displayed in the frontend, but instead is used for UUID identification when saving.

Once initializing all the items on the iPhone screen, you can click the "Save Project" button and observe the UUIDs needed in order to generate this project on your iPhone. Pressing the "Exit" button will return you to the Project Menu where you can select or create a new project to work on.

### iPad Final Function List

- Complete UI builder of switches, sliders, and labels
- Drag and drop interface with alignment aids
- Presentation of UUIDs for services and characteristics specific to the app design
- Storage and loading of multiple projects with editing allowed
- View resizing for all subviews on iPhone screen during orientation change (NOTE: Resizing is done for every UI item except for UISwitch. This is because UISwitch is an old API that has a locked intrinsic height. More discussion of this can be seen on this [StackOverflow](https://stackoverflow.com/questions/25104605/changing-uiswitch-width-and-height/25106983) post.)

## Adding New UI Elements

The creation and management of all the UI elements used within the iPad application is consolidated within the __ActionViewUtilities.swift__ file. All that would need to be done to add a new element would be to add the element throughout the methods and variables within this class. 

For the iPhone, to initialize the new UIElement in the backend, ensure that the "getView()" method in __DataModel.swift__ has the new view type in the switch statement, which returns the "type" which would appear in the json encoding for the UI element. To ensure that it gets added to the frontend and calls upon the correct actions, changes should be made to __iPhoneBuilderViewController.swift__. If the UIElement needs to be able to respond to actions, add a case for the view in __ActionViewUtilities.swift__ in the __addTarget__ method. You need an __@obj func__ for each new UIElement so the right action is taken when changes are triggered. In __func setUpEventsTarget__, set up the target of the UIElement. 

