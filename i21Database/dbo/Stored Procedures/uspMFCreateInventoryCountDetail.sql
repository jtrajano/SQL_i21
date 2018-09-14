CREATE PROCEDURE uspMFCreateInventoryCountDetail @strInventoryCountNo NVARCHAR(50)
	,@intLotId INT
	,@intUserSecurityId INT
	,@dblPhysicalCount NUMERIC(18, 6)
	,@intPhysicalCountUOMId INT
AS
BEGIN
	DECLARE @intLocationId INT
	DECLARE @intSubLocationId INT
	DECLARE @intStorageLocationId INT
	DECLARE @strLotNumber NVARCHAR(100)
	DECLARE @dblLotQty NUMERIC(18, 6)
	DECLARE @dblLastCost NUMERIC(18, 6)
	DECLARE @dblLotWeight NUMERIC(18, 6)
	DECLARE @intLotItemLocationId INT
	DECLARE @intItemId INT
	DECLARE @intInventoryCountId INT
	DECLARE @intItemUOMId INT
	DECLARE @intCountItemUOMId INT

	DECLARE @intWeightUOMId INT
	DECLARE @dblWeightPerQty NUMERIC(18, 6)


	SELECT @intLocationId = intLocationId
		,@intSubLocationId = intSubLocationId
		,@intStorageLocationId = intStorageLocationId
		,@intInventoryCountId = intInventoryCountId
	FROM tblICInventoryCount
	WHERE strCountNo = @strInventoryCountNo


	SELECT @intLotId = intLotId
		,@strLotNumber = strLotNumber
		,@dblLotQty = dblQty
		,@intLotItemLocationId = intItemLocationId
		,@intItemId = intItemId
		,@dblLastCost = dblLastCost
		,@intItemUOMId = intItemUOMId
		,@dblLotWeight = dblWeight
		,@intWeightUOMId = intWeightUOMId
		,@dblWeightPerQty = dblWeightPerQty
	FROM tblICLot
	WHERE intLotId = @intLotId

	

	    SELECT @intCountItemUOMId = intItemUOMId
		FROM tblICInventoryCountDetail
		WHERE intLotId = @intLotId
		AND intInventoryCountId = @intInventoryCountId

	IF NOT EXISTS (
			SELECT 1
			FROM tblICInventoryCountDetail
			WHERE intLotId = @intLotId
				AND intInventoryCountId = @intInventoryCountId
			)
	BEGIN
		INSERT INTO tblICInventoryCountDetail (
			intInventoryCountId
			,intItemId
			,intItemLocationId
			,intSubLocationId
			,intStorageLocationId
			,intLotId
			,dblSystemCount
			,dblLastCost
			,strCountLine
			,dblPallets
			,dblQtyPerPallet
			,dblPhysicalCount
			,intItemUOMId
			,ysnRecount
			,intEntityUserSecurityId
			,intSort
			,intConcurrencyId
			,dblNetQty
			)
		VALUES (
			@intInventoryCountId
			,@intItemId
			,@intLotItemLocationId
			,@intSubLocationId
			,@intStorageLocationId
			,@intLotId
			,@dblLotQty
			,@dblLastCost
			,@strInventoryCountNo
			,1
			,1
			,@dblPhysicalCount
			,@intItemUOMId
			,0
			,@intUserSecurityId
			,1
			,1
				,CASE 
				WHEN @intWeightUOMId = @intPhysicalCountUOMId
					THEN @dblPhysicalCount
				ELSE @dblPhysicalCount * @dblWeightPerQty
				END
			)
	END
	ELSE
	BEGIN
		

		IF @intCountItemUOMId = @intPhysicalCountUOMId
		BEGIN
			UPDATE tblICInventoryCountDetail
			SET dblPhysicalCount = @dblPhysicalCount
			,dblNetQty = CASE 
					WHEN @intWeightUOMId = @intPhysicalCountUOMId
						THEN @dblPhysicalCount
					ELSE @dblPhysicalCount * @dblWeightPerQty
					END
			WHERE intLotId = @intLotId
				AND intInventoryCountId = @intInventoryCountId
		END
		ELSE
		BEGIN
			UPDATE tblICInventoryCountDetail
			SET dblPhysicalCount = @dblPhysicalCount
			,dblNetQty = CASE 
					WHEN @intWeightUOMId = @intPhysicalCountUOMId
						THEN @dblPhysicalCount
					ELSE @dblPhysicalCount * @dblWeightPerQty
					END
				,dblSystemCount = CASE 
					WHEN @intPhysicalCountUOMId = @intItemUOMId
						THEN @dblLotQty
					ELSE @dblLotWeight
					END
				,intItemUOMId = @intPhysicalCountUOMId
			WHERE intLotId = @intLotId
				AND intInventoryCountId = @intInventoryCountId
		END
	END
END
