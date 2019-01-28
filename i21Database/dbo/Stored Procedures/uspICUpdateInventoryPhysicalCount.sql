CREATE PROCEDURE [dbo].[uspICUpdateInventoryPhysicalCount]
	@strCountNo NVARCHAR(50),
	@dblPhysicalCount NUMERIC(18,6),
	@intPhysicalCountUOMId INT,
	@intLotId INT,
	@intUserSecurityId INT,
	@intItemId INT = NULL,
	@intItemLocationId INT = NULL,
	@intStorageLocationId INT = NULL,
	@intStorageUnitId INT = NULL
AS

DECLARE @intInventoryCountId INT
DECLARE @ysnPosted BIT
DECLARE @ysnCountByLots BIT
DECLARE @msg NVARCHAR(600)
DECLARE @intLocationId INT

SELECT
	  @intInventoryCountId = intInventoryCountId
	, @ysnPosted = ysnPosted
	, @ysnCountByLots = ISNULL(ysnCountByLots, 0)
	, @intLocationId = intLocationId
FROM tblICInventoryCount 
WHERE strCountNo = @strCountNo

IF @intInventoryCountId IS NOT NULL AND @ysnPosted = 0
BEGIN
	DECLARE @strCountLine NVARCHAR(50)
	SELECT @strCountLine = @strCountNo + '-' + CAST(COUNT(*) + 1 AS NVARCHAR(50)) FROM tblICInventoryCountDetail WHERE intInventoryCountId = @intInventoryCountId
	DECLARE @intDefaultGrossUOMId INT

	IF(@ysnCountByLots = 1)
	BEGIN
		IF(@intLotId IS NULL)
		BEGIN
			SET @msg = 'Inventory Count "' + @strCountNo + '" needs a lot id.'
			RAISERROR(@msg, 11, 1)
			GOTO _Exit
		END

		IF EXISTS(SELECT * FROM tblICInventoryCountDetail WHERE intInventoryCountId = @intInventoryCountId AND intLotId = @intLotId)
		BEGIN
			DECLARE @ysnLotWeightsRequired BIT
			SELECT 
				  @intItemId = cd.intItemId
				, @ysnLotWeightsRequired = i.ysnLotWeightsRequired
			FROM tblICInventoryCountDetail cd
				INNER JOIN tblICItem i ON i.intItemId = cd.intItemId
			WHERE cd.intInventoryCountId = @intInventoryCountId
				AND cd.intLotId = @intLotId

			IF NOT EXISTS(SELECT u.strUnitMeasure, u.strUnitType
				FROM tblICItemUOM i
					INNER JOIN tblICUnitMeasure u ON u.intUnitMeasureId = i.intUnitMeasureId
				WHERE i.intItemId = @intItemId
					AND u.strUnitType = 'Weight') AND @intPhysicalCountUOMId IS NOT NULL
			BEGIN
				SET @msg = 'Invalid Gross/Net UOM Id provided.'
				RAISERROR(@msg, 11, 1)
				GOTO _Exit
			END

			IF @ysnLotWeightsRequired = 1 
				AND NOT EXISTS(
					SELECT u.strUnitMeasure, u.strUnitType
					FROM tblICItemUOM i
						INNER JOIN tblICUnitMeasure u ON u.intUnitMeasureId = i.intUnitMeasureId
					WHERE i.intItemId = @intItemId
						AND i.intItemUOMId = @intPhysicalCountUOMId
						AND u.strUnitType = 'Weight') 
				AND @intPhysicalCountUOMId IS NOT NULL
			BEGIN
				SET @msg = 'Invalid Gross/Net UOM Id provided.'
				RAISERROR(@msg, 11, 1)
				GOTO _Exit
			END

			UPDATE tblICInventoryCountDetail
			SET
					dblPhysicalCount = @dblPhysicalCount
				, intWeightUOMId = CASE WHEN @intPhysicalCountUOMId IS NULL THEN intWeightUOMId ELSE @intPhysicalCountUOMId END
				, dblWeightQty = CASE WHEN @intPhysicalCountUOMId IS NULL THEN dblWeightQty ELSE dbo.fnCalculateQtyBetweenUOM(intItemUOMId, @intPhysicalCountUOMId, @dblPhysicalCount) END
				, dblNetQty = CASE WHEN @intPhysicalCountUOMId IS NULL THEN dblWeightQty ELSE dbo.fnCalculateQtyBetweenUOM(intItemUOMId, @intPhysicalCountUOMId, @dblPhysicalCount) END
				, intEntityUserSecurityId = @intUserSecurityId
				, dtmDateModified = GETDATE()
				, intModifiedByUserId = @intUserSecurityId
			WHERE intLotId = @intLotId
				AND intInventoryCountId = @intInventoryCountId
		END
		ELSE
		BEGIN
			SELECT @intItemId = intItemId
			FROM tblICLot
			WHERE intLotId = @intLotId

			SELECT TOP 1 @intDefaultGrossUOMId = i.intItemUOMId
			FROM tblICItemUOM i
				INNER JOIN tblICUnitMeasure u ON u.intUnitMeasureId = i.intUnitMeasureId
			WHERE i.intItemId = @intItemId
				AND u.strUnitType = 'Weight'
			ORDER BY i.ysnStockUnit DESC

			IF NOT EXISTS(SELECT * FROM tblICLot WHERE intLotId = @intLotId)
			BEGIN
				SET @msg = 'Lot id does not exists. Inventory Count "' + @strCountNo + '" needs a lot id.'
				RAISERROR(@msg, 11, 1)
				GOTO _Exit	
			END

			IF NOT EXISTS(SELECT u.strUnitMeasure, u.strUnitType
				FROM tblICItemUOM i
					INNER JOIN tblICUnitMeasure u ON u.intUnitMeasureId = i.intUnitMeasureId
				WHERE i.intItemId = @intItemId
					AND u.strUnitType = 'Weight') AND @intPhysicalCountUOMId IS NOT NULL
			BEGIN
				SET @msg = 'Invalid Physical Count UOM Id provided.'
				RAISERROR(@msg, 11, 1)
				GOTO _Exit
			END

			INSERT INTO tblICInventoryCountDetail (
					intInventoryCountId
				, intItemId
				, intItemLocationId
				, intSubLocationId
				, intStorageLocationId
				, intLotId
				, strLotNo
				, strLotAlias
				, intParentLotId
				, strParentLotNo
				, strParentLotAlias
				, intEntityUserSecurityId
				, dblPhysicalCount
				, intItemUOMId
				, intWeightUOMId
				, dblWeightQty
				, dblNetQty
				, intConcurrencyId
				, dtmDateCreated
				, intCreatedByUserId
				, strCountLine
				, intStockUOMId
			)
			SELECT
				  intInventoryCountId = @intInventoryCountId
				, intItemId = lot.intItemId
				, intItemLocationId = lot.intItemLocationId
				, intSubLocationId = lot.intSubLocationId
				, intStorageLocationId = lot.intStorageLocationId
				, intLotId = lot.intLotId
				, strLotNo = lot.strLotNumber
				, strLotAlias = lot.strLotAlias
				, intParentLotId = pLot.intParentLotId
				, strParentLotNo = pLot.strParentLotNumber
				, strParentLotAlias = pLot.strParentLotAlias
				, intEntityUserSecurityId = @intUserSecurityId
				, dblPhysicalCount = @dblPhysicalCount
				, intItemUOMId = lot.intItemUOMId
				, intWeightUOMId = CASE WHEN lot.intWeightUOMId IS NOT NULL THEN lot.intWeightUOMId ELSE @intDefaultGrossUOMId END
				, dblWeightQty = CASE WHEN lot.intWeightUOMId IS NOT NULL 
					THEN lot.dblWeight 
					ELSE dbo.fnCalculateQtyBetweenUOM(
						CASE WHEN @intPhysicalCountUOMId IS NULL 
							THEN lot.intItemUOMId 
							ELSE @intPhysicalCountUOMId
						END, @intDefaultGrossUOMId, @dblPhysicalCount)
					END
				, dblNetQty = CASE WHEN lot.intWeightUOMId IS NOT NULL 
					THEN lot.dblWeight 
					ELSE dbo.fnCalculateQtyBetweenUOM(
						CASE WHEN @intPhysicalCountUOMId IS NULL 
							THEN lot.intItemUOMId 
							ELSE @intPhysicalCountUOMId
						END, @intDefaultGrossUOMId, @dblPhysicalCount)
					END
				, intConcurrencyId = 1
				, dtmDateCreated = GETDATE()
				, intCreatedByUserId = @intUserSecurityId
				, strCountLine = @strCountLine
				, intStockUOMId = stockUOM.intItemUOMId
			FROM tblICLot lot
				LEFT JOIN tblICItemStockUOM stockUOM ON stockUOM.intItemId = lot.intItemId
					AND stockUOM.intStorageLocationId = lot.intStorageLocationId
					AND stockUOM.intSubLocationId = lot.intSubLocationId
					AND stockUOM.intItemLocationId = lot.intItemLocationId
				LEFT OUTER JOIN tblICParentLot pLot ON lot.intParentLotId = pLot.intParentLotId
			WHERE lot.intLotId = @intLotId	
		END
	END
	ELSE -- Non-lotted Item
	BEGIN
		IF EXISTS(
			SELECT TOP 1 1 
			FROM tblICInventoryCountDetail 
			WHERE intInventoryCountId = @intInventoryCountId 
				AND intItemId = @intItemId 
				AND intItemLocationId = intItemLocationId
				AND (intSubLocationId = @intStorageLocationId OR @intStorageLocationId IS NULL)
				AND (intStorageLocationId = @intStorageUnitId OR @intStorageUnitId IS NULL)
			)
		BEGIN
			IF NOT EXISTS(
				SELECT TOP 1 1
				FROM tblICInventoryCountDetail cd
					INNER JOIN tblICItem i ON i.intItemId = cd.intItemId
				WHERE cd.intInventoryCountId = @intInventoryCountId
					AND cd.intItemId = @intItemId
					AND cd.intItemLocationId = @intItemLocationId
					AND (cd.intSubLocationId = @intStorageLocationId OR @intStorageLocationId IS NULL)
					AND (cd.intStorageLocationId = @intStorageUnitId OR @intStorageUnitId IS NULL)
			)
			BEGIN
				SET @msg = 'Invalid item. Possible reason(s): (1) the item id is invalid. (2) the item id might not have a reference to the item location id (3) the item location id doesn''t have a reference to the Count''s Location'
				RAISERROR(@msg, 11, 1)	
				GOTO _Exit
			END
			
			SELECT 
				@ysnLotWeightsRequired = i.ysnLotWeightsRequired
			FROM tblICInventoryCountDetail cd
				INNER JOIN tblICItem i ON i.intItemId = cd.intItemId
			WHERE cd.intInventoryCountId = @intInventoryCountId
				AND cd.intItemId = @intItemId
				AND cd.intItemLocationId = @intItemLocationId
				AND (cd.intSubLocationId = @intStorageLocationId OR @intStorageLocationId IS NULL)
				AND (cd.intStorageLocationId = @intStorageUnitId OR @intStorageUnitId IS NULL)
		
			IF NOT EXISTS(SELECT u.strUnitMeasure, u.strUnitType
				FROM tblICItemUOM i
					INNER JOIN tblICUnitMeasure u ON u.intUnitMeasureId = i.intUnitMeasureId
				WHERE i.intItemId = @intItemId AND i.intItemUOMId = @intPhysicalCountUOMId) AND @intPhysicalCountUOMId IS NOT NULL
			BEGIN
				SET @msg = 'Invalid Count UOM Id provided.'
				RAISERROR(@msg, 11, 1)
				GOTO _Exit
			END
			
			--IF @ysnLotWeightsRequired = 1 
			--	AND NOT EXISTS(
			--		SELECT u.strUnitMeasure, u.strUnitType
			--		FROM tblICItemUOM i
			--			INNER JOIN tblICUnitMeasure u ON u.intUnitMeasureId = i.intUnitMeasureId
			--		WHERE i.intItemId = @intItemId
			--			AND i.intItemUOMId = @intPhysicalCountUOMId
			--			AND u.strUnitType = 'Weight') 
			--	AND @intPhysicalCountUOMId IS NOT NULL
			--BEGIN
			--	SET @msg = 'Invalid Gross/Net UOM Id provided.'
			--	RAISERROR(@msg, 11, 1)
			--	GOTO _Exit
			--END

			IF @intStorageLocationId IS NULL AND @intStorageUnitId IS NULL AND NOT EXISTS(
				SELECT TOP 1 1
				FROM tblICInventoryCountDetail cd
					INNER JOIN tblICItem i ON i.intItemId = cd.intItemId
					INNER JOIN tblICItemLocation il ON il.intItemId = cd.intItemId
				WHERE cd.intInventoryCountId = @intInventoryCountId
					AND cd.intItemId = @intItemId
					AND cd.intItemLocationId = @intItemLocationId
					AND (cd.intSubLocationId IS NULL)
					AND (cd.intStorageLocationId IS NULL)
					AND il.intLocationId = @intLocationId
			)
			BEGIN
				SELECT TOP 1 @intDefaultGrossUOMId = i.intItemUOMId
				FROM tblICItemUOM i
					INNER JOIN tblICUnitMeasure u ON u.intUnitMeasureId = i.intUnitMeasureId
				WHERE i.intItemId = @intItemId
					AND u.strUnitType = 'Weight'
				ORDER BY i.ysnStockUnit DESC

				INSERT INTO tblICInventoryCountDetail (
					intInventoryCountId
					, intItemId
					, intItemLocationId
					, intSubLocationId
					, intStorageLocationId
					, intEntityUserSecurityId
					, dblPhysicalCount
					, intItemUOMId
					--, intWeightUOMId
					--, dblWeightQty
					--, dblNetQty
					, intConcurrencyId
					, dtmDateCreated
					, intCreatedByUserId
					, strCountLine
					, intStockUOMId
				)
				SELECT TOP 1
					  intInventoryCountId = @intInventoryCountId
					, intItemId = item.intItemId
					, intItemLocationId = il.intItemLocationId
					, intSubLocationId = @intStorageLocationId
					, intStorageLocationId = @intStorageUnitId
					, intEntityUserSecurityId = @intUserSecurityId
					, dblPhysicalCount = @dblPhysicalCount
					, intItemUOMId = @intPhysicalCountUOMId
					--, intWeightUOMId = CASE WHEN item.ysnLotWeightsRequired = 1 THEN @intDefaultGrossUOMId ELSE NULL END
					--, dblWeightQty = CASE WHEN item.ysnLotWeightsRequired = 1 
					--	THEN dbo.fnCalculateQtyBetweenUOM(@intPhysicalCountUOMId, @intDefaultGrossUOMId, @dblPhysicalCount)
					--	ELSE 0
					--	END
					--, dblNetQty = CASE WHEN item.ysnLotWeightsRequired = 1 
					--	THEN dbo.fnCalculateQtyBetweenUOM(@intPhysicalCountUOMId, @intDefaultGrossUOMId, @dblPhysicalCount)
					--	ELSE 0
					--	END
					, intConcurrencyId = 1
					, dtmDateCreated = GETDATE()
					, intCreatedByUserId = @intUserSecurityId
					, strCountLine = @strCountLine
					, intStockUOMId = stockUOM.intItemUOMId
				FROM tblICItem item
					INNER JOIN tblICItemLocation il ON il.intItemId = item.intItemId
					LEFT JOIN tblICItemStockUOM stockUOM ON stockUOM.intItemId = item.intItemId
						AND stockUOM.intItemLocationId = il.intItemLocationId
						AND (stockUOM.intSubLocationId IS NULL)
						AND (stockUOM.intStorageLocationId IS NULL)
				WHERE item.intItemId = @intItemId
					AND il.intItemLocationId = @intItemLocationId
					AND il.intLocationId = @intLocationId
			END
			ELSE
			BEGIN
				IF @intStorageLocationId IS NULL AND @intStorageUnitId IS NULL
				BEGIN
					UPDATE tblICInventoryCountDetail
					SET
						  dblPhysicalCount = @dblPhysicalCount
						, intItemUOMId = @intPhysicalCountUOMId
						, intEntityUserSecurityId = @intUserSecurityId
						, dtmDateModified = GETDATE()
						, intModifiedByUserId = @intUserSecurityId
					WHERE intItemId = @intItemId
						AND intItemLocationId = @intItemLocationId
						AND (intSubLocationId IS NULL)
						AND (intStorageLocationId IS NULL)
						AND intInventoryCountId = @intInventoryCountId
				END
				ELSE
				BEGIN
					UPDATE tblICInventoryCountDetail
					SET
						  dblPhysicalCount = @dblPhysicalCount
						, intItemUOMId = @intPhysicalCountUOMId
						, intEntityUserSecurityId = @intUserSecurityId
						, dtmDateModified = GETDATE()
						, intModifiedByUserId = @intUserSecurityId
					WHERE intItemId = @intItemId
						AND intItemLocationId = @intItemLocationId
						AND (intSubLocationId = @intStorageLocationId)
						AND (intStorageLocationId = @intStorageUnitId)
						AND intInventoryCountId = @intInventoryCountId
				END
			END
		END
		ELSE
		BEGIN
			IF NOT EXISTS(
				SELECT TOP 1 1
				FROM tblICItem item
					INNER JOIN tblICItemLocation il ON il.intItemId = item.intItemId
				WHERE item.intItemId = @intItemId
					AND il.intItemLocationId = @intItemLocationId
					AND il.intLocationId = @intLocationId
			)
			BEGIN
				SET @msg = 'Invalid item. Possible reason(s): (1) the item id is invalid. (2) the item id might not have a reference to the item location id (3) the item location id doesn''t have a reference to the Count''s Location'
				RAISERROR(@msg, 11, 1)
				GOTO _Exit
			END

			IF NOT EXISTS(SELECT u.strUnitMeasure, u.strUnitType
				FROM tblICItemUOM i
					INNER JOIN tblICUnitMeasure u ON u.intUnitMeasureId = i.intUnitMeasureId
				WHERE i.intItemId = @intItemId AND i.intItemUOMId = @intPhysicalCountUOMId) AND @intPhysicalCountUOMId IS NOT NULL
			BEGIN
				SET @msg = 'Invalid Count UOM Id provided.'
				RAISERROR(@msg, 11, 1)
				GOTO _Exit
			END

			SELECT TOP 1 @intDefaultGrossUOMId = i.intItemUOMId
			FROM tblICItemUOM i
				INNER JOIN tblICUnitMeasure u ON u.intUnitMeasureId = i.intUnitMeasureId
			WHERE i.intItemId = @intItemId
				AND u.strUnitType = 'Weight'
			ORDER BY i.ysnStockUnit DESC

			INSERT INTO tblICInventoryCountDetail (
					intInventoryCountId
				, intItemId
				, intItemLocationId
				, intSubLocationId
				, intStorageLocationId
				, intEntityUserSecurityId
				, dblPhysicalCount
				, intItemUOMId
				--, intWeightUOMId
				--, dblWeightQty
				--, dblNetQty
				, intConcurrencyId
				, dtmDateCreated
				, intCreatedByUserId
				, strCountLine
				, intStockUOMId
			)
			SELECT TOP 1
				  intInventoryCountId = @intInventoryCountId
				, intItemId = item.intItemId
				, intItemLocationId = il.intItemLocationId
				, intSubLocationId = @intStorageLocationId
				, intStorageLocationId = @intStorageUnitId
				, intEntityUserSecurityId = @intUserSecurityId
				, dblPhysicalCount = @dblPhysicalCount
				, intItemUOMId = @intPhysicalCountUOMId
				--, intWeightUOMId = CASE WHEN item.ysnLotWeightsRequired = 1 THEN @intDefaultGrossUOMId ELSE NULL END
				--, dblWeightQty = CASE WHEN item.ysnLotWeightsRequired = 1 
				--	THEN dbo.fnCalculateQtyBetweenUOM(@intPhysicalCountUOMId, @intDefaultGrossUOMId, @dblPhysicalCount)
				--	ELSE 0
				--	END
				--, dblNetQty = CASE WHEN item.ysnLotWeightsRequired = 1 
				--	THEN dbo.fnCalculateQtyBetweenUOM(@intPhysicalCountUOMId, @intDefaultGrossUOMId, @dblPhysicalCount)
				--	ELSE 0
				--	END
				, intConcurrencyId = 1
				, dtmDateCreated = GETDATE()
				, intCreatedByUserId = @intUserSecurityId
				, strCountLine = @strCountLine
				, intStockUOMId = stockUOM.intItemUOMId
			FROM tblICItem item
				INNER JOIN tblICItemLocation il ON il.intItemId = item.intItemId
				LEFT JOIN tblICItemStockUOM stockUOM ON stockUOM.intItemId = item.intItemId
					AND stockUOM.intItemLocationId = il.intItemLocationId
					AND (stockUOM.intSubLocationId = @intStorageLocationId OR @intStorageLocationId IS NULL)
					AND (stockUOM.intStorageLocationId = @intStorageUnitId OR @intStorageUnitId IS NULL)
			WHERE item.intItemId = @intItemId
				AND il.intItemLocationId = @intItemLocationId
				AND il.intLocationId = @intLocationId
		END
	END

	EXEC dbo.uspICInventoryCountUpdateOutdatedItemStock @intInventoryCountId
END
ELSE
BEGIN
	IF @intInventoryCountId IS NOT NULL
	BEGIN
		SET @msg = 'Unable to modify an Inventory Count that has already been posted.'
		RAISERROR(@msg, 11, 1)
	END
	ELSE
		RAISERROR('Invalid Inventory Count number.', 11, 1)
END

_Exit: