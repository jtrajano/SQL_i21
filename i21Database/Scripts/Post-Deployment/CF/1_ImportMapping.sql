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

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) VALUES (@vygerImportHeader, N'Quantity', 0, 259, NULL, 0, 4, N'2 Implied Decimals')
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@vygerImportHeader, SCOPE_IDENTITY(), 8, 0, NULL, N'tblCFTransaction', N'dblQuantity', NULL, 8, NULL, 1, 2)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) VALUES (@vygerImportHeader, N'Transfer Cost', 0, 0, NULL, 0, 1, NULL)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) VALUES (@vygerImportHeader, N'Total', 0, 252, NULL, 0, 4, N'2 Implied Decimals')
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
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) VALUES (@vygerImportHeader, N'Amount Indicator', 0, 251, NULL, 0, 2, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@vygerImportHeader, SCOPE_IDENTITY(), 17, 0, NULL, NULL, NULL, NULL, 1, NULL, 1, 2)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) VALUES (@vygerImportHeader, N'strTaxState', 0, 238, NULL, 0, 2, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@vygerImportHeader, SCOPE_IDENTITY(), 18, 0, NULL, NULL, NULL, NULL, 2, NULL, 1, 2)
	
END
-----------Voyager-------------


--Petrovend CSV--

DECLARE @petrovendCSVImportHeader INT
IF ((SELECT COUNT(*) FROM tblSMImportFileHeader WHERE strLayoutTitle = 'Petrovend CSV') =  0)
BEGIN

INSERT [dbo].[tblSMImportFileHeader] ([strLayoutTitle], [strFileType], [strFieldDelimiter], [strXMLType], [strXMLInitiater], [ysnActive], [intConcurrencyId]) VALUES (N'Petrovend CSV', N'Delimiter', N'Comma', NULL, NULL, 0, 3)
SET @petrovendCSVImportHeader = SCOPE_IDENTITY();

INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@petrovendCSVImportHeader, N'VehicleNumber', NULL, 0, NULL, NULL, 1, NULL, NULL)
INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@petrovendCSVImportHeader, SCOPE_IDENTITY(), 1, NULL, NULL, N'tblCFVehicle', N'strVehicleNumber', NULL, NULL, NULL, 0, 1)

INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@petrovendCSVImportHeader, N'CardNumber', 10, 0, NULL, NULL, 2, NULL, NULL)
INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@petrovendCSVImportHeader, SCOPE_IDENTITY(), 2, NULL, NULL, N'tblCFCard', N'strCardNumber', NULL, 7, NULL, 0, 2)

INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@petrovendCSVImportHeader, N'TransactionDate', NULL, 2, NULL, 1, 3, N'YYYYMMDDHH:MM', NULL)
INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@petrovendCSVImportHeader, SCOPE_IDENTITY(), 3, 1, NULL, N'tblCFTransaction', N'dtmTransactionDate', NULL, NULL, NULL, 0, 1)

INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@petrovendCSVImportHeader, N'TransactionTime', NULL, 3, NULL, 1, 3, N'YYYYMMDDHH:MM', NULL)
INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@petrovendCSVImportHeader, SCOPE_IDENTITY(), 4, 2, NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)

INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@petrovendCSVImportHeader, N'Pump', NULL, 5, NULL, NULL, 1, NULL, NULL)
INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@petrovendCSVImportHeader, SCOPE_IDENTITY(), 5, NULL, NULL, N'tblCFTransaction', N'dblOriginalPumpPrice', NULL, NULL, NULL, 0, 1)

INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@petrovendCSVImportHeader, N'SiteNumber', NULL, 6, NULL, NULL, 1, NULL, NULL)
INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@petrovendCSVImportHeader, SCOPE_IDENTITY(), 6, NULL, NULL, N'tblCFSite', N'strSiteNumber', NULL, NULL, NULL, 0, 1)

INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@petrovendCSVImportHeader, N'ProductNumber', NULL, 8, NULL, NULL, 1, NULL, NULL)
INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@petrovendCSVImportHeader, SCOPE_IDENTITY(), 7, NULL, NULL, N'tblCFItem', N'strProductNumber', NULL, NULL, NULL, 0, 1)

INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@petrovendCSVImportHeader, N'Quantity', 0, 9, NULL, NULL, 1, NULL, NULL)
INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@petrovendCSVImportHeader, SCOPE_IDENTITY(), 8, NULL, NULL, N'tblCFTransaction', N'dblQuantity', NULL, NULL, NULL, 0, 1)

INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@petrovendCSVImportHeader, N'Price', NULL, 10, NULL, NULL, 1, NULL, NULL)
INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@petrovendCSVImportHeader, SCOPE_IDENTITY(), 9, NULL, NULL, N'tblCFTransaction', N'dblOriginalGrossPrice', NULL, NULL, NULL, 0, 1)

INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@petrovendCSVImportHeader, N'Odometer', 0, 11, NULL, NULL, 2, NULL, NULL)
INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@petrovendCSVImportHeader, SCOPE_IDENTITY(), 10, NULL, NULL, N'tblCFTransaction', N'intOdometer', NULL, NULL, NULL, 0, 1)

INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@petrovendCSVImportHeader, N'CardNumberForDualCard', 10, 1, NULL, NULL, 2, NULL, NULL)
INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@petrovendCSVImportHeader, SCOPE_IDENTITY(), 11, NULL, NULL, NULL, NULL, NULL, 7, NULL, 0, 2)

END

--Petrovend CSV--



------------WEX14-----------
DECLARE @WEX14ImportHeader INT
IF ((SELECT COUNT(*) FROM tblSMImportFileHeader WHERE strLayoutTitle = 'WEX-14') =  0)
BEGIN

	INSERT [dbo].[tblSMImportFileHeader] ([strLayoutTitle], [strFileType], [strFieldDelimiter], [strXMLType], [strXMLInitiater], [ysnActive], [intConcurrencyId]) VALUES (N'WEX-14', N'Delimiter', N'Space', NULL, NULL, 1, 1)
	SET @WEX14ImportHeader = SCOPE_IDENTITY();


	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@WEX14ImportHeader, N'Tax Code', 0, 265, NULL, NULL, 1, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@WEX14ImportHeader, SCOPE_IDENTITY(), 1, NULL, NULL, NULL, NULL, NULL, 4, NULL, 0, 1)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@WEX14ImportHeader, N'Tax Rate', NULL, 278, NULL, NULL, 1, N'5 Implied Decimals', NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@WEX14ImportHeader, SCOPE_IDENTITY(), 2, NULL, NULL, NULL, NULL, NULL, 7, NULL, 0, 1)

END
------------WEX14-----------


