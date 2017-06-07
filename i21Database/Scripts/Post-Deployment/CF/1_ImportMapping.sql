GO
-----------Voyager-------------
DECLARE @vygerImportHeader INT
IF ((SELECT COUNT(*) FROM tblSMImportFileHeader WHERE strLayoutTitle = 'Voyager') =  0)
BEGIN

	INSERT [dbo].[tblSMImportFileHeader] ([strLayoutTitle], [strFileType], [strFieldDelimiter], [strXMLType], [strXMLInitiater], [ysnActive], [intConcurrencyId]) VALUES (N'Voyager', N'Delimiter', N'Space', NULL, NULL, 1, 24)
	SET @vygerImportHeader = SCOPE_IDENTITY();

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) VALUES (@vygerImportHeader, N'Transaction Date', 0, 163, NULL, 1, 6, N'YYYYMMDDHHMM')
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@vygerImportHeader, SCOPE_IDENTITY(), 1, 1, NULL, N'tblCFTransaction', N'dtmTransactionDate', NULL, 8, N'', 1, 3)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) VALUES (@vygerImportHeader, N'Site Number', 0, 183, NULL, 0, 4, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@vygerImportHeader, SCOPE_IDENTITY(), 2, 0, NULL, N'tblCFSite', N'strSiteNumber', NULL, 13, N'', 1, 3)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) VALUES (@vygerImportHeader, N'Card Number', 0, 155, NULL, 2, 4, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@vygerImportHeader, SCOPE_IDENTITY(), 3, 2, NULL, N'tblCFCard', N'strCardNumber', NULL, 5, NULL, 1, 4)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) VALUES (@vygerImportHeader, N'Vehicle Number', 0, 85, NULL, 0, 4, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@vygerImportHeader, SCOPE_IDENTITY(), 4, 0, NULL,  N'tblCFVehicle', N'strVehicleNumber', NULL, 6, NULL, 1, 3)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) VALUES (@vygerImportHeader, N'Odometer', 0, 288, NULL, 0, 4, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@vygerImportHeader, SCOPE_IDENTITY(), 5, 0, NULL, N'tblCFTransaction', N'intOdometer', NULL, 7, NULL, 1, 1)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) VALUES (@vygerImportHeader, N'Sequence Number', 0, 0, NULL, 0, 2, NULL)
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) VALUES (@vygerImportHeader, N'Pump Number', 0, 0, NULL, 0, 1, NULL)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) VALUES (@vygerImportHeader, N'Product Id', 0, 249, NULL, 0, 4, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@vygerImportHeader, SCOPE_IDENTITY(), 7, 0, NULL, N'tblCFItem', N'strProductNumber', NULL, 2, NULL, 1, 3)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) VALUES (@vygerImportHeader, N'Quantity', 0, 260, NULL, 0, 4, N'2 Implied Decimals')
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@vygerImportHeader, SCOPE_IDENTITY(), 8, 0, NULL, N'tblCFTransaction', N'dblQuantity', NULL, 7, NULL, 1, 2)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) VALUES (@vygerImportHeader, N'Transfer Cost', 0, 0, NULL, 0, 1, NULL)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) VALUES (@vygerImportHeader, N'Price', 0, 268, NULL, 0, 4, N'2 Implied Decimals')
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@vygerImportHeader, SCOPE_IDENTITY(), 9, 0, NULL,  N'tblCFTransaction', N'dblOriginalGrossPrice', NULL, 7, NULL, 1, 3)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) VALUES (@vygerImportHeader, N'ISO', 0, 0, NULL, 0, 1, NULL)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) VALUES (@vygerImportHeader, N'Site Address', 0, 196, NULL, 0, 3, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@vygerImportHeader, SCOPE_IDENTITY(), 10, 0, NULL, NULL, NULL, NULL, 25, NULL, 1, 3)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) VALUES (@vygerImportHeader, N'Site City', 0, 221, NULL, 0, 3, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@vygerImportHeader, SCOPE_IDENTITY(), 11, 0, NULL, NULL, NULL, NULL, 17, NULL, 1, 3)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) VALUES (@vygerImportHeader, N'Site State', 0, 238, NULL, 0, 2, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@vygerImportHeader, SCOPE_IDENTITY(), 12, 0, NULL, NULL, NULL, NULL, 2, NULL, 1, 4)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) VALUES (@vygerImportHeader, N'Site Zip', 0, 240, NULL, 0, 5, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@vygerImportHeader, SCOPE_IDENTITY(), 13, 0, NULL, NULL, NULL, NULL, 5, NULL, 1, 4)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) VALUES (@vygerImportHeader, N'Site Name', 0, 1009, NULL, 0, 4, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@vygerImportHeader, SCOPE_IDENTITY(), 16, 0, NULL, NULL, NULL, NULL, 25, NULL, 1, 1)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) VALUES (@vygerImportHeader, N'Transaction Time', 0, 171, NULL, 1, 4, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@vygerImportHeader, SCOPE_IDENTITY(), 14, 2, NULL, NULL, NULL, NULL, 4, NULL, 1, 4)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) VALUES (@vygerImportHeader, N'Account', 0, 1, NULL, 2, 2, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@vygerImportHeader, SCOPE_IDENTITY(), 15, 1, NULL, NULL, NULL, NULL, 9, NULL, 1, 2)
	
