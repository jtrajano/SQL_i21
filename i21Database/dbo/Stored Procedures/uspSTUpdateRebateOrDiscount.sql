CREATE PROCEDURE [dbo].[uspSTUpdateRebateOrDiscount]
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


	DECLARE @ErrMsg					NVARCHAR(MAX),
	        @idoc					INT,
	    	@Location 			    NVARCHAR(MAX),
			@Vendor                 NVARCHAR(MAX),
			@Category               NVARCHAR(MAX),
			@Family                 NVARCHAR(MAX),
			@Class                  NVARCHAR(MAX),
			@PromotionType          NVARCHAR(50),
			@BeginDate   			NVARCHAR(50),     
			@EndDate		 	    NVARCHAR(50),     
		    @RebateAmount           DECIMAL (18,6),
			@AccumlatedQty          DECIMAL (18,6),
			@AccumAmount            DECIMAL (18,6),
			@DiscThroughAmount      DECIMAL (18,6),
			@DiscThroughQty         DECIMAL (18,6),
			@DiscAmountUnit         DECIMAL (18,6),
			@ysnPreview             NVARCHAR(1),
			@currentUserId			INT
		
	                  
	EXEC sp_xml_preparedocument @idoc OUTPUT, @XML 
	
	SELECT	
			@Location	   	    =	Location,
            @Vendor             =   Vendor,
			@Category           =   Category,
			@Family             =   Family,
            @Class              =   Class,
			@PromotionType      =   PromotionTypeValue, 
			@BeginDate          =   BeginingDate,
			@EndDate            =   EndingDate,
			@RebateAmount 	    =	RebateAmount,
			@AccumlatedQty	    =	AccumlatedQuantity,
			@AccumAmount	    =	AccumlatedAmount,
		    @DiscThroughAmount  =   DiscThroughAmount,
			@DiscThroughQty     =   DiscThroughQty,
			@DiscAmountUnit     =   DiscAmountUnit,
			@ysnPreview			=	ysnPreview,
			@currentUserId		=   currentUserId

	FROM	OPENXML(@idoc, 'root',2)
	WITH
	(
			Location		        NVARCHAR(MAX),
			Vendor	     	        NVARCHAR(MAX),
			Category		        NVARCHAR(MAX),
			Family	     	        NVARCHAR(MAX),
			Class	     	        NVARCHAR(MAX),
			PromotionTypeValue      NVARCHAR(50),
			BeginingDate            NVARCHAR(50),     
			EndingDate              NVARCHAR(50),     
			RebateAmount		    DECIMAL (18,6),
			AccumlatedQuantity		DECIMAL (18,6),
			AccumlatedAmount        DECIMAL (18,6),
			DiscThroughAmount       DECIMAL (18,6),
			DiscThroughQty          DECIMAL (18,6),
			DiscAmountUnit          DECIMAL (18,6),
			ysnPreview				NVARCHAR(1),
			currentUserId			INT
	)		



	-- Create the filter tables
	BEGIN
		IF OBJECT_ID('tempdb..#tmpUpdateItemSpecialPricingForCStore_Location') IS NULL 
			BEGIN
				CREATE TABLE #tmpUpdateItemSpecialPricingForCStore_Location (
					intLocationId INT 
				)
			END

		IF OBJECT_ID('tempdb..#tmpUpdateItemSpecialPricingForCStore_Vendor') IS NULL 
			BEGIN
				CREATE TABLE #tmpUpdateItemSpecialPricingForCStore_Vendor (
					intVendorId INT 
				)
			END

		IF OBJECT_ID('tempdb..#tmpUpdateItemSpecialPricingForCStore_Category') IS NULL 
			BEGIN
				CREATE TABLE #tmpUpdateItemSpecialPricingForCStore_Category (
					intCategoryId INT 
				)
			END

		IF OBJECT_ID('tempdb..#tmpUpdateItemSpecialPricingForCStore_Family') IS NULL 
			BEGIN
				CREATE TABLE #tmpUpdateItemSpecialPricingForCStore_Family (
					intFamilyId INT 
				)
			END

		IF OBJECT_ID('tempdb..#tmpUpdateItemSpecialPricingForCStore_Class') IS NULL 
			BEGIN
				CREATE TABLE #tmpUpdateItemSpecialPricingForCStore_Class (
					intClassId INT 
				)
			END

	END 



	IF OBJECT_ID('tempdb..#tmpUpdateItemSpecialPricingForCStore_AuditLog') IS NULL  
		CREATE TABLE #tmpUpdateItemSpecialPricingForCStore_AuditLog (
			intItemId INT
			,intItemSpecialPricingId INT 
			,dtmBeginDate_Original DATETIME 
			,dtmEndDate_Original DATETIME 
			,dblDiscount_Original NUMERIC(18, 6) 
			,dblAccumulatedAmount_Original NUMERIC(18, 6) 
			,dblAccumulatedQty_Original NUMERIC(18, 6) 
			,dblDiscountThruAmount_Original NUMERIC(18, 6) 
			,dblDiscountThruQty_Original NUMERIC(18, 6) 

			,dtmBeginDate_New DATETIME 
			,dtmEndDate_New DATETIME 
			,dblDiscount_New NUMERIC(18, 6) 
			,dblAccumulatedAmount_New NUMERIC(18, 6) 
			,dblAccumulatedQty_New NUMERIC(18, 6) 
			,dblDiscountThruAmount_New NUMERIC(18, 6) 
			,dblDiscountThruQty_New NUMERIC(18, 6) 
		)


	-- Add the filter records
	BEGIN
		IF(@Location IS NOT NULL AND @Location != '')
			BEGIN
				INSERT INTO #tmpUpdateItemSpecialPricingForCStore_Location (
					intLocationId
				)
				SELECT [intID] AS intLocationId
				FROM [dbo].[fnGetRowsFromDelimitedValues](@Location)
			END
		
		IF(@Vendor IS NOT NULL AND @Vendor != '')
			BEGIN
				INSERT INTO #tmpUpdateItemSpecialPricingForCStore_Vendor (
					intVendorId
				)
				SELECT [intID] AS intVendorId
				FROM [dbo].[fnGetRowsFromDelimitedValues](@Vendor)
			END

		IF(@Category IS NOT NULL AND @Category != '')
			BEGIN
				INSERT INTO #tmpUpdateItemSpecialPricingForCStore_Category (
					intCategoryId
				)
				SELECT [intID] AS intCategoryId
				FROM [dbo].[fnGetRowsFromDelimitedValues](@Category)
			END

		IF(@Family IS NOT NULL AND @Family != '')
			BEGIN
				INSERT INTO #tmpUpdateItemSpecialPricingForCStore_Family (
					intFamilyId
				)
				SELECT [intID] AS intFamilyId
				FROM [dbo].[fnGetRowsFromDelimitedValues](@Family)
			END

		IF(@Class IS NOT NULL AND @Class != '')
			BEGIN
				INSERT INTO #tmpUpdateItemSpecialPricingForCStore_Class (
					intClassId
				)
				SELECT [intID] AS intClassId
				FROM [dbo].[fnGetRowsFromDelimitedValues](@Class)
			END
	END


	BEGIN
		
		DECLARE @dtmBeginDateConv AS DATE = CAST(@BeginDate AS DATE)
		DECLARE @dtmEndDateConv AS DATE = CAST(@EndDate AS DATE)
		DECLARE @dblDiscount AS DECIMAL(18,6) = 0

		-- MARK START UPDATE
		SET @dtmDateTimeModifiedFrom = GETUTCDATE()

		IF(@PromotionType = 'Vendor Rebate')
			BEGIN
				SET @dblDiscount = @RebateAmount
				SET @PromotionType = 'Rebate'

				-- SP
				BEGIN TRY
					EXEC [uspICUpdateItemSpecialPricingForCStore]
						-- filter params
						@strUpcCode					= NULL 
						,@strDescription			= NULL 
						,@intItemId					= NULL 
						,@strPromotionType			= @PromotionType
						-- update params
						,@dtmBeginDate				= @dtmBeginDateConv
						,@dtmEndDate				= @dtmEndDateConv
						,@dblDiscount				= @dblDiscount

						,@dblAccumulatedAmount		= @AccumAmount
						,@dblAccumulatedQty			= @AccumlatedQty

						,@dblDiscountThruAmount		= NULL
						,@dblDiscountThruQty		= NULL

						,@intEntityUserSecurityId	= @currentUserId
				END TRY
				BEGIN CATCH
					SET @strResultMsg = 'Error Message: ' + ERROR_MESSAGE()

					GOTO ExitWithRollback 
				END CATCH

			END
		ELSE IF(@PromotionType = 'Vendor Discount')
			BEGIN
				SET @dblDiscount = @DiscAmountUnit

				-- SP
				BEGIN TRY
					EXEC [uspICUpdateItemSpecialPricingForCStore]
							-- filter params
							@strUpcCode					= NULL 
							,@strDescription			= NULL 
							,@intItemId					= NULL 
							,@strPromotionType			= @PromotionType
							-- update params
							,@dtmBeginDate				= @dtmBeginDateConv
							,@dtmEndDate				= @dtmEndDateConv
							,@dblDiscount				= @dblDiscount

							,@dblAccumulatedAmount		= NULL
							,@dblAccumulatedQty			= NULL

							,@dblDiscountThruAmount		= @DiscThroughAmount
							,@dblDiscountThruQty		= @DiscThroughQty

							,@intEntityUserSecurityId	= @currentUserId
				END TRY
				BEGIN CATCH
					SET @strResultMsg = 'Error Message: ' + ERROR_MESSAGE()

					GOTO ExitWithRollback 
				END CATCH

			END

		-- MARK END UPDATE
		SET @dtmDateTimeModifiedTo = GETUTCDATE()

		IF(@ysnRecap = 1)
			BEGIN
				SELECT '#tmpUpdateItemSpecialPricingForCStore_AuditLog', * FROM #tmpUpdateItemSpecialPricingForCStore_AuditLog
			END
	END




	-------------------------------------------------------------------------------------------------
	----------- Count Items -------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------
	BEGIN
		-- Handle preview using Table variable
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
			, intItemPricingId			INT NULL
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
			, ysnPreview				BIT DEFAULT(1)
			, ysnForRevert				BIT DEFAULT(0)
		)

