//SX Fiji Macro for Image Analysis
//This macro allows the semi-automatic segmentation of fluorescence bioimaging data.
//The segmentation in ROIs will be based on the "reference channel" and the intensity
//of all other channels is measured in these ROIs and saved as an XLS file.
//for the analysis of these files see for example our tool "Fiji measurement analyzer" on
//https://github.com/QuantitativeVirology/FIJI-Measurement-Analyzer

run("Set Measurements...", "area mean redirect=None decimal=3");
Dialog.create("Settings");
Dialog.addCheckbox("Binary analysis - make threshold in every channel", false);
Dialog.addCheckbox("Reference channel needs to be measured", false);
Dialog.addCheckbox("Channels are in one file", true);
Dialog.addNumber("How many channels must be measured", 3);
Dialog.addNumber("Blurryness factor for reference channel", 15);
Dialog.addString("File extension", ".nd2")
Dialog.show();
binary = Dialog.getCheckbox();
ref = Dialog.getCheckbox();
onefile = Dialog.getCheckbox();
channel = Dialog.getNumber();
sigma = Dialog.getNumber();
ext = Dialog.getString();
sigma = "sigma="+ d2s(sigma,0);
//make threshold in the reference channel to create ROIs for measurement in the other channels
if (onefile) {
	dir = File.directory;
	run("Split Channels");
	
	imagelist = getList("image.titles");
	Dialog.create("Reference Channel");
	Dialog.addRadioButtonGroup("Select reference channel and press OK, or cancel to exit macro:", imagelist, imagelist.length, 1, imagelist[0]);
	Dialog.show();
	refchannel = Dialog.getRadioButton();
	selectWindow(refchannel);
	//waitForUser("Select reference channel and press OK, or cancel to exit macro");
	//wait(2000);
	name = getTitle();
	//print("Title of reference channel: " + name);
	name = substring(name, 3);
	name = replace(name, ext, "_");
}	else {
		waitForUser("Select reference channel and press OK, or cancel to exit macro");
		dir = File.directory;
		name = getTitle();
		//print("Title of reference channel: " + name);
		name = replace(name, ext, "_");
	}

if (ref) {
	run("Duplicate...", " ");
}
//run("8-bit");
run("Gaussian Blur...", sigma);
nameGauBlur = getTitle();
//print("Title of ref. ch. for Gaussian Blur: " + nameGauBlur);
run("Threshold...");
waitForUser("set the threshold and press OK, or cancel to exit macro");
run("Convert to Mask");
run("Watershed");
run("Analyze Particles...", "clear add");

//Do measurements in the other channels
for  (i=0; i<channel; i++) {
	waitForUser("Select the next channel and press OK, or cancel to exit macro");
	channelname = getString("Enter Channel Name. Channel name will be added to the name of the result file", "i.e. CH2");
	//run("8-bit");
	if (binary){
		run("Gaussian Blur...", sigma);
		setAutoThreshold("Default dark");
		run("Threshold...");
		waitForUser("set the threshold and press OK, or cancel to exit macro");
		run("Convert to Mask");
	}
	roiManager("Show All");
	roiManager("Measure");
	filename = dir+name+channelname+".csv";
	saveAs("Results", filename);
	IJ.deleteRows(0, 10000);
	run("Close");
}
roiManager("Delete");
run("Close All");
