CREATE PROCEDURE [dbo].[uspSTUpdatePricebookItem]
	@intItemId							INT				
	, @strDescription					NVARCHAR(250)		= NULL
	, @intCategoryId					INT					= NULL		
	, @strItemNo						NVARCHAR(100)		= NULL
	, @strShortName						NVARCHAR(100)		= NULL
	, @strUpcCode						NVARCHAR(100)		= NULL
	, @strLongUpcCode					NVARCHAR(100)		= NULL

	, @intFamilyId						INT					= NULL		
	, @intClassId						INT					= NULL		
	, @intVendorId						INT					= NULL
	--, @strPOSDescription				NVARCHAR(250)	

	, @strVendorProduct					NVARCHAR(100)		= NULL

	, @UDTItemPricing StoreItemPricing	READONLY

	, @intEntityId						INT
	, @strGuid							UNIQUEIDENTIFIER	= NULL
	, @ysnDebug							BIT					
	, @ysnPreview						BIT
	, @ysnResultSuccess					BIT				OUTPUT
	, @strResultMessage					NVARCHAR(1000)	OUTPUT
AS
BEGIN


	SET ANSI_WARNINGS ON -- Since uspICUpdateItemForCStore is using 'ANSI_WARNINGS' set to 'ON'
	SET NOCOUNT ON;
    declare @InitTranCount INT;
    SET @InitTranCount = @@TRANCOUNT
	DECLARE @Savepoint NVARCHAR(32) = SUBSTRING(('uspSTUpdatePricebookItem' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)
	
	BEGIN TRY
		
			IF @InitTranCount = 0
				BEGIN
					BEGIN TRANSACTION
					PRINT 'BEGIN TRANSACTION'

					----TEST
					--INSERT INTO CopierDB.dbo.tblTestSP(strValueOne, strValueTwo)
					--VALUES('TRAN', 'BEGIN TRANSACTION')
				END
				
			ELSE
				BEGIN
					SAVE TRANSACTION @Savepoint
					PRINT 'SAVE TRANSACTION'

					----TEST
					--INSERT INTO CopierDB.dbo.tblTestSP(strValueOne, strValueTwo)
					--VALUES('TRAN', 'SAVE TRANSACTION')
				END
				
			----TEST
			--DECLARE @strParameters AS NVARCHAR(500) = ''
			--DECLARE @intUDTCount AS INT = (SELECT COUNT(*) FROM @UDTItemPricing)
			--DECLARE @strUDTCount AS NVARCHAR(10) = CAST(@intUDTCount AS NVARCHAR(50))
			--SET @strParameters = '@intItemId: ' + CAST(@intItemId AS NVARCHAR(50))
			--				+ ' - @strDescription: ' + ISNULL(@strDescription, 'NULL')
			--				+ ' - @intCategoryId: ' + ISNULL(CAST(@intCategoryId AS NVARCHAR(50)), 'NULL')
			--				+ ' - @intFamilyId: ' + ISNULL(CAST(@intFamilyId AS NVARCHAR(50)), 'NULL')
			--				+ ' - @intClassId: ' + ISNULL(CAST(@intClassId AS NVARCHAR(50)), 'NULL')
			--				+ ' - @intVendorId: ' + ISNULL(CAST(@intVendorId AS NVARCHAR(50)), 'NULL')
			--				+ ' - @strItemNo: ' + ISNULL(@strItemNo, 'NULL')
			--				+ ' - @intVendorId: ' + ISNULL(CAST(@intVendorId AS NVARCHAR(50)), 'NULL')
			--				+ ' - @strVendorProduct: ' + ISNULL(@strVendorProduct, 'NULL')
			--				+ ' - @strGuid: ' + ISNULL(CAST(@strGuid AS NVARCHAR(100)), 'NULL')
			--				+ ' - @strShortName: ' + ISNULL(CAST(@strShortName AS NVARCHAR(100)), 'NULL')
			--				+ ' - @strUpcCode: ' + ISNULL(CAST(@strUpcCode AS NVARCHAR(100)), 'NULL')
			--				+ ' - @strLongUpcCode: ' + ISNULL(CAST(@strLongUpcCode AS NVARCHAR(100)), 'NULL')
			--				+ ' - @strUDTCount: ' + ISNULL(CAST(@strUDTCount AS NVARCHAR(100)), 'NULL')


			DECLARE @intRecordsCount AS INT = 0
			DECLARE @strRecordsCount AS NVARCHAR(50) = ''
			DECLARE @intItemUOMId AS INT = (SELECT TOP 1 intItemUOMId FROM tblICItemUOM WHERE intItemId = @intItemId AND ysnStockUnit = 1)

			SET @ysnResultSuccess = CAST(1 AS BIT)
			SET @strResultMessage = ''

		

			--PRINT 'Commented'

			---- Create the filter tables (ITEM, ITEM LOCATION, VendorXref)
			--BEGIN
			--		-- Create the temp table used for filtering. 
			--		IF OBJECT_ID('tempdb..#tmpUpdateItemForCStore_Location') IS NULL  
			--			CREATE TABLE #tmpUpdateItemForCStore_Location (
			--				intLocationId INT 
			--			)

			--		IF OBJECT_ID('tempdb..#tmpUpdateItemForCStore_Vendor') IS NULL  
			--			CREATE TABLE #tmpUpdateItemForCStore_Vendor (
			--				intVendorId INT 
			--			)

			--		IF OBJECT_ID('tempdb..#tmpUpdateItemForCStore_Category') IS NULL  
			--			CREATE TABLE #tmpUpdateItemForCStore_Category (
			--				intCategoryId INT 
			--			)

			--		IF OBJECT_ID('tempdb..#tmpUpdateItemForCStore_Family') IS NULL  
			--			CREATE TABLE #tmpUpdateItemForCStore_Family (
			--				intFamilyId INT 
			--			)

			--		IF OBJECT_ID('tempdb..#tmpUpdateItemForCStore_Class') IS NULL  
			--			CREATE TABLE #tmpUpdateItemForCStore_Class (
			--				intClassId INT 
			--			)
			--END 


			-- ITEM AuditLog temp table
			BEGIN
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
						-- Modified Fields
						,intCategoryId_New INT NULL
						,strCountCode_New NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
						,strDescription_New NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL
						,strItemNo_New NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL
						,strShortName_New NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL
					)
				;
			END

			-- Create the temp table for the audit log. 
			IF OBJECT_ID('tempdb..#tmpUpdateItemUOMForCStore_itemAuditLog') IS NULL  
				CREATE TABLE #tmpUpdateItemUOMForCStore_itemAuditLog (
					intItemUOMId INT 
					,intItemId INT 
					-- Original Fields
					,strUPCCode_Original NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
					,strLongUPCCode_Original NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
					-- Modified Fields
					,strUPCCode_New NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
					,strLongUPCCode_New NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
				)
			;

			-- ITEM PRICING AuditLog temp table
			BEGIN
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
			END 


			-- ITEM VendorXref AuditLog temp table
			BEGIN
				IF OBJECT_ID('tempdb..#tmpUpdateItemVendorXrefForCStore_itemAuditLog') IS NULL  
					CREATE TABLE #tmpUpdateItemVendorXrefForCStore_itemAuditLog (
					intItemId INT
					, intItemLocationId INT		
					, intItemVendorXrefId INT		
					, strAction NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
					-- Original Fields		
					, strVendorProduct_Original NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
					, strVendorProductDescription_Original NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
					-- Modified Fields
					, strVendorProduct_New NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
					, strVendorProductDescription_New NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
				)
			END


			-- ITEM LOCATION AuditLog temp table
			BEGIN
				IF OBJECT_ID('tempdb..#tmpUpdateItemLocationForCStore_itemLocationAuditLog') IS NULL  
					CREATE TABLE #tmpUpdateItemLocationForCStore_itemLocationAuditLog (
						intItemId INT
						,intItemLocationId INT 
						-- Original Fields
						,ysnTaxFlag1_Original BIT NULL
						,ysnTaxFlag2_Original BIT NULL
						,ysnTaxFlag3_Original BIT NULL
						,ysnTaxFlag4_Original BIT NULL
						,ysnDepositRequired_Original BIT NULL
						,intDepositPLUId_Original INT NULL 
						,ysnQuantityRequired_Original BIT NULL 
						,ysnScaleItem_Original BIT NULL 
						,ysnFoodStampable_Original BIT NULL 
						,ysnReturnable_Original BIT NULL 
						,ysnSaleable_Original BIT NULL 
						,ysnIdRequiredLiquor_Original BIT NULL 
						,ysnIdRequiredCigarette_Original BIT NULL 
						,ysnPromotionalItem_Original BIT NULL 
						,ysnPrePriced_Original BIT NULL 
						,ysnApplyBlueLaw1_Original BIT NULL 
						,ysnApplyBlueLaw2_Original BIT NULL 
						,ysnCountedDaily_Original BIT NULL 
						,strCounted_Original NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
						,ysnCountBySINo_Original BIT NULL 
						,intFamilyId_Original INT NULL 
						,intClassId_Original INT NULL 
						,intProductCodeId_Original INT NULL 
						,intVendorId_Original INT NULL 
						,intMinimumAge_Original INT NULL 
						,dblMinOrder_Original NUMERIC(18, 6) NULL 
						,dblSuggestedQty_Original NUMERIC(18, 6) NULL
						,intCountGroupId_Original INT NULL 
						,intStorageLocationId_Original INT NULL 
						,dblReorderPoint_Original NUMERIC(18, 6) NULL
						,strDescription_Original NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
						-- Modified Fields
						,ysnTaxFlag1_New BIT NULL
						,ysnTaxFlag2_New BIT NULL
						,ysnTaxFlag3_New BIT NULL
						,ysnTaxFlag4_New BIT NULL
						,ysnDepositRequired_New BIT NULL
						,intDepositPLUId_New INT NULL 
						,ysnQuantityRequired_New BIT NULL 
						,ysnScaleItem_New BIT NULL 
						,ysnFoodStampable_New BIT NULL 
						,ysnReturnable_New BIT NULL 
						,ysnSaleable_New BIT NULL 
						,ysnIdRequiredLiquor_New BIT NULL 
						,ysnIdRequiredCigarette_New BIT NULL 
						,ysnPromotionalItem_New BIT NULL 
						,ysnPrePriced_New BIT NULL 
						,ysnApplyBlueLaw1_New BIT NULL 
						,ysnApplyBlueLaw2_New BIT NULL 
						,ysnCountedDaily_New BIT NULL 
						,strCounted_New NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
						,ysnCountBySINo_New BIT NULL 
						,intFamilyId_New INT NULL 
						,intClassId_New INT NULL 
						,intProductCodeId_New INT NULL 
						,intVendorId_New INT NULL 
						,intMinimumAge_New INT NULL 
						,dblMinOrder_New NUMERIC(18, 6) NULL 
						,dblSuggestedQty_New NUMERIC(18, 6) NULL
						,intCountGroupId_New INT NULL 
						,intStorageLocationId_New INT NULL 
						,dblReorderPoint_New NUMERIC(18, 6) NULL
						,strDescription_New NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
					)
			END


			-- Handle preview using Table variable
			BEGIN
				DECLARE @tblPreview TABLE (
					intCompanyLocationId INT
					, strLocation NVARCHAR(250)
					, strUpc NVARCHAR(50)
					, strItemDescription NVARCHAR(250)
					, strChangeDescription NVARCHAR(250)
					, strOldData NVARCHAR(MAX)
					, strNewData NVARCHAR(MAX)
					, intParentId INT
					, intChildId INT
				)
			END


			-- temp table for ItemPricing
			BEGIN
				DECLARE @tblItemPricing TABLE (
					intItemPricingId		INT
					, intItemId				INT
					, dblStandardCost		NUMERIC(38,20)
					, dblLastCost			NUMERIC(38,20)
					, dblSalePrice			NUMERIC(38,20)
					, intCompanyLocationId	INT
				)
			END


			-- ============================================================================================================================
			-- [START] - ITEM UPDATE
			-- ============================================================================================================================
			BEGIN
					-- ITEM
					BEGIN TRY
						-- ===============================================
						-- [START] - PREVIEW IF DEBUG (ITEM)
						-- ===============================================
						BEGIN
							IF(@ysnDebug = 1)
								BEGIN
									SELECT 'tblICItem - Before Update'
										, item.intItemId
										, item.strItemNo
										, item.strDescription
										, category.strCategoryCode
									FROM tblICItem item
									INNER JOIN tblICCategory category
										ON item.intCategoryId = category.intCategoryId
									WHERE item.intItemId = @intItemId
								END
						END
						-- ===============================================
						-- [END] - PREVIEW IF DEBUG (ITEM)
						-- ===============================================


						EXEC [dbo].[uspICUpdateItemForCStore]
							-- filter params	
							@strDescription				= NULL 
							,@dblRetailPriceFrom		= NULL  
							,@dblRetailPriceTo			= NULL 
							,@intItemId					= @intItemId 
							,@intItemUOMId				= @intItemUOMId 
							-- update params
							,@intCategoryId				= @intCategoryId
							,@strCountCode				= NULL
							,@strItemDescription		= @strDescription 	
							,@strItemNo					= @strItemNo 
							,@strShortName				= @strShortName 
							,@strUpcCode				= @strUpcCode 
							,@strLongUpcCode			= @strLongUpcCode 
							,@intEntityUserSecurityId	= @intEntityId

						--OLD
						-- EXEC [dbo].[uspICUpdateItemForCStore]
							--@strUpcCode = NULL  
							--,@strDescription = NULL  
							--,@dblRetailPriceFrom = NULL  
							--,@dblRetailPriceTo = NULL 
							--,@intItemId = @intItemId

							--,@intCategoryId = @intCategoryId
							--,@strCountCode = NULL
							--,@strItemDescription = @strDescription 

							--,@intEntityUserSecurityId = @intEntityId
						
						-- ===============================================
						-- [START] - PREVIEW IF DEBUG (ITEM)
						-- ===============================================
						BEGIN
							IF(@ysnDebug = 1)
								BEGIN
									SELECT 'tblICItem - After Update'
										, item.intItemId
										, item.strItemNo
										, item.strDescription
										, category.strCategoryCode
									FROM tblICItem item
									INNER JOIN tblICCategory category
										ON item.intCategoryId = category.intCategoryId
									WHERE item.intItemId = @intItemId
								END
						END
						-- ===============================================
						-- [END] - PREVIEW IF DEBUG (ITEM)
						-- ===============================================


						-- Get updated records in table
						BEGIN
							-- ITEM
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
							SELECT	  NULL  -- CL.intCompanyLocationId
									, ''  -- CL.strLocationName
									, CASE
										WHEN Uom.strLongUPCCode != '' AND Uom.strLongUPCCode IS NOT NULL 
											THEN Uom.strLongUPCCode 
										ELSE 
											Uom.strUpcCode
									END
									, I.strDescription
									, CASE
										WHEN [Changes].oldColumnName = 'strCategoryId_Original' THEN 'Category'
										WHEN [Changes].oldColumnName = 'strDescription_Original' THEN 'Item Description'
									END
									, [Changes].strOldData
									, [Changes].strNewData
									, [Changes].intItemId 
									, [Changes].intItemId
							FROM 
							(
								SELECT DISTINCT intItemId, oldColumnName, strOldData, strNewData
								FROM 
								(
									SELECT intItemId
										-- Original Fields
										,CAST((SELECT strCategoryCode FROM tblICCategory WHERE intCategoryId = intCategoryId_Original) AS NVARCHAR(100)) AS strCategoryId_Original
										,CAST(strDescription_Original AS NVARCHAR(100)) AS strDescription_Original
										-- Modified Fields
										,CAST((SELECT strCategoryCode FROM tblICCategory WHERE intCategoryId = intCategoryId_New) AS NVARCHAR(100)) AS strCategoryId_New
										,CAST(strDescription_New AS NVARCHAR(100)) AS strDescription_New
									FROM #tmpUpdateItemForCStore_itemAuditLog
								) t
								unpivot
								(
									strOldData for oldColumnName in (strCategoryId_Original, strDescription_Original)--, strCountCode_Original, strDescription_Original)
								) o
								unpivot
								(
									strNewData for newColumnName in (strCategoryId_New, strDescription_New)--, strCountCode_New, strDescription_New)
								) n
								WHERE  REPLACE(oldColumnName, '_Original', '') = REPLACE(newColumnName, '_New', '')		
							) [Changes]
							JOIN tblICItem I 
								ON [Changes].intItemId = I.intItemId
							LEFT JOIN tblICItemUOM Uom
								ON I.intItemId = Uom.intItemId
							WHERE Uom.ysnStockUnit	= 1

							-- ===============================================
							-- [START] - IF DEBUG (ITEM)
							-- ===============================================
							BEGIN
								IF(@ysnDebug = 1)
									BEGIN
										SELECT '#tmpUpdateItemForCStore_itemAuditLog', * FROM #tmpUpdateItemForCStore_itemAuditLog
									END
							END
							-- ===============================================
							-- [END] - IF DEBUG (ITEM)
							-- ===============================================
						END


					END TRY
					BEGIN CATCH
						SET @ysnResultSuccess = 0
						SET @strResultMessage = 'Error updating Item: ' + ERROR_MESSAGE()  

						GOTO ExitWithRollback
					END CATCH

			END
			-- ============================================================================================================================
			-- [END] - ITEM UPDATE
			-- ============================================================================================================================
		



			-- ============================================================================================================================
			-- [START] - ITEM LOCATION UPDATE(All Locations based on intItemId)
			-- ============================================================================================================================
			BEGIN
					DECLARE @strNewItemDescription AS NVARCHAR(150)
							, @strUpcCodeFilter AS NVARCHAR(20)
				
					-- Get Item filter to update only based on intItemId
					SELECT TOP 1
						@strNewItemDescription	= Item.strDescription
						, @strUpcCodeFilter		= ISNULL(Uom.strLongUPCCode, Uom.strUpcCode)
					FROM tblICItem Item
					LEFT JOIN tblICItemUOM Uom
						ON Item.intItemId = Uom.intItemId
					WHERE Item.intItemId = @intItemId
						AND Uom.ysnStockUnit = 1


					-- ITEM LOCATION
					BEGIN TRY
						-- ===============================================
						-- [START] - PREVIEW IF DEBUG (ITEM LOCATION)
						-- ===============================================
						BEGIN
							IF(@ysnDebug = 1)
								BEGIN
									SELECT 'tblICItemLocation - Before Update'
									    , itemLoc.intItemLocationId
										, item.intItemId
										, item.strItemNo
										, item.strDescription
										, itemLoc.strDescription AS strPOSDescription
										, family.strSubcategoryId
										, class.intSubcategoryId
										, entity.strName AS strVendorName
									FROM tblICItemLocation itemLoc
									INNER JOIN tblICItem item
										ON itemLoc.intItemId = item.intItemId
									LEFT JOIN tblSTSubcategory family
										ON itemLoc.intFamilyId = family.intSubcategoryId
									LEFT JOIN tblSTSubcategory class
										ON itemLoc.intClassId = class.intSubcategoryId
									LEFT JOIN tblEMEntity entity
										ON itemLoc.intVendorId = entity.intEntityId
									WHERE itemLoc.intItemId = @intItemId
								END
						END
						-- ===============================================
						-- [END] - PREVIEW IF DEBUG (ITEM LOCATION)
						-- ===============================================


						EXEC [dbo].[uspICUpdateItemLocationForCStore]
							@strUpcCode					= @strUpcCodeFilter 
							,@strDescription			= @strNewItemDescription 
							,@dblRetailPriceFrom		= NULL  
							,@dblRetailPriceTo			= NULL 
							,@intItemLocationId			= NULL

							,@ysnTaxFlag1				= NULL 
							,@ysnTaxFlag2				= NULL
							,@ysnTaxFlag3				= NULL
							,@ysnTaxFlag4				= NULL
							,@ysnDepositRequired		= NULL
							,@intDepositPLUId			= NULL
							,@ysnQuantityRequired		= NULL
							,@ysnScaleItem				= NULL
							,@ysnFoodStampable			= NULL
							,@ysnReturnable				= NULL
							,@ysnSaleable				= NULL
							,@ysnIdRequiredLiquor		= NULL
							,@ysnIdRequiredCigarette	= NULL
							,@ysnPromotionalItem		= NULL
							,@ysnPrePriced				= NULL
							,@ysnApplyBlueLaw1			= NULL
							,@ysnApplyBlueLaw2			= NULL		
							,@ysnCountedDaily			= NULL
							,@strCounted				= NULL
							,@ysnCountBySINo			= NULL
							,@intFamilyId				= @intFamilyId
							,@intClassId				= @intClassId
							,@intProductCodeId			= NULL
							,@intVendorId				= @intVendorId
							,@intMinimumAge				= NULL
							,@dblMinOrder				= NULL
							,@dblSuggestedQty			= NULL
							,@intCountGroupId			= NULL
							,@intStorageLocationId		= NULL
							,@dblReorderPoint			= NULL 
							,@strItemLocationDescription = NULL --@strPOSDescription 

							,@intEntityUserSecurityId = @intEntityId


						-- ===============================================
						-- [START] - PREVIEW IF DEBUG (ITEM LOCATION)
						-- ===============================================
						BEGIN
							IF(@ysnDebug = 1)
								BEGIN
									SELECT 'tblICItemLocation - After Update'
										, itemLoc.intItemLocationId
										, item.intItemId
										, item.strItemNo
										, item.strDescription
										, itemLoc.strDescription AS strPOSDescription
										, family.strSubcategoryId
										, class.intSubcategoryId
										, entity.strName AS strVendorName
									FROM tblICItemLocation itemLoc
									INNER JOIN tblICItem item
										ON itemLoc.intItemId = item.intItemId
									LEFT JOIN tblSTSubcategory family
										ON itemLoc.intFamilyId = family.intSubcategoryId
									LEFT JOIN tblSTSubcategory class
										ON itemLoc.intClassId = class.intSubcategoryId
									LEFT JOIN tblEMEntity entity
										ON itemLoc.intVendorId = entity.intEntityId
									WHERE itemLoc.intItemId = @intItemId
								END
						END
						-- ===============================================
						-- [END] - PREVIEW IF DEBUG (ITEM LOCATION)
						-- ===============================================


						-- Get Updated Records in table
						BEGIN
							-- ITEM LOCATION
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
									, CASE
										WHEN UOM.strLongUPCCode != '' AND UOM.strLongUPCCode IS NOT NULL THEN UOM.strLongUPCCode ELSE UOM.strUpcCode
									END
									,I.strDescription
									,CASE
										WHEN [Changes].oldColumnName = 'strFamilyId_Original' THEN 'Family'
										WHEN [Changes].oldColumnName = 'strClassId_Original' THEN 'Class'
										WHEN [Changes].oldColumnName = 'strDescription_Original' THEN 'Description'
										WHEN [Changes].oldColumnName = 'strVendor_Original' THEN 'Vendor'
									END
									,[Changes].strOldData
									,[Changes].strNewData
									,[Changes].intItemId 
									,[Changes].intItemId
							FROM 
							(
								SELECT DISTINCT intItemId, intItemLocationId, oldColumnName, strOldData, strNewData
								FROM 
								(
									SELECT intItemId
											,intItemLocationId
											-- Original Fields 
											,CAST((SELECT strSubcategoryId FROM tblSTSubcategory WHERE intSubcategoryId = intFamilyId_Original) AS NVARCHAR(1000)) AS strFamilyId_Original
											,CAST((SELECT strSubcategoryId FROM tblSTSubcategory WHERE intSubcategoryId = intClassId_Original) AS NVARCHAR(1000)) AS strClassId_Original
											,CAST(ISNULL(strDescription_Original, '') AS NVARCHAR(1000)) AS strDescription_Original --CAST(ISNULL(REPLACE(strDescription_Original, NULL, ''), '') AS NVARCHAR(1000)) AS strDescription_Original
											,CAST((SELECT strName FROM tblEMEntity WHERE intEntityId = intVendorId_Original) AS NVARCHAR(1000)) AS strVendor_Original
											-- Modified Fields
											,CAST((SELECT strSubcategoryId FROM tblSTSubcategory WHERE intSubcategoryId = intFamilyId_New) AS NVARCHAR(1000)) AS strFamilyId_New
											,CAST((SELECT strSubcategoryId FROM tblSTSubcategory WHERE intSubcategoryId = intClassId_New) AS NVARCHAR(1000)) AS strClassId_New
											,CAST(ISNULL(strDescription_New, '') AS NVARCHAR(1000)) AS strDescription_New  --CAST(ISNULL(REPLACE(strDescription_New, NULL, ''), '') AS NVARCHAR(1000)) AS strDescription_New
											,CAST((SELECT strName FROM tblEMEntity WHERE intEntityId = intVendorId_New) AS NVARCHAR(1000)) AS strVendor_New
									FROM #tmpUpdateItemLocationForCStore_itemLocationAuditLog
								) t
								unpivot
								(
									strOldData for oldColumnName in (strFamilyId_Original, strClassId_Original, strDescription_Original, strVendor_Original)
								) o
								unpivot
								(
									strNewData for newColumnName in (strFamilyId_New, strClassId_New, strDescription_New, strVendor_New)
								) n
								WHERE  REPLACE(oldColumnName, '_Original', '') = REPLACE(newColumnName, '_New', '')	
		
							) [Changes]
							JOIN tblICItem I 
								ON [Changes].intItemId			= I.intItemId
							JOIN tblICItemPricing IP 
								ON I.intItemId					= IP.intItemId
							JOIN tblICItemUOM UOM 
								ON IP.intItemId					= UOM.intItemId
							JOIN tblICItemLocation IL 
								ON IP.intItemLocationId			= IL.intItemLocationId 
								AND IP.intItemLocationId		= IL.intItemLocationId
								AND [Changes].intItemLocationId = IL.intItemLocationId
							JOIN tblSMCompanyLocation CL 
								ON IL.intLocationId				= CL.intCompanyLocationId
						


							-- ===============================================
							-- [START] - IF DEBUG (ITEM)
							-- ===============================================
							BEGIN
								IF(@ysnDebug = 1)
									BEGIN
										SELECT '#tmpUpdateItemLocationForCStore_itemLocationAuditLog', * FROM #tmpUpdateItemLocationForCStore_itemLocationAuditLog
									END
							END
							-- ===============================================
							-- [END] - IF DEBUG (ITEM)
							-- ===============================================
						
						END

					END TRY
					BEGIN CATCH
						SET @ysnResultSuccess = 0
						SET @strResultMessage = 'Error updating Item Location: ' + ERROR_MESSAGE()  

						GOTO ExitWithRollback
					END CATCH
			END
			-- ============================================================================================================================
			-- [END] - ITEM LOCATION UPDATE(All Locations based on intItemId)
			-- ============================================================================================================================



		
			-- ============================================================================================================================
			-- [START] - ITEM VENDOR XREF UPDATE(All Locations based on intItemId)
			-- ============================================================================================================================
			BEGIN
					-- ITEM VendorXref
					BEGIN TRY
						-- ===============================================
						-- [START] - PREVIEW IF DEBUG (ITEM VENDOR XREF)
						-- ===============================================
						BEGIN
							IF(@ysnDebug = 1)
								BEGIN
									SELECT 'tblICItemVendorXref - Before Update'
										, xref.intItemVendorXrefId
										, item.intItemId
										, item.strItemNo
										, item.strDescription
										, xref.strVendorProduct
									FROM tblICItemVendorXref xref
									INNER JOIN tblICItem item
										ON xref.intItemId = item.intItemId
									WHERE xref.intItemId = @intItemId
								END
						END
						-- ===============================================
						-- [END] - PREVIEW IF DEBUG (ITEM VENDOR XREF)
						-- ===============================================


						--Note: if 'tblICItemVendorXref' does not have records 'intItemId' then it will add new records to tblICItemVendorXref
						EXEC uspICUpdateItemVendorXrefForCStore
							-- filter params
							@intItemId = @intItemId
							-- update params
							,@strVendorProduct = @strVendorProduct
							,@strVendorProductDescription = NULL
							,@intEntityUserSecurityId = @intEntityId


						-- ===============================================
						-- [START] - PREVIEW IF DEBUG (ITEM VENDOR XREF)
						-- ===============================================
						BEGIN
							IF(@ysnDebug = 1)
								BEGIN
									SELECT 'tblICItemVendorXref - After Update'
										, xref.intItemVendorXrefId
										, item.intItemId
										, item.strItemNo
										, item.strDescription
										, xref.strVendorProduct
									FROM tblICItemVendorXref xref
									INNER JOIN tblICItem item
										ON xref.intItemId = item.intItemId
									WHERE xref.intItemId = @intItemId
								END
						END
						-- ===============================================
						-- [END] - PREVIEW IF DEBUG (ITEM VENDOR XREF)
						-- ===============================================


						-- Get Updated Records in table
						BEGIN
							-- ITEM VendorXref
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
									, CASE
										WHEN UOM.strLongUPCCode != '' AND UOM.strLongUPCCode IS NOT NULL THEN UOM.strLongUPCCode ELSE UOM.strUpcCode
									END
									,I.strDescription
									,CASE
										WHEN [Changes].oldColumnName = 'strVendorProduct_Original' THEN 'Vendor Product'
									END
									,[Changes].strOldData
									,[Changes].strNewData
									,[Changes].intItemId 
									,[Changes].intItemId
							FROM 
							(
								SELECT DISTINCT intItemId, intItemLocationId, strAction, intItemVendorXrefId, oldColumnName, strOldData, strNewData
								FROM 
								(
									SELECT intItemId
											,intItemLocationId
											,intItemVendorXrefId
											,strAction
											-- Original Fields 
											,strVendorProduct_Original
											--,strVendorProductDescription_Original
											-- Modified Fields
											,strVendorProduct_New
											--,strVendorProductDescription_New
									FROM #tmpUpdateItemVendorXrefForCStore_itemAuditLog
								) t
								unpivot
								(
									strOldData for oldColumnName in (strVendorProduct_Original)--, strVendorProductDescription_Original)
								) o
								unpivot
								(
									strNewData for newColumnName in (strVendorProduct_New)--, strVendorProductDescription_New)
								) n
								WHERE  REPLACE(oldColumnName, '_Original', '') = REPLACE(newColumnName, '_New', '')	
		
							) [Changes]
							JOIN tblICItem I 
								ON [Changes].intItemId = I.intItemId
							JOIN tblICItemPricing IP 
								ON I.intItemId = IP.intItemId
							JOIN tblICItemUOM UOM 
								ON IP.intItemId = UOM.intItemId
							JOIN tblICItemLocation IL 
								ON IP.intItemLocationId = IL.intItemLocationId 
								AND IP.intItemLocationId = IL.intItemLocationId
							JOIN tblSMCompanyLocation CL 
								ON IL.intLocationId = CL.intCompanyLocationId


							-- ===============================================
							-- [START] - IF DEBUG (Vendor Xref)
							-- ===============================================
							BEGIN
								IF(@ysnDebug = 1)
									BEGIN
										SELECT '#tmpUpdateItemVendorXrefForCStore_itemAuditLog', * FROM #tmpUpdateItemVendorXrefForCStore_itemAuditLog
									END
							END
							-- ===============================================
							-- [END] - IF DEBUG (Vendor Xref)
							-- ===============================================
						END

					END TRY
					BEGIN CATCH
						SET @ysnResultSuccess = 0
						SET @strResultMessage = 'Error updating Item VendorXref: ' + ERROR_MESSAGE()  

						GOTO ExitWithRollback
					END CATCH
			END
			-- ============================================================================================================================
			-- [END] - ITEM VENDOR XREF UPDATE(All Locations based on intItemId)
			-- ============================================================================================================================




			-- ============================================================================================================================
			-- [START] - ITEM PRICING UPDATE(Only those in intItemPricingId)
			-- ============================================================================================================================
			BEGIN
					IF EXISTS(SELECT TOP 1 1 FROM @UDTItemPricing)
						BEGIN
							
							--TEST
							--SET @strResultMessage = @strResultMessage + ', Update Pricing: @UDTItemPricing has values'

							INSERT INTO @tblItemPricing
							(
								intItemPricingId
								, intItemId	
								, dblStandardCost	
								, dblLastCost
								, dblSalePrice
								, intCompanyLocationId

							)
							SELECT 
								intItemPricingId	= udt.intItemPricingId
								, intItemId			= udt.intItemId
								, dblStandardCost	= udt.dblStandardCost
								, dblLastCost		= udt.dblLastCost
								, dblSalePrice		= udt.dblSalePrice
								, intCompanyLocationId  = st.intCompanyLocationId
							FROM @UDTItemPricing udt
								INNER JOIN tblSTStore st
									ON udt.intStoreId = st.intStoreId

							--TEST
							--SET @strResultMessage = @strResultMessage + ', Update Pricing: Inserted to @tblItemPricing'

							DECLARE @intLoopItemPricingId	AS INT
							        , @intLoopItemId		AS INT
									, @dblLoopStandardCost	AS NUMERIC(38,20)
									, @dblLoopLastCost		AS NUMERIC(38,20)
									, @dblLoopSalePrice		AS NUMERIC(38,20)
									, @intLoopCompanyLocationId		AS INT




							WHILE EXISTS(SELECT TOP 1 1 FROM @tblItemPricing)
								BEGIN
						
									SELECT TOP 1
										@intLoopItemPricingId	= temp.intItemPricingId
										, @intLoopItemId		= temp.intItemId
										, @dblLoopStandardCost	= CAST(temp.dblStandardCost AS NUMERIC(38, 20))
										, @dblLoopLastCost		= CAST(temp.dblLastCost AS NUMERIC(38, 20))
										, @dblLoopSalePrice		= CAST(temp.dblSalePrice AS NUMERIC(38, 20))
										, @intLoopCompanyLocationId		= temp.intCompanyLocationId
									FROM @tblItemPricing temp


									-- ITEM PRICING
									
										-- ===============================================
										-- [START] - PREVIEW IF DEBUG (ITEM PRICING)
										-- ===============================================
										BEGIN
											IF(@ysnDebug = 1)
												BEGIN
													SELECT 'tblICItemPricing - Before Update'
														, itemPricing.intItemPricingId
														, item.intItemId
														, item.strItemNo
														, item.strDescription
														, itemPricing.dblStandardCost
														, itemPricing.dblLastCost
														, itemPricing.dblSalePrice
													FROM tblICItemPricing itemPricing
													INNER JOIN tblICItem item
														ON itemPricing.intItemId = item.intItemId
													WHERE itemPricing.intItemId = @intItemId
														AND itemPricing.intItemPricingId = @intLoopItemPricingId
												END
										END
										-- ===============================================
										-- [END] - PREVIEW IF DEBUG (ITEM PRICING)
										-- ===============================================

										BEGIN TRY

											----TEST
											--SET @strResultMessage = @strResultMessage + '  @intLoopItemPricingId: ' + CAST(@intLoopItemPricingId AS NVARCHAR(50))
											--SET @strResultMessage = @strResultMessage + '  @intLoopItemId: ' + CAST(@intLoopItemId AS NVARCHAR(50))
											
											--If item pricing is existing
											IF EXISTS(SELECT TOP 1 1 FROM tblICItemPricing WHERE intItemPricingId = @intLoopItemPricingId AND intItemId = @intLoopItemId)
											BEGIN
												EXEC [uspICUpdateItemPricingForCStore]
													-- filter params
													@strUpcCode					= NULL 
													, @strDescription			= NULL 
													, @intItemId				= @intItemId 
													, @intItemPricingId			= @intLoopItemPricingId 

													-- update params
													, @dblStandardCost			= @dblLoopStandardCost 
													, @dblRetailPrice			= @dblLoopSalePrice 
													, @dblLastCost				= @dblLoopLastCost
													, @intEntityUserSecurityId	= @intEntityId
											END
												
											IF NOT EXISTS(SELECT TOP 1 1 FROM tblICItemPricing WHERE intItemPricingId = @intLoopItemPricingId AND intItemId = @intLoopItemId)
											BEGIN
											
												DECLARE @intNewItemLocationId	AS INT
												DECLARE @intNewItemPricingId	AS INT
											
												-- temp table for ItemPricing
												BEGIN
													DECLARE @tblCStoreItemPricing TABLE (
														intItemPricingId			INT
														, intItemId					INT
														, dblStandardCost			NUMERIC(38,20)
														, dblLastCost				NUMERIC(38,20)
														, dblSalePrice				NUMERIC(38,20)
														, intCompanyLocationId		INT
													)
												END


												-- temp table for ItemLocations
												BEGIN
													DECLARE @tempCStoreLocation TABLE
													(
														intStoreId				INT,
														intCompanyLocationId	INT,

														-- Item Location
														ysnUseTaxFlag1			BIT,
														ysnUseTaxFlag2			BIT,
														ysnUseTaxFlag3			BIT,
														ysnUseTaxFlag4			BIT,
														ysnBlueLaw1				BIT,
														ysnBlueLaw2				BIT,
														ysnFoodStampable		BIT,
														ysnReturnable			BIT,
														ysnSaleable				BIT,
														ysnPrePriced			BIT,
														ysnIdRequiredLiquor		BIT,
														ysnIdRequiredCigarette	BIT,
														intProductCodeId		INT,
														intFamilyId				INT,
														intClassId				INT,
														intMinimumAge			INT
													)
												END

												-- ============================================================================================================================
												-- [START] - ADD ITEM LOCATION
												-- ============================================================================================================================
												BEGIN
	
														BEGIN TRY
															INSERT INTO @tempCStoreLocation
															(
																intStoreId,
																intCompanyLocationId,

																-- Item Location
																ysnUseTaxFlag1,
																ysnUseTaxFlag2,
																ysnUseTaxFlag3,
																ysnUseTaxFlag4,
																ysnBlueLaw1,
																ysnBlueLaw2,
																ysnFoodStampable,
																ysnReturnable,
																ysnSaleable,
																ysnPrePriced,
																ysnIdRequiredLiquor,
																ysnIdRequiredCigarette,
																intProductCodeId,
																intFamilyId,
																intClassId,
																intMinimumAge
															)
															SELECT 
																intStoreId					= st.intStoreId,
																intCompanyLocationId		= st.intCompanyLocationId,

																-- Item Location
																ysnUseTaxFlag1				= ISNULL(catLoc.ysnUseTaxFlag1, CAST(0 AS BIT)),
																ysnUseTaxFlag2				= ISNULL(catLoc.ysnUseTaxFlag2, CAST(0 AS BIT)),
																ysnUseTaxFlag3				= ISNULL(catLoc.ysnUseTaxFlag3, CAST(0 AS BIT)),
																ysnUseTaxFlag4				= ISNULL(catLoc.ysnUseTaxFlag4, CAST(0 AS BIT)),
																ysnBlueLaw1					= ISNULL(catLoc.ysnBlueLaw1, CAST(0 AS BIT)),
																ysnBlueLaw2					= ISNULL(catLoc.ysnBlueLaw2, CAST(0 AS BIT)),
																ysnFoodStampable			= ISNULL(catLoc.ysnFoodStampable, CAST(0 AS BIT)),
																ysnReturnable				= ISNULL(catLoc.ysnReturnable, CAST(0 AS BIT)),
																ysnSaleable					= ISNULL(catLoc.ysnSaleable, CAST(0 AS BIT)),
																ysnPrePriced				= ISNULL(catLoc.ysnPrePriced, CAST(0 AS BIT)),
																ysnIdRequiredLiquor			= ISNULL(catLoc.ysnIdRequiredLiquor, CAST(0 AS BIT)),
																ysnIdRequiredCigarette		= ISNULL(catLoc.ysnIdRequiredCigarette, CAST(0 AS BIT)),
																intProductCodeId			= catLoc.intProductCodeId,
																intFamilyId					= ISNULL(@intFamilyId, catLoc.intFamilyId),
																intClassId					= ISNULL(@intClassId, catLoc.intClassId),
																intMinimumAge				= catLoc.intMinimumAge
															FROM tblSTStore st
															LEFT JOIN tblICCategoryLocation catLoc
																ON st.intCompanyLocationId = catLoc.intLocationId
															WHERE st.intCompanyLocationId IS NOT NULL
																--AND catLoc.intCategoryId = @intCategoryId
														END TRY
														BEGIN CATCH
															SET @strResultMessage = 'Error creating location table: ' + ERROR_MESSAGE() 

															GOTO ExitWithRollback
														END CATCH




														INSERT INTO @tblCStoreItemPricing 
														(
															intItemPricingId
															, intItemId
															, dblStandardCost
															, dblLastCost
															, dblSalePrice
															, intCompanyLocationId
														)
														SELECT 
															intItemPricingId		= NULL
															, intItemId				= udt.intItemId
															, dblStandardCost		= udt.dblStandardCost
															, dblLastCost			= udt.dblLastCost
															, dblSalePrice			= udt.dblSalePrice
															, intCompanyLocationId  = st.intCompanyLocationId
														FROM @UDTItemPricing udt
														INNER JOIN tblSTStore st
															ON udt.intStoreId = st.intStoreId



														-- =================================================================================
														-- [START] - ADD ITEM LOCATION DEBUG
														-- =================================================================================
														IF(@ysnDebug = 1)
															BEGIN
																	SELECT '@tempCStoreLocation', * FROM @tempCStoreLocation
																	SELECT '@tblCStoreItemPricing', * FROM @tblCStoreItemPricing
															END
														-- =================================================================================
														-- [END] - ADD ITEM LOCATION DEBUG
														-- =================================================================================


														IF EXISTS(SELECT TOP 1 1 FROM @tempCStoreLocation)
															BEGIN
							
																DECLARE @intStoreId_New					INT,
																		@intCompanyLocationId_New		INT,
																		@ysnUseTaxFlag1_New				BIT,
																		@ysnUseTaxFlag2_New				BIT,
																		@ysnUseTaxFlag3_New				BIT,
																		@ysnUseTaxFlag4_New				BIT,
																		@ysnBlueLaw1_New				BIT,
																		@ysnBlueLaw2_New				BIT,
																		@ysnFoodStampable_New			BIT,
																		@ysnReturnable_New				BIT,
																		@ysnSaleable_New				BIT,
																		@ysnPrePriced_New				BIT,
																		@ysnIdRequiredLiquor_New		BIT,
																		@ysnIdRequiredCigarette_New		BIT,
																		@intProductCodeId_New			INT,
																		@intFamilyId_New				INT,
																		@intClassId_New					INT,
																		@intMinimumAge_New				INT,

																		@dblStandardCost_New			NUMERIC(18, 6),
																		@dblLastCost_New				NUMERIC(18, 6),
																		@dblSalePrice_New				NUMERIC(18, 6)

																		


																WHILE EXISTS(SELECT TOP 1 1 FROM @tempCStoreLocation)
																	BEGIN
									
																		SELECT TOP 1
																				@intStoreId_New				= intStoreId,
																				@intCompanyLocationId_New	= intCompanyLocationId,
																				@ysnUseTaxFlag1_New			= ysnUseTaxFlag1,
																				@ysnUseTaxFlag2_New			= ysnUseTaxFlag2,
																				@ysnUseTaxFlag3_New			= ysnUseTaxFlag3,
																				@ysnUseTaxFlag4_New			= ysnUseTaxFlag4,
																				@ysnBlueLaw1_New			= ysnBlueLaw1,
																				@ysnBlueLaw2_New			= ysnBlueLaw2,
																				@ysnFoodStampable_New		= ysnFoodStampable,
																				@ysnReturnable_New			= ysnReturnable,
																				@ysnSaleable_New			= ysnSaleable,
																				@ysnPrePriced_New			= ysnPrePriced,
																				@ysnIdRequiredLiquor_New	= ysnIdRequiredLiquor,
																				@ysnIdRequiredCigarette_New	= ysnIdRequiredCigarette,
																				@intProductCodeId_New		= intProductCodeId,
																				@intFamilyId_New			= intFamilyId,
																				@intClassId_New				= intClassId,
																				@intMinimumAge_New			= intMinimumAge
																		FROM @tempCStoreLocation

									
																		-- =================================================================================
																		-- [START] - ADD ITEM LOCATION DEBUG
																		-- =================================================================================
																		IF(@ysnDebug = 1)
																			BEGIN
																					SELECT 'LOOP', @intStoreId_New, @intCompanyLocationId_New, @ysnUseTaxFlag1_New, @ysnUseTaxFlag2_New, @ysnUseTaxFlag3_New, @ysnUseTaxFlag4_New, @ysnBlueLaw1_New, @ysnBlueLaw2_New, @ysnFoodStampable_New,
																									@ysnReturnable_New, @ysnSaleable_New, @ysnPrePriced_New, @ysnIdRequiredLiquor_New, @ysnIdRequiredCigarette_New, @intProductCodeId_New, @intFamilyId_New, @intClassId_New, @intMinimumAge_New
																			END
																		-- =================================================================================
																		-- [END] - ADD ITEM LOCATION DEBUG
																		-- =================================================================================

	
																		-- ITEM LOCATION
																		BEGIN TRY
										
																			EXEC [uspICAddItemLocationForCStore]
																				@intLocationId				= @intCompanyLocationId_New 
																				,@intItemId					= @intItemId

																				,@ysnTaxFlag1				= @ysnUseTaxFlag1_New 
																				,@ysnTaxFlag2				= @ysnUseTaxFlag2_New
																				,@ysnTaxFlag3				= @ysnUseTaxFlag3_New
																				,@ysnTaxFlag4				= @ysnUseTaxFlag4_New
																				,@ysnApplyBlueLaw1			= @ysnBlueLaw1_New
																				,@ysnApplyBlueLaw2			= @ysnBlueLaw2_New
																				,@intProductCodeId			= @intProductCodeId_New
																				,@intFamilyId				= @intFamilyId_New
																				,@intClassId				= @intClassId_New
																				,@ysnFoodStampable			= @ysnFoodStampable_New
																				,@ysnReturnable				= @ysnReturnable_New
																				,@ysnSaleable				= @ysnSaleable_New
																				,@ysnPrePriced				= @ysnPrePriced_New
																				,@ysnIdRequiredLiquor		= @ysnIdRequiredLiquor_New
																				,@ysnIdRequiredCigarette	= @ysnIdRequiredCigarette_New
																				,@intMinimumAge				= @intMinimumAge_New
																				,@intVendorId				= @intVendorId
																				,@intEntityUserSecurityId	= @intEntityId
																				,@intItemLocationId			= @intNewItemLocationId OUTPUT 
										
																			-- =================================================================================
																			-- [START] - ADD ITEM UOM DEBUG
																			-- =================================================================================
																			IF(@ysnDebug = 1)
																				BEGIN
																					SELECT 'New Added Item Location', * FROM tblICItemLocation WHERE intItemLocationId = @intNewItemLocationId
																				END
																			-- =================================================================================
																			-- [END] - ADD ITEM UOM DEBUG
																			-- =================================================================================

																			IF NOT EXISTS(SELECT TOP 1 1 FROM tblICItemLocation WHERE intItemLocationId = @intNewItemLocationId)
																				BEGIN
																					SET @strResultMessage = 'Item Location is not created successfully'  

																					GOTO ExitWithRollback
																				END
																				

																			IF EXISTS(SELECT TOP 1 1 FROM @tblCStoreItemPricing WHERE intCompanyLocationId = @intCompanyLocationId_New)
																				BEGIN
																					SELECT TOP 1
																						@dblStandardCost_New	= dblStandardCost,
																						@dblLastCost_New		= dblLastCost,
																						@dblSalePrice_New		= dblSalePrice
																					FROM @tblCStoreItemPricing 
																					WHERE intCompanyLocationId = @intCompanyLocationId_New

																					IF(@intItemId IS NOT NULL AND @intNewItemLocationId IS NOT NULL)
																						BEGIN
																						
																							-- ITEM PRICING
																							EXEC [uspICAddItemPricingForCStore]
																								@intItemId					= @intItemId
																								,@intItemLocationId			= @intNewItemLocationId

																								,@dblStandardCost			= @dblStandardCost_New 
																								,@dblLastCost				= @dblLastCost_New 
																								,@dblSalePrice				= @dblSalePrice_New
																								,@intEntityUserSecurityId	= @intEntityId
																								,@intItemPricingId			= @intNewItemPricingId OUTPUT


																							-- =================================================================================
																							-- [START] - ADD ITEM PRICING DEBUG
																							-- =================================================================================
																							IF(@ysnDebug = 1)
																								BEGIN
																									SELECT 'New Added Item Pricing', * FROM tblICItemPricing WHERE intItemPricingId = @intNewItemPricingId
																								END
																							-- =================================================================================
																							-- [END] - ADD ITEM PRICING DEBUG
																							-- =================================================================================

																							IF NOT EXISTS(SELECT TOP 1 1 FROM tblICItemPricing WHERE intItemPricingId = @intNewItemPricingId AND intItemId = @intItemId)
																								BEGIN
																									SET @strResultMessage = 'Item Pricing is not created successfully'  

																									GOTO ExitWithRollback
																								END
																						END
																				END
																		END TRY
																		BEGIN CATCH
																			SET @strResultMessage = 'Error Adding new Item Location: ' + ERROR_MESSAGE()  

																			GOTO ExitWithRollback
																		END CATCH


																		SET @intNewItemLocationId		= NULL
																		SET @intNewItemPricingId		= NULL


																		DELETE @tempCStoreLocation 
																		WHERE intStoreId = @intStoreId_New
																			AND intCompanyLocationId = @intCompanyLocationId_New
																	END
															END

												END
												-- ============================================================================================================================
												-- [END] - ADD ITEM LOCATION
												-- ============================================================================================================================

											END 

											-- Remove
											DELETE FROM @tblItemPricing WHERE intItemPricingId = @intLoopItemPricingId

										END TRY
										BEGIN CATCH
											SET @ysnResultSuccess = 0
											SET @strResultMessage = 'Error updating Item Pricing: ' + ERROR_MESSAGE()  

											GOTO ExitWithRollback
										END CATCH
										----TEST
										--SET @strResultMessage = @strResultMessage + ', Update Pricing: @intLoopItemPricingId:' + CAST(@intLoopItemPricingId AS NVARCHAR(50)) 
										--                                                                 + '@dblLoopStandardCost: ' + CAST(@dblLoopStandardCost AS NVARCHAR(50)) 
										--																 + '@dblLoopLastCost: ' + CAST(@dblLoopLastCost AS NVARCHAR(50))

										-- ===============================================
										-- [START] - PREVIEW IF DEBUG (ITEM PRICING)
										-- ===============================================
										BEGIN
											IF(@ysnDebug = 1)
												BEGIN
													SELECT 'tblICItemPricing - After Update'
														, itemPricing.intItemPricingId
														, item.intItemId
														, item.strItemNo
														, item.strDescription
														, itemPricing.dblStandardCost
														, itemPricing.dblLastCost
														, itemPricing.dblSalePrice
													FROM tblICItemPricing itemPricing
													INNER JOIN tblICItem item
														ON itemPricing.intItemId = item.intItemId
													WHERE itemPricing.intItemId = @intItemId
														AND itemPricing.intItemPricingId = @intLoopItemPricingId
												END
										END
										-- ===============================================
										-- [END] - PREVIEW IF DEBUG (ITEM PRICING)
										-- ===============================================

										----TEST
										--SET @strResultMessage = @strResultMessage + ', Check #ItemPricingAuditLog'

										----TEST
										--IF EXISTS(SELECT TOP 1 1 FROM #tmpUpdateItemPricingForCStore_ItemPricingAuditLog)
										--	BEGIN
										--		--TEST
										--		SET @strResultMessage = @strResultMessage + ', #ItemPricingAuditLog has record'
										--	END

										-- Get Updated records in table
										BEGIN
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
													, CASE
														WHEN UOM.strLongUPCCode != '' AND UOM.strLongUPCCode IS NOT NULL THEN UOM.strLongUPCCode ELSE UOM.strUpcCode
													END
													,I.strDescription
													,CASE
														WHEN [Changes].oldColumnName = 'strSalePrice_Original' THEN 'Sale Price'
														WHEN [Changes].oldColumnName = 'strLastCost_Original' THEN 'Last Cost'
														WHEN [Changes].oldColumnName = 'strSalePrice_Original' THEN 'Retail Price'
														WHEN [Changes].oldColumnName = 'strStandardCost_Original' THEN 'Standard Cost'
													END
													,[Changes].strOldData
													,[Changes].strNewData
													,[Changes].intItemId 
													,[Changes].intItemId
											FROM 
											(
												SELECT DISTINCT intItemId, intItemPricingId, oldColumnName, strOldData, strNewData
												FROM 
												(
													SELECT intItemId
															,intItemPricingId
															-- Original Fields 
															,CAST(CAST(dblOldStandardCost AS DECIMAL(18,3)) AS NVARCHAR(100)) AS strStandardCost_Original
															,CAST(CAST(dblOldSalePrice AS DECIMAL(18,3)) AS NVARCHAR(100)) AS strSalePrice_Original
															,CAST(CAST(dblOldLastCost AS DECIMAL(18,3)) AS NVARCHAR(100)) AS strLastCost_Original
											
															-- Modified Fields
															,CAST(CAST(dblNewStandardCost AS DECIMAL(18,3)) AS NVARCHAR(100)) AS strStandardCost_New
															,CAST(CAST(dblNewSalePrice AS DECIMAL(18,3)) AS NVARCHAR(100)) AS strSalePrice_New
															,CAST(CAST(dblNewLastCost AS DECIMAL(18,3)) AS NVARCHAR(100)) AS strLastCost_New					
													FROM #tmpUpdateItemPricingForCStore_ItemPricingAuditLog
												) t
												unpivot
												(
													strOldData for oldColumnName in (strSalePrice_Original, strLastCost_Original, strStandardCost_Original)
												) o
												unpivot
												(
													strNewData for newColumnName in (strSalePrice_New, strLastCost_New, strStandardCost_New)
												) n
												WHERE  REPLACE(oldColumnName, '_Original', '') = REPLACE(newColumnName, '_New', '')	
		
											) [Changes]
											INNER JOIN tblICItemPricing IP 
												ON [Changes].intItemPricingId	= IP.intItemPricingId
											LEFT JOIN tblICItem I 
												ON [Changes].intItemId			= I.intItemId
											LEFT JOIN tblICItemUOM UOM 
												ON IP.intItemId					= UOM.intItemId
											LEFT JOIN tblICItemLocation IL 
												ON IP.intItemLocationId			= IL.intItemLocationId 
											LEFT JOIN tblSMCompanyLocation CL 
												ON IL.intLocationId				= CL.intCompanyLocationId
											WHERE UOM.ysnStockUnit = 1
										

											-- ===============================================
											-- [START] - IF DEBUG (ItemPricing)
											-- ===============================================
											BEGIN
												IF(@ysnDebug = 1)
													BEGIN
														SELECT '#tmpUpdateItemPricingForCStore_ItemPricingAuditLog', * FROM #tmpUpdateItemPricingForCStore_ItemPricingAuditLog
													END
											END
											-- ===============================================
											-- [END] - IF DEBUG (ItemPricing)
											-- ===============================================
										END

									

									

								END
						END 
				

				
			END
			-- ============================================================================================================================
			-- [END] - ITEM PRICING UPDATE(Only those in intItemPricingId)
			-- ============================================================================================================================


			SET @intRecordsCount = (SELECT COUNT(intCompanyLocationId) FROM @tblPreview WHERE ISNULL(strOldData, '') != ISNULL(strNewData, ''))
			

			SET @strRecordsCount = CAST(@intRecordsCount AS NVARCHAR(50))

			SET @ysnResultSuccess = CAST(1 AS BIT)

			IF(@intRecordsCount > 0)
				BEGIN
					SET @strResultMessage = 'Successfully updated ' + @strRecordsCount + ' records.'
				END
			ELSE
				BEGIN
					SET @strResultMessage = @strResultMessage + 'There are no record to update.'
				END
			



			-- Clean up (ITEM, ITEM UOM, ITEM LOCATION, VendorXref)
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

					IF OBJECT_ID('tempdb..#tmpUpdateItemForCStore_itemAuditLog') IS NOT NULL  
						DROP TABLE #tmpUpdateItemForCStore_itemAuditLog 

					IF OBJECT_ID('tempdb..#tmpUpdateItemUOMForCStore_itemAuditLog') IS NOT NULL  
						DROP TABLE #tmpUpdateItemUOMForCStore_itemAuditLog 

					IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_ItemPricingAuditLog') IS NOT NULL  
						DROP TABLE #tmpUpdateItemPricingForCStore_ItemPricingAuditLog 

					IF OBJECT_ID('tempdb..#tmpUpdateItemVendorXrefForCStore_itemAuditLog') IS NOT NULL  
						DROP TABLE #tmpUpdateItemVendorXrefForCStore_itemAuditLog 

					IF OBJECT_ID('tempdb..#tmpUpdateItemLocationForCStore_itemLocationAuditLog') IS NOT NULL  
						DROP TABLE #tmpUpdateItemLocationForCStore_itemLocationAuditLog 
			END


		   -- Query Preview display
		   SELECT DISTINCT 
		          ISNULL(strLocation, '') AS strLocation
				  , ISNULL(strUpc, '')	AS strUpc
				  , ISNULL(strItemDescription, '') AS strItemDescription
				  , ISNULL(strChangeDescription, '') AS strChangeDescription
				  , ISNULL(strOldData, '') AS strOldData
				  , ISNULL(strNewData, '') AS strNewData
		   FROM @tblPreview
		   WHERE ISNULL(strNewData, '') != ISNULL(strOldData, '')
		   ORDER BY strItemDescription, strChangeDescription ASC


			
			IF(@ysnDebug = CAST(1 AS BIT) OR @ysnPreview = CAST(1 AS BIT))
				BEGIN
					PRINT @strResultMessage
					PRINT 'Will Rollback and exit'
					--SET @strResultMessage = @strResultMessage + ' @InitTranCount: ' 
					--                                          + CAST(@InitTranCount AS NVARCHAR(50))
					--										  + ' (XACT_STATE()): ' + CAST((XACT_STATE()) AS NVARCHAR(50))

					GOTO ExitWithRollback
				END
			ELSE IF(@ysnDebug = 0)
				BEGIN
					GOTO ExitWithCommit
				END

	END TRY

	BEGIN CATCH
		SET @ysnResultSuccess = CAST(0 AS BIT)
		SET @strResultMessage = ERROR_MESSAGE()  

		GOTO ExitWithRollback
	END CATCH
END







ExitWithCommit:
	--COMMIT TRANSACTION
	
	--IF @InitTranCount = 0
	--	BEGIN
	--		IF ((XACT_STATE()) <> 0)
	--		BEGIN
	--			SET @strResultMessage = @strResultMessage + '. COMMIT TRANSACTION'
	--			COMMIT TRANSACTION
	--		END
	--	END
			
	--ELSE
	--	BEGIN
	--		IF ((XACT_STATE()) <> 0)
	--			BEGIN
	--				SET @strResultMessage = @strResultMessage + '. COMMIT TRANSACTION @Savepoint'
	--				COMMIT TRANSACTION @Savepoint
	--			END
	--	END
	IF @InitTranCount = 0
		BEGIN
			COMMIT TRANSACTION
		END

	GOTO ExitPost
	


ExitWithRollback:
		
		---- TEST
		--INSERT INTO CopierDB.dbo.tblTestSP(strValueOne, strValueTwo)
		--VALUES('@InitTranCount: ' + CAST(@InitTranCount AS NVARCHAR(50)), '(XACT_STATE()): ' + CAST((XACT_STATE()) AS NVARCHAR(50)))

		IF @InitTranCount = 0
			BEGIN
				IF ((XACT_STATE()) <> 0)
				BEGIN
					PRINT 'Will Rollback Transaction.'
					SET @strResultMessage = @strResultMessage + '. Will Rollback Transaction.'

					ROLLBACK TRANSACTION
				END
			END
			
		ELSE
			BEGIN
				IF ((XACT_STATE()) <> 0)
					BEGIN
						PRINT 'Will Rollback to Save point.'
						SET @strResultMessage = @strResultMessage + '. Will Rollback to Save point.'

						ROLLBACK TRANSACTION @Savepoint
					END
			END
			
				
		
		
	

		
ExitPost:
		IF(@ysnPreview = 1)
			BEGIN
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTUpdateItemDataPreview WHERE strGuid = @strGuid)
					BEGIN
						
						-- INSERT TO PREVIEW TABLE
						INSERT INTO tblSTUpdateItemDataPreview
						(
							strGuid,
							strLocation,
							strUpc,
							strDescription,
							strChangeDescription,
							strOldData,
							strNewData,

							--intItemId,
							--intItemUOMId,
							--intItemLocationId,
							--intTableIdentityId,
							--strTableName,
							--strColumnName,
							--strColumnDataType,
							intConcurrencyId
						)
						SELECT DISTINCT 
							strGuid					=	@strGuid
							, strLocation			=	ISNULL(strLocation, '')
							, strUpc				=	ISNULL(strUpc, '')
							, strDescription		=	ISNULL(strItemDescription, '')
							, strChangeDescription	=	ISNULL(strChangeDescription, '')
							, strOldData			=	ISNULL(strOldData, '')
							, strNewData			=	ISNULL(strNewData, '')

							--, intItemId
							--, intItemUOMId
							--, intItemLocationId
							--, intPrimaryKeyId
							--, strTableName
							--, strTableColumnName
							--, strTableColumnDataType
							, intConcurrencyId		=	1
						FROM @tblPreview
						WHERE ISNULL(strNewData, '') != ISNULL(strOldData, '')
						ORDER BY strLocation, strUpc ASC

					END
			END

		---- TEST
		--INSERT INTO CopierDB.dbo.tblTestSP(strValueOne, strValueTwo)
		--VALUES('@strResultMessage', @strResultMessage) 
		--INSERT INTO CopierDB.dbo.tblTestSP(strValueOne, strValueTwo)
		--VALUES('@strParameters', @strParameters)

		--DECLARE @intRow AS INT = (SELECT COUNT(intItemId) FROM @UDTItemPricing)
		--DECLARE @strRow AS NVARCHAR(50) = CAST(@intRow AS NVARCHAR(50))
		--INSERT INTO CopierDB.dbo.tblTestSP(strValueOne, strValueTwo)
		--VALUES('@UDTItemPricing', @strRow)

		--DECLARE @strColumnValues AS NVARCHAR(MAX)
		--SELECT @strColumnValues = CAST(intItemId AS NVARCHAR(50)) + '-'
		--						+ CAST(intItemPricingId AS NVARCHAR(50)) + '-'
		--						+ CAST(dblLastCost AS NVARCHAR(50)) + '-'
		--						+ CAST(dblStandardCost AS NVARCHAR(50)) + '-'
		--FROM @UDTItemPricing
		--INSERT INTO CopierDB.dbo.tblTestSP(strValueOne, strValueTwo)
		--VALUES('@strColumnValues', @strColumnValues)

		--DECLARE @strDebug AS NVARCHAR(50) = CAST(@ysnDebug AS NVARCHAR(50))
		--	  , @strPreview AS NVARCHAR(50) = CAST(@ysnPreview AS NVARCHAR(50))
		--INSERT INTO CopierDB.dbo.tblTestSP(strValueOne, strValueTwo)
		--VALUES('@strDebug', @strDebug)
		--INSERT INTO CopierDB.dbo.tblTestSP(strValueOne, strValueTwo)
		--VALUES('@strPreview', @strPreview)