--TEST
PRINT 'test01'


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
			, intItemPricingId
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
			, ysnPreview
			, ysnForRevert
		)
		SELECT DISTINCT 
			strTableName				= N'tblICItemSpecialPricing'
			, strTableColumnName		= CASE
											WHEN [Changes].oldColumnName = 'strBeginDate_Original' THEN 'dtmBeginDate'
											WHEN [Changes].oldColumnName = 'strEndDate_Original' THEN 'dtmEndDate'
											WHEN [Changes].oldColumnName = 'strDiscount_Original' THEN 'dblDiscount'
											WHEN [Changes].oldColumnName = 'strAccumulatedAmount_Original' THEN 'dblAccumulatedAmount'
											WHEN [Changes].oldColumnName = 'strAccumulatedQty_Original' THEN 'dblAccumulatedQty'
											WHEN [Changes].oldColumnName = 'strDiscountThruAmount_Original' THEN 'dblDiscountThruAmount'
											WHEN [Changes].oldColumnName = 'strDiscountThruQty_Original' THEN 'dblDiscountThruQty'
										END
			, strTableColumnDataType	= CASE
											WHEN [Changes].oldColumnName = 'strBeginDate_Original' THEN 'DATETIME'
											WHEN [Changes].oldColumnName = 'strEndDate_Original' THEN 'DATETIME'
											WHEN [Changes].oldColumnName = 'strDiscount_Original' THEN 'NUMERIC(18, 6)'
											WHEN [Changes].oldColumnName = 'strAccumulatedAmount_Original' THEN 'NUMERIC(18, 6)'
											WHEN [Changes].oldColumnName = 'strAccumulatedQty_Original' THEN 'NUMERIC(18, 6)'
											WHEN [Changes].oldColumnName = 'strDiscountThruAmount_Original' THEN 'NUMERIC(18, 6)'
											WHEN [Changes].oldColumnName = 'strDiscountThruQty_Original' THEN 'NUMERIC(18, 6)'
										END
			, intPrimaryKeyId			= IP.intItemSpecialPricingId
			, intParentId				= I.intItemId
			, intChildId				= NULL
			, intCurrentEntityUserId	= @currentUserId
			, intItemId					= I.intItemId
			, intItemUOMId				= UOM.intItemUOMId
			, intItemLocationId			= IL.intItemLocationId
			, intItemPricingId			= NULL
			, intItemSpecialPricingId	= IP.intItemSpecialPricingId

			, dtmDateModified			= IP.dtmDateModified
			, intCompanyLocationId		= CL.intCompanyLocationId
			, strLocation				= CL.strLocationName
			, strUpc					= UOM.strLongUPCCode
			, strItemDescription		= I.strDescription
			, strChangeDescription		= CASE
											WHEN [Changes].oldColumnName = 'strBeginDate_Original' THEN 'Begin Date'
											WHEN [Changes].oldColumnName = 'strEndDate_Original' THEN 'End Date'
											WHEN [Changes].oldColumnName = 'strDiscount_Original' THEN 'Discount'
											WHEN [Changes].oldColumnName = 'strAccumulatedAmount_Original' THEN 'Accumulated Amount'
											WHEN [Changes].oldColumnName = 'strAccumulatedQty_Original' THEN 'Accumulated Quantity'
											WHEN [Changes].oldColumnName = 'strDiscountThruAmount_Original' THEN 'Discount Through Amount'
											WHEN [Changes].oldColumnName = 'strDiscountThruQty_Original' THEN 'Discount Through Quantity'
										END
			, strPreviewOldData			= [Changes].strOldData
			, strPreviewNewData			= [Changes].strNewData
			, strOldDataPreview			= [Changes].strOldData
			, ysnPreview				= 1
			, ysnForRevert				= 1
		FROM 
		(
			SELECT DISTINCT intItemId, intItemSpecialPricingId, oldColumnName, strOldData, strNewData
			FROM 
			(
				SELECT 
					intItemId 
					, intItemSpecialPricingId 
					,CAST(CAST(dtmBeginDate_Original AS DATE) AS NVARCHAR(50)) AS strBeginDate_Original
					,CAST(CAST(dtmEndDate_Original AS DATE) AS NVARCHAR(50)) AS strEndDate_Original
					,CAST(CAST(dblDiscount_Original AS DECIMAL(18,3)) AS NVARCHAR(50)) AS strDiscount_Original
					,CAST(CAST(dblAccumulatedAmount_Original AS DECIMAL(18,3)) AS NVARCHAR(50)) AS strAccumulatedAmount_Original
					,CAST(CAST(dblAccumulatedQty_Original AS DECIMAL(18,3)) AS NVARCHAR(50)) AS strAccumulatedQty_Original
					,CAST(CAST(dblDiscountThruAmount_Original AS DECIMAL(18,3)) AS NVARCHAR(50)) AS strDiscountThruAmount_Original
					,CAST(CAST(dblDiscountThruQty_Original AS DECIMAL(18,3)) AS NVARCHAR(50)) AS strDiscountThruQty_Original

					,CAST(CAST(dtmBeginDate_New AS DATE) AS NVARCHAR(50)) AS strBeginDate_New
					,CAST(CAST(dtmEndDate_New AS DATE) AS NVARCHAR(50)) AS strEndDate_New
					,CAST(CAST(dblDiscount_New AS DECIMAL(18,3)) AS NVARCHAR(50)) AS strDiscount_New
					,CAST(CAST(dblAccumulatedAmount_New AS DECIMAL(18,3)) AS NVARCHAR(50)) AS strAccumulatedAmount_New
					,CAST(CAST(dblAccumulatedQty_New AS DECIMAL(18,3)) AS NVARCHAR(50)) AS strAccumulatedQty_New
					,CAST(CAST(dblDiscountThruAmount_New AS DECIMAL(18,3)) AS NVARCHAR(50)) AS strDiscountThruAmount_New
					,CAST(CAST(dblDiscountThruQty_New AS DECIMAL(18,3)) AS NVARCHAR(50)) AS strDiscountThruQty_New
				FROM #tmpUpdateItemSpecialPricingForCStore_AuditLog
			) t
			unpivot
			(
				strOldData for oldColumnName in (strBeginDate_Original, strEndDate_Original, strDiscount_Original, strAccumulatedAmount_Original, strAccumulatedQty_Original, strDiscountThruAmount_Original, strDiscountThruQty_Original)
			) o
			unpivot
			(
				strNewData for newColumnName in (strBeginDate_New, strEndDate_New, strDiscount_New, strAccumulatedAmount_New, strAccumulatedQty_New, strDiscountThruAmount_New, strDiscountThruQty_New)
			) n
			WHERE  REPLACE(oldColumnName, '_Original', '') = REPLACE(newColumnName, '_New', '')	
		
		) [Changes]
		INNER JOIN tblICItem I 
			ON [Changes].intItemId = I.intItemId
		INNER JOIN tblICItemSpecialPricing IP 
			ON [Changes].intItemSpecialPricingId = IP.intItemSpecialPricingId
		INNER JOIN tblICItemUOM UOM 
			ON IP.intItemId = UOM.intItemId
		INNER JOIN tblICItemLocation IL 
			ON IP.intItemLocationId = IL.intItemLocationId 
			AND [Changes].intItemId = IL.intItemId
		INNER JOIN tblSMCompanyLocation CL 
			ON IL.intLocationId = CL.intCompanyLocationId
		WHERE 
		(
			NOT EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemSpecialPricingForCStore_Location)
			OR EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemSpecialPricingForCStore_Location WHERE intLocationId = CL.intCompanyLocationId) 			
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

			BEGIN TRAN

				-- INSERT TO PREVIEW TABLE
				INSERT INTO tblSTUpdateRebateOrDiscountPreview
				(
					[strGuid], 
					[strLocation],
					[strUpc],
					[strDescription],
					[strChangeDescription],
					[strOldData],
					[strNewData],

					[intItemId],
					[intItemUOMId],
					[intItemLocationId],
					[intTableIdentityId],
					[strTableName],
					[strColumnName],
					[strColumnDataType],

					[intConcurrencyId]
				)
				SELECT DISTINCT 
					[strGuid]				= @strGuid, 
					[strLocation]			= strLocation,
					[strUpc]				= strUpc,
					[strDescription]		= strItemDescription,
					[strChangeDescription]	= strChangeDescription,
					[strOldData]			= strPreviewOldData,
					[strNewData]			= strPreviewNewData,

					[intItemId]				= intItemId,
					[intItemUOMId]			= intItemUOMId,
					[intItemLocationId]		= intItemLocationId,
					[intTableIdentityId]	= intPrimaryKeyId,
					[strTableName]			= strTableName,
					[strColumnName]			= strTableColumnName,
					[strColumnDataType]		= strTableColumnDataType,

					[intConcurrencyId]		= 1
				FROM @tblPreview
				WHERE ysnPreview = 1
				ORDER BY strItemDescription, strChangeDescription ASC
			
			COMMIT TRAN
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
					IF EXISTS(SELECT TOP 1 1 FROM #tmpUpdateItemSpecialPricingForCStore_Location)
							BEGIN

								SET @strFilterCriteria = @strFilterCriteria + '<p id="p2"><b>Location</b></p>'
								
								SELECT @strFilterCriteria = @strFilterCriteria + '<p id="p2">&emsp;' + CompanyLoc.strLocationName + '</p>'
								FROM #tmpUpdateItemSpecialPricingForCStore_Location tempLoc
								INNER JOIN tblSMCompanyLocation CompanyLoc
									ON tempLoc.intLocationId = CompanyLoc.intCompanyLocationId

							END
						
						IF EXISTS(SELECT TOP 1 1 FROM #tmpUpdateItemSpecialPricingForCStore_Vendor)
							BEGIN

								SET @strFilterCriteria = @strFilterCriteria + '<p id="p2"><b>Vendor</b></p>'
								
								SELECT @strFilterCriteria = @strFilterCriteria + '<p id="p2">&emsp;' + EntityVendor.strName + '</p>'
								FROM #tmpUpdateItemSpecialPricingForCStore_Vendor tempVendor
								INNER JOIN tblEMEntity EntityVendor
									ON tempVendor.intVendorId = EntityVendor.intEntityId

							END

						IF EXISTS(SELECT TOP 1 1 FROM #tmpUpdateItemSpecialPricingForCStore_Category)
							BEGIN

								SET @strFilterCriteria = @strFilterCriteria + '<p id="p2"><b>Category</b></p>'
								
								SELECT @strFilterCriteria = @strFilterCriteria + '<p id="p2">&emsp;' + Category.strCategoryCode + '</p>'
								FROM #tmpUpdateItemSpecialPricingForCStore_Category tempCategory
								INNER JOIN tblICCategory Category
									ON tempCategory.intCategoryId = Category.intCategoryId

							END

						IF EXISTS(SELECT TOP 1 1 FROM #tmpUpdateItemSpecialPricingForCStore_Family)
							BEGIN

								SET @strFilterCriteria = @strFilterCriteria + '<p id="p2"><b>Family</b></p>'
								
								SELECT @strFilterCriteria = @strFilterCriteria + '<p id="p2">&emsp;' + SubFamily.strSubcategoryId + '</p>'
								FROM #tmpUpdateItemSpecialPricingForCStore_Family tempFamily
								INNER JOIN tblSTSubcategory SubFamily
									ON tempFamily.intFamilyId = SubFamily.intSubcategoryId
								WHERE SubFamily.strSubcategoryType = 'F'

							END

						IF EXISTS(SELECT TOP 1 1 FROM #tmpUpdateItemSpecialPricingForCStore_Class)
							BEGIN

								SET @strFilterCriteria = @strFilterCriteria + '<p id="p2"><b>Class</b></p>'
								
								SELECT @strFilterCriteria = @strFilterCriteria + '<p id="p2">&emsp;' + SubClass.strSubcategoryId + '</p>'
								FROM #tmpUpdateItemSpecialPricingForCStore_Class tempClass
								INNER JOIN tblSTSubcategory SubClass
									ON tempClass.intClassId = SubClass.intSubcategoryId
								WHERE SubClass.strSubcategoryType = 'C'

							END
						-- SELECT @strLottedItem = LEFT(@strLottedItem, LEN(@strLottedItem)-1)
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
							[dtmDateTimeModifiedFrom]	= @dtmDateTimeModifiedFrom,
							[dtmDateTimeModifiedTo]		= @dtmDateTimeModifiedTo,
							[intMassUpdatedRowCount]	= @intMassUpdatedRowCount,
							[intRevertType]				= 3,						-- *** Note: 1=Update Item Data,	2=Update Item Pricing,	  3=Update Rebate Or Discount
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
							[intItemPricingId],
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
							[intItemPricingId]			= intItemPricingId,
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
															ELSE strPreviewOldData
														END,
							[strPreviewOldData]			= strOldDataPreview,
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
		IF OBJECT_ID('tempdb..#tmpUpdateItemSpecialPricingForCStore_Location') IS NOT NULL  
			DROP TABLE #tmpUpdateItemSpecialPricingForCStore_Location 

		IF OBJECT_ID('tempdb..#tmpUpdateItemSpecialPricingForCStore_Vendor') IS NOT NULL  
			DROP TABLE #tmpUpdateItemSpecialPricingForCStore_Vendor 

		IF OBJECT_ID('tempdb..#tmpUpdateItemSpecialPricingForCStore_Category') IS NOT NULL   
			DROP TABLE #tmpUpdateItemSpecialPricingForCStore_Category 

		IF OBJECT_ID('tempdb..#tmpUpdateItemSpecialPricingForCStore_Family') IS NOT NULL  
			DROP TABLE #tmpUpdateItemSpecialPricingForCStore_Family 

		IF OBJECT_ID('tempdb..#tmpUpdateItemSpecialPricingForCStore_Class') IS NOT NULL  
			DROP TABLE #tmpUpdateItemSpecialPricingForCStore_Class 

		IF OBJECT_ID('tempdb..#tmpUpdateItemSpecialPricingForCStore_AuditLog') IS NOT NULL   
			DROP TABLE #tmpUpdateItemSpecialPricingForCStore_AuditLog 

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
	FROM @tblPreview
	WHERE ysnPreview = 1
	ORDER BY strItemDescription, strChangeDescription ASC
   
	---------------------------------------------------------------------------------------
	----------------------------- END Query Preview ---------------------------------------
	---------------------------------------------------------------------------------------




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
		END




END TRY

BEGIN CATCH       
	SET @ErrMsg = ERROR_MESSAGE()     
	 SET @strResultMsg = 'Error Message: ' + ERROR_MESSAGE()
	 IF @idoc <> 0 EXEC sp_xml_removedocument @idoc      
	 
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


--CREATE PROCEDURE [dbo].[uspSTUpdateRebateOrDiscount]
--	@XML varchar(max)
	
--AS
--BEGIN TRY

--	DECLARE @ErrMsg					NVARCHAR(MAX),
--	        @idoc					INT,
--	    	@Location 			    NVARCHAR(MAX),
--			@Vendor                 NVARCHAR(MAX),
--			@Category               NVARCHAR(MAX),
--			@Family                 NVARCHAR(MAX),
--			@Class                  NVARCHAR(MAX),
--			@PromotionType          NVARCHAR(50),
--			@BeginDate   			NVARCHAR(50),     
--			@EndDate		 	    NVARCHAR(50),     
--		    @RebateAmount           DECIMAL (18,6),
--			@AccumlatedQty          DECIMAL (18,6),
--			@AccumAmount            DECIMAL (18,6),
--			@DiscThroughAmount      DECIMAL (18,6),
--			@DiscThroughQty         DECIMAL (18,6),
--			@DiscAmountUnit         DECIMAL (18,6),
--			@ysnPreview             NVARCHAR(1),
--			@currentUserId			INT
		
	                  
--	EXEC sp_xml_preparedocument @idoc OUTPUT, @XML 
	
--	SELECT	
--			@Location	   	    =	Location,
--            @Vendor             =   Vendor,
--			@Category           =   Category,
--			@Family             =   Family,
--            @Class              =   Class,
--			@PromotionType      =   PromotionTypeValue, 
--			@BeginDate          =   BeginingDate,
--			@EndDate            =   EndingDate,
--			@RebateAmount 	    =	RebateAmount,
--			@AccumlatedQty	    =	AccumlatedQuantity,
--			@AccumAmount	    =	AccumlatedAmount,
--		    @DiscThroughAmount  =   DiscThroughAmount,
--			@DiscThroughQty     =   DiscThroughQty,
--			@DiscAmountUnit     =   DiscAmountUnit,
--			@ysnPreview			=	ysnPreview,
--			@currentUserId		=   currentUserId

--	FROM	OPENXML(@idoc, 'root',2)
--	WITH
--	(
--			Location		        NVARCHAR(MAX),
--			Vendor	     	        NVARCHAR(MAX),
--			Category		        NVARCHAR(MAX),
--			Family	     	        NVARCHAR(MAX),
--			Class	     	        NVARCHAR(MAX),
--			PromotionTypeValue      NVARCHAR(50),
--			BeginingDate            NVARCHAR(50),     
--			EndingDate              NVARCHAR(50),     
--			RebateAmount		    DECIMAL (18,6),
--			AccumlatedQuantity		DECIMAL (18,6),
--			AccumlatedAmount        DECIMAL (18,6),
--			DiscThroughAmount       DECIMAL (18,6),
--			DiscThroughQty          DECIMAL (18,6),
--			DiscAmountUnit          DECIMAL (18,6),
--			ysnPreview				NVARCHAR(1),
--			currentUserId			INT
--	)		



--	-- Create the filter tables
--	BEGIN
--		CREATE TABLE #tmpUpdateItemSpecialPricingForCStore_Location (
--			intLocationId INT 
--		)

--		CREATE TABLE #tmpUpdateItemSpecialPricingForCStore_Vendor (
--			intVendorId INT 
--		)

--		CREATE TABLE #tmpUpdateItemSpecialPricingForCStore_Category (
--			intCategoryId INT 
--		)

--		CREATE TABLE #tmpUpdateItemSpecialPricingForCStore_Family (
--			intFamilyId INT 
--		)

--		CREATE TABLE #tmpUpdateItemSpecialPricingForCStore_Class (
--			intClassId INT 
--		)
--	END 


