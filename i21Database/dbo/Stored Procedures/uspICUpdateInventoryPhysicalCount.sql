CREATE PROCEDURE [dbo].[uspICUpdateInventoryPhysicalCount]
	-- Count No and Physical Count are required
	@strCountNo NVARCHAR(50),
	@dblPhysicalCount NUMERIC(18,6),

	-- ========================================
	--    Required for a lotted item
	-- ========================================
	-- Set this to NULL for a non-lotted item
	@intLotId INT = NULL,

	-- This is also required
	@intUserSecurityId INT,

	-- ========================================
	--    Parameters for a non-lotted item
	-- ========================================
	-- Required for a non-lotted item
	@intItemId INT = NULL,
	@intItemLocationId INT = NULL,

	-- Set this to change the Count UOM 
	@intItemUOMId INT = NULL,
	-- Set these to change the storage unit/loc
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
	DECLARE @ysnLotWeightsRequired BIT

	IF(@ysnCountByLots = 1)
	BEGIN
		IF(@intLotId IS NULL)
		BEGIN
			SET @msg = 'Inventory Count "' + @strCountNo + '" needs a lot id.'
			RAISERROR(@msg, 11, 1)
			GOTO _Exit
		END

		SELECT
			@intItemId = i.intItemId,
			@ysnLotWeightsRequired = i.ysnLotWeightsRequired
		FROM tblICLot lot
			INNER JOIN tblICItem i ON i.intItemId = lot.intItemId
		WHERE lot.intLotId = @intLotId

		IF EXISTS(SELECT * FROM tblICInventoryCountDetail WHERE intInventoryCountId = @intInventoryCountId AND intLotId = @intLotId)
		BEGIN
			UPDATE tblICInventoryCountDetail
			SET
				  dblPhysicalCount = @dblPhysicalCount
				, dblWeightQty = CASE WHEN intWeightUOMId IS NOT NULL THEN dbo.fnCalculateQtyBetweenUOM(intItemUOMId, intWeightUOMId, @dblPhysicalCount) ELSE dblWeightQty END
				, dblNetQty = CASE WHEN intWeightUOMId IS NOT NULL THEN dbo.fnCalculateQtyBetweenUOM(intItemUOMId, intWeightUOMId, @dblPhysicalCount) ELSE dblNetQty END
				, intEntityUserSecurityId = @intUserSecurityId
				, dtmDateModified = GETDATE()
				, intModifiedByUserId = @intUserSecurityId
			WHERE intLotId = @intLotId
				AND intInventoryCountId = @intInventoryCountId
		END
		ELSE
		BEGIN
			IF NOT EXISTS(SELECT * FROM tblICLot WHERE intLotId = @intLotId)
			BEGIN
				SET @msg = 'Lot id does not exists. Inventory Count "' + @strCountNo + '" needs a lot id.'
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
				, intWeightUOMId = lot.intWeightUOMId
				, dblWeightQty = dbo.fnCalculateQtyBetweenUOM(lot.intItemUOMId, intWeightUOMId, @dblPhysicalCount)
				, dblNetQty = dbo.fnCalculateQtyBetweenUOM(lot.intItemUOMId, intWeightUOMId, @dblPhysicalCount)
				, intConcurrencyId = 1
				, dtmDateCreated = GETDATE()
				, intCreatedByUserId = @intUserSecurityId
				, strCountLine = @strCountLine
				, intStockUOMId = stockUOM.intItemUOMId
			FROM tblICLot lot
				LEFT JOIN tblICItemStockUOM stockUOM ON stockUOM.intItemUOMId = lot.intItemUOMId
					AND stockUOM.intItemId = lot.intItemId
					AND stockUOM.intStorageLocationId = lot.intStorageLocationId
					AND stockUOM.intSubLocationId = lot.intSubLocationId
					AND stockUOM.intItemLocationId = lot.intItemLocationId
				LEFT OUTER JOIN tblICParentLot pLot ON lot.intParentLotId = pLot.intParentLotId
			WHERE lot.intLotId = @intLotId	
		END
	END
	ELSE -- Non-lotted Item
	BEGIN
		IF(@intItemUOMId IS NULL)
		BEGIN
			SET @msg = 'Count UOM is required. Provide a value to the @intItemUOMId parameter.'
			RAISERROR(@msg, 11, 1)
			GOTO _Exit
		END

		IF NOT EXISTS(
			SElECT TOP 1 1 FROM tblICItemUOM where intItemId = @intItemId AND intItemUOMId = @intItemUOMId
		)
		BEGIN
			SET @msg = 'Invalid Count UOM. Provide a valid value to the @intItemUOMId parameter.'
			RAISERROR(@msg, 11, 1)
			GOTO _Exit	
		END

		IF @intStorageLocationId IS NOT NULL
		BEGIN
			IF NOT EXISTS(SELECT TOP 1 1
				FROM tblSMCompanyLocationSubLocation sub
					INNER JOIN tblICItemLocation il ON il.intLocationId = sub.intCompanyLocationId
				WHERE il.intItemId = @intItemId
					AND il.intItemLocationId = @intItemLocationId
					AND sub.intCompanyLocationSubLocationId = @intStorageLocationId
			)
			BEGIN
				SET @msg = 'The storage location is not set up for the item. Provide a valid value to the @intStorageLocationId parameter.'
				RAISERROR(@msg, 11, 1)
				GOTO _Exit		
			END
		END

		IF @intStorageUnitId IS NOT NULL
		BEGIN
			IF @intStorageLocationId IS NULL
			BEGIN
				SELECT @intStorageLocationId = sub.intCompanyLocationSubLocationId
				FROM tblSMCompanyLocationSubLocation sub
					INNER JOIN tblICStorageLocation sl ON sl.intSubLocationId = sub.intCompanyLocationSubLocationId
				WHERE sl.intStorageLocationId = @intStorageUnitId
			END

			IF NOT EXISTS(SELECT TOP 1 1
				FROM tblICStorageLocation sl
					INNER JOIN tblICItemLocation il ON il.intLocationId = sl.intLocationId
				WHERE sl.intStorageLocationId = @intStorageUnitId
					AND il.intItemLocationId = @intItemLocationId
					AND sl.intSubLocationId = @intStorageLocationId
					AND il.intItemId = @intItemId
			)
			BEGIN
				SET @msg = 'The storage unit is not set up for the item. Provide a valid value to the @intStorageUnitId parameter.'
				RAISERROR(@msg, 11, 1)
				GOTO _Exit			
			END

		END

		IF EXISTS(SELECT *
			FROM tblICInventoryCount c
				INNER JOIN tblICInventoryCountDetail cd ON cd.intInventoryCountId = c.intInventoryCountId
			WHERE c.intInventoryCountId = @intInventoryCountId
				AND cd.intItemLocationId = @intItemLocationId
				AND cd.intItemId = @intItemId
				AND cd.intItemUOMId = @intItemUOMId
				AND ((cd.intSubLocationId IS NULL AND @intStorageLocationId IS NULL) OR (cd.intSubLocationId = @intStorageLocationId AND @intStorageLocationId IS NOT NULL))
				AND ((cd.intStorageLocationId IS NULL AND @intStorageUnitId IS NULL) OR (cd.intStorageLocationId = @intStorageUnitId AND @intStorageUnitId IS NOT NULL))
		)
		BEGIN
			UPDATE cd
			SET
					cd.dblPhysicalCount			= @dblPhysicalCount
				, cd.intItemUOMId				= @intItemUOMId
				, cd.dtmDateModified			= GETDATE()
				, cd.intModifiedByUserId		= @intUserSecurityId
				, cd.intEntityUserSecurityId	= @intUserSecurityId
			FROM tblICInventoryCount c
				INNER JOIN tblICInventoryCountDetail cd ON cd.intInventoryCountId = c.intInventoryCountId
			WHERE c.intInventoryCountId = @intInventoryCountId
				AND cd.intItemLocationId = @intItemLocationId
				AND cd.intItemId = @intItemId
				AND cd.intItemUOMId = @intItemUOMId
				AND ((cd.intSubLocationId IS NULL AND @intStorageLocationId IS NULL) OR (cd.intSubLocationId = @intStorageLocationId AND @intStorageLocationId IS NOT NULL))
				AND ((cd.intStorageLocationId IS NULL AND @intStorageUnitId IS NULL) OR (cd.intStorageLocationId = @intStorageUnitId AND @intStorageUnitId IS NOT NULL))
		END
		ELSE
		BEGIN
			INSERT INTO tblICInventoryCountDetail (
					intInventoryCountId
				, intItemId
				, intItemLocationId
				, intSubLocationId
				, intStorageLocationId
				, intEntityUserSecurityId
				, dblPhysicalCount
				, intItemUOMId
				, intConcurrencyId
				, dtmDateCreated
				, intCreatedByUserId
				, strCountLine
				, intStockUOMId
			)
			SELECT
					intInventoryCountId		= @intInventoryCountId
				, intItemId					= i.intItemId
				, intItemLocationId			= il.intItemLocationId
				, intSubLocationId			= @intStorageLocationId
				, intStorageLocationId		= @intStorageUnitId
				, intEntityUserSecurityId	= @intUserSecurityId
				, dblPhysicalCount			= @dblPhysicalCount
				, intItemUOMId				= @intItemUOMId
				, intConcurrencyId			= 1
				, dtmDateCreated			= GETDATE()
				, intCreatedByUserId		= @intUserSecurityId
				, strCountLine				= @strCountLine
				, intStockUOMId				= u.intItemUOMId
			FROM tblICItem i
				INNER JOIN tblICItemLocation il ON il.intItemId = i.intItemId
				INNER JOIN tblICItemUOM u ON u.intItemId = i.intItemId
					AND u.ysnStockUnit = 1
			WHERE i.intItemId = @intItemId
				AND il.intItemLocationId = @intItemLocationId
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