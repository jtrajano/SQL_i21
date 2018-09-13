CREATE PROCEDURE [dbo].[uspSTUpdateRetailPriceAdjustment]
	@intRetailPriceAdjustmentId INT,
	@strPromoItemListDetailIds NVARCHAR(MAX),
	@intCurrentUserId INT,
	@strStatusMsg NVARCHAR(250) OUTPUT
AS
BEGIN
	BEGIN TRY

		-- ===========================================================================================================
		-- START Create the filter tables
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
		END
		-- END Create the filter tables
		-- ===========================================================================================================
		

		-- CREATE Temp Table
		DECLARE @tblRetailPriceAdjustmentDetailIds TABLE 
		(
			intRetailPriceAdjustmentDetailId INT, 
			ysnProcessed BIT
		)

		-- INSERT to Temp Table
		INSERT INTO @tblRetailPriceAdjustmentDetailIds
		SELECT CAST(Item AS INT), 0 
		FROM  dbo.fnSplitString(@strPromoItemListDetailIds, ',') 

		DECLARE @intLocationId INT
				, @intVendorId INT
				, @intCategoryId INT
				, @intFamilyId INT
				, @intClassId INT
				, @strUpcCode NVARCHAR(20)
				, @intItemId INT
		DECLARE @intRetailPriceAdjustmentDetailId INT
		DECLARE @intItemUOMId INT
		DECLARE @dblSalePrice DECIMAL(18,6)

		WHILE (SELECT Count(*) FROM @tblRetailPriceAdjustmentDetailIds WHERE ysnProcessed = 0) > 0
			BEGIN
			    
				SELECT TOP 1 @intRetailPriceAdjustmentDetailId = intRetailPriceAdjustmentDetailId 
				FROM @tblRetailPriceAdjustmentDetailIds 
				WHERE ysnProcessed = 0


				-- GET params
				SELECT @intLocationId = PAD.intCompanyLocationId
				       , @intVendorId = PAD.intEntityId
					   , @intCategoryId = PAD.intCategoryId
					   , @intFamilyId = PAD.intFamilyId
					   , @intClassId = PAD.intClassId
					   , @strUpcCode = CASE 
											WHEN ISNULL(UOM.strLongUPCCode, '') != ''
												THEN UOM.strLongUPCCode
											WHEN ISNULL(UOM.strUpcCode, '') != ''
												THEN UOM.strUpcCode
											ELSE NULL
									   END
				       , @intItemUOMId = UOM.intItemUOMId
					   , @dblSalePrice = PAD.dblPrice 
					   , @intItemId = UOM.intItemId
			    FROM tblSTRetailPriceAdjustmentDetail PAD
				JOIN tblICItemUOM UOM
					ON PAD.intItemUOMId = UOM.intItemUOMId
				WHERE intRetailPriceAdjustmentDetailId = @intRetailPriceAdjustmentDetailId

				-- ===============================================================================
				-- START Add the filter records
				BEGIN
					IF(@intLocationId IS NOT NULL)
						BEGIN
							INSERT INTO #tmpUpdateItemPricingForCStore_Location (
								intLocationId
							)
							VALUES(@intLocationId)
						END
		
					IF(@intVendorId IS NOT NULL)
						BEGIN
							INSERT INTO #tmpUpdateItemPricingForCStore_Vendor (
								intVendorId
							)
							VALUES(@intVendorId)
						END

					IF(@intCategoryId IS NOT NULL)
						BEGIN
							INSERT INTO #tmpUpdateItemPricingForCStore_Category (
								intCategoryId
							)
							VALUES(@intCategoryId)
						END

					IF(@intFamilyId IS NOT NULL)
						BEGIN
							INSERT INTO #tmpUpdateItemPricingForCStore_Family (
								intFamilyId
							)
							VALUES(@intFamilyId)
						END

					IF(@intClassId IS NOT NULL)
						BEGIN
							INSERT INTO #tmpUpdateItemPricingForCStore_Class (
								intClassId
							)
							VALUES(@intClassId)
						END
				END
				-- END Add the filter records
				-- ===============================================================================
				

				DECLARE @dblSalePriceConv AS NUMERIC(38, 20) = CAST(@dblSalePrice AS NUMERIC(38, 20))


				-- ITEM PRICING
				EXEC [uspICUpdateItemPricingForCStore]
					  @strUpcCode = @strUpcCode
					, @strDescription = NULL -- NOTE: Description cannot be '' or empty string, it should be NULL value instead of empty string
					, @intItemId = @intItemId
					, @dblStandardCost = NULL
					, @dblRetailPrice = @dblSalePriceConv
					, @intEntityUserSecurityId = @intCurrentUserId

				-- ===============================================================================
				-- CLEAR
				DELETE FROM #tmpUpdateItemPricingForCStore_Location
				DELETE FROM #tmpUpdateItemPricingForCStore_Vendor
				DELETE FROM #tmpUpdateItemPricingForCStore_Category
				DELETE FROM #tmpUpdateItemPricingForCStore_Family
				DELETE FROM #tmpUpdateItemPricingForCStore_Class
				-- ===============================================================================

				--IF((@intItemUOMId IS NOT NULL) AND (@intLocationId IS NOT NULL))
				--BEGIN
				--	--UPDATE IP
				--	--	SET IP.dblSalePrice = ISNULL(CAST(@dblSalePrice AS DECIMAL(18,6)), 0.000000)
				--	--FROM tblICItemLocation AS IL
				--	--JOIN tblICItemUOM AS UOM 
				--	--	ON UOM.intItemId = IL.intItemId
				--	--JOIN tblICItemPricing AS IP 
				--	--	ON IP.intItemLocationId = IL.intItemLocationId
				--	--WHERE UOM.intItemUOMId = @intItemUOMId
				--	--AND IL.intLocationId = @intLocationId
				--END



				-- Flag as processed
				UPDATE @tblRetailPriceAdjustmentDetailIds 
					SET ysnProcessed = 1 
				WHERE intRetailPriceAdjustmentDetailId = @intRetailPriceAdjustmentDetailId 
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

			IF OBJECT_ID('tempdb..#tmpUpdateItemPricingForCStore_ItemPricingAuditLog') IS NOT NULL  
				DROP TABLE #tmpUpdateItemPricingForCStore_ItemPricingAuditLog 
		END

		SET @strStatusMsg = 'Success'
	END TRY

	BEGIN CATCH
		SET @strStatusMsg = ERROR_MESSAGE()
	End CATCH
END