CREATE PROCEDURE [dbo].[uspSTUpdateRetailPriceAdjustment]
	@intRetailPriceAdjustmentId		INT,
	@intCurrentUserId				INT,
	@ysnSuccess						BIT				OUTPUT,
	@strMessage						NVARCHAR(1000)	OUTPUT
AS
BEGIN
	BEGIN TRY
		
		SET @ysnSuccess = CAST(1 AS BIT)
		SET @strMessage = ''

		IF EXISTS(SELECT TOP 1 1 FROM tblSTRetailPriceAdjustment WHERE CAST(dtmEffectiveDate AS DATE) = CAST(GETDATE() AS DATE))
			BEGIN
				
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
					intRetailPriceAdjustmentDetailId INT
				)



				-- INSERT to Temp Table
				INSERT INTO @tblRetailPriceAdjustmentDetailIds
				(
					intRetailPriceAdjustmentDetailId
					--ysnProcessed
				)
				SELECT 
					intRetailPriceAdjustmentDetailId	= pad.intRetailPriceAdjustmentDetailId 
					--ysnProcessed = CAST(0 AS BIT)
				FROM tblSTRetailPriceAdjustmentDetail pad
				INNER JOIN dbo.tblSTRetailPriceAdjustment rpa
					ON pad.intRetailPriceAdjustmentId = rpa.intRetailPriceAdjustmentId
				WHERE pad.intRetailPriceAdjustmentId = @intRetailPriceAdjustmentId
					AND pad.ysnPosted = CAST(0 AS BIT)

				--TEST
				SELECT '@tblRetailPriceAdjustmentDetailIds', * FROM @tblRetailPriceAdjustmentDetailIds

				IF EXISTS(SELECT TOP 1 1 FROM @tblRetailPriceAdjustmentDetailIds)
					BEGIN

						DECLARE @intLocationId						INT
							, @intVendorId							INT
							, @intCategoryId						INT
							, @intFamilyId							INT
							, @intClassId							INT
							, @strUpcCode							NVARCHAR(20)
							, @intItemId							INT
							, @intRecordCount						INT
							, @strDescription						NVARCHAR(250)
							, @intItemPricingId						INT
							, @intRetailPriceAdjustmentDetailId		INT
							, @intItemUOMId							INT
							, @dblRetailPrice						DECIMAL(18,6)
							, @dblLastCost							DECIMAL(18,6)


						WHILE EXISTS(SELECT TOP 1 1 FROM @tblRetailPriceAdjustmentDetailIds)
							BEGIN
								
								-- Get Primary Id
								SELECT TOP 1 
									@intRetailPriceAdjustmentDetailId = intRetailPriceAdjustmentDetailId 
								FROM @tblRetailPriceAdjustmentDetailIds 

								SELECT TOP 1 'LOOP', * FROM @tblRetailPriceAdjustmentDetailIds 

								-- GET params
								SELECT TOP 1
										 --@intRetailPriceAdjustmentDetailId  = PAD.intRetailPriceAdjustmentDetailId
									   @intLocationId						= PAD.intCompanyLocationId
									   , @intVendorId						= PAD.intEntityId
									   , @intCategoryId						= PAD.intCategoryId
									   , @intFamilyId						= PAD.intFamilyId
									   , @intClassId						= PAD.intClassId
									   , @strUpcCode						= CASE 
																				WHEN ISNULL(UOM.strLongUPCCode, '') != ''
																					THEN UOM.strLongUPCCode
																				WHEN ISNULL(UOM.strUpcCode, '') != ''
																					THEN UOM.strUpcCode
																				ELSE NULL
																		   END
									   , @intItemUOMId						= UOM.intItemUOMId
									   , @dblRetailPrice					= PAD.dblPrice 
									   , @dblLastCost						= PAD.dblLastCost
									   , @intItemId							= UOM.intItemId
									   , @strDescription					= I.strDescription
									   , @intItemPricingId					= itemPricing.intItemPricingId
								FROM tblSTRetailPriceAdjustmentDetail PAD
								INNER JOIN @tblRetailPriceAdjustmentDetailIds temp
									ON PAD.intRetailPriceAdjustmentDetailId = temp.intRetailPriceAdjustmentDetailId
								INNER JOIN tblICItemUOM UOM
									ON PAD.intItemUOMId = UOM.intItemUOMId
								INNER JOIN tblICItem I
									ON UOM.intItemId = I.intItemId
								INNER JOIN tblICItemLocation itemLoc
									ON I.intItemId = itemLoc.intItemId
										AND PAD.intCompanyLocationId = itemLoc.intLocationId
								INNER JOIN tblICItemPricing itemPricing
									ON I.intItemId	= itemPricing.intItemId
										AND itemLoc.intItemLocationId = itemPricing.intItemLocationId
								WHERE PAD.intRetailPriceAdjustmentDetailId = @intRetailPriceAdjustmentDetailId

				

								DECLARE @dblRetailPriceConv AS NUMERIC(38, 20) = CAST(@dblRetailPrice AS NUMERIC(38, 20))
								DECLARE @dblLastCostConv AS NUMERIC(38, 20) = CAST(@dblLastCost AS NUMERIC(38, 20))

								-- ITEM PRICING
								BEGIN TRY
									EXEC [uspICUpdateItemPricingForCStore]
										-- filter params
										@strUpcCode					= @strUpcCode 
										,@strDescription			= @strDescription 
										,@intItemId					= @intItemId 
										,@intItemPricingId			= @intItemPricingId 
										-- update params
										,@dblStandardCost			= NULL 
										,@dblRetailPrice			= @dblRetailPriceConv 
										,@dblLastCost				= @dblLastCostConv
										,@intEntityUserSecurityId	= @intCurrentUserId

								-- TEST
								SELECT '@intItemPricingId', * FROM tblICItemPricing WHERE intItemPricingId = @intItemPricingId
								SELECT '#tmpUpdateItemPricingForCStore_ItemPricingAuditLog', * FROM #tmpUpdateItemPricingForCStore_ItemPricingAuditLog

								-- Check if Successfull
								IF EXISTS(SELECT TOP 1 1 FROM #tmpUpdateItemPricingForCStore_ItemPricingAuditLog WHERE intItemPricingId = @intItemPricingId)
									BEGIN 

										UPDATE tblSTRetailPriceAdjustmentDetail
										SET ysnPosted = 1
										WHERE intRetailPriceAdjustmentDetailId = @intRetailPriceAdjustmentDetailId

									END
								END TRY
								BEGIN CATCH
									SET @ysnSuccess = CAST(0 AS BIT)
									SET @strMessage = 'uspICUpdateItemPricingForCStore: ' + ERROR_MESSAGE()
								END CATCH

								-- Flag as processed
								DELETE FROM @tblRetailPriceAdjustmentDetailIds
								WHERE intRetailPriceAdjustmentDetailId = @intRetailPriceAdjustmentDetailId
							END
					END
				ELSE
					BEGIN
						SET @ysnSuccess = CAST(0 AS BIT)
						SET @strMessage = 'There are no Retail Price Adjustment to process. Make sure that there is a record that is not yet Posted.'
					END


		
		

				-- Clean up 
				BEGIN
					IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_ItemPricingAuditLog') IS NOT NULL  
						DROP TABLE #tmpUpdateItemPricingForCStore_ItemPricingAuditLog 
				END

				SET @ysnSuccess = CAST(1 AS BIT)
				SET @strMessage = 'Success'
			END
		ELSE
			BEGIN
				SET @ysnSuccess = CAST(0 AS BIT)
				SET @strMessage = 'No Posting to Inventory will be executed. No Retail Price Adjustment for this day.'
			END
		
	END TRY

	BEGIN CATCH
		SET @ysnSuccess = CAST(0 AS BIT)
		SET @strMessage = ERROR_MESSAGE()
	End CATCH
END