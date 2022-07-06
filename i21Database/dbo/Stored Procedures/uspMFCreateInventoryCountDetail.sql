﻿CREATE PROCEDURE uspMFCreateInventoryCountDetail @strInventoryCountNo NVARCHAR(50)
	,@intLotId INT = NULL
	,@intUserSecurityId INT
	,@dblPhysicalCount NUMERIC(18, 6)
	,@intPhysicalCountUOMId INT=NULL
	,@intItemId INT = NULL
	,@intItemLocationId INT = NULL
	,@intItemUOMId INT = NULL
	,@intStorageLocationId INT = NULL
	,@intStorageUnitId INT = NULL
AS
BEGIN
	DECLARE @dblWeightPerQty NUMERIC(18, 6)

	IF @intLotId IS NOT NULL
	BEGIN
		SELECT @intItemUOMId = L.intItemUOMId
			,@dblWeightPerQty = CASE 
				WHEN dblWeightPerQty = 0
					THEN 1
				ELSE dblWeightPerQty
				END
		FROM tblICLot L
		WHERE L.intLotId = @intLotId

		IF @intPhysicalCountUOMId <> @intItemUOMId
		BEGIN
			SELECT @dblPhysicalCount = @dblPhysicalCount / @dblWeightPerQty
		END
	END

	EXEC dbo.uspICUpdateInventoryPhysicalCount @strCountNo = @strInventoryCountNo
		,@dblPhysicalCount = @dblPhysicalCount
		,@intLotId = @intLotId
		,@intUserSecurityId = @intUserSecurityId
		,@intItemId = @intItemId
		,@intItemLocationId = @intItemLocationId
		,@intItemUOMId = @intItemUOMId
		,@intStorageLocationId = @intStorageLocationId
		,@intStorageUnitId = @intStorageUnitId
		/*DECLARE @intLocationId INT
	DECLARE @intSubLocationId INT
	DECLARE @intStorageLocationId INT
	DECLARE @strLotNumber NVARCHAR(50)
	DECLARE @dblLotQty NUMERIC(18, 6)
	DECLARE @dblLastCost NUMERIC(18, 6)
	DECLARE @dblLotWeight NUMERIC(18, 6)
	DECLARE @intLotItemLocationId INT
	DECLARE @intItemId INT
	DECLARE @intInventoryCountId INT
	DECLARE @intItemUOMId INT
	DECLARE @intCountItemUOMId INT
	DECLARE @strLotAlias NVARCHAR(50)
		,@intParentLotId INT
		,@strParentLotNumber NVARCHAR(50)
		,@strParentLotAlias NVARCHAR(50)
		,@intWeightUOMId INT
		,@strCountLine NVARCHAR(50)
		,@strCalculatedCountLine NVARCHAR(50)
	DECLARE @dblWeightPerQty NUMERIC(18, 6)

	SELECT @intLocationId = intLocationId
		,@intInventoryCountId = intInventoryCountId
	FROM tblICInventoryCount
	WHERE strCountNo = @strInventoryCountNo

	SELECT @intLotId = L.intLotId
		,@strLotNumber = L.strLotNumber
		,@dblLotQty = L.dblQty
		,@intLotItemLocationId = L.intItemLocationId
		,@intItemId = L.intItemId
		,@dblLastCost = L.dblLastCost
		,@intItemUOMId = L.intItemUOMId
		,@dblLotWeight = L.dblWeight
		,@strLotAlias = L.strLotAlias
		,@intParentLotId = L.intParentLotId
		,@strParentLotNumber = PL.strParentLotNumber
		,@strParentLotAlias = PL.strParentLotAlias
		,@intWeightUOMId = L.intWeightUOMId
		,@intSubLocationId = L.intSubLocationId
		,@intStorageLocationId = L.intStorageLocationId
		,@dblWeightPerQty = dblWeightPerQty
	FROM tblICLot L
	JOIN tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
	WHERE L.intLotId = @intLotId

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
		SELECT TOP 1 @strCountLine = REPLACE(REPLACE(strCountLine, @strInventoryCountNo, ''), '-', '')
		FROM tblICInventoryCountDetail
		WHERE intInventoryCountId = @intInventoryCountId
		ORDER BY intInventoryCountDetailId DESC

		IF ISNULL(@strCountLine, '') = ''
			SELECT @strCountLine = 0

		IF ISNUMERIC(@strCountLine) = 1
		BEGIN
			SELECT @strCalculatedCountLine = @strInventoryCountNo + '-' + LTRIM(CONVERT(INT, @strCountLine) + 1)
		END

		INSERT INTO tblICInventoryCountDetail (
			intInventoryCountId
			,intItemId
			,intItemLocationId
			,intSubLocationId
			,intStorageLocationId
			,intLotId
			,strLotNo
			,strLotAlias
			,intParentLotId
			,strParentLotNo
			,strParentLotAlias
			,dblSystemCount
			,dblLastCost
			,strCountLine
			,dblPallets
			,dblQtyPerPallet
			,dblPhysicalCount
			,intItemUOMId
			,intWeightUOMId
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
			,@strLotNumber
			,@strLotAlias
			,@intParentLotId
			,@strParentLotNumber
			,@strParentLotAlias
			,@dblLotQty
			,@dblLastCost
			,@strCalculatedCountLine
			,1
			,1
			,@dblPhysicalCount
			,@intItemUOMId
			,@intWeightUOMId
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
	END*/
END
