GO

IF ((SELECT COUNT(*) FROM tblSMImportFileHeader WHERE strLayoutTitle = 'Pac Pride') =  0)
BEGIN

INSERT [dbo].[tblSMImportFileHeader] ([strLayoutTitle], [strFileType], [strFieldDelimiter], [strXMLType], [strXMLInitiater], [ysnActive], [intConcurrencyId]) VALUES (N'Pac Pride', N'Delimiter', N'Comma', NULL, N'', 1, 1)

DECLARE @IFH INT
SET @IFH = SCOPE_IDENTITY();

INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) VALUES (@IFH, N'Transaction Date', 0, 10, NULL, 0, 4, NULL)
INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@IFH, SCOPE_IDENTITY(), 29, 0, NULL, N'tblCFTransaction', N'dtmTransactionDate', NULL, 0, N'', 1, 4)

INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) VALUES (@IFH, N'Site Number', 0, 2, NULL, 0, 3, NULL)
INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@IFH, SCOPE_IDENTITY(), 30, 0, NULL, N'tblCFSite', N'strSiteNumber', NULL, 0, N'', 1, 3)

INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) VALUES (@IFH, N'Card Number', 0, 14, NULL, 0, 3, NULL)
INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@IFH, SCOPE_IDENTITY(), 31, 0, NULL, N'tblCFCard', N'strCardNumber', NULL, 0, N'', 1, 3)

INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) VALUES (@IFH, N'Vehicle Number', 0, 15, NULL, 0, 3, NULL)
INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@IFH, SCOPE_IDENTITY(), 32, 0, NULL, N'tblCFVehicle', N'strVehicleNumber', NULL, 0, N'', 1, 3)

INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) VALUES (@IFH, N'Odometer', 0, 19, NULL, 0, 3, NULL)
INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@IFH, SCOPE_IDENTITY(), 33, 0, NULL, N'tblCFTransaction', N'intOdometer', NULL, 0, N'', 1, 3)

INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) VALUES (@IFH, N'Sequence Number', 0, 21, NULL, 0, 3, NULL)
INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@IFH, SCOPE_IDENTITY(), 34, 0, NULL, N'tblCFTransaction', N'strSequenceNumber', NULL, 0, N'', 1, 3)

INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) VALUES (@IFH, N'Pump Number', 0, 22, NULL, 0, 3, NULL)
INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@IFH, SCOPE_IDENTITY(), 35, 0, NULL, N'tblCFTransaction', N'intPumpNumber', NULL, 0, N'', 1, 3)

INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) VALUES (@IFH, N'Product Id', 0, 24, NULL, 0, 3, NULL)
INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@IFH, SCOPE_IDENTITY(), 36, 0, NULL, N'tblCFItem', N'strProductNumber', NULL, 0, N'', 1, 3)

INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) VALUES (@IFH, N'Quantity', 0, 25, NULL, 0, 3, NULL)
INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@IFH, SCOPE_IDENTITY(), 37, 0, NULL, N'tblCFTransaction', N'dblQuantity', NULL, 0, N'', 1, 3)

INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) VALUES (@IFH, N'Transfer Cost', 0, 28, NULL, 0, 3, NULL)
INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES ( @IFH, SCOPE_IDENTITY(), 38, 0, NULL, N'tblCFTransaction', N'dblTransferCost', NULL, 0, N'', 1, 3)

INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) VALUES (@IFH, N'Price', 0, 27, NULL, 0, 2, NULL)
INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@IFH, SCOPE_IDENTITY(), 39, NULL, NULL, N'tblCFTransactionPrice', N'dblOriginalGrossPrice', NULL, NULL, NULL, 1, 6)

INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) VALUES (@IFH, N'TaxState', 0, 38, NULL, 0, 4, NULL)
INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@IFH, SCOPE_IDENTITY(), 40, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 3)

INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) VALUES (@IFH, N'Federal Excise Tax Rate', 0, 49, NULL, 0, 5, NULL)
INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@IFH, SCOPE_IDENTITY(), 41, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 3)

INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) VALUES (@IFH, N'State Excise Tax Rate 1', 0, 50, NULL, 0, 4, NULL)
INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@IFH, SCOPE_IDENTITY(), 42, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 3)

INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) VALUES (@IFH, N'State Excise Tax Rate 2', 0, 54, NULL, 0, 5, NULL)
INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@IFH, SCOPE_IDENTITY(), 43, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 3)

INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) VALUES (@IFH, N'County Excise Tax Rate', 0, 51, NULL, 0, 5, NULL)
INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@IFH, SCOPE_IDENTITY(), 44, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 3)

INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) VALUES (@IFH, N'City Excise Tax Rate', 0, 52, NULL, 0, 5, NULL)
INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@IFH, SCOPE_IDENTITY(), 45, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 3)

INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) VALUES (@IFH, N'State Sales Tax Percentage Rate', 0, 53, NULL, 0, 5, NULL)
INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@IFH, SCOPE_IDENTITY(), 46, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 3)

INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) VALUES (@IFH, N'County Sales TaxPercentage Rate', 0, 54, NULL, 0, 5, NULL)
INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@IFH, SCOPE_IDENTITY(), 47, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 3)

INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) VALUES (@IFH, N'City Sales Tax Percentage Rate', 0, 55, NULL, 0, 6, NULL)
INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@IFH, SCOPE_IDENTITY(), 48, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 3)

INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) VALUES (@IFH, N'Other Sales Tax Percentage Rate', 0, 56, NULL, 0, 6, NULL)
INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@IFH, SCOPE_IDENTITY(), 55, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 3)

INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) VALUES (@IFH, N'strSiteState', 0, 6, NULL, 0, 2, NULL)
INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@IFH, SCOPE_IDENTITY(), 56, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 2)

INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) VALUES (@IFH, N'strSiteAddress', 0, 4, NULL, 0, 2, NULL)
INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@IFH, SCOPE_IDENTITY(), 57, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 3)

INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) VALUES (@IFH, N'strSiteCity', 0, 5, NULL, 0, 2, NULL)
INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@IFH, SCOPE_IDENTITY(), 58, NULL, NULL, NULL, NULL, NULL, 0, NULL, 1, 3)

INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) VALUES (@IFH, N'intPPHostId', 0, 23, NULL, 0, 2, NULL)
INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@IFH, SCOPE_IDENTITY(), 59, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 3)

INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) VALUES (@IFH, N'strPPSiteType', 0, 3, NULL, 0, 3, NULL)
INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@IFH, SCOPE_IDENTITY(), 60, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 3)

INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) VALUES (@IFH, N'SellingHost', 0, 1, NULL, 0, 3, NULL)
INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@IFH, SCOPE_IDENTITY(), 61, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 3)

INSERT [dbo].[tblSMImportFileRecordMarker] ([intImportFileHeaderId], [strRecordMarker], [intRowsToSkip], [intPosition], [strCondition], [intSequence], [intConcurrencyId], [strFormat]) VALUES (@IFH, N'BuyingHost', 0, 16, NULL, 0, 3, NULL)
INSERT [dbo].[tblSMImportFileColumnDetail] ([intImportFileHeaderId], [intImportFileRecordMarkerId], [intLevel], [intPosition], [strXMLTag], [strTable], [strColumnName], [strDataType], [intLength], [strDefaultValue], [ysnActive], [intConcurrencyId]) VALUES (@IFH, SCOPE_IDENTITY(), 62, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 3)

END