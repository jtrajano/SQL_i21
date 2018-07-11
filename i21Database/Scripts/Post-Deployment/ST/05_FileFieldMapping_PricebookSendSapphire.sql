
GO

IF NOT EXISTS (SELECT 1 FROM [tblSMImportFileHeader] WHERE strLayoutTitle = 'Pricebook Send Sapphire' AND strFileType = 'XML' AND [strXMLType] = 'Outbound')
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
			   ('Pricebook Send Sapphire'
			   ,'XML'
			   ,NULL
			   ,'Outbound'
			   ,'<?xml version="1.0" ?>'
			   ,1
			   ,1)
END

DECLARE @intImportFileHeaderId Int, @intImportFileColumnDetailId Int

SELECT @intImportFileHeaderId = intImportFileHeaderId FROM [dbo].[tblSMImportFileHeader]
WHERE strLayoutTitle = 'Pricebook Send Sapphire' AND strFileType = 'XML' AND [strXMLType] = 'Outbound'

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'domain:PLUs')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 1, NULL, 'domain:PLUs', 'tblSTstgPricebookSendFile', NULL
			   , '', 0, '', 1, 1
END

IF EXISTS (SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'domain:PLUs')
BEGIN			   
	SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM [dbo].[tblSMImportFileColumnDetail] 
	Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'domain:PLUs' 
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'xmlns:xsi')
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	1,	'xmlns:xsi',	NULL,	NULL,	'http://www.w3.org/2001/XMLSchema-instance', 1, 1	
	END
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'xsi:schemaLocation')
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	2,	'xsi:schemaLocation',	NULL,	NULL,	'urn:vfi-sapphire:np.domain.2001-07-01 /SapphireVM1/xml/SapphireV1.1/vsmsPLUs.xsd', 1, 1	
	END
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'xmlns:domain')
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	3,	'xmlns:domain',	NULL,	NULL,	'urn:vfi-sapphire:np.domain.2001-07-01', 1, 1	
	END
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'page')
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	4,	'page',	NULL,	NULL,	'1', 1, 1	
	END
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'ofPages')
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	5,	'ofPages',	NULL,	NULL,	'1', 1, 1	
	END
	
	SET @intImportFileColumnDetailId = 0				   
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'domain:PLU')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 2,		1, 'domain:PLU', 'tblSTstgPricebookSendFile', NULL
			   , NULL, 1, '', 1, 1
END


IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'upc')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 3,		1, 'upc', 'tblSTstgPricebookSendFile',	'UPCValue'
			   , NULL, 2, '', 1, 1
END

IF EXISTS (SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'upc')
BEGIN			   
	SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM [dbo].[tblSMImportFileColumnDetail] 
	Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'upc' 
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'checkDigit')
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	1,	'checkDigit',	'tblSTstgPricebookSendFile',	'UPCCheckDigit',	'', 1, 1	
	END
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'source')
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	2,	'source',	'tblSTstgPricebookSendFile',	'UPCSource',	'', 1, 1	
	END
	
	SET @intImportFileColumnDetailId = 0
				   
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'upcModifier')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 4,		2, 'upcModifier', 'tblSTstgPricebookSendFile',	'PosCodeModifierValue'
			   , NULL, 2, '', 1, 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'description')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 5,		3, 'description', 'tblSTstgPricebookSendFile',	'Description'
			   , NULL, 2, '', 1, 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'department')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 6,		4, 'department', 'tblSTstgPricebookSendFile',	'MerchandiseCode'
			   , NULL, 2, '', 1, 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'fee')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 7,		5, 'fee', 'tblSTstgPricebookSendFile',	'Fee'
			   , NULL, 2, '', 1, 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'pcode')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 8,		6, 'pcode', 'tblSTstgPricebookSendFile',	'PaymentSystemsProductCode'
			   , NULL, 2, '', 1, 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'price')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 9,		7, 'price', 'tblSTstgPricebookSendFile',	'RegularSellPrice'
			   , NULL, 2, '', 1, 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'flags')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 10,	8, 'flags', 'tblSTstgPricebookSendFile', NULL
			   , 'Header', 2, '', 1, 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'domain:flag' AND intLevel = 11)
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 11,		1, 'domain:flag', NULL, NULL
			   , NULL, 10, '', 1, 1
			   