------------WEX12-----------
DECLARE @WEX12ImportHeader INT
IF ((SELECT COUNT(*) FROM tblSMImportFileHeader WHERE strLayoutTitle = 'WEX-12') =  0)
BEGIN

	INSERT [dbo].[tblSMImportFileHeader] ([strLayoutTitle], [strFileType], [strFieldDelimiter], [strXMLType], [strXMLInitiater], [ysnActive], [intConcurrencyId]) VALUES (N'WEX-12', N'Delimiter', N'Space', NULL, NULL, 1, 24)
	SET @WEX12ImportHeader = SCOPE_IDENTITY();


	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@WEX12ImportHeader, N'Card Number', 0, 52, NULL, NULL, 3, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@WEX12ImportHeader, SCOPE_IDENTITY(), 1, NULL, NULL, N'tblCFCard', N'strCardNumber', NULL, 9, NULL, 0, 2)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@WEX12ImportHeader, N'Transaction Date', 0, 91, NULL, NULL, 3, N'YYYYMMDDHHMMSS', NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@WEX12ImportHeader, SCOPE_IDENTITY(), 2, NULL, NULL, N'tblCFTransaction', N'dtmTransactionDate', NULL, 14, NULL, 0, 2)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@WEX12ImportHeader, N'Vehicle Number', 0, 432, NULL, NULL, 4, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@WEX12ImportHeader, SCOPE_IDENTITY(), 3, NULL, NULL, N'tblCFVehicle', N'strVehicleNumber', NULL, 6, NULL, 0, 3)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@WEX12ImportHeader, N'Pump Number', 0, 392, NULL, NULL, 3, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@WEX12ImportHeader, SCOPE_IDENTITY(), 4, NULL, NULL, N'tblCFTransaction', N'strVehicleNumber', NULL, 12, NULL, 0, 2)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@WEX12ImportHeader, N'Sequence Number', 0, 454, NULL, NULL, 3, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@WEX12ImportHeader, SCOPE_IDENTITY(), 5, NULL, NULL, N'tblCFTransaction', N'strSequenceNumber', NULL, 4, NULL, 0, 2)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@WEX12ImportHeader, N'Site Number', 0, 565, NULL, NULL, 3, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@WEX12ImportHeader, SCOPE_IDENTITY(), 6, NULL, NULL, N'tblCFSite', N'strSiteNumber', NULL, 8, NULL, 0, 2)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@WEX12ImportHeader, N'Odometer', 0, 578, NULL, NULL, 3, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@WEX12ImportHeader, SCOPE_IDENTITY(), 7, NULL, NULL, N'tblCFTransaction', N'intOdometer', NULL, 6, NULL, 0, 2)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@WEX12ImportHeader, N'Product Id', 0, 604, NULL, NULL, 4, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@WEX12ImportHeader, SCOPE_IDENTITY(), 8, NULL, NULL, N'tblCFItem', N'strProductNumber', NULL, 3, NULL, 0, 4)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@WEX12ImportHeader, N'Quantity', 0, 672, NULL, NULL, 4, N'3 Implied Decimals', NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@WEX12ImportHeader, SCOPE_IDENTITY(), 9, NULL, NULL, N'tblCFTransaction', N'dblQuantity', NULL, 9, NULL, 0, 3)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@WEX12ImportHeader, N'Total Amount', 0, 682, NULL, NULL, 5, N'3 Implied Decimals', NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@WEX12ImportHeader, SCOPE_IDENTITY(), 10, NULL, NULL, N'tblCFTransaction', N'dblOriginalTotalPrice', NULL, 9, NULL, 0, 5)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@WEX12ImportHeader, N'Transaction Type', 0, 573, NULL, NULL, 1, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@WEX12ImportHeader, SCOPE_IDENTITY(), 11, NULL, NULL, N'tblCFTransaction', N'strTransactionType', NULL, 1, NULL, 0, 1)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@WEX12ImportHeader, N'Billing Date', 0, 105, NULL, NULL, 1, N'YYYYMMDD', NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@WEX12ImportHeader, SCOPE_IDENTITY(), 12, NULL, NULL, N'tblCFTransaction', N'dtmBillingDate', NULL, 8, NULL, 0, 1)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@WEX12ImportHeader, N'Site Name', 0, 470, NULL, NULL, 1, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@WEX12ImportHeader, SCOPE_IDENTITY(), 13, NULL, NULL, N'tblCFSite', N'strSiteName', NULL, 20, NULL, 0, 1)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@WEX12ImportHeader, N'Site Address', 0, 490, NULL, NULL, 1, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@WEX12ImportHeader, SCOPE_IDENTITY(), 14, NULL, NULL, N'tblCFSite', N'strSiteAddress', NULL, 20, NULL, 0, 1)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@WEX12ImportHeader, N'Site City', 0, 510, NULL, NULL, 1, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@WEX12ImportHeader, SCOPE_IDENTITY(), 15, NULL, NULL, N'tblCFSite', N'strSiteCity', NULL, 18, NULL, 0, 1)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@WEX12ImportHeader, N'strSiteState', 0, 528, NULL, 0, 3, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@WEX12ImportHeader, SCOPE_IDENTITY(), 18, NULL, NULL, N'tblCFTransaction', N'strMiscellaneous', NULL, 12, NULL, 0, 1)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@WEX12ImportHeader, N'Miscellaneous', 0, 816, NULL, NULL, 1, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@WEX12ImportHeader, SCOPE_IDENTITY(), 19, NULL, NULL, NULL, NULL, NULL, 2, NULL, 0, 1)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@WEX12ImportHeader, N'strTaxState', 0, 528, NULL, NULL, 1, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@WEX12ImportHeader, SCOPE_IDENTITY(), 20, NULL, NULL, NULL, NULL, NULL, 2, NULL, 0, 1)
	
END
------------WEX12-----------

---------CFNCSU---------



-----------CFN CSU------------
DECLARE @CFNCSU INT
IF ((SELECT COUNT(*) FROM tblSMImportFileHeader WHERE strLayoutTitle = 'CFN CSU') =  0)
BEGIN


	INSERT [dbo].[tblSMImportFileHeader] ([strLayoutTitle], [strFileType], [strFieldDelimiter], [strXMLType], [strXMLInitiater], [ysnActive], [intConcurrencyId]) VALUES (N'CFN CSU', N'Fixed', NULL, NULL, NULL, 1, 4)
	SET @CFNCSU = SCOPE_IDENTITY();

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@CFNCSU, N'Card Number', 0, 0, NULL, NULL, 1, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@CFNCSU, SCOPE_IDENTITY(), 1, NULL, NULL, NULL, N'', NULL, 7, NULL, 1, 2)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@CFNCSU, N'Participant Number', 0, 7, NULL, NULL, 2, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@CFNCSU, SCOPE_IDENTITY(), 2, NULL, NULL, NULL, NULL, NULL, 3, NULL, 1, 2)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@CFNCSU, N'Account Number', 0, 10, NULL, NULL, 2, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@CFNCSU, SCOPE_IDENTITY(), 3, NULL, NULL, NULL, NULL, NULL, 6, NULL, 1, 2)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@CFNCSU, N'Vehicle Number', 0, 16, NULL, NULL, 2, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@CFNCSU, SCOPE_IDENTITY(), 4, NULL, NULL, NULL, NULL, NULL, 4, NULL, 1, 2)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@CFNCSU, N'Expiration Date', 0, 20, NULL, NULL, 2, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@CFNCSU, SCOPE_IDENTITY(), 5, NULL, NULL, NULL, NULL, NULL, 4, NULL, 1, 2)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@CFNCSU, N'Manual Entry Code', 0, 24, NULL, NULL, 2, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@CFNCSU, SCOPE_IDENTITY(), 6, NULL, NULL, NULL, NULL, NULL, 1, NULL, 1, 2)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@CFNCSU, N'Limit Code', 0, 25, NULL, NULL, 2, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@CFNCSU, SCOPE_IDENTITY(), 7, NULL, NULL, NULL, NULL, NULL, 1, NULL, 1, 2)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@CFNCSU, N'Product Auth Code', 0, 26, NULL, NULL, 2, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@CFNCSU, SCOPE_IDENTITY(), 8, NULL, NULL, NULL, NULL, NULL, 2, NULL, 1, 2)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@CFNCSU, N'Card Status', 0, 28, NULL, NULL, 2, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@CFNCSU, SCOPE_IDENTITY(), 9, NULL, NULL, NULL, NULL, NULL, 1, NULL, 1, 2)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@CFNCSU, N'PIN Number', 0, 114, NULL, NULL, 2, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@CFNCSU, SCOPE_IDENTITY(), 10, NULL, NULL, NULL, NULL, NULL, 5, NULL, 1, 3)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@CFNCSU, N'Description', 0, 79, NULL, NULL, 2, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@CFNCSU, SCOPE_IDENTITY(), 11, NULL, NULL, NULL, NULL, NULL, 20, NULL, 1, 2)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@CFNCSU, N'Card Type', 0, 113, NULL, NULL, 3, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@CFNCSU, SCOPE_IDENTITY(), 12, NULL, NULL, NULL, NULL, NULL, 6, NULL, 1, 3)

