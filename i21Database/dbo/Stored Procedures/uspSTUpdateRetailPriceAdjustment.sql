CREATE PROCEDURE [dbo].[uspSTUpdateRetailPriceAdjustment]
@intRetailPriceAdjustmentId INT,
@strPromoItemListDetailIds NVARCHAR(MAX),
@strStatusMsg NVARCHAR(250) OUTPUT
AS
BEGIN
	BEGIN TRY
		-- CREATE Temp Table
		DECLARE @tblRetailPriceAdjustmentDetailIds TABLE (intRetailPriceAdjustmentDetailId INT, ysnProcessed BIT)

		-- INSERT to Temp Table
		INSERT INTO @tblRetailPriceAdjustmentDetailIds
		SELECT CAST(Item AS INT), 0 
		FROM  dbo.fnSplitString(@strPromoItemListDetailIds, ',') 

		DECLARE @intRetailPriceAdjustmentDetailId int
		DECLARE @intItemUOMId int
		DECLARE @intLocationId int
		DECLARE @dblSalePrice DECIMAL(18,6)

		WHILE (SELECT Count(*) FROM @tblRetailPriceAdjustmentDetailIds WHERE ysnProcessed = 0) > 0
		BEGIN
			SELECT TOP 1 @intRetailPriceAdjustmentDetailId = intRetailPriceAdjustmentDetailId FROM @tblRetailPriceAdjustmentDetailIds WHERE ysnProcessed = 0

			SELECT @intItemUOMId = intItemUOMId, @intLocationId = intCompanyLocationId, @dblSalePrice = dblPrice FROM tblSTRetailPriceAdjustmentDetail WHERE intRetailPriceAdjustmentDetailId = @intRetailPriceAdjustmentDetailId

			IF((@intItemUOMId IS NOT NULL) AND (@intLocationId IS NOT NULL))
			BEGIN
				UPDATE IP
					SET IP.dblSalePrice = ISNULL(CAST(@dblSalePrice AS DECIMAL(18,6)), 0.000000)
				FROM tblICItemLocation AS IL
				JOIN tblICItemUOM AS UOM ON UOM.intItemId = IL.intItemId
				JOIN tblICItemPricing AS IP ON IP.intItemLocationId = IL.intItemLocationId
				WHERE UOM.intItemUOMId = @intItemUOMId
				AND IL.intLocationId = @intLocationId
			END

			Update @tblRetailPriceAdjustmentDetailIds Set ysnProcessed = 1 Where intRetailPriceAdjustmentDetailId = @intRetailPriceAdjustmentDetailId 
		END
		
		SET @strStatusMsg = 'Success'
	END TRY

	BEGIN CATCH
		SET @strStatusMsg = ERROR_MESSAGE()
	End CATCH
END