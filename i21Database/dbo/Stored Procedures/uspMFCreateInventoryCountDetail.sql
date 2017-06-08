CREATE PROCEDURE uspMFCreateInventoryCountDetail
			@strInventoryCountNo NVARCHAR(50),
			@intLotId INT,
			@intUserSecurityId INT,
			@dblPhysicalCount NUMERIC(18,6)
AS
BEGIN
	DECLARE @intLocationId INT
	DECLARE @intSubLocationId INT
	DECLARE @intStorageLocationId INT
	DECLARE @strLotNumber NVARCHAR(100)
	DECLARE @dblLotQty NUMERIC(18,6)
	DECLARE @dblLastCost NUMERIC(18,6)
	DECLARE @dblLotWeight NUMERIC(18,6)
	DECLARE @intLotItemLocationId INT
	DECLARE @intItemId INT
	DECLARE @intInventoryCountId INT
	DECLARE @intItemUOMId INT
	DECLARE @intCountItemUOMId int
	DECLARE @intStockItemUOMId int
			,@ysnCycleCountByStockUnit bit

	SELECT @intLocationId = intLocationId
		,@intSubLocationId = intSubLocationId
		,@intStorageLocationId = intStorageLocationId
		,@intInventoryCountId = intInventoryCountId
	FROM tblICInventoryCount
	WHERE strCountNo = @strInventoryCountNo

	SELECT @intLotId = intLotId,
		   @strLotNumber = strLotNumber,
		   @dblLotQty = dblQty,
		   @intLotItemLocationId = intItemLocationId,
		   @intItemId = intItemId,
		   @dblLastCost = dblLastCost,
		   @intItemUOMId = intItemUOMId,
		   @dblLotWeight=dblWeight
	FROM tblICLot
	WHERE intLotId = @intLotId

	IF NOT EXISTS (SELECT 1 FROM tblICInventoryCountDetail WHERE intLotId = @intLotId AND intInventoryCountId = @intInventoryCountId)
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
			,intConcurrencyId)
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
			,1)
	END
	ELSE
	BEGIN
		Select @intStockItemUOMId=intItemUOMId from tblICItemUOM Where intItemId=@intItemId and ysnStockUnit =1
		Select @intCountItemUOMId=intItemUOMId
		From tblICInventoryCountDetail 
		WHERE intLotId = @intLotId
			AND intInventoryCountId = @intInventoryCountId

		Select @ysnCycleCountByStockUnit=ysnCycleCountByStockUnit from tblMFCompanyPreference 

		IF @ysnCycleCountByStockUnit is null
		Begin
			Select @ysnCycleCountByStockUnit=1
		End

		If @intCountItemUOMId=@intStockItemUOMId or @ysnCycleCountByStockUnit=0
		Begin
			UPDATE tblICInventoryCountDetail
			SET dblPhysicalCount = @dblPhysicalCount
			WHERE intLotId = @intLotId
				AND intInventoryCountId = @intInventoryCountId
		end
		Else
		Begin
			UPDATE tblICInventoryCountDetail
			SET dblPhysicalCount = @dblPhysicalCount,dblSystemCount =Case When @intStockItemUOMId=@intItemUOMId Then @dblLotQty Else @dblLotWeight End,intItemUOMId =@intStockItemUOMId
			WHERE intLotId = @intLotId
				AND intInventoryCountId = @intInventoryCountId
		End
	END
END