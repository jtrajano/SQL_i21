

IF NOT EXISTS (SELECT 1 FROM [tblSMImportFileHeader] WHERE strLayoutTitle = 'Pricebook File' AND strFileType = 'XML' AND [strXMLType] = 'Outbound')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileHeader]
			   ([strLayoutTitle]
			   ,[strFileType]
			   ,[strFieldDelimiter]
			   ,[strXMLType]
			   ,[strXMLInitiater]
			   ,[intConcurrencyId])
		 VALUES
			   ('Pricebook File'
			   ,'XML'
			   ,NULL
			   ,'Outbound'
			   ,'<?xml version="1.0" encoding="UTF-8" ?>'
			   ,1)
END

DECLARE @intImportFileHeaderId Int, @intImportFileColumnDetailId Int

SELECT @intImportFileHeaderId = intImportFileHeaderId FROM [dbo].[tblSMImportFileHeader]
WHERE strLayoutTitle = 'Pricebook File' AND strFileType = 'XML' AND [strXMLType] = 'Outbound'

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'NAXML-MaintenanceRequest')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 1, NULL, 'NAXML-MaintenanceRequest', 'tblSTstgPricebookSendFile', NULL
			   , '', 0, '', 1
			   
	SET @intImportFileColumnDetailId = @@IDENTITY
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'xmlns:radiant')
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	1,	'xmlns:radiant',	NULL,	NULL,	'http://www.radiantsystems.com/NAXML-Extension', 1	
	END
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'xmlns:xsi')
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	2,	'xmlns:xsi',	NULL,	NULL,	'http://www.w3.org/2001/XMLSchema-instance', 1	
	END
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'version')
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	3,	'version',	NULL,	NULL,	'3.4', 1	
	END
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'xsi:schemaLocation')
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	4,	'xsi:schemaLocation',	NULL,	NULL,	'http://www.radiantsystems.com/NAXML-Extension NAXML-RadiantExtension34.xsd', 1	
	END
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'xmlns')
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	5,	'xmlns',	NULL,	NULL,	'http://www.naxml.org/POSBO/Vocabulary/2003-10-16', 1	
	END
	
	SET @intImportFileColumnDetailId = 0				   
END



IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'TransmissionHeader')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 2, 1, 'TransmissionHeader', 'tblSTstgPricebookSendFile', NULL
			   , 'Header', 1, '', 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'StoreLocationID')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 3,		1, 'StoreLocationID', 'tblSTstgPricebookSendFile', 'StoreLocationID'
			   , NULL, 2, '', 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'VendorName')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 4,		2, 'VendorName', 'tblSTstgPricebookSendFile', 'VendorName'
			   , NULL, 2, '', 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'VendorModelVersion')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 5,		3, 'VendorModelVersion', 'tblSTstgPricebookSendFile', 'VendorModelVersion'
			   , NULL, 2, '', 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'ItemMaintenance')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 6,		2, 'ItemMaintenance', 'tblSTstgPricebookSendFile', NULL
			   , 'Header', 1, '', 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'TableAction')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 7,		1, 'TableAction', NULL, NULL
			   , NULL, 6, '', 1
			   
			   
	SET @intImportFileColumnDetailId = @@IDENTITY
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'type')
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	1,	'type',	'tblSTstgPricebookSendFile',	'TableActionType',	'', 1	
	END
	
	SET @intImportFileColumnDetailId = 0
			   
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'RecordAction')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 8,		2, 'RecordAction', NULL, NULL
			   , NULL, 6, '', 1
			   
			   
	SET @intImportFileColumnDetailId = @@IDENTITY
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'type')
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	1,	'type',	'tblSTstgPricebookSendFile',	'RecordActionType',	'', 1	
	END
	
	SET @intImportFileColumnDetailId = 0
				   
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'ITTDetail')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 9,		3, 'ITTDetail', 'tblSTstgPricebookSendFile', NULL
			   , NULL, 6, '', 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'RecordAction' AND intLength = 9)
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 10,		1, 'RecordAction', NULL, NULL
			   , NULL, 9, '', 1
			   
			   
	SET @intImportFileColumnDetailId = @@IDENTITY
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'type')
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	1,	'type',	'tblSTstgPricebookSendFile',	'ITTDetailRecordActionType',	'', 1	
	END
	
	SET @intImportFileColumnDetailId = 0
				   
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'ItemCode')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 11,		2, 'ItemCode', 'tblSTstgPricebookSendFile', NULL
			   , NULL, 9, '', 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'POSCodeFormat')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 12,		1, 'POSCodeFormat', NULL, NULL
			   , NULL, 11, '', 1
			   
			   
	SET @intImportFileColumnDetailId = @@IDENTITY
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'format')
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	1,	'format',	'tblSTstgPricebookSendFile',	'POSCodeFormat',	'', 1	
	END
	
	SET @intImportFileColumnDetailId = 0
			   
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'POSCode')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 13,		2, 'POSCode', 'tblSTstgPricebookSendFile', 'POSCode'
			   , NULL, 11, '', 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'POSCodeModifier')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 14,		3, 'POSCodeModifier', 'tblSTstgPricebookSendFile', 'PosCodeModifierValue'
			   , NULL, 11, '0', 1
			   
			   
	SET @intImportFileColumnDetailId = @@IDENTITY
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'name')
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	1,	'name',	'tblSTstgPricebookSendFile',	'PosCodeModifierName',	'', 1	
	END
	
	SET @intImportFileColumnDetailId = 0
				   
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'ITTData')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 15,		3, 'ITTData', 'tblSTstgPricebookSendFile', NULL
			   , NULL, 9, '', 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'ActiveFlag')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 16,		1, 'ActiveFlag', NULL, NULL
			   , NULL, 15, '', 1
			   
			   
	SET @intImportFileColumnDetailId = @@IDENTITY
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'value')
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	1,	'value',	'tblSTstgPricebookSendFile',	'ActiveFlagValue',	'', 1	
	END
	
	SET @intImportFileColumnDetailId = 0
				   
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'MerchandiseCode')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 17,		2, 'MerchandiseCode', 'tblSTstgPricebookSendFile', 'MerchandiseCode'
			   , NULL, 15, '', 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'RegularSellPrice')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 18,		3, 'RegularSellPrice', 'tblSTstgPricebookSendFile', 'RegularSellPrice'
			   , NULL, 15, '', 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'Description')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 19,		4, 'Description', 'tblSTstgPricebookSendFile', 'Description'
			   , NULL, 15, '', 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'ItemType')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 20,		5, 'ItemType', 'tblSTstgPricebookSendFile', NULL
			   , NULL, 15, '', 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'ItemTypeCode')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 21,		1, 'ItemTypeCode', 'tblSTstgPricebookSendFile', 'ItemTypeCode'
			   , NULL, 20, '', 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'ItemTypeSubCode')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 22,		2, 'ItemTypeSubCode', 'tblSTstgPricebookSendFile', 'ItemTypeSubCode'
			   , NULL, 20, '', 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'PaymentSystemsProductCode')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 23,		6, 'PaymentSystemsProductCode', 'tblSTstgPricebookSendFile', 'PaymentSystemsProductCode'
			   , NULL, 15, '', 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'SalesRestrictCode')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 24,		7, 'SalesRestrictCode', 'tblSTstgPricebookSendFile', 'SalesRestrictCode'
			   , NULL, 15, '', 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'SellingUnits')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 25,		8, 'SellingUnits', 'tblSTstgPricebookSendFile', 'SellingUnits'
			   , NULL, 15, '', 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'TaxStrategyID')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 26,		9, 'TaxStrategyID', 'tblSTstgPricebookSendFile', 'TaxStrategyID'
			   , NULL, 15, '', 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'Extension')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 27,		4, 'Extension', 'tblSTstgPricebookSendFile', NULL
			   , NULL, 9, '', 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'radiant:ProhibitSaleLocation' AND intLength = 27)
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 28,		1, 'radiant:ProhibitSaleLocation', NULL, NULL
			   , NULL, 27, '', 1
			   
			   
	SET @intImportFileColumnDetailId = @@IDENTITY
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'type')
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	1,	'type',	'tblSTstgPricebookSendFile',	'ProhibitSaleLocationType',	'', 1	
	END
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'value')
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	2,	'value',	'tblSTstgPricebookSendFile',	'ProhibitSaleLocationValue',	'', 1	
	END
	
	SET @intImportFileColumnDetailId = 0
				   
END