END
---------CFNCSU---------



-----------CFN CSU CSV------------
DECLARE @CFNCSVCSU INT
IF ((SELECT COUNT(*) FROM tblSMImportFileHeader WHERE strLayoutTitle = 'CFN CSV CSU') =  0)
BEGIN

	INSERT [dbo].[tblSMImportFileHeader] ([strLayoutTitle], [strFileType], [strFieldDelimiter], [strXMLType], [strXMLInitiater], [ysnActive], [intConcurrencyId]) VALUES (N'CFN CSV CSU', N'Delimiter', N'Comma', NULL, NULL, 1, 1)
	SET @CFNCSVCSU = SCOPE_IDENTITY();

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@CFNCSVCSU, N'Card Number', 0, 0, NULL, NULL, 2, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@CFNCSVCSU, SCOPE_IDENTITY(), 1, NULL, NULL, NULL, N'', NULL, 0, NULL, 1, 1)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@CFNCSVCSU, N'Participant Number', 0, 1, NULL, NULL, 2, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@CFNCSVCSU, SCOPE_IDENTITY(), 2, NULL, NULL, NULL, NULL, NULL, 0, NULL, 1, 1)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@CFNCSVCSU, N'Account Number', 0, 2, NULL, NULL, 3, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@CFNCSVCSU, SCOPE_IDENTITY(), 3, NULL, NULL, NULL, NULL, NULL, 0, NULL, 1, 2)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@CFNCSVCSU, N'Vehicle Number', 0, 3, NULL, NULL, 2, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@CFNCSVCSU, SCOPE_IDENTITY(), 4, NULL, NULL, NULL, NULL, NULL, 0, NULL, 1, 1)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@CFNCSVCSU, N'Expiration Date', 0, 4, NULL, NULL, 3, N'YYMM', NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@CFNCSVCSU, SCOPE_IDENTITY(), 5, NULL, NULL, NULL, NULL, NULL, 0, NULL, 1, 1)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@CFNCSVCSU, N'Manual Entry Code', 0, 5, NULL, NULL, 2, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@CFNCSVCSU, SCOPE_IDENTITY(), 6, NULL, NULL, NULL, NULL, NULL, 0, NULL, 1, 1)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@CFNCSVCSU, N'Limit Code', 0, 6, NULL, NULL, 2, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@CFNCSVCSU, SCOPE_IDENTITY(), 7, NULL, NULL, NULL, NULL, NULL, 0, NULL, 1, 1)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@CFNCSVCSU, N'Product Auth Code', 0, 7, NULL, NULL, 2, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@CFNCSVCSU, SCOPE_IDENTITY(), 8, NULL, NULL, NULL, NULL, NULL, 0, NULL, 1, 1)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@CFNCSVCSU, N'Card Status', 0, 8, NULL, NULL, 2, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@CFNCSVCSU, SCOPE_IDENTITY(), 9, NULL, NULL, NULL, NULL, NULL, 0, NULL, 1, 1)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@CFNCSVCSU, N'PIN Number', 0, 22, NULL, NULL, 2, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@CFNCSVCSU, SCOPE_IDENTITY(), 10, NULL, NULL, NULL, NULL, NULL, 0, NULL, 1, 1)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@CFNCSVCSU, N'Description', 0, 17, NULL, NULL, 3, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@CFNCSVCSU, SCOPE_IDENTITY(), 11, NULL, NULL, NULL, NULL, NULL, 0, NULL, 1, 1)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@CFNCSVCSU, N'Card Type', 0, 20, NULL, NULL, 4, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@CFNCSVCSU, SCOPE_IDENTITY(), 12, NULL, NULL, NULL, NULL, NULL, 0, NULL, 1, 2)
	
END
-----------CFN CSU CSV------------



-----------Pac Pride CSU------------
DECLARE @PacPrideCSU INT
IF ((SELECT COUNT(*) FROM tblSMImportFileHeader WHERE strLayoutTitle = 'PacPride CSU') =  0)
BEGIN

	INSERT [dbo].[tblSMImportFileHeader] ([strLayoutTitle], [strFileType], [strFieldDelimiter], [strXMLType], [strXMLInitiater], [ysnActive], [intConcurrencyId]) VALUES (N'PacPride CSU', N'Delimiter', N'Comma', NULL, NULL, 1, 1)
	SET @PacPrideCSU = SCOPE_IDENTITY();

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@PacPrideCSU, N'Card Number', 0, 0, NULL, NULL, 2, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@PacPrideCSU, SCOPE_IDENTITY(), 1, NULL, NULL, NULL, N'', NULL, 0, NULL, 1, 1)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@PacPrideCSU, N'Participant Number', 0, 1, NULL, NULL, 2, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@PacPrideCSU, SCOPE_IDENTITY(), 2, NULL, NULL, NULL, NULL, NULL, 0, NULL, 1, 1)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@PacPrideCSU, N'Account Number', 0, 2, NULL, NULL, 3, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@PacPrideCSU, SCOPE_IDENTITY(), 3, NULL, NULL, NULL, NULL, NULL, 0, NULL, 1, 2)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@PacPrideCSU, N'Vehicle Number', 0, 3, NULL, NULL, 2, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@PacPrideCSU, SCOPE_IDENTITY(), 4, NULL, NULL, NULL, NULL, NULL, 0, NULL, 1, 1)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@PacPrideCSU, N'Expiration Date', 0, 4, NULL, NULL, 3, N'YYMM', NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@PacPrideCSU, SCOPE_IDENTITY(), 5, NULL, NULL, NULL, NULL, NULL, 0, NULL, 1, 1)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@PacPrideCSU, N'Manual Entry Code', 0, 5, NULL, NULL, 2, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@PacPrideCSU, SCOPE_IDENTITY(), 6, NULL, NULL, NULL, NULL, NULL, 0, NULL, 1, 1)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@PacPrideCSU, N'Limit Code', 0, 6, NULL, NULL, 2, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@PacPrideCSU, SCOPE_IDENTITY(), 7, NULL, NULL, NULL, NULL, NULL, 0, NULL, 1, 1)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@PacPrideCSU, N'Product Auth Code', 0, 7, NULL, NULL, 2, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@PacPrideCSU, SCOPE_IDENTITY(), 8, NULL, NULL, NULL, NULL, NULL, 0, NULL, 1, 1)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@PacPrideCSU, N'Card Status', 0, 8, NULL, NULL, 2, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@PacPrideCSU, SCOPE_IDENTITY(), 9, NULL, NULL, NULL, NULL, NULL, 0, NULL, 1, 1)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@PacPrideCSU, N'PIN Number', 0, 22, NULL, NULL, 2, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@PacPrideCSU, SCOPE_IDENTITY(), 10, NULL, NULL, NULL, NULL, NULL, 0, NULL, 1, 1)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@PacPrideCSU, N'Description', 0, 17, NULL, NULL, 3, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@PacPrideCSU, SCOPE_IDENTITY(), 11, NULL, NULL, NULL, NULL, NULL, 0, NULL, 1, 1)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@PacPrideCSU, N'Card Type', 0, 20, NULL, NULL, 4, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@PacPrideCSU, SCOPE_IDENTITY(), 12, NULL, NULL, NULL, NULL, NULL, 0, NULL, 1, 2)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@PacPrideCSU, N'ChangedDate', 0, 11, NULL, 1, 2, N'YYMMDDHHMMSS', NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@PacPrideCSU, SCOPE_IDENTITY(), 13, 1, NULL, NULL, NULL, NULL, 0, NULL, 1, 1)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@PacPrideCSU, N'ChangeTime', 0, 12, NULL, 1, 2, N'YYMMDDHHMMSS', NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@PacPrideCSU, SCOPE_IDENTITY(), 14, 2, NULL, NULL, NULL, NULL, 0, NULL, 1, 1)

