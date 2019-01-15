CREATE PROCEDURE [dbo].[uspICUpdateInventoryPhysicalCount]
	@strCountNo NVARCHAR(50),
	@dblPhysicalCount NUMERIC(18,6),
	@intPhysicalCountUOMId INT,
	@intLotId INT,
	@intUserSecurityId INT
AS

DECLARE @intInventoryCountId INT
DECLARE @ysnPosted BIT
DECLARE @ysnCountByLots BIT
DECLARE @msg NVARCHAR(200)

SELECT
	  @intInventoryCountId = intInventoryCountId
	, @ysnPosted = ysnPosted
	, @ysnCountByLots = ysnCountByLots
FROM tblICInventoryCount 
WHERE strCountNo = @strCountNo

IF @intInventoryCountId IS NOT NULL AND @ysnPosted = 0
BEGIN
	IF @intLotId IS NULL AND ISNULL(@ysnCountByLots, 0) = 1
	BEGIN
		SET @msg = 'Inventory Count "' + @strCountNo + '" needs a lot id.'
		RAISERROR(@msg, 11, 1)
		GOTO _Exit
	END
	
	IF EXISTS(SELECT * FROM tblICInventoryCountDetail WHERE intInventoryCountId = @intInventoryCountId AND intLotId = @intLotId)
	BEGIN
		IF (NOT EXISTS(SELECT TOP 1 1
			FROM tblICItemUOM iu
				INNER JOIN tblICInventoryCountDetail cd ON cd.intItemId = iu.intItemId
			WHERE cd.intInventoryCountId = @intInventoryCountId
				AND cd.intLotId = @intLotId
				AND iu.intItemUOMId = @intPhysicalCountUOMId) AND @intPhysicalCountUOMId IS NOT NULL)
		BEGIN
			SET @msg = 'Invalid Physical Count UOM Id provided.'
			RAISERROR(@msg, 11, 1)
			GOTO _Exit
		END

		-- Update
		UPDATE tblICInventoryCountDetail
		SET
			  dblPhysicalCount = @dblPhysicalCount
			, intItemUOMId = CASE WHEN @intPhysicalCountUOMId IS NULL THEN intItemUOMId ELSE @intPhysicalCountUOMId END
			, intEntityUserSecurityId = @intUserSecurityId
			, dtmDateModified = GETDATE()
			, intModifiedByUserId = @intUserSecurityId
		WHERE intLotId = @intLotId
			AND intInventoryCountId = @intInventoryCountId
	END
	ELSE
	BEGIN
		DECLARE @strCountLine NVARCHAR(50)
		SELECT @strCountLine = @strCountNo + '-' + CAST(COUNT(*) + 1 AS NVARCHAR(50)) FROM tblICInventoryCountDetail WHERE intInventoryCountId = @intInventoryCountId
		DECLARE @intDefaultGrossUOMId INT
		SELECT @intDefaultGrossUOMId = i.intItemUOMId
		FROM tblICItemUOM i
			INNER JOIN tblICUnitMeasure u ON u.intUnitMeasureId = i.intUnitMeasureId
			INNER JOIN tblICLot lot ON lot.intItemId = i.intItemId
		WHERE lot.intLotId = @intLotId
			AND u.strUnitType = 'Weight'
		ORDER BY i.ysnStockUnit DESC

		IF(@ysnCountByLots = 1)
		BEGIN
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
				, intItemUOMId = CASE WHEN @intPhysicalCountUOMId IS NULL THEN lot.intItemUOMId ELSE @intPhysicalCountUOMId END
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
		ELSE
		BEGIN
			SET @msg = 
				CASE WHEN @intLotId IS NULL OR @ysnCountByLots = 0
					THEN 'Updating non-lotted item is not yet supported. ' + 'Inventory Count "' + @strCountNo + '" needs a lot id.' 
					ELSE 'Invalid lot id provided.' 
					END
			RAISERROR(@msg, 11, 1)
			GOTO _Exit
		END
	END

	EXEC dbo.uspICInventoryCountUpdateOutdatedItemStock @intInventoryCountId
END
ELSE
BEGIN
	IF @intInventoryCountId IS NOT NULL
	BEGIN
		SET @msg = 'Unable to modify an Inventory Count "' + @strCountNo + '" that has already been posted.'
		RAISERROR(@msg, 11, 1)
	END
	ELSE
		RAISERROR('Invalid Inventory Count number.', 11, 1)
END

_Exit: