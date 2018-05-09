﻿CREATE PROCEDURE [dbo].[uspSTReportUpdateItemDataPreview]
	@xmlParam NVARCHAR(MAX) = NULL
AS

BEGIN TRY

	DECLARE @ErrMsg NVARCHAR(MAX)

	--START Handle xml Param
	DECLARE @strCompanyLocationId 	   NVARCHAR(MAX),
			@strVendorId               NVARCHAR(MAX),
			@strCategoryId             NVARCHAR(MAX),
			@Family               NVARCHAR(MAX),
			@strClassId                NVARCHAR(MAX),
			@intUpcCode                INT,
			@strDescription            NVARCHAR(250),
			@dblPriceBetween1             DECIMAL (18,6),
			@dblPriceBetween2             DECIMAL (18,6),
			@strTaxFlag1ysn               NVARCHAR(1),
			@strTaxFlag2ysn               NVARCHAR(1),
			@strTaxFlag3ysn               NVARCHAR(1),
			@strTaxFlag4ysn               NVARCHAR(1),
			@strDepositRequiredysn        NVARCHAR(1),
			@intDepositPLU                INT,
			@strQuantityRequiredysn       NVARCHAR(1),
			@strScaleItemysn              NVARCHAR(1),
			@strFoodStampableysn          NVARCHAR(1),
			@strReturnableysn             NVARCHAR(1),
			@strSaleableysn               NVARCHAR(1),
			@strID1Requiredysn            NVARCHAR(1),
			@strID2Requiredysn            NVARCHAR(1),
			@strPromotionalItemysn        NVARCHAR(1),
			@strPrePricedysn              NVARCHAR(1),
			@strActiveysn                 NVARCHAR(1),
			@strBlueLaw1ysn               NVARCHAR(1),
			@strBlueLaw2ysn               NVARCHAR(1),
			@strCountedDailyysn           NVARCHAR(1),
			@strCounted                   NVARCHAR(50),
			@strCountSerialysn            NVARCHAR(1),
			@strStickReadingysn           NVARCHAR(1),
			@intNewFamily                 INT,
			@intNewClass                  INT,
			@intNewProductCode            INT,
			@intNewCategory               INT,
			@intNewVendor                 INT,
			@intNewInventoryGroup         INT,
			@strNewCountCode              NVARCHAR(50),     
			@intNewMinAge                 INT,
			@dblNewMinVendorOrderQty      DECIMAL(18,6),
			@dblNewVendorSuggestedQty     DECIMAL(18,6),
			@dblNewMinQtyOnHand           DECIMAL(18,6),
			@intNewBinLocation            INT,
			@intNewGLPurchaseAccount      INT,
			@intNewGLSalesAccount         INT,
			--@intNewGLVarianceAccount      INT,
			@strYsnPreview                NVARCHAR(1),
			@intCurrentUserId			  INT

	IF LTRIM(RTRIM(@xmlParam)) = ''
		SET @xmlParam = NULL

	--Declare xmlParam holder
	DECLARE @temp_xml_table TABLE 
	(  
			[fieldname]		NVARCHAR(MAX),  
			condition		NVARCHAR(20),        
			[from]			NVARCHAR(MAX), 
			[to]			NVARCHAR(50),  
			[join]			NVARCHAR(10),  
			[begingroup]	NVARCHAR(50),  
			[endgroup]		NVARCHAR(50),  
			[datatype]		NVARCHAR(50) 
	)  

	DECLARE @xmlDocumentId INT

	EXEC sp_xml_preparedocument @xmlDocumentId OUTPUT ,@xmlParam

	INSERT INTO @temp_xml_table  
	SELECT	*  
	FROM	OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2)  
	WITH (  
				[fieldname]		NVARCHAR(MAX),  
				condition		NVARCHAR(20),        
				[from]			NVARCHAR(MAX), 
				[to]			NVARCHAR(50),  
				[join]			NVARCHAR(10),  
				[begingroup]	NVARCHAR(50),  
				[endgroup]		NVARCHAR(50),  
				[datatype]		NVARCHAR(50)  
	)  

	--strCompanyLocationId
	SELECT @strCompanyLocationId = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strCompanyLocationId'

	--strVendorId
	SELECT @strVendorId = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strVendorId'

	--strCategoryId
	SELECT @strCategoryId = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strCategoryId'

	--strFamilyId
	SELECT @Family = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strFamilyId'

	--strClassId
	SELECT @strClassId = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strClassId'

	--intUpcCode
	SELECT @intUpcCode = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intUpcCode'

	--strDescription
	SELECT @strDescription = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strDescription'

	--dblPriceBetween1
	SELECT @dblPriceBetween1 = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'dblPriceBetween1'

	--dblPriceBetween2
	SELECT @dblPriceBetween2 = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'dblPriceBetween2'

	--strTaxFlag1ysn
	SELECT @strTaxFlag1ysn = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strTaxFlag1ysn'

	--strTaxFlag2ysn
	SELECT @strTaxFlag2ysn = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strTaxFlag2ysn'

	--strTaxFlag3ysn
	SELECT @strTaxFlag3ysn = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strTaxFlag3ysn'

	--strTaxFlag4ysn
	SELECT @strTaxFlag4ysn = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strTaxFlag4ysn'

	--strDepositRequiredysn
	SELECT @strDepositRequiredysn = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strDepositRequiredysn'

	--intDepositPLU
	SELECT @intDepositPLU = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intDepositPLU'

	--strQuantityRequiredysn
	SELECT @strQuantityRequiredysn = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strQuantityRequiredysn'

	--strScaleItemysn
	SELECT @strScaleItemysn = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strScaleItemysn'

	--strFoodStampableysn
	SELECT @strFoodStampableysn = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strFoodStampableysn'

	--strReturnableysn
	SELECT @strReturnableysn = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strReturnableysn'

	--strSaleableysn
	SELECT @strSaleableysn = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strSaleableysn'

	--strID1Requiredysn
	SELECT @strID1Requiredysn = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strID1Requiredysn'

	--strID2Requiredysn
	SELECT @strID2Requiredysn = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strID2Requiredysn'

	--strPromotionalItemysn
	SELECT @strPromotionalItemysn = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strPromotionalItemysn'

	--strPrePricedysn
	SELECT @strPrePricedysn = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strPrePricedysn'

	--strActiveysn
	SELECT @strActiveysn = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strActiveysn'

	--strBlueLaw1ysn
	SELECT @strBlueLaw1ysn = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strBlueLaw1ysn'

	--strBlueLaw2ysn 
	SELECT @strBlueLaw2ysn = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strBlueLaw2ysn'

	--strCountedDailyysn 
	SELECT @strCountedDailyysn = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strCountedDailyysn'

	--strCounted 
	SELECT @strCounted = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strCounted'

	--strCountSerialysn 
	SELECT @strCountSerialysn = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strCountSerialysn'

	--strStickReadingysn 
	SELECT @strStickReadingysn = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strStickReadingysn'

	--intNewFamily 
	SELECT @intNewFamily = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intNewFamily'

	--intNewClass 
	SELECT @intNewClass = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intNewClass'

	--intNewProductCode 
	SELECT @intNewProductCode = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intNewProductCode'

	--intNewCategory 
	SELECT @intNewCategory = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intNewCategory'

	--intNewVendor 
	SELECT @intNewVendor = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intNewVendor'

	--intNewInventoryGroup 
	SELECT @intNewInventoryGroup = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intNewInventoryGroup'

	--strNewCountCode 
	SELECT @strNewCountCode = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strNewCountCode'

	--intNewMinAge 
	SELECT @intNewMinAge = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intNewMinAge'

	--dblNewMinVendorOrderQty 
	SELECT @dblNewMinVendorOrderQty = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'dblNewMinVendorOrderQty'

	--dblNewVendorSuggestedQty 
	SELECT @dblNewVendorSuggestedQty = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'dblNewVendorSuggestedQty'

	--dblNewMinQtyOnHand 
	SELECT @dblNewMinQtyOnHand = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'dblNewMinQtyOnHand'

	--intNewBinLocation 
	SELECT @intNewBinLocation = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intNewBinLocation'

	--intNewGLPurchaseAccount 
	SELECT @intNewGLPurchaseAccount = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intNewGLPurchaseAccount'

	--intNewGLSalesAccount 
	SELECT @intNewGLSalesAccount = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intNewGLSalesAccount'

	----intNewGLVarianceAccount 
	--SELECT @intNewGLVarianceAccount = [from]
	--FROM @temp_xml_table
	--WHERE [fieldname] = 'intNewGLVarianceAccount'

	--strYsnPreview 
	SELECT @strYsnPreview = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strYsnPreview'

	--@intCurrentUserId
	SELECT @intCurrentUserId = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intCurrentUserId'





	DECLARE @FamilyId NVARCHAR(250)
	DECLARE @strClassIdId  NVARCHAR(250)
	DECLARE @ProductCode NVARCHAR(250)
	DECLARE @strVendorIdId NVARCHAR(250)
	DECLARE @NewDepositPluId NVARCHAR(250)
	DECLARE @NewInventoryCountGroupId NVARCHAR(250)
	
	DECLARE @UpdateCount INT
	SET @UpdateCount = 0



	--============================================================
	-- AUDIT LOGS
	DECLARE @ParentTableAuditLog NVARCHAR(MAX)
	SET @ParentTableAuditLog = ''

	DECLARE @ChildTableAuditLog NVARCHAR(MAX)
	SET @ChildTableAuditLog = ''

	DECLARE @JsonStringAuditLog NVARCHAR(MAX)
	SET @JsonStringAuditLog = ''

	DECLARE @checkComma bit
	--============================================================

	--Declare temp01 table holder
	DECLARE @tblTempOne TABLE 
	(
		strLocation NVARCHAR(250)
		, strUpc NVARCHAR(50)
		, strItemDescription NVARCHAR(250)
		, strChangeDescription NVARCHAR(100)
		, strOldData NVARCHAR(MAX)
		, strNewData NVARCHAR(MAX)
		, intParentId INT
		, intChildId INT
	)

	--Declare temp02 table holder (w/ distinct)
	DECLARE @tblTempTwo TABLE 
	(
		strUpc NVARCHAR(50)
		, strItemDescription NVARCHAR(250)
		, strChangeDescription NVARCHAR(100)
		, strOldData NVARCHAR(MAX)
		, strNewData NVARCHAR(MAX)
		, intParentId INT
		, intChildId INT
	)

	--Declare @tblTempItemGLAccount table holder
	DECLARE @tblTempItemGLAccount TABLE 
	(
		strLocation NVARCHAR(250)
		, strUpc NVARCHAR(50)
		, strItemDescription NVARCHAR(250)
		, strChangeDescription NVARCHAR(100)
		, strOldData NVARCHAR(MAX)
		, strNewData NVARCHAR(MAX)
		, intParentId INT
		, intChildId INT
	)

	--Declare ParentId holder
	DECLARE @tblId TABLE 
	(
		intId INT
	)

	--=======================================================
	--Use in while loop
	DECLARE @RowCountMax INT
	SET @RowCountMax = 0

	DECLARE @RowCountMin INT
	SET @RowCountMin = 0

	DECLARE @strChangeDescription NVARCHAR(100)
	SET @strChangeDescription = ''

	DECLARE @strOldData NVARCHAR(100)
	SET @strOldData = ''

	DECLARE @strNewData NVARCHAR(100)
	SET @strNewData = ''

	DECLARE @intParentId INT
	SET @intParentId = 0

	DECLARE @intChildId INT
	SET @intChildId = 0
	--=======================================================




	DECLARE @CompanyCurrencyDecimal NVARCHAR(1)
	SET @CompanyCurrencyDecimal = 0
	SELECT @CompanyCurrencyDecimal = intCurrencyDecimal from tblSMCompanyPreference

	DECLARE @intAccountCategoryId INT
	DECLARE @strAccountCategory NVARCHAR(100)

	DECLARE @SqlQuery1 as NVARCHAR(MAX)

	  --PRINT '@strTaxFlag1ysn'
	 -----------------------------------Handle Dynamic Query 1
	 IF (@strTaxFlag1ysn IS NOT NULL)
	 BEGIN
		 --IF (@strDepositRequiredysn IS NOT NULL)
		 --BEGIN
		 --END
		 SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
				(
					'Tax Flag1'
					, 'CASE WHEN IL.ysnTaxFlag1 = 0 THEN ''No'' ELSE ''Yes'' END'
					, 'CASE WHEN ' + CAST(@strTaxFlag1ysn AS NVARCHAR(50)) + ' = 0 THEN ''No'' ELSE ''Yes'' END'
					, @strCompanyLocationId
					, @strVendorId
					, @strCategoryId
					, @Family
					, @strClassId
					, @intUpcCode
					, @strDescription
					, @dblPriceBetween1
					, @dblPriceBetween2
					, 'I.intItemId'
					, 'IL.intItemLocationId' 
				)

			INSERT @tblTempOne
			EXEC (@SqlQuery1) 
	 END 


	 --PRINT '@strTaxFlag2ysn'
	 -----------------------------------Handle Dynamic Query 2
	 IF (@strTaxFlag2ysn IS NOT NULL)
	 BEGIN
		 --IF (@strDepositRequiredysn IS NOT NULL)
		 --BEGIN
		 --END
		 SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
				(
					'Tax Flag2'
					, 'CASE WHEN IL.ysnTaxFlag2 = 0 THEN ''No'' ELSE ''Yes'' END'
					, 'CASE WHEN ' + CAST(@strTaxFlag2ysn AS NVARCHAR(50)) + ' = 0 THEN ''No'' ELSE ''Yes'' END'
					, @strCompanyLocationId
					, @strVendorId
					, @strCategoryId
					, @Family
					, @strClassId
					, @intUpcCode
					, @strDescription
					, @dblPriceBetween1
					, @dblPriceBetween2
					, 'I.intItemId'
					, 'IL.intItemLocationId'
				)

			INSERT @tblTempOne
			EXEC (@SqlQuery1) 
	 END 


	 --PRINT '@strTaxFlag3ysn'
	 -----------------------------------Handle Dynamic Query 3
	 IF (@strTaxFlag3ysn IS NOT NULL)
	 BEGIN
		 --IF (@strDepositRequiredysn IS NOT NULL)
		 --BEGIN
		 --END
		 SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
				(
					'Tax Flag3'
					, 'CASE WHEN IL.ysnTaxFlag3 = 0 THEN ''No'' ELSE ''Yes'' END'
					, 'CASE WHEN ' + CAST(@strTaxFlag3ysn AS NVARCHAR(50)) + ' = 0 THEN ''No'' ELSE ''Yes'' END'
					, @strCompanyLocationId
					, @strVendorId
					, @strCategoryId
					, @Family
					, @strClassId
					, @intUpcCode
					, @strDescription
					, @dblPriceBetween1
					, @dblPriceBetween2
					, 'I.intItemId'
					, 'IL.intItemLocationId'
				)

			INSERT @tblTempOne
			EXEC (@SqlQuery1) 
	 END 


	 --PRINT '@strTaxFlag4ysn'
	 -----------------------------------Handle Dynamic Query 4
	 IF (@strTaxFlag4ysn IS NOT NULL)
	 BEGIN
		 --IF (@strDepositRequiredysn IS NOT NULL)
		 --BEGIN
		 --END  
		 SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
				(
					'Tax Flag4'
					, 'CASE WHEN IL.ysnTaxFlag4 = 0 THEN ''No'' ELSE ''Yes'' END'
					, 'CASE WHEN ' + CAST(@strTaxFlag4ysn AS NVARCHAR(50)) + ' = 0 THEN ''No'' ELSE ''Yes'' END'
					, @strCompanyLocationId
					, @strVendorId
					, @strCategoryId
					, @Family
					, @strClassId
					, @intUpcCode
					, @strDescription
					, @dblPriceBetween1
					, @dblPriceBetween2
					, 'I.intItemId'
					, 'IL.intItemLocationId'
				)

			INSERT @tblTempOne
			EXEC (@SqlQuery1) 
	 END


	 --PRINT '@strDepositRequiredysn'
	 -----------------------------------Handle Dynamic Query 5
	 IF (@strDepositRequiredysn IS NOT NULL)
	 BEGIN
		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				'Deposit Required'
				, 'CASE WHEN IL.ysnDepositRequired = 0 THEN ''No'' ELSE ''Yes'' END'
				, 'CASE WHEN ' + CAST(@strDepositRequiredysn AS NVARCHAR(50)) + ' = 0 THEN ''No'' ELSE ''Yes'' END'
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @Family
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
				, 'I.intItemId'
				, 'IL.intItemLocationId'
			)

		INSERT @tblTempOne
		EXEC (@SqlQuery1) 
	 END 


	 --PRINT '@intDepositPLU'
	 -----------------------------------Handle Dynamic Query 6
	 IF (@intDepositPLU IS NOT NULL)
	 BEGIN

			SELECT @NewDepositPluId = strUpcCode from tblICItemUOM where intItemUOMId = @intDepositPLU

		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				'Deposit PLU'
				, '(select strUpcCode from tblICItemUOM where intItemUOMId = IL.intDepositPLUId)'
				, 'CAST(''' + CAST(@NewDepositPluId AS NVARCHAR(50)) + ''' AS NVARCHAR(50))'
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @Family
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
				, 'I.intItemId'
				, 'IL.intItemLocationId'
			)

		INSERT @tblTempOne
		EXEC (@SqlQuery1) 
	 END 


	 --PRINT '@strQuantityRequiredysn'
	 -----------------------------------Handle Dynamic Query 7
	 IF (@strQuantityRequiredysn IS NOT NULL)
	 BEGIN
		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				'Quantity Required'
				, 'CASE WHEN IL.ysnQuantityRequired = 0 THEN ''No'' ELSE ''Yes'' END'
				, 'CASE WHEN ' + CAST(@strQuantityRequiredysn AS NVARCHAR(50)) + ' = 0 THEN ''No'' ELSE ''Yes'' END'
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @Family
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
				, 'I.intItemId'
				, 'IL.intItemLocationId'
			)

		INSERT @tblTempOne
		EXEC (@SqlQuery1) 
	 END 


	 --PRINT 'strScaleItemysn'
	 -----------------------------------Handle Dynamic Query 8
	 IF (@strScaleItemysn IS NOT NULL)
	 BEGIN
		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				'Scale Item'
				, 'CASE WHEN IL.ysnScaleItem = 0 THEN ''No'' ELSE ''Yes'' END'
				, 'CASE WHEN ' + CAST(@strScaleItemysn AS NVARCHAR(50)) + ' = 0 THEN ''No'' ELSE ''Yes'' END'
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @Family
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
				, 'I.intItemId'
				, 'IL.intItemLocationId'
			)

		INSERT @tblTempOne
		EXEC (@SqlQuery1) 
	 END 


	 --PRINT '@strFoodStampableysn'
	 -----------------------------------Handle Dynamic Query 9
	 IF (@strFoodStampableysn IS NOT NULL)
	 BEGIN
		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				'Food Stampable'
				, 'CASE WHEN IL.ysnFoodStampable = 0 THEN ''No'' ELSE ''Yes'' END'
				, 'CASE WHEN ' + CAST(@strFoodStampableysn AS NVARCHAR(50)) + ' = 0 THEN ''No'' ELSE ''Yes'' END'
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @Family
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
				, 'I.intItemId'
				, 'IL.intItemLocationId'
			)

		INSERT @tblTempOne
		EXEC (@SqlQuery1) 
	 END 


	 --PRINT '@strReturnableysn'
	 -----------------------------------Handle Dynamic Query 10
	 IF (@strReturnableysn IS NOT NULL)
	 BEGIN
		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				'Returnable'
				, 'CASE WHEN IL.ysnReturnable = 0 THEN ''No'' ELSE ''Yes'' END'
				, 'CASE WHEN ' + CAST(@strReturnableysn AS NVARCHAR(50)) + ' = 0 THEN ''No'' ELSE ''Yes'' END'
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @Family
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
				, 'I.intItemId'
				, 'IL.intItemLocationId'
			)

		INSERT @tblTempOne
		EXEC (@SqlQuery1) 
	 END 


	 --PRINT '@strSaleableysn'
	 -----------------------------------Handle Dynamic Query 11
	 IF (@strSaleableysn IS NOT NULL)
	 BEGIN
		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				'Saleable'
				, 'CASE WHEN IL.ysnSaleable = 0 THEN ''No'' ELSE ''Yes'' END'
				, 'CASE WHEN ' + CAST(@strSaleableysn AS NVARCHAR(50)) + ' = 0 THEN ''No'' ELSE ''Yes'' END'
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @Family
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
				, 'I.intItemId'
				, 'IL.intItemLocationId'
			)

		INSERT @tblTempOne
		EXEC (@SqlQuery1) 
	 END 


	 --PRINT '@strID1Requiredysn'
	 -----------------------------------Handle Dynamic Query 12
	 IF (@strID1Requiredysn IS NOT NULL)
	 BEGIN
		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				'Liquor Id Required'
				, 'CASE WHEN IL.ysnIdRequiredLiquor = 0 THEN ''No'' ELSE ''Yes'' END'
				, 'CASE WHEN ' + CAST(@strID1Requiredysn AS NVARCHAR(50)) + ' = 0 THEN ''No'' ELSE ''Yes'' END'
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @Family
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
				, 'I.intItemId'
				, 'IL.intItemLocationId'
			)

		INSERT @tblTempOne
		EXEC (@SqlQuery1) 
	 END 


	 --PRINT '@strID2Requiredysn'
	 -----------------------------------Handle Dynamic Query 13
	 IF (@strID2Requiredysn IS NOT NULL)
	 BEGIN

		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				'Cigarette Id Required'
				, 'CASE WHEN IL.ysnIdRequiredCigarette = 0 THEN ''No'' ELSE ''Yes'' END'
				, 'CASE WHEN ' + CAST(@strID2Requiredysn AS NVARCHAR(50)) + ' = 0 THEN ''No'' ELSE ''Yes'' END'
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @Family
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
				, 'I.intItemId'
				, 'IL.intItemLocationId'
			)

		INSERT @tblTempOne
		EXEC (@SqlQuery1) 
	 END 


	 --PRINT '@strPromotionalItemysn'
	 -----------------------------------Handle Dynamic Query 14
	 IF (@strPromotionalItemysn IS NOT NULL)
	 BEGIN

		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				'Promotional Item'
				, 'CASE WHEN IL.ysnPromotionalItem = 0 THEN ''No'' ELSE ''Yes'' END'
				, 'CASE WHEN ' + CAST(@strPromotionalItemysn AS NVARCHAR(50)) + ' = 0 THEN ''No'' ELSE ''Yes'' END'
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @Family
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
				, 'I.intItemId'
				, 'IL.intItemLocationId'
			)

		INSERT @tblTempOne
		EXEC (@SqlQuery1) 
	 END 


	 --PRINT '@strPrePricedysn'
	 -----------------------------------Handle Dynamic Query 15
	 IF (@strPrePricedysn IS NOT NULL)
	 BEGIN

		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				'Pre Priced'
				, 'CASE WHEN IL.ysnPrePriced = 0 THEN ''No'' ELSE ''Yes'' END'
				, 'CASE WHEN ' + CAST(@strPrePricedysn AS NVARCHAR(50)) + ' = 0 THEN ''No'' ELSE ''Yes'' END'
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @Family
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
				, 'I.intItemId'
				, 'IL.intItemLocationId'
			)

		INSERT @tblTempOne
		EXEC (@SqlQuery1) 
	 END 


	 --PRINT '@strBlueLaw1ysn'
	 -----------------------------------Handle Dynamic Query 16
	 IF (@strBlueLaw1ysn IS NOT NULL)
	 BEGIN

		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				'Blue Law1'
				, 'CASE WHEN IL.ysnApplyBlueLaw1 = 0 THEN ''No'' ELSE ''Yes'' END'
				, 'CASE WHEN ' + CAST(@strBlueLaw1ysn AS NVARCHAR(50)) + ' = 0 THEN ''No'' ELSE ''Yes'' END'
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @Family
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
				, 'I.intItemId'
				, 'IL.intItemLocationId'
			)

		INSERT @tblTempOne
		EXEC (@SqlQuery1) 
	 END 


	 --PRINT '@strBlueLaw2ysn'
	 -----------------------------------Handle Dynamic Query 17
	 IF (@strBlueLaw2ysn IS NOT NULL)
	 BEGIN

		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				'Blue Law2'
				, 'CASE WHEN IL.ysnApplyBlueLaw2 = 0 THEN ''No'' ELSE ''Yes'' END'
				, 'CASE WHEN ' + CAST(@strBlueLaw2ysn AS NVARCHAR(50)) + ' = 0 THEN ''No'' ELSE ''Yes'' END'
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @Family
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
				, 'I.intItemId'
				, 'IL.intItemLocationId'
			)

		INSERT @tblTempOne
		EXEC (@SqlQuery1) 
	 END 


	 --PRINT '@strCountedDailyysn'
	 -----------------------------------Handle Dynamic Query 18
	 IF (@strCountedDailyysn IS NOT NULL)
	 BEGIN

		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				'Counted Daily'
				, 'CASE WHEN IL.ysnCountedDaily = 0 THEN ''No'' ELSE ''Yes'' END'
				, 'CASE WHEN ' + CAST(@strCountedDailyysn AS NVARCHAR(50)) + ' = 0 THEN ''No'' ELSE ''Yes'' END'
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @Family
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
				, 'I.intItemId'
				, 'IL.intItemLocationId'
			)

		INSERT @tblTempOne
		EXEC (@SqlQuery1) 
	 END 


	 --PRINT '@strCounted'
	 -----------------------------------Handle Dynamic Query 19
	 IF (@strCounted IS NOT NULL)
	 BEGIN

		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				'Counted'
				, 'IL.strCounted'
				, 'CAST(''' + CAST(@strCounted AS NVARCHAR(50)) + ''' AS NVARCHAR(250))'
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @Family
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
				, 'I.intItemId'
				, 'IL.intItemLocationId'
			)

		INSERT @tblTempOne
		EXEC (@SqlQuery1) 
	 END 


	 --PRINT '@strCountSerialysn'
	 -----------------------------------Handle Dynamic Query 20
	 IF (@strCountSerialysn IS NOT NULL)
	 BEGIN

		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				'Count By Serial No'
				, 'CASE WHEN IL.ysnCountBySINo = 0 THEN ''No'' ELSE ''Yes'' END'
				, 'CASE WHEN ' + CAST(@strCountSerialysn AS NVARCHAR(50)) + ' = 0 THEN ''No'' ELSE ''Yes'' END'
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @Family
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
				, 'I.intItemId'
				, 'IL.intItemLocationId'
			)

		INSERT @tblTempOne
		EXEC (@SqlQuery1) 
	 END 


	 --PRINT '@intNewFamily'
	 -----------------------------------Handle Dynamic Query 21
	 IF (@intNewFamily IS NOT NULL)
	 BEGIN

		SELECT @FamilyId = strSubcategoryId FROM tblSTSubcategory WHERE intSubcategoryId = @intNewFamily

		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				'Family'
				, '(SELECT strSubcategoryId FROM tblSTSubcategory WHERE intSubcategoryId = IL.intFamilyId)'
				, 'CAST(''' + CAST(@FamilyId AS NVARCHAR(50)) + ''' AS NVARCHAR(250))'
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @Family
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
				, 'I.intItemId'
				, 'IL.intItemLocationId'
			)

		INSERT @tblTempOne
		EXEC (@SqlQuery1) 
	 END 


	 --PRINT '@intNewClass'
	 -----------------------------------Handle Dynamic Query 22
	 IF (@intNewClass IS NOT NULL)
	 BEGIN

		SELECT @strClassIdId = strSubcategoryId from tblSTSubcategory where intSubcategoryId = @intNewClass

		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				'Class'
				, '(SELECT strSubcategoryId FROM tblSTSubcategory WHERE intSubcategoryId = IL.intClassId )'
				, 'CAST(''' + CAST(@strClassIdId AS NVARCHAR(50)) + ''' AS NVARCHAR(250))'
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @Family
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
				, 'I.intItemId'
				, 'IL.intItemLocationId'
			)

		INSERT @tblTempOne
		EXEC (@SqlQuery1) 
	 END 


	 --PRINT '@intNewProductCode'
	 -----------------------------------Handle Dynamic Query 23
	 IF (@intNewProductCode IS NOT NULL)
	 BEGIN

		SELECT @ProductCode = strRegProdCode from tblSTSubcategoryRegProd where intRegProdId = @intNewProductCode

		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				'Product Code'
				, '( select strRegProdCode from tblSTSubcategoryRegProd where intRegProdId = IL.intProductCodeId )'
				, 'CAST(''' + CAST(@ProductCode AS NVARCHAR(50)) + ''' AS NVARCHAR(250))'
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @Family
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
				, 'I.intItemId'
				, 'IL.intItemLocationId'
			)

		INSERT @tblTempOne
		EXEC (@SqlQuery1) 
	 END 


	 --PRINT '@intNewVendor'
	 -----------------------------------Handle Dynamic Query 24
	 IF (@intNewVendor IS NOT NULL)
	 BEGIN

		SELECT @strVendorIdId = strName from tblEMEntity where intEntityId = @intNewVendor

		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				'Vendor'
				, '( select strName from tblEMEntity where intEntityId = IL.intVendorId )'
				, 'CAST(''' + CAST(@strVendorIdId AS NVARCHAR(50)) + ''' AS NVARCHAR(50))'
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @Family
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
				, 'I.intItemId'
				, 'IL.intItemLocationId'
			)

		INSERT @tblTempOne
		EXEC (@SqlQuery1) 
	 END 


	 --PRINT '@intNewMinAge'
	 -----------------------------------Handle Dynamic Query 25
	 IF (@intNewMinAge IS NOT NULL)
	 BEGIN

		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				'Minimum Age'
				, 'IL.intMinimumAge'
				, 'CAST(' + CAST(@intNewMinAge AS NVARCHAR(50)) + ' AS NVARCHAR(250))'
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @Family
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
				, 'I.intItemId'
				, 'IL.intItemLocationId'
			)

		INSERT @tblTempOne
		EXEC (@SqlQuery1) 
	 END


	 --PRINT '@dblNewMinVendorOrderQty'
	 -----------------------------------Handle Dynamic Query 26
	 IF (@dblNewMinVendorOrderQty IS NOT NULL)
	 BEGIN

		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				'Vendor Minimum Order Qty'
				, 'IL.dblMinOrder'
				, 'CAST(' + CAST(@dblNewMinVendorOrderQty AS NVARCHAR(50)) + ' AS NVARCHAR(250))'
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @Family
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
				, 'I.intItemId'
				, 'IL.intItemLocationId'
			)

		INSERT @tblTempOne
		EXEC (@SqlQuery1) 
	 END


	 --PRINT '@dblNewVendorSuggestedQty'
	 -----------------------------------Handle Dynamic Query 27
	 IF (@dblNewVendorSuggestedQty IS NOT NULL)
	 BEGIN

		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				'Vendor Suggested Qty'
				, 'IL.dblSuggestedQty'
				, 'CAST(' + CAST(@dblNewVendorSuggestedQty AS NVARCHAR(50)) + ' AS NVARCHAR(250))'
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @Family
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
				, 'I.intItemId'
				, 'IL.intItemLocationId'
			)

		INSERT @tblTempOne
		EXEC (@SqlQuery1) 
	 END


	 --PRINT '@dblNewMinQtyOnHand'
	 -----------------------------------Handle Dynamic Query 28
	 IF (@dblNewMinQtyOnHand IS NOT NULL)
	 BEGIN
		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				'Min Qty On Hand'
				, 'IL.dblReorderPoint'
				, 'CAST(' + CAST(@dblNewMinQtyOnHand AS NVARCHAR(50)) + ' AS NVARCHAR(250))'
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @Family
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
				, 'I.intItemId'
				, 'IL.intItemLocationId'
			)

		INSERT @tblTempOne
		EXEC (@SqlQuery1) 
	 END


	 --PRINT '@intNewInventoryGroup'
	 -----------------------------------Handle Dynamic Query 29
	 IF (@intNewInventoryGroup IS NOT NULL)
	 BEGIN

		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				'Inventory Group'
				, '( SELECT strCountGroup FROM tblICCountGroup WHERE intCountGroupId = IL.intCountGroupId )'
				, 'CAST(' + CAST(@intNewInventoryGroup AS NVARCHAR(50)) + ' AS NVARCHAR(250))'
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @Family
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
				, 'I.intItemId'
				, 'IL.intItemLocationId'
			)

		INSERT @tblTempOne
		EXEC (@SqlQuery1) 
	 END


	 --PRINT '@strNewCountCode'
	 -----------------------------------Handle Dynamic Query 30
	 IF (@strNewCountCode IS NOT NULL)
	 BEGIN

		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				'Count Code'
				, 'I.strCountCode'
				, 'CAST(''' + CAST(@strNewCountCode AS NVARCHAR(50)) + ''' AS NVARCHAR(250))'
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @Family
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
				, 'I.intItemId'
				, 'IL.intItemLocationId'
			)

		INSERT @tblTempOne
		EXEC (@SqlQuery1) 
	 END


	 --PRINT '@intNewCategory'
	 -----------------------------------Handle Dynamic Query 31
	 IF (@intNewCategory IS NOT NULL)
	 BEGIN
		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				'Category'
				, '(select strCategoryCode from tblICCategory where intCategoryId = I.intCategoryId)'
				, '(select strCategoryCode from tblICCategory where intCategoryId = ' + CAST(@intNewCategory AS NVARCHAR(50)) + ')'
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @Family
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
				, 'I.intItemId'
				, 'I.intItemId'
			)

		INSERT @tblTempOne
		EXEC (@SqlQuery1) 
	 END


	 --PRINT '@intNewBinLocation'
	 -----------------------------------Handle Dynamic Query 32
	 IF (@intNewBinLocation IS NOT NULL)
	 BEGIN

		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				'Storage Location'
				, '( select strName from tblICStorageLocation where intStorageLocationId = IL.intStorageLocationId )'
				, '( select strName from tblICStorageLocation where intStorageLocationId =  CAST( ' +  LTRIM(CAST(@intNewBinLocation AS NVARCHAR(50))) +' AS INT))'
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @Family
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
				, 'I.intItemId'
				, 'IL.intItemLocationId'
			)

		INSERT @tblTempOne
		EXEC (@SqlQuery1) 
	 END


	 --PRINT '@intNewGLPurchaseAccount'
	 -----------------------------------Handle Dynamic Query 33
	 IF (@intNewGLPurchaseAccount IS NOT NULL)
		BEGIN
			--, '''( select strAccountId from tblGLAccount where intAccountId =  CAST( ' +  LTRIM(@intNewGLPurchaseAccount) +' AS INT))'''
		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				'Cost of Goods Sold Account'
				, '( select strAccountId from tblGLAccount where intAccountId = IA.intAccountId )'
				, '( select strAccountId from tblGLAccount where intAccountId =  CAST( ' +  CAST(LTRIM(@intNewGLPurchaseAccount) AS NVARCHAR(50)) +' AS INT))'
				--, (select strAccountId from tblGLAccount where intAccountId = @intNewGLPurchaseAccount)
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @Family
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
				, 'I.intItemId'
				, 'IA.intItemAccountId'
			)

			INSERT @tblTempOne
			EXEC (@SqlQuery1) 

			-- =====================================================================================================
			-- START Check if 'Cost of Goods Exist on selected Item records
			INSERT @tblTempItemGLAccount
			EXEC (@SqlQuery1) 

			IF NOT EXISTS(SELECT * FROM @tblTempItemGLAccount WHERE strChangeDescription = 'Cost of Goods Sold Account')
			BEGIN
				SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
					(
						'Add New Cost of Goods Sold Account'
						, ''''''
						, '( select strAccountId from tblGLAccount where intAccountId =  CAST( ' +  CAST(LTRIM(@intNewGLPurchaseAccount) AS NVARCHAR(50)) +' AS INT))'
						, @strCompanyLocationId
						, @strVendorId
						, @strCategoryId
						, @Family
						, @strClassId
						, @intUpcCode
						, @strDescription
						, @dblPriceBetween1
						, @dblPriceBetween2
						, 'I.intItemId'
						, 'IA.intItemAccountId'
					)

				-- Insert here for getting intItemId's
				INSERT @tblTempOne
				EXEC (@SqlQuery1) 
			END
			-- END Check if 'Cost of Goods Exist on selected Item records
			-- =====================================================================================================
		
	 END


	 --PRINT '@intNewGLSalesAccount'
	 -----------------------------------Handle Dynamic Query 34
	 IF (@intNewGLSalesAccount IS NOT NULL)
	 BEGIN

		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				'Sales Account'
				, '( select strAccountId from tblGLAccount where intAccountId = IA.intAccountId )'
				, '( select strAccountId from tblGLAccount where intAccountId =  CAST( ' +  CAST(LTRIM(@intNewGLSalesAccount) AS NVARCHAR(50)) +' AS INT))'
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @Family
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
				, 'I.intItemId'
				, 'IA.intItemAccountId'
			)

		INSERT @tblTempOne
		EXEC (@SqlQuery1)

		-- =====================================================================================================
		-- START Check if 'Sales Account Exist on selected Item records
		INSERT @tblTempItemGLAccount
		EXEC (@SqlQuery1) 

		IF NOT EXISTS(SELECT * FROM @tblTempItemGLAccount WHERE strChangeDescription = 'Sales Account')
		BEGIN
			SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
				(
					'Add New Sales Account'
					, ''''''
					, '( select strAccountId from tblGLAccount where intAccountId =  CAST( ' +  CAST(LTRIM(@intNewGLSalesAccount) AS NVARCHAR(50)) +' AS INT))'
					, @strCompanyLocationId
					, @strVendorId
					, @strCategoryId
					, @Family
					, @strClassId
					, @intUpcCode
					, @strDescription
					, @dblPriceBetween1
					, @dblPriceBetween2
					, 'I.intItemId'
					, 'IA.intItemAccountId'
				)

			-- Insert here for getting intItemId's
			INSERT @tblTempOne
			EXEC (@SqlQuery1) 
		END
		-- END Check if 'Sales Account Exist on selected Item records
		-- =====================================================================================================
	 END


	 ----PRINT '@intNewGLVarianceAccount'
	 -------------------------------------Handle Dynamic Query 35
	 --IF (@intNewGLVarianceAccount IS NOT NULL)
	 --BEGIN

		--    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
		--	(
		--		'Variance Account'
		--		, '( select strAccountId from tblGLAccount where intAccountId = IA.intAccountId )'
		--		, '( select strAccountId from tblGLAccount where intAccountId =  CAST( ' +  CAST(LTRIM(@intNewGLVarianceAccount) AS NVARCHAR(50)) +' AS INT))'
		--		, @strCompanyLocationId
		--		, @strVendorId
		--		, @strCategoryId
		--		, @Family
		--		, @strClassId
		--		, @intUpcCode
		--		, @strDescription
		--		, @dblPriceBetween1
		--		, @dblPriceBetween2
		--		, 'I.intItemId'
		--		, 'IA.intItemAccountId'
		--	)

		--INSERT @tblTempOne
		--EXEC (@SqlQuery1) 
	 --END




	 DELETE FROM @tblTempOne WHERE strOldData = strNewData

	 SELECT @UpdateCount = count(*) from @tblTempOne WHERE strOldData != strNewData

	  
	 ---Update Logic-------
--PRINT 'Update Logic 01'		      
IF((@strYsnPreview != 'Y') AND (@UpdateCount > 0))
   BEGIN

     IF ((@strTaxFlag1ysn IS NOT NULL) OR (@strTaxFlag2ysn IS NOT NULL)
			   OR (@strTaxFlag3ysn IS NOT NULL) OR (@strTaxFlag4ysn IS NOT NULL) 
			   OR (@strDepositRequiredysn IS NOT NULL) OR (@intDepositPLU IS NOT NULL)
			   OR (@strQuantityRequiredysn IS NOT NULL) OR (@strScaleItemysn IS NOT NULL)
			   OR (@strFoodStampableysn IS NOT NULL) OR (@strReturnableysn IS NOT NULL)
			   OR (@strSaleableysn IS NOT NULL) OR (@strID1Requiredysn IS NOT NULL)
			   OR (@strID2Requiredysn IS NOT NULL) OR (@strPromotionalItemysn IS NOT NULL)
			   OR (@strPrePricedysn IS NOT NULL) OR (@strBlueLaw1ysn IS NOT NULL)
			   OR (@strBlueLaw2ysn IS NOT NULL) OR(@strCountedDailyysn IS NOT NULL)
			   OR (@strCounted IS NOT NULL) OR (@strCountSerialysn IS NOT NULL)
			   OR (@intNewFamily IS NOT NULL) OR (@intNewClass IS NOT NULL)
			   OR (@intNewProductCode IS NOT NULL) OR (@intNewVendor IS NOT NULL)
			   OR (@intNewMinAge IS NOT NULL) OR (@dblNewMinVendorOrderQty IS NOT NULL)
			   OR (@dblNewVendorSuggestedQty IS NOT NULL) OR (@intNewInventoryGroup IS NOT NULL)
			   OR (@intNewBinLocation IS NOT NULL) OR (@dblNewMinQtyOnHand IS NOT NULL))
      BEGIN 
	      

		  --SET @UpdateCount = 0

          SET @SqlQuery1 = ' UPDATE tblICItemLocation SET '

		  IF (@strTaxFlag1ysn IS NOT NULL)
			  BEGIN
				set @SqlQuery1 = @SqlQuery1 + 'ysnTaxFlag1 = ''' + LTRIM(@strTaxFlag1ysn) + ''''
			  END

		  IF (@strTaxFlag2ysn IS NOT NULL)  
			  BEGIN
			  if (@strTaxFlag1ysn IS NOT NULL)
 				 set @SqlQuery1 = @SqlQuery1 + ' , ysnTaxFlag2 = ''' + LTRIM(@strTaxFlag2ysn) + ''''
			  else
				 set @SqlQuery1 = @SqlQuery1 + ' ysnTaxFlag2 = ''' + LTRIM(@strTaxFlag2ysn) + '''' 
			  END

		  IF (@strTaxFlag3ysn IS NOT NULL)  
			  BEGIN
			  if ((@strTaxFlag1ysn IS NOT NULL) OR (@strTaxFlag2ysn IS NOT NULL))   
 				 set @SqlQuery1 = @SqlQuery1 + ' , ysnTaxFlag3 = ''' + LTRIM(@strTaxFlag3ysn) + ''''
			  else
				 set @SqlQuery1 = @SqlQuery1 + ' ysnTaxFlag3 = ''' + LTRIM(@strTaxFlag3ysn) + '''' 
			  END

		  IF (@strTaxFlag4ysn IS NOT NULL)  
			  BEGIN
			  if ((@strTaxFlag1ysn IS NOT NULL) OR (@strTaxFlag2ysn IS NOT NULL)
			  OR (@strTaxFlag3ysn IS NOT NULL))   
 				 set @SqlQuery1 = @SqlQuery1 + ' , ysnTaxFlag4 = ''' + LTRIM(@strTaxFlag4ysn) + ''''
			  else
				 set @SqlQuery1 = @SqlQuery1 + ' ysnTaxFlag4 = ''' + LTRIM(@strTaxFlag4ysn) + '''' 
			  END

          IF (@strDepositRequiredysn IS NOT NULL)  
			  BEGIN
			  if ((@strTaxFlag1ysn IS NOT NULL) OR (@strTaxFlag2ysn IS NOT NULL)
			  OR (@strTaxFlag3ysn IS NOT NULL) OR (@strTaxFlag4ysn IS NOT NULL))   
 				 set @SqlQuery1 = @SqlQuery1 + ' , ysnDepositRequired = ''' + LTRIM(@strDepositRequiredysn) + ''''
			  else
				 set @SqlQuery1 = @SqlQuery1 + ' ysnDepositRequired = ''' + LTRIM(@strDepositRequiredysn) + '''' 
			  END

           IF(@intDepositPLU IS NOT NULL)
		     BEGIN
			   if ((@strTaxFlag1ysn IS NOT NULL) OR (@strTaxFlag2ysn IS NOT NULL)
			  OR (@strTaxFlag3ysn IS NOT NULL) OR (@strTaxFlag4ysn IS NOT NULL) 
			  OR (@strDepositRequiredysn IS NOT NULL))   
 				 set @SqlQuery1 = @SqlQuery1 + ' , intDepositPLUId = ''' + LTRIM(@intDepositPLU) + ''''
			  else
				 set @SqlQuery1 = @SqlQuery1 + ' intDepositPLUId = ''' + LTRIM(@intDepositPLU) + '''' 
			 END

           IF(@strQuantityRequiredysn IS NOT NULL)
		     BEGIN
			   if ((@strTaxFlag1ysn IS NOT NULL) OR (@strTaxFlag2ysn IS NOT NULL)
			   OR (@strTaxFlag3ysn IS NOT NULL) OR (@strTaxFlag4ysn IS NOT NULL) 
			   OR (@strDepositRequiredysn IS NOT NULL) OR (@intDepositPLU IS NOT NULL))   
 				  set @SqlQuery1 = @SqlQuery1 + ' , ysnQuantityRequired = ''' + LTRIM(@strQuantityRequiredysn) + ''''
			   else
				  set @SqlQuery1 = @SqlQuery1 + ' ysnQuantityRequired = ''' + LTRIM(@strQuantityRequiredysn) + '''' 
			 END

           IF(@strScaleItemysn IS NOT NULL)
		     BEGIN
			   if ((@strTaxFlag1ysn IS NOT NULL) OR (@strTaxFlag2ysn IS NOT NULL)
			   OR (@strTaxFlag3ysn IS NOT NULL) OR (@strTaxFlag4ysn IS NOT NULL) 
			   OR (@strDepositRequiredysn IS NOT NULL) OR (@intDepositPLU IS NOT NULL)
			   OR (@strQuantityRequiredysn IS NOT NULL))   
 				  set @SqlQuery1 = @SqlQuery1 + ' , ysnScaleItem = ''' + LTRIM(@strScaleItemysn) + ''''
			   else
				  set @SqlQuery1 = @SqlQuery1 + ' ysnScaleItem = ''' + LTRIM(@strScaleItemysn) + '''' 
			 END

           IF(@strFoodStampableysn IS NOT NULL)
		     BEGIN
			   if ((@strTaxFlag1ysn IS NOT NULL) OR (@strTaxFlag2ysn IS NOT NULL)
			   OR (@strTaxFlag3ysn IS NOT NULL) OR (@strTaxFlag4ysn IS NOT NULL) 
			   OR (@strDepositRequiredysn IS NOT NULL) OR (@intDepositPLU IS NOT NULL)
			   OR (@strQuantityRequiredysn IS NOT NULL) OR (@strScaleItemysn IS NOT NULL))   
 				  set @SqlQuery1 = @SqlQuery1 + ' , ysnFoodStampable = ''' + LTRIM(@strFoodStampableysn) + ''''
			   else
				  set @SqlQuery1 = @SqlQuery1 + ' ysnFoodStampable = ''' + LTRIM(@strFoodStampableysn) + '''' 
			 END

           IF(@strReturnableysn IS NOT NULL)
		     BEGIN
			   if ((@strTaxFlag1ysn IS NOT NULL) OR (@strTaxFlag2ysn IS NOT NULL)
			   OR (@strTaxFlag3ysn IS NOT NULL) OR (@strTaxFlag4ysn IS NOT NULL) 
			   OR (@strDepositRequiredysn IS NOT NULL) OR (@intDepositPLU IS NOT NULL)
			   OR (@strQuantityRequiredysn IS NOT NULL) OR (@strScaleItemysn IS NOT NULL)
			   OR (@strFoodStampableysn IS NOT NULL))   
 				  set @SqlQuery1 = @SqlQuery1 + ' , ysnReturnable = ''' + LTRIM(@strReturnableysn) + ''''
			   else
				  set @SqlQuery1 = @SqlQuery1 + ' ysnReturnable = ''' + LTRIM(@strReturnableysn) + '''' 
			 END

          IF(@strSaleableysn IS NOT NULL)
		     BEGIN
			   if ((@strTaxFlag1ysn IS NOT NULL) OR (@strTaxFlag2ysn IS NOT NULL)
			   OR (@strTaxFlag3ysn IS NOT NULL) OR (@strTaxFlag4ysn IS NOT NULL) 
			   OR (@strDepositRequiredysn IS NOT NULL) OR (@intDepositPLU IS NOT NULL)
			   OR (@strQuantityRequiredysn IS NOT NULL) OR (@strScaleItemysn IS NOT NULL)
			   OR (@strFoodStampableysn IS NOT NULL) OR (@strReturnableysn IS NOT NULL))   
 				  set @SqlQuery1 = @SqlQuery1 + ' , ysnSaleable = ''' + LTRIM(@strSaleableysn) + ''''
			   else
				  set @SqlQuery1 = @SqlQuery1 + ' ysnSaleable = ''' + LTRIM(@strSaleableysn) + '''' 
			 END

          IF(@strID1Requiredysn IS NOT NULL)
		     BEGIN
			   if ((@strTaxFlag1ysn IS NOT NULL) OR (@strTaxFlag2ysn IS NOT NULL)
			   OR (@strTaxFlag3ysn IS NOT NULL) OR (@strTaxFlag4ysn IS NOT NULL) 
			   OR (@strDepositRequiredysn IS NOT NULL) OR (@intDepositPLU IS NOT NULL)
			   OR (@strQuantityRequiredysn IS NOT NULL) OR (@strScaleItemysn IS NOT NULL)
			   OR (@strFoodStampableysn IS NOT NULL) OR (@strReturnableysn IS NOT NULL)
			   OR (@strSaleableysn IS NOT NULL))   
 				  set @SqlQuery1 = @SqlQuery1 + ' , ysnIdRequiredLiquor = ''' + LTRIM(@strID1Requiredysn) + ''''
			   else
				  set @SqlQuery1 = @SqlQuery1 + ' ysnIdRequiredLiquor = ''' + LTRIM(@strID1Requiredysn) + '''' 
			 END

          IF(@strID2Requiredysn IS NOT NULL)
		     BEGIN
			   if ((@strTaxFlag1ysn IS NOT NULL) OR (@strTaxFlag2ysn IS NOT NULL)
			   OR (@strTaxFlag3ysn IS NOT NULL) OR (@strTaxFlag4ysn IS NOT NULL) 
			   OR (@strDepositRequiredysn IS NOT NULL) OR (@intDepositPLU IS NOT NULL)
			   OR (@strQuantityRequiredysn IS NOT NULL) OR (@strScaleItemysn IS NOT NULL)
			   OR (@strFoodStampableysn IS NOT NULL) OR (@strReturnableysn IS NOT NULL)
			   OR (@strSaleableysn IS NOT NULL) OR (@strID1Requiredysn IS NOT NULL))   
 				  set @SqlQuery1 = @SqlQuery1 + ' , ysnIdRequiredCigarette = ''' + LTRIM(@strID2Requiredysn) + ''''
			   else
				  set @SqlQuery1 = @SqlQuery1 + ' ysnIdRequiredCigarette = ''' + LTRIM(@strID2Requiredysn) + '''' 
			 END

         IF(@strPromotionalItemysn IS NOT NULL)
		     BEGIN
			   if ((@strTaxFlag1ysn IS NOT NULL) OR (@strTaxFlag2ysn IS NOT NULL)
			   OR (@strTaxFlag3ysn IS NOT NULL) OR (@strTaxFlag4ysn IS NOT NULL) 
			   OR (@strDepositRequiredysn IS NOT NULL) OR (@intDepositPLU IS NOT NULL)
			   OR (@strQuantityRequiredysn IS NOT NULL) OR (@strScaleItemysn IS NOT NULL)
			   OR (@strFoodStampableysn IS NOT NULL) OR (@strReturnableysn IS NOT NULL)
			   OR (@strSaleableysn IS NOT NULL) OR (@strID1Requiredysn IS NOT NULL)
			   OR (@strID2Requiredysn IS NOT NULL))   
 				  set @SqlQuery1 = @SqlQuery1 + ' , ysnPromotionalItem = ''' + LTRIM(@strPromotionalItemysn) + ''''
			   else
				  set @SqlQuery1 = @SqlQuery1 + ' ysnPromotionalItem = ''' + LTRIM(@strPromotionalItemysn) + '''' 
			 END

         IF(@strPrePricedysn IS NOT NULL)
		     BEGIN
			   if ((@strTaxFlag1ysn IS NOT NULL) OR (@strTaxFlag2ysn IS NOT NULL)
			   OR (@strTaxFlag3ysn IS NOT NULL) OR (@strTaxFlag4ysn IS NOT NULL) 
			   OR (@strDepositRequiredysn IS NOT NULL) OR (@intDepositPLU IS NOT NULL)
			   OR (@strQuantityRequiredysn IS NOT NULL) OR (@strScaleItemysn IS NOT NULL)
			   OR (@strFoodStampableysn IS NOT NULL) OR (@strReturnableysn IS NOT NULL)
			   OR (@strSaleableysn IS NOT NULL) OR (@strID1Requiredysn IS NOT NULL)
			   OR (@strID2Requiredysn IS NOT NULL) OR (@strPromotionalItemysn IS NOT NULL))   
 				  set @SqlQuery1 = @SqlQuery1 + ' , ysnPrePriced = ''' + LTRIM(@strPrePricedysn) + ''''
			   else
				  set @SqlQuery1 = @SqlQuery1 + ' ysnPrePriced = ''' + LTRIM(@strPrePricedysn) + '''' 
			 END

         IF(@strBlueLaw1ysn IS NOT NULL)
		     BEGIN
			   if ((@strTaxFlag1ysn IS NOT NULL) OR (@strTaxFlag2ysn IS NOT NULL)
			   OR (@strTaxFlag3ysn IS NOT NULL) OR (@strTaxFlag4ysn IS NOT NULL) 
			   OR (@strDepositRequiredysn IS NOT NULL) OR (@intDepositPLU IS NOT NULL)
			   OR (@strQuantityRequiredysn IS NOT NULL) OR (@strScaleItemysn IS NOT NULL)
			   OR (@strFoodStampableysn IS NOT NULL) OR (@strReturnableysn IS NOT NULL)
			   OR (@strSaleableysn IS NOT NULL) OR (@strID1Requiredysn IS NOT NULL)
			   OR (@strID2Requiredysn IS NOT NULL) OR (@strPromotionalItemysn IS NOT NULL)
			   OR (@strPrePricedysn IS NOT NULL))   
 				  set @SqlQuery1 = @SqlQuery1 + ' , ysnApplyBlueLaw1 = ''' + LTRIM(@strBlueLaw1ysn) + ''''
			   else
				  set @SqlQuery1 = @SqlQuery1 + ' ysnApplyBlueLaw1 = ''' + LTRIM(@strBlueLaw1ysn) + '''' 
			 END

          IF(@strBlueLaw2ysn IS NOT NULL)
		     BEGIN
			   if ((@strTaxFlag1ysn IS NOT NULL) OR (@strTaxFlag2ysn IS NOT NULL)
			   OR (@strTaxFlag3ysn IS NOT NULL) OR (@strTaxFlag4ysn IS NOT NULL) 
			   OR (@strDepositRequiredysn IS NOT NULL) OR (@intDepositPLU IS NOT NULL)
			   OR (@strQuantityRequiredysn IS NOT NULL) OR (@strScaleItemysn IS NOT NULL)
			   OR (@strFoodStampableysn IS NOT NULL) OR (@strReturnableysn IS NOT NULL)
			   OR (@strSaleableysn IS NOT NULL) OR (@strID1Requiredysn IS NOT NULL)
			   OR (@strID2Requiredysn IS NOT NULL) OR (@strPromotionalItemysn IS NOT NULL)
			   OR (@strPrePricedysn IS NOT NULL) OR (@strBlueLaw1ysn IS NOT NULL))   
 				  set @SqlQuery1 = @SqlQuery1 + ' , ysnApplyBlueLaw2 = ''' + LTRIM(@strBlueLaw2ysn) + ''''
			   else
				  set @SqlQuery1 = @SqlQuery1 + ' ysnApplyBlueLaw2 = ''' + LTRIM(@strBlueLaw2ysn) + '''' 
			 END

          IF(@strCountedDailyysn IS NOT NULL)
		     BEGIN
			   if ((@strTaxFlag1ysn IS NOT NULL) OR (@strTaxFlag2ysn IS NOT NULL)
			   OR (@strTaxFlag3ysn IS NOT NULL) OR (@strTaxFlag4ysn IS NOT NULL) 
			   OR (@strDepositRequiredysn IS NOT NULL) OR (@intDepositPLU IS NOT NULL)
			   OR (@strQuantityRequiredysn IS NOT NULL) OR (@strScaleItemysn IS NOT NULL)
			   OR (@strFoodStampableysn IS NOT NULL) OR (@strReturnableysn IS NOT NULL)
			   OR (@strSaleableysn IS NOT NULL) OR (@strID1Requiredysn IS NOT NULL)
			   OR (@strID2Requiredysn IS NOT NULL) OR (@strPromotionalItemysn IS NOT NULL)
			   OR (@strPrePricedysn IS NOT NULL) OR (@strBlueLaw1ysn IS NOT NULL)
			   OR (@strBlueLaw2ysn IS NOT NULL))   
 				  set @SqlQuery1 = @SqlQuery1 + ' , ysnCountedDaily = ''' + LTRIM(@strCountedDailyysn) + ''''
			   else
				  set @SqlQuery1 = @SqlQuery1 + ' ysnCountedDaily = ''' + LTRIM(@strCountedDailyysn) + '''' 
			 END

          IF(@strCounted IS NOT NULL)
		     BEGIN
			   if ((@strTaxFlag1ysn IS NOT NULL) OR (@strTaxFlag2ysn IS NOT NULL)
			   OR (@strTaxFlag3ysn IS NOT NULL) OR (@strTaxFlag4ysn IS NOT NULL) 
			   OR (@strDepositRequiredysn IS NOT NULL) OR (@intDepositPLU IS NOT NULL)
			   OR (@strQuantityRequiredysn IS NOT NULL) OR (@strScaleItemysn IS NOT NULL)
			   OR (@strFoodStampableysn IS NOT NULL) OR (@strReturnableysn IS NOT NULL)
			   OR (@strSaleableysn IS NOT NULL) OR (@strID1Requiredysn IS NOT NULL)
			   OR (@strID2Requiredysn IS NOT NULL) OR (@strPromotionalItemysn IS NOT NULL)
			   OR (@strPrePricedysn IS NOT NULL) OR (@strBlueLaw1ysn IS NOT NULL)
			   OR (@strBlueLaw2ysn IS NOT NULL) OR(@strCountedDailyysn IS NOT NULL))   
 				  set @SqlQuery1 = @SqlQuery1 + ' , strCounted = ''' + LTRIM(@strCounted) + ''''
			   else
				  set @SqlQuery1 = @SqlQuery1 + ' strCounted = ''' + LTRIM(@strCounted) + '''' 
			 END

          IF(@strCountSerialysn IS NOT NULL)
		     BEGIN
			   if ((@strTaxFlag1ysn IS NOT NULL) OR (@strTaxFlag2ysn IS NOT NULL)
			   OR (@strTaxFlag3ysn IS NOT NULL) OR (@strTaxFlag4ysn IS NOT NULL) 
			   OR (@strDepositRequiredysn IS NOT NULL) OR (@intDepositPLU IS NOT NULL)
			   OR (@strQuantityRequiredysn IS NOT NULL) OR (@strScaleItemysn IS NOT NULL)
			   OR (@strFoodStampableysn IS NOT NULL) OR (@strReturnableysn IS NOT NULL)
			   OR (@strSaleableysn IS NOT NULL) OR (@strID1Requiredysn IS NOT NULL)
			   OR (@strID2Requiredysn IS NOT NULL) OR (@strPromotionalItemysn IS NOT NULL)
			   OR (@strPrePricedysn IS NOT NULL) OR (@strBlueLaw1ysn IS NOT NULL)
			   OR (@strBlueLaw2ysn IS NOT NULL) OR(@strCountedDailyysn IS NOT NULL)
			   OR (@strCounted IS NOT NULL))   
 				  set @SqlQuery1 = @SqlQuery1 + ' , ysnCountBySINo = ''' + LTRIM(@strCountSerialysn) + ''''
			   else
				  set @SqlQuery1 = @SqlQuery1 + ' ysnCountBySINo = ''' + LTRIM(@strCountSerialysn) + '''' 
			 END

          IF(@intNewFamily IS NOT NULL)
		     BEGIN
			   if ((@strTaxFlag1ysn IS NOT NULL) OR (@strTaxFlag2ysn IS NOT NULL)
			   OR (@strTaxFlag3ysn IS NOT NULL) OR (@strTaxFlag4ysn IS NOT NULL) 
			   OR (@strDepositRequiredysn IS NOT NULL) OR (@intDepositPLU IS NOT NULL)
			   OR (@strQuantityRequiredysn IS NOT NULL) OR (@strScaleItemysn IS NOT NULL)
			   OR (@strFoodStampableysn IS NOT NULL) OR (@strReturnableysn IS NOT NULL)
			   OR (@strSaleableysn IS NOT NULL) OR (@strID1Requiredysn IS NOT NULL)
			   OR (@strID2Requiredysn IS NOT NULL) OR (@strPromotionalItemysn IS NOT NULL)
			   OR (@strPrePricedysn IS NOT NULL) OR (@strBlueLaw1ysn IS NOT NULL)
			   OR (@strBlueLaw2ysn IS NOT NULL) OR(@strCountedDailyysn IS NOT NULL)
			   OR (@strCounted IS NOT NULL) OR (@strCountSerialysn IS NOT NULL))   
 				  set @SqlQuery1 = @SqlQuery1 + ' , intFamilyId = ''' + LTRIM(@intNewFamily) + ''''
			   else
				  set @SqlQuery1 = @SqlQuery1 + ' intFamilyId = ''' + LTRIM(@intNewFamily) + '''' 
			 END

          IF(@intNewClass IS NOT NULL)
		     BEGIN
			   if ((@strTaxFlag1ysn IS NOT NULL) OR (@strTaxFlag2ysn IS NOT NULL)
			   OR (@strTaxFlag3ysn IS NOT NULL) OR (@strTaxFlag4ysn IS NOT NULL) 
			   OR (@strDepositRequiredysn IS NOT NULL) OR (@intDepositPLU IS NOT NULL)
			   OR (@strQuantityRequiredysn IS NOT NULL) OR (@strScaleItemysn IS NOT NULL)
			   OR (@strFoodStampableysn IS NOT NULL) OR (@strReturnableysn IS NOT NULL)
			   OR (@strSaleableysn IS NOT NULL) OR (@strID1Requiredysn IS NOT NULL)
			   OR (@strID2Requiredysn IS NOT NULL) OR (@strPromotionalItemysn IS NOT NULL)
			   OR (@strPrePricedysn IS NOT NULL) OR (@strBlueLaw1ysn IS NOT NULL)
			   OR (@strBlueLaw2ysn IS NOT NULL) OR(@strCountedDailyysn IS NOT NULL)
			   OR (@strCounted IS NOT NULL) OR (@strCountSerialysn IS NOT NULL)
			   OR (@intNewFamily IS NOT NULL))   
 				  set @SqlQuery1 = @SqlQuery1 + ' , intClassId = ''' + LTRIM(@intNewClass) + ''''
			   else
				  set @SqlQuery1 = @SqlQuery1 + ' intClassId = ''' + LTRIM(@intNewClass) + '''' 
			 END

         IF(@intNewProductCode IS NOT NULL)
		     BEGIN
			   if ((@strTaxFlag1ysn IS NOT NULL) OR (@strTaxFlag2ysn IS NOT NULL)
			   OR (@strTaxFlag3ysn IS NOT NULL) OR (@strTaxFlag4ysn IS NOT NULL) 
			   OR (@strDepositRequiredysn IS NOT NULL) OR (@intDepositPLU IS NOT NULL)
			   OR (@strQuantityRequiredysn IS NOT NULL) OR (@strScaleItemysn IS NOT NULL)
			   OR (@strFoodStampableysn IS NOT NULL) OR (@strReturnableysn IS NOT NULL)
			   OR (@strSaleableysn IS NOT NULL) OR (@strID1Requiredysn IS NOT NULL)
			   OR (@strID2Requiredysn IS NOT NULL) OR (@strPromotionalItemysn IS NOT NULL)
			   OR (@strPrePricedysn IS NOT NULL) OR (@strBlueLaw1ysn IS NOT NULL)
			   OR (@strBlueLaw2ysn IS NOT NULL) OR(@strCountedDailyysn IS NOT NULL)
			   OR (@strCounted IS NOT NULL) OR (@strCountSerialysn IS NOT NULL)
			   OR (@intNewFamily IS NOT NULL) OR (@intNewClass IS NOT NULL))   
 				  set @SqlQuery1 = @SqlQuery1 + ' , intProductCodeId = ''' + LTRIM(@intNewProductCode) + ''''
			   else
				  set @SqlQuery1 = @SqlQuery1 + ' intProductCodeId = ''' + LTRIM(@intNewProductCode) + '''' 
			 END

         IF(@intNewVendor IS NOT NULL)
		     BEGIN
			   if ((@strTaxFlag1ysn IS NOT NULL) OR (@strTaxFlag2ysn IS NOT NULL)
			   OR (@strTaxFlag3ysn IS NOT NULL) OR (@strTaxFlag4ysn IS NOT NULL) 
			   OR (@strDepositRequiredysn IS NOT NULL) OR (@intDepositPLU IS NOT NULL)
			   OR (@strQuantityRequiredysn IS NOT NULL) OR (@strScaleItemysn IS NOT NULL)
			   OR (@strFoodStampableysn IS NOT NULL) OR (@strReturnableysn IS NOT NULL)
			   OR (@strSaleableysn IS NOT NULL) OR (@strID1Requiredysn IS NOT NULL)
			   OR (@strID2Requiredysn IS NOT NULL) OR (@strPromotionalItemysn IS NOT NULL)
			   OR (@strPrePricedysn IS NOT NULL) OR (@strBlueLaw1ysn IS NOT NULL)
			   OR (@strBlueLaw2ysn IS NOT NULL) OR(@strCountedDailyysn IS NOT NULL)
			   OR (@strCounted IS NOT NULL) OR (@strCountSerialysn IS NOT NULL)
			   OR (@intNewFamily IS NOT NULL) OR (@intNewClass IS NOT NULL)
			   OR (@intNewProductCode IS NOT NULL))   
 				  set @SqlQuery1 = @SqlQuery1 + ' , intVendorId = ''' + LTRIM(@intNewVendor) + ''''
			   else
				  set @SqlQuery1 = @SqlQuery1 + ' intVendorId = ''' + LTRIM(@intNewVendor) + '''' 
			 END

          IF(@intNewMinAge IS NOT NULL)
		     BEGIN
			   if ((@strTaxFlag1ysn IS NOT NULL) OR (@strTaxFlag2ysn IS NOT NULL)
			   OR (@strTaxFlag3ysn IS NOT NULL) OR (@strTaxFlag4ysn IS NOT NULL) 
			   OR (@strDepositRequiredysn IS NOT NULL) OR (@intDepositPLU IS NOT NULL)
			   OR (@strQuantityRequiredysn IS NOT NULL) OR (@strScaleItemysn IS NOT NULL)
			   OR (@strFoodStampableysn IS NOT NULL) OR (@strReturnableysn IS NOT NULL)
			   OR (@strSaleableysn IS NOT NULL) OR (@strID1Requiredysn IS NOT NULL)
			   OR (@strID2Requiredysn IS NOT NULL) OR (@strPromotionalItemysn IS NOT NULL)
			   OR (@strPrePricedysn IS NOT NULL) OR (@strBlueLaw1ysn IS NOT NULL)
			   OR (@strBlueLaw2ysn IS NOT NULL) OR(@strCountedDailyysn IS NOT NULL)
			   OR (@strCounted IS NOT NULL) OR (@strCountSerialysn IS NOT NULL)
			   OR (@intNewFamily IS NOT NULL) OR (@intNewClass IS NOT NULL)
			   OR (@intNewProductCode IS NOT NULL) OR (@intNewVendor IS NOT NULL))   
 				  set @SqlQuery1 = @SqlQuery1 + ' , intMinimumAge = ''' + LTRIM(@intNewMinAge) + ''''
			   else
				  set @SqlQuery1 = @SqlQuery1 + ' intMinimumAge = ''' + LTRIM(@intNewMinAge) + '''' 
			 END

          IF(@dblNewMinVendorOrderQty IS NOT NULL)
		     BEGIN
			   if ((@strTaxFlag1ysn IS NOT NULL) OR (@strTaxFlag2ysn IS NOT NULL)
			   OR (@strTaxFlag3ysn IS NOT NULL) OR (@strTaxFlag4ysn IS NOT NULL) 
			   OR (@strDepositRequiredysn IS NOT NULL) OR (@intDepositPLU IS NOT NULL)
			   OR (@strQuantityRequiredysn IS NOT NULL) OR (@strScaleItemysn IS NOT NULL)
			   OR (@strFoodStampableysn IS NOT NULL) OR (@strReturnableysn IS NOT NULL)
			   OR (@strSaleableysn IS NOT NULL) OR (@strID1Requiredysn IS NOT NULL)
			   OR (@strID2Requiredysn IS NOT NULL) OR (@strPromotionalItemysn IS NOT NULL)
			   OR (@strPrePricedysn IS NOT NULL) OR (@strBlueLaw1ysn IS NOT NULL)
			   OR (@strBlueLaw2ysn IS NOT NULL) OR(@strCountedDailyysn IS NOT NULL)
			   OR (@strCounted IS NOT NULL) OR (@strCountSerialysn IS NOT NULL)
			   OR (@intNewFamily IS NOT NULL) OR (@intNewClass IS NOT NULL)
			   OR (@intNewProductCode IS NOT NULL) OR (@intNewVendor IS NOT NULL)
			   OR (@intNewMinAge IS NOT NULL))   
 				  set @SqlQuery1 = @SqlQuery1 + ' , dblMinOrder = ''' + LTRIM(@dblNewMinVendorOrderQty) + ''''
			   else
				  set @SqlQuery1 = @SqlQuery1 + ' dblMinOrder = ''' + LTRIM(@dblNewMinVendorOrderQty) + '''' 
			 END

          IF(@dblNewVendorSuggestedQty IS NOT NULL)
		     BEGIN
			   if ((@strTaxFlag1ysn IS NOT NULL) OR (@strTaxFlag2ysn IS NOT NULL)
			   OR (@strTaxFlag3ysn IS NOT NULL) OR (@strTaxFlag4ysn IS NOT NULL) 
			   OR (@strDepositRequiredysn IS NOT NULL) OR (@intDepositPLU IS NOT NULL)
			   OR (@strQuantityRequiredysn IS NOT NULL) OR (@strScaleItemysn IS NOT NULL)
			   OR (@strFoodStampableysn IS NOT NULL) OR (@strReturnableysn IS NOT NULL)
			   OR (@strSaleableysn IS NOT NULL) OR (@strID1Requiredysn IS NOT NULL)
			   OR (@strID2Requiredysn IS NOT NULL) OR (@strPromotionalItemysn IS NOT NULL)
			   OR (@strPrePricedysn IS NOT NULL) OR (@strBlueLaw1ysn IS NOT NULL)
			   OR (@strBlueLaw2ysn IS NOT NULL) OR(@strCountedDailyysn IS NOT NULL)
			   OR (@strCounted IS NOT NULL) OR (@strCountSerialysn IS NOT NULL)
			   OR (@intNewFamily IS NOT NULL) OR (@intNewClass IS NOT NULL)
			   OR (@intNewProductCode IS NOT NULL) OR (@intNewVendor IS NOT NULL)
			   OR (@intNewMinAge IS NOT NULL) OR (@dblNewMinVendorOrderQty IS NOT NULL))   
 				  set @SqlQuery1 = @SqlQuery1 + ' , dblSuggestedQty = ''' + LTRIM(@dblNewVendorSuggestedQty) + ''''
			   else
				  set @SqlQuery1 = @SqlQuery1 + ' dblSuggestedQty = ''' + LTRIM(@dblNewVendorSuggestedQty) + '''' 
			 END

             IF(@intNewInventoryGroup IS NOT NULL)
		     BEGIN
			   if ((@strTaxFlag1ysn IS NOT NULL) OR (@strTaxFlag2ysn IS NOT NULL)
			   OR (@strTaxFlag3ysn IS NOT NULL) OR (@strTaxFlag4ysn IS NOT NULL) 
			   OR (@strDepositRequiredysn IS NOT NULL) OR (@intDepositPLU IS NOT NULL)
			   OR (@strQuantityRequiredysn IS NOT NULL) OR (@strScaleItemysn IS NOT NULL)
			   OR (@strFoodStampableysn IS NOT NULL) OR (@strReturnableysn IS NOT NULL)
			   OR (@strSaleableysn IS NOT NULL) OR (@strID1Requiredysn IS NOT NULL)
			   OR (@strID2Requiredysn IS NOT NULL) OR (@strPromotionalItemysn IS NOT NULL)
			   OR (@strPrePricedysn IS NOT NULL) OR (@strBlueLaw1ysn IS NOT NULL)
			   OR (@strBlueLaw2ysn IS NOT NULL) OR(@strCountedDailyysn IS NOT NULL)
			   OR (@strCounted IS NOT NULL) OR (@strCountSerialysn IS NOT NULL)
			   OR (@intNewFamily IS NOT NULL) OR (@intNewClass IS NOT NULL)
			   OR (@intNewProductCode IS NOT NULL) OR (@intNewVendor IS NOT NULL)
			   OR (@intNewMinAge IS NOT NULL) OR (@dblNewMinVendorOrderQty IS NOT NULL)
			   OR (@dblNewVendorSuggestedQty IS NOT NULL))   
 				  set @SqlQuery1 = @SqlQuery1 + ' , intCountGroupId = ''' + LTRIM(@intNewInventoryGroup) + ''''
			   else
				  set @SqlQuery1 = @SqlQuery1 + ' intCountGroupId = ''' + LTRIM(@intNewInventoryGroup) + '''' 
			 END


			 IF(@intNewBinLocation IS NOT NULL)
		     BEGIN
			   if ((@strTaxFlag1ysn IS NOT NULL) OR (@strTaxFlag2ysn IS NOT NULL)
			   OR (@strTaxFlag3ysn IS NOT NULL) OR (@strTaxFlag4ysn IS NOT NULL) 
			   OR (@strDepositRequiredysn IS NOT NULL) OR (@intDepositPLU IS NOT NULL)
			   OR (@strQuantityRequiredysn IS NOT NULL) OR (@strScaleItemysn IS NOT NULL)
			   OR (@strFoodStampableysn IS NOT NULL) OR (@strReturnableysn IS NOT NULL)
			   OR (@strSaleableysn IS NOT NULL) OR (@strID1Requiredysn IS NOT NULL)
			   OR (@strID2Requiredysn IS NOT NULL) OR (@strPromotionalItemysn IS NOT NULL)
			   OR (@strPrePricedysn IS NOT NULL) OR (@strBlueLaw1ysn IS NOT NULL)
			   OR (@strBlueLaw2ysn IS NOT NULL) OR(@strCountedDailyysn IS NOT NULL)
			   OR (@strCounted IS NOT NULL) OR (@strCountSerialysn IS NOT NULL)
			   OR (@intNewFamily IS NOT NULL) OR (@intNewClass IS NOT NULL)
			   OR (@intNewProductCode IS NOT NULL) OR (@intNewVendor IS NOT NULL)
			   OR (@intNewMinAge IS NOT NULL) OR (@dblNewMinVendorOrderQty IS NOT NULL)
			   OR (@dblNewVendorSuggestedQty IS NOT NULL) OR (@intNewInventoryGroup IS NOT NULL))   
 				  set @SqlQuery1 = @SqlQuery1 + ' , intStorageLocationId = ''' + LTRIM(@intNewBinLocation) + ''''
			   else
				  set @SqlQuery1 = @SqlQuery1 + ' intStorageLocationId = ''' + LTRIM(@intNewBinLocation) + '''' 
			 END

			 IF(@dblNewMinQtyOnHand IS NOT NULL)
		     BEGIN
			   if ((@strTaxFlag1ysn IS NOT NULL) OR (@strTaxFlag2ysn IS NOT NULL)
			   OR (@strTaxFlag3ysn IS NOT NULL) OR (@strTaxFlag4ysn IS NOT NULL) 
			   OR (@strDepositRequiredysn IS NOT NULL) OR (@intDepositPLU IS NOT NULL)
			   OR (@strQuantityRequiredysn IS NOT NULL) OR (@strScaleItemysn IS NOT NULL)
			   OR (@strFoodStampableysn IS NOT NULL) OR (@strReturnableysn IS NOT NULL)
			   OR (@strSaleableysn IS NOT NULL) OR (@strID1Requiredysn IS NOT NULL)
			   OR (@strID2Requiredysn IS NOT NULL) OR (@strPromotionalItemysn IS NOT NULL)
			   OR (@strPrePricedysn IS NOT NULL) OR (@strBlueLaw1ysn IS NOT NULL)
			   OR (@strBlueLaw2ysn IS NOT NULL) OR(@strCountedDailyysn IS NOT NULL)
			   OR (@strCounted IS NOT NULL) OR (@strCountSerialysn IS NOT NULL)
			   OR (@intNewFamily IS NOT NULL) OR (@intNewClass IS NOT NULL)
			   OR (@intNewProductCode IS NOT NULL) OR (@intNewVendor IS NOT NULL)
			   OR (@intNewMinAge IS NOT NULL) OR (@dblNewMinVendorOrderQty IS NOT NULL)
			   OR (@dblNewVendorSuggestedQty IS NOT NULL) OR (@intNewInventoryGroup IS NOT NULL)
			   OR (@intNewBinLocation IS NOT NULL))   
 				  set @SqlQuery1 = @SqlQuery1 + ' , dblReorderPoint = ''' + LTRIM(@dblNewMinQtyOnHand) + ''''
			   else
				  set @SqlQuery1 = @SqlQuery1 + ' dblReorderPoint = ''' + LTRIM(@dblNewMinQtyOnHand) + '''' 
			 END

			 SET @SqlQuery1 = @SqlQuery1 + ' where 1=1 ' 

			 IF (@strCompanyLocationId IS NOT NULL)
		         BEGIN 
		               set @SqlQuery1 = @SqlQuery1 +  ' and  tblICItemLocation.intLocationId
		             	       IN (' + CAST(@strCompanyLocationId as NVARCHAR) + ')' 
		         END
			 
			 IF (@strVendorId IS NOT NULL)
		         BEGIN 
		               set @SqlQuery1 = @SqlQuery1 +  ' and  tblICItemLocation.intVendorId
		             	       IN (' + CAST(@strVendorId as NVARCHAR) + ')' 
		         END

             IF (@strCategoryId IS NOT NULL)
		         BEGIN
     	               set @SqlQuery1 = @SqlQuery1 +  ' and tblICItemLocation.intItemId  
		               IN (select intItemId from tblICItem where intCategoryId IN
			           (select intCategoryId from tblICCategory where intCategoryId 
					 IN (' + CAST(@strCategoryId as NVARCHAR) + ')' + '))'
		         END

             IF (@Family IS NOT NULL)
		         BEGIN
  			            set @SqlQuery1 = @SqlQuery1 +  ' and  tblICItemLocation.intFamilyId
		             	       IN (' + CAST(@Family as NVARCHAR) + ')' 
		          END

             IF (@strClassId IS NOT NULL)
		         BEGIN
  			            set @SqlQuery1 = @SqlQuery1 +  ' and  tblICItemLocation.intClassId
		             	       IN (' + CAST(@strClassId as NVARCHAR) + ')' 
		          END
		    
			 IF (@intUpcCode IS NOT NULL)
			      BEGIN
				        set @SqlQuery1 = @SqlQuery1 +  ' and tblICItemLocation.intItemId  
                        IN (select intItemId from tblICItemUOM where  intItemUOMId IN
				   	    (' + CAST(@intUpcCode as NVARCHAR) + ')' + ')'
			      END

             IF ((@strDescription IS NOT NULL)
				   and (@strDescription != ''))
					BEGIN
					   set @SqlQuery1 = @SqlQuery1 +  ' and tblICItemLocation.intItemId IN 
					   (select intItemId from tblICItem where strDescription 
					    like ''%' + LTRIM(@strDescription) + '%'' )'
					END

             IF (@dblPriceBetween1 IS NOT NULL) 
		      BEGIN
			      set @SqlQuery1 = @SqlQuery1 +  ' and tblICItemLocation.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice >= 
					   ''' + CONVERT(NVARCHAR,(@dblPriceBetween1)) + '''' + ')'
		      END 
		      
             IF (@dblPriceBetween2 IS NOT NULL) 
		        BEGIN
			        set @SqlQuery1 = @SqlQuery1 +  ' and tblICItemLocation.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice <= 
					   ''' + CONVERT(NVARCHAR,(@dblPriceBetween2)) + '''' + ')'
		        END     


		  EXEC (@SqlQuery1)

		  --SELECT  @UpdateCount =   @UpdateCount + (@@ROWCOUNT)   
	 END	  
END


--PRINT 'Update Logic 02'	
IF((@strYsnPreview != 'Y')
AND(@UpdateCount > 0))
BEGIN
    IF ((@intNewCategory IS NOT NULL)
	OR (@strNewCountCode IS NOT NULL))    
    BEGIN    
		 SET @SqlQuery1 = ' update tblICItem set '
		 
         IF(@intNewCategory IS NOT NULL)
		    BEGIN
			 	  SET @SqlQuery1 = @SqlQuery1 + ' intCategoryId = ''' + LTRIM(@intNewCategory) + '''' 
			END
           
		 IF(@strNewCountCode IS NOT NULL)
		    BEGIN
			     IF (@intNewCategory IS NOT NULL)
				      SET @SqlQuery1 = @SqlQuery1 + ', strCountCode = ''' + LTRIM(@strNewCountCode) + '''' 
	   	         ELSE
			          SET @SqlQuery1 = @SqlQuery1 + ' strCountCode = ''' + LTRIM(@strNewCountCode) + '''' 
            END
	
		 SET @SqlQuery1 = @SqlQuery1 + ' where 1=1 ' 

		 IF (@strCompanyLocationId IS NOT NULL)
		 BEGIN

		      SET @SqlQuery1 = @SqlQuery1 +  ' and tblICItem.intItemId IN 
			              (select intItemId from tblICItemLocation where intLocationId IN
					      (' + CAST(@strCompanyLocationId as NVARCHAR) + ')' + ')'
		 END

		 IF (@strVendorId IS NOT NULL)
		     BEGIN 
		           SET @SqlQuery1 = @SqlQuery1 +  ' and tblICItem.intItemId IN 
			              (select intItemId from tblICItemLocation where intVendorId IN
					       (' + CAST(@strVendorId as NVARCHAR) + ')' + ')'
		     END

         IF (@strCategoryId IS NOT NULL)
		     BEGIN
     	           SET @SqlQuery1 = @SqlQuery1 +  ' and  tblICItem.intCategoryId
		             	       IN (' + CAST(@strCategoryId as NVARCHAR) + ')' 
		     END

         IF (@Family IS NOT NULL)
		     BEGIN
  		           SET @SqlQuery1 = @SqlQuery1 +  ' and tblICItem.intItemId IN 
			              (select intItemId from tblICItemLocation where intFamilyId IN
					       (' + CAST(@Family as NVARCHAR) + ')' + ')'
		     END

         IF (@strClassId IS NOT NULL)
		     BEGIN
  			       SET @SqlQuery1 = @SqlQuery1 +  ' and tblICItem.intItemId IN 
			           (select intItemId from tblICItemLocation where intClassId IN
					    (' + CAST(@strClassId as NVARCHAR) + ')' + ')'
		     END
		    
         IF (@intUpcCode IS NOT NULL)
		     BEGIN
		           SET @SqlQuery1 = @SqlQuery1 +  ' and tblICItem.intItemId  
                        IN (select intItemId from tblICItemUOM where  intItemUOMId IN
				   	    (' + CAST(@intUpcCode as NVARCHAR) + ')' + ')'
			 END

         IF ((@strDescription IS NOT NULL)
		 and (@strDescription != ''))
		 	 BEGIN
			      SET @SqlQuery1 = @SqlQuery1 +  ' and tblICItem.strDescription like ''%' + LTRIM(@strDescription) + '%'' '
			 END

         IF (@dblPriceBetween1 IS NOT NULL) 
		     BEGIN
			      SET @SqlQuery1 = @SqlQuery1 +  ' and tblICItem.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice >= 
					   ''' + CONVERT(NVARCHAR,(@dblPriceBetween1)) + '''' + ')'
		      END 
		      
          IF (@dblPriceBetween2 IS NOT NULL) 
		      BEGIN
			        set @SqlQuery1 = @SqlQuery1 +  ' and tblICItem.intItemId IN 
					   (select intItemId from tblICItemPricing where dblSalePrice <= 
				   ''' + CONVERT(NVARCHAR,(@dblPriceBetween2)) + '''' + ')'
		      END     

          EXEC (@SqlQuery1)
		  --SELECT  @UpdateCount =   @UpdateCount + (@@ROWCOUNT)   	  
	END
END

--PRINT 'Update Logic 03'	
IF((@strYsnPreview != 'Y')
AND(@UpdateCount > 0))
BEGIN
      IF ((@intNewGLPurchaseAccount IS NOT NULL) OR (@intNewGLSalesAccount IS NOT NULL))
	  BEGIN
	         --PRINT '@intNewGLPurchaseAccount'
	         IF (@intNewGLPurchaseAccount IS NOT NULL)
			 BEGIN
			    SET @strAccountCategory = 'Cost of Goods'
				IF EXISTS(SELECT * FROM dbo.tblGLAccountCategory WHERE strAccountCategory = @strAccountCategory)
				BEGIN
					SET @SqlQuery1 = ' update tblICItemAccount set '  

					SET @SqlQuery1 = @SqlQuery1 + ' intAccountId = ''' + LTRIM(@intNewGLPurchaseAccount) + '''' 

					SET @SqlQuery1 = @SqlQuery1 + ' where 1=1 ' 

					IF (@strCompanyLocationId IS NOT NULL)
					BEGIN
	      			  SET @SqlQuery1 = @SqlQuery1 +  ' and tblICItemAccount.intItemId IN 
							  (select intItemId from tblICItemLocation where intLocationId IN
							  (' + CAST(@strCompanyLocationId as NVARCHAR) + ')' + ')'
   					END

					IF (@strVendorId IS NOT NULL)
					BEGIN 
						SET @SqlQuery1 = @SqlQuery1 +  ' and tblICItemAccount.intItemId IN 
							  (select intItemId from tblICItemLocation where intVendorId IN
							   (' + CAST(@strVendorId as NVARCHAR) + ')' + ')'
					END

					IF (@strCategoryId IS NOT NULL)
					BEGIN
     					SET @SqlQuery1 = @SqlQuery1 +  ' and tblICItemAccount.intItemId IN (select intItemId from tblICCategory where intCategoryId IN (' + CAST(@strCategoryId as NVARCHAR) + ')' + ')'
					END

					IF (@Family IS NOT NULL)
					BEGIN
  					   SET @SqlQuery1 = @SqlQuery1 +  ' and tblICItemAccount.intItemId IN 
							  (select intItemId from tblICItemLocation where intFamilyId IN
							   (' + CAST(@Family as NVARCHAR) + ')' + ')'
					END

					IF (@strClassId IS NOT NULL)
					BEGIN
  					   SET @SqlQuery1 = @SqlQuery1 +  ' and tblICItemAccount.intItemId IN 
						   (select intItemId from tblICItemLocation where intClassId IN
							(' + CAST(@strClassId as NVARCHAR) + ')' + ')'
					END
		    
					IF (@intUpcCode IS NOT NULL)
					BEGIN
					   SET @SqlQuery1 = @SqlQuery1 +  ' and tblICItemAccount.intItemId  
							IN (select intItemId from tblICItemUOM where  intItemUOMId IN
				   			(' + CAST(@intUpcCode as NVARCHAR) + ')' + ')'
					END

					IF ((@strDescription IS NOT NULL)
					and (@strDescription != ''))
		 			BEGIN
					  --SET @SqlQuery1 = @SqlQuery1 +  ' and tblICItemAccount.strDescription like ''%' + LTRIM(@strDescription) + '%'' '
					   SET @SqlQuery1 = @SqlQuery1 +  ' AND tblICItemAccount.intItemId IN 
						   (SELECT intItemId FROM tblICItem WHERE strDescription like ''%' + LTRIM(@strDescription) + '%'')'
					END

					IF (@dblPriceBetween1 IS NOT NULL) 
					BEGIN
					  SET @SqlQuery1 = @SqlQuery1 +  ' and tblICItemAccount.intItemId IN 
						   (select intItemId from tblICItemPricing where dblSalePrice >= 
						   ''' + CONVERT(NVARCHAR,(@dblPriceBetween1)) + '''' + ')'
					END 
		      
					IF (@dblPriceBetween2 IS NOT NULL) 
					BEGIN
						set @SqlQuery1 = @SqlQuery1 +  ' and tblICItemAccount.intItemId IN 
						   (select intItemId from tblICItemPricing where dblSalePrice <= 
					   ''' + CONVERT(NVARCHAR,(@dblPriceBetween2)) + '''' + ')'
					END     

					--SET @SqlQuery1 = @SqlQuery1 + ' and  intAccountCategoryId = 30 '
					SELECT @intAccountCategoryId = intAccountCategoryId FROM dbo.tblGLAccountCategory WHERE strAccountCategory = @strAccountCategory
					SET @SqlQuery1 = @SqlQuery1 + ' and  intAccountCategoryId = ' + CAST(@intAccountCategoryId AS NVARCHAR(50)) + ' '

					EXEC (@SqlQuery1)
					--SELECT  @UpdateCount =   @UpdateCount + (@@ROWCOUNT)   	  
				END 
			 END


			 --PRINT '@intNewGLSalesAccount'
             IF (@intNewGLSalesAccount IS NOT NULL)
			 BEGIN
			    SET @strAccountCategory = 'Sales Account'
				IF EXISTS(SELECT * FROM dbo.tblGLAccountCategory WHERE strAccountCategory = @strAccountCategory)
				BEGIN
					SET @SqlQuery1 = ' update tblICItemAccount set '  

					SET @SqlQuery1 = @SqlQuery1 + ' intAccountId = ''' + LTRIM(@intNewGLSalesAccount) + '''' 

					SET @SqlQuery1 = @SqlQuery1 + ' where 1=1 ' 

					IF (@strCompanyLocationId IS NOT NULL)
					BEGIN
	      			  SET @SqlQuery1 = @SqlQuery1 +  ' and tblICItemAccount.intItemId IN 
							  (select intItemId from tblICItemLocation where intLocationId IN
							  (' + CAST(@strCompanyLocationId as NVARCHAR) + ')' + ')'
   					END

					IF (@strVendorId IS NOT NULL)
					BEGIN 
						SET @SqlQuery1 = @SqlQuery1 +  ' and tblICItemAccount.intItemId IN (select intItemId from tblICItemLocation where intVendorId IN (' + CAST(@strVendorId as NVARCHAR) + ')' + ')'
					END

					IF (@strCategoryId IS NOT NULL)
					BEGIN
     					SET @SqlQuery1 = @SqlQuery1 +  ' and tblICItemAccount.intItemId IN (select intItemId from tblICCategory where intCategoryId IN (' + CAST(@strCategoryId as NVARCHAR) + ')' + ')'
					END

					IF (@Family IS NOT NULL)
					BEGIN
  					   SET @SqlQuery1 = @SqlQuery1 +  ' and tblICItemAccount.intItemId IN 
							  (select intItemId from tblICItemLocation where intFamilyId IN
							   (' + CAST(@Family as NVARCHAR) + ')' + ')'
					END

					IF (@strClassId IS NOT NULL)
					BEGIN
  					   SET @SqlQuery1 = @SqlQuery1 +  ' and tblICItemAccount.intItemId IN 
						   (select intItemId from tblICItemLocation where intClassId IN
							(' + CAST(@strClassId as NVARCHAR) + ')' + ')'
					END
		    
					IF (@intUpcCode IS NOT NULL)
					BEGIN
					   SET @SqlQuery1 = @SqlQuery1 +  ' and tblICItemAccount.intItemId  
							IN (select intItemId from tblICItemUOM where  intItemUOMId IN
				   			(' + CAST(@intUpcCode as NVARCHAR) + ')' + ')'
					END

					IF ((@strDescription IS NOT NULL)
					and (@strDescription != ''))
		 			BEGIN
					  --SET @SqlQuery1 = @SqlQuery1 +  ' and tblICItemAccount.strDescription like ''%' + LTRIM(@strDescription) + '%'' '
					   SET @SqlQuery1 = @SqlQuery1 +  ' AND tblICItemAccount.intItemId IN 
						   (SELECT intItemId FROM tblICItem WHERE strDescription like ''%' + LTRIM(@strDescription) + '%'')'
					END

					IF (@dblPriceBetween1 IS NOT NULL) 
					BEGIN
					  SET @SqlQuery1 = @SqlQuery1 +  ' and tblICItemAccount.intItemId IN 
						   (select intItemId from tblICItemPricing where dblSalePrice >= 
						   ''' + CONVERT(NVARCHAR,(@dblPriceBetween1)) + '''' + ')'
					END 
		      
					IF (@dblPriceBetween2 IS NOT NULL) 
					BEGIN
						set @SqlQuery1 = @SqlQuery1 +  ' and tblICItemAccount.intItemId IN 
						   (select intItemId from tblICItemPricing where dblSalePrice <= 
					   ''' + CONVERT(NVARCHAR,(@dblPriceBetween2)) + '''' + ')'
					END     

					--SET @SqlQuery1 = @SqlQuery1 + ' and  intAccountCategoryId = 33 '
					SELECT @intAccountCategoryId = intAccountCategoryId FROM dbo.tblGLAccountCategory WHERE strAccountCategory = @strAccountCategory
					SET @SqlQuery1 = @SqlQuery1 + ' and  intAccountCategoryId = ' + CAST(@intAccountCategoryId AS NVARCHAR(50)) + ' '

					EXEC (@SqlQuery1)
				
					--SELECT  @UpdateCount =   @UpdateCount + (@@ROWCOUNT)   	  
				END 
			 END
             



			 --IF (@intNewGLVarianceAccount IS NOT NULL)
			 --BEGIN
			    
				--SET @SqlQuery1 = ' update tblICItemAccount set '  

			 --   SET @SqlQuery1 = @SqlQuery1 + ' intAccountId = ''' + LTRIM(@intNewGLVarianceAccount) + '''' 

				--SET @SqlQuery1 = @SqlQuery1 + ' where 1=1 ' 

		  --      IF (@strCompanyLocationId IS NOT NULL)
		  --      BEGIN
	   --   	      SET @SqlQuery1 = @SqlQuery1 +  ' and tblICItemAccount.intItemId IN 
			 --             (select intItemId from tblICItemLocation where intLocationId IN
				--	      (' + CAST(@strCompanyLocationId as NVARCHAR) + ')' + ')'
   	--	        END

		  --      IF (@strVendorId IS NOT NULL)
		  --      BEGIN 
		  --          SET @SqlQuery1 = @SqlQuery1 +  ' and tblICItemAccount.intItemId IN 
			 --             (select intItemId from tblICItemLocation where intVendorId IN
				--	       (' + CAST(@strVendorId as NVARCHAR) + ')' + ')'
		  --      END

    --            IF (@strCategoryId IS NOT NULL)
		  --      BEGIN
    -- 	            SET @SqlQuery1 = @SqlQuery1 +  ' and  tblICItemAccount.intCategoryId
		  --           	       IN (' + CAST(@strCategoryId as NVARCHAR) + ')' 
		  --      END

    --            IF (@Family IS NOT NULL)
		  --      BEGIN
  		--           SET @SqlQuery1 = @SqlQuery1 +  ' and tblICItemAccount.intItemId IN 
			 --             (select intItemId from tblICItemLocation where intFamilyId IN
				--	       (' + CAST(@Family as NVARCHAR) + ')' + ')'
		  --      END

    --            IF (@strClassId IS NOT NULL)
		  --      BEGIN
  		--	       SET @SqlQuery1 = @SqlQuery1 +  ' and tblICItemAccount.intItemId IN 
			 --          (select intItemId from tblICItemLocation where intClassId IN
				--	    (' + CAST(@strClassId as NVARCHAR) + ')' + ')'
		  --      END
		    
    --            IF (@intUpcCode IS NOT NULL)
		  --      BEGIN
		  --         SET @SqlQuery1 = @SqlQuery1 +  ' and tblICItemAccount.intItemId  
    --                    IN (select intItemId from tblICItemUOM where  intItemUOMId IN
				--   	    (' + CAST(@intUpcCode as NVARCHAR) + ')' + ')'
			 --   END

    --            IF ((@strDescription IS NOT NULL)
		  --      and (@strDescription != ''))
		 	--    BEGIN
			 --     SET @SqlQuery1 = @SqlQuery1 +  ' and tblICItemAccount.strDescription like ''%' + LTRIM(@strDescription) + '%'' '
			 --   END

    --            IF (@dblPriceBetween1 IS NOT NULL) 
		  --      BEGIN
			 --     SET @SqlQuery1 = @SqlQuery1 +  ' and tblICItemAccount.intItemId IN 
				--	   (select intItemId from tblICItemPricing where dblSalePrice >= 
				--	   ''' + CONVERT(NVARCHAR,(@dblPriceBetween1)) + '''' + ')'
		  --      END 
		      
    --            IF (@dblPriceBetween2 IS NOT NULL) 
		  --      BEGIN
			 --       set @SqlQuery1 = @SqlQuery1 +  ' and tblICItemAccount.intItemId IN 
				--	   (select intItemId from tblICItemPricing where dblSalePrice <= 
				--   ''' + CONVERT(NVARCHAR,(@dblPriceBetween2)) + '''' + ')'
		  --      END     

				--SET @SqlQuery1 = @SqlQuery1 + ' and  intAccountCategoryId = 40 '

    --            EXEC (@SqlQuery1)
				
		  --      SELECT  @UpdateCount =   @UpdateCount + (@@ROWCOUNT)   	  
			 --END
	  END
END

--Insert to tblICItemAccount
IF(@strYsnPreview != 'Y' AND @intNewGLPurchaseAccount IS NOT NULL)
BEGIN
	SET @strAccountCategory = 'Cost of Goods'
	IF EXISTS(SELECT * FROM dbo.tblGLAccountCategory WHERE strAccountCategory = @strAccountCategory)
	BEGIN
		SELECT @intAccountCategoryId = intAccountCategoryId FROM dbo.tblGLAccountCategory WHERE strAccountCategory = @strAccountCategory
		
		DECLARE @strAddCostOfGoods AS NVARCHAR(100) = 'Add New Cost of Goods Sold Account'

		IF EXISTS (SELECT * FROM @tblTempOne WHERE strChangeDescription = @strAddCostOfGoods)
		BEGIN
			DECLARE @intItemIdCostOfGoods AS INT = (SELECT TOP 1 intParentId FROM @tblTempOne WHERE strChangeDescription = @strAddCostOfGoods)

			INSERT INTO tblICItemAccount(intItemId, intAccountCategoryId, intAccountId, intConcurrencyId)
			VALUES(@intItemIdCostOfGoods, @intAccountCategoryId, @intNewGLPurchaseAccount, 0)
		END
	END 
END

IF(@strYsnPreview != 'Y' AND @intNewGLSalesAccount IS NOT NULL)
BEGIN
	SET @strAccountCategory = 'Sales Account'
	IF EXISTS(SELECT * FROM dbo.tblGLAccountCategory WHERE strAccountCategory = @strAccountCategory)
	BEGIN
		SELECT @intAccountCategoryId = intAccountCategoryId FROM dbo.tblGLAccountCategory WHERE strAccountCategory = @strAccountCategory
		
		DECLARE @strAddSalesAccount AS NVARCHAR(100) = 'Add New Sales Account'

		IF EXISTS (SELECT * FROM @tblTempOne WHERE strChangeDescription = @strAddSalesAccount)
		BEGIN
			DECLARE @intItemIdSalesAccount AS INT = (SELECT TOP 1 intParentId FROM @tblTempOne WHERE strChangeDescription = @strAddSalesAccount)

			INSERT INTO tblICItemAccount(intItemId, intAccountCategoryId, intAccountId, intConcurrencyId)
			VALUES(@intItemIdSalesAccount, @intAccountCategoryId, @intNewGLSalesAccount, 0)
		END
	END 
END

--AUDIT LOG
IF(@UpdateCount >= 1 AND @strYsnPreview != 'Y' AND (@strNewCountCode IS NOT NULL OR @intNewCategory IS NOT NULL OR @intNewGLPurchaseAccount IS NOT NULL OR @intNewGLSalesAccount IS NOT NULL))
BEGIN
			--AUDIT LOG

			--use distinct to table Id's
			INSERT INTO @tblId(intId)
			SELECT DISTINCT intChildId 
			FROM @tblTempOne
			ORDER BY intChildId ASC

			--==========================================================================================================================================
			WHILE EXISTS (SELECT TOP (1) 1 FROM @tblId)
			BEGIN
				SELECT TOP 1 @intChildId = intId FROM @tblId

				--use distinct to table tempOne
				DELETE FROM @tblTempTwo
				INSERT INTO @tblTempTwo(strUpc, strItemDescription, strChangeDescription, strOldData, strNewData, intParentId, intChildId)
				SELECT DISTINCT strUpc
								, strItemDescription
								, strChangeDescription
								, strOldData
								, strNewData
								, intParentId
								, intChildId 
				--FROM tblSTMassUpdateReportMaster
				FROM @tblTempOne
				WHERE intChildId = @intChildId
				ORDER BY intChildId ASC

				SET @RowCountMin = 1
				SELECT @RowCountMax = Count(*) FROM @tblTempTwo

					WHILE(@RowCountMin <= @RowCountMax)
					BEGIN
						SELECT TOP(1) @strChangeDescription = strChangeDescription, @strOldData = strOldData, @strNewData = strNewData, @intParentId = intParentId from @tblTempTwo
			    


						IF(@strChangeDescription = 'Count Code')
						BEGIN
							SET @ParentTableAuditLog = @ParentTableAuditLog + '{"change":"strCountCode","from":"' + @strOldData + '","to":"' + @strNewData + '","leaf":true,"iconCls":"small-gear","isField":true,"keyValue":' + CAST(@intParentId AS NVARCHAR(50)) + ',"changeDescription":"' + @strChangeDescription + '","hidden":false},'
						END
						ELSE IF(@strChangeDescription = 'Category')
						BEGIN
							SET @ParentTableAuditLog = @ParentTableAuditLog + '{"change":"intCategoryId","from":"' + @strOldData + '","to":"' + @strNewData + '","leaf":true,"iconCls":"small-gear","isField":true,"keyValue":' + CAST(@intParentId AS NVARCHAR(50)) + ',"changeDescription":"' + @strChangeDescription + '","hidden":false},'
						END

						ELSE IF(@strChangeDescription = 'Cost of Goods Sold Account' OR @strChangeDescription = 'Sales Account')
						BEGIN
							SET @ChildTableAuditLog = @ChildTableAuditLog + '{"change":"intAccountId","from":"' + @strOldData + '","to":"' + @strNewData + '","leaf":true,"iconCls":"small-gear","isField":true,"keyValue":' + CAST(@intChildId AS NVARCHAR(50)) + ',"associationKey":"tblICItemAccounts","changeDescription":"' + @strChangeDescription + '","hidden":false},'
						END



						SET @RowCountMin = @RowCountMin + 1
						DELETE TOP (1) FROM @tblTempTwo
					END


				--INSERT to AUDITLOG
				--=================================================================================================
				----tblICItem
				--IF (@ParentTableAuditLog != '')
				--BEGIN
				--	--Remove last character comma(,)
				--	SET @ParentTableAuditLog = left(@ParentTableAuditLog, len(@ParentTableAuditLog)-1)

				--	SET @ParentTableAuditLog = '{"change":"tblICItems","children":[{"action":"Updated","change":"Updated - Record: ' + CAST(@intParentId AS NVARCHAR(50)) + '","keyValue":' + CAST(@intChildId AS NVARCHAR(50)) + ',"iconCls":"small-tree-modified","children":[' + @ParentTableAuditLog + ']}],"iconCls":"small-tree-grid","changeDescription":"Pricing"},'
				--END


				--tblICItemAccount
				IF (@ChildTableAuditLog != '')
				BEGIN
					--Remove last character comma(,)
					SET @ChildTableAuditLog = left(@ChildTableAuditLog, len(@ChildTableAuditLog)-1)

					SET @ChildTableAuditLog = '{"change":"tblICItemPricings","children":[{"action":"Updated","change":"Updated - Record: ' + CAST(@intChildId AS NVARCHAR(50)) + '","keyValue":' + CAST(@intChildId AS NVARCHAR(50)) + ',"iconCls":"small-tree-modified","children":[' + @ChildTableAuditLog + ']}],"iconCls":"small-tree-grid","changeDescription":"GL Accounts"},'
				END


				SET @JsonStringAuditLog = @ParentTableAuditLog + @ChildTableAuditLog


				SELECT @checkComma = CASE WHEN RIGHT(@JsonStringAuditLog, 1) IN (',') THEN 1 ELSE 0 END
				IF(@checkComma = 1)
				BEGIN
					--Remove last character comma(,)
					SET @JsonStringAuditLog = left(@JsonStringAuditLog, len(@JsonStringAuditLog)-1)
				END

				SET @JsonStringAuditLog = '{"action":"Updated","change":"Updated - Record: ' + CAST(@intParentId AS NVARCHAR(50)) + '","keyValue":' + CAST(@intParentId AS NVARCHAR(50)) + ',"iconCls":"small-tree-modified","children":[' + @JsonStringAuditLog + ']}'
				INSERT INTO tblSMAuditLog(strActionType, strTransactionType, strRecordNo, strDescription, strRoute, strJsonData, dtmDate, intEntityId, intConcurrencyId)
				VALUES(
						'Updated'
						, 'Inventory.view.Item'
						, @intParentId
						, ''
						, null
						, @JsonStringAuditLog
						, GETUTCDATE()
						, @intCurrentUserId
						, 1
				)
				--=================================================================================================

				--Clear
				SET @ParentTableAuditLog = ''
				SET @ChildTableAuditLog = ''

				DELETE TOP (1) FROM @tblId
			END
			--==========================================================================================================================================


			SELECT @UpdateCount = COUNT(*)
			FROM 
			(
			  SELECT DISTINCT intChildId FROM @tblTempOne --tblSTMassUpdateReportMaster
			) T1
	END




	DELETE FROM tblSTMassUpdateReportMaster
	INSERT INTO tblSTMassUpdateReportMaster(strLocationName, UpcCode, ItemDescription, ChangeDescription, OldData, NewData)
	SELECT strLocation
		  , strUpc
		  , strItemDescription
		  , strChangeDescription
		  , strOldData
		  , strNewData 
	FROM @tblTempOne




	 -- Get CompanyName
	DECLARE @strCompanyName as NVARCHAR(250)
	IF EXISTS (SELECT * FROM dbo.tblSMCompanySetup)
	BEGIN
		SELECT @strCompanyName = strCompanyName FROM tblSMCompanySetup
	END
	ELSE IF NOT EXISTS (SELECT * FROM dbo.tblSMCompanySetup)
	BEGIN
		SET @strCompanyName = 'Not Set'
	END




   SELECT DISTINCT @strCompanyName as CompanyName
		  , LEFT(DATENAME(DW,GETDATE()),10) + ' ' + DATENAME(MONTH, SYSDATETIME())+ ' ' + RIGHT('0' + DATENAME(DAY, SYSDATETIME()), 2) + ', ' + DATENAME(YEAR, SYSDATETIME()) as DateToday
		  , RIGHT('0' + LTRIM(STUFF(RIGHT(CONVERT(CHAR(26), CURRENT_TIMESTAMP, 109), 14),9, 4, ' ')),11) as TimeToday
		  , strLocation
		  , strUpc
		  , strItemDescription
		  , strChangeDescription
		  , strOldData
		  , strNewData
   FROM @tblTempOne
   ORDER BY strLocation, strItemDescription, strChangeDescription


   --DELETE FROM @tblTempOne

END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
END CATCH