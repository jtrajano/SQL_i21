CREATE PROCEDURE [dbo].[uspSTUpdateItemPricing]
	@XML varchar(max)
	, @strEntityIds AS NVARCHAR(MAX) OUTPUT
AS
BEGIN TRY

	SET @strEntityIds = ''

	DECLARE @ErrMsg				NVARCHAR(MAX),
	        @idoc				INT,
			@Location 			NVARCHAR(MAX),
			@Vendor             NVARCHAR(MAX),
			@Category           NVARCHAR(MAX),
			@Family             NVARCHAR(MAX),
			@Class              NVARCHAR(MAX),
			@Description        NVARCHAR(250),
			@Region             NVARCHAR(6),
			@District           NVARCHAR(6),
			@State              NVARCHAR(2),
			@intItemUOMId       INT, --NVARCHAR(MAX),
			@StandardCost       DECIMAL (18,6),
			@RetailPrice        DECIMAL (18,6),
			@SalesPrice         DECIMAL (18,6),
		    @SalesStartDate		NVARCHAR(50),
			@SalesEndDate   	NVARCHAR(50),
			@ysnPreview			NVARCHAR(1),
			@currentUserId		INT
		
	                  
	EXEC sp_xml_preparedocument @idoc OUTPUT, @XML 
	
	SELECT	
			@Location		 =	 Location,
            @Vendor          =   Vendor,
			@Category        =   Category,
			@Family          =   Family,
            @Class           =   Class,
            @Description     =   ItmDescription,
			@Region          =   Region,
			@District        =   District,
			@State           =   States,
			@intItemUOMId    =   UPCCode,
			@StandardCost 	 = 	 Cost,
			@RetailPrice   	 =	 Retail,
			@SalesPrice		 =	 SalesPrice,
			@SalesStartDate	 =	 SalesStartingDate,
			@SalesEndDate	 =	 SalesEndingDate,
			@ysnPreview		 =   ysnPreview,
			@currentUserId   =   currentUserId
		
	FROM	OPENXML(@idoc, 'root',2)
	WITH
	(
			Location		        NVARCHAR(MAX),
			Vendor	     	        NVARCHAR(MAX),
			Category		        NVARCHAR(MAX),
			Family	     	        NVARCHAR(MAX),
			Class	     	        NVARCHAR(MAX),
			ItmDescription		    NVARCHAR(250),
			Region                  NVARCHAR(6),
			District                NVARCHAR(6),
			States                  NVARCHAR(2),
			UPCCode		            INT,
			Cost		            DECIMAL (18,6),
			Retail		            DECIMAL (18,6),
			SalesPrice       		DECIMAL (18,6),
			SalesStartingDate		NVARCHAR(50),
			SalesEndingDate			NVARCHAR(50),
			ysnPreview				NVARCHAR(1),
			currentUserId			INT
	)  
    -- Insert statements for procedure here


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
				,dblOldLastCost NUMERIC(38, 20) NULL
				,dblNewStandardCost NUMERIC(38, 20) NULL
				,dblNewSalePrice NUMERIC(38, 20) NULL
				,dblNewLastCost NUMERIC(38, 20) NULL
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
		IF(@Location IS NOT NULL AND @Location != '')
			BEGIN
				INSERT INTO #tmpUpdateItemPricingForCStore_Location (
					intLocationId
				)
				--SELECT intLocationId = 2
				SELECT [intID] AS intLocationId
				FROM [dbo].[fnGetRowsFromDelimitedValues](@Location)
			END
		
		IF(@Vendor IS NOT NULL AND @Vendor != '')
			BEGIN
				INSERT INTO #tmpUpdateItemPricingForCStore_Vendor (
					intVendorId
				)
				--SELECT intVendorId = CAST(@Vendor AS INT)
				SELECT [intID] AS intVendorId
				FROM [dbo].[fnGetRowsFromDelimitedValues](@Vendor)
			END

		IF(@Category IS NOT NULL AND @Category != '')
			BEGIN
				INSERT INTO #tmpUpdateItemPricingForCStore_Category (
					intCategoryId
				)
				--SELECT intCategoryId = CAST(@Category AS INT)
				SELECT [intID] AS intCategoryId
				FROM [dbo].[fnGetRowsFromDelimitedValues](@Category)
			END

		IF(@Family IS NOT NULL AND @Family != '')
			BEGIN
				INSERT INTO #tmpUpdateItemPricingForCStore_Family (
					intFamilyId
				)
				--SELECT intFamilyId = CAST(@Family AS INT)
				SELECT [intID] AS intFamilyId
				FROM [dbo].[fnGetRowsFromDelimitedValues](@Family)
			END

		IF(@Class IS NOT NULL AND @Class != '')
			BEGIN
				INSERT INTO #tmpUpdateItemPricingForCStore_Class (
					intClassId
				)
				--SELECT intClassId = CAST(@Class AS INT)
				SELECT [intID] AS intClassId
				FROM [dbo].[fnGetRowsFromDelimitedValues](@Class)
			END
	END



	-- Get strUpcCode
	DECLARE @strUpcCode AS NVARCHAR(20) = (
											SELECT CASE
													WHEN strLongUPCCode IS NOT NULL AND strLongUPCCode != '' THEN strLongUPCCode ELSE strUpcCode
											END AS strUpcCode
											FROM tblICItemUOM 
											WHERE intItemUOMId = @intItemUOMId
											)

	DECLARE @dblStandardCostConv AS NUMERIC(38, 20) = CAST(@StandardCost AS NUMERIC(38, 20))
	DECLARE @dblRetailPriceConv AS NUMERIC(38, 20) = CAST(@RetailPrice AS NUMERIC(38, 20))
	DECLARE @intCurrentUserIdConv AS INT = CAST(@currentUserId AS INT)


	-- ITEM PRICING
	EXEC [uspICUpdateItemPricingForCStore]
		  @strUpcCode = @strUpcCode
		, @strDescription = @Description -- NOTE: Description cannot be '' or empty string, it should be NULL value instead of empty string
		, @intItemId = NULL
		, @dblStandardCost = @dblStandardCostConv
		, @dblRetailPrice = @dblRetailPriceConv
		, @intEntityUserSecurityId = @intCurrentUserIdConv



	DECLARE @dblSalesPriceConv AS DECIMAL(18, 6) = CAST(@SalesPrice AS DECIMAL(18, 6))
	DECLARE @dtmSalesStartingDateConv AS DATE = CAST(@SalesStartDate AS DATE)
	DECLARE @dtmSalesEndingDateConv AS DATE = CAST(@SalesEndDate AS DATE)

	-- ITEM SPECIAL PRICING
	EXEC [dbo].[uspICUpdateItemPromotionalPricingForCStore]
		 @dblPromotionalSalesPrice = @dblSalesPriceConv 
		,@dtmBeginDate = @dtmSalesStartingDateConv
		,@dtmEndDate = @dtmSalesEndingDateConv 
		,@intEntityUserSecurityId = @intCurrentUserIdConv


	
	-------------------------------------------------------------------------------------------------
	----------- Count Items -------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------
	BEGIN
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
					WHEN [Changes].oldColumnName = 'strStandardCost_Original' THEN 'Standard Cost'
					WHEN [Changes].oldColumnName = 'strSalePrice_Original' THEN 'Sale Price'
					WHEN [Changes].oldColumnName = 'strLastCost_Original' THEN 'Last Cost'
				END
				,[Changes].strOldData
				,[Changes].strNewData
				,[Changes].intItemId 
				,[Changes].intItemPricingId
		FROM 
		(
			SELECT DISTINCT intItemId, intItemPricingId, oldColumnName, strOldData, strNewData
			FROM 
			(
				SELECT intItemId
				   , intItemPricingId
				   , CAST(CAST(dblOldStandardCost AS DECIMAL(18,3)) AS NVARCHAR(50)) AS strStandardCost_Original
				   , CAST(CAST(dblOldSalePrice AS DECIMAL(18,3))  AS NVARCHAR(50)) AS strSalePrice_Original
				   , CAST(CAST(dblOldLastCost AS DECIMAL(18,3))  AS NVARCHAR(50)) AS strLastCost_Original
				   , CAST(CAST(dblNewStandardCost AS DECIMAL(18,3))  AS NVARCHAR(50)) AS strStandardCost_New
				   , CAST(CAST(dblNewSalePrice AS DECIMAL(18,3))  AS NVARCHAR(50)) AS strSalePrice_New
				   , CAST(CAST(dblNewLastCost AS DECIMAL(18,3))  AS NVARCHAR(50)) AS strLastCost_New
				FROM #tmpUpdateItemPricingForCStore_ItemPricingAuditLog
			) t
			unpivot
			(
				strOldData for oldColumnName in (strStandardCost_Original, strSalePrice_Original, strLastCost_Original)
			) o
			unpivot
			(
				strNewData for newColumnName in (strStandardCost_New, strSalePrice_New, strLastCost_New)
			) n
			WHERE  REPLACE(oldColumnName, '_Original', '') = REPLACE(newColumnName, '_New', '')	
		) [Changes]
		JOIN tblICItem I ON [Changes].intItemId = I.intItemId
		JOIN tblICItemPricing IP ON [Changes].intItemPricingId = IP.intItemPricingId
		JOIN tblICItemUOM UOM ON IP.intItemId = UOM.intItemId
		JOIN tblICItemLocation IL ON IP.intItemLocationId = IL.intItemLocationId AND IP.intItemLocationId = IL.intItemLocationId
		JOIN tblSMCompanyLocation CL ON IL.intLocationId = CL.intCompanyLocationId
		WHERE 
		(
			NOT EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemPricingForCStore_Location)
			OR EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemPricingForCStore_Location WHERE intLocationId = CL.intCompanyLocationId) 			
		)
		AND 
		(
			NOT EXISTS (SELECT TOP 1 1 FROM tblICItemUOM WHERE intItemUOMId = @intItemUOMId)
			OR EXISTS (SELECT TOP 1 1 FROM tblICItemUOM WHERE intItemUOMId = @intItemUOMId AND intItemUOMId = UOM.intItemUOMId) 		
		)


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
					WHEN [Changes].oldColumnName = 'strUnitAfterDiscount_Original' THEN 'Unit After Discount'
					WHEN [Changes].oldColumnName = 'strBeginDate_Original' THEN 'Begin Date'
					WHEN [Changes].oldColumnName = 'strEndDate_Original' THEN 'End Date'
				END
				,[Changes].strOldData
				,[Changes].strNewData
				,[Changes].intItemId 
				,[Changes].intItemSpecialPricingId
		FROM 
		(
			SELECT DISTINCT intItemId, intItemSpecialPricingId, oldColumnName, strOldData, strNewData
			FROM 
			(
				SELECT intItemId 
					,intItemSpecialPricingId 
					,CAST(CAST(dblOldUnitAfterDiscount AS DECIMAL(18,3)) AS NVARCHAR(50)) AS strUnitAfterDiscount_Original
					,CAST(CAST(dtmOldBeginDate AS DATE) AS NVARCHAR(50)) AS strBeginDate_Original
					,CAST(CAST(dtmOldEndDate AS DATE) AS NVARCHAR(50)) AS strEndDate_Original
					,CAST(CAST(dblNewUnitAfterDiscount AS DECIMAL(18,3)) AS NVARCHAR(50)) AS strUnitAfterDiscount_New
					,CAST(CAST(dtmNewBeginDate AS DATE) AS NVARCHAR(50)) AS strBeginDate_New
					,CAST(CAST(dtmNewEndDate AS DATE) AS NVARCHAR(50)) AS strEndDate_New
				FROM #tmpUpdateItemPricingForCStore_ItemSpecialPricingAuditLog
			) t
			unpivot
			(
				strOldData for oldColumnName in (strUnitAfterDiscount_Original, strBeginDate_Original, strEndDate_Original)
			) o
			unpivot
			(
				strNewData for newColumnName in (strUnitAfterDiscount_New, strBeginDate_New, strEndDate_New)
			) n
			WHERE  REPLACE(oldColumnName, '_Original', '') = REPLACE(newColumnName, '_New', '')	
		
		) [Changes]
		JOIN tblICItem I ON [Changes].intItemId = I.intItemId
		JOIN tblICItemSpecialPricing IP ON [Changes].intItemSpecialPricingId = IP.intItemSpecialPricingId
		JOIN tblICItemUOM UOM ON IP.intItemId = UOM.intItemId
		JOIN tblICItemLocation IL ON IP.intItemLocationId = IL.intItemLocationId AND IP.intItemLocationId = IL.intItemLocationId
		JOIN tblSMCompanyLocation CL ON IL.intLocationId = CL.intCompanyLocationId
		WHERE 
		(
			NOT EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemPricingForCStore_Location)
			OR EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemPricingForCStore_Location WHERE intLocationId = CL.intCompanyLocationId) 			
		)
		AND 
		(
			NOT EXISTS (SELECT TOP 1 1 FROM tblICItemUOM WHERE intItemUOMId = @intItemUOMId)
			OR EXISTS (SELECT TOP 1 1 FROM tblICItemUOM WHERE intItemUOMId = @intItemUOMId AND intItemUOMId = UOM.intItemUOMId) 		
		)



	   DELETE FROM @tblPreview WHERE ISNULL(strOldData, '') = ISNULL(strNewData, '')
	END
   -------------------------------------------------------------------------------------------------
	----------- Count Items -------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------




	DECLARE @RecCount AS INT = 0
	DECLARE @UpdateCount AS INT = 0

	--SET @RecCount = @RecCount + (SELECT COUNT(*) FROM #tmpUpdateItemPricingForCStore_ItemPricingAuditLog WHERE dblOldSalePrice != dblNewSalePrice OR dblOldStandardCost != dblNewStandardCost)
	--SET @RecCount = @RecCount + (SELECT COUNT(*) FROM #tmpUpdateItemPricingForCStore_ItemSpecialPricingAuditLog WHERE dblOldUnitAfterDiscount != dblNewUnitAfterDiscount OR dtmOldBeginDate != dtmNewBeginDate OR dtmOldEndDate != dtmNewEndDate)

	--SET @UpdateCount = @UpdateCount + (SELECT COUNT(DISTINCT intItemPricingId) FROM #tmpUpdateItemPricingForCStore_ItemPricingAuditLog)
	--SET @UpdateCount = @UpdateCount + (SELECT COUNT(DISTINCT intItemSpecialPricingId) FROM #tmpUpdateItemPricingForCStore_ItemSpecialPricingAuditLog)

	SET @UpdateCount = (SELECT COUNT(*) FROM @tblPreview)
	SET @RecCount = (SELECT COUNT(DISTINCT intChildId) FROM @tblPreview)

	SELECT @UpdateCount as UpdateItemPrcicingCount, @RecCount as RecCount

	-- Clean up 
	BEGIN
		IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_Location') IS NULL  
			DROP TABLE #tmpUpdateItemPricingForCStore_Location 

		IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_Vendor') IS NULL  
			DROP TABLE #tmpUpdateItemPricingForCStore_Vendor 

		IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_Category') IS NULL  
			DROP TABLE #tmpUpdateItemPricingForCStore_Category 

		IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_Family') IS NULL  
			DROP TABLE #tmpUpdateItemPricingForCStore_Family 

		IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_Class') IS NULL  
			DROP TABLE #tmpUpdateItemPricingForCStore_Class 

		IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_ItemPricingAuditLog') IS NOT NULL  
			DROP TABLE #tmpUpdateItemPricingForCStore_ItemPricingAuditLog 

		IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_ItemSpecialPricingAuditLog') IS NOT NULL  
			DROP TABLE #tmpUpdateItemPricingForCStore_ItemSpecialPricingAuditLog 
	END
END TRY

BEGIN CATCH  
	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')         
END CATCH