END
	-----------Voyager-------------


-----------Pac Pride-------------
DECLARE @pacpridePK INT
IF ((SELECT COUNT(*) FROM tblSMImportFileHeader WHERE strLayoutTitle = 'Pac Pride') =  0)
BEGIN

	INSERT [dbo].[tblSMImportFileHeader] ([strLayoutTitle], [strFileType], [strFieldDelimiter], [strXMLType], [strXMLInitiater], [ysnActive], [intConcurrencyId]) VALUES (N'Pac Pride', N'Delimiter', N'Comma', NULL, N'', 1, 1)
	SET @pacpridePK = SCOPE_IDENTITY();

	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@pacpridePK, N'Transaction Date', 0, 10, NULL, 1, 5, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@pacpridePK, SCOPE_IDENTITY(), 29, 1, NULL, N'tblCFTransaction', N'dtmTransactionDate', NULL, 0, N'', 1, 4)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@pacpridePK, N'Transaction Time', 0, 11, NULL, 1, 1, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@pacpridePK, SCOPE_IDENTITY(), 63, 2, NULL, NULL, NULL, NULL, NULL, NULL, 1, 2)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@pacpridePK, N'Site Number', 0, 2, NULL, 0, 3, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@pacpridePK, SCOPE_IDENTITY(), 30, 0, NULL, N'tblCFSite', N'strSiteNumber', NULL, 0, N'', 1, 3)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@pacpridePK, N'Card Number', 0, 14, NULL, 0, 3, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@pacpridePK, SCOPE_IDENTITY(), 31, 0, NULL, N'tblCFCard', N'strCardNumber', NULL, 0, N'', 1, 3)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@pacpridePK, N'Vehicle Number', 0, 15, NULL, 0, 3, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@pacpridePK, SCOPE_IDENTITY(), 32, 0, NULL, N'tblCFVehicle', N'strVehicleNumber', NULL, 0, N'', 1, 3)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@pacpridePK, N'Odometer', 0, 19, NULL, 0, 3, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@pacpridePK, SCOPE_IDENTITY(), 33, 0, NULL, N'tblCFTransaction', N'intOdometer', NULL, 0, N'', 1, 3)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@pacpridePK, N'Sequence Number', 0, 21, NULL, 0, 3, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@pacpridePK, SCOPE_IDENTITY(), 34, 0, NULL, N'tblCFTransaction', N'strSequenceNumber', NULL, 0, N'', 1, 3)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@pacpridePK, N'Pump Number', 0, 22, NULL, 0, 3, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@pacpridePK, SCOPE_IDENTITY(), 35, 0, NULL, N'tblCFTransaction', N'intPumpNumber', NULL, 0, N'', 1, 3)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@pacpridePK, N'Product Id', 0, 24, NULL, 0, 3, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@pacpridePK, SCOPE_IDENTITY(), 36, 0, NULL, N'tblCFItem', N'strProductNumber', NULL, 0, N'', 1, 3)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@pacpridePK, N'Quantity', 0, 25, NULL, 0, 3, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@pacpridePK, SCOPE_IDENTITY(), 37, 0, NULL, N'tblCFTransaction', N'dblQuantity', NULL, 0, N'', 1, 3)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@pacpridePK, N'Transfer Cost', 0, 28, NULL, 0, 3, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES ( @pacpridePK, SCOPE_IDENTITY(), 38, 0, NULL, N'tblCFTransaction', N'dblTransferCost', NULL, 0, N'', 1, 3)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@pacpridePK, N'Price', 0, 27, NULL, 0, 2, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@pacpridePK, SCOPE_IDENTITY(), 39, NULL, NULL, N'tblCFTransactionPrice', N'dblOriginalGrossPrice', NULL, NULL, NULL, 1, 6)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@pacpridePK, N'TaxState', 0, 38, NULL, 0, 4, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@pacpridePK, SCOPE_IDENTITY(), 40, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 3)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@pacpridePK, N'Federal Excise Tax Rate', 0, 49, NULL, 0, 5, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@pacpridePK, SCOPE_IDENTITY(), 41, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 3)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@pacpridePK, N'State Excise Tax Rate 1', 0, 50, NULL, 0, 4, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@pacpridePK, SCOPE_IDENTITY(), 42, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 3)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@pacpridePK, N'State Excise Tax Rate 2', 0, 51, NULL, 0, 5, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@pacpridePK, SCOPE_IDENTITY(), 43, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 3)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@pacpridePK, N'County Excise Tax Rate', 0, 52, NULL, 0, 5, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@pacpridePK, SCOPE_IDENTITY(), 44, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 3)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@pacpridePK, N'City Excise Tax Rate', 0, 53, NULL, 0, 5, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@pacpridePK, SCOPE_IDENTITY(), 45, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 3)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@pacpridePK, N'State Sales Tax Percentage Rate', 0, 54, NULL, 0, 5, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@pacpridePK, SCOPE_IDENTITY(), 46, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 3)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@pacpridePK, N'County Sales TaxPercentage Rate', 0, 55, NULL, 0, 5, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@pacpridePK, SCOPE_IDENTITY(), 47, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 3)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@pacpridePK, N'City Sales Tax Percentage Rate', 0, 56, NULL, 0, 6, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@pacpridePK, SCOPE_IDENTITY(), 48, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 3)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@pacpridePK, N'Other Sales Tax Percentage Rate', 0, 57, NULL, 0, 6, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@pacpridePK, SCOPE_IDENTITY(), 55, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 3)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@pacpridePK, N'strSiteState', 0, 6, NULL, 0, 2, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@pacpridePK, SCOPE_IDENTITY(), 56, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 2)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@pacpridePK, N'strSiteAddress', 0, 4, NULL, 0, 2, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@pacpridePK, SCOPE_IDENTITY(), 57, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 3)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@pacpridePK, N'strSiteCity', 0, 5, NULL, 0, 2, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@pacpridePK, SCOPE_IDENTITY(), 58, NULL, NULL, NULL, NULL, NULL, 0, NULL, 1, 3)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@pacpridePK, N'intPPHostId', 0, 23, NULL, 0, 2, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@pacpridePK, SCOPE_IDENTITY(), 59, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 3)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@pacpridePK, N'strPPSiteType', 0, 3, NULL, 0, 3, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@pacpridePK, SCOPE_IDENTITY(), 60, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 3)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@pacpridePK, N'SellingHost', 0, 1, NULL, 0, 3, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@pacpridePK, SCOPE_IDENTITY(), 61, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 3)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@pacpridePK, N'BuyingHost', 0, 16, NULL, 0, 3, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@pacpridePK, SCOPE_IDENTITY(), 62, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 3)

