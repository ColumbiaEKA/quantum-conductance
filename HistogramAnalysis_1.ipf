#pragma rtGlobals=1		// Use modern global access method.

macro PullOutAnalysis()
	PullOutInitialize()
	PullOut_Analysis()

	NewPath Relocate "C:\Users\Haixing\Documents\HaixingAnalysis"
	NewPath SavedHist "C:\Users\Haixing\Documents\HaixingAnalysis\SavedHist:"
	NewPath/O Saved2DHist "C:\Users\Haixing\Documents\HaixingAnalysis\Saved2DHist:"

end
Menu "PullOut"
"Decrease Included # /F2",/Q, DecreaseIncluded()2
"Increase Included # /F4",/Q, IncreaseIncluded()
"Remove Pull Out /F3",/Q, RemovePullOutNumber(" ")
End  

      

//	TempW[0] = MaxExcursion
//	TempW[1] = Rate
//	TempW[2] = EngageStepSize
//	TempW[3] = ExcursionOffset
//	TempW[4] = BiasSave
//	TempW[5] = StartX-StopX
//	TempW[6] = Actual_Bias
//	TempW[7] = CurrentGain
//	TempW[8] = ExtensionGain
//	TempW[9] = CurrentVoltConversion
//	TempW[10] = TipBias
//	TempW[11] = Bias
//	TempW[12] = SeriesResistance
//	TempW[13] = EngageConductance
//	TempW[14] = EngageDelay
//	TempW[15] = MaxIVBias
//	TempW[16] = RiseTime
//	TempW[17] = ExternalBiasCheck
//	TempW[18] = VoltageOffset
//	TempW[19] = CurrentSuppress


Function PullOutInitialize()
NewDataFolder/O root:Data

Variable/G root:Data:G_DisplayNum=1
Make/O/N=1 root:Data:POConductanceHist
Variable/G root:Data:G_SmoothCond=1
Variable/G root:Data:G_SmoothForce=0
Variable/G root:Data:G_SmoothType=3
Variable/G root:Data:G_SmoothLevel=11
Variable/G root:Data:G_SmoothRepeat=1
Variable/G root:Data:G_Total_Included=0
Variable/G root:Data:G_Hist_Bin_Size=.0001
Variable/G root:Data:G_Hist_Bin_Start=0
Variable/G root:Data:G_HighCutOff=2.0
Variable/G root:Data:G_zero_cutoff=0.0005
Variable/G root:Data:G_DisplayFromIncluded = 0
Variable/G root:Data:G_IncludedCurveNumber=0
Variable/G root:Data:G_RedimStart=0
Variable/G root:Data:G_RedimStop=1000
Variable/G root:Data:G_SaveHist=0
Variable/G root:Data:G_Noise=0
Variable/G root:Data:G_Offline=0	//Offline button
Variable/G root:Data:G_Setup=1	//Determines which setup is being used
Variable/G root:Data:G_Overwrite=0	//whether to overwrite saved histogram

Variable/G root:Data:G_ReadBlockCurrent=-1
Variable/G root:Data:G_ReadBlockVoltage=-1
Variable/G root:Data:G_ReadBlockConductance=-1
Variable/G root:Data:G_mergecheck=0

Variable/G root:Data:G_LoadIV=0
Variable/G root:Data:G_IVStartPt=0
Variable/G root:Data:G_IVEndPt=0
Variable/G root:Data:G_Counter
Variable/G root:Data:G_2DLog=1
Variable/G root:Data:G_AlignG=0.5
Variable/G root:Data:G_2Dxmin=-0.5
Variable/G root:Data:G_2Dxmax= 1.5


PathInfo Relocate
if (V_flag==1)
	Variable Slen=strlen(S_path)
	S_path=S_path[Slen-14,Slen-7]
endif

String/G root:Data:G_PathDate=""//S_path
String/G root:Data:G_Drive=""
String/G root:Data:G_histName=""		//Used in renaming functions in histogram analysis
String/G root:Data:G_axisName="left"		//Used in defining which axis range to change
String/G root:Data:G_LeftLabel="Conductance (G\B0\M)"	//Used in fixgraph and fixgraphbutton
String/G root:Data:G_BottomLabel="Displacement (nm)"		//Used in fixgraph and fixgraphbutton

Make/O/N=999 root:Data:IncludedNumbers=p+1
Make/O/T/N=7 root:Data:textWave0={"10\S1","10\S0", "10\S-1","10\S-2","10\S-3","10\S-4","10\S-5","10\S-6"}
Make/O/N=7 root:Data:wave0={1,0,-1,-2,-3,-4,-5,-6}

SetDataFolder root:Data
End