END

IF EXISTS (SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'domain:flag' AND intLevel = 11)
BEGIN			   
	SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM [dbo].[tblSMImportFileColumnDetail] 
	Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'domain:flag'  AND intLevel = 11
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'sysid' AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	1,	'sysid',	'tblSTstgPricebookSendFile',	'FlagSysId1',	'', 1, 1	
	END
	
	SET @intImportFileColumnDetailId = 0
			   
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'domain:flag' AND intLevel = 12)
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 12,		2, 'domain:flag', NULL, NULL
			   , NULL, 10, '', 1, 1
			   
END

IF EXISTS (SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'domain:flag' AND intLevel = 12)
BEGIN			   
	SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM [dbo].[tblSMImportFileColumnDetail] 
	Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'domain:flag'  AND intLevel = 12
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'sysid' AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	1,	'sysid',	'tblSTstgPricebookSendFile',	'FlagSysId2',	'', 1, 1	
	END
	
	SET @intImportFileColumnDetailId = 0
			   
END



IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'taxRates')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 13,		9, 'taxRates', 'tblSTstgPricebookSendFile', NULL
			   , 'Header', 2, '', 1, 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'domain:taxRate' AND intLevel = 14)
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 14,		1, 'domain:taxRate', NULL, NULL
			   , NULL, 13, '', 1, 1
			   
END

IF EXISTS (SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'domain:taxRate' AND intLevel = 14)
BEGIN			   
	SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM [dbo].[tblSMImportFileColumnDetail] 
	Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'domain:taxRate'  AND intLevel = 14
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'sysid' AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	1,	'sysid',	'tblSTstgPricebookSendFile',	'TaxRateSysId1',	'', 1, 1	
	END
	
	SET @intImportFileColumnDetailId = 0
			   
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'domain:taxRate' AND intLevel = 15)
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 15,		2, 'domain:taxRate', NULL, NULL
			   , NULL, 13, '', 1, 1
			   
END

IF EXISTS (SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'domain:taxRate' AND intLevel = 15)
BEGIN			   
	SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM [dbo].[tblSMImportFileColumnDetail] 
	Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'domain:taxRate'  AND intLevel = 15
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'sysid' AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	1,	'sysid',	'tblSTstgPricebookSendFile',	'TaxRateSysId2',	'', 1, 1	
	END
	
	SET @intImportFileColumnDetailId = 0
			   
END


IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'domain:taxRate' AND intLevel = 16)
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 16,		3, 'domain:taxRate', NULL, NULL
			   , NULL, 13, '', 1, 1
			   
END

IF EXISTS (SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'domain:taxRate' AND intLevel = 16)
BEGIN			   
	SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM [dbo].[tblSMImportFileColumnDetail] 
	Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'domain:taxRate'  AND intLevel = 16
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'sysid' AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	1,	'sysid',	'tblSTstgPricebookSendFile',	'TaxRateSysId3',	'', 1, 1	
	END
	
	SET @intImportFileColumnDetailId = 0
			   
END


IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'domain:taxRate' AND intLevel = 17)
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 17,		4, 'domain:taxRate', NULL, NULL
			   , NULL, 13, '', 1, 1
			   
END

IF EXISTS (SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'domain:taxRate' AND intLevel = 17)
BEGIN			   
	SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM [dbo].[tblSMImportFileColumnDetail] 
	Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'domain:taxRate'  AND intLevel = 17
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'sysid' AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	1,	'sysid',	'tblSTstgPricebookSendFile',	'TaxRateSysId4',	'', 1, 1	
	END
	
	SET @intImportFileColumnDetailId = 0
			   