END
	-----------Pac Pride-------------


-----------Petrovend-------------
DECLARE @petrovendPK INT
IF ((SELECT COUNT(*) FROM tblSMImportFileHeader WHERE strLayoutTitle = 'Petrovend') =  0)
BEGIN

	INSERT [dbo].[tblSMImportFileHeader] ([strLayoutTitle], [strFileType], [strFieldDelimiter], [strXMLType], [strXMLInitiater], [ysnActive], [intConcurrencyId]) 
	VALUES (N'Petrovend', N'Delimiter', N'Space', NULL, NULL, 1, 6)

	SET @petrovendPK = SCOPE_IDENTITY()

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@petrovendPK, N'Transaction Date', 0, 84, NULL, NULL, 1, N'YYMMDD')
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId],[intImportFileRecordMarkerId],[intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@petrovendPK, SCOPE_IDENTITY(), 1, NULL, NULL, N'tblCFTransaction', N'dtmTransactionDate', NULL, 6, NULL, 1, 4)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@petrovendPK, N'Site Number', 0, 99, NULL, NULL, 2, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@petrovendPK, SCOPE_IDENTITY(), 2, NULL, NULL, N'tblCFSite', N'strSiteNumber', NULL, 5, NULL, 1, 4)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@petrovendPK, N'Card Number', 0, 37, NULL, NULL, 2, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@petrovendPK, SCOPE_IDENTITY(), 3, NULL, NULL, N'tblCFCard', N'strCardNumber', NULL, 5, NULL, 1, 5)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@petrovendPK, N'Vehicle Number', 0, 126, NULL, NULL, 2, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@petrovendPK, SCOPE_IDENTITY(), 4, NULL, NULL, N'tblCFVehicle', N'strVehicleNumber', NULL, 4, NULL, 1, 4)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@petrovendPK, N'Odometer', 0, 21, NULL, NULL, 2, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@petrovendPK, SCOPE_IDENTITY(), 5, NULL, NULL, N'tblCFTransaction', N'intOdometer', NULL, 7, NULL, 1, 4)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@petrovendPK, N'Sequence Number', 0, NULL, NULL, NULL, 1, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@petrovendPK, SCOPE_IDENTITY(), 6, NULL, NULL, N'tblCFTransaction', N'strSequenceNumber', NULL, NULL, NULL, 1, 4)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@petrovendPK, N'Pump Number', 0, 78, NULL, NULL, 2, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@petrovendPK, SCOPE_IDENTITY(), 7, NULL, NULL, N'tblCFTransaction', N'intPumpNumber', NULL, 2, NULL, 1, 4)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@petrovendPK, N'Product Id', 0, 76, NULL, NULL, 2, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@petrovendPK, SCOPE_IDENTITY(), 8, NULL, NULL, N'tblCFItem', N'strProductNumber', NULL, 2, NULL, 1, 4)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@petrovendPK, N'Quantity', 0, 10, NULL, NULL, 2, N'3 Implied Decimals')
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@petrovendPK, SCOPE_IDENTITY(), 9, NULL, NULL, N'tblCFTransaction', N'dblQuantity', NULL, 6, NULL, 1, 4)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@petrovendPK, N'Transfer Cost', 0, NULL, NULL, NULL, 1, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@petrovendPK, SCOPE_IDENTITY(), 10, NULL, NULL, N'tblCFTransaction', N'dblTransferCost', NULL, NULL, NULL, 1, 4)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@petrovendPK, N'Price', 0, 6, NULL, NULL, 3, N'3 Implied Decimals')
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@petrovendPK, SCOPE_IDENTITY(), 11, NULL, NULL, N'tblCFTransaction', N'dblOriginalGrossPrice', NULL, 4, NULL, 1, 4)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@petrovendPK, N'ISO', 0, 32, NULL, NULL, 2, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@petrovendPK, SCOPE_IDENTITY(), 12, NULL, NULL, N'tblCFCreditCard', N'strPrefix', NULL, 4, NULL, 1, 2)