--	IF OBJECT_ID('tempdb..#tmpUpdateItemSpecialPricingForCStore_AuditLog') IS NULL  
--		CREATE TABLE #tmpUpdateItemSpecialPricingForCStore_AuditLog (
--			intItemId INT
--			,intItemSpecialPricingId INT 
--			,dtmBeginDate_Original DATETIME 
--			,dtmEndDate_Original DATETIME 
--			,dblDiscount_Original NUMERIC(18, 6) 
--			,dblAccumulatedAmount_Original NUMERIC(18, 6) 
--			,dblAccumulatedQty_Original NUMERIC(18, 6) 
--			,dblDiscountThruAmount_Original NUMERIC(18, 6) 
--			,dblDiscountThruQty_Original NUMERIC(18, 6) 

--			,dtmBeginDate_New DATETIME 
--			,dtmEndDate_New DATETIME 
--			,dblDiscount_New NUMERIC(18, 6) 
--			,dblAccumulatedAmount_New NUMERIC(18, 6) 
--			,dblAccumulatedQty_New NUMERIC(18, 6) 
--			,dblDiscountThruAmount_New NUMERIC(18, 6) 
--			,dblDiscountThruQty_New NUMERIC(18, 6) 
--		)


--	-- Add the filter records
--	BEGIN
--		IF(@Location IS NOT NULL AND @Location != '')
--			BEGIN
--				INSERT INTO #tmpUpdateItemSpecialPricingForCStore_Location (
--					intLocationId
--				)
--				--SELECT intLocationId = CAST(@strCompanyLocationId AS INT)
--				SELECT [intID] AS intLocationId
--				FROM [dbo].[fnGetRowsFromDelimitedValues](@Location)
--			END
		
