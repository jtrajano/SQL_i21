CREATE PROCEDURE [dbo].[uspSTReportUpdateItemPricingPreview]
	@xmlParam NVARCHAR(MAX) = NULL
AS

BEGIN TRANSACTION

	DECLARE @ErrMsg NVARCHAR(MAX)

	DECLARE @UpdateCount INT
	SET @UpdateCount = 0

	--START Handle xml Param
	DECLARE @strCompanyLocationId NVARCHAR(MAX)
			, @strVendorId NVARCHAR(MAX)
			, @strCategoryId NVARCHAR(MAX)
			, @strFamilyId NVARCHAR(MAX)
			, @strClassId NVARCHAR(MAX)
			, @strDescription NVARCHAR(MAX)
			, @strRegion NVARCHAR(MAX)
			, @strDistrict NVARCHAR(MAX)
			, @strState NVARCHAR(MAX)
			, @intUpcCode INT
			, @dblStandardCost DECIMAL (18,6)
			, @dblRetailPrice DECIMAL (18,6)
			, @dblSalesPrice DECIMAL (18,6)
			, @dtmSalesStartingDate DATE
			, @dtmSalesEndingDate DATE
			, @ysnPreview NVARCHAR(1)
			, @intCurrentUserId INT


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

	--START FILTERS
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

	--strRegion
	SELECT @strRegion = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strRegion'

	--strDistrict
	SELECT @strDistrict = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strDistrict'

	--strState
	SELECT @strState = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strState'
	--END OF FILTERS



	-- UPDATE FIELDS
	--dblCost
	SELECT @dblStandardCost = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'dblCost'

	--dblRetail
	SELECT @dblRetailPrice = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'dblRetail'

	--dblSalesPrice
	SELECT @dblSalesPrice = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'dblSalesPrice'

	--dtmSalesStartingDate
	SELECT @dtmSalesStartingDate = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'dtmSalesStartingDate'

	--dtmSalesEndingDate
	SELECT @dtmSalesEndingDate = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'dtmSalesEndingDate'
	-- END OF UPDATE FIELDS



	--ysnPreview
	SELECT @ysnPreview = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'ysnPreview'

	--currentUserId
	SELECT @intCurrentUserId = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intCurrentUserId'



	-- Create the filter tables
	BEGIN
		CREATE TABLE #tmpUpdateItemPricingForCStore_Location (
			intLocationId INT 
		)

		CREATE TABLE #tmpUpdateItemPricingForCStore_Vendor (
			intVendorId INT 
		)

		CREATE TABLE #tmpUpdateItemPricingForCStore_Category (
			intCategoryId INT 
		)

		CREATE TABLE #tmpUpdateItemPricingForCStore_Family (
			intFamilyId INT 
		)

		CREATE TABLE #tmpUpdateItemPricingForCStore_Class (
			intClassId INT 
		)

		-- Create the temp table for the audit log. 
		IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_ItemPricingAuditLog') IS NULL  
			CREATE TABLE #tmpUpdateItemPricingForCStore_ItemPricingAuditLog (
				intItemId INT
				,intItemPricingId INT 
				,dblOldStandardCost NUMERIC(38, 20) NULL
				,dblOldSalePrice NUMERIC(38, 20) NULL
				,dblNewStandardCost NUMERIC(38, 20) NULL
				,dblNewSalePrice NUMERIC(38, 20) NULL
			)
		;

		-- Create the temp table for the audit log. 
		IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_ItemSpecialPricingAuditLog') IS NULL  
			CREATE TABLE #tmpUpdateItemPricingForCStore_ItemSpecialPricingAuditLog (
				intItemId INT 
				,intItemSpecialPricingId INT 
				,dblOldUnitAfterDiscount NUMERIC(38, 20) NULL 
				,dtmOldBeginDate DATETIME NULL 
				,dtmOldEndDate DATETIME NULL 
				,dblNewUnitAfterDiscount NUMERIC(38, 20) NULL 
				,dtmNewBeginDate DATETIME NULL
				,dtmNewEndDate DATETIME NULL 		
			)
		;
	END



	-- Add the filter records
	BEGIN
		IF(@strCompanyLocationId IS NOT NULL AND @strCompanyLocationId != '')
			BEGIN
				INSERT INTO #tmpUpdateItemPricingForCStore_Location (
					intLocationId
				)
				SELECT intLocationId = CAST(@strCompanyLocationId AS INT)
			END
		
		IF(@strVendorId IS NOT NULL AND @strVendorId != '')
			BEGIN
				INSERT INTO #tmpUpdateItemPricingForCStore_Vendor (
					intVendorId
				)
				SELECT intVendorId = CAST(@strVendorId AS INT)
			END

		IF(@strCategoryId IS NOT NULL AND @strCategoryId != '')
			BEGIN
				INSERT INTO #tmpUpdateItemPricingForCStore_Category (
					intCategoryId
				)
				SELECT intCategoryId = CAST(@strCategoryId AS INT)
			END

		IF(@strFamilyId IS NOT NULL AND @strFamilyId != '')
			BEGIN
				INSERT INTO #tmpUpdateItemPricingForCStore_Family (
					intFamilyId
				)
				SELECT intFamilyId = CAST(@strFamilyId AS INT)
			END

		IF(@strClassId IS NOT NULL AND @strClassId != '')
			BEGIN
				INSERT INTO #tmpUpdateItemPricingForCStore_Class (
					intClassId
				)
				SELECT intClassId = CAST(@strClassId AS INT)
			END
	END

	DECLARE @dblStandardCostConv AS DECIMAL(18, 6) = CAST(@dblStandardCost AS DECIMAL(18, 6))
	DECLARE @dblRetailPriceConv AS DECIMAL(18, 6) = CAST(@dblRetailPrice AS DECIMAL(18, 6))
	DECLARE @intCurrentUserIdConv AS INT = CAST(@intCurrentUserId AS INT)

	-- ITEM PRICING
	EXEC [uspICUpdateItemPricingForCStore]
		@dblStandardCost = @dblStandardCostConv
		,@dblRetailPrice = @dblRetailPriceConv
		,@intEntityUserSecurityId = @intCurrentUserIdConv



	DECLARE @dblSalesPriceConv AS DECIMAL(18, 6) = CAST(@dblSalesPrice AS DECIMAL(18, 6))
	DECLARE @dtmSalesStartingDateConv AS DATE = CAST(@dtmSalesStartingDate AS DATE)
	DECLARE @dtmSalesEndingDateConv AS DATE = CAST(@dtmSalesEndingDate AS DATE)

	-- ITEM SPECIAL PRICING
	EXEC [dbo].[uspICUpdateItemPromotionalPricingForCStore]
		@dblPromotionalSalesPrice = @dblSalesPriceConv 
		,@dtmBeginDate = @dtmSalesStartingDateConv
		,@dtmEndDate = @dtmSalesEndingDateConv 
		,@intEntityUserSecurityId = @intCurrentUserIdConv


	-- Handle preview using Table variable
	DECLARE @tblPreview TABLE (
	    intCompanyLocationId INT
		, strLocation NVARCHAR(250)
		, strUpc NVARCHAR(50)
		, strItemDescription NVARCHAR(250)
		, strChangeDescription NVARCHAR(100)
		, strOldData NVARCHAR(MAX)
		, strNewData NVARCHAR(MAX)
		, intParentId INT
		, intChildId INT
	)

	-- ITEM PRICING
	INSERT INTO @tblPreview (
		intCompanyLocationId
		, strLocation
		, strUpc
		, strItemDescription
		, strChangeDescription
		, strOldData
		, strNewData
		, intParentId
		, intChildId
	)
	SELECT	CL.intCompanyLocationId
	        ,CL.strLocationName
			,UOM.strLongUPCCode
			,I.strDescription
			,CASE
				WHEN [Changes].dblOldStandardCost IS NOT NULL AND ISNULL([Changes].dblOldStandardCost, 0) != ISNULL([Changes].dblNewStandardCost, 0) THEN 'Standard Cost'
				WHEN [Changes].dblOldSalePrice IS NOT NULL AND ISNULL([Changes].dblOldSalePrice, 0) != ISNULL([Changes].dblNewSalePrice, 0) THEN 'Retail Price'
			 END
			,CASE
				WHEN [Changes].dblOldStandardCost IS NOT NULL AND ISNULL([Changes].dblOldStandardCost, 0) != ISNULL([Changes].dblNewStandardCost, 0) THEN CAST(CAST(ISNULL([Changes].dblOldStandardCost, 0) AS DECIMAL(18,2)) AS NVARCHAR(50))
				WHEN [Changes].dblOldSalePrice IS NOT NULL AND ISNULL([Changes].dblOldSalePrice, 0) != ISNULL([Changes].dblNewSalePrice, 0) THEN CAST(CAST(ISNULL([Changes].dblOldSalePrice, 0) AS DECIMAL(18,2)) AS NVARCHAR(50))
			 END
			,CASE
				WHEN [Changes].dblNewStandardCost IS NOT NULL AND ISNULL([Changes].dblOldStandardCost, 0) != ISNULL([Changes].dblNewStandardCost, 0) THEN CAST(CAST(ISNULL([Changes].dblNewStandardCost, 0) AS DECIMAL(18,2)) AS NVARCHAR(50))
				WHEN [Changes].dblNewSalePrice IS NOT NULL AND ISNULL([Changes].dblOldSalePrice, 0) != ISNULL([Changes].dblNewSalePrice, 0) THEN CAST(CAST(ISNULL([Changes].dblNewSalePrice, 0) AS DECIMAL(18,2)) AS NVARCHAR(50))
			 END
	        ,[Changes].intItemId 
			,[Changes].intItemPricingId
	FROM #tmpUpdateItemPricingForCStore_ItemPricingAuditLog [Changes]
	JOIN tblICItem I ON [Changes].intItemId = I.intItemId
	JOIN tblICItemPricing IP ON [Changes].intItemPricingId = IP.intItemPricingId
	JOIN tblICItemUOM UOM ON IP.intItemId = UOM.intItemId
	JOIN tblICItemLocation IL ON IP.intItemLocationId = IL.intItemLocationId AND IP.intItemLocationId = IL.intItemLocationId
	JOIN tblSMCompanyLocation CL ON IL.intLocationId = CL.intCompanyLocationId



	-- ITEM SPECIAL PRICING
	INSERT INTO @tblPreview (
		intCompanyLocationId
		, strLocation
		, strUpc
		, strItemDescription
		, strChangeDescription
		, strOldData
		, strNewData
		, intParentId
		, intChildId
	)
	SELECT	CL.intCompanyLocationId
	        ,CL.strLocationName
			,UOM.strLongUPCCode
			,I.strDescription
			,CASE
				WHEN [Changes].dblOldUnitAfterDiscount IS NOT NULL AND ISNULL([Changes].dblOldUnitAfterDiscount, 0) != ISNULL([Changes].dblNewUnitAfterDiscount, 0) THEN 'Sales Price'
				WHEN [Changes].dtmOldBeginDate IS NOT NULL AND CAST([Changes].dtmOldBeginDate AS DATE) != CAST([Changes].dtmNewBeginDate AS DATE) THEN 'Sales Starting Date'
				WHEN [Changes].dtmOldEndDate IS NOT NULL AND CAST([Changes].dtmOldEndDate AS DATE) != CAST([Changes].dtmNewEndDate AS DATE) THEN 'Sales Ending Date'
			 END
			,CASE
				WHEN [Changes].dblOldUnitAfterDiscount IS NOT NULL AND ISNULL([Changes].dblOldUnitAfterDiscount, 0) != ISNULL([Changes].dblNewUnitAfterDiscount, 0) THEN CAST(CAST(ISNULL([Changes].dblOldUnitAfterDiscount, 0) AS DECIMAL(18,2)) AS NVARCHAR(50))
				WHEN [Changes].dtmOldBeginDate IS NOT NULL AND CAST([Changes].dtmOldBeginDate AS DATE) != CAST([Changes].dtmNewBeginDate AS DATE) THEN CAST(CAST([Changes].dtmOldBeginDate AS DATE) AS NVARCHAR(50))
				WHEN [Changes].dtmOldEndDate IS NOT NULL AND CAST([Changes].dtmOldEndDate AS DATE) != CAST([Changes].dtmNewEndDate AS DATE) THEN CAST(CAST([Changes].dtmOldEndDate AS DATE) AS NVARCHAR(50))
			 END
			,CASE
				WHEN [Changes].dblNewUnitAfterDiscount IS NOT NULL AND ISNULL([Changes].dblOldUnitAfterDiscount, 0) != ISNULL([Changes].dblNewUnitAfterDiscount, 0) THEN CAST(CAST(ISNULL([Changes].dblNewUnitAfterDiscount, 0) AS DECIMAL(18,2)) AS NVARCHAR(50))
				WHEN [Changes].dtmNewBeginDate IS NOT NULL AND CAST([Changes].dtmOldBeginDate AS DATE) != CAST([Changes].dtmNewBeginDate AS DATE) THEN CAST(CAST([Changes].dtmNewBeginDate AS DATE) AS NVARCHAR(50))
				WHEN [Changes].dtmNewEndDate IS NOT NULL AND CAST([Changes].dtmOldEndDate AS DATE) != CAST([Changes].dtmNewEndDate AS DATE) THEN CAST(CAST([Changes].dtmNewEndDate AS DATE) AS NVARCHAR(50))
			 END
	        ,[Changes].intItemId 
			,[Changes].intItemSpecialPricingId
	FROM #tmpUpdateItemPricingForCStore_ItemSpecialPricingAuditLog [Changes]
	JOIN tblICItem I ON [Changes].intItemId = I.intItemId
	JOIN tblICItemSpecialPricing IP ON [Changes].intItemSpecialPricingId = IP.intItemSpecialPricingId
	JOIN tblICItemUOM UOM ON IP.intItemId = UOM.intItemId
	JOIN tblICItemLocation IL ON IP.intItemLocationId = IL.intItemLocationId AND IP.intItemLocationId = IL.intItemLocationId
	JOIN tblSMCompanyLocation CL ON IL.intLocationId = CL.intCompanyLocationId


   DELETE FROM @tblPreview WHERE ISNULL(strOldData, '') = ISNULL(strNewData, '')

   -- Query Preview display
   SELECT strLocation
		  , strUpc
		  , strItemDescription
		  , strChangeDescription
		  , strOldData
		  , strNewData
   FROM @tblPreview
   ORDER BY strItemDescription, strChangeDescription ASC
    
   DELETE FROM @tblPreview

ROLLBACK TRANSACTION