END
-----------Pac Pride CSU------------



-----------Pac Pride-------------
	DECLARE @pacpridePK INT
IF ((SELECT COUNT(*) FROM tblSMImportFileHeader WHERE strLayoutTitle = 'Pac Pride') =  0)
BEGIN

	INSERT [dbo].[tblSMImportFileHeader] ([strLayoutTitle], [strFileType], [strFieldDelimiter], [strXMLType], [strXMLInitiater], [ysnActive], [intConcurrencyId]) 
	VALUES (N'Pac Pride', N'Delimiter', N'Comma', NULL, N'', 1, 1)
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

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@pacpridePK, N'Miscellanous', 0, 18, NULL, 0, 1, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@pacpridePK, SCOPE_IDENTITY(), 64, NULL, NULL, N'tblCFTransaction', N'strMiscellaneous', NULL, NULL, NULL, 1, 1)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) 
	VALUES (@pacpridePK, N'Federal Excise Tax Rate Reference', NULL, 59, NULL, NULL, 1, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@pacpridePK, SCOPE_IDENTITY(), 65, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) 
	VALUES (@pacpridePK, N'State Excise Tax Rate 1 Reference', 0, 60, NULL, NULL, 1, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@pacpridePK, SCOPE_IDENTITY(), 66, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)	
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) 
	VALUES (@pacpridePK, N'State Excise Tax Rate 2 Reference', 0, 61, NULL, NULL, 1, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@pacpridePK, SCOPE_IDENTITY(), 67, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding])
	VALUES (@pacpridePK, N'County Excise Tax Rate Reference', 0, 62, NULL, NULL, 1, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@pacpridePK, SCOPE_IDENTITY(), 68, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)	
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) 
	VALUES (@pacpridePK, N'City Excise Tax Rate Reference', 0, 63, NULL, NULL, 1, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@pacpridePK, SCOPE_IDENTITY(), 69, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)	
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) 
	VALUES (@pacpridePK, N'State Sales Tax Percentage Rate Reference', 0, 64, NULL, NULL, 1, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@pacpridePK, SCOPE_IDENTITY(), 70, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)	
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) 
	VALUES (@pacpridePK, N'County Sales Tax Percentage Rate Reference', 0, 65, NULL, NULL, 1, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@pacpridePK, SCOPE_IDENTITY(), 71, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)	
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) 
	VALUES (@pacpridePK, N'City Sales Tax Percentage Rate Reference', 0, 66, NULL, NULL, 1, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@pacpridePK, SCOPE_IDENTITY(), 72, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)	
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) 
	VALUES (@pacpridePK, N'Other Sales Tax Percentage Rate Reference', 0, 67, NULL, NULL, 1, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@pacpridePK, SCOPE_IDENTITY(), 73, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)	

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) 
	VALUES (@pacpridePK, N'Billing Date', 0, 30, NULL, NULL, 1, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@pacpridePK, SCOPE_IDENTITY(), 74, 0, NULL, N'tblCFTransaction', N'dtmBillingDate', NULL, 0, NULL, 1, 1)

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
	VALUES (@nbsPK, N'Card Number', 0, 37, NULL, 0, 2, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@nbsPK, SCOPE_IDENTITY(), 3, 0, NULL, N'tblCFCard', N'strCardNumber', NULL, 21, NULL, 1, 1)

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

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@nbsPK, N'Quantity', 0, 95, NULL, 0, 2, N'5 Implied Decimals')
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@nbsPK, SCOPE_IDENTITY(), 8, 0, NULL, N'tblCFTransaction', N'dblQuantity', NULL, 8, NULL, 1, 1)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@nbsPK, N'Price', 0, 103, NULL, 0, 2, N'2 Implied Decimals')
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) 
	VALUES (@nbsPK, SCOPE_IDENTITY(), 9, 0, NULL, N'tblCFTransaction', N'dblOriginalGrossPrice', NULL, 7, NULL, 1, 1)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@nbsPK, N'Product Id', 0, 164, NULL, 0, 2, NULL)
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@nbsPK, N'Quantity', 0, 1877, NULL, 0, 2, N'5 Implied Decimals')
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) 
	VALUES (@nbsPK, N'Price', 0, 1885, NULL, 0, 2, N'2 Implied Decimals')

END
-----------NBS-------------


-----------CFN-------------