Window PullOut_Analysis() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(1266,172,1566,620)
	SetDrawLayer UserBack
	SetDrawEnv fsize= 14
	DrawText 213,412,"Counter"
	GroupBox box1,pos={21,34},size={250,116},title="Display Trace"
	GroupBox box1,font="Times New Roman",fSize=12
	SetVariable setvar4,pos={41,60},size={90,16},proc=DisplayPullOut,title="start #"
	SetVariable setvar4,limits={0,100000,1},value= root:Data:G_DisplayNum
	CheckBox check1,pos={164,61},size={91,14},title="Smooth Cond.?"
	CheckBox check1,variable= root:Data:G_SmoothCond
	SetVariable setvar0,pos={184,83},size={65,16},proc=DisplayPullOut,title="Type"
	SetVariable setvar0,limits={1,3,1},value= root:Data:G_SmoothType
	SetVariable setvar0_1,pos={184,105},size={65,16},proc=DisplayPullOut,title="Level"
	SetVariable setvar0_1,limits={1,100,1},value= root:Data:G_SmoothLevel
	GroupBox box101,pos={20,156},size={255,228},title="Histogram Analysis"
	GroupBox box101,font="Times New Roman",fSize=12
	ValDisplay valdisp0,pos={180,183},size={71,14},title="# Inc.",fSize=10
	ValDisplay valdisp0,format="%d",limits={0,0,0},barmisc={0,1000}
	ValDisplay valdisp0,value= #"root:Data:G_Total_Included"
	Button button102,pos={206,208},size={56,33},proc=DisplayHist,title="1D HIST"
	Button button102,labelBack=(65535,65535,65535),fSize=12,fStyle=0
	Button button102,fColor=(0,43520,65280)
	SetVariable setvar6,pos={28,183},size={71,16},proc=SetBinSize,title="Bin"
	SetVariable setvar6,limits={0,10000,0},value= root:Data:G_Hist_Bin_size
	SetVariable setvar0_2,pos={174,127},size={75,16},proc=DisplayPullOut,title="Repeat"
	SetVariable setvar0_2,limits={0,100,1},value= root:Data:G_SmoothRepeat
	SetVariable setvar12,pos={27,207},size={100,16},title="Hist Max",format="%3.1e"
	SetVariable setvar12,limits={0,10000,0},value= root:Data:G_HighCutOff
	CheckBox check2,pos={152,76},size={76,14},disable=1,proc=FilterPullOutData,title="Filter Force?"
	CheckBox check2,value= 0
	CheckBox check3,pos={152,98},size={90,14},disable=1,title="Smooth Force?"
	CheckBox check3,value= 0
	SetVariable setvar8,pos={102,183},size={75,16},title="Zero"
	SetVariable setvar8,limits={0,10000,0},value= root:Data:G_Zero_cutoff
	CheckBox check6,pos={39,94},size={91,14},proc=FromIncludedCheck,title="From Included?"
	CheckBox check6,value= 0
	SetVariable setvar14,pos={36,118},size={90,16},disable=1,proc=DisplayIncludedNumbers,title="Inc #"
	SetVariable setvar14,limits={0,50000,1},value= root:Data:G_IncludedCurveNumber
	SetVariable setvar3,pos={14,397},size={108,16},proc=ChangePath,title="Path"
	SetVariable setvar3,fStyle=1,value= root:Data:G_PathDate
	Button button0,pos={49,276},size={50,20},proc=RedimButton,title="Redim",fSize=12
	SetVariable setvar13,pos={29,252},size={65,16},title="Start",format="%d"
	SetVariable setvar13,limits={0,100000,0},value= root:Data:G_RedimStart
	SetVariable setvar15,pos={116,252},size={65,16},proc=SetRedimStopProc,title="Stop"
	SetVariable setvar15,format="%d"
	SetVariable setvar15,limits={0,100000,0},value= root:Data:G_RedimStop
	CheckBox check8,pos={204,253},size={64,14},title="Save Hist"
	CheckBox check8,variable= root:Data:G_SaveHist
	SetVariable setvar5,pos={133,397},size={56,16},title="Drive",fStyle=1
	SetVariable setvar5,value= root:Data:G_Drive
	Button button1,pos={115,276},size={63,20},proc=Plus1000,title="Plus1000"
	Button button1,fSize=12
	SetVariable setvar16,pos={14,417},size={50,16},title="Setup"
	SetVariable setvar16,limits={1,2,0},value= root:Data:G_Setup
	CheckBox check4,pos={204,281},size={63,14},title="Overwrite"
	CheckBox check4,variable= root:Data:G_Overwrite
	CheckBox check199,pos={74,417},size={54,14},title="Merged"
	CheckBox check199,variable= root:Data:G_mergecheck
	Button button5,pos={197,60},size={55,16},disable=1,proc=DisplayHistButton,title="Display"
	Button button5,fSize=12
	TitleBox title2,pos={27,134},size={57,13},disable=1,title="Axis Scaling",frame=0
	Button button6,pos={24,111},size={130,16},disable=1,proc=CopyCurrentTrace,title="Copy Current Trace"
	Button button6,fSize=12
	Button button8,pos={134,153},size={129,16},disable=1,proc=LinLinButton,title="Linear-Linear Scaling"
	Button button8,fSize=12
	Button button9,pos={25,153},size={103,16},disable=1,proc=LogLogButton,title="Log-Log Scaling"
	Button button9,fSize=12
	SetVariable setvar1,pos={26,85},size={234,16},disable=1,proc=HistogramSearch,title="Search"
	SetVariable setvar1,fStyle=0
	SetVariable setvar1,limits={-inf,inf,0},value= root:Data:G_histName,live= 1
	PopupMenu popup3,pos={20,59},size={151,21},bodyWidth=95,disable=1,proc=DisplayListMenu,title="Display List"
	PopupMenu popup3,mode=2,popvalue="wave0",value= #"\"textWave0;wave0;Conductance_D_Raw;Con_YWave;Con_XWave;\""
	Button button7,pos={28,540},size={60,16},disable=1,proc=FixGraphButton,title="FixGraph"
	Button button7,fSize=12
	Button button08,pos={93,192},size={75,16},disable=1,proc=FixGraphButton,title="FixGraph2D"
	Button button08,fSize=12
	Button button05,pos={174,192},size={95,16},disable=1,proc=UndoFixGraphButton,title="Undo FixGraph"
	Button button05,fSize=12
	ValDisplay valdisp0_1,pos={28,231},size={109,14},title="Noise",format="%2.3e"
	ValDisplay valdisp0_1,limits={0,0,0},barmisc={0,1000}
	ValDisplay valdisp0_1,value= #"root:Data:G_Noise"
	SetVariable setvar17,pos={26,359},size={80,16},title="IV Start",format="%d"
	SetVariable setvar17,limits={0,100000,0},value= root:Data:G_IVStartPt
	SetVariable setvar18,pos={114,359},size={80,16},title="IV End",format="%d"
	SetVariable setvar18,limits={0,100000,0},value= root:Data:G_IVEndPt
	CheckBox check5,pos={205,360},size={55,14},title="Load IV"
	CheckBox check5,variable= root:Data:G_LoadIV
	GroupBox box102,pos={18,37},size={259,181},disable=1,title="Histogram Display"
	GroupBox box102,font="Times New Roman",fSize=12
	Button button103,pos={206,313},size={56,33},proc=Hist2D,title="2D HIST"
	Button button103,labelBack=(65535,65535,65535),fSize=12,fStyle=0
	Button button103,fColor=(65535,16385,16385)
	SetVariable setvar19,pos={25,332},size={80,16},title="2D X min",format="%1.1f"
	SetVariable setvar19,limits={0,100000,0},value= root:Data:G_2Dxmin
	SetVariable setvar20,pos={117,331},size={80,16},title="2D X max",format="%1.1f"
	SetVariable setvar20,limits={0,100000,0},value= root:Data:G_2Dxmax
	CheckBox check7,pos={130,309},size={53,14},title="2D Log"
	CheckBox check7,variable= root:Data:G_2DLog
	SetVariable setvar21,pos={25,310},size={90,16},title="2D G Align",format="%1.2f"
	SetVariable setvar21,limits={0,100000,0},value= root:Data:G_AlignG
	Button button09,pos={134,133},size={129,16},disable=1,proc=LinLogButton,title="Linear-Log Scaling"
	Button button09,fSize=12
	TitleBox title3,pos={25,175},size={90,13},disable=1,title="Graph Appearance"
	TitleBox title3,frame=0
	TabControl Tab_0,pos={7,8},size={283,382},proc=TabProc,tabLabel(0)="Hist Anal."
	TabControl Tab_0,tabLabel(1)="Display",tabLabel(2)="Params",value= 0
	SetVariable servar0,pos={61,390},size={50,20},disable=1
	GroupBox box2,pos={71,156},size={154,225},disable=1,title="Parameters"
	GroupBox box2,labelBack=(56576,56576,56576),font="Times New Roman",fSize=14
	GroupBox box2,frame=0
	ValDisplay valdisp1,pos={85,181},size={125,14},disable=1,title="Speed (nm/s)"
	ValDisplay valdisp1,fStyle=1,limits={0,0,0},barmisc={0,1000}
	ValDisplay valdisp1,value= #"root:Data:POParameter_Display[1]"
	ValDisplay valdisp2,pos={85,203},size={125,14},disable=1,title="Distance (nm)"
	ValDisplay valdisp2,fStyle=1,limits={0,0,0},barmisc={0,1000}
	ValDisplay valdisp2,value= #"root:Data:POParameter_Display[0]"
	ValDisplay valdisp3,pos={85,249},size={125,14},disable=1,title="Applied V (V)"
	ValDisplay valdisp3,format="%3.3f",fStyle=1,limits={0,0,0},barmisc={0,1000}
	ValDisplay valdisp3,value= #"root:Data:POParameter_Display[10]/1000"
	ValDisplay valdisp4,pos={85,272},size={125,14},disable=1,title="Hit G            "
	ValDisplay valdisp4,format="%3.1f",fStyle=1,limits={0,0,0},barmisc={0,1000}
	ValDisplay valdisp4,value= #"root:Data:POParameter_Display[13]"
	ValDisplay valdisp5,pos={85,294},size={125,14},disable=1,title="Suppress I "
	ValDisplay valdisp5,format="%3.1e",fStyle=1,limits={0,0,0},barmisc={0,1000}
	ValDisplay valdisp5,value= #"root:Data:POParameter_Display[19]"
	ValDisplay valdisp6,pos={85,317},size={125,14},disable=1,title="Gain           "
	ValDisplay valdisp6,fStyle=1,limits={0,0,0},barmisc={0,1000}
	ValDisplay valdisp6,value= #"6-log(root:Data:POParameter_Display[9])"
	ValDisplay valdisp7,pos={85,340},size={125,14},disable=1,title="Bias Save      "
	ValDisplay valdisp7,fStyle=1,limits={0,0,0},barmisc={0,1000}
	ValDisplay valdisp7,value= #"root:Data:POParameter_Display[4]"
	ValDisplay valdisp8,pos={85,363},size={125,14},disable=1,title="Series R   "
	ValDisplay valdisp8,fStyle=1,limits={0,0,0},barmisc={0,1000}
	ValDisplay valdisp8,value= #"root:Data:POParameter_Display[12]"
	ValDisplay valdisp9,pos={85,226},size={125,14},disable=1,title="Actual D (nm)"
	ValDisplay valdisp9,fStyle=1,limits={0,0,0},barmisc={0,1000}
	ValDisplay valdisp9,value= #"root:Data:POParameter_Display[5]"
	ValDisplay Counter,pos={210,414},size={70,21},fSize=16,format="%d",fStyle=1
	ValDisplay Counter,limits={0,0,0},barmisc={0,1000},value= #"root:Data:G_Counter"
	Button button10,pos={25,192},size={63,16},disable=1,proc=FixGraphButton,title="FixGraph"
	Button button10,fSize=12
EndMacro

