
GO

IF NOT EXISTS (SELECT 1 FROM [tblSMImportFileHeader] WHERE strLayoutTitle = 'Promotion Item List' AND strFileType = 'XML' AND [strXMLType] = 'Outbound')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileHeader]
			   ([strLayoutTitle]
			   ,[strFileType]
			   ,[strFieldDelimiter]
			   ,[strXMLType]
			   ,[strXMLInitiater]
			   ,[ysnActive]
			   ,[intConcurrencyId])
		 VALUES
			   ('Promotion Item List'
			   ,'XML'
			   ,NULL
			   ,'Outbound'
			   ,'<?xml version="1.0" encoding="UTF-8" ?>'
			   ,1
			   ,1)
END


DECLARE @intImportFileHeaderId Int, @intImportFileColumnDetailId Int

SELECT @intImportFileHeaderId = intImportFileHeaderId FROM [dbo].[tblSMImportFileHeader]
WHERE strLayoutTitle = 'Promotion Item List' AND strFileType = 'XML' AND [strXMLType] = 'Outbound'

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'NAXML-MaintenanceRequest')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 1, NULL, 'NAXML-MaintenanceRequest', 'tblSTstgPromotionItemListSend', NULL
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
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'xmlns:xsi')
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	2,	'xmlns:xsi',	NULL,	NULL,	'http://www.w3.org/2001/XMLSchema-instance', 1, 1	
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
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'xmlns')
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	5,	'xmlns',	NULL,	NULL,	'http://www.naxml.org/POSBO/Vocabulary/2003-10-16', 1, 1	
	END
	
	SET @intImportFileColumnDetailId = 0				   
END



IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'TransmissionHeader')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 2, 1, 'TransmissionHeader', 'tblSTstgPromotionItemListSend', NULL
			   , 'Header', 1, '', 1, 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'StoreLocationID')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 3,		1, 'StoreLocationID', 'tblSTstgPromotionItemListSend', 'StoreLocationID'
			   , NULL, 2, '', 1, 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'VendorName')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 4,		2, 'VendorName', 'tblSTstgPromotionItemListSend', 'VendorName'
			   , NULL, 2, '', 1, 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'VendorModelVersion')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 5,		3, 'VendorModelVersion', 'tblSTstgPromotionItemListSend', 'VendorModelVersion'
			   , NULL, 2, '', 1, 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'ItemListMaintenance')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 6,		2, 'ItemListMaintenance', 'tblSTstgPromotionItemListSend', NULL
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
		SELECT @intImportFileColumnDetailId,	1,	'type',	'tblSTstgPromotionItemListSend',	'TableActionType',	'', 1, 1	
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
		SELECT @intImportFileColumnDetailId,	1,	'type',	'tblSTstgPromotionItemListSend',	'RecordActionType',	'', 1, 1	
	END
	
	SET @intImportFileColumnDetailId = 0
				   
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'ILTDetail')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 9,		3, 'ILTDetail', 'tblSTstgPromotionItemListSend', NULL
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
		SELECT @intImportFileColumnDetailId,	1,	'type',	'tblSTstgPromotionItemListSend',	'ILTDetailRecordActionType',	'', 1, 1	
	END
	
	SET @intImportFileColumnDetailId = 0
				   
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'ItemListID')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 11,		2, 'ItemListID', 'tblSTstgPromotionItemListSend', 'ItemListID'
			   , NULL, 9, '', 1, 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'ItemListDescription')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 12,		3, 'ItemListDescription', 'tblSTstgPromotionItemListSend', 'ItemListDescription'
			   , NULL, 9, '', 1, 1			   
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'ItemListEntry')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 13,		4, 'ItemListEntry', 'tblSTstgPromotionItemListSend', NULL
			   , NULL, 9, '', 1, 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'ItemCode')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 14,		1, 'ItemCode', 'tblSTstgPromotionItemListSend', NULL
			   , 'Header', 13, '', 1, 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'POSCodeFormat')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 15,		1, 'POSCodeFormat', NULL, NULL
			   , NULL, 14, '', 1, 1
			   
			   
	SET @intImportFileColumnDetailId = @@IDENTITY
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'format')
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	1,	'format',	'tblSTstgPromotionItemListSend',	'POSCodeFormat',	'', 1, 1	
	END
	
	SET @intImportFileColumnDetailId = 0
			   
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'POSCode')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 16,		2, 'POSCode', 'tblSTstgPromotionItemListSend', 'POSCode'
			   , NULL, 14, '', 1, 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'POSCodeModifier')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 17,		3, 'POSCodeModifier', 'tblSTstgPromotionItemListSend', 'POSCodeModifierValue'
			   , NULL, 14, '', 1, 1		   
END

IF EXISTS (SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'POSCodeModifier' )
BEGIN			   
	SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM [dbo].[tblSMImportFileColumnDetail] 
	Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'POSCodeModifier' 
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'name')
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	1,	'name',	'tblSTstgPromotionItemListSend',	'POSCodeModifierName',	'', 1, 1	
	END
	
	SET @intImportFileColumnDetailId = 0
		
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'MerchandiseCode')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 18,		2, 'MerchandiseCode', 'tblSTstgPromotionItemListSend', 'MerchandiseCode'
			   , NULL, 13, '', 1, 1		   
END

GO