END
-----------Petrovend-------------

-----------NBS-------------
DECLARE @nbsPK INT
IF ((SELECT COUNT(*) FROM tblSMImportFileHeader WHERE strLayoutTitle = 'NBS') =  0)
BEGIN

	INSERT [dbo].[tblSMImportFileHeader] ([strLayoutTitle], [strFileType], [strFieldDelimiter], [strXMLType], [strXMLInitiater], [ysnActive], [intConcurrencyId]) 
	VALUES (N'NBS', N'Delimiter', N'Space', NULL, NULL, 1, 6)

	SET @nbsPK = SCOPE_IDENTITY()

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@nbsPK, N'Transaction Date', 0, 16, NULL, 0, 2, N'YYMMDDHHMM')
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@nbsPK, SCOPE_IDENTITY(), 1, 0, NULL, N'tblCFTransaction', N'dtmTransactionDate', NULL, 10, N'', 1, 2)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@nbsPK, N'Site Number', 0, 7, NULL, 0, 2, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@nbsPK, SCOPE_IDENTITY(), 2, 0, NULL, N'tblCFSite', N'strSiteNumber', NULL, 6, N'', 1, 1)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@nbsPK, N'Card Number', 0, 49, NULL, 0, 2, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@nbsPK, SCOPE_IDENTITY(), 3, 0, NULL, N'tblCFCard', N'strCardNumber', NULL, 6, NULL, 1, 1)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@nbsPK, N'Vehicle Number', 0, 77, NULL, 0, 2, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@nbsPK, SCOPE_IDENTITY(), 4, 0, NULL, N'tblCFVehicle', N'strVehicleNumber', NULL, 6, NULL, 1, 1)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@nbsPK, N'Odometer', 0, 83, NULL, 0, 2, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@nbsPK, SCOPE_IDENTITY(), 5, 0, NULL, N'tblCFTransaction', N'intOdometer', NULL, 7, NULL, 1, 1)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@nbsPK, N'Sequence Number', 0, 14, NULL, 0, 2, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@nbsPK, SCOPE_IDENTITY(), 6, 0, NULL, N'tblCFTransaction', N'strSequenceNumber', NULL, 2, NULL, 1, 1)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@nbsPK, N'Pump Number', 0, 0, NULL, 0, 1, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@nbsPK, SCOPE_IDENTITY(), 10, 0, NULL, N'tblCFTransaction', N'intPumpNumber', NULL, 0, NULL, 1, 1)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@nbsPK, N'Transfer Cost', 0, 0, NULL, 0, 1, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@nbsPK, SCOPE_IDENTITY(), 11, 0, NULL, N'tblCFTransaction', N'dblTransferCost', NULL, 0, NULL, 1, 1)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@nbsPK, N'ISO', 0, 0, NULL, 0, 1, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@nbsPK, SCOPE_IDENTITY(), 12, 0, NULL, N'tblCFCreditCard', N'strPrefix', NULL, 0, NULL, 0, 1)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@nbsPK, N'Product Id', 0, 92, NULL, 0, 2, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@nbsPK, SCOPE_IDENTITY(), 7, 0, NULL, N'tblCFItem', N'strProductNumber', NULL, 3, NULL, 1, 1)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) 
	VALUES (@nbsPK, N'Quantity', 0, 95, NULL, 0, 2, N'5 Implied Decimals', 3)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@nbsPK, SCOPE_IDENTITY(), 8, 0, NULL, N'tblCFTransaction', N'dblQuantity', NULL, 8, NULL, 1, 1)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@nbsPK, N'Price', 0, 103, NULL, 0, 2, N'2 Implied Decimals')
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@nbsPK, SCOPE_IDENTITY(), 9, 0, NULL, N'tblCFTransaction', N'dblOriginalGrossPrice', NULL, 7, NULL, 1, 1)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@nbsPK, N'Product Id', 0, 164, NULL, 0, 2, NULL)
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat],[intRounding]) 
	VALUES (@nbsPK, N'Quantity', 0, 1877, NULL, 0, 2, N'5 Implied Decimals', 3)
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@nbsPK, N'Price', 0, 1885, NULL, 0, 2, N'2 Implied Decimals')

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@nbsPK, N'Transaction Type', 0, 36, NULL, 0, 2, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@nbsPK, SCOPE_IDENTITY(), 13, 0, NULL, NULL, NULL, NULL, 1, NULL, 0, 1)

END

-----------NBS-------------