--		IF(@Vendor IS NOT NULL AND @Vendor != '')
--			BEGIN
--				INSERT INTO #tmpUpdateItemSpecialPricingForCStore_Vendor (
--					intVendorId
--				)
--				--SELECT intVendorId = CAST(@strVendorId AS INT)
--				SELECT [intID] AS intVendorId
--				FROM [dbo].[fnGetRowsFromDelimitedValues](@Vendor)
--			END

--		IF(@Category IS NOT NULL AND @Category != '')
--			BEGIN
--				INSERT INTO #tmpUpdateItemSpecialPricingForCStore_Category (
--					intCategoryId
--				)
--				--SELECT intCategoryId = CAST(@strCategoryId AS INT)
--				SELECT [intID] AS intCategoryId
--				FROM [dbo].[fnGetRowsFromDelimitedValues](@Category)
--			END

--		IF(@Family IS NOT NULL AND @Family != '')
--			BEGIN
--				INSERT INTO #tmpUpdateItemSpecialPricingForCStore_Family (
--					intFamilyId
--				)
--				--SELECT intFamilyId = CAST(@strFamilyId AS INT)
--				SELECT [intID] AS intFamilyId
--				FROM [dbo].[fnGetRowsFromDelimitedValues](@Family)
--			END

--		IF(@Class IS NOT NULL AND @Class != '')
--			BEGIN
--				INSERT INTO #tmpUpdateItemSpecialPricingForCStore_Class (
--					intClassId
--				)
--				--SELECT intClassId = CAST(@strClassId AS INT)
--				SELECT [intID] AS intClassId
--				FROM [dbo].[fnGetRowsFromDelimitedValues](@Class)
--			END
--	END