END


IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'idChecks')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 18,		10, 'idChecks', 'tblSTstgPricebookSendFile', NULL
			   , 'Header', 2, '', 1, 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'domain:idCheck' AND intLevel = 19)
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 19,		1, 'domain:idCheck', NULL, NULL
			   , NULL, 18, '', 1, 1
			   
END

IF EXISTS (SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'domain:idCheck' AND intLevel = 19)
BEGIN			   
	SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM [dbo].[tblSMImportFileColumnDetail] 
	Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'domain:idCheck'  AND intLevel = 19
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'sysid' AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	1,	'sysid',	'tblSTstgPricebookSendFile',	'IdCheckSysId1',	'', 1, 1	
	END
	
	SET @intImportFileColumnDetailId = 0
			   
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'domain:idCheck' AND intLevel = 20)
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 20,		2, 'domain:idCheck', NULL, NULL
			   , NULL, 18, '', 1, 1
			   
END

IF EXISTS (SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'domain:idCheck' AND intLevel = 20)
BEGIN			   
	SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM [dbo].[tblSMImportFileColumnDetail] 
	Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'domain:idCheck'  AND intLevel = 20
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'sysid' AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	1,	'sysid',	'tblSTstgPricebookSendFile',	'IdCheckSysId2',	'', 1, 1	
	END
	
	SET @intImportFileColumnDetailId = 0
			   
END



IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'blueLaws')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 21,	11, 'blueLaws', 'tblSTstgPricebookSendFile', NULL
			   , 'Header', 2, '', 1, 1
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'domain:blueLaw' AND intLevel = 22)
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 22,	1, 'domain:blueLaw', NULL, NULL
			   , NULL, 21, '', 1, 1
			   
END

IF EXISTS (SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'domain:blueLaw' AND intLevel = 22)
BEGIN			   
	SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM [dbo].[tblSMImportFileColumnDetail] 
	Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'domain:blueLaw'  AND intLevel = 22
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'sysid' AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	1,	'sysid',	'tblSTstgPricebookSendFile',	'BlueLawSysId1',	'', 1, 1	
	END
	
	SET @intImportFileColumnDetailId = 0
			   
END

IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'domain:blueLaw' AND intLevel = 23)
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 23,		2, 'domain:blueLaw', NULL, NULL
			   , NULL, 21, '', 1, 1
			   
END

IF EXISTS (SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'domain:blueLaw' AND intLevel = 23)
BEGIN			   
	SELECT @intImportFileColumnDetailId = intImportFileColumnDetailId FROM [dbo].[tblSMImportFileColumnDetail] 
	Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'domain:blueLaw'  AND intLevel = 23
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblSMXMLTagAttribute] Where intImportFileColumnDetailId = @intImportFileColumnDetailId AND strTagAttribute = 'sysid' AND intImportFileColumnDetailId = @intImportFileColumnDetailId)
	BEGIN	
		INSERT INTO [dbo].[tblSMXMLTagAttribute]
		SELECT @intImportFileColumnDetailId,	1,	'sysid',	'tblSTstgPricebookSendFile',	'BlueLawSysId2',	'', 1, 1	
	END
	
	SET @intImportFileColumnDetailId = 0
			   
END



IF NOT EXISTS(SELECT 1 FROM [dbo].[tblSMImportFileColumnDetail] Where intImportFileHeaderId = @intImportFileHeaderId AND strXMLTag = 'SellUnit')
BEGIN
	INSERT INTO [dbo].[tblSMImportFileColumnDetail]
	SELECT @intImportFileHeaderId, NULL, 24,	12, 'SellUnit', 'tblSTstgPricebookSendFile', 'SellingUnits'
			   , NULL, 2, '', 1, 1
END

GO
