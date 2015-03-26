IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE name = 'intDimensionUOMId' AND object_id = object_id('tblICItem'))
BEGIN
	IF EXISTS(SELECT TOP 1 1 FROM sys.columns WHERE name = 'intUnitMeasureId' AND object_id = object_id('tblICUnitMeasure'))
	BEGIN
		EXEC('UPDATE tblICItem
			SET intDimensionUOMId = NULL
			WHERE intDimensionUOMId NOT IN (SELECT intUnitMeasureId FROM tblICUnitMeasure)')
	END
END

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE name = 'intWeightUOMId' AND object_id = object_id('tblICItem'))
BEGIN
	IF EXISTS(SELECT TOP 1 1 FROM sys.columns WHERE name = 'intUnitMeasureId' AND object_id = object_id('tblICUnitMeasure'))
	BEGIN
		EXEC('UPDATE tblICItem
		SET intWeightUOMId = NULL
		WHERE intWeightUOMId NOT IN (SELECT intUnitMeasureId FROM tblICUnitMeasure)')
	END
END

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE name = 'intUnitMeasureId' AND object_id = object_id('tblICItemPricingLevel'))
BEGIN
	IF EXISTS(SELECT TOP 1 1 FROM sys.columns WHERE name = 'intItemUOMId' AND object_id = object_id('tblICItemUOM'))
	BEGIN
		EXEC('UPDATE tblICItemPricingLevel
		SET intUnitMeasureId = NULL
		WHERE intUnitMeasureId NOT IN (SELECT intItemUOMId FROM tblICItemUOM)')
	END
END

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE name = 'intUnitMeasureId' AND object_id = object_id('tblICItemSpecialPricing'))
BEGIN
	IF EXISTS(SELECT TOP 1 1 FROM sys.columns WHERE name = 'intItemUOMId' AND object_id = object_id('tblICItemUOM'))
	BEGIN
		EXEC('UPDATE tblICItemSpecialPricing
		SET intUnitMeasureId = NULL
		WHERE intUnitMeasureId NOT IN (SELECT intItemUOMId FROM tblICItemUOM)')
	END
END

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE name = 'strAccountDescription' AND object_id = object_id('tblICItemAccount'))
BEGIN
	IF EXISTS(SELECT TOP 1 1 FROM sys.columns WHERE name = 'strAccountCategory' AND object_id = object_id('tblGLAccountCategory'))
	BEGIN
		EXEC('
		DELETE FROM tblICItemAccount
		WHERE strAccountDescription NOT IN (SELECT strAccountCategory FROM tblGLAccountCategory)
		')
	END
END

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE name = 'strAccountDescription' AND object_id = object_id('tblICCategoryAccount'))
BEGIN
	IF EXISTS(SELECT TOP 1 1 FROM sys.columns WHERE name = 'strAccountCategory' AND object_id = object_id('tblGLAccountCategory'))
	BEGIN
		EXEC('
		DELETE FROM tblICItemAccount
		WHERE strAccountDescription NOT IN (SELECT strAccountCategory FROM tblGLAccountCategory)
		')
	END
END

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE name = 'strAccountDescription' AND object_id = object_id('tblICItemAccount'))
BEGIN
	IF EXISTS(SELECT TOP 1 1 FROM sys.columns WHERE name = 'strAccountCategory' AND object_id = object_id('tblGLAccountCategory'))
	BEGIN
		EXEC('
		UPDATE tblICItemAccount
		SET strAccountDescription = (SELECT intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = tblICItemAccount.strAccountDescription)
		')
	END
END

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE name = 'strAccountDescription' AND object_id = object_id('tblICCategoryAccount'))
BEGIN
	IF EXISTS(SELECT TOP 1 1 FROM sys.columns WHERE name = 'strAccountCategory' AND object_id = object_id('tblGLAccountCategory'))
	BEGIN
		EXEC('
		UPDATE tblICCategoryAccount
		SET strAccountDescription = (SELECT intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = tblICCategoryAccount.strAccountDescription)
		')
	END
END

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE name = 'intPackTypeId' AND object_id = object_id('tblICInventoryReceiptItem'))
BEGIN
	IF EXISTS(SELECT TOP 1 1 FROM sys.columns WHERE name = 'strUnitType' AND object_id = object_id('tblICUnitMeasure'))
	BEGIN
		EXEC('
		UPDATE tblICInventoryReceiptItem
		SET intPackTypeId = (SELECT ISNULL(intUnitMeasureId,NULL) FROM tblICUnitMeasure WHERE strUnitType = ''Packed'' AND intUnitMeasureId = tblICInventoryReceiptItem.intPackTypeId)
		')
	END
END

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE name = 'intItemLocationId' AND object_id = object_id('tblICItemLocation'))
BEGIN
	EXEC ('
	SELECT intItemId, intLocationId INTO #tmpItemLocations FROM tblICItemLocation GROUP BY intItemId, intLocationId HAVING COUNT(*) > 1
	IF EXISTS(SELECT TOP 1 1 FROM #tmpItemLocations)
	BEGIN

		DECLARE @intLocationId INT
		DECLARE @intItemId INT
		DECLARE @intItemLocationId INT
		SELECT TOP 1 @intItemId = intItemId, @intLocationId = intLocationId FROM #tmpItemLocations
		SELECT intItemLocationId INTO #DeleteLocations FROM tblICItemLocation WHERE intItemId = @intItemId AND intLocationId = @intLocationId
		SELECT TOP 1 @intItemLocationId = intItemLocationId FROM tblICItemLocation
		WHILE EXISTS(SELECT TOP 2 1 FROM #DeleteLocations)
		BEGIN
			BEGIN TRY
				DELETE FROM tblICItemLocation WHERE intItemLocationId = @intItemLocationId
			END TRY
			BEGIN CATCH
			END CATCH
			DELETE FROM #DeleteLocations WHERE intItemLocationId = @intItemLocationId
			SELECT TOP 1 @intItemLocationId = intItemLocationId FROM #DeleteLocations
		END
		DROP TABLE #DeleteLocations
	END
	DROP TABLE #tmpItemLocations')
END

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE name = 'intCategoryLocationId' AND object_id = object_id('tblICCategoryLocation'))
BEGIN
	EXEC ('
	SELECT intCategoryId, intLocationId INTO #tmpCategoryLocations FROM tblICCategoryLocation GROUP BY intCategoryId, intLocationId HAVING COUNT(*) > 1
	IF EXISTS(SELECT TOP 1 1 FROM #tmpCategoryLocations)
	BEGIN

		DECLARE @intLocationId INT
		DECLARE @intCategoryId INT
		DECLARE @intCategoryLocationId INT
		SELECT TOP 1 @intCategoryId = intCategoryId, @intLocationId = intLocationId FROM #tmpCategoryLocations
		SELECT intCategoryLocationId INTO #DeleteLocations FROM tblICCategoryLocation WHERE intCategoryId = @intCategoryId AND intLocationId = @intLocationId
		SELECT TOP 1 @intCategoryLocationId = intCategoryLocationId FROM tblICCategoryLocation
		WHILE EXISTS(SELECT TOP 2 1 FROM #DeleteLocations)
		BEGIN
			BEGIN TRY
				DELETE FROM tblICCategoryLocation WHERE intCategoryLocationId = @intCategoryLocationId
			END TRY
			BEGIN CATCH
			END CATCH
			DELETE FROM #DeleteLocations WHERE intCategoryLocationId = @intCategoryLocationId
			SELECT TOP 1 @intCategoryLocationId = intCategoryLocationId FROM #DeleteLocations
		END
		DROP TABLE #DeleteLocations
	END
	DROP TABLE #tmpCategoryLocations')
END

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE name = 'intItemLocationId' AND object_id = object_id('tblICItemPricing'))
BEGIN
	EXEC ('
	SELECT intItemId, intItemLocationId INTO #tmpItemPricing FROM tblICItemPricing GROUP BY intItemId, intItemLocationId HAVING COUNT(*) > 1
	IF EXISTS(SELECT TOP 1 1 FROM #tmpItemPricing)
	BEGIN

		DECLARE @intLocationId INT
		DECLARE @intItemId INT
		DECLARE @intItemPricingId INT
		SELECT TOP 1 @intItemId = intItemId, @intLocationId = intItemLocationId FROM #tmpItemPricing
		SELECT intItemPricingId INTO #DeletePricing FROM tblICItemPricing WHERE intItemId = @intItemId AND intItemLocationId = @intLocationId
		SELECT TOP 1 @intItemPricingId = intItemPricingId FROM tblICItemPricing
		WHILE EXISTS(SELECT TOP 2 1 FROM #DeletePricing)
		BEGIN
			BEGIN TRY
				DELETE FROM tblICItemPricing WHERE intItemPricingId = @intItemPricingId
			END TRY
			BEGIN CATCH
			END CATCH
			DELETE FROM #DeletePricing WHERE intItemPricingId = @intItemPricingId
			SELECT TOP 1 @intItemPricingId = intItemPricingId FROM #DeletePricing
		END
		DROP TABLE #DeletePricing
	END
	DROP TABLE #tmpItemPricing')
END

IF EXISTS(SELECT TOP 1 1 FROM sys.columns WHERE name = 'intWeightUOMId' AND object_id = OBJECT_ID('tblICInventoryReceiptItemLot'))
BEGIN
EXEC ('

	DECLARE @ReceiptNumber NVARCHAR(50) = '''',
	@ItemNo NVARCHAR(50) = ''''

	SELECT TOP 1 
		@ReceiptNumber = Receipt.strReceiptNumber,
		@ItemNo = Item.strItemNo
	FROM (
		SELECT intInventoryReceiptItemId, COUNT(*) intCount
		FROM tblICInventoryReceiptItemLot
		WHERE ISNULL(intWeightUOMId, 0) <> 0
		GROUP BY intInventoryReceiptItemId
	) LotCount
	LEFT JOIN (
		SELECT intInventoryReceiptItemId, intWeightUOMId, COUNT(*) intWeightCount
		FROM tblICInventoryReceiptItemLot
		WHERE ISNULL(intWeightUOMId, 0) <> 0
		GROUP BY intInventoryReceiptItemId, intWeightUOMId
	) LotWeightCount ON LotCount.intInventoryReceiptItemId = LotWeightCount.intInventoryReceiptItemId
	LEFT JOIN tblICInventoryReceiptItem ReceiptItem ON ReceiptItem.intInventoryReceiptItemId = LotWeightCount.intInventoryReceiptItemId
	LEFT JOIN tblICItem Item ON Item.intItemId = ReceiptItem.intItemId
	LEFT JOIN tblICInventoryReceipt Receipt ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
	WHERE intCount <> intWeightCount
	IF (ISNULL(@ReceiptNumber, '''') <> '''')
	BEGIN
		DECLARE @msg NVARCHAR(MAX) = '''';
		SET @msg = ''Receipt number '' + @ReceiptNumber + '' with Item number '' + @ItemNo + '' should have the same Weight UOMs all throughout its lots!'';
		THROW 50000, @msg, 1
		RETURN
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM sys.columns WHERE name = ''intWeightUOMId'' AND object_id = OBJECT_ID(''tblICInventoryReceiptItem''))
	BEGIN
		ALTER TABLE tblICInventoryReceiptItem
		ADD intWeightUOMId INT NULL
	END	
	')

	EXEC ('
		UPDATE tblICInventoryReceiptItem
		SET tblICInventoryReceiptItem.intWeightUOMId = tblPatch.intWeightUOMId
		FROM (
			SELECT DISTINCT intInventoryReceiptItemId, intWeightUOMId
			FROM tblICInventoryReceiptItemLot
			WHERE ISNULL(intWeightUOMId, 0) <> 0) tblPatch
			WHERE tblPatch.intInventoryReceiptItemId = tblICInventoryReceiptItem.intInventoryReceiptItemId	
	')
END