--	BEGIN
		
--		DECLARE @dtmBeginDateConv AS DATE = CAST(@BeginDate AS DATE)
--		DECLARE @dtmEndDateConv AS DATE = CAST(@EndDate AS DATE)
--		DECLARE @dblDiscount AS DECIMAL(18,6) = 0

--		IF(@PromotionType = 'Vendor Rebate')
--			BEGIN
--				SET @dblDiscount = @RebateAmount
--				SET @PromotionType = 'Rebate'

--				-- SP
--				EXEC [uspICUpdateItemSpecialPricingForCStore]
--					-- filter params
--					@strUpcCode = NULL 
--					,@strDescription = NULL 
--					,@intItemId = NULL 
--					,@strPromotionType = @PromotionType
--					-- update params
--					,@dtmBeginDate = @dtmBeginDateConv
--					,@dtmEndDate = @dtmEndDateConv
--					,@dblDiscount = @dblDiscount

--					,@dblAccumulatedAmount = @AccumAmount
--					,@dblAccumulatedQty = @AccumlatedQty

--					,@dblDiscountThruAmount = NULL
--					,@dblDiscountThruQty = NULL

--					,@intEntityUserSecurityId = @currentUserId
--			END
--		ELSE IF(@PromotionType = 'Vendor Discount')
--			BEGIN
--				SET @dblDiscount = @DiscAmountUnit

