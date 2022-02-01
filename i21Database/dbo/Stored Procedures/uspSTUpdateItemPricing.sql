CREATE PROCEDURE [dbo].[uspSTUpdateItemPricing]
	@XML VARCHAR(MAX)
	, @ysnRecap BIT
	, @strGuid UNIQUEIDENTIFIER
	, @strEntityIds AS NVARCHAR(MAX) OUTPUT
	, @strResultMsg NVARCHAR(1000) OUTPUT
AS
BEGIN TRY
	
	BEGIN TRANSACTION

	SET @strEntityIds = ''

	DECLARE @dtmDateTimeModifiedFrom AS DATETIME
	DECLARE @dtmDateTimeModifiedTo AS DATETIME

	DECLARE @ErrMsg				NVARCHAR(MAX),
	        @idoc				INT,
			@StoreGroup 		NVARCHAR(MAX),
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
			@PromotionalCost    DECIMAL (18,6),
		    @EffectiveDate		NVARCHAR(50),
		    @SalesStartDate		NVARCHAR(50),
			@SalesEndDate   	NVARCHAR(50),
			@ysnPreview			NVARCHAR(1),
			@currentUserId		INT
	

	EXEC sp_xml_preparedocument @idoc OUTPUT, @XML 


	SELECT	
			@StoreGroup		 =	 StoreGroup,
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
			@PromotionalCost =	 PromotionalCost,
			@EffectiveDate	 =	 EffectiveDate,
			@SalesStartDate	 =	 SalesStartingDate,
			@SalesEndDate	 =	 SalesEndingDate,
			@ysnPreview		 =   ysnPreview,
			@currentUserId   =   currentUserId
		
	FROM	OPENXML(@idoc, 'root',2)
	WITH
	(
			StoreGroup		        NVARCHAR(MAX),
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
			PromotionalCost      	DECIMAL (18,6),
			EffectiveDate			NVARCHAR(50),
			SalesStartingDate		NVARCHAR(50),
			SalesEndingDate			NVARCHAR(50),
			ysnPreview				NVARCHAR(1),
			currentUserId			INT
	)  
    -- Insert statements for procedure here




	-- Create the filter tables
	BEGIN
		IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_Location') IS NULL 
			BEGIN
				CREATE TABLE #tmpUpdateItemPricingForCStore_Location (
					intLocationId INT 
				)
			END

		IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_Vendor') IS NULL 
			BEGIN
				CREATE TABLE #tmpUpdateItemPricingForCStore_Vendor (
					intVendorId INT 
				)
			END

		IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_Category') IS NULL 
			BEGIN
				CREATE TABLE #tmpUpdateItemPricingForCStore_Category (
					intCategoryId INT 
				)
			END

		IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_Family') IS NULL 
			BEGIN
				CREATE TABLE #tmpUpdateItemPricingForCStore_Family (
					intFamilyId INT 
				)
			END

		IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_Class') IS NULL 
			BEGIN
				CREATE TABLE #tmpUpdateItemPricingForCStore_Class (
					intClassId INT 
				)
			END

			IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_Description') IS NULL 
			BEGIN
				CREATE TABLE #tmpUpdateItemPricingForCStore_Description (
					intItemId INT 
				)
			END
			
		-- Create the temp table for the audit log. 
		IF OBJECT_ID('tempdb..#tmpEffectiveCostForCStore_AuditLog') IS NULL  
			CREATE TABLE #tmpEffectiveCostForCStore_AuditLog (
				intEffectiveItemCostId INT
				,intItemId INT
				,intItemLocationId INT 
				,dblOldCost NUMERIC(38, 20) NULL
				,dblNewCost NUMERIC(38, 20) NULL
				,dtmOldEffectiveDate DATETIME NULL
				,dtmNewEffectiveDate DATETIME NULL
				,strAction NVARCHAR(50) NULL
			)
		;

		-- Create the temp table for the audit log. 
		IF OBJECT_ID('tempdb..#tmpEffectivePriceForCStore_AuditLog') IS NULL  
			CREATE TABLE #tmpEffectivePriceForCStore_AuditLog (
				intItemId INT
				,intEffectiveItemPriceId INT
				,intItemLocationId INT 
				,dblOldPrice NUMERIC(38, 20) NULL
				,dblNewPrice NUMERIC(38, 20) NULL
				,dtmOldEffectiveDate DATETIME NULL
				,dtmNewEffectiveDate DATETIME NULL
				,strAction NVARCHAR(50) NULL
			)
		;

		-- Create the temp table for the audit log. 
		IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_ItemSpecialPricingAuditLog') IS NULL  
			CREATE TABLE #tmpUpdateItemPricingForCStore_ItemSpecialPricingAuditLog (
				intItemId INT 
				,intItemSpecialPricingId INT 
				,dblOldUnitAfterDiscount NUMERIC(38, 20) NULL 
				,dblOldCost NUMERIC(38, 20) NULL 
				,dtmOldBeginDate DATETIME NULL 
				,dtmOldEndDate DATETIME NULL 
				,dblNewUnitAfterDiscount NUMERIC(38, 20) NULL 
				,dblNewCost NUMERIC(38, 20) NULL 
				,dtmNewBeginDate DATETIME NULL
				,dtmNewEndDate DATETIME NULL 			
				,strAction VARCHAR(20) NULL	
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
				SELECT [intID] AS intLocationId
				FROM [dbo].[fnGetRowsFromDelimitedValues](@Location)
			END
			
		IF(@StoreGroup IS NOT NULL AND @StoreGroup != '')
			BEGIN
				INSERT INTO #tmpUpdateItemPricingForCStore_Location (
					intLocationId
				)
				SELECT st.intCompanyLocationId AS intLocationId
				FROM [dbo].[fnGetRowsFromDelimitedValues](@StoreGroup)
				INNER JOIN tblSTStoreGroup sg
					ON sg.intStoreGroupId = intID
				INNER JOIN tblSTStoreGroupDetail sgt
					ON sgt.intStoreGroupId = sg.intStoreGroupId
				INNER JOIN tblSTStore st
					ON st.intStoreId = sgt.intStoreId
			END
		
		IF(@Vendor IS NOT NULL AND @Vendor != '')
			BEGIN
				INSERT INTO #tmpUpdateItemPricingForCStore_Vendor (
					intVendorId
				)
				SELECT [intID] AS intVendorId
				FROM [dbo].[fnGetRowsFromDelimitedValues](@Vendor)
			END

		IF(@Category IS NOT NULL AND @Category != '')
			BEGIN
				INSERT INTO #tmpUpdateItemPricingForCStore_Category (
					intCategoryId
				)
				SELECT [intID] AS intCategoryId
				FROM [dbo].[fnGetRowsFromDelimitedValues](@Category)
			END

		IF(@Family IS NOT NULL AND @Family != '')
			BEGIN
				INSERT INTO #tmpUpdateItemPricingForCStore_Family (
					intFamilyId
				)
				SELECT [intID] AS intFamilyId
				FROM [dbo].[fnGetRowsFromDelimitedValues](@Family)
			END

		IF(@Class IS NOT NULL AND @Class != '')
			BEGIN
				INSERT INTO #tmpUpdateItemPricingForCStore_Class (
					intClassId
				)
				SELECT [intID] AS intClassId
				FROM [dbo].[fnGetRowsFromDelimitedValues](@Class)
			END

		IF(@Description IS NOT NULL AND @Description != '')
			BEGIN
				INSERT INTO #tmpUpdateItemPricingForCStore_Description (
					intItemId
				)
				SELECT intItemId as intItemId FROM
				tblICItem WHERE strDescription LIKE '%' + @Description + '%'
			END
	END





	-- SELECT strDistrict, strRegion, strState, * FROM tblSTStore
	-- ==========================================================================================
	-- [START] - IF (@Location=EMPTY OR IS NULL) (strDistrict and strRegion and strState are nulls)
	-- ==========================================================================================
	IF(@Location IS NULL AND ((@Region IS NOT NULL AND @Region != '') OR (@District IS NOT NULL AND @District != '') OR (@State IS NOT NULL AND @State != '')))
		BEGIN

			DELETE FROM #tmpUpdateItemPricingForCStore_Location
			
			INSERT INTO #tmpUpdateItemPricingForCStore_Location 
			(
				intLocationId
			)
			SELECT DISTINCT
				intLocationId = intCompanyLocationId
			FROM tblSTStore
			WHERE strRegion		= ISNULL(@Region, strRegion)
				AND strDistrict = ISNULL(@District, strDistrict)
				AND strState	= ISNULL(@State, strState)
				AND intCompanyLocationId IN (SELECT st.intCompanyLocationId AS intLocationId
					FROM [dbo].[fnGetRowsFromDelimitedValues](@StoreGroup)
					INNER JOIN tblSTStoreGroup sg
						ON sg.intStoreGroupId = intID
					INNER JOIN tblSTStoreGroupDetail sgt
						ON sgt.intStoreGroupId = sg.intStoreGroupId
					INNER JOIN tblSTStore st
						ON st.intStoreId = sgt.intStoreId) --To not allow duplicates

			
			--To prevent defaulting to all stores if Region District and State did not return any rows
			IF NOT EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemPricingForCStore_Location)
			INSERT INTO #tmpUpdateItemPricingForCStore_Location 
			(
				intLocationId
			)
			VALUES
			(
				9999999999 --So that it will filter to null
			)
		END
	-- ==========================================================================================
	-- [END] - IF (@Location=EMPTY OR IS NULL) (strDistrict and strRegion and strState are nulls)
	-- ==========================================================================================





	-- MARK START UPDATE
	SET @dtmDateTimeModifiedFrom = GETUTCDATE()



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
	DECLARE @dtmEffectiveDateConv AS DATE = CAST(@EffectiveDate AS DATE)
	DECLARE @intCurrentUserIdConv AS INT = CAST(@currentUserId AS INT)

	IF @dtmEffectiveDateConv IS NOT NULL
	BEGIN
		BEGIN TRY
			-- ITEM PRICING
			EXEC [uspICUpdateEffectivePricingForCStore]
				  @strUpcCode				= @strUpcCode
				, @strScreen				= 'UpdateItemPricing'
				, @strDescription			= @Description -- NOTE: Description cannot be '' or empty string, it should be NULL value instead of empty string
				, @intItemId				= NULL
				, @dblStandardCost			= @dblStandardCostConv
				, @dblRetailPrice			= @dblRetailPriceConv
				, @intEntityUserSecurityId	= @intCurrentUserIdConv
				, @dtmEffectiveDate			= @dtmEffectiveDateConv
		END TRY
		BEGIN CATCH
			SELECT 'uspICUpdateItemPricingForCStore', ERROR_MESSAGE()
			SET @strResultMsg = 'Error Message: ' + ERROR_MESSAGE()

			GOTO ExitWithRollback 
		END CATCH
	END





	DECLARE @dblSalesPriceConv AS DECIMAL(18, 6) = CAST(@SalesPrice AS DECIMAL(18, 6))
	DECLARE @dblPromotionalCostConv AS DECIMAL(18, 6) = CAST(@PromotionalCost AS DECIMAL(18, 6))
	DECLARE @dtmSalesStartingDateConv AS DATE = CAST(@SalesStartDate AS DATE)
	DECLARE @dtmSalesEndingDateConv AS DATE = CAST(@SalesEndDate AS DATE)
	IF @dtmSalesStartingDateConv IS NOT NULL AND @dtmSalesEndingDateConv IS NOT NULL
	BEGIN
		BEGIN TRY
			-- ITEM SPECIAL PRICING
			EXEC [dbo].[uspICUpdateItemPromotionalPricingForCStore]
				 @dblPromotionalSalesPrice		= @dblSalesPriceConv 
				,@dblPromotionalCost			= @dblPromotionalCostConv 
				,@dtmBeginDate					= @dtmSalesStartingDateConv
				,@dtmEndDate					= @dtmSalesEndingDateConv 
				,@strUpcCode					= @strUpcCode
				,@intEntityUserSecurityId		= @intCurrentUserIdConv
		END TRY
		BEGIN CATCH
			SELECT 'uspICUpdateItemPromotionalPricingForCStore', ERROR_MESSAGE()
			SET @strResultMsg = 'Error Message: ' + ERROR_MESSAGE()

			GOTO ExitWithRollback 
		END CATCH
	END





	IF(@ysnRecap = 1) 
		BEGIN
			SELECT '#tmpEffectiveCostForCStore_AuditLog', * FROM #tmpEffectiveCostForCStore_AuditLog
			SELECT '#tmpEffectivePriceForCStore_AuditLog', * FROM #tmpEffectivePriceForCStore_AuditLog
			SELECT '#tmpUpdateItemPricingForCStore_ItemSpecialPricingAuditLog', * FROm #tmpUpdateItemPricingForCStore_ItemSpecialPricingAuditLog
		END


	-- MARK END UPDATE
	SET @dtmDateTimeModifiedTo = GETUTCDATE()



	
	-------------------------------------------------------------------------------------------------
	----------- Count Items -------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------
	BEGIN
		DECLARE @tblPreview TABLE (
			strTableName				NVARCHAR(150)
			, strTableColumnName		NVARCHAR(150)
			, strTableColumnDataType	NVARCHAR(50)
			, intPrimaryKeyId			INT NOT NULL
			, intParentId				INT NULL
			, intChildId				INT NULL
			, intCurrentEntityUserId	INT NOT NULL
			, intItemId					INT NULL
			, intItemUOMId				INT NULL
			, intItemLocationId			INT NULL
			, intEffectiveItemCostId	INT NULL
			, intEffectiveItemPriceId	INT NULL
			, intItemSpecialPricingId	INT NULL

			, dtmDateModified			DATETIME NOT NULL
			, intCompanyLocationId		INT
			, strLocation				NVARCHAR(250)
			, strUpc					NVARCHAR(50)
			, strItemDescription		NVARCHAR(250)
			, strChangeDescription		NVARCHAR(100)
			, strPreviewOldData			NVARCHAR(MAX)
			, strPreviewNewData			NVARCHAR(MAX)
			, strOldDataPreview			NVARCHAR(MAX)
			, strAction					NVARCHAR(MAX)
			, ysnPreview				BIT DEFAULT(1)
			, ysnForRevert				BIT DEFAULT(0)
		)

		-- Effective item COST pricing
		INSERT INTO @tblPreview (
			strTableName
			, strTableColumnName
			, strTableColumnDataType
			, intPrimaryKeyId
			, intParentId
			, intChildId
			, intCurrentEntityUserId
			, intItemId
			, intItemUOMId
			, intItemLocationId
			, intEffectiveItemCostId
			, intItemSpecialPricingId

			, dtmDateModified
			, intCompanyLocationId
			, strLocation
			, strUpc
			, strItemDescription
			, strChangeDescription
			, strPreviewOldData
			, strPreviewNewData
			, strOldDataPreview
			, strAction
			, ysnPreview
			, ysnForRevert
		)
		SELECT	DISTINCT
				strTableName					= N'tblICEffectiveItemCost'
				, strTableColumnName			= CASE
													WHEN [Changes].oldColumnName = 'strCost_Original' THEN 'dblCost'
												END
				, strTableColumnDataType		= CASE
													WHEN [Changes].oldColumnName = 'strCost_Original' THEN 'NUMERIC(38, 20)'
												END
				, intPrimaryKeyId				= [Changes].intEffectiveItemCostId
				, intParentId					= I.intItemId
				, intChildId					= NULL
				, intCurrentEntityUserId		= @currentUserId
				, intItemId						= I.intItemId
				, intItemUOMId					= UOM.intItemUOMId
				, intItemLocationId				= IL.intItemLocationId 
				, intEffectiveItemCostId		= tic.intEffectiveItemCostId
				, intItemSpecialPricingId		= NULL

				, dtmDateModified				= ISNULL(tic.dtmDateModified, GETDATE())
				, intCompanyLocationId			= CL.intCompanyLocationId
				, strLocation					= CL.strLocationName
				, strUpc						= UOM.strLongUPCCode
				, strItemDescription			= I.strDescription
				, strChangeDescription			= CASE
													WHEN [Changes].oldColumnName = 'strCost_Original' THEN 'Cost'
												END
				, strPreviewOldData				= CASE WHEN [Changes].strOldData = ''
													THEN CAST((SELECT TOP 1 CAST(dblCost AS DECIMAL(10,3))
																					FROM tblICEffectiveItemCost getCost
																					WHERE dtmEffectiveCostDate < @dtmEffectiveDateConv
																					AND intItemId = tic.intItemId
																					AND intItemLocationId = tic.intItemLocationId 
																					ORDER BY dtmEffectiveCostDate DESC) AS VARCHAR(50))
													ELSE
														[Changes].strOldData
													END
				, strPreviewNewData				= [Changes].strNewData
				, strOldDataPreview				= CASE WHEN [Changes].strOldData = ''
													THEN CAST((SELECT TOP 1 CAST(dblCost AS DECIMAL(10,3))
																					FROM tblICEffectiveItemCost getCost
																					WHERE dtmEffectiveCostDate < @dtmEffectiveDateConv
																					AND intItemId = tic.intItemId
																					AND intItemLocationId = tic.intItemLocationId 
																					ORDER BY dtmEffectiveCostDate DESC) AS VARCHAR(50))
													ELSE
														[Changes].strOldData
													END
				, strAction						= [Changes].strAction
				, ysnPreview					= 1
				, ysnForRevert					= 1
		FROM 
		(
			SELECT DISTINCT intEffectiveItemCostId, intItemId, intItemLocationId, oldColumnName, strOldData, strNewData, strAction
			FROM 
			(
				SELECT intEffectiveItemCostId
				   , intItemId
				   , intItemLocationId
				   , ISNULL(CAST(CAST(dblOldCost AS DECIMAL(18,3)) AS NVARCHAR(50)),'') AS strCost_Original
				   , CAST(CAST(dblNewCost AS DECIMAL(18,3))  AS NVARCHAR(50)) AS strCost_New
				   , strAction
				FROM #tmpEffectiveCostForCStore_AuditLog
			) t
			unpivot
			(
				strOldData for oldColumnName in (strCost_Original)
			) o
			unpivot
			(
				strNewData for newColumnName in (strCost_New)
			) n
			WHERE  REPLACE(oldColumnName, '_Original', '') = REPLACE(newColumnName, '_New', '')	
		) [Changes]
		INNER JOIN tblICItem I 
			ON [Changes].intItemId = I.intItemId
		INNER JOIN tblICItemUOM UOM 
			ON I.intItemId = UOM.intItemId
		INNER JOIN tblICEffectiveItemCost tic 
			ON I.intItemId = tic.intItemId 
				AND [Changes].intItemLocationId = tic.intItemLocationId 
				AND tic.dtmEffectiveCostDate = @dtmEffectiveDateConv
		INNER JOIN tblICItemLocation IL 
			ON tic.intItemLocationId = IL.intItemLocationId 
			AND [Changes].intItemId = IL.intItemId
		INNER JOIN tblSMCompanyLocation CL 
			ON IL.intLocationId = CL.intCompanyLocationId
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
			AND UOM.ysnStockUnit = 1

		
		-- Effective item PRICE pricing
		INSERT INTO @tblPreview (
			strTableName
			, strTableColumnName
			, strTableColumnDataType
			, intPrimaryKeyId
			, intParentId
			, intChildId
			, intCurrentEntityUserId
			, intItemId
			, intItemUOMId
			, intItemLocationId
			, intEffectiveItemPriceId
			, intItemSpecialPricingId

			, dtmDateModified
			, intCompanyLocationId
			, strLocation
			, strUpc
			, strItemDescription
			, strChangeDescription
			, strPreviewOldData
			, strPreviewNewData
			, strOldDataPreview
			, strAction
			, ysnPreview
			, ysnForRevert
		)
		SELECT	DISTINCT
				strTableName					= N'tblICEffectiveItemPrice'
				, strTableColumnName			= CASE
													WHEN [Changes].oldColumnName = 'strPrice_Original' THEN 'dblRetailPrice'
												END
				, strTableColumnDataType		= CASE
													WHEN [Changes].oldColumnName = 'strPrice_Original' THEN 'NUMERIC(38, 20)'
												END
				, intPrimaryKeyId				= [Changes].intEffectiveItemPriceId
				, intParentId					= I.intItemId
				, intChildId					= NULL
				, intCurrentEntityUserId		= @currentUserId
				, intItemId						= I.intItemId
				, intItemUOMId					= UOM.intItemUOMId
				, intItemLocationId				= IL.intItemLocationId 
				, intEffectiveItemPriceId		= tip.intEffectiveItemPriceId
				, intItemSpecialPricingId		= NULL
				
				, dtmDateModified				= ISNULL(tip.dtmDateModified, GETDATE())
				, intCompanyLocationId			= CL.intCompanyLocationId
				, strLocation					= CL.strLocationName
				, strUpc						= UOM.strLongUPCCode
				, strItemDescription			= I.strDescription
				, strChangeDescription			= CASE
													WHEN [Changes].oldColumnName = 'strPrice_Original' THEN 'Retail Price'
												END
				, strPreviewOldData				= CASE WHEN [Changes].strOldData = ''
													THEN CAST((SELECT TOP 1 CAST(dblRetailPrice AS DECIMAL(10,3))
																					FROM tblICEffectiveItemPrice getPrice
																					WHERE dtmEffectiveRetailPriceDate < @dtmEffectiveDateConv
																					AND intItemId = tip.intItemId
																					AND intItemLocationId = tip.intItemLocationId 
																					ORDER BY dtmEffectiveRetailPriceDate DESC) AS VARCHAR(50))
													ELSE
														[Changes].strOldData
													END
				, strPreviewNewData				= [Changes].strNewData
				, strOldDataPreview				= CASE WHEN [Changes].strOldData = ''
													THEN CAST((SELECT TOP 1 CAST(dblRetailPrice AS DECIMAL(10,3))
																					FROM tblICEffectiveItemPrice getPrice
																					WHERE dtmEffectiveRetailPriceDate < @dtmEffectiveDateConv
																					AND intItemId = tip.intItemId
																					AND intItemLocationId = tip.intItemLocationId 
																					ORDER BY dtmEffectiveRetailPriceDate DESC) AS VARCHAR(50))
													ELSE
														[Changes].strOldData
													END
				, strAction						= [Changes].strAction
				, ysnPreview					= 1
				, ysnForRevert					= 1
		FROM 
		(
			SELECT DISTINCT intEffectiveItemPriceId, intItemId, intItemLocationId, oldColumnName, strOldData, strNewData, strAction
			FROM 
			(
				SELECT intEffectiveItemPriceId
				   , intItemId
				   , intItemLocationId
				   , ISNULL(CAST(CAST(dblOldPrice AS DECIMAL(18,3)) AS NVARCHAR(50)),'') AS strPrice_Original
				   , CAST(CAST(dblNewPrice AS DECIMAL(18,3))  AS NVARCHAR(50)) AS strPrice_New
				   , strAction
				FROM #tmpEffectivePriceForCStore_AuditLog
			) t
			unpivot
			(
				strOldData for oldColumnName in (strPrice_Original)
			) o
			unpivot
			(
				strNewData for newColumnName in (strPrice_New)
			) n
			WHERE  REPLACE(oldColumnName, '_Original', '') = REPLACE(newColumnName, '_New', '')	
		) [Changes]
		INNER JOIN tblICItem I 
			ON [Changes].intItemId = I.intItemId
		INNER JOIN tblICItemUOM UOM 
			ON I.intItemId = UOM.intItemId
		INNER JOIN tblICEffectiveItemPrice tip 
			ON I.intItemId = tip.intItemId 
				AND [Changes].intItemLocationId = tip.intItemLocationId 
				AND tip.dtmEffectiveRetailPriceDate = @dtmEffectiveDateConv
		INNER JOIN tblICItemLocation IL 
			ON tip.intItemLocationId = IL.intItemLocationId 
			AND [Changes].intItemId = IL.intItemId
		INNER JOIN tblSMCompanyLocation CL 
			ON IL.intLocationId = CL.intCompanyLocationId
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
			AND UOM.ysnStockUnit = 1





		-- ITEM SPECIAL PRICING
		INSERT INTO @tblPreview (
			strTableName
			, strTableColumnName
			, strTableColumnDataType
			, intPrimaryKeyId
			, intParentId
			, intChildId
			, intCurrentEntityUserId
			, intItemId
			, intItemUOMId
			, intItemLocationId
			, intItemSpecialPricingId

			, dtmDateModified
			, intCompanyLocationId
			, strLocation
			, strUpc
			, strItemDescription
			, strChangeDescription
			, strPreviewOldData
			, strPreviewNewData
			, strOldDataPreview
			, strAction
			, ysnPreview
			, ysnForRevert
		)
		SELECT  
			strTableName				= N'tblICItemSpecialPricing'
			, strTableColumnName		= CASE
											WHEN [Changes].oldColumnName = 'strUnitAfterDiscount_Original' THEN 'dblUnitAfterDiscount'
											WHEN [Changes].oldColumnName = 'strCost_Original' THEN 'dblCost'
											WHEN [Changes].oldColumnName = 'strBeginDate_Original' THEN 'dtmBeginDate'
											WHEN [Changes].oldColumnName = 'strEndDate_Original' THEN 'dtmEndDate'
										END
			, strTableColumnDataType	= CASE
											WHEN [Changes].oldColumnName = 'strUnitAfterDiscount_Original' THEN 'NUMERIC(18, 6)'
											WHEN [Changes].oldColumnName = 'strCost_Original' THEN 'NUMERIC(18, 6)'
											WHEN [Changes].oldColumnName = 'strBeginDate_Original' THEN 'DATETIME'
											WHEN [Changes].oldColumnName = 'strEndDate_Original' THEN 'DATETIME'
										END
			, intPrimaryKeyId			= ISP.intItemSpecialPricingId
			, intParentId				= I.intItemId
			, intChildId				= NULL
			, intCurrentEntityUserId	= @currentUserId
			, intItemId					= I.intItemId
			, intItemUOMId				= UOM.intItemUOMId
			, intItemLocationId			= IL.intItemLocationId
			, intItemSpecialPricingId	= ISP.intItemSpecialPricingId
			
			, dtmDateModified			= ISNULL(ISP.dtmDateModified, GETDATE())
			, intCompanyLocationId		= CL.intCompanyLocationId
			, strLocation				= CL.strLocationName
			, strUpc					= UOM.strLongUPCCode
			, strItemDescription		= I.strDescription
			, strChangeDescription		= CASE
											WHEN [Changes].oldColumnName = 'strUnitAfterDiscount_Original' THEN 'Unit After Discount'
											WHEN [Changes].oldColumnName = 'strCost_Original' THEN 'Promotional Cost'
											WHEN [Changes].oldColumnName = 'strBeginDate_Original' THEN 'Begin Date'
											WHEN [Changes].oldColumnName = 'strEndDate_Original' THEN 'End Date'
										END
			, strPreviewOldData			= CASE WHEN [Changes].strOldData = ''
												THEN NULL
											ELSE
												[Changes].strOldData
											END
			, strPreviewNewData			= [Changes].strNewData
			, strOldDataPreview			= CASE WHEN [Changes].strOldData = ''
												THEN NULL
											ELSE
												[Changes].strOldData
											END
			, strAction					= [Changes].strAction
			, ysnPreview				= 1
			, ysnForRevert				= 1
		FROM 
		(
			SELECT DISTINCT intItemId, intItemSpecialPricingId, oldColumnName, strOldData, strNewData, strAction
			FROM 
			(
				SELECT intItemId 
					,intItemSpecialPricingId 
					,ISNULL(CAST(CAST(dblOldUnitAfterDiscount AS DECIMAL(18,3)) AS NVARCHAR(50)), '') AS strUnitAfterDiscount_Original
					,ISNULL(CAST(CAST(dblOldCost AS DECIMAL(18,3)) AS NVARCHAR(50)), '') AS strCost_Original
					,CAST(CAST(dtmOldBeginDate AS DATE) AS NVARCHAR(50)) AS strBeginDate_Original
					,CAST(CAST(dtmOldEndDate AS DATE) AS NVARCHAR(50)) AS strEndDate_Original
					,ISNULL(CAST(CAST(dblNewUnitAfterDiscount AS DECIMAL(18,3)) AS NVARCHAR(50)), '0') AS strUnitAfterDiscount_New
					,ISNULL(CAST(CAST(dblNewCost AS DECIMAL(18,3)) AS NVARCHAR(50)), '0') AS strCost_New
					,CAST(CAST(dtmNewBeginDate AS DATE) AS NVARCHAR(50)) AS strBeginDate_New
					,CAST(CAST(dtmNewEndDate AS DATE) AS NVARCHAR(50)) AS strEndDate_New
					,strAction
				FROM #tmpUpdateItemPricingForCStore_ItemSpecialPricingAuditLog
			) t
			unpivot
			(
				strOldData for oldColumnName in (strUnitAfterDiscount_Original, strCost_Original, strBeginDate_Original, strEndDate_Original)
			) o
			unpivot
			(
				strNewData for newColumnName in (strUnitAfterDiscount_New, strCost_New, strBeginDate_New, strEndDate_New)
			) n
			WHERE  REPLACE(oldColumnName, '_Original', '') = REPLACE(newColumnName, '_New', '')	
		
		) [Changes]
		INNER JOIN tblICItem I 
			ON [Changes].intItemId = I.intItemId
		INNER JOIN tblICItemSpecialPricing ISP 
			ON [Changes].intItemSpecialPricingId = ISP.intItemSpecialPricingId
		INNER JOIN tblICItemUOM UOM 
			ON ISP.intItemId = UOM.intItemId
		INNER JOIN tblICItemLocation IL 
			ON ISP.intItemLocationId = IL.intItemLocationId 
			AND I.intItemId = IL.intItemId
		INNER JOIN tblSMCompanyLocation CL 
			ON IL.intLocationId = CL.intCompanyLocationId
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
			AND UOM.ysnStockUnit = 1
	END



	DELETE FROM @tblPreview WHERE ISNULL(strPreviewOldData, '') = ISNULL(strPreviewNewData, '')



	 IF(@ysnRecap = 1)
		BEGIN
				
			IF @@TRANCOUNT > 0
				BEGIN
					ROLLBACK TRANSACTION 
				END

			-- INSERT TO PREVIEW TABLE
			INSERT INTO tblSTUpdateItemPricingPreview
			(
				strGuid,
				strLocation,
				strUpc,
				strDescription,
				strChangeDescription,
				strOldData,
				strNewData,
				strActionType,

				intItemId,
				intItemUOMId,
				intItemLocationId,
				intTableIdentityId,
				strTableName,
				strColumnName,
				strColumnDataType,
				intConcurrencyId
			)
			SELECT DISTINCT 
				@strGuid
				, strLocation
			 	, strUpc
				, strItemDescription
				, strChangeDescription
				, strPreviewOldData
				, strPreviewNewData
				, strAction

				, intItemId
				, intItemUOMId
				, intItemLocationId
				, intPrimaryKeyId
				, strTableName
				, strTableColumnName
				, strTableColumnDataType
				, 1
			FROM @tblPreview
			WHERE ysnPreview = 1
			ORDER BY strUpc, strChangeDescription, strLocation ASC

		END
	 ELSE IF(@ysnRecap = 0)
		BEGIN
				
			IF EXISTS(SELECT TOP 1 1 FROM @tblPreview WHERE ysnForRevert = 1)
				BEGIN
					DECLARE @intMassUpdatedRowCount AS INT = (SELECT COUNT(ysnForRevert) FROM @tblPreview WHERE ysnForRevert = 1)

					-- ===================================================================================
					-- [START] - Insert value to tblSTUpdateItemDataRevertHolder
					-- ===================================================================================
						
					DECLARE @intNewRevertHolderId AS INT,
							@strFilterCriteria AS NVARCHAR(MAX) = '',
							@strUpdateValues AS NVARCHAR(MAX) = ''



					-- ===================================================================================
					-- [START] Filter Criteria
					-- ===================================================================================
					-- '<p id="p2"><b>Location</b></p><p id="p2">&emsp;Brookwood</p> <p id="p2">&emsp;Royville</p><p id="p2"><b>Category</b></p><p id="p2">&emsp;7-Pop/Energy</p><p id="p2">&emsp;13-Beer/Wine</p><p id="p2"><b>Family</b></p><p id="p2">&emsp;Mike Sells</p>'
					IF EXISTS(SELECT TOP 1 1 FROM #tmpUpdateItemPricingForCStore_Location)
							BEGIN
								SET @strFilterCriteria = @strFilterCriteria + '<p id="p2"><b>Location</b></p>'
								
								SELECT @strFilterCriteria = @strFilterCriteria + '<p id="p2">&emsp;' + CompanyLoc.strLocationName + '</p>'
								FROM #tmpUpdateItemPricingForCStore_Location tempLoc
								INNER JOIN tblSMCompanyLocation CompanyLoc
									ON tempLoc.intLocationId = CompanyLoc.intCompanyLocationId

								--SET @strFilterCriteria = @strFilterCriteria + '<br>'
							END
						
					IF EXISTS(SELECT TOP 1 1 FROM #tmpUpdateItemPricingForCStore_Vendor)
						BEGIN
							SET @strFilterCriteria = @strFilterCriteria + '<p id="p2"><b>Vendor</b></p>'
								
							SELECT @strFilterCriteria = @strFilterCriteria + '<p id="p2">&emsp;' + EntityVendor.strName + '</p>'
							FROM #tmpUpdateItemPricingForCStore_Vendor tempVendor
							INNER JOIN tblEMEntity EntityVendor
								ON tempVendor.intVendorId = EntityVendor.intEntityId

							--SET @strFilterCriteria = @strFilterCriteria + '<br>'
						END

					IF EXISTS(SELECT TOP 1 1 FROM #tmpUpdateItemPricingForCStore_Category)
						BEGIN
							SET @strFilterCriteria = @strFilterCriteria + '<p id="p2"><b>Category</b></p>'
								
							SELECT @strFilterCriteria = @strFilterCriteria + '<p id="p2">&emsp;' + Category.strCategoryCode + '</p>'
							FROM #tmpUpdateItemPricingForCStore_Category tempCategory
							INNER JOIN tblICCategory Category
								ON tempCategory.intCategoryId = Category.intCategoryId

							--SET @strFilterCriteria = @strFilterCriteria + '<br>'
						END

					IF EXISTS(SELECT TOP 1 1 FROM #tmpUpdateItemPricingForCStore_Family)
						BEGIN
							SET @strFilterCriteria = @strFilterCriteria + '<p id="p2"><b>Family</b></p>'
								
							SELECT @strFilterCriteria = @strFilterCriteria + '<p id="p2">&emsp;' + SubFamily.strSubcategoryId + '</p>'
							FROM #tmpUpdateItemPricingForCStore_Family tempFamily
							INNER JOIN tblSTSubcategory SubFamily
								ON tempFamily.intFamilyId = SubFamily.intSubcategoryId
							WHERE SubFamily.strSubcategoryType = 'F'

							--SET @strFilterCriteria = @strFilterCriteria + '<br>'
						END

					IF EXISTS(SELECT TOP 1 1 FROM #tmpUpdateItemPricingForCStore_Class)
						BEGIN
							SET @strFilterCriteria = @strFilterCriteria + '<p id="p2"><b>Class</b></p>'
								
							SELECT @strFilterCriteria = @strFilterCriteria + '<p id="p2">&emsp;' + SubClass.strSubcategoryId + '</p>'
							FROM #tmpUpdateItemPricingForCStore_Class tempClass
							INNER JOIN tblSTSubcategory SubClass
								ON tempClass.intClassId = SubClass.intSubcategoryId
							WHERE SubClass.strSubcategoryType = 'C'

							--SET @strFilterCriteria = @strFilterCriteria + '<br>'
						END
					IF ISNULL(@strUpcCode, '') != ''
						BEGIN
							SET @strFilterCriteria = @strFilterCriteria + '<p id="p2"><b>UPC Code</b></p>'
								
							SELECT @strFilterCriteria = @strFilterCriteria + '<p id="p2">&emsp;' + @strUpcCode + '</p>'

							--SET @strFilterCriteria = @strFilterCriteria + '<br>'
						END

					--ST-2074
					IF ISNULL(@Description, '') != ''
					BEGIN
						SET @strFilterCriteria = @strFilterCriteria + '<p id="p2"><b>Description</b></p>'
							
						SELECT @strFilterCriteria = @strFilterCriteria + '<p id="p2">&emsp;' + @Description + '</p>'
					
						--SET @strFilterCriteria = @strFilterCriteria + '<br>'
					END

					-- ===================================================================================
					-- [END] Filter Criteria
					-- ===================================================================================





						-- ===================================================================================
						-- [START] Update Values
						-- ===================================================================================
						SELECT @strUpdateValues = @strUpdateValues + '<p id="p2"><b>' + strChangeDescription + ':</b>&emsp; ' + strPreviewNewData + '</p>'
						FROM 
						(
							SELECT DISTINCT
								strChangeDescription
								, strPreviewNewData
							FROM @tblPreview
							WHERE ysnPreview = 1
						) A
						
						-- ===================================================================================
						-- [END] Update Values
						-- ===================================================================================





						-- Insert to header
						INSERT INTO tblSTRevertHolder
						(
							[intEntityId],
							[dtmEffectiveDate],
							[dtmDateTimeModifiedFrom],
							[dtmDateTimeModifiedTo],
							[intMassUpdatedRowCount],
							[intRevertType],
							[strOriginalFilterCriteria],
							[strOriginalUpdateValues],
							[intConcurrencyId]
						)
						SELECT 
							[intEntityId]				= @currentUserId,
							[dtmEffectiveDate]			= @dtmEffectiveDateConv,
							[dtmDateTimeModifiedFrom]	= @dtmDateTimeModifiedFrom,
							[dtmDateTimeModifiedTo]		= @dtmDateTimeModifiedTo,
							[intMassUpdatedRowCount]	= @intMassUpdatedRowCount,
							[intRevertType]				= 2,						-- *** Note: 1=Update Item Data,	2=Update Item Pricing
							[strOriginalFilterCriteria]	= @strFilterCriteria,
							[strOriginalUpdateValues]	= @strUpdateValues,
							[intConcurrencyId]			= 1


						SET @intNewRevertHolderId = SCOPE_IDENTITY()

						-- Insert to detail
						INSERT INTO tblSTRevertHolderDetail
						(
							[intRevertHolderId],
							[strTableName],
							[strTableColumnName],
							[strTableColumnDataType],
							[intPrimaryKeyId],
							[intParentId],
							[intChildId],
							[intItemId],
							[intItemUOMId],
							[intItemLocationId],
							[intEffectiveItemCostId],
							[intEffectiveItemPriceId],
							[intItemSpecialPricingId],
							[dtmDateModified],
							[intCompanyLocationId],
							[strLocation],
							[strUpc],
							[strItemDescription],
							[strChangeDescription],
							[strOldData],
							[strNewData],
							[strPreviewOldData],
							[strAction],
							[intConcurrencyId]
						)
						SELECT 
							[intRevertHolderId]			= @intNewRevertHolderId,
							[strTableName]				= strTableName,
							[strTableColumnName]		= strTableColumnName,
							[strTableColumnDataType]	= strTableColumnDataType,
							[intPrimaryKeyId]			= intPrimaryKeyId,
							[intParentId]				= intParentId,
							[intChildId]				= intChildId,
							[intItemId]					= intItemId,
							[intItemUOMId]				= intItemUOMId,
							[intItemLocationId]			= intItemLocationId,
							[intEffectiveItemCostId]	= intEffectiveItemCostId,
							[intEffectiveItemPriceId]	= intEffectiveItemPriceId,
							[intItemSpecialPricingId]	= intItemSpecialPricingId,
							[dtmDateModified]			= dtmDateModified,
							[intCompanyLocationId]		= intCompanyLocationId,
							[strLocation]				= strLocation,
							[strUpc]					= strUpc,
							[strItemDescription]		= strItemDescription,
							[strChangeDescription]		= strChangeDescription,
							[strOldData]				= CASE
															WHEN strTableColumnDataType = 'DATETIME'
																THEN CAST(CONVERT(VARCHAR(10), CAST(strPreviewOldData AS DATETIME), 101) AS NVARCHAR(10))
															ELSE strPreviewOldData
														END,
							[strNewData]				= CASE
															WHEN strTableColumnDataType = 'DATETIME'
																THEN CAST(CONVERT(VARCHAR(10), CAST(strPreviewNewData AS DATETIME), 101) AS NVARCHAR(10))
															ELSE strPreviewNewData
														END,
							[strPreviewOldData]			= strOldDataPreview,
							[strAction]					= strAction,
							[intConcurrencyId]			= 1
						FROM @tblPreview 
						WHERE ysnForRevert = 1
						-- ===================================================================================
						-- [END] - Insert value to tblSTUpdateItemDataRevertHolder
						-- ===================================================================================
						
					END

			END

	

	-- Clean up 
	BEGIN
		IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_Location') IS NOT NULL  
			DROP TABLE #tmpUpdateItemPricingForCStore_Location 

		IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_Vendor') IS NOT NULL  
			DROP TABLE #tmpUpdateItemPricingForCStore_Vendor 

		IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_Category') IS NOT NULL   
			DROP TABLE #tmpUpdateItemPricingForCStore_Category 

		IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_Family') IS NOT NULL  
			DROP TABLE #tmpUpdateItemPricingForCStore_Family 

		IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_Class') IS NOT NULL  
			DROP TABLE #tmpUpdateItemPricingForCStore_Class 

		IF OBJECT_ID('tempdb..#tmpEffectiveCostForCStore_AuditLog') IS NOT NULL   
			DROP TABLE #tmpEffectiveCostForCStore_AuditLog 

		IF OBJECT_ID('tempdb..##tmpEffectivePriceForCStore_AuditLog') IS NOT NULL   
			DROP TABLE #tmpEffectivePriceForCStore_AuditLog 

		IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_ItemSpecialPricingAuditLog') IS NOT NULL   
			DROP TABLE #tmpUpdateItemPricingForCStore_ItemSpecialPricingAuditLog 
	END




	---------------------------------------------------------------------------------------
	----------------------------- START Query Preview -------------------------------------
	---------------------------------------------------------------------------------------
	-- Query Preview display
	SELECT DISTINCT 
	          strLocation
			  , strUpc
			  , strItemDescription
			  , strChangeDescription
			  , strPreviewOldData AS strOldData
			  , strPreviewNewData AS strNewData
			  , CASE WHEN strAction = 'INSERT' THEN 'ADDED' 
					WHEN strAction = 'UPDATE' THEN 'UPDATED'
					END AS strActionType
	FROM @tblPreview
	WHERE ysnPreview = 1
	ORDER BY strItemDescription, strChangeDescription ASC
   
	---------------------------------------------------------------------------------------
	----------------------------- END Query Preview ---------------------------------------
	---------------------------------------------------------------------------------------


	
	-- Remove records
	DELETE FROM @tblPreview
	   

	-- Handle Returned Table
	IF(@ysnRecap = 1)
		BEGIN
			-- Exit
			GOTO ExitPost
		END
	ELSE IF(@ysnRecap = 0)
		BEGIN
			-- Commit transaction
			GOTO ExitWithCommit

			----TEST
			--GOTO ExitWithRollback
	END


END TRY

BEGIN CATCH      
	
	 SET @ErrMsg = ERROR_MESSAGE()     
	 --SET @strResultMsg = ERROR_MESSAGE()
	 SET @strResultMsg = 'Error Message: ' + ERROR_MESSAGE() --+ '<\BR>' + 
	 IF @idoc <> 0 EXEC sp_xml_removedocument @idoc      
	 --RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')  
	 
	 GOTO ExitWithRollback
END CATCH



ExitWithCommit:
	COMMIT TRANSACTION
	GOTO ExitPost
	

ExitWithRollback:
	IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION 
		END
	
		
ExitPost:
