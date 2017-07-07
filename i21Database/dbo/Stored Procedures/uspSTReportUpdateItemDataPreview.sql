CREATE PROCEDURE [dbo].[uspSTReportUpdateItemDataPreview]
	@xmlParam NVARCHAR(MAX) = NULL
AS

BEGIN TRY

	--INSERT INTO TestDatabase.dbo.tblPerson(strFirstName)
	--VALUES(@xmlParam)
	--SELECT * FROM TestDatabase.dbo.tblPerson

	DECLARE @ErrMsg NVARCHAR(MAX)

	--START Handle xml Param
	DECLARE @strCompanyLocationId 	   NVARCHAR(MAX),
			@strVendorId               NVARCHAR(MAX),
			@strCategoryId             NVARCHAR(MAX),
			@strFamilyId               NVARCHAR(MAX),
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
			@intNewGLVarianceAccount      INT,
			@strYsnPreview         NVARCHAR(1)

	IF LTRIM(RTRIM(@xmlParam)) = ''
		SET @xmlParam = NULL

	--Declare xmlParam holder
	DECLARE @temp_xml_table TABLE 
	(  
			[fieldname]		NVARCHAR(50),  
			condition		NVARCHAR(20),        
			[from]			NVARCHAR(50), 
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
				[fieldname]		NVARCHAR(50),  
				condition		NVARCHAR(20),        
				[from]			NVARCHAR(50), 
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
	SELECT @strFamilyId = [from]
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

	--intNewGLVarianceAccount 
	SELECT @intNewGLVarianceAccount = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intNewGLVarianceAccount'

	--strYsnPreview 
	SELECT @strYsnPreview = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strYsnPreview'

	--Declare Table holder
	DECLARE @tblUpdateItemDataPreview TABLE 
	(
		strLocation NVARCHAR(250)
		, strUpc NVARCHAR(50)
		, strItemDescription NVARCHAR(250)
		, strChangeDescription NVARCHAR(100)
		, strOldData NVARCHAR(MAX)
		, strNewData NVARCHAR(MAX)
	)

	DECLARE @strFamilyIdId NVARCHAR(250)
	DECLARE @strClassIdId  NVARCHAR(250)
	DECLARE @ProductCode NVARCHAR(250)
	DECLARE @strVendorIdId NVARCHAR(250)
	DECLARE @NewDepositPluId NVARCHAR(250)
	DECLARE @NewInventoryCountGroupId NVARCHAR(250)
	
	DECLARE @UpdateCount INT
	SET @UpdateCount = 0

	DECLARE @CompanyCurrencyDecimal NVARCHAR(1)
	SET @CompanyCurrencyDecimal = 0
	SELECT @CompanyCurrencyDecimal = intCurrencyDecimal from tblSMCompanyPreference

	DECLARE @SqlQuery1 as NVARCHAR(MAX)
	 -----------------------------------Handle Dynamic Query 1
	 IF (@strTaxFlag1ysn IS NOT NULL)
	 BEGIN
		 IF (@strDepositRequiredysn IS NOT NULL)
		 BEGIN
				SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
				(
					', ''Tax Flag1'''
					, ', CASE WHEN a.ysnTaxFlag1 = 0 THEN ''No'' ELSE ''Yes'' END'
					, ', ''' + CASE WHEN @strTaxFlag1ysn = 0 THEN 'No' ELSE 'Yes' END +''''
					, @strCompanyLocationId
					, @strVendorId
					, @strCategoryId
					, @strFamilyId
					, @strClassId
					, @intUpcCode
					, @strDescription
					, @dblPriceBetween1
					, @dblPriceBetween2
				)

			INSERT @tblUpdateItemDataPreview
			EXEC (@SqlQuery1) 

		 END
	 END 

	 -----------------------------------Handle Dynamic Query 2
	 IF (@strTaxFlag2ysn IS NOT NULL)
	 BEGIN
		 IF (@strDepositRequiredysn IS NOT NULL)
		 BEGIN
				SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
				(
					', ''Tax Flag2'''
					, ', CASE WHEN a.ysnTaxFlag2 = 0 THEN ''No'' ELSE ''Yes'' END'
					, ', ''' + CASE WHEN @strTaxFlag2ysn = 0 THEN 'No' ELSE 'Yes' END +''''
					, @strCompanyLocationId
					, @strVendorId
					, @strCategoryId
					, @strFamilyId
					, @strClassId
					, @intUpcCode
					, @strDescription
					, @dblPriceBetween1
					, @dblPriceBetween2
				)

			INSERT @tblUpdateItemDataPreview
			EXEC (@SqlQuery1) 

		 END
	 END 

	 -----------------------------------Handle Dynamic Query 3
	 IF (@strTaxFlag3ysn IS NOT NULL)
	 BEGIN
		 IF (@strDepositRequiredysn IS NOT NULL)
		 BEGIN
				SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
				(
					', ''Tax Flag3'''
					, ', CASE WHEN a.ysnTaxFlag3 = 0 THEN ''No'' ELSE ''Yes'' END'
					, ', ''' + CASE WHEN @strTaxFlag3ysn = 0 THEN 'No' ELSE 'Yes' END +''''
					, @strCompanyLocationId
					, @strVendorId
					, @strCategoryId
					, @strFamilyId
					, @strClassId
					, @intUpcCode
					, @strDescription
					, @dblPriceBetween1
					, @dblPriceBetween2
				)

			INSERT @tblUpdateItemDataPreview
			EXEC (@SqlQuery1) 
		 END
	 END 

	 -----------------------------------Handle Dynamic Query 4
	 IF (@strTaxFlag4ysn IS NOT NULL)
	 BEGIN
		 IF (@strDepositRequiredysn IS NOT NULL)
		 BEGIN
				SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
				(
					', ''Tax Flag4'''
					, ', CASE WHEN a.ysnTaxFlag4 = 0 THEN ''No'' ELSE ''Yes'' END'
					, ', ''' + CASE WHEN @strTaxFlag4ysn = 0 THEN 'No' ELSE 'Yes' END +''''
					, @strCompanyLocationId
					, @strVendorId
					, @strCategoryId
					, @strFamilyId
					, @strClassId
					, @intUpcCode
					, @strDescription
					, @dblPriceBetween1
					, @dblPriceBetween2
				)

			INSERT @tblUpdateItemDataPreview
			EXEC (@SqlQuery1) 
		 END  
	 END

	 -----------------------------------Handle Dynamic Query 5
	 IF (@strDepositRequiredysn IS NOT NULL)
	 BEGIN
		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				', ''Deposit Required'''
				, ', CASE WHEN a.ysnDepositRequired = 0 THEN ''No'' ELSE ''Yes'' END'
				, ', ''' + case when @strDepositRequiredysn = 0 then 'No' else 'Yes' end +''''
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @strFamilyId
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
			)

		INSERT @tblUpdateItemDataPreview
		EXEC (@SqlQuery1) 
	 END 

	 -----------------------------------Handle Dynamic Query 6
	 IF (@intDepositPLU IS NOT NULL)
	 BEGIN

			SELECT @NewDepositPluId = strUpcCode from tblICItemUOM where intItemUOMId = @intDepositPLU

		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				', ''Deposit PLU'''
				, ', (select strUpcCode from tblICItemUOM where intItemUOMId = a.intDepositPLUId)'
				, ', ''' + @NewDepositPluId + ''''
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @strFamilyId
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
			)

		INSERT @tblUpdateItemDataPreview
		EXEC (@SqlQuery1) 
	 END 

	 -----------------------------------Handle Dynamic Query 7
	 IF (@strQuantityRequiredysn IS NOT NULL)
	 BEGIN

		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				', ''Quantity Required'''
				, ', CASE WHEN a.ysnQuantityRequired = 0 THEN ''No'' ELSE ''Yes'' END'
				, ', ''' + CASE WHEN @strQuantityRequiredysn = 0 THEN 'No' ELSE 'Yes' END +''''
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @strFamilyId
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
			)

		INSERT @tblUpdateItemDataPreview
		EXEC (@SqlQuery1) 
	 END 

	 -----------------------------------Handle Dynamic Query 8
	 IF (@strScaleItemysn IS NOT NULL)
	 BEGIN

		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				', ''Scale Item'''
				, ', CASE WHEN a.ysnScaleItem = 0 THEN ''No'' ELSE ''Yes'' END'
				, ', ''' + CASE WHEN @strScaleItemysn = 0 THEN 'No' ELSE 'Yes' END +''''
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @strFamilyId
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
			)

		INSERT @tblUpdateItemDataPreview
		EXEC (@SqlQuery1) 
	 END 

	 -----------------------------------Handle Dynamic Query 9
	 IF (@strFoodStampableysn IS NOT NULL)
	 BEGIN

		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				', ''Food Stampable'''
				, ', CASE WHEN a.ysnFoodStampable = 0 THEN ''No'' ELSE ''Yes'' END'
				, ', ''' + CASE WHEN @strFoodStampableysn = 0 THEN 'No' ELSE 'Yes' END +''''
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @strFamilyId
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
			)

		INSERT @tblUpdateItemDataPreview
		EXEC (@SqlQuery1) 
	 END 

	 -----------------------------------Handle Dynamic Query 10
	 IF (@strReturnableysn IS NOT NULL)
	 BEGIN

		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				', ''Returnable'''
				, ', CASE WHEN a.ysnReturnable = 0 THEN ''No'' ELSE ''Yes'' END'
				, ', ''' + CASE WHEN @strReturnableysn = 0 THEN 'No' ELSE 'Yes' END +''''
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @strFamilyId
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
			)

		INSERT @tblUpdateItemDataPreview
		EXEC (@SqlQuery1) 
	 END 

	 -----------------------------------Handle Dynamic Query 11
	 IF (@strSaleableysn IS NOT NULL)
	 BEGIN

		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				', ''Saleable'''
				, ', CASE WHEN a.ysnSaleable = 0 THEN ''No'' ELSE ''Yes'' END'
				, ', ''' + CASE WHEN @strSaleableysn = 0 THEN 'No' ELSE 'Yes' END +''''
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @strFamilyId
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
			)

		INSERT @tblUpdateItemDataPreview
		EXEC (@SqlQuery1) 
	 END 

	 -----------------------------------Handle Dynamic Query 12
	 IF (@strID1Requiredysn IS NOT NULL)
	 BEGIN

		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				', ''Liquor Id Required'''
				, ', CASE WHEN a.ysnIdRequiredLiquor = 0 THEN ''No'' ELSE ''Yes'' END'
				, ', ''' + CASE WHEN @strID1Requiredysn = 0 THEN 'No' ELSE 'Yes' END +''''
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @strFamilyId
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
			)

		INSERT @tblUpdateItemDataPreview
		EXEC (@SqlQuery1) 
	 END 

	 -----------------------------------Handle Dynamic Query 13
	 IF (@strID2Requiredysn IS NOT NULL)
	 BEGIN

		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				', ''Cigarette Id Required'''
				, ', CASE WHEN a.ysnIdRequiredCigarette = 0 THEN ''No'' ELSE ''Yes'' END'
				, ', ''' + CASE WHEN @strID2Requiredysn = 0 THEN 'No' ELSE 'Yes' END +''''
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @strFamilyId
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
			)

		INSERT @tblUpdateItemDataPreview
		EXEC (@SqlQuery1) 
	 END 

	 -----------------------------------Handle Dynamic Query 14
	 IF (@strPromotionalItemysn IS NOT NULL)
	 BEGIN

		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				', ''Promotional Item'''
				, ', CASE WHEN a.ysnPromotionalItem = 0 THEN ''No'' ELSE ''Yes'' END'
				, ', ''' + CASE WHEN @strPromotionalItemysn = 0 THEN 'No' ELSE 'Yes' END +''''
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @strFamilyId
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
			)

		INSERT @tblUpdateItemDataPreview
		EXEC (@SqlQuery1) 
	 END 

	 -----------------------------------Handle Dynamic Query 15
	 IF (@strPrePricedysn IS NOT NULL)
	 BEGIN

		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				', ''Pre Priced'''
				, ', CASE WHEN a.ysnPrePriced = 0 THEN ''No'' ELSE ''Yes'' END'
				, ', ''' + CASE WHEN @strPrePricedysn = 0 THEN 'No' ELSE 'Yes' END +''''
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @strFamilyId
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
			)

		INSERT @tblUpdateItemDataPreview
		EXEC (@SqlQuery1) 
	 END 

	 -----------------------------------Handle Dynamic Query 16
	 IF (@strBlueLaw1ysn IS NOT NULL)
	 BEGIN

		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				', ''Blue Law1'''
				, ', CASE WHEN a.ysnApplyBlueLaw1 = 0 THEN ''No'' ELSE ''Yes'' END'
				, ', ''' + CASE WHEN @strBlueLaw1ysn = 0 THEN 'No' ELSE 'Yes' END +''''
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @strFamilyId
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
			)

		INSERT @tblUpdateItemDataPreview
		EXEC (@SqlQuery1) 
	 END 

	 -----------------------------------Handle Dynamic Query 17
	 IF (@strBlueLaw2ysn IS NOT NULL)
	 BEGIN

		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				', ''Blue Law2'''
				, ', CASE WHEN a.ysnApplyBlueLaw2 = 0 THEN ''No'' ELSE ''Yes'' END'
				, ', ''' + CASE WHEN @strBlueLaw2ysn = 0 THEN 'No' ELSE 'Yes' END +''''
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @strFamilyId
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
			)

		INSERT @tblUpdateItemDataPreview
		EXEC (@SqlQuery1) 
	 END 

	 -----------------------------------Handle Dynamic Query 18
	 IF (@strCountedDailyysn IS NOT NULL)
	 BEGIN

		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				', ''Counted Daily'''
				, ', CASE WHEN a.ysnCountedDaily = 0 THEN ''No'' ELSE ''Yes'' END'
				, ', ''' + CASE WHEN @strCountedDailyysn = 0 THEN 'No' ELSE 'Yes' END +''''
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @strFamilyId
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
			)

		INSERT @tblUpdateItemDataPreview
		EXEC (@SqlQuery1) 
	 END 

	 -----------------------------------Handle Dynamic Query 19
	 IF (@strCounted IS NOT NULL)
	 BEGIN

		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				', ''Counted'''
				, ', a.strCounted'
				, ', ''' + CAST(@strCounted AS NVARCHAR(250))  +''''
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @strFamilyId
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
			)

		INSERT @tblUpdateItemDataPreview
		EXEC (@SqlQuery1) 
	 END 

	 -----------------------------------Handle Dynamic Query 20
	 IF (@strCountSerialysn IS NOT NULL)
	 BEGIN

		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				', ''Count By Serial No'''
				, ', CASE WHEN a.ysnCountBySINo = 0 THEN ''No'' ELSE ''Yes'' END'
				, ', ''' + CASE WHEN @strCountSerialysn = 0 THEN 'No' ELSE 'Yes' END +''''
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @strFamilyId
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
			)

		INSERT @tblUpdateItemDataPreview
		EXEC (@SqlQuery1) 
	 END 

	 -----------------------------------Handle Dynamic Query 21
	 IF (@intNewFamily IS NOT NULL)
	 BEGIN

		SELECT @strFamilyIdId = strSubcategoryId FROM tblSTSubcategory WHERE intSubcategoryId = @intNewFamily

		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				', ''Family'''
				, ', (SELECT strSubcategoryId FROM tblSTSubcategory WHERE intSubcategoryId = a.intFamilyId)'
				, ', ''' + @strFamilyIdId +''''
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @strFamilyId
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
			)

		INSERT @tblUpdateItemDataPreview
		EXEC (@SqlQuery1) 
	 END 

	 -----------------------------------Handle Dynamic Query 22
	 IF (@intNewClass IS NOT NULL)
	 BEGIN

		SELECT @strClassIdId = strSubcategoryId from tblSTSubcategory where intSubcategoryId = @intNewClass

		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				', ''Class'''
				, ', (SELECT strSubcategoryId FROM tblSTSubcategory WHERE intSubcategoryId = a.intClassId )'
				, ', ''' + @strClassIdId +''''
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @strFamilyId
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
			)

		INSERT @tblUpdateItemDataPreview
		EXEC (@SqlQuery1) 
	 END 

	 -----------------------------------Handle Dynamic Query 23
	 IF (@intNewProductCode IS NOT NULL)
	 BEGIN

		SELECT @ProductCode = strRegProdCode from tblSTSubcategoryRegProd where intRegProdId = @intNewProductCode

		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				', ''Product Code'''
				, ', ( select strRegProdCode from tblSTSubcategoryRegProd where intRegProdId = a.intProductCodeId )'
				, ', ''' + @ProductCode +''''
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @strFamilyId
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
			)

		INSERT @tblUpdateItemDataPreview
		EXEC (@SqlQuery1) 
	 END 

	 -----------------------------------Handle Dynamic Query 24
	 IF (@intNewVendor IS NOT NULL)
	 BEGIN

		SELECT @strVendorIdId = strName from tblEMEntity where intEntityId = @intNewVendor

		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				', ''Vendor'''
				, ', ( select strName from tblEMEntity where intEntityId = a.intVendorId )'
				, ', ''' + @strVendorIdId +''''
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @strFamilyId
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
			)

		INSERT @tblUpdateItemDataPreview
		EXEC (@SqlQuery1) 
	 END 

	 -----------------------------------Handle Dynamic Query 25
	 IF (@intNewMinAge IS NOT NULL)
	 BEGIN

		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				', ''Minimum Age'''
				, ', a.intMinimumAge'
				, ', ''' + CAST(@intNewMinAge AS NVARCHAR(250))  +''''
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @strFamilyId
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
			)

		INSERT @tblUpdateItemDataPreview
		EXEC (@SqlQuery1) 
	 END

	 -----------------------------------Handle Dynamic Query 26
	 IF (@dblNewMinVendorOrderQty IS NOT NULL)
	 BEGIN

		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				', ''Vendor Minimum Order Qty'''
				, ', a.dblMinOrder'
				, ', ''' + CAST(@dblNewMinVendorOrderQty AS NVARCHAR(250))  +''''
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @strFamilyId
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
			)

		INSERT @tblUpdateItemDataPreview
		EXEC (@SqlQuery1) 
	 END

	 -----------------------------------Handle Dynamic Query 27
	 IF (@dblNewVendorSuggestedQty IS NOT NULL)
	 BEGIN

		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				', ''Vendor Suggested Qty'''
				, ', a.dblSuggestedQty'
				, ', ''' + CAST(@dblNewVendorSuggestedQty AS NVARCHAR(250))  +''''
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @strFamilyId
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
			)

		INSERT @tblUpdateItemDataPreview
		EXEC (@SqlQuery1) 
	 END

	 -----------------------------------Handle Dynamic Query 28
	 IF (@dblNewMinQtyOnHand IS NOT NULL)
	 BEGIN

		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				', ''Min Qty On Hand'''
				, ', a.dblReorderPoint'
				, ', ''' + CAST(@dblNewMinQtyOnHand AS NVARCHAR(250))  +''''
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @strFamilyId
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
			)

		INSERT @tblUpdateItemDataPreview
		EXEC (@SqlQuery1) 
	 END

	 -----------------------------------Handle Dynamic Query 29
	 IF (@intNewInventoryGroup IS NOT NULL)
	 BEGIN

		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				', ''Inventory Group'''
				, ', ( SELECT strCountGroup FROM tblICCountGroup WHERE intCountGroupId = a.intCountGroupId )'
				, ', ''' + CAST(@intNewInventoryGroup AS NVARCHAR(250))  +''''
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @strFamilyId
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
			)

		INSERT @tblUpdateItemDataPreview
		EXEC (@SqlQuery1) 
	 END

	 -----------------------------------Handle Dynamic Query 30
	 IF (@strNewCountCode IS NOT NULL)
	 BEGIN

		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				', ''Count Code'''
				, ', a.strCountCode'
				, ', ''' + CAST(@strNewCountCode AS NVARCHAR(250))  +''''
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @strFamilyId
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
			)

		INSERT @tblUpdateItemDataPreview
		EXEC (@SqlQuery1) 
	 END

	 -----------------------------------Handle Dynamic Query 31
	 IF (@intNewBinLocation IS NOT NULL)
	 BEGIN

		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				', ''Storage Location'''
				, ', ( select strName from tblICStorageLocation where intStorageLocationId = a.intStorageLocationId )'
				, ', ( select strName from tblICStorageLocation where intStorageLocationId =  CAST( ' +  LTRIM(@intNewBinLocation) +' AS INT))'
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @strFamilyId
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
			)

		INSERT @tblUpdateItemDataPreview
		EXEC (@SqlQuery1) 
	 END

	 -----------------------------------Handle Dynamic Query 32
	 IF (@intNewGLPurchaseAccount IS NOT NULL)
	 BEGIN

		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				', ''Purchase Account'''
				, ', ( select strAccountId from tblGLAccount where intAccountId = e.intAccountId )'
				, ', ( select strAccountId from tblGLAccount where intAccountId =  CAST( ' +  LTRIM(@intNewGLPurchaseAccount) +' AS INT))'
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @strFamilyId
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
			)

		INSERT @tblUpdateItemDataPreview
		EXEC (@SqlQuery1) 
	 END

	 -----------------------------------Handle Dynamic Query 33
	 IF (@intNewGLSalesAccount IS NOT NULL)
	 BEGIN

		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				', ''Sales Account'''
				, ', ( select strAccountId from tblGLAccount where intAccountId = e.intAccountId )'
				, ', ( select strAccountId from tblGLAccount where intAccountId =  CAST( ' +  LTRIM(@intNewGLSalesAccount) +' AS INT))'
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @strFamilyId
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
			)

		INSERT @tblUpdateItemDataPreview
		EXEC (@SqlQuery1) 
	 END

	 -----------------------------------Handle Dynamic Query 34
	 IF (@intNewGLVarianceAccount IS NOT NULL)
	 BEGIN

		    SET @SqlQuery1 = dbo.fnSTDynamicQueryItemData
			(
				', ''Variance Account'''
				, ', ( select strAccountId from tblGLAccount where intAccountId = e.intAccountId )'
				, ', ( select strAccountId from tblGLAccount where intAccountId =  CAST( ' +  LTRIM(@intNewGLVarianceAccount) +' AS INT))'
				, @strCompanyLocationId
				, @strVendorId
				, @strCategoryId
				, @strFamilyId
				, @strClassId
				, @intUpcCode
				, @strDescription
				, @dblPriceBetween1
				, @dblPriceBetween2
			)

		INSERT @tblUpdateItemDataPreview
		EXEC (@SqlQuery1) 
	 END


	 SELECT @UpdateCount = count(*) from @tblUpdateItemDataPreview WHERE strOldData != strNewData



	 ---Update Logic-------
			      
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
	     
		  SET @UpdateCount = 0

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

             IF (@strFamilyId IS NOT NULL)
		         BEGIN
  			            set @SqlQuery1 = @SqlQuery1 +  ' and  tblICItemLocation.intFamilyId
		             	       IN (' + CAST(@strFamilyId as NVARCHAR) + ')' 
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

		  SELECT  @UpdateCount =   @UpdateCount + (@@ROWCOUNT)   
	 END	  
