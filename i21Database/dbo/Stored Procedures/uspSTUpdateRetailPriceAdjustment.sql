﻿CREATE PROCEDURE [dbo].[uspSTUpdateRetailPriceAdjustment]
	@intRetailPriceAdjustmentId		INT,
	@intCurrentUserId				INT,
	@ysnHasPreviewReport			BIT,
	@ysnRecap						BIT,
	@ysnBatchPost					BIT		= 1,
	@ysnSuccess						BIT				OUTPUT,
	@strMessage						NVARCHAR(1000)	OUTPUT
AS

SET ANSI_NULLS, QUOTED_IDENTIFIER ON
SET NOCOUNT ON
SET XACT_ABORT ON

BEGIN

    DECLARE @InitTranCount INT;
    SET @InitTranCount = @@TRANCOUNT
	DECLARE @Savepoint NVARCHAR(32) = SUBSTRING(('uspSTUpdateRetailPriceAdjustment' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)

	BEGIN TRY
		

		IF @InitTranCount = 0
			BEGIN
				BEGIN TRANSACTION
			END		
		ELSE
			BEGIN
				SAVE TRANSACTION @Savepoint
			END

		DECLARE @intSuccessPostCount INT = 0
		DECLARE @intFailedPostCount  INT = 0

		SET @ysnSuccess = CAST(1 AS BIT)
		SET @strMessage = ''

		--TEST
		--SELECT 'uspSTUpdateRetailPriceAdjustment'

		IF EXISTS(SELECT TOP 1 1 
		          FROM tblSTRetailPriceAdjustment 
				  WHERE intRetailPriceAdjustmentId = @intRetailPriceAdjustmentId 
					AND (
							-- IF BATCH POST
							(@ysnBatchPost = 1
								AND CAST(dtmEffectiveDate AS DATE) <= CAST(GETDATE() AS DATE)
							)
							OR
							-- IF NORMAL POST
							(@ysnBatchPost = 0
								AND CAST(dtmEffectiveDate AS DATE) = CAST(GETDATE() AS DATE)
							)
						)
					)
			BEGIN
				
				-- VALIDATION
				IF EXISTS( SELECT TOP 1 1
					FROM tblSTRetailPriceAdjustmentDetail pad
					INNER JOIN dbo.tblSTRetailPriceAdjustment rpa
						ON pad.intRetailPriceAdjustmentId = rpa.intRetailPriceAdjustmentId

					WHERE pad.intRetailPriceAdjustmentId = @intRetailPriceAdjustmentId
					AND intCategoryId IS NULL
					AND intFamilyId IS NULL
					AND intClassId IS NULL
					AND pad.intEntityId IS NULL
					AND pad.intItemUOMId IS NULL
					AND ISNULL(strRegion, '')  =  ''
					AND ISNULL(strDistrict, '')  =  '')
				BEGIN
					GOTO ExitWithRollback
				END


				--TEST
				--SELECT 'GETDATE()', CAST(GETDATE() AS DATE)

				-- ===========================================================================================================
				-- START Create the filter tables
				BEGIN
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
				END
				-- END Create the filter tables
				-- ===========================================================================================================

				-- CREATE Temp Table
				DECLARE @tblRetailPriceAdjustmentDetailIds TABLE 
				(
					intRetailPriceAdjustmentDetailId	INT,
					ysnOneTimeUse						BIT,
					intCompanyLocationId				INT NULL,
					intCategoryId						INT NULL,
				    intFamilyId							INT NULL,
					intClassId							INT NULL,
					intEntityId							INT NULL,
					strRegion							NVARCHAR(100) NULL,
					strPriceMethod						NVARCHAR(100) NULL,
					strRoundPrice						NVARCHAR(10) NULL,
					strPriceEndingDigit					NVARCHAR(10) NULL,
					strDistrict							NVARCHAR(100) NULL,
					intItemUOMId						INT NULL,
 					dblPrice							NUMERIC(18,6) NULL, 
					dblLastCost							NUMERIC(18,6) NULL,
					dblFactor							NUMERIC(18,6) NULL,
					dtmEffectiveDate					DATETIME NULL
				)
				
				-- INSERT to Temp Table
				INSERT INTO @tblRetailPriceAdjustmentDetailIds
				(
					intRetailPriceAdjustmentDetailId,
					ysnOneTimeUse,
					intCompanyLocationId,
					intCategoryId,
				    intFamilyId,
					intClassId,
					intEntityId,
					strRegion,
					strPriceMethod,		
					strRoundPrice,		
					strPriceEndingDigit,
					strDistrict,
					intItemUOMId,
 					dblPrice, 
					dblLastCost,
					dblFactor,
					dtmEffectiveDate
				)
				SELECT
					pad.intRetailPriceAdjustmentDetailId,
					ysnOneTimeUse,
					intCompanyLocationId,
					intCategoryId,
				    intFamilyId,
					intClassId,
					pad.intEntityId,
					strRegion,
					pad.strPriceMethod,		
					pad.strRoundPrice,		
					pad.strPriceEndingDigit,
					strDistrict,
					intItemUOMId,
 					dblPrice, 
					dblLastCost,
					pad.dblFactor,
					rpa.dtmEffectiveDate
				FROM tblSTRetailPriceAdjustmentDetail pad
				INNER JOIN dbo.tblSTRetailPriceAdjustment rpa
					ON pad.intRetailPriceAdjustmentId = rpa.intRetailPriceAdjustmentId
				WHERE pad.intRetailPriceAdjustmentId = @intRetailPriceAdjustmentId
					AND rpa.ysnPosted = CAST(0 AS BIT)

				IF EXISTS(SELECT TOP 1 1 FROM @tblRetailPriceAdjustmentDetailIds)
					BEGIN

						DECLARE @intLocationId						INT = NULL
							, @intVendorId							INT = NULL
							, @intCategoryId						INT = NULL
							, @intFamilyId							INT = NULL
							, @intClassId							INT = NULL
							, @intItemId							INT = NULL
							, @intRecordCount						INT = NULL
							, @intItemUOMId							INT = NULL
							, @intRetailPriceAdjustmentDetailId		INT = NULL
							, @dblRetailPrice						DECIMAL(18,6) = NULL
							, @dblLastCostPrice						DECIMAL(18,6) = NULL
							, @dblFactor							DECIMAL(18,6) = NULL
							, @intSavedUserId						INT = NULL
							, @ysnOneTimeUse						BIT = NULL 
							, @strRegion							NVARCHAR(100) = NULL
							, @strPriceMethod						NVARCHAR(100) = NULL
							, @strRoundPrice						NVARCHAR(100) = NULL
							, @strPriceEndingDigit					NVARCHAR(100) = NULL
							, @strDistrict							NVARCHAR(100) = NULL
							, @dtmEffectiveDate						DATETIME = NULL

						WHILE EXISTS(SELECT TOP 1 1 FROM @tblRetailPriceAdjustmentDetailIds)
							BEGIN
								-- Get Primary Id
								SELECT TOP 1 
									@intRetailPriceAdjustmentDetailId	= intRetailPriceAdjustmentDetailId,
									@ysnOneTimeUse						= ysnOneTimeUse,
									@intLocationId						= intCompanyLocationId,
									@intCategoryId						= intCategoryId,
									@intFamilyId						= intFamilyId,
									@intClassId							= intClassId,
									@intVendorId						= intEntityId,
									@strRegion							= ISNULL(strRegion, ''),
									@strPriceMethod						= strPriceMethod,
									@strRoundPrice						= strRoundPrice,
									@strPriceEndingDigit				= strPriceEndingDigit,
									@strDistrict						= ISNULL(strDistrict, ''),
									@intItemUOMId						= intItemUOMId,
 									@dblRetailPrice						= dblPrice, 
									@dblLastCostPrice					= dblLastCost,
									@dblFactor							= dblFactor,
									@dtmEffectiveDate					= dtmEffectiveDate
								FROM @tblRetailPriceAdjustmentDetailIds

								DECLARE @dblRetailPriceConv AS NUMERIC(38, 20) = CAST(@dblRetailPrice AS NUMERIC(38, 20))
								DECLARE @dblLastCostConv AS NUMERIC(38, 20) = CAST(@dblLastCostPrice AS NUMERIC(38, 20))
								DECLARE @dtmEffectiveDateConv AS DATETIME = @dtmEffectiveDate

								SET @intCurrentUserId = ISNULL(@intCurrentUserId, @intSavedUserId)

								DECLARE @CursorTran AS CURSOR
								SET @CursorTran = CURSOR FOR
								SELECT DISTINCT I.intItemId
									, itemPricing.intItemPricingId
									, UOM.strLongUPCCode
									, I.strDescription
									, itemPricing.dblStandardCost
									, itemPricing.dblSalePrice
									, itemPricing.dblLastCost
								FROM tblICItem I
								INNER JOIN tblICItemLocation itemLoc ON itemLoc.intItemId = I.intItemId
								INNER JOIN tblICItemPricing itemPricing ON I.intItemId	= itemPricing.intItemId
									AND itemLoc.intItemLocationId = itemPricing.intItemLocationId
								INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = itemLoc.intLocationId
								INNER JOIN tblAPVendor Vendor ON Vendor.intEntityId = itemLoc.intVendorId
								INNER JOIN tblSTStore ST ON ST.intCompanyLocationId = itemLoc.intLocationId
								INNER JOIN tblICItemUOM UOM ON UOM.intItemId = I.intItemId
								INNER JOIN tblICCategory CAT ON CAT.intCategoryId = I.intCategoryId
								LEFT JOIN tblSTSubcategory FAMILY ON FAMILY.intSubcategoryId = itemLoc.intFamilyId
								LEFT JOIN tblSTSubcategory CLASS ON CLASS.intSubcategoryId = itemLoc.intClassId
								WHERE (@intLocationId IS NULL OR (CL.intCompanyLocationId = @intLocationId))
								AND (@intVendorId IS NULL OR (Vendor.intEntityId = @intVendorId))
								AND (@strRegion = '' OR (ST.strRegion = @strRegion))
								AND (@strDistrict = '' OR (ST.strDistrict = @strDistrict))
								AND (@intItemUOMId IS NULL OR (UOM.intItemUOMId = @intItemUOMId))
								AND (@intCategoryId IS NULL OR (CAT.intCategoryId = @intCategoryId))
								AND (@intFamilyId IS NULL OR (FAMILY.intSubcategoryId = @intFamilyId))
								AND (@intClassId IS NULL OR (CLASS.intSubcategoryId = @intClassId))
								AND UOM.strLongUPCCode IS NOT NULL
								AND itemPricing.intItemPricingId IS NOT NULL


								DECLARE @strProcessLongUpcCode NVARCHAR(50) = NULL,
									 @intProcessItemId INT = NULL,
									 @intProcessLocationId INT = NULL,
									 @intProcessItemPricingId INT = NULL,
									 @strProcessDescription NVARCHAR(500) = NULL,
									 @dblStandardCost NVARCHAR(500) = NULL,
									 @dblSalePrice NVARCHAR(500) = NULL,
									 @dblLastCost NVARCHAR(500) = NULL,
									 @dblFirst NVARCHAR(500) = NULL,
									 @intSecond NVARCHAR(500) = NULL,
									 @dblRetailPriceConvCopy  AS NUMERIC(38, 20) = @dblRetailPriceConv

								OPEN @CursorTran
								FETCH NEXT FROM @CursorTran INTO @intProcessItemId, @intProcessItemPricingId, @strProcessLongUpcCode, @strProcessDescription, @dblStandardCost, @dblSalePrice, @dblLastCost
								WHILE @@FETCH_STATUS = 0
								BEGIN
									-- ITEM PRICING
									BEGIN TRY


									SET @dblFactor = ISNULL(@dblFactor, 0);
									SET @dblSalePrice = ROUND(@dblSalePrice, 2)
									
									IF ISNULL(@dblRetailPriceConvCopy, 0) = 0
										BEGIN
											SET @dblRetailPriceConv = CASE WHEN @strPriceMethod = 'Sell + Amount'
																			  THEN @dblSalePrice + @dblFactor
																		   WHEN @strPriceMethod = 'Sell + Percent'
																		      THEN @dblSalePrice * (1 +(@dblFactor / 100))
																		   WHEN @strPriceMethod = 'Gross Margin' AND @dblStandardCost > 0 
																		      THEN @dblStandardCost / (1 - (@dblFactor / 100))
																		   WHEN @strPriceMethod = 'Gross Margin' AND @dblStandardCost = 0 
																		      THEN @dblLastCost / (1 - (@dblFactor / 100))

																	  END
											SET @dblRetailPriceConv = ROUND(@dblRetailPriceConv, 2)

											IF @strRoundPrice = 'Yes'
												BEGIN
													SET @intSecond = SUBSTRING(CONVERT(VARCHAR, @dblRetailPriceConv), LEN(@dblSalePrice), 1);
													SET @dblFirst = SUBSTRING(CONVERT(VARCHAR, @dblRetailPriceConv), 1, LEN(@dblSalePrice) - 1);
													
													IF @intSecond <= @strPriceEndingDigit
														BEGIN 
															SET @intSecond = @strPriceEndingDigit
														END
													ELSE 
														BEGIN
															SET @dblFirst = CONVERT(DECIMAL(38, 1), @dblFirst)  + .1;
															SET @intSecond = @strPriceEndingDigit
														END

													--Final value for Retail Price
													SET @dblRetailPriceConv = CONVERT(VARCHAR,@dblFirst) + CONVERT(VARCHAR, @intSecond)
												END
										END


										SET @dblRetailPriceConv = ROUND(@dblRetailPriceConv, 2)

										EXEC [uspICUpdateItemPricingForCStore]
											-- filter params
											@strUpcCode					= @strProcessLongUpcCode 
											,@strDescription			= @strProcessDescription 
											,@intItemId					= @intProcessItemId
											,@intItemPricingId			= @intProcessItemPricingId 
											,@strScreen					= 'RetailPriceAdjustment' 
											-- update params
											,@dblStandardCost			= NULL 
											,@dblRetailPrice			= @dblRetailPriceConv
											,@dblLastCost				= @dblLastCostConv
											,@dtmEffectiveDate			= @dtmEffectiveDateConv
											,@intEntityUserSecurityId	= @intCurrentUserId
			
										-- Check if Successfull
										IF EXISTS(SELECT TOP 1 1 FROM #tmpUpdateItemPricingForCStore_ItemPricingAuditLog WHERE intItemPricingId = @intProcessItemPricingId)
										BEGIN 
											SET @intSuccessPostCount = @intSuccessPostCount + 1
										END
										ELSE
										BEGIN
											SET @intFailedPostCount = @intFailedPostCount + 1
										END				

									END TRY
									BEGIN CATCH
										SET @ysnSuccess = CAST(0 AS BIT)
										SET @strMessage = 'uspICUpdateItemPricingForCStore: ' + ERROR_MESSAGE()
										GOTO ExitWithRollback
									END CATCH

									FETCH NEXT FROM @CursorTran INTO @intProcessItemId, @intProcessItemPricingId, @strProcessLongUpcCode, @strProcessDescription, @dblStandardCost, @dblSalePrice, @dblLastCost
								END
								
								CLOSE @CursorTran  
								DEALLOCATE @CursorTran

								-- Flag as processed
								DELETE FROM @tblRetailPriceAdjustmentDetailIds
								WHERE intRetailPriceAdjustmentDetailId = @intRetailPriceAdjustmentDetailId
							END
						
						IF(@intSuccessPostCount > 0)
							BEGIN
								
								SET @ysnSuccess = CAST(1 AS BIT)

								-- UPDATE tblRetailPriceAdjustment
								UPDATE rpa
									SET rpa.dtmPostedDate	= GETUTCDATE(),
										rpa.intEntityId		= @intCurrentUserId,
										rpa.ysnPosted		= CAST(1 AS BIT)
								FROM tblSTRetailPriceAdjustment rpa
								WHERE rpa.intRetailPriceAdjustmentId = @intRetailPriceAdjustmentId 
							END
						ELSE IF(@intFailedPostCount > 0 AND @intSuccessPostCount <= 0)
							BEGIN
								SET @ysnSuccess = CAST(0 AS BIT)
							END
						

					END
				ELSE
					BEGIN
						SET @ysnSuccess = CAST(0 AS BIT)
						SET @strMessage = 'There are no Retail Price Adjustment to process. Make sure that there is a record that is not yet Posted.'

						GOTO ExitWithRollback
					END


		
				
				-- ==============================================================================================
				-- [START] IF HAS PREVIEW REPORT
				-- ==============================================================================================
				IF(@ysnHasPreviewReport = CAST(1 AS BIT))
					BEGIN
						-- Handle preview using Table variable
						DECLARE @tblPreview TABLE 
						(
							intItemId					INT NULL
							, intItemUOMId				INT NULL
							, intItemLocationId			INT NULL
							, intItemPricingId			INT NULL
							, intCompanyLocationId		INT
							, dtmDateModified			DATETIME NOT NULL
						
							, strItemNo					NVARCHAR(150)
							, strItemDescription		NVARCHAR(250)
							, strLongUPCCode			NVARCHAR(50)
							, strLocationName			NVARCHAR(150)
							, strChangeDescription		NVARCHAR(100)
							, strPreviewOldData			NVARCHAR(MAX)
							, strPreviewNewData			NVARCHAR(MAX)
						)
			
						-- Generate Preview of records changes
						BEGIN
							INSERT INTO @tblPreview 
							(
								intItemId
								, intItemUOMId
								, intItemLocationId
								, intItemPricingId
								, intCompanyLocationId
								, dtmDateModified
							
								, strItemNo
								, strItemDescription
								, strLongUPCCode
								, strLocationName
								, strChangeDescription
								, strPreviewOldData
								, strPreviewNewData
							)
							SELECT	DISTINCT
									intItemId						= item.intItemId
									, intItemUOMId					= uom.intItemUOMId
									, intItemLocationId				= itemLoc.intItemLocationId
									, intItemPricingId				= itemPricing.intItemPricingId
									, intCompanyLocationId			= companyLoc.intCompanyLocationId
									, dtmDateModified				= itemPricing.dtmDateModified
							
									, strItemNo						= item.strItemNo
									, strItemDescription			= item.strDescription
									, strLongUPCCode				= uom.strLongUPCCode
									, strLocationName				= companyLoc.strLocationName
									, strChangeDescription			= CASE
																		WHEN [Changes].oldColumnName = 'strStandardCost_Original' THEN 'Standard Cost'
																		WHEN [Changes].oldColumnName = 'strSalePrice_Original' THEN 'Sale Price'
																		WHEN [Changes].oldColumnName = 'strLastCost_Original' THEN 'Last Cost'
																	END			
									, strPreviewOldData				= ISNULL([Changes].strOldData, '')
									, strPreviewNewData				= ISNULL([Changes].strNewData, '')
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
							INNER JOIN tblICItem item
								ON [Changes].intItemId = item.intItemId
							INNER JOIN tblICItemPricing itemPricing 
								ON [Changes].intItemPricingId = itemPricing.intItemPricingId
									AND [Changes].intItemId = itemPricing.intItemId
							INNER JOIN tblICItemLocation itemLoc 
								ON itemPricing.intItemLocationId = itemLoc.intItemLocationId 
									AND itemPricing.intItemId = itemLoc.intItemId
							INNER JOIN tblSMCompanyLocation companyLoc 
								ON itemLoc.intLocationId = companyLoc.intCompanyLocationId
							LEFT JOIN tblICItemUOM uom 
								ON itemPricing.intItemId = uom.intItemId
							WHERE uom.ysnStockUnit = CAST(1 AS BIT) 
						END


						-- Return Preview
						SELECT DISTINCT
								intItemId
								, intItemUOMId
								, intItemLocationId
								, intItemPricingId
								, intCompanyLocationId
								, dtmDateModified
						
								, strItemNo
								, strItemDescription
								, strLongUPCCode		AS strUpc
								, strLocationName		AS strLocation
								, strChangeDescription
								, strPreviewOldData		AS strOldData
								, strPreviewNewData		AS strNewData
						FROM @tblPreview
						WHERE strPreviewOldData != strPreviewNewData
						ORDER BY strItemNo, strLocationName ASC
					END
				-- ==============================================================================================
				-- [END] IF HAS PREVIEW REPORT
				-- ==============================================================================================
				


				-- Clean up 
				BEGIN
					IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_ItemPricingAuditLog') IS NOT NULL  
						DROP TABLE #tmpUpdateItemPricingForCStore_ItemPricingAuditLog 
						
					IF OBJECT_ID('tempdb..#tmpUpdateItemRetailForCStoreEffectiveDate_AuditLog') IS NOT NULL  
						DROP TABLE #tmpUpdateItemRetailForCStoreEffectiveDate_AuditLog 
						
					IF OBJECT_ID('tempdb..#tmpUpdateItemCostForCStoreEffectiveDate_AuditLog') IS NOT NULL  
						DROP TABLE #tmpUpdateItemCostForCStoreEffectiveDate_AuditLog 
				END


				IF(@ysnRecap = 0)
					BEGIN
						GOTO ExitWithCommit
					END
				ELSE
					BEGIN
						SET @ysnSuccess = CAST(1 AS BIT)
						SET @strMessage = 'Post Recap successfully.'

						GOTO ExitWithRollback
					END

			END
		ELSE
			BEGIN
				SET @ysnSuccess = CAST(0 AS BIT)
				SET @strMessage = 'No Posting to Inventory will be executed. No Retail Price Adjustment for this day.'

				GOTO ExitWithRollback
			END
		
	END TRY

	BEGIN CATCH
		SET @ysnSuccess = CAST(0 AS BIT)
		SET @strMessage = ERROR_MESSAGE()

		GOTO ExitWithRollback
	End CATCH
END




ExitWithCommit:
	IF @InitTranCount = 0
		BEGIN
			COMMIT TRANSACTION
		END

	GOTO ExitPost
	




ExitWithRollback:
		SET @ysnSuccess			= CAST(0 AS BIT)

		IF @InitTranCount = 0
			BEGIN
				IF ((XACT_STATE()) <> 0)
				BEGIN
					SET @strMessage = @strMessage + '. Will Rollback Transaction.'

					ROLLBACK TRANSACTION
				END
			END
			
		ELSE
			BEGIN
				IF ((XACT_STATE()) <> 0)
					BEGIN
						SET @strMessage = @strMessage + '. Will Rollback to Save point.'

						ROLLBACK TRANSACTION @Savepoint
					END
			END
			
				
	

		
ExitPost:
