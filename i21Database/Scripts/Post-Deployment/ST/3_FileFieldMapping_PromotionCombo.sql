

GO

IF NOT EXISTS (SELECT 1 FROM [tblSMImportFileHeader] WHERE strLayoutTitle = 'Pricebook Combo' AND strFileType = 'XML' AND [strXMLType] = 'Outbound')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileHeader]
			   ([strLayoutTitle]
			   ,[strFileType]
			   ,[strFieldDelimiter]
			   ,[strXMLType]
			   ,[strXMLInitiater]
			   ,[intConcurrencyId])
		 VALUES
			   ('Pricebook Combo'
			   ,'XML'
			   ,NULL
			   ,'Outbound'
			   ,'<?xml version="1.0"?>'
			   ,1)
END

DECLARE @intImportFileHeaderId Int, @intImportFileColumnDetailId Int

SELECT @intImportFileHeaderId = intImportFileHeaderId FROM [dbo].[tblSMImportFileHeader]
WHERE strLayoutTitle = 'Pricebook Combo' AND strFileType = 'XML' AND [strXMLType] = 'Outbound'

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'NAXML-MaintenanceRequest')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 1, NULL, 'NAXML-MaintenanceRequest', 'tblSTstgComboSalesFile', NULL
			   , '', 0, '', 1, 1
END

IF EXISTS (SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'NAXML-MaintenanceRequest')
BEGIN			   
	SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM [dbo].[tblSMImportFileColumnDetail] 
	Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'NAXML-MaintenanceRequest'  
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'xmlns:radiant')
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	1,	'xmlns:radiant',	NULL,	NULL,	'http://www.radiantsystems.com/NAXML-Extension', 1, 1	
	END
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'xmlns')
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	2,	'xmlns',	NULL,	NULL,	'http://www.naxml.org/POSBO/Vocabulary/2003-10-16', 1, 1	
	END
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'version')
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	3,	'version',	NULL,	NULL,	'3.4', 1, 1	
	END
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'xsi:schemaLocation')
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	4,	'xsi:schemaLocation',	NULL,	NULL,	'http://www.radiantsystems.com/NAXML-Extension NAXML-RadiantExtension34.xsd', 1, 1	
	END
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'xmlns:xsi')
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	5,	'xmlns:xsi',	NULL,	NULL,	'http://www.w3.org/2001/XMLSchema-instance', 1, 1	
	END
	
	SET @intImportFileColumnDetailId = 0				   
END



IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'TransmissionHeader')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 2, 1, 'TransmissionHeader', 'tblSTstgComboSalesFile', NULL
			   , 'Header', 1, '', 1, 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'StoreLocationID')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 3,		1, 'StoreLocationID', 'tblSTstgComboSalesFile', 'StoreLocationID'
			   , NULL, 2, '', 1, 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'VendorName')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 4,		2, 'VendorName', 'tblSTstgComboSalesFile', 'VendorName'
			   , NULL, 2, '', 1, 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'VendorModelVersion')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 5,		3, 'VendorModelVersion', 'tblSTstgComboSalesFile', 'VendorModelVersion'
			   , NULL, 2, '', 1, 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'ComboMaintenance')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 6,		2, 'ComboMaintenance', 'tblSTstgComboSalesFile', NULL
			   , 'Header', 1, '', 1, 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'TableAction')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 7,		1, 'TableAction', NULL, NULL
			   , NULL, 6, '', 1, 1
			   
END

IF EXISTS (SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'TableAction')
BEGIN			   
	SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM [dbo].[tblSMImportFileColumnDetail] 
	Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'TableAction'  
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'type')
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	1,	'type',	'tblSTstgComboSalesFile',	'TableActionType',	'', 1, 1	
	END
	
	SET @intImportFileColumnDetailId = 0
			   
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'RecordAction' AND intLevel = 8)
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 8,		2, 'RecordAction', NULL, NULL
			   , NULL, 6, '', 1, 1
END

IF EXISTS (SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'RecordAction' AND intLevel = 8)
BEGIN			   
	SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM [dbo].[tblSMImportFileColumnDetail] 
	Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'RecordAction' AND intLevel = 8  
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'type')
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	1,	'type',	'tblSTstgComboSalesFile',	'RecordActionType',	'', 1, 1	
	END
	
	SET @intImportFileColumnDetailId = 0
				   
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'CBTDetail')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 9,		3, 'CBTDetail', 'tblSTstgComboSalesFile', NULL
			   , NULL, 6, '', 1, 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'RecordAction' AND intLevel = 10)
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 10,		1, 'RecordAction', NULL, NULL
			   , NULL, 9, '', 1, 1
END