DECLARE @cfnImportHeader INT
IF ((SELECT COUNT(*) FROM tblSMImportFileHeader WHERE strLayoutTitle = 'CFN') =  0)
BEGIN

	INSERT [dbo].[tblSMImportFileHeader] ([strLayoutTitle], [strFileType], [strFieldDelimiter], [strXMLType], [strXMLInitiater], [ysnActive], [intConcurrencyId]) VALUES (N'CFN', N'Delimiter', N'Comma', NULL, NULL, 1, 24)
	SET @cfnImportHeader = SCOPE_IDENTITY();
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@cfnImportHeader, N'Site Number', 0, 0, NULL, 0, 3, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@cfnImportHeader,SCOPE_IDENTITY(), 1,  0, NULL, N'tblCFSite', N'strSiteNumber', NULL, 0, NULL, 1, 6)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@cfnImportHeader, N'Sequence Number', 0, 1, NULL, 0, 3, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@cfnImportHeader,SCOPE_IDENTITY(), 2,  0, NULL, N'tblCFTransaction', N'strSequenceNumber', NULL, 0, NULL, 1, 6)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@cfnImportHeader, N'Total Amount', 0, 3, NULL, 0, 3, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@cfnImportHeader,SCOPE_IDENTITY(), 3,  0, NULL, N'tblCFTransaction', N'dblOriginalTotalPrice', NULL, 0, NULL, 1, 5)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@cfnImportHeader, N'Product Code', 0, 5, NULL, 0, 3, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@cfnImportHeader,SCOPE_IDENTITY(), 4,  0, NULL, N'tblCFItem', N'strProductNumber', NULL, 0, NULL, 1, 5)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@cfnImportHeader, N'Quantity', 0, 9, NULL, 0, 3, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@cfnImportHeader,SCOPE_IDENTITY(), 5,  0, NULL, N'tblCFTransaction', N'dblQuantity', NULL, 0, NULL, 1, 5)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@cfnImportHeader, N'Odometer', 0, 10, NULL, 0, 3, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@cfnImportHeader,SCOPE_IDENTITY(), 6,  0, NULL, N'tblCFTransaction', N'intOdometer', NULL, 0, NULL, 1, 5)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@cfnImportHeader, N'Transaction Date', 0, 13, NULL, 1, 4, N'YYMMDDHHMM', NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@cfnImportHeader,SCOPE_IDENTITY(), 7,  1, NULL, N'tblCFTransaction', N'dtmTransactionDate', NULL, 0, NULL, 1, 4)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@cfnImportHeader, N'Transaction Time', 0, 14, NULL, 1, 4, N'YYMMDDHHMM', NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@cfnImportHeader,SCOPE_IDENTITY(), 8,  2, NULL, NULL, N'', NULL, 0, NULL, 1, 4)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@cfnImportHeader, N'Miscellanous', 0, 17, NULL, 0, 3, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@cfnImportHeader,SCOPE_IDENTITY(), 9,  0, NULL, N'tblCFTransaction', N'strMiscellaneous', NULL, 0, NULL, 1, 5)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@cfnImportHeader, N'Card Number', 0, 18, NULL, 0, 3, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@cfnImportHeader,SCOPE_IDENTITY(), 10, 0, NULL, N'tblCFCard', N'strCardNumber', NULL, 7, NULL, 1, 5)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@cfnImportHeader, N'Vehicle Number', 16, 18, NULL, 0, 4, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@cfnImportHeader,SCOPE_IDENTITY(), 11, 0, NULL, N'tblCFVehicle', N'strVehicleNumber', NULL, 4, NULL, 1, 5)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@cfnImportHeader, N'Transaction Type', 0, 41, NULL, 0, 3, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@cfnImportHeader,SCOPE_IDENTITY(), 12, 0, NULL, N'tblCFTransaction', N'strTransactionType', NULL, 0, NULL, 1, 5)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@cfnImportHeader, N'Pump Price', 0, 44, NULL, 0, 3, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@cfnImportHeader,SCOPE_IDENTITY(), 13, 0, NULL, N'tblCFTransaction', N'dblOriginalGrossPrice', NULL, 0, NULL, 1, 5)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@cfnImportHeader, N'CFN Price', 0, 46, NULL, 0, 3, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@cfnImportHeader,SCOPE_IDENTITY(), 14, 0, NULL, N'tblCFTransaction', N'dblTransferCost', NULL, 0, NULL, 1, 5)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@cfnImportHeader, N'Tax1', 0, 21, NULL, 0, 2, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@cfnImportHeader,SCOPE_IDENTITY(), 15, 0, NULL, NULL, NULL, NULL, 0, NULL, 1, 1)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@cfnImportHeader, N'Tax2', 0, 22, NULL, 0, 2, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@cfnImportHeader,SCOPE_IDENTITY(), 16, 0, NULL, NULL, NULL, NULL, 0, NULL, 1, 1)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@cfnImportHeader, N'Tax3', 0, 23, NULL, 0, 2, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@cfnImportHeader,SCOPE_IDENTITY(), 17, 0, NULL, NULL, NULL, NULL, 0, NULL, 1, 1)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@cfnImportHeader, N'Tax4', 0, 24, NULL, 0, 2, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@cfnImportHeader,SCOPE_IDENTITY(), 18, 0, NULL, NULL, NULL, NULL, 0, NULL, 1, 1)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@cfnImportHeader, N'Tax5', 0, 25, NULL, 0, 2, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@cfnImportHeader,SCOPE_IDENTITY(), 19, 0, NULL, NULL, NULL, NULL, 0, NULL, 1, 1)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@cfnImportHeader, N'Tax6', 0, 26, NULL, 0, 2, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@cfnImportHeader,SCOPE_IDENTITY(), 20, 0, NULL, NULL, NULL, NULL, 0, NULL, 1, 1)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@cfnImportHeader, N'Tax7', 0, 27, NULL, 0, 2, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@cfnImportHeader,SCOPE_IDENTITY(), 21, 0, NULL, NULL, NULL, NULL, 0, NULL, 1, 1)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@cfnImportHeader, N'Tax8', 0, 28, NULL, 0, 2, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@cfnImportHeader,SCOPE_IDENTITY(), 22, 0, NULL, NULL, NULL, NULL, 0, NULL, 1, 1)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@cfnImportHeader, N'Tax9', 0, 29, NULL, 0, 2, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@cfnImportHeader,SCOPE_IDENTITY(), 23, 0, NULL, NULL, NULL, NULL, 0, NULL, 1, 1)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@cfnImportHeader, N'Tax10', 0, 30, NULL, 0, 2, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@cfnImportHeader,SCOPE_IDENTITY(), 24, 0, NULL, NULL, NULL, NULL, 0, NULL, 1, 1)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@cfnImportHeader, N'TaxValue1', 0, 31, NULL, 0, 2, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@cfnImportHeader,SCOPE_IDENTITY(), 25, 0, NULL, NULL, NULL, NULL, 0, NULL, 1, 1)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@cfnImportHeader, N'TaxValue2', 0, 32, NULL, 0, 2, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@cfnImportHeader,SCOPE_IDENTITY(), 26, 0, NULL, NULL, NULL, NULL, 0, NULL, 1, 1)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@cfnImportHeader, N'TaxValue3', 0, 33, NULL, 0, 2, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@cfnImportHeader,SCOPE_IDENTITY(), 27, 0, NULL, NULL, NULL, NULL, 0, NULL, 1, 1)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@cfnImportHeader, N'TaxValue4', 0, 34, NULL, 0, 2, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@cfnImportHeader,SCOPE_IDENTITY(), 28, 0, NULL, NULL, NULL, NULL, 0, NULL, 1, 1)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@cfnImportHeader, N'TaxValue5', 0, 35, NULL, 0, 2, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@cfnImportHeader,SCOPE_IDENTITY(), 29, 0, NULL, NULL, NULL, NULL, 0, NULL, 1, 1)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@cfnImportHeader, N'TaxValue6', 0, 36, NULL, 0, 2, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@cfnImportHeader,SCOPE_IDENTITY(), 30, 0, NULL, NULL, NULL, NULL, 0, NULL, 1, 1)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@cfnImportHeader, N'TaxValue7', 0, 37, NULL, 0, 2, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@cfnImportHeader,SCOPE_IDENTITY(), 31, 0, NULL, NULL, NULL, NULL, 0, NULL, 1, 1)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@cfnImportHeader, N'TaxValue8', 0, 38, NULL, 0, 2, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@cfnImportHeader,SCOPE_IDENTITY(), 32, 0, NULL, NULL, NULL, NULL, 0, NULL, 1, 1)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@cfnImportHeader, N'TaxValue9', 0, 39, NULL, 0, 2, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@cfnImportHeader,SCOPE_IDENTITY(), 33, 0, NULL, NULL, NULL, NULL, 0, NULL, 1, 1)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@cfnImportHeader, N'TaxValue10', 0, 40, NULL, 0, 2, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@cfnImportHeader,SCOPE_IDENTITY(), 34, 0, NULL, NULL, NULL, NULL, 0, NULL, 1, 1)
	
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@cfnImportHeader, N'PumpNumber', 0, 11, NULL, 0, 2, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@cfnImportHeader,SCOPE_IDENTITY(), 35, 0, NULL, N'tblCFTransaction', N'intPumpNumber', NULL, 0, NULL, 1, 1)

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@cfnImportHeader, N'SiteTaxLocation', 0, 20, NULL, 0, 1, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@cfnImportHeader,SCOPE_IDENTITY(), 36, 0, NULL, NULL, NULL, NULL, 2, NULL, 1, 1)

END


-----------CFN-------------