END



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

         IF (@strFamilyId IS NOT NULL)
		     BEGIN
  		           SET @SqlQuery1 = @SqlQuery1 +  ' and tblICItem.intItemId IN 
			              (select intItemId from tblICItemLocation where intFamilyId IN
					       (' + CAST(@strFamilyId as NVARCHAR) + ')' + ')'
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
		  SELECT  @UpdateCount =   @UpdateCount + (@@ROWCOUNT)   	  
	END
END

IF((@strYsnPreview != 'Y')
AND(@UpdateCount > 0))
BEGIN
      IF ((@intNewGLPurchaseAccount IS NOT NULL)
	  OR (@intNewGLSalesAccount IS NOT NULL)    
	  OR (@intNewGLVarianceAccount IS NOT NULL))
	  BEGIN
	          
	         IF (@intNewGLPurchaseAccount IS NOT NULL)
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
     	            SET @SqlQuery1 = @SqlQuery1 +  ' and  tblICItemAccount.intCategoryId
		             	       IN (' + CAST(@strCategoryId as NVARCHAR) + ')' 
		        END

                IF (@strFamilyId IS NOT NULL)
		        BEGIN
  		           SET @SqlQuery1 = @SqlQuery1 +  ' and tblICItemAccount.intItemId IN 
			              (select intItemId from tblICItemLocation where intFamilyId IN
					       (' + CAST(@strFamilyId as NVARCHAR) + ')' + ')'
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
			      SET @SqlQuery1 = @SqlQuery1 +  ' and tblICItemAccount.strDescription like ''%' + LTRIM(@strDescription) + '%'' '
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

				SET @SqlQuery1 = @SqlQuery1 + ' and  intAccountCategoryId = 30 '

                EXEC (@SqlQuery1)
				
		        SELECT  @UpdateCount =   @UpdateCount + (@@ROWCOUNT)   	  
			 END

             IF (@intNewGLSalesAccount IS NOT NULL)
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
		            SET @SqlQuery1 = @SqlQuery1 +  ' and tblICItemAccount.intItemId IN 
			              (select intItemId from tblICItemLocation where intVendorId IN
					       (' + CAST(@strVendorId as NVARCHAR) + ')' + ')'
		        END

                IF (@strCategoryId IS NOT NULL)
		        BEGIN
     	            SET @SqlQuery1 = @SqlQuery1 +  ' and  tblICItemAccount.intCategoryId
		             	       IN (' + CAST(@strCategoryId as NVARCHAR) + ')' 
		        END

                IF (@strFamilyId IS NOT NULL)
		        BEGIN
  		           SET @SqlQuery1 = @SqlQuery1 +  ' and tblICItemAccount.intItemId IN 
			              (select intItemId from tblICItemLocation where intFamilyId IN
					       (' + CAST(@strFamilyId as NVARCHAR) + ')' + ')'
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
			      SET @SqlQuery1 = @SqlQuery1 +  ' and tblICItemAccount.strDescription like ''%' + LTRIM(@strDescription) + '%'' '
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

				SET @SqlQuery1 = @SqlQuery1 + ' and  intAccountCategoryId = 33 '

                EXEC (@SqlQuery1)
				
		        SELECT  @UpdateCount =   @UpdateCount + (@@ROWCOUNT)   	  
			 END
             
			 IF (@intNewGLVarianceAccount IS NOT NULL)
			 BEGIN
			    
				SET @SqlQuery1 = ' update tblICItemAccount set '  

			    SET @SqlQuery1 = @SqlQuery1 + ' intAccountId = ''' + LTRIM(@intNewGLVarianceAccount) + '''' 

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
     	            SET @SqlQuery1 = @SqlQuery1 +  ' and  tblICItemAccount.intCategoryId
		             	       IN (' + CAST(@strCategoryId as NVARCHAR) + ')' 
		        END

                IF (@strFamilyId IS NOT NULL)
		        BEGIN
  		           SET @SqlQuery1 = @SqlQuery1 +  ' and tblICItemAccount.intItemId IN 
			              (select intItemId from tblICItemLocation where intFamilyId IN
					       (' + CAST(@strFamilyId as NVARCHAR) + ')' + ')'
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
			      SET @SqlQuery1 = @SqlQuery1 +  ' and tblICItemAccount.strDescription like ''%' + LTRIM(@strDescription) + '%'' '
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

				SET @SqlQuery1 = @SqlQuery1 + ' and  intAccountCategoryId = 40 '

                EXEC (@SqlQuery1)
				
		        SELECT  @UpdateCount =   @UpdateCount + (@@ROWCOUNT)   	  
			 END
	  END
END










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

   SELECT @strCompanyName as CompanyName
		  , LEFT(DATENAME(DW,GETDATE()),10) + ' ' + DATENAME(MONTH, SYSDATETIME())+ ' ' + RIGHT('0' + DATENAME(DAY, SYSDATETIME()), 2) + ', ' + DATENAME(YEAR, SYSDATETIME()) as DateToday
		  , RIGHT('0' + LTRIM(STUFF(RIGHT(CONVERT(CHAR(26), CURRENT_TIMESTAMP, 109), 14),9, 4, ' ')),11) as TimeToday
		  , strLocation
		  , strUpc
		  , strItemDescription
		  , strChangeDescription
		  , strOldData
		  , strNewData
   FROM @tblUpdateItemDataPreview
    
   DELETE FROM @tblUpdateItemDataPreview

END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
END CATCH