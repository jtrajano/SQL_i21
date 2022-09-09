﻿
GO

IF NOT EXISTS (SELECT 1 FROM [tblSMImportFileHeader] WHERE strLayoutTitle = 'Pricebook Mix Match' AND strFileType = 'XML' AND [strXMLType] = 'Outbound')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileHeader]
			   ([strLayoutTitle]
			   ,[strFileType]
			   ,[strFieldDelimiter]
			   ,[strXMLType]
			   ,[strXMLInitiater]
			   ,[intConcurrencyId])
		 VALUES
			   ('Pricebook Mix Match'
			   ,'XML'
			   ,NULL
			   ,'Outbound'
			   ,'<?xml version="1.0"?>'
			   ,1)
END

DECLARE @intImportFileHeaderId Int, @intImportFileColumnDetailId Int

SELECT @intImportFileHeaderId = intImportFileHeaderId FROM [dbo].[tblSMImportFileHeader]
WHERE strLayoutTitle = 'Pricebook Mix Match' AND strFileType = 'XML' AND [strXMLType] = 'Outbound'
	
DELETE FROM [dbo].[tblSMImportFileColumnDetail] WHERE intImportFileHeaderId = @intImportFileHeaderId

DELETE FROM [dbo].[tblSMImportFileColumnDetail] WHERE intImportFileHeaderId = @intImportFileHeaderId

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'NAXML-MaintenanceRequest')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 1, NULL, 'NAXML-MaintenanceRequest', 'tblSTstgMixMatchFile', NULL
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
	SELECT @intImportFileHeaderId, NULL, 2, 1, 'TransmissionHeader', 'tblSTstgMixMatchFile', NULL
			   , 'Header', 1, '', 1, 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'StoreLocationID')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 3,		1, 'StoreLocationID', 'tblSTstgMixMatchFile', 'StoreLocationID'
			   , NULL, 2, '', 1, 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'VendorName')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 4,		2, 'VendorName', 'tblSTstgMixMatchFile', 'VendorName'
			   , NULL, 2, '', 1, 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'VendorModelVersion')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 5,		3, 'VendorModelVersion', 'tblSTstgMixMatchFile', 'VendorModelVersion'
			   , NULL, 2, '', 1, 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'MixMatchMaintenance')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 6,		2, 'MixMatchMaintenance', 'tblSTstgMixMatchFile', NULL
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
		SELECT @intImportFileColumnDetailId,	1,	'type',	'tblSTstgMixMatchFile',	'TableActionType',	'', 1, 1	
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
		SELECT @intImportFileColumnDetailId,	1,	'type',	'tblSTstgMixMatchFile',	'RecordActionType',	'', 1, 1	
	END
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'confirm')
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	2,	'confirm',	NULL,	NULL,	'', 1, 1	
	END
	
	SET @intImportFileColumnDetailId = 0
				   
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'MMTDetail')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 9,		3, 'MMTDetail', 'tblSTstgMixMatchFile', NULL
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
		SELECT @intImportFileColumnDetailId,	1,	'type',	'tblSTstgMixMatchFile',	'MMTDetailRecordActionType',	'', 1, 1	
	END
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'confirm')
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	2,	'confirm',	'tblSTstgMixMatchFile',	'MMTDetailRecordActionConfirm',	'', 1, 1	
	END
	
	SET @intImportFileColumnDetailId = 0
				   
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'Promotion')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 11,		2, 'Promotion', 'tblSTstgMixMatchFile', NULL
			   , 'Header', 9, '', 1, 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'PromotionID')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 12,		1, 'PromotionID', 'tblSTstgMixMatchFile', 'PromotionID'
			   , NULL, 11, '', 1, 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'PromotionReason')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 13,		2, 'PromotionReason', 'tblSTstgMixMatchFile', 'PromotionReason'
			   , NULL, 11, '', 1, 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'MixMatchDescription')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 14,		3, 'MixMatchDescription', 'tblSTstgMixMatchFile', 'MixMatchDescription'
			   , NULL, 9, '', 1, 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'SalesRestrictCode')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 15,		4, 'SalesRestrictCode', 'tblSTstgMixMatchFile', 'SalesRestrictCode'
			   , NULL, 9, '', 1, 1
END

IF EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'MixMatchStrictHighFlag')
BEGIN
	DELETE FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'MixMatchStrictHighFlag'
END

IF EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'MixMatchStrictLowFlag')
BEGIN
	DELETE FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'MixMatchStrictLowFlag'
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'ItemListID')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 16,		5, 'ItemListID', 'tblSTstgMixMatchFile', 'ItemListID'
			   , NULL, 9, '', 1, 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'StartDate')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 17,		6, 'StartDate', 'tblSTstgMixMatchFile', 'StartDate'
			   , NULL, 9, '', 1, 1
END

IF EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'StartTime')
BEGIN
	DELETE FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'StartTime'
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'StopDate')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 18,		7, 'StopDate', 'tblSTstgMixMatchFile', 'StopDate'
			   , NULL, 9, '', 1, 1
END

IF EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'StopTime')
BEGIN
	DELETE FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'StopTime'
END

IF EXISTS(SELECT * FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'WeekdayAvailability')
BEGIN
	DELETE FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'WeekdayAvailability'
			   
END



IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'MixMatchEntry')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 19,		8, 'MixMatchEntry', 'tblSTstgMixMatchFile', NULL
			   , 'Header', 9, '', 1, 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'MixMatchUnits')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 20,		1, 'MixMatchUnits', 'tblSTstgMixMatchFile', 'MixMatchUnits'
			   , NULL, 19, '', 1, 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'MixMatchPrice')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 21,		2, 'MixMatchPrice', 'tblSTstgMixMatchFile', 'MixMatchPrice'
			   , NULL, 19, '', 1, 1
END

IF EXISTS (SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'MixMatchPrice'  )
BEGIN			   
	SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM [dbo].[tblSMImportFileColumnDetail] 
	Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'MixMatchPrice'
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'currency')
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	1,	'currency',	'tblSTstgMixMatchFile',	'MixMatchPriceCurrency',	'', 1, 1	
	END
	
	SET @intImportFileColumnDetailId = 0			
			   
END


IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'Priority')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 22,		9, 'Priority', 'tblSTstgMixMatchFile', 'Priority'
			   , NULL, 9, '', 1, 1
		   
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'Extension')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 23,		10, 'Extension', 'tblSTstgMixMatchFile', NULL
			   , 'Header', 9, '', 1, 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'radiant:DiscountExternalID')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 24,		1, 'radiant:DiscountExternalID', 'tblSTstgMixMatchFile', 'DiscountExternalID'
			   , NULL, 23, '', 1, 1
	
	--SET @intImportFileColumnDetailId = @@IDENTITY
	
	--IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'uom')
	--BEGIN	
	--	INSERT INTO [dbo].[tblSMXMLTagAttribute]
	--	SELECT @intImportFileColumnDetailId,	1,	'value',	'tblSTstgMixMatchFile',	'',	'', 1, 1	
	--END
	
	--SET @intImportFileColumnDetailId = 0				   
				   
END

GO