IF EXISTS (SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'RecordAction' AND intLevel = 10)
BEGIN			   
	SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM [dbo].[tblSMImportFileColumnDetail] 
	Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'RecordAction' AND intLevel = 10  
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'type')
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	1,	'type',	'tblSTstgComboSalesFile',	'CBTDetailRecordActionType',	'', 1, 1	
	END
	
	SET @intImportFileColumnDetailId = 0
				   
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'Promotion')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 11,		2, 'Promotion', 'tblSTstgComboSalesFile', NULL
			   , 'Header', 9, '', 1, 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'PromotionID')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 12,		1, 'PromotionID', 'tblSTstgComboSalesFile', 'PromotionID'
			   , NULL, 11, '', 1, 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'PromotionReason')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 13,		2, 'PromotionReason', 'tblSTstgComboSalesFile', 'PromotionReason'
			   , NULL, 11, '', 1, 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'SalesRestrictCode')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 14,		3, 'SalesRestrictCode', 'tblSTstgComboSalesFile', 'SalesRestrictCode'
			   , NULL, 9, '', 1, 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'LinkCode')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 15,		4, 'LinkCode', 'tblSTstgComboSalesFile', 'LinkCodeValue'
			   , NULL, 9, '0', 1, 1
END

IF EXISTS (SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'LinkCode' )
BEGIN			   
	SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM [dbo].[tblSMImportFileColumnDetail] 
	Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'LinkCode' 
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'type')
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	1,	'type',	'tblSTstgComboSalesFile',	'LinkCodeType',	'', 1, 1	
	END
	
	SET @intImportFileColumnDetailId = 0
				   
END 

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'ComboDescription')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 16,		5, 'ComboDescription', 'tblSTstgComboSalesFile', 'ComboDescription'
			   , NULL, 9, '', 1, 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'ComboPrice')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 17,		6, 'ComboPrice', 'tblSTstgComboSalesFile', 'ComboPrice'
			   , NULL, 9, '', 1, 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'ComboList')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 18,		7, 'ComboList', 'tblSTstgComboSalesFile', NULL
			   , 'Header', 9, '', 1, 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'ComboItemList')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 19,		1, 'ComboItemList', 'tblSTstgComboSalesFile', NULL
			   , NULL, 18, '', 1, 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'ItemListID')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 20,		1, 'ItemListID', 'tblSTstgComboSalesFile', 'ItemListID'
			   , NULL, 19, '', 1, 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'ComboItemQuantity')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 21,		2, 'ComboItemQuantity', 'tblSTstgComboSalesFile', 'ComboItemQuantity'
			   , NULL, 19, '', 1, 1
			   
END

IF EXISTS (SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'ComboItemQuantity' )
BEGIN			   
	SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM [dbo].[tblSMImportFileColumnDetail] 
	Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'ComboItemQuantity' 
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'uom')
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	1,	'uom',	'tblSTstgComboSalesFile',	'ComboItemQuantityUOM',	'', 1, 1	
	END
	
	SET @intImportFileColumnDetailId = 0			
			   
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'ComboItemUnitPrice')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 22,		3, 'ComboItemUnitPrice', 'tblSTstgComboSalesFile', 'ComboItemUnitPrice'
			   , NULL, 19, '', 1, 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'StartDate')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 23,		8, 'StartDate', 'tblSTstgComboSalesFile', 'StartDate'
			   , NULL, 9, '', 1, 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'StartTime')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 24,		9, 'StartTime', 'tblSTstgComboSalesFile', 'StartTime'
			   , NULL, 9, '', 1, 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'StopDate')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 25,		10, 'StopDate', 'tblSTstgComboSalesFile', 'StopDate'
			   , NULL, 9, '', 1, 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'StopTime')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 26,		11, 'StopTime', 'tblSTstgComboSalesFile', 'StopTime'
			   , NULL, 9, '', 1, 1
END

IF NOT EXISTS(SELECT * FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'WeekdayAvailability' AND intLevel = 27)
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 27,		12, 'WeekdayAvailability', NULL, NULL
			   , NULL, 9, '', 1, 1
			   
END

IF EXISTS (SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'WeekdayAvailability' AND intLevel = 27 )
BEGIN			   
	SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM [dbo].[tblSMImportFileColumnDetail] 
	Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'WeekdayAvailability' AND intLevel = 27
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'avaialble')
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	1,	'avaialble',	'tblSTstgComboSalesFile',	'WeekdayAvailabilitySunday',	'', 1, 1	
	END
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'weekday')
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	2,	'weekday',	'tblSTstgComboSalesFile',	'WeekdaySunday',	'', 1, 1	
	END
	
	SET @intImportFileColumnDetailId = 0			
			   
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'WeekdayAvailability' AND intLevel = 28)
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 28,		13, 'WeekdayAvailability', NULL, NULL
			   , NULL, 9, '', 1, 1
			   
END

IF EXISTS (SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'WeekdayAvailability' AND intLevel = 28 )
BEGIN			   
	SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM [dbo].[tblSMImportFileColumnDetail] 
	Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'WeekdayAvailability' AND intLevel = 28
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'avaialble')
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	1,	'avaialble',	'tblSTstgComboSalesFile',	'WeekdayAvailabilityMonday',	'', 1, 1	
	END
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'weekday')
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	2,	'weekday',	'tblSTstgComboSalesFile',	'WeekdayMonday',	'', 1, 1	
	END
	
	SET @intImportFileColumnDetailId = 0			
			   