--				-- SP
--				EXEC [uspICUpdateItemSpecialPricingForCStore]
--						-- filter params
--						@strUpcCode = NULL 
--						,@strDescription = NULL 
--						,@intItemId = NULL 
--						,@strPromotionType = @PromotionType
--						-- update params
--						,@dtmBeginDate = @dtmBeginDateConv
--						,@dtmEndDate = @dtmEndDateConv
--						,@dblDiscount = @dblDiscount

--						,@dblAccumulatedAmount = NULL
--						,@dblAccumulatedQty = NULL

--						,@dblDiscountThruAmount = @DiscThroughAmount
--						,@dblDiscountThruQty = @DiscThroughQty

--						,@intEntityUserSecurityId = @currentUserId
--			END
--	END




--	-------------------------------------------------------------------------------------------------
--	----------- Count Items -------------------------------------------------------------------------
--	-------------------------------------------------------------------------------------------------
--	-- Handle preview using Table variable
--	DECLARE @tblPreview TABLE (
--	    intCompanyLocationId INT
--		, strLocation NVARCHAR(250)
--		, strUpc NVARCHAR(50)
--		, strItemDescription NVARCHAR(250)
--		, strChangeDescription NVARCHAR(100)
--		, strOldData NVARCHAR(MAX)
--		, strNewData NVARCHAR(MAX)
--		, intParentId INT
--		, intChildId INT
--	)