----- Network Cost Pac Pride
DECLARE @headerId INT
DECLARE @fileHeaderId INT
IF ((SELECT COUNT(*) FROM tblSMImportFileHeader WHERE strLayoutTitle = 'Network Cost Pac Pride') =  0)
BEGIN
	--[tblSMImportFileHeader]
	INSERT [dbo].[tblSMImportFileHeader] ([strLayoutTitle], [strFileType], [strFieldDelimiter], [strXMLType], [strXMLInitiater], [ysnActive], [intConcurrencyId]) VALUES (N'Network Cost Pac Pride', N'Delimiter', 'Comma', NULL, NULL, 1, 1)

	SET @headerId = SCOPE_IDENTITY()

	--[tblSMImportFileRecordMarker]
	INSERT [dbo].[tblSMImportFileRecordMarker] ( [intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@headerId, N'Site', 0, 2, NULL, NULL, 1, NULL, NULL)
	SET @fileHeaderId = SCOPE_IDENTITY()
	INSERT [dbo].[tblSMImportFileColumnDetail] ( [intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@headerId, @fileHeaderId, 1, 0, NULL, NULL, NULL, NULL, NULL, N'', 1, 1)


	INSERT [dbo].[tblSMImportFileRecordMarker] ( [intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@headerId, N'Product', 0, 7, NULL, NULL, 1, NULL, NULL)
	SET @fileHeaderId = SCOPE_IDENTITY()
	INSERT [dbo].[tblSMImportFileColumnDetail] ( [intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@headerId, @fileHeaderId, 2, 0, NULL, NULL, NULL, NULL, NULL, N'', 1, 1)


	INSERT [dbo].[tblSMImportFileRecordMarker] ( [intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@headerId, N'Transfer Cost', 0, 9, NULL, NULL, 1, NULL, NULL)
	SET @fileHeaderId = SCOPE_IDENTITY()
	INSERT [dbo].[tblSMImportFileColumnDetail] ( [intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@headerId, @fileHeaderId, 3, 0, NULL, NULL, NULL, NULL, NULL, N'', 1, 1)


	INSERT [dbo].[tblSMImportFileRecordMarker] ( [intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@headerId, N'Effective Date', 0, 6, NULL, NULL, 1, NULL, NULL)
	SET @fileHeaderId = SCOPE_IDENTITY()
	INSERT [dbo].[tblSMImportFileColumnDetail] ( [intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@headerId, @fileHeaderId, 4, 0, NULL, NULL, NULL, NULL, NULL, N'', 1, 1)


	INSERT [dbo].[tblSMImportFileRecordMarker] ( [intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@headerId, N'Fed Tax', 0, 11, NULL, NULL, 1, NULL, NULL)
	SET @fileHeaderId = SCOPE_IDENTITY()
	INSERT [dbo].[tblSMImportFileColumnDetail] ( [intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@headerId, @fileHeaderId, 5, 0, NULL, NULL, NULL, NULL, NULL, N'', 1, 1)


	INSERT [dbo].[tblSMImportFileRecordMarker] ( [intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@headerId, N'State Tax', 0, 12, NULL, NULL, 1, NULL, NULL)
	SET @fileHeaderId = SCOPE_IDENTITY()
	INSERT [dbo].[tblSMImportFileColumnDetail] ( [intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@headerId, @fileHeaderId, 6, 0, NULL, NULL, NULL, NULL, NULL, N'', 1, 1)


	INSERT [dbo].[tblSMImportFileRecordMarker] ( [intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@headerId, N'County Tax', 0, 13, NULL, NULL, 1, NULL, NULL)
	SET @fileHeaderId = SCOPE_IDENTITY()
	INSERT [dbo].[tblSMImportFileColumnDetail] ( [intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@headerId, @fileHeaderId, 7, 0, NULL, NULL, NULL, NULL, NULL, N'', 1, 1)


	INSERT [dbo].[tblSMImportFileRecordMarker] ( [intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@headerId, N'City Tax', 0, 14, NULL, NULL, 1, NULL, NULL)
	SET @fileHeaderId = SCOPE_IDENTITY()
	INSERT [dbo].[tblSMImportFileColumnDetail] ( [intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@headerId, @fileHeaderId, 8, 0, NULL, NULL, NULL, NULL, NULL, N'', 1, 1)


	INSERT [dbo].[tblSMImportFileRecordMarker] ( [intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@headerId, N'Sales Tax', 0, 34, NULL, NULL, 1, NULL, NULL)
	SET @fileHeaderId = SCOPE_IDENTITY()
	INSERT [dbo].[tblSMImportFileColumnDetail] ( [intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@headerId, @fileHeaderId, 9, 0, NULL, NULL, NULL, NULL, NULL, N'', 1, 1)


	INSERT [dbo].[tblSMImportFileRecordMarker] ( [intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@headerId, N'St Other Tax', 0, 17, NULL, NULL, 1, NULL, NULL)
	SET @fileHeaderId = SCOPE_IDENTITY()
	INSERT [dbo].[tblSMImportFileColumnDetail] ( [intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@headerId, @fileHeaderId, 10, 0, NULL, NULL, NULL, NULL, NULL, N'', 1, 1)


	INSERT [dbo].[tblSMImportFileRecordMarker] ( [intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@headerId, N'Sales Tax Type', 0, 16, NULL, NULL, 1, NULL, NULL)
	SET @fileHeaderId = SCOPE_IDENTITY()
	INSERT [dbo].[tblSMImportFileColumnDetail] ( [intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@headerId, @fileHeaderId, 11, 0, NULL, NULL, NULL, NULL, NULL, N'', 1, 1)


	INSERT [dbo].[tblSMImportFileRecordMarker] ( [intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@headerId, N'Fed Tax Type', 0, 21, NULL, NULL, 1, NULL, NULL)
	SET @fileHeaderId = SCOPE_IDENTITY()
	INSERT [dbo].[tblSMImportFileColumnDetail] ( [intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@headerId, @fileHeaderId, 12, 0, NULL, NULL, NULL, NULL, NULL, N'', 1, 1)


	INSERT [dbo].[tblSMImportFileRecordMarker] ( [intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@headerId, N'State Tax Type', 0, 22, NULL, NULL, 1, NULL, NULL)
	SET @fileHeaderId = SCOPE_IDENTITY()
	INSERT [dbo].[tblSMImportFileColumnDetail] ( [intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@headerId, @fileHeaderId, 13, 0, NULL, NULL, NULL, NULL, NULL, N'', 1, 1)


	INSERT [dbo].[tblSMImportFileRecordMarker] ( [intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@headerId, N'County Tax Type', 0, 23, NULL, NULL, 1, NULL, NULL)
	SET @fileHeaderId = SCOPE_IDENTITY()
	INSERT [dbo].[tblSMImportFileColumnDetail] ( [intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@headerId, @fileHeaderId, 14, 0, NULL, NULL, NULL, NULL, NULL, N'', 1, 1)


	INSERT [dbo].[tblSMImportFileRecordMarker] ( [intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@headerId, N'City Tax Type', 0, 24, NULL, NULL, 1, NULL, NULL)
	SET @fileHeaderId = SCOPE_IDENTITY()
	INSERT [dbo].[tblSMImportFileColumnDetail] ( [intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@headerId, @fileHeaderId, 15, 0, NULL, NULL, NULL, NULL, NULL, N'', 1, 1)


	INSERT [dbo].[tblSMImportFileRecordMarker] ( [intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@headerId, N'St Other Tax Type', 0, 25, NULL, NULL, 1, NULL, NULL)
	SET @fileHeaderId = SCOPE_IDENTITY()
	INSERT [dbo].[tblSMImportFileColumnDetail] ( [intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@headerId, @fileHeaderId, 16, 0, NULL, NULL, NULL, NULL, NULL, N'', 1, 1)

END

---- Network Cost Pac Pride

---- Network Cost CFN
DECLARE @siteFileHeaderId INT
DECLARE @dateFileHeaderId INT
DECLARE @productFileHeaderId INT
DECLARE @costFileHeaderId INT
DECLARE @taxFileHeaderId INT

IF ((SELECT COUNT(*) FROM tblSMImportFileHeader WHERE strLayoutTitle = 'Network Cost CFN') =  0)
BEGIN
	--[tblSMImportFileHeader]
	INSERT [dbo].[tblSMImportFileHeader] ([strLayoutTitle], [strFileType], [strFieldDelimiter], [strXMLType], [strXMLInitiater], [ysnActive], [intConcurrencyId]) VALUES (N'Network Cost CFN', N'Fixed', NULL, NULL, NULL, 1, 1)

	SET @headerId = SCOPE_IDENTITY()

	--[tblSMImportFileRecordMarker]
	INSERT [dbo].[tblSMImportFileRecordMarker] ( [intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@headerId, N'Site', 0, 0, NULL, 1, 1, NULL, NULL)
	SET @siteFileHeaderId = SCOPE_IDENTITY()

	INSERT [dbo].[tblSMImportFileRecordMarker] ( [intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@headerId, N'Date', 0, 6, NULL, 2, 1, N'YYMMDD', NULL)
	SET @dateFileHeaderId = SCOPE_IDENTITY()

	INSERT [dbo].[tblSMImportFileRecordMarker] ( [intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@headerId, N'Product', 0, 12, NULL, 3, 1, NULL, NULL)
	SET @productFileHeaderId = SCOPE_IDENTITY()

	INSERT [dbo].[tblSMImportFileRecordMarker] ( [intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@headerId, N'Network Cost', 0, 16, NULL, 4, 1, N'5 Implied Decimals', NULL)
	SET @costFileHeaderId = SCOPE_IDENTITY()

	INSERT [dbo].[tblSMImportFileRecordMarker] ( [intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@headerId, N'Taxes', 0, 22, NULL, 5, 1, N'5 Implied Decimals', NULL)
	SET @taxFileHeaderId = SCOPE_IDENTITY()


	--[tblSMImportFileColumnDetail]
	INSERT [dbo].[tblSMImportFileColumnDetail] ( [intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@headerId, @siteFileHeaderId, 1, 0, NULL, N'tblCFSite', N'strSiteNumber', NULL, 6, N'', 1, 1)

	INSERT [dbo].[tblSMImportFileColumnDetail] ( [intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@headerId, @dateFileHeaderId, 2, 6, NULL, N'tblCFNetworkCost', N'dtmDate', NULL, 6, N'', 1, 1)

	INSERT [dbo].[tblSMImportFileColumnDetail] ( [intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@headerId, @productFileHeaderId, 3, 12, NULL, N'tblICItem', N'strItemNo', NULL, 4, N'', 1, 1)

	INSERT [dbo].[tblSMImportFileColumnDetail] ( [intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@headerId, @costFileHeaderId, 4, 16, NULL, N'tblCFNetworkCost', N'dblTransferCost', NULL, 6, N'', 1, 1)

	INSERT [dbo].[tblSMImportFileColumnDetail] ( [intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@headerId, @taxFileHeaderId, 5, 22, NULL, N'tblCFNetworkCost', N'dblTaxesPerUnit', NULL, 6, N'', 1, 1)
END
---- Network Cost CFN


----GASBOY


GO
DECLARE @gasboyBodyImportHeader INT
IF ((SELECT COUNT(*) FROM tblSMImportFileHeader WHERE strLayoutTitle = 'Gasboy Detail') =  0)
BEGIN

INSERT [dbo].[tblSMImportFileHeader] ([strLayoutTitle], [strFileType], [strFieldDelimiter], [strXMLType], [strXMLInitiater], [ysnActive], [intConcurrencyId]) VALUES (N'Gasboy Detail', N'Delimiter', N'Space', NULL, NULL, 1, 16)
SET @gasboyBodyImportHeader = SCOPE_IDENTITY();

INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@gasboyBodyImportHeader, N'Transaction Date', 0, 44, NULL, 0, 4, N'MM/DD HH:MM', NULL)
INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@gasboyBodyImportHeader, SCOPE_IDENTITY(), 1, 1, NULL, N'tblCFTransaction', N'dtmTransactionDate', NULL, 11, NULL, 1, 4)

INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@gasboyBodyImportHeader, N'Card Number', 0, 19, NULL, 2, 3, NULL, NULL)
INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@gasboyBodyImportHeader, SCOPE_IDENTITY(), 3, 2, NULL, N'tblCFCard', N'strCardNumber', NULL, 4, NULL, 1, 3)

INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@gasboyBodyImportHeader, N'Vehicle Number', 0, 29, NULL, NULL, 2, NULL, NULL)
INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@gasboyBodyImportHeader, SCOPE_IDENTITY(), 4, NULL, NULL, N'tblCFVehicle', N'strVehicleNumber', NULL, 7, NULL, 1, 2)

INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@gasboyBodyImportHeader, N'Odometer', 0, 88, NULL, NULL, 2, NULL, NULL)
INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@gasboyBodyImportHeader, SCOPE_IDENTITY(), 5, NULL, NULL, N'tblCFTransaction', N'intOdometer', NULL, 6, NULL, 1, 2)

INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@gasboyBodyImportHeader, N'Sequence Number', 0, 0, NULL, NULL, 2, NULL, NULL)
INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@gasboyBodyImportHeader, SCOPE_IDENTITY(), 6, NULL, NULL, N'tblCFTransaction', N'strSequenceNumber', NULL, 4, NULL, 1, 2)

INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@gasboyBodyImportHeader, N'Pump Number', 0, 56, NULL, NULL, 2, NULL, NULL)
INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@gasboyBodyImportHeader, SCOPE_IDENTITY(), 7, NULL, NULL, N'tblCFTransaction', N'intPumpNumber', NULL, 2, NULL, 1, 1)

INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@gasboyBodyImportHeader, N'Product Id', 0, 59, NULL, NULL, 2, NULL, NULL)
INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@gasboyBodyImportHeader, SCOPE_IDENTITY(), 8, NULL, NULL, N'tblCFItem', N'strProductNumber', NULL, 2, NULL, 1, 1)

INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@gasboyBodyImportHeader, N'Quantity', 0, 64, NULL, NULL, 3, N'2 Implied Decimals', NULL)
INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@gasboyBodyImportHeader, SCOPE_IDENTITY(), 9, NULL, NULL, N'tblCFTransaction', N'dblQuantity', NULL, 7, NULL, 1, 3)

INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@gasboyBodyImportHeader, N'Transfer Cost', 0, NULL, NULL, NULL, 1, NULL, NULL)
INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@gasboyBodyImportHeader, SCOPE_IDENTITY(), 10, NULL, NULL, N'tblCFTransaction', N'dblTransferCost', NULL, NULL, NULL, 1, 1)

INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@gasboyBodyImportHeader, N'Price', 0, 72, NULL, NULL, 2, N'3 Implied Decimals', NULL)
INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@gasboyBodyImportHeader, SCOPE_IDENTITY(), 11, NULL, NULL, N'tblCFTransaction', N'dblOriginalGrossPrice', NULL, 5, NULL, 1, 2)

INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@gasboyBodyImportHeader, N'ISO', 0, 32, NULL, NULL, 1, NULL, NULL)
INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@gasboyBodyImportHeader, SCOPE_IDENTITY(), 12, NULL, NULL, N'tblCFCreditCard', N'strPrefix', NULL, 4, NULL, 1, 1)

INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@gasboyBodyImportHeader, N'Transaction Time', 0, 50, NULL, 0, 3, N'HH:MM', NULL)
INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@gasboyBodyImportHeader, SCOPE_IDENTITY(), 13, 2, NULL, NULL, NULL, NULL, 5, NULL, 0, 4)

INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@gasboyBodyImportHeader, N'Account', 0, 12, NULL, 2, 2, NULL, NULL)
INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@gasboyBodyImportHeader, SCOPE_IDENTITY(), 14, 1, NULL, NULL, NULL, NULL, 6, NULL, 1, 2)

END



GO
DECLARE @gasboyHeaderImportHeader INT
IF ((SELECT COUNT(*) FROM tblSMImportFileHeader WHERE strLayoutTitle = 'Gasboy Header') =  0)
BEGIN

	INSERT [dbo].[tblSMImportFileHeader] ([strLayoutTitle], [strFileType], [strFieldDelimiter], [strXMLType], [strXMLInitiater], [ysnActive], [intConcurrencyId]) VALUES (N'Gasboy Header', N'Delimiter', N'Space', NULL, NULL, 1, 1)
	SET @gasboyHeaderImportHeader = SCOPE_IDENTITY();

	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@gasboyHeaderImportHeader, N'Site Number', 0, 21, NULL, NULL, 1, NULL, NULL)
	INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@gasboyHeaderImportHeader, SCOPE_IDENTITY(), 1, 0, NULL, N'tblCFSite', N'strSiteNumber', NULL, 4, N'', 1, 1)
END


GO
DECLARE @advanceMappingHeader INT
IF ((SELECT COUNT(*) FROM [tblCFAdvanceMapping] WHERE [strAdvanceMappingId] = 'Gasboy Advance Mapping') =  0)
BEGIN
	INSERT [dbo].[tblCFAdvanceMapping] ([strAdvanceMappingId], [intConcurrencyId]) VALUES (N'Gasboy Advance Mapping', 1)
	SET @advanceMappingHeader = SCOPE_IDENTITY();

	INSERT [dbo].[tblCFAdvanceMappingDetail] ([intAdvanceMappingId], [strRecordType], [intRecordTypePosition], [intRecordTypeLength], [strFileType], [intLinkFieldPosition], [intLinkFieldLength], [strSequenceId], [intImportMapping], [strRuleId], [intConcurrencyId]) VALUES (@advanceMappingHeader, N'Transactions at site', 0, 20, N'txt', 0, 0, N'Header', null, N'With each detail', 1)
	INSERT [dbo].[tblCFAdvanceMappingDetail] ([intAdvanceMappingId], [strRecordType], [intRecordTypePosition], [intRecordTypeLength], [strFileType], [intLinkFieldPosition], [intLinkFieldLength], [strSequenceId], [intImportMapping], [strRuleId], [intConcurrencyId]) VALUES (@advanceMappingHeader, N'=(type)Numeric', 0, 4, N'txt', 0, 0, N'Detail', null, N'', 1)

END


----GASBOY



GO
DECLARE @magmediaImportHeader INT
IF ((SELECT COUNT(*) FROM tblSMImportFileHeader WHERE strLayoutTitle = 'CF MagMedia CSV') =  0)
BEGIN

	INSERT [dbo].[tblSMImportFileHeader] ([strLayoutTitle], [strFileType], [strFieldDelimiter], [strXMLType], [strXMLInitiater], [ysnActive], [intConcurrencyId]) VALUES (N'CF MagMedia CSV', N'Delimiter', N'Comma', NULL, NULL, 1, 5)
	SET @magmediaImportHeader = SCOPE_IDENTITY();


	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@magmediaImportHeader, N'TX-Record', 0, 1, NULL, 0, 1, NULL, NULL)
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@magmediaImportHeader, N'CustomerNumber', 0, 2, NULL, 0, 1, NULL, NULL)
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@magmediaImportHeader, N'CustomerName', 0, 3, NULL, 0, 2, NULL, NULL)
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@magmediaImportHeader, N'StatementDate', 0, 4, NULL, 0, 1, NULL, NULL)
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@magmediaImportHeader, N'VehicleNumber', 0, 5, NULL, 0, 1, NULL, NULL)
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@magmediaImportHeader, N'VehicleNumberDescription', 0, 6, NULL, 0, 1, NULL, NULL)
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@magmediaImportHeader, N'CardNumber', 0, 7, NULL, 0, 1, NULL, NULL)
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@magmediaImportHeader, N'CardDescription', 0, 8, NULL, 0, 1, NULL, NULL)
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@magmediaImportHeader, N'SiteNumber', 0, 9, NULL, 0, 1, NULL, NULL)
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@magmediaImportHeader, N'SiteAddress', 0, 10, NULL, 0, 1, NULL, NULL)
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@magmediaImportHeader, N'TransactionDate', 0, 11, NULL, 0, 1, N'MM/DD/YYYY', NULL)
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@magmediaImportHeader, N'TransactionTime', 0, 12, NULL, 0, 2, N'HHMM', NULL)
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@magmediaImportHeader, N'Odometer', 0, 13, NULL, 0, 1, NULL, NULL)
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@magmediaImportHeader, N'Miscellaneous', 0, 14, NULL, 0, 1, NULL, NULL)
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@magmediaImportHeader, N'ItemNumber', 0, 15, NULL, 0, 1, NULL, NULL)
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@magmediaImportHeader, N'ItemDescription', 0, 16, NULL, 0, 1, NULL, NULL)
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@magmediaImportHeader, N'Quantity', 0, 17, NULL, 0, 1, NULL, NULL)
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@magmediaImportHeader, N'GrossPrice', 0, 18, NULL, 0, 1, NULL, NULL)
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@magmediaImportHeader, N'TotalAmount', 0, 19, NULL, 0, 1, NULL, NULL)
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@magmediaImportHeader, N'ZZ FET1', 0, 20, NULL, 0, 1, NULL, NULL)
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@magmediaImportHeader, N'ZZ SET', 0, 21, NULL, 0, 1, NULL, NULL)
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@magmediaImportHeader, N'ZZ SET2', 0, 22, NULL, 0, 1, NULL, NULL)
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@magmediaImportHeader, N'ZZ SET3', 0, 23, NULL, 0, 1, NULL, NULL)
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@magmediaImportHeader, N'ZZ County', 0, 24, NULL, 0, 1, NULL, NULL)
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@magmediaImportHeader, N'ZZ City', 0, 25, NULL, 0, 1, NULL, NULL)
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@magmediaImportHeader, N'ZZ Misc', 0, 26, NULL, 0, 1, NULL, NULL)
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@magmediaImportHeader, N'ZZ Sales Tax', 0, 27, NULL, 0, 1, NULL, NULL)
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@magmediaImportHeader, N'ZZ County Sales', 0, 28, NULL, 0, 1, NULL, NULL)
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@magmediaImportHeader, N'ZZ City Sales Tax', 0, 29, NULL, 0, 1, NULL, NULL)
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@magmediaImportHeader, N'TransactionNumber', 0, 30, NULL, 0, 1, NULL, NULL)
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@magmediaImportHeader, N'ZZ - Tran Seq#', 0, 31, NULL, 0, 1, NULL, NULL)
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@magmediaImportHeader, N'Department', 0, 32, NULL, 0, 1, NULL, NULL)
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@magmediaImportHeader, N'ZZ AFS Tax Code', 0, 33, NULL, 0, 1, NULL, NULL)
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@magmediaImportHeader, N'TaxState', 0, 34, NULL, 0, 1, NULL, NULL)
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@magmediaImportHeader, N'Network', 0, 35, NULL, 0, 1, NULL, NULL)
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@magmediaImportHeader, N'InvoiceNo', 0, 36, NULL, 0, 2, NULL, NULL)
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@magmediaImportHeader, N'FET', 0, 37, NULL, 0, 2, NULL, NULL)
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@magmediaImportHeader, N'SET', 0, 38, NULL, 0, 2, NULL, NULL)
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@magmediaImportHeader, N'SST', 0, 39, NULL, 0, 2, NULL, NULL)
	INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat], [intRounding]) VALUES (@magmediaImportHeader, N'Local', 0, 40, NULL, 0, 2, NULL, NULL)

END