END


IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'WeekdayAvailability' AND intLevel = 29)
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 29,		14, 'WeekdayAvailability', NULL, NULL
			   , NULL, 9, '', 1, 1
END

IF EXISTS (SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'WeekdayAvailability' AND intLevel = 29 )
BEGIN			   
	SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM [dbo].[tblSMImportFileColumnDetail] 
	Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'WeekdayAvailability' AND intLevel = 29
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'avaialble')
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	1,	'avaialble',	'tblSTstgComboSalesFile',	'WeekdayAvailabilityTuesday',	'', 1, 1	
	END
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'weekday')
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	2,	'weekday',	'tblSTstgComboSalesFile',	'WeekdayTuesday',	'', 1, 1	
	END
	
	SET @intImportFileColumnDetailId = 0			

END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'WeekdayAvailability'  AND intLevel = 30)
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 30,		15, 'WeekdayAvailability', NULL, NULL
			   , NULL, 9, '', 1, 1
END

IF EXISTS (SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'WeekdayAvailability' AND intLevel = 30 )
BEGIN			   
	SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM [dbo].[tblSMImportFileColumnDetail] 
	Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'WeekdayAvailability' AND intLevel = 30
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'avaialble')
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	1,	'avaialble',	'tblSTstgComboSalesFile',	'WeekdayAvailabilityWednesday',	'', 1, 1	
	END
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'weekday')
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	2,	'weekday',	'tblSTstgComboSalesFile',	'WeekdayWednesday',	'', 1, 1	
	END
	
	SET @intImportFileColumnDetailId = 0			

END


IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'WeekdayAvailability' AND intLevel = 31)
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 31,		16, 'WeekdayAvailability',  NULL, NULL
			   , NULL, 9, '', 1, 1
END

IF EXISTS (SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'WeekdayAvailability' AND intLevel = 31 )
BEGIN			   
	SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM [dbo].[tblSMImportFileColumnDetail] 
	Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'WeekdayAvailability' AND intLevel = 31
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'avaialble')
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	1,	'avaialble',	'tblSTstgComboSalesFile',	'WeekdayAvailabilityThursday',	'', 1, 1	
	END
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'weekday')
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	2,	'weekday',	'tblSTstgComboSalesFile',	'WeekdayThursday',	'', 1, 1	
	END
	
	SET @intImportFileColumnDetailId = 0			

END


IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'WeekdayAvailability' AND intLevel = 32)
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 32,		17, 'WeekdayAvailability', NULL, NULL
			   , NULL, 9, '', 1, 1
END

IF EXISTS (SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'WeekdayAvailability' AND intLevel = 32 )
BEGIN			   
	SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM [dbo].[tblSMImportFileColumnDetail] 
	Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'WeekdayAvailability' AND intLevel = 32
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'avaialble')
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	1,	'avaialble',	'tblSTstgComboSalesFile',	'WeekdayAvailabilityFriday',	'', 1, 1	
	END
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'weekday')
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	2,	'weekday',	'tblSTstgComboSalesFile',	'WeekdayFriday',	'', 1, 1	
	END
	
	SET @intImportFileColumnDetailId = 0			

END


IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'WeekdayAvailability'  AND intLevel = 33)
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 33,		18, 'WeekdayAvailability',  NULL, NULL
			   , NULL, 9, '', 1, 1
END

IF EXISTS (SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'WeekdayAvailability' AND intLevel = 33 )
BEGIN			   
	SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM [dbo].[tblSMImportFileColumnDetail] 
	Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'WeekdayAvailability' AND intLevel = 33
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'avaialble')
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	1,	'avaialble',	'tblSTstgComboSalesFile',	'WeekdayAvailabilitySaturday',	'', 1, 1	
	END
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'weekday')
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	2,	'weekday',	'tblSTstgComboSalesFile',	'WeekdaySaturday',	'', 1, 1	
	END
	
	SET @intImportFileColumnDetailId = 0			

END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'Priority')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 34,		18, 'Priority', 'tblSTstgComboSalesFile', 'Priority'
			   , NULL, 9, '', 1, 1
		   
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'TransactionLimit')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 35,		19, 'TransactionLimit', 'tblSTstgComboSalesFile', 'TransactionLimit'
			   , NULL, 9, '', 1, 1
		   
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'Extension')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 36,		20, 'Extension', 'tblSTstgComboSalesFile', NULL
			   , 'Header', 9, '', 1, 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'radiant:Upsellable')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 37,		1, 'radiant:Upsellable', NULL, NULL
			   , NULL, 36, '', 1, 1
	
END

IF EXISTS (SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'radiant:Upsellable')
BEGIN			   
	SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM [dbo].[tblSMImportFileColumnDetail] 
	Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'radiant:Upsellable' 
		
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'value')
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	1,	'value',	NULL,	NULL,	'no', 1, 1	
	END
	
	SET @intImportFileColumnDetailId = 0				   
				   
END

GO