--	-- ITEM SPECIAL PRICING
--	INSERT INTO @tblPreview (
--		intCompanyLocationId
--		, strLocation
--		, strUpc
--		, strItemDescription
--		, strChangeDescription
--		, strOldData
--		, strNewData
--		, intParentId
--		, intChildId
--	)
--	SELECT	CL.intCompanyLocationId
--	        ,CL.strLocationName
--			,UOM.strLongUPCCode
--			,I.strDescription
--			,CASE
--				WHEN [Changes].oldColumnName = 'strBeginDate_Original' THEN 'Begin Date'
--				WHEN [Changes].oldColumnName = 'strEndDate_Original' THEN 'End Date'
--				WHEN [Changes].oldColumnName = 'strDiscount_Original' THEN 'Discount'
--				WHEN [Changes].oldColumnName = 'strAccumulatedAmount_Original' THEN 'Accumulated Amount'
--				WHEN [Changes].oldColumnName = 'strAccumulatedQty_Original' THEN 'Accumulated Quantity'
--				WHEN [Changes].oldColumnName = 'strDiscountThruAmount_Original' THEN 'Discount Through Amount'
--				WHEN [Changes].oldColumnName = 'strDiscountThruQty_Original' THEN 'Discount Through Quantity'
--			END
--			,[Changes].strOldData
--			,[Changes].strNewData
--	        ,[Changes].intItemId 
--			,[Changes].intItemSpecialPricingId
--	FROM 
--	(
--		SELECT DISTINCT intItemId, intItemSpecialPricingId, oldColumnName, strOldData, strNewData
--		FROM 
--		(
--			SELECT intItemId
--					,intItemSpecialPricingId 
--					,CAST(CAST(dtmBeginDate_Original AS DATE) AS NVARCHAR(50)) AS strBeginDate_Original
--					,CAST(CAST(dtmEndDate_Original AS DATE) AS NVARCHAR(50)) AS strEndDate_Original
--					,CAST(CAST(dblDiscount_Original AS DECIMAL(18,3)) AS NVARCHAR(50)) AS strDiscount_Original
--					,CAST(CAST(dblAccumulatedAmount_Original AS DECIMAL(18,3)) AS NVARCHAR(50)) AS strAccumulatedAmount_Original
--					,CAST(CAST(dblAccumulatedQty_Original AS DECIMAL(18,3)) AS NVARCHAR(50)) AS strAccumulatedQty_Original
--					,CAST(CAST(dblDiscountThruAmount_Original AS DECIMAL(18,3)) AS NVARCHAR(50)) AS strDiscountThruAmount_Original
--					,CAST(CAST(dblDiscountThruQty_Original AS DECIMAL(18,3)) AS NVARCHAR(50)) AS strDiscountThruQty_Original

--					,CAST(CAST(dtmBeginDate_New AS DATE) AS NVARCHAR(50)) AS strBeginDate_New
--					,CAST(CAST(dtmEndDate_New AS DATE) AS NVARCHAR(50)) AS strEndDate_New
--					,CAST(CAST(dblDiscount_New AS DECIMAL(18,3)) AS NVARCHAR(50)) AS strDiscount_New
--					,CAST(CAST(dblAccumulatedAmount_New AS DECIMAL(18,3)) AS NVARCHAR(50)) AS strAccumulatedAmount_New
--					,CAST(CAST(dblAccumulatedQty_New AS DECIMAL(18,3)) AS NVARCHAR(50)) AS strAccumulatedQty_New
--					,CAST(CAST(dblDiscountThruAmount_New AS DECIMAL(18,3)) AS NVARCHAR(50)) AS strDiscountThruAmount_New
--					,CAST(CAST(dblDiscountThruQty_New AS DECIMAL(18,3)) AS NVARCHAR(50)) AS strDiscountThruQty_New
--			FROM #tmpUpdateItemSpecialPricingForCStore_AuditLog
--		) t
--		unpivot
--		(
--			strOldData for oldColumnName in (strBeginDate_Original, strEndDate_Original, strDiscount_Original, strAccumulatedAmount_Original, strAccumulatedQty_Original, strDiscountThruAmount_Original, strDiscountThruQty_Original)
--		) o
--		unpivot
--		(
--			strNewData for newColumnName in (strBeginDate_New, strEndDate_New, strDiscount_New, strAccumulatedAmount_New, strAccumulatedQty_New, strDiscountThruAmount_New, strDiscountThruQty_New)
--		) n
--		WHERE  REPLACE(oldColumnName, '_Original', '') = REPLACE(newColumnName, '_New', '')	
		
--	) [Changes]
--	INNER JOIN tblICItem I 
--		ON [Changes].intItemId = I.intItemId
--	INNER JOIN tblICItemSpecialPricing IP 
--		ON [Changes].intItemSpecialPricingId = IP.intItemSpecialPricingId
--	INNER JOIN tblICItemUOM UOM 
--		ON IP.intItemId = UOM.intItemId
--	INNER JOIN tblICItemLocation IL 
--		ON IP.intItemLocationId = IL.intItemLocationId 
--		AND [Changes].intItemId = IL.intItemId
--	INNER JOIN tblSMCompanyLocation CL 
--		ON IL.intLocationId = CL.intCompanyLocationId
--	WHERE 
--	(
--		NOT EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemSpecialPricingForCStore_Location)
--		OR EXISTS (SELECT TOP 1 1 FROM #tmpUpdateItemSpecialPricingForCStore_Location WHERE intLocationId = CL.intCompanyLocationId) 			
--	)

	
--	-------------------------------------------------------------------------------------------------
--	----------- Count Items -------------------------------------------------------------------------
--	-------------------------------------------------------------------------------------------------