Function DisplayListMenu(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	SVAR G_histName = root:Data:G_histName
	
	switch( pa.eventCode )
		case 2: // mouse up
			G_histName = pa.popStr
			break
	endswitch

	return 0
End

Function HistogramSearch(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	SVAR G_histName = root:Data:G_histName
	String searchName = ""
	String searchList = ""
	
	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			G_histName = sva.sval
			searchName = "*" + G_histName + "*"
			searchList = WaveList(searchName, ";", "")
			searchList = "\"" + searchList + "\""	
			if (stringmatch(G_histName, "") == 1)
				searchList = "\"" + WaveList("PO*", ";", "") + WaveList("total*", ";","") + "\""
			endif	
			PopupMenu popup3 value=#searchList
			break
	endswitch

	return 0
End

Function DisplayHistButton(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	
	SVAR G_histName = root:Data:G_histName
	
	switch( ba.eventCode )
		case 2: // mouse up
			if (stringmatch(G_histName,"")==1) //if input is no name, then exit
				break
			endif
			
			switch(WaveDims($G_histname))
				case 0:
					Print "Wave does not exist"
					break
				case 1: 
					Display $G_histName
					break
				case 2:
					Display;AppendImage $G_histName
					ModifyImage $G_histName ctab= {*,150,Geo,1}
					break
			endswitch
			break
	endswitch

	return 0
End

Function DuplicateButtons(buttonType) : ButtonControl
	String buttonType
	
	SVAR G_histName = root:Data:G_histName
	String newName = G_histName
	Variable buttonNum = 0
	
	if (stringmatch(buttonType, "button2")) // LinHist
		buttonNum = 2
	elseif (stringmatch(buttonType, "button0")) // LogHist
		buttonNum = 0
	elseif (stringmatch(buttonType, "button1")) // 2DHist
		buttonNum = 1
	endif
		
	switch (buttonNum)
		case 2:
			if (WaveExists(POConductanceHist)==0) //checks if histogram has been made
				DoAlert 0, "No linear histogram found. Run histogram."
			elseif (stringmatch(G_histName,"")==1) //if input is no name, then exit
				break
			elseif (WaveExists($G_histName)==0) //if it is not a duplicate wave name then create wave
				Duplicate POConductanceHist $G_histName
			elseif (WaveExists($G_histName)==1) //if the wave name is in use, indicate that the wave is in use
				Prompt newName, "This wave name is in use. Please choose another name: "
				DoPrompt "Error", newName
				if(V_flag == 1)
					break
				endif
				G_histName = newName
				DuplicateButtons("button2")
			endif
			break
		case 0:
			if (WaveExists(POConductanceHistLog)==0) //checks if histogram has been made
				DoAlert 0, "No Log histogram found. Run histogram."
			elseif (stringmatch(G_histName,"")==1) //if input is no name, then exit
				break
			elseif (WaveExists($G_histName)==0) //if it is not a duplicate wave name then create wave
				Duplicate POConductanceHistLog $G_histName
			elseif (WaveExists($G_histName)==1) //if the wave name is in use, indicate that the wave is in use
				Prompt newName, "This wave name is in use. Please choose another name: "
				DoPrompt "Error", newName
				if(V_flag == 1)
					break
				endif
				G_histName = newName
				DuplicateButtons("button0")
			endif
			break
		case 1:
			if (WaveExists(total2dhist)==0) //checks if histogram has been made
				Prompt newName, "No 2D histogram found. Run histogram."
				DoPrompt "Error", newName
			elseif (stringmatch(G_histName,"")==1) //if input is no name, then exit
				break
			elseif (WaveExists($G_histName)==0) //if it is not a duplicate wave name then create wave
				Duplicate total2dhist $G_histName
			elseif (WaveExists($G_histName)==1) //if the wave name is in use, indicate that the wave is in use
				Prompt newName, "This wave name is in use. Please choose another name: "
				DoPrompt "Error", newName
				if(V_flag == 1)
					break
				endif
				G_histName = newName
				DuplicateButtons("button1")
			endif
			break
	endswitch

	return 0
End

Function CopyCurrentTrace(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	
	NVAR G_DisplayNum = root:Data:G_DisplayNum
	String traceName
	
	switch( ba.eventCode )
		case 2: // mouse up
			traceName = "Trace" + num2str(G_DisplayNum)
			Duplicate /O POConductance_Display $traceName	
			break
	endswitch

	return 0
End

Function FixGraphButton(ctrlName) : ButtonControl
	String ctrlName
	
	SVAR G_LeftLabel = root:Data:G_LeftLabel
	SVAR G_BottomLabel = root:Data:G_BottomLabel
		
	if ((stringmatch(GetAxisLabel("", "left"), "Conductance (G\B0\M)") == 1)&&(stringmatch(GetAxisLabel("", "bottom"), "Displacement (nm)")==1))
		//Do Nothing
	elseif ((stringmatch(GetAxisLabel("", "left"), "Counts") == 1)&&(stringmatch(GetAxisLabel("", "bottom"), "Conductance (G\B0\M)")==1))
		//Do Nothing
	else
		G_LeftLabel = GetAxisLabel("", "left")
		G_BottomLabel = GetAxisLabel("", "bottom")
	endif
	
	ModifyGraph axisOnTop=1
	ModifyGraph tick=2,fSize=14,axThick=1.5,standoff=0
	ModifyGraph mirror=2
	if (stringmatch(ctrlName, "button08") == 1)
		Label left "Conductance (G\B0\M)";DelayUpdate
		Label bottom "Displacement (nm)"
		ModifyGraph userticks(left)={wave0,textWave0}
	elseif (stringmatch(ctrlName, "button10") == 1)
		Label left "Counts";DelayUpdate
		Label bottom "Conductance (G\B0\M)"
	endif	
end

Function UndoFixGraphButton(ctrlName) : ButtonControl
	String ctrlName
	String temp_LeftLabel
	String temp_BottomLabel
	
	SVAR G_LeftLabel = root:Data:G_LeftLabel
	SVAR G_BottomLabel = root:Data:G_BottomLabel
	
	temp_LeftLabel = G_LeftLabel
	temp_BottomLabel = G_BottomLabel 

	G_LeftLabel = GetAxisLabel("", "left")
	G_BottomLabel = GetAxisLabel("", "bottom")
	
	ModifyGraph axisOnTop=1
	ModifyGraph tick=2,fSize=14,axThick=1.5,standoff=0
	ModifyGraph mirror=2
	Label left temp_LeftLabel;DelayUpdate
	Label bottom temp_BottomLabel
end

Function SetRange(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva
	
	NVAR G_axisMin = root:Data:G_axisMin
	NVAR G_axisMax = root:Data:G_axisMax
	SVAR G_axisName = root:Data:G_axisName
	
	switch( sva.eventCode )
		case 2: // mouse up
			SetAxis $G_axisName G_axisMin, G_axisMax
			break
	endswitch

	return 0
End

Function SetAxisMenu(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa
	
	NVAR G_axisMin = root:Data:G_axisMin
	NVAR G_axisMax = root:Data:G_axisMax
	SVAR G_axisName = root:Data:G_axisName
	
	switch( pa.eventCode )
		case 2: // mouse up
			PopupMenu popup0 value=AxisList("")
			G_axisName = pa.popStr
			
			GetAxis /Q $G_axisName
			G_axisMin = V_min
			G_axisMax = V_max
			break
	endswitch

	return 0
End

//Either use these or the leftaxisset functions
Function LogLogButton(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			ModifyGraph log(left)=1
			ModifyGraph log(bottom)=1
			break
	endswitch
End 

Function LinLinButton(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			ModifyGraph log(left)=0
			ModifyGraph log(bottom)=0
			break
	endswitch
End 

Function LinLogButton(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			ModifyGraph log(left)=1
			ModifyGraph log(bottom)=0
			break
	endswitch
End 

Function PartialHistButton(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba
	NVAR PartialHist=root:Data:G_PartialHist
	
	switch( cba.eventCode )
		case 2: // mouse up
			if (PartialHist==1)
				SetVariable setvar7 disable=0
				SetVariable setvar9 disable=0
			else
				SetVariable setvar7 disable=2
				SetVariable setvar9 disable=2
			endif
			break
	endswitch

	return 0
End



Function SetBinSize(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	NVAR HighCutOff = root:Data:G_HighCutOff
	
	if (varNum==0.0001)
		HighCutOff=2.0
	else
		HighCutOff=varNum*10000
	endif
	

End

Function ChangePath(ctrlName,varNum,NPath,varName) : SetVariableControl
	String ctrlName,NPath, varName
	Variable varNum
	String Link
	NVAR MergeCheck=root:Data:G_Mergecheck
	NVAR Setup=root:Data:G_Setup

	Variable i,j
	
	Link = "Data:"
	
	SVAR CurrentPath=root:Data:G_PathDate
	SVAR Drive=root:Data:G_Drive
	String OldFullPath,NewFullPath,Folder,OldPath, TempPath	
	
	if (strsearch(NPath,"J",0)>0)
		Folder="JExperiments"//+CurrentPath[6,7]+":"
		TempPath=NPath
	elseif(strsearch(NPath,"K",0)>0)
		Folder="KExperiments"//+CurrentPath[6,7]+":"
		TempPath=NPath//[0,4]+"_"+NPath[6,7]
	else
		Folder="Experiments"//+CurrentPath[6,7]+":"
		TempPath=NPath
	endif
	
	//if ((strsearch(Drive,"Z:",0)>-1)||(strsearch(Drive,"Y:",0)>-1))
	//	Folder=""
	//endif
	Make/O/T/N=8 AllDrives
	Make/O/T/N=4 AllFolders
	AllDrives[0]="Z:"
	AllDrives[1]="X:"
	AllDrives[2]="W:"
	AllDrives[3]="V:"
	AllDrives[4]="Y:"
	AllDrives[5]="U:"
	AllFolders[0]=""
	AllFolders[1]="Experiments"//+CurrentPath[6,7]+":"
	AllFolders[2]="JExperiments"//+CurrentPath[6,7]+":"
	AllFolders[3]="KExperiments"//+CurrentPath[6,7]+":"
	
	Variable PathFound=0
		PathInfo Relocate
		OldFullPath=S_path
		Variable Slen=strlen(S_path)
		OldPath=S_path[Slen-14,Slen-7]
//		NewFullPath=Drive+Folder+TempPath+"Waves:"
		NewFullPath=Drive+Folder+TempPath+"Merge:"
		NewPath/O/Z/Q Relocate NewFullPath
		if (V_flag!=0)
			i=0
			Do
				j=0
				Do
					NewFullPath=AllDrives[i]+AllFolders[j]+TempPath+"Merge:"
					NewPath/O/Z/Q Relocate NewFullPath
					j+=1
				while ((V_flag!=0)&&(j<numpnts(AllFolders)))
				i+=1
			while ((V_flag!=0)&&(i<numpnts(AllDrives)))
			if (V_flag!=0)
				i=0
				Do
					j=0
					Do
						NewFullPath=AllDrives[i]+AllFolders[j]+TempPath+"Waves:"
						NewPath/O/Z/Q Relocate NewFullPath
						j+=1
					while ((V_flag!=0)&&(j<numpnts(AllFolders)))
					i+=1
				while ((V_flag!=0)&&(i<numpnts(AllDrives)))
			endif
			if (V_flag!=0)
				NewPath/O/Z/Q Relocate OldFullPath
				CurrentPath=OldPath
				NewFullPath=OldFullPath
				Drive=AllDrives[i-1]
			endif
		endif
	
	if ((strsearch(NewFullPath,"Merge",0)>-1))
		MergeCheck=1
	else
		MergeCheck=0
	endif
	Drive = AllDrives[i-1]
	if ((strsearch(CurrentPath,"J",0)>-1) || (strsearch(CurrentPath,"j",0)>-1))
		Setup=3
	elseif((strsearch(CurrentPath,"F",0)>-1))
		Setup=2
	elseif((strsearch(CurrentPath,"K",0)>-1))
	       Setup=4
	else
		Setup=1
	endif

	Printf "root:Data:G_PathDate = \"%s\"; NewPath/O/Z/Q Relocate \"%s\"\r",CurrentPath,NewFullPath
End

Function DisplayPullOut(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	variable i,j, error,NumPts
	String POExtension,POConductance,POParameter

	NVAR DisplayStartNumber=root:Data:G_DisplayNum
	NVAR SmoothCond=root:Data:G_SmoothCond
	NVAR SmoothType=root:Data:G_SmoothType
	NVAR SmoothLevel=root:Data:G_SmoothLevel
	NVAR SmoothRepeat=root:Data:G_SmoothRepeat
	NVAR Noise = root:Data:G_Noise
	NVAR LoadIV = root:Data:G_LoadIV
	NVAR Startpt = root:Data:G_IVStartPt
	NVAR Endpt = root:Data:G_IVEndPt

	Variable Ext_offset = 0
	
	make/O/N=2 coef

	string excmd
	SetDataFolder root:Data
	i = DisplayStartNumber
	make/N=0/O POConductance_Display
	if (LoadCond(POConductance_Display,i,N=NumPts)==-1)
		Print " Trace does not exist"
		return 0
	endif

	if (SmoothCond == 1)
		SmoothData(POConductance_Display,POConductance_Display,SmoothType, SmoothLevel,SmoothRepeat)
	endif

	Wavestats/Q/R=[NumPts*0.95,NumPts*.955] POConductance_Display
	POConductance_Display-=V_avg
	Noise=V_avg

	//Haixing's Test*************************************************************************
//	      make/N=0/O Conductance_D
//		error=LoadCond(Conductance_D,i)
//		if (error==-1)
//			Print "ERROR: Check Your Range"
//			return 0
//		endif
//	      if (SmoothCond == 1)    //Smooth Data if button is checked
//			smoothdata(Conductance_D, Conductance_D, SmoothType, SmoothLevel,SmoothRepeat)
//		endif
//		NumPts=numpnts(Conductance_D)
//		Wavestats/Q/R=[NumPts*0.94,NumPts*0.95] Conductance_D
//		Conductance_D-=V_avg
//	       Duplicate/o POConductance_Display Conductance_D
//	       DeletePoints EndPt+1001, numpnts(Conductance_D)-EndPt-1000, Conductance_D
//	       DeletePoints 0, StartPt-1001, Conductance_D 
//	       AnalyzeStep_Sri (30, 10,i)
//	       Wave Sri_wave
//		DeletePoints numpnts(Sri_wave)-1519, 1520, Sri_wave
//	       DeletePoints 0, 1500, Sri_wave 	
//		
//		Wavestats/Q Sri_Wave
//		//print V_maxloc
//		
//	       Cursor/A=1/H=1 B POConductance_Display  (V_maxloc+StartPt+500)/40000
	
	
	
	
	//*********************************************************************************************
      
	DoWindow/F POGXAnalysis
	if(V_Flag==0)
		execute "POGXAnalysis()"
	endif
	
	if (LoadIV==1)
		if (waveexists(POCurrent_Display)==0)
			make/N=0 POCurrent_Display
		else
			wave POCurrent_Display
		endif
		if (waveexists(POVoltage_Display)==0)
			make/N=0 POVoltage_Display
		else
			wave POVoltage_Display
		endif
		if ((LoadCurrent(POCurrent_Display,i)==0) && (LoadVoltage(POVoltage_Display,i)==0))
			variable midpt = (startpt+endpt)/2
			Duplicate/O POVoltage_Display Voltage_D
			Duplicate/O POCurrent_Display Current_D
			smooth/B 11, Current_D
			wavestats/Q/R=[NumPts*0.9, NumPts*0.92] Current_D
			Current_D-=V_avg
			redimension/N=(Endpt) Current_D, Voltage_D
			deletepoints 0, Startpt, Current_D, Voltage_D
			//DoWindow/F IVData
			if (V_Flag==0)
				Display/W=(425,150,825,400)
				DoWindow/C IVData
				AppendToGraph/W=IVData Current_D[0,(endpt-startpt)/2-10] vs Voltage_D[0,(endpt-startpt)/2-10]
				AppendToGraph/W=IVData Current_D[(endpt-startpt)/2-10,inf] vs Voltage_D[(endpt-startpt)/2-10,inf]
				ModifyGraph rgb(Current_D#1)=(1,16019,65535)
				ModifyGraph zero=1
				ModifyGraph margin(left)=50
				ModifyGraph rgb(Current_D#1)=(1,16019,65535)
				ModifyGraph zero=1
				ModifyGraph mirror=2
				ModifyGraph font="Arial"
				ModifyGraph fSize=14
				ModifyGraph standoff=0
				ModifyGraph axThick=1.5
				ModifyGraph notation(left)=1
				ModifyGraph prescaleExp(left)=6
				ModifyGraph axisOnTop=1
				Label left "Current (micro Amp)"
				Label bottom "Voltage (V)"
			endif
		endif
	endif
	
	dowindow/F PullOut_Analysis
End

Window POGXAnalysis() : Graph
	PauseUpdate; Silent 1		// building window...
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Data:
	Display /W=(35.25,50.75,525.75,428)
	AppendToGraph POConductance_Display
	SetDataFolder fldrSav0
	ModifyGraph margin(left)=70
	ModifyGraph rgb(POConductance_Display)=(65280,0,0)
	ModifyGraph tick=2
	ModifyGraph mirror=2
	ModifyGraph standoff=0
	ModifyGraph axThick=1.5
	ModifyGraph lsize=1.5
	Label bottom "Displacement (nm)"
	Label left "Conductance (2e\\Z06\\S2\\Z10\\M/h)"
	SetAxis left 1e-05,10
	ShowInfo
	Button button0,pos={1,2},size={50,20},proc=SLButton,title="SL"
	Button button1,pos={2,29},size={50,20},proc=LogLinButton,title="Log/Lin"
EndMacro

Function DecreaseIncluded()
	NVAR CurveNumber=root:Data:G_IncludedCurveNumber
	CurveNumber = CurveNumber-1
	If (CurveNumber < 0)
		CurveNumber = 0
	endif
	DisplayIncludedNumbers(" ", 0, " ", " ")
end

Function IncreaseIncluded()
	NVAR CurveNumber=root:Data:G_IncludedCurveNumber
	NVAR Total_Included = root:Data:G_Total_Included

	CurveNumber = CurveNumber+1
	If (CurveNumber > Total_Included)
		CurveNumber = Total_Included
	endif
	DisplayIncludedNumbers(" ", 0, " ", " ")	
end


Function DisplayIncludedNumbers(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	NVAR DisplayStartNumber=root:Data:G_DisplayNum
	NVAR DisplayFromIncluded = root:Data:G_DisplayFromIncluded
	NVAR Total_Included = root:Data:G_Total_Included
	Wave IncludedNumbers=root:Data:IncludedNumbers
	NVAR CurveNumber = root:Data:G_IncludedCurveNumber
	
	if (CurveNumber==0)
		return 0
	endif
	if (CurveNumber>Total_Included)
		CurveNumber = Total_Included
	endif
	DisplayStartNumber=IncludedNumbers[CurveNumber]
	DisplayPullOut("",0,"","")
End


Function DH([Disp])
Variable Disp

if (ParamIsDefault(Disp))
	DisplayHist("no")
else
	DisplayHist("NP")
endif
DoWindow/H

end

Function FromIncludedCheck(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	NVAR DisplayFromIncluded = root:Data:G_DisplayFromIncluded
	if(checked==0)
		DisplayFromIncluded=0
		SetVariable Setvar14 Win=PullOut_Analysis, disable=1
	else
		DisplayFromIncluded=1
		SetVariable Setvar14 Win=PullOut_Analysis, disable=0
	endif

End
function SmoothData(Wave_in, Wave_out, SmoothType, SmoothLevel,SmoothRepeat)
	Wave Wave_in, Wave_out
	Variable SmoothType, SmoothLevel, SmoothRepeat
	Variable k
	Wave_out=Wave_in

	if (SmoothType==2)
		SmoothLevel=(floor(SmoothLevel/2))*2+1
		if (SmoothLevel<5)
			SmoothLevel=5
		elseif (SmoothLevel > 25)
			SmoothLevel=25
		endif					
		for (k=0;k<SmoothRepeat;k+=1)
			Smooth/S=2 (SmoothLevel), Wave_out
		endfor
	elseif (SmoothType==3)
		SmoothLevel=(floor(SmoothLevel/2))*2+1
		for (k=0;k<SmoothRepeat;k+=1)					
			Smooth/B  (SmoothLevel), Wave_out
		endfor
	else // SmoothType=1
		for (k=0;k<SmoothRepeat;k+=1)
			Smooth (SmoothLevel), Wave_out
		endfor
	endif

end

Function RedimButton(ctrlName) : ButtonControl
	String ctrlName
	NVAR Start=root:Data:G_RedimStart
	NVAR Stop=root:Data:G_RedimStop
	
	print "Redim("+num2str(Start)+","+num2str(Stop)+")"
	Redim(Start,Stop)

End

Function SetRedimStopProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	NVAR Start=root:Data:G_RedimStart
	NVAR Stop=root:Data:G_RedimStop
	
	print "Redim("+num2str(Start)+","+num2str(Stop)+")"
	Redim(Start,Stop)

End


function Redim(start,finish)
	Variable start,finish
	
	Variable i
	Variable CH, j, k=0
	Wave IncludedNumbers=root:Data:IncludedNumbers
	NVAR Total_Included = root:Data:G_Total_Included
	NVAR GStart=root:Data:G_RedimStart
	NVAR GStop=root:Data:G_RedimStop
	GStart=start
	GStop=finish
	if (finish<start)
		i=start
		start=finish
		finish=i
	endif
	
      CH=0
      Variable NumIncludedNumbers=numpnts(IncludedNumbers)
       if(CH==0)
	redimension/N=(Finish-Start+1) IncludedNumbers
	IncludedNumbers=p+Start
	Total_Included=NumIncludedNumbers
	endif
	
	if(CH==1)
	redimension/N=0 IncludedNumbers
	for(j=Start; j<Finish+1; j+=4000)
	k+=1
	redimension/N=(k*1000) IncludedNumbers
	for(i=0;i<1000;i+=1)
	IncludedNumbers[(k-1)*1000+i]=j+i
	endfor
	endfor
	Total_Included=numpnts(IncludedNumbers)

	endif
	
	
	if (GStart==0)
		deletepoints 0,1,IncludedNumbers
	endif
end


function Plus1000(ctrlName) : ButtonControl
	String ctrlName

	NVAR GStart=root:Data:G_RedimStart
	NVAR GStop=root:Data:G_RedimStop

	GStart+=1000
	GStop+=1000
	
	Redim(GStart,GStop)
	Print "Redim("+num2str(GStart)+","+num2str(GStop)+")"
	//dh()

end


Function LoadCond(Conductance_D,i,[N])
	Wave Conductance_D
	Variable i
	Variable &N
       
	SVAR CurrentPath=root:Data:G_PathDate
	NVAR MergeCheck=root:Data:G_MergeCheck
	NVAR ReadBlockConductance=root:Data:G_ReadBlockConductance

	String Conductance
	Variable error
	
	if(MergeCheck==1)
		
		String ConductanceBlockName
		variable blocknumber=ceil(i/100)
		if(blocknumber!=ReadBlockConductance)
			
			ConductanceBlockName="PullOutConductanceBlock_"+num2str(blocknumber)
			GetFileFolderInfo/P=Relocate/Q/Z ConductanceBlockName+".ibw"
			if (V_flag == 0)
				ConductanceBlockName="PullOutConductanceBlock_"+num2str(blocknumber)			
				LoadWave/Q/H/P=Relocate/O ConductanceBlockName+".ibw"
				duplicate/O  $ConductanceBlockName ConductanceBlock
				killwaves $ConductanceBlockName
				ReadBlockConductance=blocknumber
			else	
				Print "ConductanceBlock ",blocknumber," does not exist" 
				return -1
			endif
		endif		
		
		Wave ConductanceBlock
	//	make/O/N=(dimsize(ConductanceBlock,0)) Conductance_D			
		redimension/N=(dimsize( ConductanceBlock,0)) Conductance_D
		Conductance_D= ConductanceBlock[p][mod(i-1,100)]
		
	else

		Conductance="PullOutConductance_"+num2str(i)
		error = WaveExists($Conductance)
		if (error == 1)
			killwaves $Conductance
		endif

		LoadWave/Q/H/P=Relocate/O Conductance+".ibw"
		if (V_flag == 0)
			Print "Wave ",i," does not exist" 
			return -1
		endif
		duplicate/O $Conductance Conductance_D
		Killwaves $Conductance
	endif
	
		N=numpnts(Conductance_D)-22
		make/O/N=20 POParameter_Display
		POParameter_Display=Conductance_D[N+2+p]
		
		redimension/N=(N) Conductance_D
		SetScale/I x 0,POParameter_Display[0],"", Conductance_D

	return 0

end

Function LoadCurrent(Current_D,i)
	Wave Current_D
	Variable i

	SVAR CurrentPath=root:Data:G_PathDate
	NVAR MergeCheck=root:Data:G_MergeCheck
	NVAR ReadBlockCurrent=root:Data:G_ReadBlockCurrent

	String CurrentBlockName, Current
	Variable error
	Wave POParameter_Display
	
	if(MergeCheck==1)
		
		variable blocknumber=ceil(i/100)
		if(blocknumber!=ReadBlockCurrent)
			
			CurrentBlockName="PullOutCurrentBlock_"+num2str(blocknumber)
			LoadWave/Q/H/P=Relocate/O CurrentBlockName+".ibw"
			if (V_flag == 0)
				Print "CurrentBlock ",blocknumber," does not exist" 
				return -1
			endif
			duplicate/O  $CurrentBlockName CurrentBlock
			killwaves $CurrentBlockName
			ReadBlockCurrent=blocknumber
		endif
		
		
		Wave CurrentBlock	
//		make/O/N=(dimsize(CurrentBlock,0)) Current_D
		redimension/N=(dimsize(CurrentBlock,0)) Current_D
		Current_D= CurrentBlock[p][mod(i-1,100)]
		redimension/N=(numpnts(Current_D)-2) Current_D
	else

		Current="PullOutCurrent_"+num2str(i)
		error = WaveExists($Current)
		if (error == 1)
			killwaves $Current
		endif

		LoadWave/Q/H/P=Relocate/O Current+".ibw"
		if (V_flag == 0)
			Print "Wave ",i," does not exist" 
			return -1
		endif
		duplicate/O $Current Current_D
		Killwaves $Current
	endif
	SetScale/I x 0,POParameter_Display[0],"", Current_D

	return 0

end
Function LoadVoltage(Voltage_D,i)
	Wave Voltage_D
	Variable i

	Wave POParameter_Display
	SVAR CurrentPath=root:Data:G_PathDate
	NVAR MergeCheck=root:Data:G_MergeCheck
	NVAR ReadBlockVoltage=root:Data:G_ReadBlockVoltage

	String VoltageBlockName, Voltage
	Variable error
	
	if(MergeCheck==1)
		
		variable blocknumber=ceil(i/100)
		if(blocknumber!=ReadBlockVoltage)
			
			VoltageBlockName="PullOutVoltageBlock_"+num2str(blocknumber)
			LoadWave/Q/H/P=Relocate/O VoltageBlockName+".ibw"
			if (V_flag == 0)
				Print "VoltageBlock ",blocknumber," does not exist" 
				return -1
			endif
			duplicate/O  $VoltageBlockName VoltageBlock
			killwaves $VoltageBlockName
			ReadBlockVoltage=blocknumber
		endif
		
		
		Wave VoltageBlock			
	//	Make/O/N=(dimsize(VoltageBlock,0)) Voltage_D
		Redimension/N=(dimsize(VoltageBlock,0)) Voltage_D	
		Voltage_D= VoltageBlock[p][mod(i-1,100)]
		redimension/N=(numpnts(Voltage_D)-2) Voltage_D

	else

		Voltage="PullOutVoltage_"+num2str(i)
		error = WaveExists($Voltage)
		if (error == 1)
			killwaves $Voltage
		endif

		LoadWave/Q/H/P=Relocate/O Voltage+".ibw"
		if (V_flag == 0)
			Print "Wave ",i," does not exist" 
			return -1
		endif
		duplicate/O $Voltage Voltage_D
		Killwaves $Voltage
	endif
	SetScale/I x 0,POParameter_Display[0],"", Voltage_D
	
	return 0

end

Function RunHist(Nstart, NStop)
	Variable Nstart,NStop

	NVAR Start=root:Data:G_RedimStart
	NVAR Stop=root:Data:G_RedimStop
	NVAR SaveHist = root:Data:G_SaveHist
	NVAR Bin_Size = root:Data:G_Hist_Bin_Size

	NStart=NStart*1000
	NStop=NStop*1000
	Variable Num=round((NStop-NStart)/1000)
	Variable G0Peak=0
	SaveHist=1
	Wave w_coef,poconductancehist, poconductancehistlog
	Variable i,j


	for (i=0;i<Num;i+=1)
		Start=Nstart
		Stop=Start+1000
		print "Redim("+num2str(Start)+","+num2str(Stop)+")"

		Redim(Start,Stop)
		DH()

		duplicate/o poconductancehist foo
		duplicate/o poconductancehistlog foolog
		DoUpdate
		Nstart+=1000
		if (i==0)
			duplicate/o foo namefoo
			duplicate/o foolog namefoolog
		else
			namefoo=(namefoo*i+foo)/(i+1)
			namefoolog=(namefoolog*i+foolog)/(i+1)
		endif
		DoWindow/F FooGraph
		if (V_Flag==0)
			execute "FooGraph()"
		endif
		DoWindow/F LogFoo
		if (V_Flag==0)
			execute "LogFoo()"
		endif
	    sleep/s 1
	endfor
	
end

Function DisplayHist(ctrlName) : ButtonControl
	String ctrlName
	
	Variable NoDisplay
	if (stringmatch(ctrlName,"NP")==1)
		NoDisplay=2
	else
		NoDisplay=stringmatch(ctrlName,"button102") // called from button, therefore update graph
	endif
	Wave IncludedNumbers=root:Data:IncludedNumbers
	Wave POConductanceHist=root:Data:POConductanceHist
	NVAR Total_Included = root:Data:G_Total_Included
	NVAR Bin_Size = root:Data:G_Hist_Bin_Size
	NVAR SmoothCond=root:Data:G_SmoothCond
	NVAR SmoothType=root:Data:G_SmoothType
	NVAR SmoothLevel=root:Data:G_SmoothLevel
	NVAR SmoothRepeat=root:Data:G_SmoothRepeat
	NVAR HighCutOff = root:Data:G_HighCutOff
	NVAR Zero_Cutoff=root:Data:G_zero_cutoff
	NVAR Offline=root:Data:G_Offline
	NVAR Counter=root:Data:G_Counter
	NVAR Noise = root:Data:G_Noise
	NVAR LoadIV = root:Data:G_LoadIV
	NVAR Startpt = root:Data:G_IVStartPt
	NVAR Endpt = root:Data:G_IVEndPt

	SVAR CurrentPath=root:Data:G_PathDate
	SVAR G_SavedHistPath=root:Data:G_SavedHistPath
	NVAR Start=root:Data:G_RedimStart
	NVAR Stop=root:Data:G_RedimStop
	NVAR SaveHist = root:Data:G_SaveHist
	NVAR Overwrite = root:Data:G_OverWrite
	variable i=0,j=0, error,numskip=0,k
	Variable NumPts, lowcutoff,num, HighCut, LowCut
	Wave Conductance_D
	Variable Stopped = 0
	Variable V_fitOptions=4

	Variable Num_Bin=HighCutOff/Bin_Size
	Total_Included=numpnts(IncludedNumbers)
	if (NoDisplay <2)
		print "Histogram"
	endif
	String histout

	if (Total_Included<1)	// No good waves to make a histogram so quit
		return 0
	endif

	Make/O/N=(Num_Bin) POConductanceHist
	POConductanceHist=0
	SetScale/I x 0,HighCutOff,"", POConductanceHist
	Make/O/N=(1000) POConductanceHistLog
	POConductanceHistLog=0
	SetScale/I x -8,2,"", POConductanceHistLog
	
 
 	Variable Loaded=0
	if ((SaveHist == 1)&&(OverWrite==0))
		histout = "hist"+num2str(Start)+"_"+num2str(Stop)+"_"+CurrentPath[0,7]+"H"+num2str(-log(Bin_size))
		Loaded+=LoadHist(histout, NoDisplay)
		histout = "Loghist"+num2str(Start)+"_"+num2str(Stop)+"_"+CurrentPath[0,7]
		Loaded+=LoadHist(histout, NoDisplay)
		if (Loaded==2)
			return 0
		endif
	endif
	make/N=0/O Conductance_D
//	DoWindow/K CounterWindow
//	Execute "CounterWindow()"

	String Conductance
	for (j=0;j<Total_Included;j+=1)
		i=IncludedNumbers[j]
		LoadCond(Conductance_D,i,N=Numpts)

		
	
	//*******************************hist for pulling experiment HL
	Variable P=0
	Variable Firstlimit, Secondlimit, Thirdlimit, Fourthlimit
	Firstlimit = 4000
	Secondlimit = 6747
	Thirdlimit = 7253 - (Secondlimit - Firstlimit+1)
	Fourthlimit = 10000 - (Secondlimit - Firstlimit+1)
	if(P==1)
	deletepoints Firstlimit, Secondlimit, Conductance_D
	NumPts=numpnts(Conductance_D)
	 deletepoints Thirdlimit, Fourthlimit, Conductance_D
	 NumPts=numpnts(Conductance_D)    
	 endif    
	//*********************************************************************************
	
	
	
	
	
		if (SmoothCond == 1)    //Smooth Data if button is checked
			smoothdata(Conductance_D, Conductance_D, SmoothType, SmoothLevel,SmoothRepeat)
		endif		
		Wavestats/Q/R=[NumPts*0.93,NumPts*0.94] Conductance_D
		Noise=V_avg
		Conductance_D-=V_avg
		if (LoadIV==1)
			deletepoints Startpt,EndPt-Startpt, Conductance_D
			NumPts=numpnts(Conductance_D)
			if (j==1)
				print "Deleting points",Startpt, EndPt
			endif
		endif
		Wavestats/Q/R=[0,round(NumPts*0.02)] Conductance_D
		

		if ((Noise<Zero_Cutoff))//&&(abs(V_avg)>1.02)) // skip curves that don't go to saturation or noise (change 1.02 to 1.5)
			redimension/N=(NumPts*0.935) Conductance_D
			Histogram/A Conductance_D POConductanceHist
			Conductance_D=Log(Conductance_D)
			Histogram/A Conductance_D POConductanceHistLog
			Counter=j
			DoUpdate/W=PullOut_Analysis

		else
			numskip+=1
		endif
	endfor
	
		printf "Number Skipped = %d\r",numskip
		poconductanceHist/=((Total_Included-numskip)/1000) // Normalize by # of traces used
		poconductancehistLog/=((Total_Included-numskip)/1000)

	if (((SaveHist == 1)&&(Stopped==0))&&(numskip<500))
		histout = "hist"+num2str(Start)+"_"+num2str(Stop)+"_"+CurrentPath[0,7]+"H"+num2str(-log(Bin_size))
		duplicate/O poconductancehist $histout
		if (NoDisplay<2)
			print "Saved Hist as: ", histout
		endif
//		NewPath/Q/O SavedHist G_SavedHistPath+"SavedHist"+CurrentPath[5,7]
		if (OverWrite==1)
			Save/C/O/P=SavedHist $histout as histout+".ibw"
		else
			GetFileFolderInfo/P=SavedHist/Q/Z histout+".ibw"
			if (V_flag !=0)		
				Save/C/P=SavedHist $histout as histout+".ibw"
			endif
		endif
		killwaves $histout
		histout = "Loghist"+num2str(Start)+"_"+num2str(Stop)+"_"+CurrentPath[0,7]
		duplicate/O poconductancehistLog $histout			
		Save/C/O/P=SavedHist $histout as histout+".ibw"
		print "Saved LogHist as: ", histout
		killwaves $histout
	endif
	
	duplicate/o poconductancehist foo
	duplicate/o poconductancehistlog foolog
	if (waveexists(namefoo)==0)
		duplicate foo namefoo
	endif
	if (waveexists(namefoolog)==0)
		duplicate foolog namefoolog
	endif
	DoWindow/F FooGraph
	if (V_Flag==0)
		execute "FooGraph()"
	endif
	DoWindow/F LogFoo
	if (V_Flag==0)
		execute "LogFoo()"
	endif

End

Function LoadHist(Name, NoDisplay)
String Name
Variable NoDisplay
SVAR CurrentPath=root:Data:G_PathDate
SVAR G_SavedHistPath=root:Data:G_SavedHistPath

NVAR Offline=root:Data:G_Offline
//		NewPath/Q/O SavedHist G_SavedHistPath+"SavedHist"+CurrentPath[5,7]
		GetFileFolderInfo/P=SavedHist/Q/Z Name+".ibw"
		if (V_flag==0)
			if (NoDisplay<2)
				LoadWave/O/H/P=SavedHist Name+".ibw"
			else
				LoadWave/O/H/Q/P=SavedHist Name+".ibw"
			endif
			if (stringmatch(Name,"Log*")==1)
				duplicate/O $Name POConductanceHistLog
			else
				duplicate/O $Name POConductanceHist
			endif
			killwaves $Name
			return 1
		elseif (Offline==1)
			print "Histogram Does Not Exist; Offline"
			return 2
		endif
		return -1
end
Function DisplayLogHist()

	Wave IncludedNumbers=root:Data:IncludedNumbers
	NVAR Total_Included = root:Data:G_Total_Included
	NVAR SmoothCond=root:Data:G_SmoothCond
	NVAR SmoothType=root:Data:G_SmoothType
	NVAR SmoothLevel=root:Data:G_SmoothLevel
	NVAR SmoothRepeat=root:Data:G_SmoothRepeat
	NVAR Zero_Cutoff=root:Data:G_zero_cutoff
	NVAR Counter=root:Data:G_Counter

	variable i=0,j=0, error,numskip=0,k
	Variable NumPts, lowcutoff,num, HighCut, LowCut
	Wave Conductance_D
	Total_Included=numpnts(IncludedNumbers)
	print "Log Histogram"
	String histout, Conductance

	if (Total_Included<1)	// No good waves to make a histogram so quit
		DoWindow/F PullOutPOConductanceHistogram
		if(V_Flag==1)
			DoWindow/K PullOutPOConductanceHistogram
		endif
		return 0
	endif

	Variable BinSizeVar=1000
	Make/O/N=(BinSizeVar) POConductanceHistLog
	SetScale/I x -8,2,"", POConductanceHistLog
	POConductanceHistLog=0

//	DoWindow/K CounterWindow
//	Execute "CounterWindow()"	

	for (j=0;j<Total_Included;j+=1)
		i=IncludedNumbers[j]
		Conductance="PullOutConductance_"+num2str(i)
		LoadCond(Conductance_D,i,N=Numpts)

		if (SmoothCond == 1)    //Smooth Data if button is checked
			smoothdata(Conductance_D, Conductance_D, SmoothType, SmoothLevel,SmoothRepeat)
		endif		
		// Get rid of all points below and above thresholds - set them to zero
		Wavestats/Q/R=[NumPts*0.91,NumPts*.92] Conductance_D
		lowcutoff=V_avg
		if (lowcutoff<Zero_Cutoff)	// skip curves which don't go to zero at the end
			redimension/N=(NumPts*0.95) Conductance_D
			Conductance_D-=lowcutoff // Correct for Zero
			Conductance_D=Log(Conductance_D)
			Histogram/A Conductance_D POConductanceHistLog
		endif
		Counter=j
//		DoUpdate/W=CounterWindow
		DoUpdate/W=PullOut_Analysis
		if (floor(j/1000)==j/1000)
			DoUpdate
		endif
	endfor
	POConductanceHistLog/=(Total_Included/1000)
//	DoWindow/K CounterWindow

End



Function Hist2D(ctrlName) : ButtonControl
	String ctrlName
	NVAR AlignG=root:Data:G_AlignG
	NVAR	Linlog=root:Data:G_2DLog
	MakeCond2DHist(AlignG,Linlog)
End


Function MakeCond2DHist(AlignG,Linlog)
	Variable AlignG,LinLog
	String Name

	NVAR Counter=root:Data:G_Counter
	NVAR Total_Included = root:Data:G_Total_Included
	NVAR Xmin=root:Data:G_2DXmin
	NVAR Xmax=root:Data:G_2DXmax
	NVAR Setup = root:Data:G_Setup
	SVAR CurrentPath=root:Data:G_PathDate
	NVAR SaveHist = root:Data:G_SaveHist
	NVAR Start=root:Data:G_RedimStart
	NVAR Stop=root:Data:G_RedimStop
	NVAR SmoothCond=root:Data:G_SmoothCond
	NVAR SmoothType=root:Data:G_SmoothType
	NVAR SmoothLevel=root:Data:G_SmoothLevel
	NVAR SmoothRepeat=root:Data:G_SmoothRepeat
	NVAR Zero_Cutoff=root:Data:G_zero_cutoff


	Wave IncludedNumbers=root:Data:IncludedNumbers
	Variable type = 1 // 0-normal, 1 - include all traces, look only for x where trace goes to lowcutoff
	Variable Ymin		// -6 for log, 0 for linear
	Variable Ymax	// 1 for log, 10 for linear

	if (LinLog==1)
		Ymin=-7		// -6 for log, 0 for linear
		Ymax=1	// 1 for log, 10 for linear
	else
		Ymin=0		// -6 for log, 0 for linear
		Ymax=10	// 1 for log, 10 for linear
	endif

	Variable XNum=1400; 
	Variable YNum=1600;
	Variable Factor

	If (Setup==1)
		Factor = 0.72 // Setup 1
	elseif (Setup==3)
		Factor = 0.79 // Setup 3
       elseif(Setup==4)
             //Factor = 1
             Factor = 1.87
	endif
	
	Total_Included=numpnts(IncludedNumbers)

	Make/O/N=(XNum,YNum) total2DHist=0;
	Wave total2DHist
	SetScale/I x Xmin,Xmax,"",total2DHist
	SetScale/I y Ymin,Ymax,"", total2DHist	
//	DoWindow/K CounterWindow
//	Execute "CounterWindow()"

	Wave W_Findlevels, Conductance_D

	Variable k, EndX, DeltaEx, j, NumPts, CounterN=0

	for (k=0;k<Total_Included;k+=1)
		j=IncludedNumbers[k]
		EndX=0;
		
		if (LoadCond(Conductance_D,j,N=NumPts)==-1)
			print "Check Wave Number"
			return 0
		endif
		DeltaEx=deltax(Conductance_D)*Factor
		redimension/N=(NumPts*0.95) Conductance_D
		NumPts*=0.95
		if (SmoothCond == 1)
			smoothdata(Conductance_D, Conductance_D, SmoothType, SmoothLevel,SmoothRepeat)
		endif		
		Wavestats/Q/R=[NumPts*0.98,NumPts*0.99] Conductance_D
		if ((abs(V_avg)>2*Zero_Cutoff))
			//return 0
		endif
		Conductance_D-=V_avg
		duplicate/O Conductance_D Conductance_D_Raw
		smoothdata(Conductance_D, Conductance_D, 3, 21,3)
	//	Findlevel/Q/Edge=2 Conductance_D, AlignG // search only for decreasing levels.
		Findlevel/Q/Edge=2/R=[NumPts,1] Conductance_D, AlignG // search only for decreasing levels.
		
		if (V_flag==0)
			CounterN+=1
			//Endx=V_LevelX*Factor
			Endx=1.5*Factor
			duplicate/o Conductance_D_Raw Con_YWave
			duplicate/o Conductance_D_Raw Con_XWave
			if (LinLog==1)
				Con_YWave=log(abs(Con_YWave))	//For Log
			endif
			Con_XWave=(p)*DeltaEx-EndX
			//			if (Endx<Ymax)
			//				print "Bad", EndX, j, Good, V_StepL
			//			endif
			Make2DHist(total2DHist,Con_XWave, Con_YWave,Xmin,Xmax,Ymin,Ymax,XNum,YNum)
//			DoUpdate/W=CounterWindow
			DoUpdate/W=PullOut_Analysis
			if (floor(k/100)==k/100)
				DoUpdate
				DoWindow/F Cond2D
				if (V_Flag==0)
					execute "Cond2D()"
				endif
				
			endif
		else
			IncludedNumbers[k]=0
		endif
		Counter=k
	endfor

	total2DHist/=(CounterN/1000)	
	//SetScale/I x Xmin*Factor,Xmax*Factor,"",C_2DHist;
	if (SaveHist==1)
		SVAR G_SavedHistPath=root:Data:G_SavedHistPath
		duplicate/o total2DHist $("C_2DHist_"+num2str(Start)+"_"+num2str(Stop)+"_"+CurrentPath[0,7])
//		NewPath/Q/O SavedHist G_SavedHistPath
		Save/C/O/P=Saved2DHist $("C_2DHist_"+num2str(Start)+"_"+num2str(Stop)+"_"+CurrentPath[0,7])
		killwaves $("C_2DHist_"+num2str(Start)+"_"+num2str(Stop)+"_"+CurrentPath[0,7])
	endif
	print " X Factor used", Factor
	DoWindow/F Cond2D
	if (V_Flag==0)
		execute "Cond2D()"
	endif
end

Function Make2DHist(Hist2D,XWave, YWave,Xmin,Xmax,Ymin,Ymax,NumXBin,NumYBin)
Wave Hist2D, XWave, YWave
Variable Xmin, Xmax, Ymin, Ymax, NumXbin, NumYbin
Variable XVal, YVal

SetScale/I x Xmin,Xmax,"", Hist2D;
SetScale/I y Ymin,Ymax,"", Hist2D;


	Variable num=numpnts(XWave)
	Variable k
		for(k=0;k<num;k+=1)
			XVal=-1
			YVal=-1
			XVal=XWave[k]
			XVal = ((XWave[k]-Xmin)*NumXBin/(XMax-XMin))
			YVal=YWave[k]
			YVal = ((YWave[k]-Ymin)*NumYBin/(YMax-YMin))
			if((XVal<numXBin)&&(XVal>0)&&(YVal<numYBin)&&(YVal>0))
				Hist2D[XVal][YVal]+=1
			endif
		endfor
end

Function/S GetAxisLabel(gname, axisname)	//From the Internet, and edited because it was janky
	String gname, axisname
 	
 	//Finds top graph
 	gname = WinName(0, 1)
 	
	String grecreation = WinRecreation(gname, 0)
	String oneLine
	String labelStr = ""
	String part1, part2

	Variable i=0
	do
		oneLine = StringFromList(i, grecreation, "\r")
		if (stringmatch(oneLine, "\tLabel *" + axisname + "*"))
			String regexp = "^\\tLabel "+axisname+" \\\"(.*)\\\""
			SplitString/E=regexp oneLine, labelStr
			//Yes you really do need all 3
			labelStr = ReplaceString("\\\\", labelStr, "\\")
			labelStr = ReplaceString("\\\\", labelStr, "\\")
			labelStr = ReplaceString("\\\\", labelStr, "\\")
			break;
		endif
		i += 1
	while(strlen(oneLine) > 0)
 
	return labelStr
end

Function SLButton(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			SetAxis left 1e-05,*
			break
	endswitch

	return 0
End

Function LogLinButton(ctrlName) : ButtonControl
	String ctrlName
	DoWindow/F POGXAnalysis
	If (numberbykey("log(x)",axisinfo("POGXAnalysis","left"),"=")==0)
		ModifyGraph log(left)=1
	else
		ModifyGraph log(left)=0
	endif	
End

Window FooGraph() : Graph
	PauseUpdate; Silent 1		// building window...
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Data:
	Display /W=(582,200,982,529) foo,namefoo
	SetDataFolder fldrSav0
	ModifyGraph lSize(namefoo)=1.5
	ModifyGraph rgb(foo)=(0,0,0),rgb(namefoo)=(1,4,52428)
	ModifyGraph log=1
	ModifyGraph tick=2
	ModifyGraph mirror=2
	ModifyGraph fSize=12
	ModifyGraph standoff=0
	ModifyGraph axThick=1.5
EndMacro

Window LogFoo() : Graph
	PauseUpdate; Silent 1		// building window...
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Data:
	Display /W=(180,199,580,527) foolog,namefoolog
	SetDataFolder fldrSav0
	ModifyGraph lSize(namefoolog)=1.5
	ModifyGraph rgb(foolog)=(0,0,0),rgb(namefoolog)=(1,4,52428)
	ModifyGraph tick=2
	ModifyGraph mirror=2
	ModifyGraph fSize=12
	ModifyGraph standoff=0
	ModifyGraph axThick=1.5
EndMacro

Window Cond2D() : Graph
	PauseUpdate; Silent 1		// building window...
	Display /W=(481,591,892,953)
	AppendImage :Data:total2DHist
	ModifyImage total2DHist ctab= {*,*,Geo32,1}
	ModifyGraph userticks(left)={:Data:wave0,:Data:textWave0}
	ModifyGraph margin(left)=50,margin(bottom)=50
	ModifyGraph tick=2
	ModifyGraph mirror=2
	ModifyGraph font="Arial"
	ModifyGraph fSize=14
	ModifyGraph standoff=0
	ModifyGraph axThick=1.5
	ModifyGraph axisOnTop=1
	Label left "Conductance (G\\B0\\M)"
	Label bottom "Displacement (nm)"
EndMacro

Function TabProc(ctrlName,tabNum) : TabControl
String ctrlName
Variable tabNum
NVAR DisplayFromIncluded = root:Data:G_DisplayFromIncluded

switch(tabNum)
case 0:
//cosmetic tab disable
PopupMenu popup3 disable =1
Button button5 disable=1
Button button6 disable=1
SetVariable setvar1 disable=1
Titlebox title2 disable = 1
GroupBox Box102 disable = 1
titlebox title3 disable = 1
Button button09 disable =1
Button button9 disable =1
Button button8 disable = 1
Button button7 disable = 1
Button button10 disable = 1
//Button button07 disable =1
Button button08 disable =1
Button button05 disable = 1
//Hist Anal tab enable
Button button0 disable=0
Button button1 disable=0
SetVariable setvar4 disable=0
GroupBox Box1 disable = 0
GroupBox box101 disable = 0
Button button102 disable =0
Button button103 disable =0
//Checkbox check0 disable = 0
Checkbox check1 disable = 0
Checkbox check4 disable =  0
Checkbox check5 disable =  0
Checkbox check6 disable = 0
Checkbox check7 disable = 0
Checkbox check8 disable = 0
SetVariable setvar0_1 disable = 0 
SetVariable setvar0_2 disable = 0
SetVariable setvar6 disable = 0
SetVariable setvar8 disable = 0
SetVariable setvar12 disable = 0
SetVariable setvar13 disable = 0
SetVariable setvar14 disable = (1-DisplayFromIncluded)
SetVariable setvar15 disable = 0
SetVariable setvar17 disable = 0
SetVariable setvar18 disable = 0 
SetVariable setvar19 disable = 0 
SetVariable setvar20 disable = 0
SetVariable setvar21 disable = 0
SetVariable setvar0 disable = 0
ValDisplay valdisp0 disable = 0
ValDisplay valdisp0_1 disable = 0
//enable Params tab
ValDisplay valdisp1 disable = 1
ValDisplay valdisp2 disable = 1
ValDisplay valdisp3 disable = 1
ValDisplay valdisp4 disable = 1
ValDisplay valdisp5 disable = 1
ValDisplay valdisp6 disable = 1
ValDisplay valdisp7 disable = 1
ValDisplay valdisp8 disable = 1
ValDisplay valdisp9 disable = 1
GroupBox box2 disable = 1
break
case 1:
//cosmetics tab enable
PopupMenu popup3 disable =0
Button button5 disable=0
Button button6 disable=0
SetVariable setvar1 disable=0
Titlebox title2 disable = 0
GroupBox Box102 disable = 0
titlebox title3 disable = 0
Button button09 disable =0
Button button9 disable =0
Button button8 disable = 0
Button button10 disable = 0
//Button button07 disable =0
Button button08 disable =0
Button button05 disable = 0
//Hist Anal tab disable
Button button0 disable=1
Button button1 disable=1
SetVariable setvar4 disable=1
GroupBox Box1 disable = 1
GroupBox box101 disable = 1
Button button102 disable =1
Button button103 disable =1
//Checkbox check0 disable = 1
Checkbox check1 disable = 1
Checkbox check4 disable =  1
Checkbox check5 disable =  1
Checkbox check6 disable = 1
Checkbox check7 disable = 1
Checkbox check8 disable = 1
SetVariable setvar0_1 disable = 1 
SetVariable setvar0_2 disable = 1
SetVariable servar0 disable = 1
SetVariable setvar6 disable = 1
SetVariable setvar8 disable = 1
SetVariable setvar12 disable = 1
SetVariable setvar13 disable = 1
SetVariable setvar14 disable = 1
SetVariable setvar15 disable = 1
SetVariable setvar17 disable = 1
SetVariable setvar18 disable = 1 
SetVariable setvar19 disable = 1 
SetVariable setvar20 disable = 1
SetVariable setvar21 disable = 1
ValDisplay valdisp0 disable = 1
ValDisplay valdisp0_1 disable = 1
SetVariable setvar0 disable =1
//disable Params tab
ValDisplay valdisp1 disable = 1
ValDisplay valdisp2 disable = 1
ValDisplay valdisp3 disable = 1
ValDisplay valdisp4 disable = 1
ValDisplay valdisp5 disable = 1
ValDisplay valdisp6 disable = 1
ValDisplay valdisp7 disable = 1
ValDisplay valdisp8 disable =1
ValDisplay valdisp9 disable = 1
GroupBox box2 disable = 1
break
case 2:
//cosmetic tab disable
PopupMenu popup3 disable =1
Button button5 disable=1
Button button6 disable=1
SetVariable setvar1 disable=1
Titlebox title2 disable = 1
GroupBox Box102 disable = 1
titlebox title3 disable = 1
Button button09 disable =1
Button button9 disable =1
Button button8 disable = 1
Button button7 disable = 1
Button button08 disable =1
Button button05 disable = 1
Button button10 disable = 1
//display tab disable
Button button0 disable=1
Button button1 disable=1
SetVariable setvar4 disable=0
GroupBox Box1 disable = 0
GroupBox box101 disable = 1
Button button102 disable =1
Button button103 disable =1
//Checkbox check0 disable =1
Checkbox check1 disable =0
Checkbox check4 disable = 1
Checkbox check5 disable =  1
Checkbox check6 disable = 0
Checkbox check7 disable = 1
Checkbox check8 disable = 1
SetVariable setvar0_1 disable = 0
SetVariable setvar0_2 disable =0
SetVariable setvar6 disable =1
SetVariable setvar8 disable = 1
SetVariable setvar12 disable = 1
SetVariable setvar13 disable = 1
SetVariable setvar15 disable = 1
SetVariable setvar14 disable = (1-DisplayFromIncluded)
SetVariable setvar17 disable = 1
SetVariable setvar18 disable = 1 
SetVariable setvar19 disable = 1
SetVariable setvar20 disable = 1
SetVariable setvar21 disable =1
SetVariable setvar0 disable =0
ValDisplay valdisp0 disable = 1
ValDisplay valdisp0_1 disable = 1
//enable Params tab
ValDisplay valdisp1 disable = 0
ValDisplay valdisp2 disable = 0
ValDisplay valdisp3 disable = 0
ValDisplay valdisp4 disable = 0
ValDisplay valdisp5 disable = 0
ValDisplay valdisp6 disable = 0
ValDisplay valdisp7 disable = 0
ValDisplay valdisp8 disable = 0
ValDisplay valdisp9 disable = 0
GroupBox box2 disable = 0

break
endswitch
return 0
end

