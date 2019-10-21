CREATE PROCEDURE [dbo].[uspSTRevertMassPricebookChanges]
		@intRevertHolderId				INT,
		@strRevertHolderDetailIdList	NVARCHAR(MAX),
		@intEntityId					INT,
		@ysnDebug						BIT,
		@ysnSuccess						BIT OUTPUT,
		@strResultMsg					NVARCHAR(1000) OUTPUT
	AS
BEGIN TRY
	    
		



		IF NOT EXISTS(
						SELECT TOP 1 1 FROM vyuSTSearchRevertHolderDetail detail
						WHERE detail.intRevertHolderId = @intRevertHolderId
							AND detail.intRevertHolderDetailId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@strRevertHolderDetailIdList))
							AND detail.strPreviewOldData != detail.strPreviewNewData
					 )
			BEGIN 
				SET @ysnSuccess	= 0
				SET @strResultMsg = 'There are no records to revert.' 

				GOTO ExitPost
			END

		BEGIN TRANSACTION


		SET @strResultMsg = ''    
		SET @ysnSuccess = CAST(1 AS BIT)

		DECLARE @intRevertType AS INT = (SELECT TOP 1 intRevertType FROM tblSTRevertHolder WHERE intRevertHolderId = @intRevertHolderId)

		DECLARE @intRevertItemRecords INT = 0
		DECLARE @intRevertItemLocationRecords INT = 0
		DECLARE @intRevertItemPricingRecords INT = 0
		DECLARE @intRevertItemSpecialPricingRecords INT = 0

		
		

		

		IF(@intRevertType = 1)
			BEGIN
				-- ITEM
				-- ==================================================================================================================================================
				-- [START] - Revert ITEM
				-- ==================================================================================================================================================
				IF EXISTS(
							SELECT TOP 1 1 FROM vyuSTSearchRevertHolderDetail detail
							WHERE detail.strTableName = N'tblICItem' 
								AND detail.intRevertHolderId = @intRevertHolderId
								AND detail.intRevertHolderDetailId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@strRevertHolderDetailIdList))
								AND detail.strPreviewOldData != detail.strPreviewNewData
						 )
					BEGIN

				


						-- Create
						DECLARE @tempITEM TABLE (
								intItemId			INT NULL
								, intCategoryId		INT NULL
								, strCountCode		NVARCHAR(50)  COLLATE Latin1_General_CI_AS NULL
						)



						-- Insert
						INSERT INTO @tempITEM
						(
							intItemId
							, intCategoryId
							, strCountCode
						)
						SELECT DISTINCT
							intItemId			= piv.intItemId
							, intCategoryId		= piv.intCategoryId
							, strCountCode		= piv.strCountCode
						FROM (
							SELECT detail.intItemId
								 , detail.strTableColumnName
								 , detail.strOldData
							FROM vyuSTSearchRevertHolderDetail detail
							WHERE detail.strTableName = N'tblICItem'
								AND detail.intRevertHolderId = @intRevertHolderId
								AND detail.intRevertHolderDetailId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@strRevertHolderDetailIdList))
								AND detail.strPreviewOldData != detail.strPreviewNewData
						) src
						PIVOT (
							MAX(strOldData) FOR strTableColumnName IN (intCategoryId, strCountCode)
						) piv



						-- Record row count
						SET @intRevertItemRecords = (
														SELECT COUNT(detail.intItemId) FROM vyuSTSearchRevertHolderDetail detail
														WHERE detail.strTableName = N'tblICItem' 
															AND detail.intRevertHolderId = @intRevertHolderId
															AND detail.intRevertHolderDetailId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@strRevertHolderDetailIdList))
															AND detail.strPreviewOldData != detail.strPreviewNewData
													 )




						-----------------------------------------------------------------------------
						-- [START] - ITEM DEBUG MODE
						-----------------------------------------------------------------------------
						IF (@ysnDebug = 1)
							BEGIN
								SELECT 'tblICItem temp table', * FROM @tempITEM

								SELECT DISTINCT
									   'tblICItem - Before Update'
										 , Item.intItemId
										 , Item.strItemNo
										 , Item.strDescription
										 , Item.intCategoryId
										 , Item.strCountCode
								FROM tblICItem Item
								INNER JOIN vyuSTSearchRevertHolderDetail detail
									ON Item.intItemId = detail.intItemId	
								WHERE detail.strTableName = N'tblICItem'
									AND detail.intRevertHolderDetailId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@strRevertHolderDetailIdList))
									AND detail.strPreviewOldData != detail.strPreviewNewData
								ORDER BY Item.intItemId ASC
							END
						-----------------------------------------------------------------------------
						-- [END] - ITEM DEBUG MODE
						-----------------------------------------------------------------------------




						-- LOOP ITEM's
						WHILE EXISTS(SELECT TOP 1 1 FROM @tempITEM)
							BEGIN			
	
								DECLARE  @intItemId			INT
										, @intCategoryId	INT
										, @strCountCode		NVARCHAR(50)

				
				

								SELECT TOP 1 
										@intItemId			=  temp.intItemId
										, @intCategoryId	=  CASE 
																	WHEN temp.intCategoryId IS NULL
																		THEN Item.intCategoryId
																	ELSE temp.intCategoryId
															END
										, @strCountCode		=  CASE 
																	WHEN temp.strCountCode IS NULL
																		THEN Item.strCountCode
																	ELSE temp.strCountCode
															END
								FROM @tempITEM temp
								INNER JOIN tblICItem Item
									ON temp.intItemId = Item.intItemId
								ORDER BY temp.intItemId ASC



								-- UPDATE ITEM
								EXEC [dbo].[uspICUpdateItemForCStore]
									-- filter params	
									@strDescription				= NULL 
									,@dblRetailPriceFrom		= NULL  
									,@dblRetailPriceTo			= NULL 
									,@intItemId					= @intItemId 
									,@intItemUOMId				= NULL 
									-- update params
									,@intCategoryId				= @intCategoryId
									,@strCountCode				= NULL
									,@strItemDescription		= @strCountCode 	
									,@strItemNo					= NULL 
									,@strShortName				= NULL 
									,@strUpcCode				= NULL 
									,@strLongUpcCode			= NULL 
									,@intEntityUserSecurityId	=  @intEntityId

								--OLD
								--EXEC [dbo].[uspICUpdateItemForCStore]
								--	 @strUpcCode				= NULL 
								--	 ,@strDescription			= NULL 
								--	 ,@dblRetailPriceFrom		= NULL  
								--	 ,@dblRetailPriceTo			= NULL 
								--	 ,@intItemId				= @intItemId

								--	 ,@intCategoryId			= @intCategoryId
								--	 ,@strCountCode				= @strCountCode
								--	 ,@strItemDescription		= NULL
								--	 ,@intEntityUserSecurityId	= @intEntityId -- *** ADD EntityId of the user who commited the revert ***

								


								--UPDATE tbl
								--SET tbl.strPreviewOldData = CASE
								--								WHEN tbl.strTableColumnName = N'intCategoryId'
								--									THEN Category.strCategoryCode
								--								WHEN tbl.strTableColumnName = N'strCountCode'
								--									THEN tbl.strOldData
								--								ELSE 
								--									tbl.strPreviewOldData
								--							END
								--FROM tblSTRevertHolderDetail tbl
								--INNER JOIN tblICItem Item
								--	ON tbl.intItemId = Item.intItemId
								--INNER JOIN tblICCategory Category
								--	ON Item.intCategoryId = Category.intCategoryId 
								--WHERE tbl.intRevertHolderId = @intRevertHolderId
								--	AND tbl.strTableName = N'tblICItem'
								--	AND tbl.strTableColumnName IN (N'intCategoryId', N'strCountCode')
								--	AND tbl.intItemId = @intItemId


								-- Remove
								DELETE FROM @tempITEM WHERE intItemId = @intItemId
		
							END




						-----------------------------------------------------------------------------
						-- [START] - ITEM DEBUG MODE
						-----------------------------------------------------------------------------
						IF (@ysnDebug = 1)
							BEGIN
								SELECT DISTINCT 
										'tblICItem - After Update'
										, Item.intItemId
										, Item.strItemNo
										, Item.strDescription
										, Item.intCategoryId
										, Item.strCountCode
								FROM tblICItem Item
								INNER JOIN vyuSTSearchRevertHolderDetail detail
									ON Item.intItemId = detail.intItemId	
								WHERE detail.strTableName = N'tblICItem'
									AND detail.intRevertHolderDetailId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@strRevertHolderDetailIdList))
									AND detail.strPreviewOldData != detail.strPreviewNewData
								ORDER BY Item.intItemId ASC
							END
						-----------------------------------------------------------------------------
						-- [END] - ITEM DEBUG MODE
						-----------------------------------------------------------------------------



				

					END
				ELSE
					BEGIN
						PRINT 'No Records found to update - tblICItem'
					END
				-- ==================================================================================================================================================
				-- [END] - Revert ITEM
				-- ==================================================================================================================================================




				-- ITEM LOCATION
				-- ==================================================================================================================================================
				-- [START] - Revert ITEM LOCATION
				-- ==================================================================================================================================================
				IF EXISTS(
							SELECT TOP 1 1 
							FROM vyuSTSearchRevertHolderDetail detail
							WHERE detail.strTableName = N'tblICItemLocation' 
								AND detail.intRevertHolderId = @intRevertHolderId
								AND detail.intRevertHolderDetailId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@strRevertHolderDetailIdList))
								AND detail.strPreviewOldData != detail.strPreviewNewData
						 )
					BEGIN
				
				
	
						-- Create
						DECLARE @tempITEMLOCATION TABLE (
								intItemLocationId			INT		NOT NULL,
								ysnTaxFlag1					BIT		NULL,
								ysnTaxFlag2					BIT		NULL,
								ysnTaxFlag3					BIT		NULL,
								ysnTaxFlag4					BIT		NULL,
								ysnDepositRequired			BIT		NULL,
								intDepositPLUId				INT		NULL,
								ysnQuantityRequired			BIT		NULL,	
								ysnScaleItem				BIT		NULL,
								ysnFoodStampable			BIT		NULL,
								ysnReturnable				BIT		NULL,
								ysnSaleable					BIT		NULL,
								ysnIdRequiredLiquor			BIT		NULL,
								ysnIdRequiredCigarette		BIT		NULL,
								ysnPromotionalItem			BIT		NULL,
								ysnPrePriced				BIT		NULL,
								ysnApplyBlueLaw1			BIT		NULL,
								ysnApplyBlueLaw2			BIT		NULL,
								ysnCountedDaily				BIT		NULL,
								strCounted					NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
								ysnCountBySINo				BIT		NULL,
								intFamilyId					INT		NULL,
								intClassId					INT		NULL,
								intProductCodeId			INT		NULL,
								intVendorId					INT		NULL,
								intMinimumAge				INT		NULL,
								dblMinOrder					NUMERIC(18, 6) NULL,
								dblSuggestedQty				NUMERIC(18, 6) NULL,
								intStorageLocationId		INT		NULL,
								intCountGroupId				INT		NULL
						)




						-- Insert
						INSERT INTO @tempITEMLOCATION
						(
							intItemLocationId,
							ysnTaxFlag1,
							ysnTaxFlag2,
							ysnTaxFlag3,
							ysnTaxFlag4,
							ysnDepositRequired,
							intDepositPLUId,
							ysnQuantityRequired,	
							ysnScaleItem,
							ysnFoodStampable,
							ysnReturnable,
							ysnSaleable,
							ysnIdRequiredLiquor,
							ysnIdRequiredCigarette,
							ysnPromotionalItem,
							ysnPrePriced,
							ysnApplyBlueLaw1,
							ysnApplyBlueLaw2,
							ysnCountedDaily,
							strCounted,
							ysnCountBySINo,
							intFamilyId,
							intClassId,
							intProductCodeId,
							intVendorId,
							intMinimumAge,
							dblMinOrder,
							dblSuggestedQty,
							intStorageLocationId,
							intCountGroupId
						)
						SELECT DISTINCT
							intItemLocationId		= piv.intItemLocationId,
							ysnTaxFlag1				= piv.ysnTaxFlag1,
							ysnTaxFlag2				= piv.ysnTaxFlag2,
							ysnTaxFlag3				= piv.ysnTaxFlag3,
							ysnTaxFlag4				= piv.ysnTaxFlag4,
							ysnDepositRequired		= piv.ysnDepositRequired,
							intDepositPLUId			= CASE WHEN piv.intDepositPLUId = '' THEN NULL ELSE piv.intDepositPLUId END,
							ysnQuantityRequired		= piv.ysnQuantityRequired,	
							ysnScaleItem			= piv.ysnScaleItem,
							ysnFoodStampable		= piv.ysnFoodStampable,
							ysnReturnable			= piv.ysnReturnable,
							ysnSaleable				= piv.ysnSaleable,
							ysnIdRequiredLiquor		= piv.ysnIdRequiredLiquor,
							ysnIdRequiredCigarette	= piv.ysnIdRequiredCigarette,
							ysnPromotionalItem		= piv.ysnPromotionalItem,
							ysnPrePriced			= piv.ysnPrePriced,
							ysnApplyBlueLaw1		= piv.ysnApplyBlueLaw1,
							ysnApplyBlueLaw2		= piv.ysnApplyBlueLaw2,
							ysnCountedDaily			= piv.ysnCountedDaily,
							strCounted				= piv.strCounted,
							ysnCountBySINo			= piv.ysnCountBySINo,
							intFamilyId				= CASE WHEN piv.intFamilyId = '' THEN NULL ELSE piv.intFamilyId END, --piv.intFamilyId,
							intClassId				= CASE WHEN piv.intClassId = '' THEN NULL ELSE piv.intClassId END, --piv.intClassId,
							intProductCodeId		= CASE WHEN piv.intProductCodeId = '' THEN NULL ELSE piv.intProductCodeId END, --piv.intProductCodeId,
							intVendorId				= CASE WHEN piv.intVendorId = '' THEN NULL ELSE piv.intVendorId END, --piv.intVendorId,
							intMinimumAge			= CASE WHEN piv.intMinimumAge = '' THEN NULL ELSE piv.intMinimumAge END, -- piv.intMinimumAge,
							dblMinOrder				= CASE WHEN piv.dblMinOrder = '' THEN NULL ELSE piv.dblMinOrder END, -- piv.dblMinOrder,
							dblSuggestedQty			= CASE WHEN piv.dblSuggestedQty = '' THEN NULL ELSE piv.dblSuggestedQty END, -- piv.dblSuggestedQty,
							intStorageLocationId	= CASE WHEN piv.intStorageLocationId = '' THEN NULL ELSE piv.intStorageLocationId END, --piv.intStorageLocationId
							intCountGroupId			= CASE WHEN piv.intCountGroupId = '' THEN NULL ELSE piv.intCountGroupId END --piv.intStorageLocationId
						FROM (
							SELECT detail.intItemLocationId
								 , detail.strTableColumnName
								 , detail.strOldData
							FROM vyuSTSearchRevertHolderDetail detail
							INNER JOIN tblICItemLocation ItemLoc
								ON detail.intItemLocationId = ItemLoc.intItemLocationId
							WHERE detail.strTableName = N'tblICItemLocation'
								AND detail.intRevertHolderDetailId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@strRevertHolderDetailIdList))
								AND detail.strPreviewOldData != detail.strPreviewNewData
						) src
						PIVOT (
							MAX(strOldData) FOR strTableColumnName IN (ysnTaxFlag1,ysnTaxFlag2, ysnTaxFlag3, ysnTaxFlag4, ysnDepositRequired, intDepositPLUId, ysnQuantityRequired, ysnScaleItem, ysnFoodStampable,
																		ysnReturnable, ysnSaleable, ysnIdRequiredLiquor, ysnIdRequiredCigarette, ysnPromotionalItem, ysnPrePriced, ysnApplyBlueLaw1, ysnApplyBlueLaw2,
																		ysnCountedDaily, strCounted, ysnCountBySINo, intFamilyId, intClassId, intProductCodeId, intVendorId, intMinimumAge, dblMinOrder, dblSuggestedQty, 
																		intStorageLocationId, intCountGroupId)
						) piv





						-- Record row count
						-- SET @intRevertItemLocationRecords = (SELECT COUNT(intItemLocationId) FROM @tempITEMLOCATION)
						SET @intRevertItemLocationRecords = (
																SELECT COUNT(detail.intItemLocationId)
																FROM vyuSTSearchRevertHolderDetail detail
																WHERE detail.strTableName = N'tblICItemLocation' 
																	AND detail.intRevertHolderId = @intRevertHolderId
																	AND detail.intRevertHolderDetailId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@strRevertHolderDetailIdList))
																	AND detail.strPreviewOldData != detail.strPreviewNewData
															 )

	
		--SELECT '@intRevertItemLocationRecords', @intRevertItemLocationRecords

						-----------------------------------------------------------------------------
						-- [START] - ITEM DEBUG MODE
						-----------------------------------------------------------------------------
						IF (@ysnDebug = 1)
							BEGIN
								SELECT 'tblICItemLocation temp table', * FROM @tempITEMLOCATION

								SELECT DISTINCT
									 Item.intItemId,
									 'tblICItemLocation - Before Update',
									 Item.strItemNo,
									 Item.strDescription,
									 ItemLoc.intItemLocationId,
									 ItemLoc.ysnTaxFlag1,
									 ItemLoc.ysnTaxFlag2,
									 ItemLoc.ysnTaxFlag3,
									 ItemLoc.ysnTaxFlag4,
									 ItemLoc.ysnDepositRequired,
									 ItemLoc.intDepositPLUId,
									 ItemLoc.ysnQuantityRequired,	
									 ItemLoc.ysnScaleItem,
									 ItemLoc.ysnFoodStampable,
									 ItemLoc.ysnReturnable,
									 ItemLoc.ysnSaleable,
									 ItemLoc.ysnIdRequiredLiquor,
									 ItemLoc.ysnIdRequiredCigarette,
									 ItemLoc.ysnPromotionalItem,
									 ItemLoc.ysnPrePriced,
									 ItemLoc.ysnApplyBlueLaw1,
									 ItemLoc.ysnApplyBlueLaw2,
									 ItemLoc.ysnCountedDaily,
									 ItemLoc.strCounted,
									 ItemLoc.ysnCountBySINo,
									 ItemLoc.intFamilyId,
									 ItemLoc.intClassId,
									 ItemLoc.intProductCodeId,
									 ItemLoc.intVendorId,
									 ItemLoc.intMinimumAge,
									 ItemLoc.dblMinOrder,
									 ItemLoc.dblSuggestedQty,
									 ItemLoc.intStorageLocationId,
									 ItemLoc.intCountGroupId
								FROM tblICItemLocation ItemLoc
								INNER JOIN vyuSTSearchRevertHolderDetail detail
									ON ItemLoc.intItemLocationId = detail.intItemLocationId	
								INNER JOIN tblICItem Item
									ON ItemLoc.intItemId = Item.intItemId
								WHERE detail.strTableName = N'tblICItemLocation'
									AND detail.intRevertHolderDetailId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@strRevertHolderDetailIdList))
									AND detail.strPreviewOldData != detail.strPreviewNewData
								ORDER BY Item.intItemId ASC
							END
						-----------------------------------------------------------------------------
						-- [END] - ITEM DEBUG MODE
						-----------------------------------------------------------------------------




						-- LOOP ITEM LOCATIONS's
						WHILE EXISTS(SELECT TOP 1 1 FROM @tempITEMLOCATION)
							BEGIN			
	
								DECLARE		@intItemLocationId			INT,
											@ysnTaxFlag1				BIT,
											@ysnTaxFlag2				BIT,
											@ysnTaxFlag3				BIT,
											@ysnTaxFlag4				BIT,
											@ysnDepositRequired			BIT,
											@intDepositPLUId			INT,
											@ysnQuantityRequired		BIT,	
											@ysnScaleItem				BIT,
											@ysnFoodStampable			BIT,
											@ysnReturnable				BIT,
											@ysnSaleable				BIT,
											@ysnIdRequiredLiquor		BIT,
											@ysnIdRequiredCigarette		BIT,
											@ysnPromotionalItem			BIT,
											@ysnPrePriced				BIT,
											@ysnApplyBlueLaw1			BIT,
											@ysnApplyBlueLaw2			BIT,
											@ysnCountedDaily			BIT,
											@strCounted					NVARCHAR(50),
											@ysnCountBySINo				BIT,
											@intFamilyId				INT,
											@intClassId					INT,
											@intProductCodeId			INT,
											@intVendorId				INT,
											@intMinimumAge				INT,
											@dblMinOrder				NUMERIC(18, 6),
											@dblSuggestedQty			NUMERIC(18, 6),
											@intStorageLocationId		INT,
											@intCountGroupId			INT
				

								SELECT TOP 1 
											@intItemLocationId			= temp.intItemLocationId,
											@ysnTaxFlag1				= ISNULL(temp.ysnTaxFlag1, ItemLoc.ysnTaxFlag1),
											@ysnTaxFlag2				= ISNULL(temp.ysnTaxFlag2, ItemLoc.ysnTaxFlag2),
											@ysnTaxFlag3				= ISNULL(temp.ysnTaxFlag3, ItemLoc.ysnTaxFlag3),
											@ysnTaxFlag4				= ISNULL(temp.ysnTaxFlag4, ItemLoc.ysnTaxFlag4),
											@ysnDepositRequired			= ISNULL(temp.ysnDepositRequired, ItemLoc.ysnDepositRequired),
											@intDepositPLUId			= ISNULL(temp.intDepositPLUId, ItemLoc.intDepositPLUId), -- CASE WHEN temp.intDepositPLUId IS NULL THEN ItemLoc.intDepositPLUId ELSE temp.intDepositPLUId END,
											@ysnQuantityRequired		= ISNULL(temp.ysnQuantityRequired, ItemLoc.ysnQuantityRequired),
											@ysnScaleItem				= ISNULL(temp.ysnScaleItem, ItemLoc.ysnScaleItem),
											@ysnFoodStampable			= ISNULL(temp.ysnFoodStampable, ItemLoc.ysnFoodStampable),
											@ysnReturnable				= ISNULL(temp.ysnReturnable, ItemLoc.ysnReturnable),
											@ysnSaleable				= ISNULL(temp.ysnSaleable, ItemLoc.ysnSaleable),
											@ysnIdRequiredLiquor		= ISNULL(temp.ysnIdRequiredLiquor, ItemLoc.ysnIdRequiredLiquor),
											@ysnIdRequiredCigarette		= ISNULL(temp.ysnIdRequiredCigarette, ItemLoc.ysnIdRequiredCigarette),
											@ysnPromotionalItem			= ISNULL(temp.ysnPromotionalItem, ItemLoc.ysnPromotionalItem),
											@ysnPrePriced				= ISNULL(temp.ysnPrePriced, ItemLoc.ysnPrePriced),
											@ysnApplyBlueLaw1			= ISNULL(temp.ysnApplyBlueLaw1, ItemLoc.ysnApplyBlueLaw1),
											@ysnApplyBlueLaw2			= ISNULL(temp.ysnApplyBlueLaw2, ItemLoc.ysnApplyBlueLaw2),
											@ysnCountedDaily			= ISNULL(temp.ysnCountedDaily, ItemLoc.ysnCountedDaily),
											@strCounted					= ISNULL(temp.strCounted, ItemLoc.strCounted),
											@ysnCountBySINo				= ISNULL(temp.ysnCountBySINo, ItemLoc.ysnCountBySINo),
											@intFamilyId				= ISNULL(temp.intFamilyId, ItemLoc.intFamilyId), -- CASE WHEN temp.intFamilyId IS NULL THEN ItemLoc.intFamilyId ELSE temp.intFamilyId END, -- temp.intFamilyId,
											@intClassId					= ISNULL(temp.intClassId, ItemLoc.intClassId), -- CASE WHEN temp.intClassId IS NULL THEN ItemLoc.intClassId ELSE temp.intClassId END, -- temp.intClassId,
											@intProductCodeId			= ISNULL(temp.intProductCodeId, ItemLoc.intProductCodeId), -- CASE WHEN temp.intProductCodeId IS NULL THEN ItemLoc.intProductCodeId ELSE temp.intProductCodeId END, -- temp.intProductCodeId,
											@intVendorId				= ISNULL(temp.intVendorId, ItemLoc.intVendorId), -- CASE WHEN temp.intVendorId IS NULL THEN ItemLoc.intVendorId ELSE temp.intVendorId END, -- temp.intVendorId,
											@intMinimumAge				= ISNULL(temp.intMinimumAge, ItemLoc.intMinimumAge),
											@dblMinOrder				= ISNULL(temp.dblMinOrder, ItemLoc.dblMinOrder),
											@dblSuggestedQty			= ISNULL(temp.dblSuggestedQty, ItemLoc.dblSuggestedQty),
											@intStorageLocationId		= ISNULL(temp.intStorageLocationId, ItemLoc.intStorageLocationId), -- CASE WHEN temp.intStorageLocationId IS NULL THEN ItemLoc.intStorageLocationId ELSE temp.intStorageLocationId END -- temp.intStorageLocationId
											@intCountGroupId			= ISNULL(temp.intCountGroupId, ItemLoc.intCountGroupId)
								FROM @tempITEMLOCATION temp
								INNER JOIN tblICItemLocation ItemLoc
									ON temp.intItemLocationId = ItemLoc.intItemLocationId
								ORDER BY temp.intItemLocationId ASC




								-- UPDATE ITEM LOCATION
								EXEC [dbo].[uspICUpdateItemLocationForCStore]
										-- filter params
										@strUpcCode									= NULL 
										,@strDescription							= NULL 
										,@dblRetailPriceFrom						= NULL  
										,@dblRetailPriceTo							= NULL 
										,@intItemLocationId							= @intItemLocationId                -- *** SET VALUE TO UPDATE SPECIFIC RECORD ***
										-- update params 
										,@ysnTaxFlag1								= @ysnTaxFlag1
										,@ysnTaxFlag2								= @ysnTaxFlag2
										,@ysnTaxFlag3								= @ysnTaxFlag3
										,@ysnTaxFlag4								= @ysnTaxFlag4
										,@ysnDepositRequired						= @ysnDepositRequired
										,@intDepositPLUId							= @intDepositPLUId 
										,@ysnQuantityRequired						= @ysnQuantityRequired 
										,@ysnScaleItem								= @ysnScaleItem 
										,@ysnFoodStampable							= @ysnFoodStampable 
										,@ysnReturnable								= @ysnReturnable 
										,@ysnSaleable								= @ysnSaleable 
										,@ysnIdRequiredLiquor						= @ysnIdRequiredLiquor 
										,@ysnIdRequiredCigarette					= @ysnIdRequiredCigarette 
										,@ysnPromotionalItem						= @ysnPromotionalItem
										,@ysnPrePriced								= @ysnPrePriced 
										,@ysnApplyBlueLaw1							= @ysnApplyBlueLaw1 
										,@ysnApplyBlueLaw2							= @ysnApplyBlueLaw2 
										,@ysnCountedDaily							= @ysnCountedDaily 
										,@strCounted								= @strCounted
										,@ysnCountBySINo							= @ysnCountBySINo 
										,@intFamilyId								= @intFamilyId 
										,@intClassId								= @intClassId 
										,@intProductCodeId							= @intProductCodeId 
										,@intVendorId								= @intVendorId
										,@intMinimumAge								= @intMinimumAge 
										,@dblMinOrder								= @dblMinOrder 
										,@dblSuggestedQty							= @dblSuggestedQty
										,@intCountGroupId							= @intCountGroupId
										,@intStorageLocationId						= @intStorageLocationId 
										,@dblReorderPoint							= NULL
										,@strItemLocationDescription				= NULL 

										,@intEntityUserSecurityId					= @intEntityId -- *** ADD EntityId of the user who commited the revert ***




								--UPDATE tbl
								--SET tbl.strPreviewOldData = CASE
								--								WHEN tbl.strTableColumnName = N'intDepositPLUId'
								--									THEN ISNULL(Uom.strUpcCode, '')
								--								WHEN tbl.strTableColumnName = N'intFamilyId'
								--									THEN ISNULL(Family.strSubcategoryId, '')
								--								WHEN tbl.strTableColumnName = N'intClassId'
								--									THEN ISNULL(Class.strSubcategoryId, '')
								--								WHEN tbl.strTableColumnName = N'intProductCodeId'
								--									THEN ISNULL(ProductCode.strRegProdCode, '')
								--								WHEN tbl.strTableColumnName = N'intVendorId'
								--									THEN ISNULL(Vendor.strName, '')
								--								WHEN tbl.strTableColumnName = N'intCountGroupId'
								--									THEN ISNULL(CountGroup.strCountGroup, '')
								--								ELSE 
								--									tbl.strPreviewOldData
								--							END
								--FROM tblSTRevertHolderDetail tbl
								--INNER JOIN tblICItemLocation ItemLoc
								--	ON tbl.intItemLocationId = ItemLoc.intItemLocationId 
								--LEFT JOIN tblICItemUOM Uom
								--	ON ItemLoc.intDepositPLUId = Uom.intItemUOMId
								--LEFT JOIN tblSTSubcategory Family
								--	ON ItemLoc.intFamilyId = Family.intSubcategoryId
								--LEFT JOIN tblSTSubcategory Class
								--	ON ItemLoc.intClassId = Class.intSubcategoryId
								--LEFT JOIN tblSTSubcategoryRegProd ProductCode
								--	ON ItemLoc.intProductCodeId = ProductCode.intRegProdId
								--LEFT JOIN tblEMEntity Vendor
								--	ON ItemLoc.intVendorId = Vendor.intEntityId
								--LEFT JOIN tblICCountGroup CountGroup
								--	ON ItemLoc.intCountGroupId = CountGroup.intCountGroupId
								--WHERE tbl.intRevertHolderId = @intRevertHolderId
								--	AND tbl.strTableName = N'tblICItemLocation'
								--	AND tbl.strTableColumnName IN (N'intDepositPLUId', N'intFamilyId', N'intClassId', N'intProductCodeId', N'intVendorId', N'intCountGroupId')
								--	AND tbl.intItemLocationId = @intItemLocationId



								-- Remove
								DELETE FROM @tempITEMLOCATION WHERE intItemLocationId = @intItemLocationId
		
							END




						-----------------------------------------------------------------------------
						-- [START] - ITEM DEBUG MODE
						-----------------------------------------------------------------------------
						IF (@ysnDebug = 1)
							BEGIN
								SELECT DISTINCT 
									 Item.intItemId,
									 'tblICItemLocation - After Update',
									 Item.strItemNo,
									 Item.strDescription,
									 ItemLoc.intItemLocationId,
									 ItemLoc.ysnTaxFlag1,
									 ItemLoc.ysnTaxFlag2,
									 ItemLoc.ysnTaxFlag3,
									 ItemLoc.ysnTaxFlag4,
									 ItemLoc.ysnDepositRequired,
									 ItemLoc.intDepositPLUId,
									 ItemLoc.ysnQuantityRequired,	
									 ItemLoc.ysnScaleItem,
									 ItemLoc.ysnFoodStampable,
									 ItemLoc.ysnReturnable,
									 ItemLoc.ysnSaleable,
									 ItemLoc.ysnIdRequiredLiquor,
									 ItemLoc.ysnIdRequiredCigarette,
									 ItemLoc.ysnPromotionalItem,
									 ItemLoc.ysnPrePriced,
									 ItemLoc.ysnApplyBlueLaw1,
									 ItemLoc.ysnApplyBlueLaw2,
									 ItemLoc.ysnCountedDaily,
									 ItemLoc.strCounted,
									 ItemLoc.ysnCountBySINo,
									 ItemLoc.intFamilyId,
									 ItemLoc.intClassId,
									 ItemLoc.intProductCodeId,
									 ItemLoc.intVendorId,
									 ItemLoc.intMinimumAge,
									 ItemLoc.dblMinOrder,
									 ItemLoc.dblSuggestedQty,
									 ItemLoc.intStorageLocationId,
									 ItemLoc.intCountGroupId
								FROM tblICItemLocation ItemLoc
								INNER JOIN vyuSTSearchRevertHolderDetail detail
									ON ItemLoc.intItemLocationId = detail.intItemLocationId	
								INNER JOIN tblICItem Item
									ON ItemLoc.intItemId = Item.intItemId
								WHERE detail.strTableName = N'tblICItemLocation'
									AND detail.intRevertHolderDetailId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@strRevertHolderDetailIdList))
									AND detail.strPreviewOldData != detail.strPreviewNewData
								ORDER BY Item.intItemId ASC
							END
						-----------------------------------------------------------------------------
						-- [END] - ITEM DEBUG MODE
						-----------------------------------------------------------------------------


				

					END
				ELSE
					BEGIN
						PRINT 'No Records found to update - tblICItemLocation'
					END
				-- ==================================================================================================================================================
				-- [END] - Revert ITEM LOCATION
				-- ==================================================================================================================================================

			END

		ELSE IF(@intRevertType = 2)
			BEGIN
				
				-- ITEM PRICING
				-- ==================================================================================================================================================
				-- [START] - Revert ITEM PRICING
				-- ==================================================================================================================================================
				IF EXISTS(
							SELECT TOP 1 1 FROM vyuSTSearchRevertHolderDetail detail
							WHERE detail.strTableName = N'tblICItemPricing' 
								AND detail.intRevertHolderId = @intRevertHolderId
								AND detail.intRevertHolderDetailId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@strRevertHolderDetailIdList))
								AND detail.strPreviewOldData != detail.strPreviewNewData
						 )
					BEGIN
							-- Create
							DECLARE @tempITEMPRICING TABLE (
									intItemPricingId		INT NOT NULL
									, dblStandardCost		NUMERIC(38, 20) NULL
									, dblSalePrice			NUMERIC(38, 20) NULL
									, dblLastCost			NUMERIC(38, 20) NULL
									, intItemId				INT
									, intCompanyLocationId	INT
									, intItemLocationId		INT
									, intItemUOMId			INT
							)


							-- Insert
							INSERT INTO @tempITEMPRICING
							(
								intItemPricingId
								, dblStandardCost
								, dblSalePrice
								, dblLastCost
								, intItemId
								, intCompanyLocationId
								, intItemLocationId
								, intItemUOMId
							)
							SELECT DISTINCT
								intItemPricingId		= piv.intItemPricingId
								, dblStandardCost		= piv.dblStandardCost
								, dblSalePrice			= piv.dblSalePrice
								, dblLastCost			= piv.dblLastCost
								, intItemId				= piv.intItemId
								, intCompanyLocationId	= piv.intCompanyLocationId
								, intItemLocationId		= piv.intItemLocationId
								, intItemUOMId			= piv.intItemUOMId
							FROM (
								SELECT detail.intItemPricingId
									 , detail.intItemId
									 , detail.intCompanyLocationId
									 , detail.intItemLocationId
									 , detail.intItemUOMId
									 , detail.strTableColumnName
									 , detail.strOldData
								FROM vyuSTSearchRevertHolderDetail detail
								WHERE detail.strTableName = N'tblICItemPricing'
									AND detail.intRevertHolderId = @intRevertHolderId
									AND detail.intRevertHolderDetailId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@strRevertHolderDetailIdList))
									AND detail.strPreviewOldData != detail.strPreviewNewData
							) src
							PIVOT (
								MAX(strOldData) FOR strTableColumnName IN (dblStandardCost, dblSalePrice, dblLastCost)
							) piv



							-- Count records
							SET @intRevertItemPricingRecords = (
																SELECT COUNT(detail.intItemLocationId)
																FROM vyuSTSearchRevertHolderDetail detail
																WHERE detail.strTableName = N'tblICItemPricing' 
																	AND detail.intRevertHolderId = @intRevertHolderId
																	AND detail.intRevertHolderDetailId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@strRevertHolderDetailIdList))
																	AND detail.strPreviewOldData != detail.strPreviewNewData
																)



							-----------------------------------------------------------------------------
							-- [START] - ITEM PRICING DEBUG MODE
							-----------------------------------------------------------------------------
							IF (@ysnDebug = 1)
								BEGIN
									SELECT 'tblICItemPricing temp table', * FROM @tempITEMPRICING

									SELECT DISTINCT
										   'tblICItemPricing - Before Update'
										     , Item.strItemNo
											 , Item.strDescription
											 , ItemPricing.intItemPricingId
											 , ItemPricing.dblStandardCost
											 , ItemPricing.dblSalePrice
											 , ItemPricing.dblLastCost
									FROM tblICItemPricing ItemPricing
									INNER JOIN tblICItem Item
										ON ItemPricing.intItemId = Item.intItemId
									INNER JOIN vyuSTSearchRevertHolderDetail detail
										ON ItemPricing.intItemPricingId = detail.intItemPricingId	
									WHERE detail.strTableName = N'tblICItemPricing'
										AND detail.intRevertHolderDetailId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@strRevertHolderDetailIdList))
										-- AND detail.strPreviewOldData != detail.strPreviewNewData
									ORDER BY ItemPricing.intItemPricingId ASC
								END
							-----------------------------------------------------------------------------
							-- [END] - ITEM PRICING DEBUG MODE
							-----------------------------------------------------------------------------



							-- LOOP ITEM PRICING's
							WHILE EXISTS(SELECT TOP 1 1 FROM @tempITEMPRICING)
								BEGIN			
	
									DECLARE  @intItemPricingId		INT
											, @dblStandardCost		DECIMAL(38, 20)
											, @dblSalePrice			DECIMAL(38, 20)
											, @dblLastCost			DECIMAL(38, 20)

											, @intCompanyLocationId INT
											, @intItemUOMId			INT
											, @strItemDescription	NVARCHAR(150)
											, @strUpcCode			NVARCHAR(50)


								    -- GET VALUES HERE
									SELECT TOP 1 
											@intItemPricingId			=  temp.intItemPricingId
											, @intItemId				=  temp.intItemId
											, @intCompanyLocationId		=  temp.intCompanyLocationId
											, @intItemLocationId		=  temp.intItemLocationId
											, @intItemUOMId				=  temp.intItemUOMId
											, @strItemDescription		=  Item.strDescription
											, @strUpcCode				=  CASE 
																				WHEN Uom.strLongUPCCode IS NULL OR Uom.strLongUPCCode = ''
																					THEN Uom.strUpcCode
																				ELSE Uom.strLongUPCCode
																		END
																				

											, @dblStandardCost			=  CASE 
																				WHEN temp.dblStandardCost IS NULL
																					THEN ItemPricing.dblStandardCost
																				ELSE temp.dblStandardCost
																		END
											, @dblSalePrice				=  CASE 
																				WHEN temp.dblSalePrice IS NULL
																					THEN ItemPricing.dblSalePrice
																				ELSE temp.dblSalePrice
																		END
											, @dblLastCost				=  CASE 
																				WHEN temp.dblLastCost IS NULL
																					THEN ItemPricing.dblLastCost
																				ELSE temp.dblLastCost
																		END
									FROM @tempITEMPRICING temp
									INNER JOIN tblICItemPricing ItemPricing
										ON temp.intItemPricingId = ItemPricing.intItemPricingId
									INNER JOIN tblICItem Item
										ON ItemPricing.intItemId = Item.intItemId
									INNER JOIN tblICItemLocation ItemLoc
										ON Item.intItemId = ItemLoc.intItemId
										AND temp.intItemLocationId = ItemLoc.intItemLocationId
									LEFT JOIN tblICItemUOM Uom
										ON temp.intItemUOMId = Uom.intItemUOMId
										AND Item.intItemId = Uom.intItemId
									WHERE Uom.ysnStockUnit = 1
									ORDER BY temp.intItemPricingId ASC
										


									-- UPDATE ITEM PRICING
									EXEC [dbo].[uspICUpdateItemPricingForCStore]
											-- filter params
											@strUpcCode					= @strUpcCode 
											,@strDescription			= @strItemDescription 
											,@intItemId					= @intItemId 
											,@intItemPricingId			= @intItemPricingId 

											-- update params
											,@dblStandardCost			= @dblStandardCost 
											,@dblRetailPrice			= @dblSalePrice 
											,@dblLastCost				= @dblLastCost
											,@intEntityUserSecurityId	= @intEntityId -- *** ADD EntityId of the user who commited the revert ***

			
									-- Remove
									DELETE FROM @tempITEMPRICING WHERE intItemPricingId = @intItemPricingId
		
								END


							

							-----------------------------------------------------------------------------
							-- [START] - ITEM PRICING DEBUG MODE
							-----------------------------------------------------------------------------
							IF (@ysnDebug = 1)
								BEGIN
									SELECT 'tblICItemPricing temp table', * FROM @tempITEMPRICING

									SELECT DISTINCT
										   'tblICItemPricing - After Update'
										     , Item.strItemNo
											 , Item.strDescription
											 , ItemPricing.intItemPricingId
											 , ItemPricing.dblStandardCost
											 , ItemPricing.dblSalePrice
											 , ItemPricing.dblLastCost
									FROM tblICItemPricing ItemPricing
									INNER JOIN tblICItem Item
										ON ItemPricing.intItemId = Item.intItemId
									INNER JOIN vyuSTSearchRevertHolderDetail detail
										ON ItemPricing.intItemPricingId = detail.intItemPricingId	
									WHERE detail.strTableName = N'tblICItemPricing'
										AND detail.intRevertHolderDetailId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@strRevertHolderDetailIdList))
										-- AND detail.strPreviewOldData != detail.strPreviewNewData
									ORDER BY ItemPricing.intItemPricingId ASC
								END
							-----------------------------------------------------------------------------
							-- [END] - ITEM PRICING DEBUG MODE
							-----------------------------------------------------------------------------


					END	
				-- ==================================================================================================================================================
				-- [END] - Revert ITEM PRICING
				-- ==================================================================================================================================================




				-- ITEM SPECIAL PRICING
				-- ==================================================================================================================================================
				-- [START] - Revert ITEM SPECIAL PRICING
				-- ==================================================================================================================================================
				IF EXISTS(
							SELECT TOP 1 1 FROM vyuSTSearchRevertHolderDetail detail
							WHERE detail.strTableName = N'tblICItemSpecialPricing' 
								AND detail.intRevertHolderId = @intRevertHolderId
								AND detail.intRevertHolderDetailId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@strRevertHolderDetailIdList))
								AND detail.strPreviewOldData != detail.strPreviewNewData
						 )
					BEGIN
	

							-- Create
							DECLARE @tempITEMSPECIALPRICING TABLE (
										intItemSpecialPricingId		INT NOT NULL
										, dblUnitAfterDiscount		NUMERIC(38, 20) NULL
										, dtmBeginDate				DATETIME
										, dtmEndDate				DATETIME

										, intItemId					INT
										, intCompanyLocationId		INT
										, intItemLocationId			INT
										, intItemUOMId				INT
							)


							-- Insert
							INSERT INTO @tempITEMSPECIALPRICING
							(
								intItemSpecialPricingId
								, dblUnitAfterDiscount
								, dtmBeginDate
								, dtmEndDate

								, intItemId
								, intCompanyLocationId
								, intItemLocationId
								, intItemUOMId
							)
							SELECT DISTINCT
								intItemSpecialPricingId	= piv.intItemSpecialPricingId
								, dblUnitAfterDiscount	= piv.dblUnitAfterDiscount
								, dtmBeginDate			= piv.dtmBeginDate
								, dtmEndDate			= piv.dtmEndDate

								, intItemId				= piv.intItemId
								, intCompanyLocationId	= piv.intCompanyLocationId
								, intItemLocationId		= piv.intItemLocationId
								, intItemUOMId			= piv.intItemUOMId
							FROM (
								SELECT detail.intItemSpecialPricingId
									 , detail.intItemId
									 , detail.intCompanyLocationId
									 , detail.intItemLocationId
									 , detail.intItemUOMId
									 , detail.strTableColumnName
									 , detail.strOldData
								FROM vyuSTSearchRevertHolderDetail detail
								WHERE detail.strTableName = N'tblICItemSpecialPricing'
									AND detail.intRevertHolderId = @intRevertHolderId
									AND detail.intRevertHolderDetailId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@strRevertHolderDetailIdList))
									AND detail.strPreviewOldData != detail.strPreviewNewData
							) src
							PIVOT (
								MAX(strOldData) FOR strTableColumnName IN (dblUnitAfterDiscount, dtmBeginDate, dtmEndDate)
							) piv

							-- Count records
							SET @intRevertItemSpecialPricingRecords = (
																		SELECT COUNT(detail.intItemLocationId)
																		FROM vyuSTSearchRevertHolderDetail detail
																		WHERE detail.strTableName = N'tblICItemSpecialPricing' 
																			AND detail.intRevertHolderId = @intRevertHolderId
																			AND detail.intRevertHolderDetailId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@strRevertHolderDetailIdList))
																			AND detail.strPreviewOldData != detail.strPreviewNewData
																	  )



							-----------------------------------------------------------------------------
							-- [START] - ITEM SPECIAL PRICING DEBUG MODE
							-----------------------------------------------------------------------------
							IF (@ysnDebug = 1)
								BEGIN
									SELECT 'tblICItemSpecialPricing temp table', * FROM @tempITEMSPECIALPRICING

									SELECT DISTINCT
										   'tblICItemSpecialPricing - Before Update'
										     , Item.strItemNo
											 , Item.strDescription
											 , ItemSpecialPricing.intItemSpecialPricingId
											 , ItemSpecialPricing.dblUnitAfterDiscount
											 , ItemSpecialPricing.dtmBeginDate
											 , ItemSpecialPricing.dtmEndDate
									FROM tblICItemSpecialPricing ItemSpecialPricing
									INNER JOIN tblICItem Item
										ON ItemSpecialPricing.intItemId = Item.intItemId
									INNER JOIN vyuSTSearchRevertHolderDetail detail
										ON ItemSpecialPricing.intItemSpecialPricingId = detail.intItemSpecialPricingId	
									WHERE detail.strTableName = N'tblICItemSpecialPricing'
										AND detail.intRevertHolderDetailId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@strRevertHolderDetailIdList))
										-- AND detail.strPreviewOldData != detail.strPreviewNewData
									ORDER BY ItemSpecialPricing.intItemSpecialPricingId ASC
								END
							-----------------------------------------------------------------------------
							-- [END] - ITEM SPECIAL PRICING DEBUG MODE
							-----------------------------------------------------------------------------



							-- LOOP ITEM SPECIAL PRICING's
							WHILE EXISTS(SELECT TOP 1 1 FROM @tempITEMSPECIALPRICING)
								BEGIN			
	
									DECLARE  @intItemSpecialPricingId		INT
											, @dblUnitAfterDiscount			DECIMAL(38, 20)
											, @dtmBeginDate					DATETIME
											, @dtmEndDate					DATETIME

								    -- GET VALUES HERE
									SELECT TOP 1 
											@intItemSpecialPricingId	=  temp.intItemSpecialPricingId
											, @intItemId				=  temp.intItemId
											, @intCompanyLocationId		=  temp.intCompanyLocationId
											, @intItemLocationId		=  temp.intItemLocationId
											, @intItemUOMId				=  temp.intItemUOMId
											, @strItemDescription		=  Item.strDescription
											, @strUpcCode				=  CASE 
																				WHEN Uom.strLongUPCCode IS NULL OR Uom.strLongUPCCode = ''
																					THEN Uom.strUpcCode
																				ELSE Uom.strLongUPCCode
																		END
																				

											, @dblUnitAfterDiscount		= ISNULL(temp.dblUnitAfterDiscount, ItemSpecialPricing.dblUnitAfterDiscount)
											, @dtmBeginDate				= ISNULL(temp.dtmBeginDate, ItemSpecialPricing.dtmBeginDate)
											, @dtmEndDate				= ISNULL(temp.dtmEndDate, ItemSpecialPricing.dtmEndDate)
									FROM @tempITEMSPECIALPRICING temp
									INNER JOIN tblICItemSpecialPricing ItemSpecialPricing
										ON temp.intItemSpecialPricingId = ItemSpecialPricing.intItemSpecialPricingId
									INNER JOIN tblICItem Item
										ON ItemSpecialPricing.intItemId = Item.intItemId
									INNER JOIN tblICItemLocation ItemLoc
										ON Item.intItemId = ItemLoc.intItemId
										AND temp.intItemLocationId = ItemLoc.intItemLocationId
									LEFT JOIN tblICItemUOM Uom
										ON temp.intItemUOMId = Uom.intItemUOMId
										AND Item.intItemId = Uom.intItemId
									WHERE Uom.ysnStockUnit = 1
									ORDER BY temp.intItemSpecialPricingId ASC
										


									-- UPDATE ITEM PECIAL PRICING
									EXEC [dbo].[uspICUpdateItemPromotionalPricingForCStore]
											@dblPromotionalSalesPrice	= @dblUnitAfterDiscount 
											, @dtmBeginDate				= @dtmBeginDate 
											, @dtmEndDate 				= @dtmEndDate 
											, @intItemSpecialPricingId  = @intItemSpecialPricingId
											, @intEntityUserSecurityId	= @intEntityId -- *** ADD EntityId of the user who commited the revert ***

	

									-- Remove
									DELETE FROM @tempITEMSPECIALPRICING WHERE intItemSpecialPricingId = @intItemSpecialPricingId
		
								END



							-----------------------------------------------------------------------------
							-- [START] - ITEM SPECIAL PRICING DEBUG MODE
							-----------------------------------------------------------------------------
							IF (@ysnDebug = 1)
								BEGIN
									SELECT DISTINCT
										   'tblICItemSpecialPricing - After Update'
										     , Item.strItemNo
											 , Item.strDescription
											 , ItemSpecialPricing.intItemSpecialPricingId
											 , ItemSpecialPricing.dblUnitAfterDiscount
											 , ItemSpecialPricing.dtmBeginDate
											 , ItemSpecialPricing.dtmEndDate
									FROM tblICItemSpecialPricing ItemSpecialPricing
									INNER JOIN tblICItem Item
										ON ItemSpecialPricing.intItemId = Item.intItemId
									INNER JOIN vyuSTSearchRevertHolderDetail detail
										ON ItemSpecialPricing.intItemSpecialPricingId = detail.intItemSpecialPricingId	
									WHERE detail.strTableName = N'tblICItemSpecialPricing'
										AND detail.intRevertHolderDetailId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@strRevertHolderDetailIdList))
										--AND detail.strPreviewOldData != detail.strPreviewNewData
									ORDER BY ItemSpecialPricing.intItemSpecialPricingId ASC
								END
							-----------------------------------------------------------------------------
							-- [END] - ITEM SPECIAL PRICING DEBUG MODE
							-----------------------------------------------------------------------------
						   
					END
				-- ==================================================================================================================================================
				-- [END] - Revert ITEM SPECIAL PRICING
				-- ==================================================================================================================================================

			END
		
		



		-- Clean up (ITEM, ITEM UOM, ITEM LOCATION, VendorXref)
		BEGIN
			IF OBJECT_ID('tempdb..#tmpUpdateItemForCStore_itemAuditLog') IS NOT NULL  
				DROP TABLE #tmpUpdateItemForCStore_itemAuditLog 

			IF OBJECT_ID('tempdb..#tmpUpdateItemUOMForCStore_itemAuditLog') IS NOT NULL  
				DROP TABLE #tmpUpdateItemUOMForCStore_itemAuditLog 

			IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_ItemPricingAuditLog') IS NOT NULL  
				DROP TABLE #tmpUpdateItemPricingForCStore_ItemPricingAuditLog 
				
			IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_ItemSpecialPricingAuditLog') IS NOT NULL  
				DROP TABLE #tmpUpdateItemPricingForCStore_ItemSpecialPricingAuditLog 

			IF OBJECT_ID('tempdb..#tmpUpdateItemVendorXrefForCStore_itemAuditLog') IS NOT NULL  
				DROP TABLE #tmpUpdateItemVendorXrefForCStore_itemAuditLog 

			IF OBJECT_ID('tempdb..#tmpUpdateItemLocationForCStore_itemLocationAuditLog') IS NOT NULL  
				DROP TABLE #tmpUpdateItemLocationForCStore_itemLocationAuditLog 
		END

			



		DECLARE @intAllRevertedRecordsCount INT = 0
		SET @intAllRevertedRecordsCount = @intRevertItemRecords + @intRevertItemLocationRecords + @intRevertItemPricingRecords + @intRevertItemSpecialPricingRecords

		DECLARE @strAllRevertedRecordsCount NVARCHAR(500) = CAST(@intAllRevertedRecordsCount AS NVARCHAR(500))

		-- RECORDs
		IF(@strAllRevertedRecordsCount = 1)
			BEGIN
				SET @strResultMsg = 'Successfully reverted ' + @strAllRevertedRecordsCount + ' record.'
			END
		ELSE IF(@strAllRevertedRecordsCount > 1)
			BEGIN
				SET @strResultMsg = 'Successfully reverted ' + @strAllRevertedRecordsCount + ' records.'
			END



		IF(@ysnDebug = 0)
			BEGIN
				GOTO ExitWithCommit
			END
		ELSE IF(@ysnDebug = 1)
			BEGIN
				PRINT @strResultMsg
				PRINT 'Will Rollback and exit'
				GOTO ExitWithRollback
			END

END TRY

BEGIN CATCH      	   
	 SET @strResultMsg = 'Error Message: ' + ERROR_MESSAGE()    
	 SET @ysnSuccess = CAST(0 AS BIT)

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