--	--DELETE FROM @tblPreview WHERE ISNULL(strOldData, '') = ISNULL(strNewData, '')
--	--DECLARE @RecCount AS INT = (SELECT COUNT(*) FROM @tblPreview)
--	--DECLARE @UpdateCount AS INT = (SELECT COUNT(DISTINCT intChildId) FROM @tblPreview)

--	--SELECT  @RecCount as RecCount,  @UpdateCount as UpdateItemPrcicingCount	


--	---------------------------------------------------------------------------------------
--	----------------------------- START Query Preview -------------------------------------
--	---------------------------------------------------------------------------------------
--	DELETE FROM @tblPreview WHERE ISNULL(strOldData, '') = ISNULL(strNewData, '')

--	-- Query Preview display
--	SELECT DISTINCT 
--	          strLocation
--			  , strUpc
--			  , strItemDescription
--			  , strChangeDescription
--			  , strOldData
--			  , strNewData
--	FROM @tblPreview
--	ORDER BY strItemDescription, strChangeDescription ASC
    
--	DELETE FROM @tblPreview
--	---------------------------------------------------------------------------------------
--	----------------------------- END Query Preview ---------------------------------------
--	---------------------------------------------------------------------------------------

--END TRY

--BEGIN CATCH       
-- SET @ErrMsg = ERROR_MESSAGE()      
-- IF @idoc <> 0 EXEC sp_xml_removedocument @idoc      
-- RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')      
--END CATCH