CREATE PROCEDURE [dbo].[uspSTUpdateItemDiscontinued]
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
			@Location 			NVARCHAR(MAX),
			@Vendor             NVARCHAR(MAX),
			@Category           NVARCHAR(MAX),
			@Family             NVARCHAR(MAX),
			@Class              NVARCHAR(MAX),
		    @NotSoldSince		NVARCHAR(50),
			@NotPurchasedSince  NVARCHAR(50),
			@CreatedOlder		NVARCHAR(50),
			@ysnPreview			NVARCHAR(1),
			@currentUserId		INT
	

	EXEC sp_xml_preparedocument @idoc OUTPUT, @XML 


	SELECT	
			@Location			=	 Location,
            @Vendor				=   Vendor,
			@Category			=   Category,
			@Family				=   Family,
            @Class				=   Class,
            @NotSoldSince       =   NotSoldSince,
            @NotPurchasedSince  =   NotPurchasedSince,
            @CreatedOlder       =   CreatedOlder,
			@ysnPreview			=   ysnPreview,
			@currentUserId		=   currentUserId
		
	FROM	OPENXML(@idoc, 'root',2)
	WITH
	(
			Location		        NVARCHAR(MAX),
			Vendor	     	        NVARCHAR(MAX),
			Category		        NVARCHAR(MAX),
			Family	     	        NVARCHAR(MAX),
			Class	     	        NVARCHAR(MAX),
			NotSoldSince			NVARCHAR(50),
			NotPurchasedSince		NVARCHAR(50),
			CreatedOlder			NVARCHAR(50),
			ysnPreview				NVARCHAR(1),
			currentUserId			INT
	)  

	--START Create the filter tables
	BEGIN
		IF OBJECT_ID('tempdb..#tmpUpdateItemForCStore_Location') IS NULL 
			BEGIN
				CREATE TABLE #tmpUpdateItemForCStore_Location (
					intLocationId INT 
				)
			END

		IF OBJECT_ID('tempdb..#tmpUpdateItemForCStore_Vendor') IS NULL 
			BEGIN
				CREATE TABLE #tmpUpdateItemForCStore_Vendor (
					intVendorId INT 
				)
			END

		IF OBJECT_ID('tempdb..#tmpUpdateItemForCStore_Category') IS NULL 
			BEGIN
				CREATE TABLE #tmpUpdateItemForCStore_Category (
					intCategoryId INT 
				)
			END

		IF OBJECT_ID('tempdb..#tmpUpdateItemForCStore_Family') IS NULL 
			BEGIN
				CREATE TABLE #tmpUpdateItemForCStore_Family (
					intFamilyId INT 
				)
			END

		IF OBJECT_ID('tempdb..#tmpUpdateItemForCStore_Class') IS NULL 
			BEGIN
				CREATE TABLE #tmpUpdateItemForCStore_Class (
					intClassId INT 
				)
			END
			
		IF OBJECT_ID('tempdb..#tmpUpdateItemForCStore_Items') IS NULL 
			BEGIN
				CREATE TABLE #tmpUpdateItemForCStore_Items (
					intItemId INT,
					dtmNotSoldSince DATETIME,
					dtmNotPurchased DATETIME,
					dtmCreatedOlderThan DATETIME
				)
			END

		-- Create the temp table for the audit log. 
		IF OBJECT_ID('tempdb..#tmpUpdateItemForCStore_itemAuditLog') IS NULL  
			CREATE TABLE #tmpUpdateItemForCStore_itemAuditLog (
				intItemId INT
				-- Original Fields
				,intCategoryId_Original INT NULL
				,strCountCode_Original NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
				,strDescription_Original NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL
				,strItemNo_Original NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL
				,strShortName_Original NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL
				,strStatus_Original NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL
				-- Modified Fields
				,intCategoryId_New INT NULL
				,strCountCode_New NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
				,strDescription_New NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL
				,strItemNo_New NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL
				,strShortName_New NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL
				,strStatus_New NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL
			)
		;
	END
	-- END Create the filter tables

	-- START Add the filter records
	BEGIN
		IF(@Location IS NOT NULL AND @Location != '')
			BEGIN
				INSERT INTO #tmpUpdateItemForCStore_Location (
					intLocationId
				)
				SELECT [intID] AS intLocationId
				FROM [dbo].[fnGetRowsFromDelimitedValues](@Location)
			END
		
		IF(@Vendor IS NOT NULL AND @Vendor != '')
			BEGIN
				INSERT INTO #tmpUpdateItemForCStore_Vendor (
					intVendorId
				)
				SELECT [intID] AS intVendorId
				FROM [dbo].[fnGetRowsFromDelimitedValues](@Vendor)
			END

		IF(@Category IS NOT NULL AND @Category != '')
			BEGIN
				INSERT INTO #tmpUpdateItemForCStore_Category (
					intCategoryId
				)
				SELECT [intID] AS intCategoryId
				FROM [dbo].[fnGetRowsFromDelimitedValues](@Category)
			END

		IF(@Family IS NOT NULL AND @Family != '')
			BEGIN
				INSERT INTO #tmpUpdateItemForCStore_Family (
					intFamilyId
				)
				SELECT [intID] AS intFamilyId
				FROM [dbo].[fnGetRowsFromDelimitedValues](@Family)
			END

		IF(@Class IS NOT NULL AND @Class != '')
			BEGIN
				INSERT INTO #tmpUpdateItemForCStore_Class (
					intClassId
				)
				SELECT [intID] AS intClassId
				FROM [dbo].[fnGetRowsFromDelimitedValues](@Class)
			END

		--Add OR condition for ST-2009	
		IF (@CreatedOlder IS NOT NULL OR @CreatedOlder != '' OR
			@NotSoldSince IS NOT NULL OR @NotSoldSince != '' OR
			@NotPurchasedSince IS NOT NULL OR @NotPurchasedSince != '' )
			BEGIN
					INSERT INTO #tmpUpdateItemForCStore_Items (
					intItemId,
					dtmCreatedOlderThan,
					dtmNotSoldSince,
					dtmNotPurchased
				)
				SELECT DISTINCT item.intItemId as intItemId,
				item.dtmDateCreated as dtmCreatedOlderThan,
				invoice.dtmDate as dtmNotSoldSince,
				receipt.dtmDateCreated as dtmNotPurchased
				FROM tblICItem item
				LEFT JOIN tblARInvoiceDetail invoicedetail
					ON item.intItemId = invoicedetail.intItemId
				LEFT JOIN tblARInvoice invoice
					ON invoicedetail.intInvoiceId = invoice.intInvoiceId
				LEFT JOIN tblICInventoryReceiptItem receipt
					ON item.intItemId = receipt.intItemId
				WHERE item.strStatus != 'Discontinued'

		END


	END
	-- END Add the filter records

	-- MARK START UPDATE
	SET @dtmDateTimeModifiedFrom = GETUTCDATE()

	BEGIN TRY
		
		IF (EXISTS (SELECT * FROM #tmpUpdateItemForCStore_Items))
		BEGIN
			-- This is where IC SP Executed for updating 
			EXEC [uspICUpdateItemForCStore]
					@strDescription					= NULL
					,@dblRetailPriceFrom			= NULL
					,@dblRetailPriceTo 				= NULL
					,@intItemId 					= NULL
					,@intItemUOMId 					= NULL
					--update params				
					,@intCategoryId 				= NULL
					,@strCountCode 					= NULL
					,@strItemDescription 			= NULL
					,@strItemNo 					= NULL
					,@strShortName 					= NULL
					,@strUpcCode					= NULL
					,@strLongUpcCode 				= NULL
					,@strStatus 					= 'Discontinued'
					,@intEntityUserSecurityId		= @currentUserId
		END

	END TRY
	BEGIN CATCH
		SELECT 'uspICUpdateItemDiscontinuedForCStore', ERROR_MESSAGE()
		SET @strResultMsg = 'Error Message: ' + ERROR_MESSAGE()

		GOTO ExitWithRollback 
	END CATCH

	-- MARK END UPDATE
	SET @dtmDateTimeModifiedTo = GETUTCDATE()

	
	-------------------------------------------------------------------------------------------------
	----------- Count Items -------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------
	BEGIN
		-- Handle preview using Table variable
		DECLARE @tblPreview TABLE (
			strTableName				NVARCHAR(150)
			, strTableColumnName		NVARCHAR(150)
			, strTableColumnDataType	NVARCHAR(50)
			, intPrimaryKeyId			INT NULL
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
			, dtmNotSoldSince			DATETIME -- Added 
			, dtmNotPurchased			DATETIME -- Added 
			, dtmCreatedOlderThan		DATETIME -- Added 
		)

		-- ITEM PRICING
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
			, dtmNotSoldSince			 -- Added 
			, dtmNotPurchased			 -- Added 
			, dtmCreatedOlderThan		 -- Added 
		)
		SELECT	DISTINCT
				strTableName					= N'tblICItem'
				, strTableColumnName			= 'strStatus'
				, strTableColumnDataType		= 'VARCHAR'
				, intPrimaryKeyId				= NULL
				, intParentId					= I.intItemId
				, intChildId					= NULL
				, intCurrentEntityUserId		= @currentUserId
				, intItemId						= I.intItemId
				, intItemUOMId					= UOM.intItemUOMId
				, intItemLocationId				= NULL
				, intItemPricingId				= NULL
				, intItemSpecialPricingId		= NULL

				, dtmDateModified				= I.dtmDateModified
				, intCompanyLocationId			= NULL
				, strLocation					= NULL
				, strUpc						= UOM.strLongUPCCode
				, strItemDescription			= I.strDescription
				, strChangeDescription			= 'Status'
				, strPreviewOldData				= 'Active'
				, strPreviewNewData				= 'Discontinued'
				, strOldDataPreview				= 'Discontinued'

				, ysnPreview					= 1
				, ysnForRevert					= 1

				, dtmNotSoldSince			    = (SELECT TOP 1 dtmNotSoldSince FROM #tmpUpdateItemForCStore_Items WHERE intItemId = I.intItemId) -- Added 
				, dtmNotPurchased			    = (SELECT TOP 1 dtmNotPurchased FROM #tmpUpdateItemForCStore_Items WHERE intItemId = I.intItemId) -- Added 
				, dtmCreatedOlderThan		    = (SELECT TOP 1 dtmCreatedOlderThan FROM #tmpUpdateItemForCStore_Items WHERE intItemId = I.intItemId) -- Added 
		FROM 
		(
			SELECT DISTINCT intItemId
			FROM 
			(
				SELECT intItemId
				FROM #tmpUpdateItemForCStore_itemAuditLog
			) t
		) [Changes]
		INNER JOIN tblICItem I 
			ON [Changes].intItemId = I.intItemId
		INNER JOIN tblICItemUOM UOM 
			ON I.intItemId = UOM.intItemId AND UOM.ysnStockUnit = 1
		
		--START Remove the Duplicate on the @tblPreview
			;WITH CTE AS(
			   SELECT intItemId,
				   RN = ROW_NUMBER()OVER(PARTITION BY intItemId ORDER BY intItemId)
			   FROM @tblPreview
			)
			DELETE FROM CTE WHERE RN > 1 
		--END Remove the Duplicate on the @tblPreview
	END

	DELETE FROM @tblPreview WHERE ISNULL(strPreviewOldData, '') = ISNULL(strPreviewNewData, '')

	 IF(@ysnRecap = 1)
		BEGIN
				
			IF @@TRANCOUNT > 0
				BEGIN
					ROLLBACK TRANSACTION 
				END


			-- INSERT TO PREVIEW TABLE
			INSERT INTO tblSTUpdateItemDiscontinuedPreview
			(
				strGuid,
				strLocation,
				strUpc,
				strDescription,
				strChangeDescription,
				strOldData,
				strNewData,

				intItemId,
				intItemUOMId,
				intItemLocationId,
				intTableIdentityId,
				strTableName,
				strColumnName,
				strColumnDataType,
				intConcurrencyId,
				dtmNotSoldSince	,		     -- Added 
			    dtmNotPurchased,			 -- Added 
			    dtmCreatedOlderThan         -- Added 
			)
			SELECT DISTINCT 
				@strGuid
				, strLocation
				, strUpc
				, strItemDescription
				, strChangeDescription
				, strPreviewOldData
				, strPreviewNewData

				, intItemId
				, intItemUOMId
				, intItemLocationId
				, intPrimaryKeyId
				, strTableName
				, strTableColumnName
				, strTableColumnDataType
				, 1
				, dtmNotSoldSince			     -- Added 
			    , dtmNotPurchased			     -- Added 
			    , dtmCreatedOlderThan	         -- Added
			FROM @tblPreview
			WHERE ysnPreview = 1
			--ORDER BY strItemDescription, strChangeDescription ASC

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
					IF EXISTS(SELECT TOP 1 1 FROM #tmpUpdateItemForCStore_Location)
							BEGIN
								SET @strFilterCriteria = @strFilterCriteria + '<p id="p2"><b>Location</b></p>'
								
								SELECT @strFilterCriteria = @strFilterCriteria + '<p id="p2">&emsp;' + CompanyLoc.strLocationName + '</p>'
								FROM #tmpUpdateItemForCStore_Location tempLoc
								INNER JOIN tblSMCompanyLocation CompanyLoc
									ON tempLoc.intLocationId = CompanyLoc.intCompanyLocationId

								--SET @strFilterCriteria = @strFilterCriteria + '<br>'
							END
						
						IF EXISTS(SELECT TOP 1 1 FROM #tmpUpdateItemForCStore_Vendor)
							BEGIN
								SET @strFilterCriteria = @strFilterCriteria + '<p id="p2"><b>Vendor</b></p>'
								
								SELECT @strFilterCriteria = @strFilterCriteria + '<p id="p2">&emsp;' + EntityVendor.strName + '</p>'
								FROM #tmpUpdateItemForCStore_Vendor tempVendor
								INNER JOIN tblEMEntity EntityVendor
									ON tempVendor.intVendorId = EntityVendor.intEntityId

								--SET @strFilterCriteria = @strFilterCriteria + '<br>'
							END

						IF EXISTS(SELECT TOP 1 1 FROM #tmpUpdateItemForCStore_Category)
							BEGIN
								SET @strFilterCriteria = @strFilterCriteria + '<p id="p2"><b>Category</b></p>'
								
								SELECT @strFilterCriteria = @strFilterCriteria + '<p id="p2">&emsp;' + Category.strCategoryCode + '</p>'
								FROM #tmpUpdateItemForCStore_Category tempCategory
								INNER JOIN tblICCategory Category
									ON tempCategory.intCategoryId = Category.intCategoryId

								--SET @strFilterCriteria = @strFilterCriteria + '<br>'
							END

						IF EXISTS(SELECT TOP 1 1 FROM #tmpUpdateItemForCStore_Family)
							BEGIN
								SET @strFilterCriteria = @strFilterCriteria + '<p id="p2"><b>Family</b></p>'
								
								SELECT @strFilterCriteria = @strFilterCriteria + '<p id="p2">&emsp;' + SubFamily.strSubcategoryId + '</p>'
								FROM #tmpUpdateItemForCStore_Family tempFamily
								INNER JOIN tblSTSubcategory SubFamily
									ON tempFamily.intFamilyId = SubFamily.intSubcategoryId
								WHERE SubFamily.strSubcategoryType = 'F'

								--SET @strFilterCriteria = @strFilterCriteria + '<br>'
							END

						IF EXISTS(SELECT TOP 1 1 FROM #tmpUpdateItemForCStore_Class)
							BEGIN
								SET @strFilterCriteria = @strFilterCriteria + '<p id="p2"><b>Class</b></p>'
								
								SELECT @strFilterCriteria = @strFilterCriteria + '<p id="p2">&emsp;' + SubClass.strSubcategoryId + '</p>'
								FROM #tmpUpdateItemForCStore_Class tempClass
								INNER JOIN tblSTSubcategory SubClass
									ON tempClass.intClassId = SubClass.intSubcategoryId
								WHERE SubClass.strSubcategoryType = 'C'

								--SET @strFilterCriteria = @strFilterCriteria + '<br>'
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
							[intRevertType]				= 3,						-- *** Note: 1=Update Item Data,	2=Update Item Pricing,		3=Update Item Discontinued
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
							[intPrimaryKeyId]			= intItemId,
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
															ELSE strPreviewNewData
														END,
							[strPreviewOldData]			= strOldDataPreview,
							--[strOldData]				= strPreviewOldData,
							--[strNewData]				= strPreviewNewData,
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
		IF OBJECT_ID('tempdb..#tmpUpdateItemForCStore_Location') IS NOT NULL  
			DROP TABLE #tmpUpdateItemForCStore_Location 

		IF OBJECT_ID('tempdb..#tmpUpdateItemForCStore_Vendor') IS NOT NULL  
			DROP TABLE #tmpUpdateItemForCStore_Vendor 

		IF OBJECT_ID('tempdb..#tmpUpdateItemForCStore_Category') IS NOT NULL   
			DROP TABLE #tmpUpdateItemForCStore_Category 

		IF OBJECT_ID('tempdb..#tmpUpdateItemForCStore_Family') IS NOT NULL  
			DROP TABLE #tmpUpdateItemForCStore_Family 

		IF OBJECT_ID('tempdb..#tmpUpdateItemForCStore_Class') IS NOT NULL  
			DROP TABLE #tmpUpdateItemForCStore_Class 

		IF OBJECT_ID('tempdb..#tmpUpdateItemForCStore_Items') IS NOT NULL   
			DROP TABLE #tmpUpdateItemForCStore_Items 

		IF OBJECT_ID('tempdb..#tmpUpdateItemForCStore_itemAuditLog') IS NOT NULL   
			DROP TABLE #tmpUpdateItemForCStore_itemAuditLog 
	END




	---------------------------------------------------------------------------------------
	----------------------------- START Query Preview -------------------------------------
	---------------------------------------------------------------------------------------
	-- Query Preview display
	SELECT  pr.intItemId
			  , ci.strItemNo
			  , strItemDescription
			  , strChangeDescription
			  , strPreviewOldData AS strOldData
			  , strPreviewNewData AS strNewData
	FROM @tblPreview pr
		JOIN tblICItem ci
			ON pr.intItemId = ci.intItemId
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