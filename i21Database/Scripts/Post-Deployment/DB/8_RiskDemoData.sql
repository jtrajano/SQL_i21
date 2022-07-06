PRINT '*Start Populating Demo Data for Risk Dashboard*'
IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblDBRiskDemoVaR')
BEGIN
	IF EXISTS (SELECT TOP 1 1 FROM tblDBRiskDemoMultiDayVaR)
	BEGIN
		RETURN
	END

	--tblDBRiskDemoVaR
	INSERT INTO tblDBRiskDemoVaR([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblVaR], [dblComponentVaR], [dblConditionalVaR], [dblTotalVaR], [dblTotalConditionalVaR], [strVaRModel], [dblConfidence], [dtmStartDate], [strBaseFX]) 
	VALUES ('Cotton #2', 'ICE', 'CTH22', 487, 106.23, 25867005.00, 906477.45, 906477.45, 906477.45, 7164163.25, 8474733.43, 'Full Historical', 0.01,'12/14/2020','USD')

	INSERT INTO tblDBRiskDemoVaR([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblVaR], [dblComponentVaR], [dblConditionalVaR], [dblTotalVaR], [dblTotalConditionalVaR], [strVaRModel], [dblConfidence], [dtmStartDate], [strBaseFX]) 
	VALUES ('Cotton #2', 'ICE', 'CTH22', 257, 104.93,  13483505.00,  471402.25, 491062.75, 581248.33, NULL, NULL, NULL, NULL,NULL,NULL)

	INSERT INTO tblDBRiskDemoVaR([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblVaR], [dblComponentVaR], [dblConditionalVaR], [dblTotalVaR], [dblTotalConditionalVaR], [strVaRModel], [dblConfidence], [dtmStartDate], [strBaseFX]) 
	VALUES ('Cotton #2', 'ICE', 'CTH22', 736, 102.8, 37830400.00, 1229451.20, 1261908.81, 1513706.67, NULL, NULL, NULL, NULL,NULL,NULL)

	INSERT INTO tblDBRiskDemoVaR([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblVaR], [dblComponentVaR], [dblConditionalVaR], [dblTotalVaR], [dblTotalConditionalVaR], [strVaRModel], [dblConfidence], [dtmStartDate], [strBaseFX]) 
	VALUES ('Cotton #2', 'ICE', 'CTH22', 393, 94.55, 18579075.00, 509386.95, 539451.45, 550855.00, NULL, NULL, NULL, NULL,NULL,NULL)

	INSERT INTO tblDBRiskDemoVaR([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblVaR], [dblComponentVaR], [dblConditionalVaR], [dblTotalVaR], [dblTotalConditionalVaR], [strVaRModel], [dblConfidence], [dtmStartDate], [strBaseFX]) 
	VALUES ('Cotton #2', 'ICE', 'CTH22', 859, 89.75, 38547625.00, 914577.30, 953318.20, 1118131.67, NULL, NULL, NULL, NULL,NULL,NULL)

	INSERT INTO tblDBRiskDemoVaR([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblVaR], [dblComponentVaR], [dblConditionalVaR], [dblTotalVaR], [dblTotalConditionalVaR], [strVaRModel], [dblConfidence], [dtmStartDate], [strBaseFX]) 
	VALUES ('Cotton #2', 'ICE', 'CTH23', 257, 86.6, 11128100.00, 263771.95, 264748.55, 328531.67, NULL, NULL, NULL, NULL,NULL,NULL)

	INSERT INTO tblDBRiskDemoVaR([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblVaR], [dblComponentVaR], [dblConditionalVaR], [dblTotalVaR], [dblTotalConditionalVaR], [strVaRModel], [dblConfidence], [dtmStartDate], [strBaseFX]) 
	VALUES ('Cotton #2', 'ICE', 'CTH23', 648, 85.35, 27653400.00, 592822.80, 627685.21, 725760.00, NULL, NULL, NULL, NULL,NULL,NULL)

	INSERT INTO tblDBRiskDemoVaR([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblVaR], [dblComponentVaR], [dblConditionalVaR], [dblTotalVaR], [dblTotalConditionalVaR], [strVaRModel], [dblConfidence], [dtmStartDate], [strBaseFX]) 
	VALUES ('Cotton #2', 'ICE', 'CTH23', 449, 83.8, 18813100.00, 384815.45, 393503.60, 400358.33, NULL, NULL, NULL, NULL,NULL,NULL)

	INSERT INTO tblDBRiskDemoVaR([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblVaR], [dblComponentVaR], [dblConditionalVaR], [dblTotalVaR], [dblTotalConditionalVaR], [strVaRModel], [dblConfidence], [dtmStartDate], [strBaseFX]) 
	VALUES ('Cotton #2', 'ICE', 'CTH23', -326, 81.19, 13233970.00, 202234.10, 237865.90, 273296.67, NULL, NULL, NULL, NULL,NULL,NULL)

	INSERT INTO tblDBRiskDemoVaR([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblVaR], [dblComponentVaR], [dblConditionalVaR], [dblTotalVaR], [dblTotalConditionalVaR], [strVaRModel], [dblConfidence], [dtmStartDate], [strBaseFX]) 
	VALUES ('Cotton #2', 'ICE', 'CTH23', -9, 79.19, 356355.00, 5609.70, 5337.00, 7245.00, NULL, NULL, NULL, NULL,NULL,NULL)

	INSERT INTO tblDBRiskDemoVaR([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblVaR], [dblComponentVaR], [dblConditionalVaR], [dblTotalVaR], [dblTotalConditionalVaR], [strVaRModel], [dblConfidence], [dtmStartDate], [strBaseFX]) 
	VALUES ('Cotton #2', 'ICE', 'CTH24', -35, 79.69, 1394575.00, 18590.25, 13938.74, 26308.33, NULL, NULL, NULL, NULL,NULL,NULL)

	INSERT INTO tblDBRiskDemoVaR([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblVaR], [dblComponentVaR], [dblConditionalVaR], [dblTotalVaR], [dblTotalConditionalVaR], [strVaRModel], [dblConfidence], [dtmStartDate], [strBaseFX]) 
	VALUES ('Cotton #2', 'ICE', 'CTH24', -246, 80.19, 9863370.00, 130662.90, 97969.49, 184910.00, NULL, NULL, NULL, NULL,NULL,NULL)

	INSERT INTO tblDBRiskDemoVaR([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblVaR], [dblComponentVaR], [dblConditionalVaR], [dblTotalVaR], [dblTotalConditionalVaR], [strVaRModel], [dblConfidence], [dtmStartDate], [strBaseFX]) 
	VALUES ('Cotton #2', 'ICE', 'CTH24', -566, 80.69, 22835270.00, 293952.10, 225409.49, 425443.33, NULL, NULL, NULL, NULL,NULL,NULL)

	INSERT INTO tblDBRiskDemoVaR([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblVaR], [dblComponentVaR], [dblConditionalVaR], [dblTotalVaR], [dblTotalConditionalVaR], [strVaRModel], [dblConfidence], [dtmStartDate], [strBaseFX]) 
	VALUES ('Cotton #2', 'ICE', 'CTH24', -920, 80.19, 36887400.00, 203688.00, 366390.00, 515200.00, NULL, NULL, NULL, NULL,NULL,NULL)

	INSERT INTO tblDBRiskDemoVaR([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblVaR], [dblComponentVaR], [dblConditionalVaR], [dblTotalVaR], [dblTotalConditionalVaR], [strVaRModel], [dblConfidence], [dtmStartDate], [strBaseFX]) 
	VALUES ('Cotton #2 July 22 Put', 'ICE', 'CTN69.0Q.FO', 626, 0.21, 65730.00, 130896.60, 90801.29, 154413.33, NULL, NULL, NULL, NULL,NULL,NULL)

	INSERT INTO tblDBRiskDemoVaR([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblVaR], [dblComponentVaR], [dblConditionalVaR], [dblTotalVaR], [dblTotalConditionalVaR], [strVaRModel], [dblConfidence], [dtmStartDate], [strBaseFX]) 
	VALUES ('Cotton #2 July 22 Put', 'ICE', 'CTN68.0Q.FO', -156, 0.17, 13260.00, 29959.80, 21028.80, 35620.00, NULL, NULL, NULL, NULL,NULL,NULL)

	INSERT INTO tblDBRiskDemoVaR([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblVaR], [dblComponentVaR], [dblConditionalVaR], [dblTotalVaR], [dblTotalConditionalVaR], [strVaRModel], [dblConfidence], [dtmStartDate], [strBaseFX]) 
	VALUES ('Cotton #2 July 22 Put', 'ICE', 'CTN40.0Q.FO', 276, 0.01, 1380.00, 1380.00, 1131.59, 2267.14, NULL, NULL, NULL, NULL,NULL,NULL)

	INSERT INTO tblDBRiskDemoVaR([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblVaR], [dblComponentVaR], [dblConditionalVaR], [dblTotalVaR], [dblTotalConditionalVaR], [strVaRModel], [dblConfidence], [dtmStartDate], [strBaseFX]) 
	VALUES ('Cotton #2 Dec 22 Call', 'ICE', 'CTZ64.0D.FO', 975, 26.3, 12821250.00, 848591.25, 938242.51, 1053000.00, NULL, NULL, NULL, NULL,NULL,NULL)

	INSERT INTO tblDBRiskDemoVaR([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblVaR], [dblComponentVaR], [dblConditionalVaR], [dblTotalVaR], [dblTotalConditionalVaR], [strVaRModel], [dblConfidence], [dtmStartDate], [strBaseFX]) 
	VALUES ('Cotton #2 March 22 Call', 'ICE', 'CTH81.0D.FO', 712, 25.35, 9024600.00, 1242546.80, 1142475.21, 1565213.33, NULL, NULL, NULL, NULL,NULL,NULL)

	INSERT INTO tblDBRiskDemoVaR([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblVaR], [dblComponentVaR], [dblConditionalVaR], [dblTotalVaR], [dblTotalConditionalVaR], [strVaRModel], [dblConfidence], [dtmStartDate], [strBaseFX]) 
	VALUES ('Cotton #2 July 22 Call', 'ICE', 'CTN71.0D.FO', 598, 32.09, 9594910.00, 926840.20, 923461.51, 1192013.33, NULL, NULL, NULL, NULL,NULL,NULL)

	INSERT INTO tblDBRiskDemoVaR([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblVaR], [dblComponentVaR], [dblConditionalVaR], [dblTotalVaR], [dblTotalConditionalVaR], [strVaRModel], [dblConfidence], [dtmStartDate], [strBaseFX]) 
	VALUES ('Cotton #2 July 22 Call', 'ICE', 'CTN65.0D.FO', 720, 37.9, 13644000.00, 1136052.00, 1160856.00, 1462800.00, NULL, NULL, NULL, NULL,NULL,NULL)

	INSERT INTO tblDBRiskDemoVaR([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblVaR], [dblComponentVaR], [dblConditionalVaR], [dblTotalVaR], [dblTotalConditionalVaR], [strVaRModel], [dblConfidence], [dtmStartDate], [strBaseFX]) 
	VALUES ('Cotton #2 July 22 Call', 'ICE', 'CTH90.0D.FO', 248, 16.77, 2079480.00, 406149.60, 354937.60, 505093.33, NULL, NULL, NULL, NULL,NULL,NULL)

	INSERT INTO tblDBRiskDemoVaR([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblVaR], [dblComponentVaR], [dblConditionalVaR], [dblTotalVaR], [dblTotalConditionalVaR], [strVaRModel], [dblConfidence], [dtmStartDate], [strBaseFX]) 
	VALUES ('Cotton #2 July 22 Call', 'ICE', 'CTH82.0D.FO', 91, 24.37, 1108835.00, 158435.55, 143989.30, 198986.67, NULL, NULL, NULL, NULL,NULL,NULL)

	INSERT INTO tblDBRiskDemoVaR([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblVaR], [dblComponentVaR], [dblConditionalVaR], [dblTotalVaR], [dblTotalConditionalVaR], [strVaRModel], [dblConfidence], [dtmStartDate], [strBaseFX]) 
	VALUES ('Cotton #2 May 22 Put', 'ICE', 'CTK76.0Q.FO', -190, 0.22, 20900.00, 76456.00, 42702.50, 111783.33, NULL, NULL, NULL, NULL,NULL,NULL)

	INSERT INTO tblDBRiskDemoVaR([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblVaR], [dblComponentVaR], [dblConditionalVaR], [dblTotalVaR], [dblTotalConditionalVaR], [strVaRModel], [dblConfidence], [dtmStartDate], [strBaseFX]) 
	VALUES ('Cotton #2 Dec 22 Call', 'ICE', 'CTZ76.0D.FO', -563, 16.45, 4630675.00, 337715.55, 438211.05, 406298.33, NULL, NULL, NULL, NULL,NULL,NULL)

	INSERT INTO tblDBRiskDemoVaR([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblVaR], [dblComponentVaR], [dblConditionalVaR], [dblTotalVaR], [dblTotalConditionalVaR], [strVaRModel], [dblConfidence], [dtmStartDate], [strBaseFX]) 
	VALUES ('Cotton #2 Dec 22 Call', 'ICE', 'CTK75.0D.FO', -917, 30.11, 13805435.00,  1336573.35, 1560046.25, 1710205.00, NULL, NULL, NULL, NULL,NULL,NULL)

	INSERT INTO tblDBRiskDemoVaR([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblVaR], [dblComponentVaR], [dblConditionalVaR], [dblTotalVaR], [dblTotalConditionalVaR], [strVaRModel], [dblConfidence], [dtmStartDate], [strBaseFX]) 
	VALUES ('Cotton #2 Dec 22 Put', 'ICE', 'CTZ71.0Q.FO', -231, 1.49, 172095.00, 67313.40, 56872.20, 102025.00, NULL, NULL, NULL, NULL,NULL,NULL)




	--tblDBRiskDemoMultiDayVaR
	INSERT INTO tblDBRiskDemoMultiDayVaR([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblVaR], [dblComponentVaR], [dblConditionalVaR], [dblTotalVaR], [dblTotalConditionalVaR], [strVaRModel], [dblConfidence], [dtmStartDate], [strBaseFX], [ysnSliding], [dblSampleRate]) 
	VALUES ('Cotton #2', 'ICE', 'CTH22', 487, 106.23, 25867005.00, 2307784.04, 2248243.81, 3224548.75, 16693317.29, 24307917.20, 'Parmetric', 0.01,'12/14/2020','USD', 1, 10)

	INSERT INTO tblDBRiskDemoMultiDayVaR([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblVaR], [dblComponentVaR], [dblConditionalVaR], [dblTotalVaR], [dblTotalConditionalVaR], [strVaRModel], [dblConfidence], [dtmStartDate], [strBaseFX], [ysnSliding]) 
	VALUES ('Cotton #2', 'ICE', 'CTH22', 257, 104.93,  13483505.00, 1145026.92, 1120951.64, 1588951.92, NULL, NULL, NULL, NULL,NULL,NULL, NULL)

	INSERT INTO tblDBRiskDemoMultiDayVaR([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblVaR], [dblComponentVaR], [dblConditionalVaR], [dblTotalVaR], [dblTotalConditionalVaR], [strVaRModel], [dblConfidence], [dtmStartDate], [strBaseFX], [ysnSliding]) 
	VALUES ('Cotton #2', 'ICE', 'CTH22', 736, 102.8, 37830400.00, 2933139.41, 2899723.42, 4247333.33, NULL, NULL, NULL, NULL,NULL,NULL, NULL)

	INSERT INTO tblDBRiskDemoMultiDayVaR([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblVaR], [dblComponentVaR], [dblConditionalVaR], [dblTotalVaR], [dblTotalConditionalVaR], [strVaRModel], [dblConfidence], [dtmStartDate], [strBaseFX], [ysnSliding])  
	VALUES ('Cotton #2', 'ICE', 'CTH22', 393, 94.55, 18579075.00, 1109802.81, 1073206.45, 1498148.75, NULL, NULL, NULL, NULL,NULL,NULL, NULL)

	INSERT INTO tblDBRiskDemoMultiDayVaR([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblVaR], [dblComponentVaR], [dblConditionalVaR], [dblTotalVaR], [dblTotalConditionalVaR], [strVaRModel], [dblConfidence], [dtmStartDate], [strBaseFX], [ysnSliding])  
	VALUES ('Cotton #2', 'ICE', 'CTH22', 859, 89.75, 38547625.00, 1819209.28, 1693477.27, 2435655.45, NULL, NULL, NULL, NULL,NULL,NULL, NULL)

	INSERT INTO tblDBRiskDemoMultiDayVaR([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblVaR], [dblComponentVaR], [dblConditionalVaR], [dblTotalVaR], [dblTotalConditionalVaR], [strVaRModel], [dblConfidence], [dtmStartDate], [strBaseFX], [ysnSliding])  
	VALUES ('Cotton #2', 'ICE', 'CTH23', 257, 86.6, 11128100.00, 535000.86, 469582.51, 703011.82, NULL, NULL, NULL, NULL,NULL,NULL, NULL)

	INSERT INTO tblDBRiskDemoMultiDayVaR([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblVaR], [dblComponentVaR], [dblConditionalVaR], [dblTotalVaR], [dblTotalConditionalVaR], [strVaRModel], [dblConfidence], [dtmStartDate], [strBaseFX], [ysnSliding])  
	VALUES ('Cotton #2', 'ICE', 'CTH23', 648, 85.35, 27653400.00, 1351484.38, 1118518.36, 1725624.00, NULL, NULL, NULL, NULL,NULL,NULL, NULL)

	INSERT INTO tblDBRiskDemoMultiDayVaR([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblVaR], [dblComponentVaR], [dblConditionalVaR], [dblTotalVaR], [dblTotalConditionalVaR], [strVaRModel], [dblConfidence], [dtmStartDate], [strBaseFX], [ysnSliding])  
	VALUES ('Cotton #2', 'ICE', 'CTH23', 449, 83.8, 18813100.00, 886227.25, 663854.79, 1115765.00, NULL, NULL, NULL, NULL,NULL,NULL, NULL)

	INSERT INTO tblDBRiskDemoMultiDayVaR([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblVaR], [dblComponentVaR], [dblConditionalVaR], [dblTotalVaR], [dblTotalConditionalVaR], [strVaRModel], [dblConfidence], [dtmStartDate], [strBaseFX], [ysnSliding])  
	VALUES ('Cotton #2', 'ICE', 'CTH23', -326, 81.19, 13233970.00, 602116.74, 391521.72, 707691.67, NULL, NULL, NULL, NULL,NULL,NULL, NULL)

	INSERT INTO tblDBRiskDemoMultiDayVaR([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblVaR], [dblComponentVaR], [dblConditionalVaR], [dblTotalVaR], [dblTotalConditionalVaR], [strVaRModel], [dblConfidence], [dtmStartDate], [strBaseFX], [ysnSliding])  
	VALUES ('Cotton #2', 'ICE', 'CTH23', -9, 79.19, 356355.00, 15981.44, 8855.73, 17947.50, NULL, NULL, NULL, NULL,NULL,NULL, NULL)

	INSERT INTO tblDBRiskDemoMultiDayVaR([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblVaR], [dblComponentVaR], [dblConditionalVaR], [dblTotalVaR], [dblTotalConditionalVaR], [strVaRModel], [dblConfidence], [dtmStartDate], [strBaseFX], [ysnSliding])  
	VALUES ('Cotton #2', 'ICE', 'CTH24', -35, 79.69, 1394575.00, 54148.76, 30292.70, 63950.00, NULL, NULL, NULL, NULL,NULL,NULL, NULL)

	INSERT INTO tblDBRiskDemoMultiDayVaR([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblVaR], [dblComponentVaR], [dblConditionalVaR], [dblTotalVaR], [dblTotalConditionalVaR], [strVaRModel], [dblConfidence], [dtmStartDate], [strBaseFX], [ysnSliding])  
	VALUES ('Cotton #2', 'ICE', 'CTH24', -246, 80.19, 9863370.00, 316557.10, 147747.54, 406720.00, NULL, NULL, NULL, NULL,NULL,NULL, NULL)

	INSERT INTO tblDBRiskDemoMultiDayVaR([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblVaR], [dblComponentVaR], [dblConditionalVaR], [dblTotalVaR], [dblTotalConditionalVaR], [strVaRModel], [dblConfidence], [dtmStartDate], [strBaseFX], [ysnSliding])  
	VALUES ('Cotton #2', 'ICE', 'CTH24', -566, 80.69, 22835270.00, 722387.99, 263670.73, 939913.75, NULL, NULL, NULL, NULL,NULL,NULL, NULL)

	INSERT INTO tblDBRiskDemoMultiDayVaR([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblVaR], [dblComponentVaR], [dblConditionalVaR], [dblTotalVaR], [dblTotalConditionalVaR], [strVaRModel], [dblConfidence], [dtmStartDate], [strBaseFX], [ysnSliding])  
	VALUES ('Cotton #2', 'ICE', 'CTH24', -920, 80.19, 36887400.00, 423384.97, 55279.70, 693986.67, NULL, NULL, NULL, NULL,NULL,NULL, NULL)

	INSERT INTO tblDBRiskDemoMultiDayVaR([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblVaR], [dblComponentVaR], [dblConditionalVaR], [dblTotalVaR], [dblTotalConditionalVaR], [strVaRModel], [dblConfidence], [dtmStartDate], [strBaseFX], [ysnSliding])  
	VALUES ('Cotton #2 July 22 Put', 'ICE', 'CTN69.0Q.FO', 626, 0.21, 65730.00, 283452.21, 128716.13, 343048.00, NULL, NULL, NULL, NULL,NULL,NULL, NULL)

	INSERT INTO tblDBRiskDemoMultiDayVaR([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblVaR], [dblComponentVaR], [dblConditionalVaR], [dblTotalVaR], [dblTotalConditionalVaR], [strVaRModel], [dblConfidence], [dtmStartDate], [strBaseFX], [ysnSliding])  
	VALUES ('Cotton #2 July 22 Put', 'ICE', 'CTN68.0Q.FO', -156, 0.17, 13260.00, 65192.47, 28361.82, 79092.00, NULL, NULL, NULL, NULL,NULL,NULL, NULL)

	INSERT INTO tblDBRiskDemoMultiDayVaR([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblVaR], [dblComponentVaR], [dblConditionalVaR], [dblTotalVaR], [dblTotalConditionalVaR], [strVaRModel], [dblConfidence], [dtmStartDate], [strBaseFX], [ysnSliding])  
	VALUES ('Cotton #2 July 22 Put', 'ICE', 'CTN40.0Q.FO', 276, 0.01, 1380.00, 6174.54, 251.27, 8772.86, NULL, NULL, NULL, NULL,NULL,NULL, NULL)

	INSERT INTO tblDBRiskDemoMultiDayVaR([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblVaR], [dblComponentVaR], [dblConditionalVaR], [dblTotalVaR], [dblTotalConditionalVaR], [strVaRModel], [dblConfidence], [dtmStartDate], [strBaseFX], [ysnSliding])  
	VALUES ('Cotton #2 Dec 22 Call', 'ICE', 'CTZ64.0D.FO', 975, 26.3, 12821250.00, 1845646.13, 1723094.53, 2593093.75, NULL, NULL, NULL, NULL,NULL,NULL, NULL)

	INSERT INTO tblDBRiskDemoMultiDayVaR([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblVaR], [dblComponentVaR], [dblConditionalVaR], [dblTotalVaR], [dblTotalConditionalVaR], [strVaRModel], [dblConfidence], [dtmStartDate], [strBaseFX], [ysnSliding])  
	VALUES ('Cotton #2 March 22 Call', 'ICE', 'CTH81.0D.FO', 712, 25.35, 9024600.00, 3019171.13, 2887125.26, 4123527.06, NULL, NULL, NULL, NULL,NULL,NULL, NULL)

	INSERT INTO tblDBRiskDemoMultiDayVaR([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblVaR], [dblComponentVaR], [dblConditionalVaR], [dblTotalVaR], [dblTotalConditionalVaR], [strVaRModel], [dblConfidence], [dtmStartDate], [strBaseFX], [ysnSliding])  
	VALUES ('Cotton #2 July 22 Call', 'ICE', 'CTN71.0D.FO', 598, 32.09, 9594910.00, 2245702.41, 2202333.40, 3312460.05, NULL, NULL, NULL, NULL,NULL,NULL, NULL)

	INSERT INTO tblDBRiskDemoMultiDayVaR([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblVaR], [dblComponentVaR], [dblConditionalVaR], [dblTotalVaR], [dblTotalConditionalVaR], [strVaRModel], [dblConfidence], [dtmStartDate], [strBaseFX], [ysnSliding])  
	VALUES ('Cotton #2 July 22 Call', 'ICE', 'CTN65.0D.FO', 720, 37.9, 13644000.00, 2790177.80, 2749950.73, 4047230.77, NULL, NULL, NULL, NULL,NULL,NULL, NULL)

	INSERT INTO tblDBRiskDemoMultiDayVaR([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblVaR], [dblComponentVaR], [dblConditionalVaR], [dblTotalVaR], [dblTotalConditionalVaR], [strVaRModel], [dblConfidence], [dtmStartDate], [strBaseFX], [ysnSliding])  
	VALUES ('Cotton #2 July 22 Call', 'ICE', 'CTH90.0D.FO', 248, 16.77, 2079480.00, 928016.92, 871201.74, 1293684.71, NULL, NULL, NULL, NULL,NULL,NULL, NULL)

	INSERT INTO tblDBRiskDemoMultiDayVaR([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblVaR], [dblComponentVaR], [dblConditionalVaR], [dblTotalVaR], [dblTotalConditionalVaR], [strVaRModel], [dblConfidence], [dtmStartDate], [strBaseFX], [ysnSliding])  
	VALUES ('Cotton #2 July 22 Call', 'ICE', 'CTH82.0D.FO', 91, 24.37, 1108835.00, 381940.47, 364542.90, 523169.71, NULL, NULL, NULL, NULL,NULL,NULL, NULL)

	INSERT INTO tblDBRiskDemoMultiDayVaR([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblVaR], [dblComponentVaR], [dblConditionalVaR], [dblTotalVaR], [dblTotalConditionalVaR], [strVaRModel], [dblConfidence], [dtmStartDate], [strBaseFX], [ysnSliding])  
	VALUES ('Cotton #2 May 22 Put', 'ICE', 'CTK76.0Q.FO', -190, 0.22, 20900.00, 142460.72, 73000.68, 64908.82, NULL, NULL, NULL, NULL,NULL,NULL, NULL)

	INSERT INTO tblDBRiskDemoMultiDayVaR([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblVaR], [dblComponentVaR], [dblConditionalVaR], [dblTotalVaR], [dblTotalConditionalVaR], [strVaRModel], [dblConfidence], [dtmStartDate], [strBaseFX], [ysnSliding])  
	VALUES ('Cotton #2 Dec 22 Call', 'ICE', 'CTZ76.0D.FO', -563, 16.45, 4630675.00, 884957.25, 807757.44, 1272849.17, NULL, NULL, NULL, NULL,NULL,NULL, NULL)

	INSERT INTO tblDBRiskDemoMultiDayVaR([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblVaR], [dblComponentVaR], [dblConditionalVaR], [dblTotalVaR], [dblTotalConditionalVaR], [strVaRModel], [dblConfidence], [dtmStartDate], [strBaseFX], [ysnSliding])  
	VALUES ('Cotton #2 Dec 22 Call', 'ICE', 'CTK75.0D.FO', -917, 30.11, 13805435.00, 3809409.12, 3690088.54, 5182128.88, NULL, NULL, NULL, NULL,NULL,NULL, NULL)

	INSERT INTO tblDBRiskDemoMultiDayVaR([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblVaR], [dblComponentVaR], [dblConditionalVaR], [dblTotalVaR], [dblTotalConditionalVaR], [strVaRModel], [dblConfidence], [dtmStartDate], [strBaseFX], [ysnSliding])  
	VALUES ('Cotton #2 Dec 22 Put', 'ICE', 'CTZ71.0Q.FO', -231, 1.49, 172095.00, 165932.09, 87053.46, 270911.67, NULL, NULL, NULL, NULL,NULL,NULL, NULL)



	--tblDBRiskDemoStressTestingIndex
	INSERT INTO tblDBRiskDemoStressTestingIndex([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [strIndex], [strStressType], [dblSpotStress], [dblVolatilityStress], [dblIndexStress], [dblStressPrice], [dblStressImpact], [dblTotalStressImpact], [dtmStartDate]) 
	VALUES ('Cotton #2', 'ICE', 'CTH22', 487, 106.23, 25867005.00, 'CTY1', 'Index', -5, 0, 0, 105.1677, 258670.05, 1869661.82, '11/14/2021')

	INSERT INTO tblDBRiskDemoStressTestingIndex([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [strIndex], [strStressType], [dblSpotStress], [dblVolatilityStress], [dblIndexStress], [dblStressPrice], [dblStressImpact], [dblTotalStressImpact], [dtmStartDate]) 
	VALUES ('Cotton #2', 'ICE', 'CTH22', 257, 104.93,  13483505.00, NULL, NULL, NULL, NULL, NULL, 103.8790829, 135042.84, NULL, NULL)

	INSERT INTO tblDBRiskDemoStressTestingIndex([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [strIndex], [strStressType], [dblSpotStress], [dblVolatilityStress], [dblIndexStress], [dblStressPrice], [dblStressImpact], [dblTotalStressImpact], [dtmStartDate]) 
	VALUES ('Cotton #2', 'ICE', 'CTH22', 736, 102.8, 37830400.00, NULL, NULL, NULL, NULL, NULL, 101.8829606, 337470.49, NULL, NULL)

	INSERT INTO tblDBRiskDemoStressTestingIndex([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [strIndex], [strStressType], [dblSpotStress], [dblVolatilityStress], [dblIndexStress], [dblStressPrice], [dblStressImpact], [dblTotalStressImpact], [dtmStartDate])  
	VALUES ('Cotton #2', 'ICE', 'CTH22', 393, 94.55, 18579075.00, NULL, NULL, NULL, NULL, NULL, 93.8620141, 135189.23, NULL, NULL)

	INSERT INTO tblDBRiskDemoStressTestingIndex([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [strIndex], [strStressType], [dblSpotStress], [dblVolatilityStress], [dblIndexStress], [dblStressPrice], [dblStressImpact], [dblTotalStressImpact], [dtmStartDate])  
	VALUES ('Cotton #2', 'ICE', 'CTH22', 859, 89.75, 38547625.00, NULL, NULL, NULL, NULL, NULL, 89.18922555, 240852.63, NULL, NULL)

	INSERT INTO tblDBRiskDemoStressTestingIndex([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [strIndex], [strStressType], [dblSpotStress], [dblVolatilityStress], [dblIndexStress], [dblStressPrice], [dblStressImpact], [dblTotalStressImpact], [dtmStartDate])  
	VALUES ('Cotton #2', 'ICE', 'CTH23', 257, 86.6, 11128100.00, NULL, NULL, NULL, NULL, NULL, 86.08380295, 66331.32, NULL, NULL)

	INSERT INTO tblDBRiskDemoStressTestingIndex([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [strIndex], [strStressType], [dblSpotStress], [dblVolatilityStress], [dblIndexStress], [dblStressPrice], [dblStressImpact], [dblTotalStressImpact], [dtmStartDate])  
	VALUES ('Cotton #2', 'ICE', 'CTH23', 648, 85.35, 27653400.00, NULL, NULL, NULL, NULL, NULL, 84.84534822, 163507.18, NULL, NULL)

	INSERT INTO tblDBRiskDemoStressTestingIndex([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [strIndex], [strStressType], [dblSpotStress], [dblVolatilityStress], [dblIndexStress], [dblStressPrice], [dblStressImpact], [dblTotalStressImpact], [dtmStartDate])  
	VALUES ('Cotton #2', 'ICE', 'CTH23', 449, 83.8, 18813100.00, NULL, NULL, NULL, NULL, NULL, 83.34330498, 102528.03, NULL, NULL)

	INSERT INTO tblDBRiskDemoStressTestingIndex([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [strIndex], [strStressType], [dblSpotStress], [dblVolatilityStress], [dblIndexStress], [dblStressPrice], [dblStressImpact], [dblTotalStressImpact], [dtmStartDate])  
	VALUES ('Cotton #2', 'ICE', 'CTH23', -326, 81.19, 13233970.00, NULL, NULL, NULL, NULL, NULL, 80.77219456, 68102.29, NULL, NULL)

	INSERT INTO tblDBRiskDemoStressTestingIndex([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [strIndex], [strStressType], [dblSpotStress], [dblVolatilityStress], [dblIndexStress], [dblStressPrice], [dblStressImpact], [dblTotalStressImpact], [dtmStartDate])  
	VALUES ('Cotton #2', 'ICE', 'CTH23', -9, 79.19, 356355.00, NULL, NULL, NULL, NULL, NULL, 78.84318963, 1560.65, NULL, NULL)

	INSERT INTO tblDBRiskDemoStressTestingIndex([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [strIndex], [strStressType], [dblSpotStress], [dblVolatilityStress], [dblIndexStress], [dblStressPrice], [dblStressImpact], [dblTotalStressImpact], [dtmStartDate])  
	VALUES ('Cotton #2', 'ICE', 'CTH24', -35, 79.69, 1394575.00, NULL, NULL, NULL, NULL, NULL, 79.3724831, 5556.55, NULL, NULL)

	INSERT INTO tblDBRiskDemoStressTestingIndex([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [strIndex], [strStressType], [dblSpotStress], [dblVolatilityStress], [dblIndexStress], [dblStressPrice], [dblStressImpact], [dblTotalStressImpact], [dtmStartDate])  
	VALUES ('Cotton #2', 'ICE', 'CTH24', -246, 80.19, 9863370.00, NULL, NULL, NULL, NULL, NULL, 79.89357011, 36460.88,NULL, NULL)

	INSERT INTO tblDBRiskDemoStressTestingIndex([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [strIndex], [strStressType], [dblSpotStress], [dblVolatilityStress], [dblIndexStress], [dblStressPrice], [dblStressImpact], [dblTotalStressImpact], [dtmStartDate])  
	VALUES ('Cotton #2', 'ICE', 'CTH24', -566, 80.69, 22835270.00, NULL, NULL, NULL, NULL, NULL, 80.41479208, 77883.84 , NULL, NULL)

	INSERT INTO tblDBRiskDemoStressTestingIndex([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [strIndex], [strStressType], [dblSpotStress], [dblVolatilityStress], [dblIndexStress], [dblStressPrice], [dblStressImpact], [dblTotalStressImpact], [dtmStartDate])  
	VALUES ('Cotton #2', 'ICE', 'CTH24', -920, 80.19, 36887400.00, NULL, NULL, NULL, NULL, NULL, 79.91476535, 126607.94 ,NULL, NULL)

	INSERT INTO tblDBRiskDemoStressTestingIndex([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [strIndex], [strStressType], [dblSpotStress], [dblVolatilityStress], [dblIndexStress], [dblStressPrice], [dblStressImpact], [dblTotalStressImpact], [dtmStartDate])  
	VALUES ('Cotton #2 July 22 Put', 'ICE', 'CTN69.0Q.FO', 626, 0.21, 65730.00, NULL, NULL, NULL, NULL, NULL, 0.232892601, 7163.75 ,NULL, NULL)

	INSERT INTO tblDBRiskDemoStressTestingIndex([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [strIndex], [strStressType], [dblSpotStress], [dblVolatilityStress], [dblIndexStress], [dblStressPrice], [dblStressImpact], [dblTotalStressImpact], [dtmStartDate])  
	VALUES ('Cotton #2 July 22 Put', 'ICE', 'CTN68.0Q.FO', -156, 0.17, 13260.00, NULL, NULL, NULL, NULL, NULL, 0.189111247, 1490.42 ,NULL, NULL)

	INSERT INTO tblDBRiskDemoStressTestingIndex([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [strIndex], [strStressType], [dblSpotStress], [dblVolatilityStress], [dblIndexStress], [dblStressPrice], [dblStressImpact], [dblTotalStressImpact], [dtmStartDate])  
	VALUES ('Cotton #2 July 22 Put', 'ICE', 'CTN40.0Q.FO', 276, 0.01, 1380.00, NULL, NULL, NULL, NULL, NULL, 0.010967955, 132.62 ,NULL, NULL)

	INSERT INTO tblDBRiskDemoStressTestingIndex([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [strIndex], [strStressType], [dblSpotStress], [dblVolatilityStress], [dblIndexStress], [dblStressPrice], [dblStressImpact], [dblTotalStressImpact], [dtmStartDate])  
	VALUES ('Cotton #2 Dec 22 Call', 'ICE', 'CTZ64.0D.FO', 975, 26.3, 12821250.00, NULL, NULL, NULL, NULL, NULL, 25.79598473, 245710.21, NULL, NULL)

	INSERT INTO tblDBRiskDemoStressTestingIndex([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [strIndex], [strStressType], [dblSpotStress], [dblVolatilityStress], [dblIndexStress], [dblStressPrice], [dblStressImpact], [dblTotalStressImpact], [dtmStartDate])  
	VALUES ('Cotton #2 March 22 Call', 'ICE', 'CTH81.0D.FO', 712, 25.35, 9024600.00, NULL, NULL, NULL, NULL, NULL, 24.25422083, 350937.78, NULL, NULL)

	INSERT INTO tblDBRiskDemoStressTestingIndex([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [strIndex], [strStressType], [dblSpotStress], [dblVolatilityStress], [dblIndexStress], [dblStressPrice], [dblStressImpact], [dblTotalStressImpact], [dtmStartDate])  
	VALUES ('Cotton #2 July 22 Call', 'ICE', 'CTN71.0D.FO', 598, 32.09, 9594910.00, NULL, NULL, NULL, NULL, NULL, 30.96914375, 251416.97, NULL, NULL)

	INSERT INTO tblDBRiskDemoStressTestingIndex([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [strIndex], [strStressType], [dblSpotStress], [dblVolatilityStress], [dblIndexStress], [dblStressPrice], [dblStressImpact], [dblTotalStressImpact], [dtmStartDate])  
	VALUES ('Cotton #2 July 22 Call', 'ICE', 'CTN65.0D.FO', 720, 37.9, 13644000.00, NULL, NULL, NULL, NULL, NULL, 36.97718852, 299814.20, NULL, NULL)

	INSERT INTO tblDBRiskDemoStressTestingIndex([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [strIndex], [strStressType], [dblSpotStress], [dblVolatilityStress], [dblIndexStress], [dblStressPrice], [dblStressImpact], [dblTotalStressImpact], [dtmStartDate])  
	VALUES ('Cotton #2 July 22 Call', 'ICE', 'CTH90.0D.FO', 248, 16.77, 2079480.00, NULL, NULL, NULL, NULL, NULL, 15.81942209, 117872.11,NULL, NULL)

	INSERT INTO tblDBRiskDemoStressTestingIndex([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [strIndex], [strStressType], [dblSpotStress], [dblVolatilityStress], [dblIndexStress], [dblStressPrice], [dblStressImpact], [dblTotalStressImpact], [dtmStartDate])  
	VALUES ('Cotton #2 July 22 Call', 'ICE', 'CTH82.0D.FO', 91, 24.37, 1108835.00, NULL, NULL, NULL, NULL, NULL, 23.25295569, 44910.28,NULL, NULL)

	INSERT INTO tblDBRiskDemoStressTestingIndex([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [strIndex], [strStressType], [dblSpotStress], [dblVolatilityStress], [dblIndexStress], [dblStressPrice], [dblStressImpact], [dblTotalStressImpact], [dtmStartDate])  
	VALUES ('Cotton #2 May 22 Put', 'ICE', 'CTK76.0Q.FO', -190, 0.22, 20900.00, NULL, NULL, NULL, NULL, NULL, 0.25215954, 3055.45,NULL, NULL)

	INSERT INTO tblDBRiskDemoStressTestingIndex([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [strIndex], [strStressType], [dblSpotStress], [dblVolatilityStress], [dblIndexStress], [dblStressPrice], [dblStressImpact], [dblTotalStressImpact], [dtmStartDate])  
	VALUES ('Cotton #2 Dec 22 Call', 'ICE', 'CTZ76.0D.FO', -563, 16.45, 4630675.00, NULL, NULL, NULL, NULL, NULL, 16.01089635, 123605.66 ,NULL, NULL)

	INSERT INTO tblDBRiskDemoStressTestingIndex([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [strIndex], [strStressType], [dblSpotStress], [dblVolatilityStress], [dblIndexStress], [dblStressPrice], [dblStressImpact], [dblTotalStressImpact], [dtmStartDate])  
	VALUES ('Cotton #2 Dec 22 Call', 'ICE', 'CTK75.0D.FO', -917, 30.11, 13805435.00, NULL, NULL, NULL, NULL, NULL, 28.9724398, 443626.10 ,NULL, NULL)

	INSERT INTO tblDBRiskDemoStressTestingIndex([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [strIndex], [strStressType], [dblSpotStress], [dblVolatilityStress], [dblIndexStress], [dblStressPrice], [dblStressImpact], [dblTotalStressImpact], [dtmStartDate])  
	VALUES ('Cotton #2 Dec 22 Put', 'ICE', 'CTZ71.0Q.FO', -231, 1.49, 172095.00, NULL, NULL, NULL, NULL, NULL, 1.563966398, 8543.74,NULL, NULL)

	--tblDBRiskDemoStressTestingVolumeAndSpot
	INSERT INTO tblDBRiskDemoStressTestingVolumeAndSpot([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [strIndex], [strStressType], [dblSpotStress], [dblVolatilityStress], [dblIndexStress], [dblStressPrice], [dblStressImpact], [dblTotalStressImpact], [dtmStartDate]) 
	VALUES ('Cotton #2', 'ICE', 'CTH22', 487, 106.23, 25867005.00, 'CTY1', 'Both', -5, 0.1, 0, 100.9185,  1293350.25,  9034817.94, '11/14/2021')

	INSERT INTO tblDBRiskDemoStressTestingVolumeAndSpot([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [strIndex], [strStressType], [dblSpotStress], [dblVolatilityStress], [dblIndexStress], [dblStressPrice], [dblStressImpact], [dblTotalStressImpact], [dtmStartDate]) 
	VALUES ('Cotton #2', 'ICE', 'CTH22', 257, 104.93,  13483505.00, NULL, NULL, NULL, NULL, NULL, 99.6835, 674175.25, NULL, NULL)

	INSERT INTO tblDBRiskDemoStressTestingVolumeAndSpot([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [strIndex], [strStressType], [dblSpotStress], [dblVolatilityStress], [dblIndexStress], [dblStressPrice], [dblStressImpact], [dblTotalStressImpact], [dtmStartDate]) 
	VALUES ('Cotton #2', 'ICE', 'CTH22', 736, 102.8, 37830400.00, NULL, NULL, NULL, NULL, NULL, 97.66, 1891520.00, NULL, NULL)

	INSERT INTO tblDBRiskDemoStressTestingVolumeAndSpot([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [strIndex], [strStressType], [dblSpotStress], [dblVolatilityStress], [dblIndexStress], [dblStressPrice], [dblStressImpact], [dblTotalStressImpact], [dtmStartDate])  
	VALUES ('Cotton #2', 'ICE', 'CTH22', 393, 94.55, 18579075.00, NULL, NULL, NULL, NULL, NULL, 89.8225, 928953.75, NULL, NULL)

	INSERT INTO tblDBRiskDemoStressTestingVolumeAndSpot([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [strIndex], [strStressType], [dblSpotStress], [dblVolatilityStress], [dblIndexStress], [dblStressPrice], [dblStressImpact], [dblTotalStressImpact], [dtmStartDate])  
	VALUES ('Cotton #2', 'ICE', 'CTH22', 859, 89.75, 38547625.00, NULL, NULL, NULL, NULL, NULL, 85.2625, 1927381.25, NULL, NULL)

	INSERT INTO tblDBRiskDemoStressTestingVolumeAndSpot([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [strIndex], [strStressType], [dblSpotStress], [dblVolatilityStress], [dblIndexStress], [dblStressPrice], [dblStressImpact], [dblTotalStressImpact], [dtmStartDate])  
	VALUES ('Cotton #2', 'ICE', 'CTH23', 257, 86.6, 11128100.00, NULL, NULL, NULL, NULL, NULL, 82.27, 556405.00, NULL, NULL)

	INSERT INTO tblDBRiskDemoStressTestingVolumeAndSpot([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [strIndex], [strStressType], [dblSpotStress], [dblVolatilityStress], [dblIndexStress], [dblStressPrice], [dblStressImpact], [dblTotalStressImpact], [dtmStartDate])  
	VALUES ('Cotton #2', 'ICE', 'CTH23', 648, 85.35, 27653400.00, NULL, NULL, NULL, NULL, NULL, 81.0825, 1382670.00, NULL, NULL)

	INSERT INTO tblDBRiskDemoStressTestingVolumeAndSpot([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [strIndex], [strStressType], [dblSpotStress], [dblVolatilityStress], [dblIndexStress], [dblStressPrice], [dblStressImpact], [dblTotalStressImpact], [dtmStartDate])  
	VALUES ('Cotton #2', 'ICE', 'CTH23', 449, 83.8, 18813100.00, NULL, NULL, NULL, NULL, NULL, 79.61, 940655.00, NULL, NULL)

	INSERT INTO tblDBRiskDemoStressTestingVolumeAndSpot([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [strIndex], [strStressType], [dblSpotStress], [dblVolatilityStress], [dblIndexStress], [dblStressPrice], [dblStressImpact], [dblTotalStressImpact], [dtmStartDate])  
	VALUES ('Cotton #2', 'ICE', 'CTH23', -326, 81.19, 13233970.00, NULL, NULL, NULL, NULL, NULL, 77.1305, 661698.50, NULL, NULL)

	INSERT INTO tblDBRiskDemoStressTestingVolumeAndSpot([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [strIndex], [strStressType], [dblSpotStress], [dblVolatilityStress], [dblIndexStress], [dblStressPrice], [dblStressImpact], [dblTotalStressImpact], [dtmStartDate])  
	VALUES ('Cotton #2', 'ICE', 'CTH23', -9, 79.19, 356355.00, NULL, NULL, NULL, NULL, NULL, 75.2305, 17817.75, NULL, NULL)

	INSERT INTO tblDBRiskDemoStressTestingVolumeAndSpot([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [strIndex], [strStressType], [dblSpotStress], [dblVolatilityStress], [dblIndexStress], [dblStressPrice], [dblStressImpact], [dblTotalStressImpact], [dtmStartDate])  
	VALUES ('Cotton #2', 'ICE', 'CTH24', -35, 79.69, 1394575.00, NULL, NULL, NULL, NULL, NULL, 75.7055, 69728.75, NULL, NULL)

	INSERT INTO tblDBRiskDemoStressTestingVolumeAndSpot([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [strIndex], [strStressType], [dblSpotStress], [dblVolatilityStress], [dblIndexStress], [dblStressPrice], [dblStressImpact], [dblTotalStressImpact], [dtmStartDate])  
	VALUES ('Cotton #2', 'ICE', 'CTH24', -246, 80.19, 9863370.00, NULL, NULL, NULL, NULL, NULL, 76.1805, 493168.50, NULL, NULL)

	INSERT INTO tblDBRiskDemoStressTestingVolumeAndSpot([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [strIndex], [strStressType], [dblSpotStress], [dblVolatilityStress], [dblIndexStress], [dblStressPrice], [dblStressImpact], [dblTotalStressImpact], [dtmStartDate])  
	VALUES ('Cotton #2', 'ICE', 'CTH24', -566, 80.69, 22835270.00, NULL, NULL, NULL, NULL, NULL, 76.6555, 1141763.50, NULL, NULL)

	INSERT INTO tblDBRiskDemoStressTestingVolumeAndSpot([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [strIndex], [strStressType], [dblSpotStress], [dblVolatilityStress], [dblIndexStress], [dblStressPrice], [dblStressImpact], [dblTotalStressImpact], [dtmStartDate])  
	VALUES ('Cotton #2', 'ICE', 'CTH24', -920, 80.19, 36887400.00, NULL, NULL, NULL, NULL, NULL, 76.1805, 1844370.00, NULL, NULL)

	INSERT INTO tblDBRiskDemoStressTestingVolumeAndSpot([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [strIndex], [strStressType], [dblSpotStress], [dblVolatilityStress], [dblIndexStress], [dblStressPrice], [dblStressImpact], [dblTotalStressImpact], [dtmStartDate])  
	VALUES ('Cotton #2 July 22 Put', 'ICE', 'CTN69.0Q.FO', 626, 0.21, 65730.00, NULL, NULL, NULL, NULL, NULL, 1.225169358, 317746.38, NULL, NULL)

	INSERT INTO tblDBRiskDemoStressTestingVolumeAndSpot([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [strIndex], [strStressType], [dblSpotStress], [dblVolatilityStress], [dblIndexStress], [dblStressPrice], [dblStressImpact], [dblTotalStressImpact], [dtmStartDate])  
	VALUES ('Cotton #2 July 22 Put', 'ICE', 'CTN68.0Q.FO', -156, 0.17, 13260.00, NULL, NULL, NULL, NULL, NULL, 1.079634362, 70951.23, NULL, NULL)

	INSERT INTO tblDBRiskDemoStressTestingVolumeAndSpot([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [strIndex], [strStressType], [dblSpotStress], [dblVolatilityStress], [dblIndexStress], [dblStressPrice], [dblStressImpact], [dblTotalStressImpact], [dtmStartDate])  
	VALUES ('Cotton #2 July 22 Put', 'ICE', 'CTN40.0Q.FO', 276, 0.01, 1380.00, NULL, NULL, NULL, NULL, NULL, 0.095973619, 11863.40, NULL, NULL)

	INSERT INTO tblDBRiskDemoStressTestingVolumeAndSpot([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [strIndex], [strStressType], [dblSpotStress], [dblVolatilityStress], [dblIndexStress], [dblStressPrice], [dblStressImpact], [dblTotalStressImpact], [dtmStartDate])  
	VALUES ('Cotton #2 Dec 22 Call', 'ICE', 'CTZ64.0D.FO', 975, 26.3, 12821250.00, NULL, NULL, NULL, NULL, NULL, 24.07362014, 1085362.95, NULL, NULL)

	INSERT INTO tblDBRiskDemoStressTestingVolumeAndSpot([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [strIndex], [strStressType], [dblSpotStress], [dblVolatilityStress], [dblIndexStress], [dblStressPrice], [dblStressImpact], [dblTotalStressImpact], [dtmStartDate])  
	VALUES ('Cotton #2 March 22 Call', 'ICE', 'CTH81.0D.FO', 712, 25.35, 9024600.00, NULL, NULL, NULL, NULL, NULL, 21.05311013, 1490533.18, NULL, NULL)

	INSERT INTO tblDBRiskDemoStressTestingVolumeAndSpot([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [strIndex], [strStressType], [dblSpotStress], [dblVolatilityStress], [dblIndexStress], [dblStressPrice], [dblStressImpact], [dblTotalStressImpact], [dtmStartDate])  
	VALUES ('Cotton #2 July 22 Call', 'ICE', 'CTN71.0D.FO', 598, 32.09, 9594910.00, NULL, NULL, NULL, NULL, NULL, 28.25408082, 1063220.79, NULL, NULL)

	INSERT INTO tblDBRiskDemoStressTestingVolumeAndSpot([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [strIndex], [strStressType], [dblSpotStress], [dblVolatilityStress], [dblIndexStress], [dblStressPrice], [dblStressImpact], [dblTotalStressImpact], [dtmStartDate])  
	VALUES ('Cotton #2 July 22 Call', 'ICE', 'CTN65.0D.FO', 720, 37.9, 13644000.00, NULL, NULL, NULL, NULL, NULL, 34.215627, 1293976.35, NULL, NULL)

	INSERT INTO tblDBRiskDemoStressTestingVolumeAndSpot([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [strIndex], [strStressType], [dblSpotStress], [dblVolatilityStress], [dblIndexStress], [dblStressPrice], [dblStressImpact], [dblTotalStressImpact], [dtmStartDate])  
	VALUES ('Cotton #2 July 22 Call', 'ICE', 'CTH90.0D.FO', 248, 16.77, 2079480.00, NULL, NULL, NULL, NULL, NULL, 13.33711224, 425678.54, NULL, NULL)

	INSERT INTO tblDBRiskDemoStressTestingVolumeAndSpot([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [strIndex], [strStressType], [dblSpotStress], [dblVolatilityStress], [dblIndexStress], [dblStressPrice], [dblStressImpact], [dblTotalStressImpact], [dtmStartDate])  
	VALUES ('Cotton #2 July 22 Call', 'ICE', 'CTH82.0D.FO', 91, 24.37, 1108835.00, NULL, NULL, NULL, NULL, NULL, 20.06421629, 189997.92, NULL, NULL)

	INSERT INTO tblDBRiskDemoStressTestingVolumeAndSpot([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [strIndex], [strStressType], [dblSpotStress], [dblVolatilityStress], [dblIndexStress], [dblStressPrice], [dblStressImpact], [dblTotalStressImpact], [dtmStartDate])  
	VALUES ('Cotton #2 May 22 Put', 'ICE', 'CTK76.0Q.FO', -190, 0.22, 20900.00, NULL, NULL, NULL, NULL, NULL, 1.281341149, 100827.70, NULL, NULL)

	INSERT INTO tblDBRiskDemoStressTestingVolumeAndSpot([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [strIndex], [strStressType], [dblSpotStress], [dblVolatilityStress], [dblIndexStress], [dblStressPrice], [dblStressImpact], [dblTotalStressImpact], [dtmStartDate])  
	VALUES ('Cotton #2 Dec 22 Call', 'ICE', 'CTZ76.0D.FO', -563, 16.45, 4630675.00, NULL, NULL, NULL, NULL, NULL, 15.84337944, 170761.67, NULL, NULL)

	INSERT INTO tblDBRiskDemoStressTestingVolumeAndSpot([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [strIndex], [strStressType], [dblSpotStress], [dblVolatilityStress], [dblIndexStress], [dblStressPrice], [dblStressImpact], [dblTotalStressImpact], [dtmStartDate])  
	VALUES ('Cotton #2 Dec 22 Call', 'ICE', 'CTK75.0D.FO', -917, 30.11, 13805435.00, NULL, NULL, NULL, NULL, NULL, 26.0972197, 1761914.52, NULL, NULL)

	INSERT INTO tblDBRiskDemoStressTestingVolumeAndSpot([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [strIndex], [strStressType], [dblSpotStress], [dblVolatilityStress], [dblIndexStress], [dblStressPrice], [dblStressImpact], [dblTotalStressImpact], [dtmStartDate])  
	VALUES ('Cotton #2 Dec 22 Put', 'ICE', 'CTZ71.0Q.FO', -231, 1.49, 172095.00, NULL, NULL, NULL, NULL, NULL, 4.5366977, 351894.21, NULL, NULL)



	--[tblDBRiskDemoOptionSensitivity]
	INSERT INTO tblDBRiskDemoOptionSensitivity([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblDelta], [dblGamma], [dblVega], [dblTheta], [dblRho]) 
	VALUES ('Cotton #2', 'ICE', 'CTH22', 487, 106.23, 25867005.00, 1, 0, 0, 0, 0)

	INSERT INTO tblDBRiskDemoOptionSensitivity([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblDelta], [dblGamma], [dblVega], [dblTheta], [dblRho]) 
	VALUES ('Cotton #2', 'ICE', 'CTH22', 257, 104.93,  13483505.00, 1, 0, 0, 0, 0)

	INSERT INTO tblDBRiskDemoOptionSensitivity([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblDelta], [dblGamma], [dblVega], [dblTheta], [dblRho]) 
	VALUES ('Cotton #2', 'ICE', 'CTH22', 736, 102.8, 37830400.00, 1, 0, 0, 0, 0)

	INSERT INTO tblDBRiskDemoOptionSensitivity([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblDelta], [dblGamma], [dblVega], [dblTheta], [dblRho])  
	VALUES ('Cotton #2', 'ICE', 'CTH22', 393, 94.55, 18579075.00, 1, 0, 0, 0, 0)

	INSERT INTO tblDBRiskDemoOptionSensitivity([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblDelta], [dblGamma], [dblVega], [dblTheta], [dblRho])  
	VALUES ('Cotton #2', 'ICE', 'CTH22', 859, 89.75, 38547625.00, 1, 0, 0, 0, 0)

	INSERT INTO tblDBRiskDemoOptionSensitivity([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblDelta], [dblGamma], [dblVega], [dblTheta], [dblRho])  
	VALUES ('Cotton #2', 'ICE', 'CTH23', 257, 86.6, 11128100.00, 1, 0, 0, 0, 0)

	INSERT INTO tblDBRiskDemoOptionSensitivity([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblDelta], [dblGamma], [dblVega], [dblTheta], [dblRho])  
	VALUES ('Cotton #2', 'ICE', 'CTH23', 648, 85.35, 27653400.00, 1, 0, 0, 0, 0)

	INSERT INTO tblDBRiskDemoOptionSensitivity([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblDelta], [dblGamma], [dblVega], [dblTheta], [dblRho])  
	VALUES ('Cotton #2', 'ICE', 'CTH23', 449, 83.8, 18813100.00, 1, 0, 0, 0, 0)

	INSERT INTO tblDBRiskDemoOptionSensitivity([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblDelta], [dblGamma], [dblVega], [dblTheta], [dblRho])  
	VALUES ('Cotton #2', 'ICE', 'CTH23', -326, 81.19, 13233970.00, 1, 0, 0, 0, 0)

	INSERT INTO tblDBRiskDemoOptionSensitivity([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblDelta], [dblGamma], [dblVega], [dblTheta], [dblRho])  
	VALUES ('Cotton #2', 'ICE', 'CTH23', -9, 79.19, 356355.00, 1, 0, 0, 0, 0)

	INSERT INTO tblDBRiskDemoOptionSensitivity([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblDelta], [dblGamma], [dblVega], [dblTheta], [dblRho])  
	VALUES ('Cotton #2', 'ICE', 'CTH24', -35, 79.69, 1394575.00, 1, 0, 0, 0, 0)

	INSERT INTO tblDBRiskDemoOptionSensitivity([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblDelta], [dblGamma], [dblVega], [dblTheta], [dblRho])  
	VALUES ('Cotton #2', 'ICE', 'CTH24', -246, 80.19, 9863370.00, 1, 0, 0, 0, 0)

	INSERT INTO tblDBRiskDemoOptionSensitivity([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblDelta], [dblGamma], [dblVega], [dblTheta], [dblRho])  
	VALUES ('Cotton #2', 'ICE', 'CTH24', -566, 80.69, 22835270.00, 1, 0, 0, 0, 0)

	INSERT INTO tblDBRiskDemoOptionSensitivity([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblDelta], [dblGamma], [dblVega], [dblTheta], [dblRho])  
	VALUES ('Cotton #2', 'ICE', 'CTH24', -920, 80.19, 36887400.00, 1, 0, 0, 0, 0)

	INSERT INTO tblDBRiskDemoOptionSensitivity([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblDelta], [dblGamma], [dblVega], [dblTheta], [dblRho])  
	VALUES ('Cotton #2 July 22 Put', 'ICE', 'CTN69.0Q.FO', 626, 0.21, 65730.00, -0.02374739, 0.002562217, 0.040624916, -0.012260645, -0.013194303)

	INSERT INTO tblDBRiskDemoOptionSensitivity([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblDelta], [dblGamma], [dblVega], [dblTheta], [dblRho])  
	VALUES ('Cotton #2 July 22 Put', 'ICE', 'CTN68.0Q.FO', -156, 0.17, 13260.00, -0.019793177, 0.002202683, 0.03483127, -0.01046941, -0.010975212)

	INSERT INTO tblDBRiskDemoOptionSensitivity([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblDelta], [dblGamma], [dblVega], [dblTheta], [dblRho])  
	VALUES ('Cotton #2 July 22 Put', 'ICE', 'CTN40.0Q.FO', 276, 0.01, 1380.00, -0.000999847, 0.000103739, 0.002443461, -0.001118028, -0.000562136)

	INSERT INTO tblDBRiskDemoOptionSensitivity([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblDelta], [dblGamma], [dblVega], [dblTheta], [dblRho])  
	VALUES ('Cotton #2 Dec 22 Call', 'ICE', 'CTZ64.0D.FO', 975, 26.3, 12821250.00, 0.899874898, 0.003741008, 0.12679367, -0.017560445, 9.316877124)

	INSERT INTO tblDBRiskDemoOptionSensitivity([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblDelta], [dblGamma], [dblVega], [dblTheta], [dblRho])  
	VALUES ('Cotton #2 March 22 Call', 'ICE', 'CTH81.0D.FO', 712, 25.35, 9024600.00, 0.928246365, 0.000177991, 0.048374275, -0.052661735, 49.60029944)

	INSERT INTO tblDBRiskDemoOptionSensitivity([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblDelta], [dblGamma], [dblVega], [dblTheta], [dblRho])  
	VALUES ('Cotton #2 July 22 Call', 'ICE', 'CTN71.0D.FO', 598, 32.09, 9594910.00, 0.91710654, 0.000216716, 0.083132788, -0.026255078, 29.07574125)

	INSERT INTO tblDBRiskDemoOptionSensitivity([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblDelta], [dblGamma], [dblVega], [dblTheta], [dblRho])  
	VALUES ('Cotton #2 July 22 Call', 'ICE', 'CTN65.0D.FO', 720, 37.9, 13644000.00, 0.908273336, 0.000151346, 0.084249234, -0.034581587, 32.31809043)

	INSERT INTO tblDBRiskDemoOptionSensitivity([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblDelta], [dblGamma], [dblVega], [dblTheta], [dblRho])  
	VALUES ('Cotton #2 July 22 Call', 'ICE', 'CTH90.0D.FO', 248, 16.77, 2079480.00, 0.900272532, 0.009680434, 0.073555367, -0.066005121, 15.16985601)

	INSERT INTO tblDBRiskDemoOptionSensitivity([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblDelta], [dblGamma], [dblVega], [dblTheta], [dblRho])  
	VALUES ('Cotton #2 July 22 Call', 'ICE', 'CTH82.0D.FO', 91, 24.37, 1108835.00, 0.929460615, 0.000195044, 0.048144078, -0.049729275, 48.66732743)

	INSERT INTO tblDBRiskDemoOptionSensitivity([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblDelta], [dblGamma], [dblVega], [dblTheta], [dblRho])  
	VALUES ('Cotton #2 May 22 Put', 'ICE', 'CTK76.0Q.FO', -190, 0.22, 20900.00, -0.02868785, 0.003504397, 0.040251959, -0.017880458, -0.011042857)

	INSERT INTO tblDBRiskDemoOptionSensitivity([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblDelta], [dblGamma], [dblVega], [dblTheta], [dblRho])  
	VALUES ('Cotton #2 Dec 22 Call', 'ICE', 'CTZ76.0D.FO', -563, 16.45, 4630675.00, 0.786638637, 0.012777335, 0.243929177, -0.032171149, 2.121502168)

	INSERT INTO tblDBRiskDemoOptionSensitivity([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblDelta], [dblGamma], [dblVega], [dblTheta], [dblRho])  
	VALUES ('Cotton #2 Dec 22 Call', 'ICE', 'CTK75.0D.FO', -917, 30.11, 13805435.00, 0.920905922, 0.00020286, 0.069475597,-0.034440856, 28.27708291)

	INSERT INTO tblDBRiskDemoOptionSensitivity([strDescription], [strExchange], [strSymbol], [intQuantity], [dblLastPrice], [dblMarketValue], [dblDelta], [dblGamma], [dblVega], [dblTheta], [dblRho])  
	VALUES ('Cotton #2 Dec 22 Put', 'ICE', 'CTZ71.0Q.FO', -231, 1.49, 172095.00, -0.129037943, 0.010113865, 0.180974868, -0.023640436, -0.118852586)




	----Dashboard panels
	--PRINT '*Start Creating Dashboard Panel Data for Risk Dashboard*'

	----Risk Dashboard - VaR
	--DECLARE @RiskDashboardVaRPanelId int
	--INSERT INTO [dbo].[tblDBPanel] ([intRowsReturned], [intRowsVisible], [intChartZoom], [intChartHeight], [intUserId], [intDefaultColumn], [intDefaultRow], [intDefaultWidth], [intSourcePanelId], [intConnectionId], [intDrillDownPanel], [strClass], [strPanelName], [strStyle], [strAccessType], [strCaption], [strChart], [strChartPosition], [strChartColor], [strConnectionName], [strDateCondition], [strDateCondition2], [strDateFieldName], [strDateFieldName2], [strDataSource], [strDataSource2], [strDateVariable], [strDateVariable2], [strDefaultTab], [strDescription], [strPanelNameDuplicate], [strPanelType], [strQBCriteriaOptions], [strFilterCondition], [strFilterVariable], [strFilterFieldName], [strFilterVariable2], [strFilterFieldName2], [strGroupFields], [strFilters], [strConfigurator], [ysnChartLegend], [ysnShowInGroups], [imgLayoutGrid], [imgLayoutPivotGrid], [strPanelVersion], [intFilterId], [intConcurrencyId ], [intCannedPanelId], [strSortValue]) 
	--VALUES (
	--	0, 20, 100, 250, 1, 0, 0, 0, 0, 1, 0, 'Master', 'Risk Dashboard - VaR', 'Grid', '', 'Risk Dashboard - VaR', 'Bar', 'outside', 'Base', NULL, 'None', 'None', '', '', 'select * from tblDBRiskDemoVaR', '', '@DATE@', '@DATE@', '', 'Risk Dashboard - VaR', NULL, '', '', 'None', '', '', '', '', '', '', '', 0, 0, NULL, NULL, '22.1.1', NULL, 1, 0, ''
	--)
	--SET @RiskDashboardVaRPanelId = (SELECT SCOPE_IDENTITY())
	
	--INSERT INTO [dbo].[tblDBPanelColumn] ([intPanelId], [strColumn], [strCaption], [intWidth], [strAlignment], [strArea], [strFooter], [strFormat], [intSort], [strFormatTrue], [strFormatFalse], [strDrillDownColumn], [ysnVisible], [strType], [strAxis], [strUserName], [intUserId], [intDonut], [intMinInterval], [intMaxInterval], [intStepInterval], [strIntervalFormat], [ysnHiddenColumn], [intConcurrencyId], [intCannedPanelId], [strDataType])
	--VALUES (
	--	@RiskDashboardVaRPanelId, 'strDescription', 'Description', 200, 'Left', '', '', '', 3, '', '', '', 0, 'Grid', '', 'irelyadmin', 1, 0, 0, 0, 0, '', 0, 3, 0, 'System.String'
	--)
	--INSERT INTO [dbo].[tblDBPanelColumn] ([intPanelId], [strColumn], [strCaption], [intWidth], [strAlignment], [strArea], [strFooter], [strFormat], [intSort], [strFormatTrue], [strFormatFalse], [strDrillDownColumn], [ysnVisible], [strType], [strAxis], [strUserName], [intUserId], [intDonut], [intMinInterval], [intMaxInterval], [intStepInterval], [strIntervalFormat], [ysnHiddenColumn], [intConcurrencyId], [intCannedPanelId], [strDataType])
	--VALUES (
	--	@RiskDashboardVaRPanelId, 'strExchange', 'Exchange', 100, 'Left', '', '', '', 4, '', '', '', 0, 'Grid', '', 'irelyadmin', 1, 0, 0, 0, 0, '', 0, 2, 0, 'System.String'
	--)
	--INSERT INTO [dbo].[tblDBPanelColumn] ([intPanelId], [strColumn], [strCaption], [intWidth], [strAlignment], [strArea], [strFooter], [strFormat], [intSort], [strFormatTrue], [strFormatFalse], [strDrillDownColumn], [ysnVisible], [strType], [strAxis], [strUserName], [intUserId], [intDonut], [intMinInterval], [intMaxInterval], [intStepInterval], [strIntervalFormat], [ysnHiddenColumn], [intConcurrencyId], [intCannedPanelId], [strDataType])
	--VALUES (
	--	@RiskDashboardVaRPanelId, 'strSymbol', 'Symbol', 100, 'Left', '', '', '', 5, '', '', '', 0, 'Grid', '', 'irelyadmin', 1, 0, 0, 0, 0, '',0, 2, 0, 'System.String'
	--)
	--INSERT INTO [dbo].[tblDBPanelColumn] ([intPanelId], [strColumn], [strCaption], [intWidth], [strAlignment], [strArea], [strFooter], [strFormat], [intSort], [strFormatTrue], [strFormatFalse], [strDrillDownColumn], [ysnVisible], [strType], [strAxis], [strUserName], [intUserId], [intDonut], [intMinInterval], [intMaxInterval], [intStepInterval], [strIntervalFormat], [ysnHiddenColumn], [intConcurrencyId], [intCannedPanelId], [strDataType])
	--VALUES (
	--	@RiskDashboardVaRPanelId, 'intQuantity', 'Quantity', 100, 'Left', '', '', '', 6, '', '', '', 0, 'Grid', '', 'irelyadmin', 1, 0, 0, 0, 0, '', 0, 2, 0, 'System.Int32'
	--)
	--INSERT INTO [dbo].[tblDBPanelColumn] ([intPanelId], [strColumn], [strCaption], [intWidth], [strAlignment], [strArea], [strFooter], [strFormat], [intSort], [strFormatTrue], [strFormatFalse], [strDrillDownColumn], [ysnVisible], [strType], [strAxis], [strUserName], [intUserId], [intDonut], [intMinInterval], [intMaxInterval], [intStepInterval], [strIntervalFormat], [ysnHiddenColumn], [intConcurrencyId], [intCannedPanelId], [strDataType])
	--VALUES (
	--	@RiskDashboardVaRPanelId, 'dblLastPrice', 'Last Price', 100, 'Left', '', '', '', 7, '', '', '',0 ,'Grid', '', 'irelyadmin', 1, 0, 0, 0, 0, '',0 ,2 ,0, 'System.Decimal'
	--)
	--INSERT INTO [dbo].[tblDBPanelColumn] ([intPanelId], [strColumn], [strCaption], [intWidth], [strAlignment], [strArea], [strFooter], [strFormat], [intSort], [strFormatTrue], [strFormatFalse], [strDrillDownColumn], [ysnVisible], [strType], [strAxis], [strUserName], [intUserId], [intDonut], [intMinInterval], [intMaxInterval], [intStepInterval], [strIntervalFormat], [ysnHiddenColumn], [intConcurrencyId], [intCannedPanelId], [strDataType])
	--VALUES (
	--	@RiskDashboardVaRPanelId, 'dblMarketValue', 'Market Value', 100, 'Left', '', '', '$###0.00', 8, '', '', '', 0, 'Grid', '', 'irelyadmin', 1, 0, 0, 0, 0, '', 0, 2, 0, 'System.Decimal'
	--)
	--INSERT INTO [dbo].[tblDBPanelColumn] ([intPanelId], [strColumn], [strCaption], [intWidth], [strAlignment], [strArea], [strFooter], [strFormat], [intSort], [strFormatTrue], [strFormatFalse], [strDrillDownColumn], [ysnVisible], [strType], [strAxis], [strUserName], [intUserId], [intDonut], [intMinInterval], [intMaxInterval], [intStepInterval], [strIntervalFormat], [ysnHiddenColumn], [intConcurrencyId], [intCannedPanelId], [strDataType])
	--VALUES (
	--	@RiskDashboardVaRPanelId, 'dblVaR', 'VaR', 100, 'Left', '', '', '$###0.00', 9, '', '', '', 0, 'Grid', '', 'irelyadmin', 1, 0, 0, 0, 0, '', 0, 2, 0, 'System.Decimal'
	--)
	--INSERT INTO [dbo].[tblDBPanelColumn] ([intPanelId], [strColumn], [strCaption], [intWidth], [strAlignment], [strArea], [strFooter], [strFormat], [intSort], [strFormatTrue], [strFormatFalse], [strDrillDownColumn], [ysnVisible], [strType], [strAxis], [strUserName], [intUserId], [intDonut], [intMinInterval], [intMaxInterval], [intStepInterval], [strIntervalFormat], [ysnHiddenColumn], [intConcurrencyId], [intCannedPanelId], [strDataType])
	--VALUES (
	--	@RiskDashboardVaRPanelId,'dblComponentVaR', 'Component VaR', 100, 'Left', '', '', '$###0.00', 10, '', '', '', 0, 'Grid', '', 'irelyadmin', 1, 0, 0, 0, 0, '',0, 2, 0, 'System.Decimal'
	--)
	--INSERT INTO [dbo].[tblDBPanelColumn] ([intPanelId], [strColumn], [strCaption], [intWidth], [strAlignment], [strArea], [strFooter], [strFormat], [intSort], [strFormatTrue], [strFormatFalse], [strDrillDownColumn], [ysnVisible], [strType], [strAxis], [strUserName], [intUserId], [intDonut], [intMinInterval], [intMaxInterval], [intStepInterval], [strIntervalFormat], [ysnHiddenColumn], [intConcurrencyId], [intCannedPanelId], [strDataType])
	--VALUES (
	--	@RiskDashboardVaRPanelId, 'dblConditionalVaR', 'Conditional VaR', 100, 'Left', '', '', '$###0.00', 11, '', '', '', 0, 'Grid', '', 'irelyadmin',1, 0, 0, 0, 0, '',0 ,2 ,0 , 'System.Decimal'
	--)
	--INSERT INTO [dbo].[tblDBPanelColumn] ([intPanelId], [strColumn], [strCaption], [intWidth], [strAlignment], [strArea], [strFooter], [strFormat], [intSort], [strFormatTrue], [strFormatFalse], [strDrillDownColumn], [ysnVisible], [strType], [strAxis], [strUserName], [intUserId], [intDonut], [intMinInterval], [intMaxInterval], [intStepInterval], [strIntervalFormat], [ysnHiddenColumn], [intConcurrencyId], [intCannedPanelId], [strDataType])
	--VALUES (
	--	@RiskDashboardVaRPanelId,dblTotalVaR,'Total Var', 100, 'Left', '', '', '$###0.00', 12, '', '', '', 0, 'Grid', '', 'irelyadmin', 1, 0, 0, 0, 0,'', 0, 2, 0, 'System.Decimal'
	--)
	--INSERT INTO [dbo].[tblDBPanelColumn] ([intPanelId], [strColumn], [strCaption], [intWidth], [strAlignment], [strArea], [strFooter], [strFormat], [intSort], [strFormatTrue], [strFormatFalse], [strDrillDownColumn], [ysnVisible], [strType], [strAxis], [strUserName], [intUserId], [intDonut], [intMinInterval], [intMaxInterval], [intStepInterval], [strIntervalFormat], [ysnHiddenColumn], [intConcurrencyId], [intCannedPanelId], [strDataType])
	--VALUES (
	--	@RiskDashboardVaRPanelId, 'dblTotalConditionalVaR', 'Total Conditional VaR', 120, 'Left', '', '', '$###0.00', 13, '', '', '', 0, 'Grid', '', 'irelyadmin', 1, 0, 0, 0, 0, '', 0, 3, 0, 'System.Decimal'
	--)
	--INSERT INTO [dbo].[tblDBPanelColumn] ([intPanelId], [strColumn], [strCaption], [intWidth], [strAlignment], [strArea], [strFooter], [strFormat], [intSort], [strFormatTrue], [strFormatFalse], [strDrillDownColumn], [ysnVisible], [strType], [strAxis], [strUserName], [intUserId], [intDonut], [intMinInterval], [intMaxInterval], [intStepInterval], [strIntervalFormat], [ysnHiddenColumn], [intConcurrencyId], [intCannedPanelId], [strDataType])
	--VALUES (
	--	@RiskDashboardVaRPanelId, 'strVaRModel', 'VaR Model', 100, 'Left', '', '', '', 14, '', '', '', 0, 'Grid', '', 'irelyadmin', 1, 0, 0, 0, 0, '', 0, 2, 0, 'System.String'
	--)
	--INSERT INTO [dbo].[tblDBPanelColumn] ([intPanelId], [strColumn], [strCaption], [intWidth], [strAlignment], [strArea], [strFooter], [strFormat], [intSort], [strFormatTrue], [strFormatFalse], [strDrillDownColumn], [ysnVisible], [strType], [strAxis], [strUserName], [intUserId], [intDonut], [intMinInterval], [intMaxInterval], [intStepInterval], [strIntervalFormat], [ysnHiddenColumn], [intConcurrencyId], [intCannedPanelId], [strDataType])
	--VALUES (
	--	@RiskDashboardVaRPanelId,'dblConfidence', 'Confidence', 100, 'Left', '', '', '', 15, '', '', '', 0, 'Grid', '', 'irelyadmin', 1, 0, 0, 0, 0, '', 0, 2, 0, 'System.Decimal'
	--)
	--INSERT INTO [dbo].[tblDBPanelColumn] ([intPanelId], [strColumn], [strCaption], [intWidth], [strAlignment], [strArea], [strFooter], [strFormat], [intSort], [strFormatTrue], [strFormatFalse], [strDrillDownColumn], [ysnVisible], [strType], [strAxis], [strUserName], [intUserId], [intDonut], [intMinInterval], [intMaxInterval], [intStepInterval], [strIntervalFormat], [ysnHiddenColumn], [intConcurrencyId], [intCannedPanelId], [strDataType])
	--VALUES (
	--	@RiskDashboardVaRPanelId, 'dtmStartDate', 'Start Date', 100, Left, '', '', 'Date', 16, '', '', '', 0, 'Grid', '', 'irelyadmin', 1, 0, 0, 0, 0, '', 0, 2, 0, 'System.DateTime'
	--)
	--INSERT INTO [dbo].[tblDBPanelColumn] ([intPanelId], [strColumn], [strCaption], [intWidth], [strAlignment], [strArea], [strFooter], [strFormat], [intSort], [strFormatTrue], [strFormatFalse], [strDrillDownColumn], [ysnVisible], [strType], [strAxis], [strUserName], [intUserId], [intDonut], [intMinInterval], [intMaxInterval], [intStepInterval], [strIntervalFormat], [ysnHiddenColumn], [intConcurrencyId], [intCannedPanelId], [strDataType])
	--VALUES (
	--	@RiskDashboardVaRPanelId, 'strBaseFX', 'Base FX', 100, 'Left', '', '', '', 17, '', '', '', 0, 'Grid', '', 'irelyadmin', 1, 0, 0, 0, 0, '', 0, 2, 0, 'System.String'
	--)





	PRINT '*End Creating Dashboard Panel Data for Risk Dashboard*'

END
PRINT '*End Populating Demo Data for Risk Dashboard*'