CREATE PROCEDURE dbo.uspLGUpdateReleasedQtyForPickLot
	@intPickLotHeaderId AS INT,
    @intUserSecurityId AS INT,
    @ysnClear AS BIT -- This will determine if the release qty will be increased or decreased
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ItemsToRelease AS dbo.LotReleaseTableType;
DECLARE @intInventoryTransactionType AS INT
DECLARE @strInvalidItemNo AS NVARCHAR(50) 
DECLARE @intInvalidItemId AS INT

-- Get the transaction type id
BEGIN 
	SELECT TOP 1 
			@intInventoryTransactionType = intTransactionTypeId
	FROM	dbo.tblICInventoryTransactionType
	WHERE	strName = 'Pick Lots'
END

-- Get the items to release
BEGIN 
	INSERT INTO @ItemsToRelease (
			intItemId
			,intItemLocationId
			,intItemUOMId
			,intLotId
			,intSubLocationId
			,intStorageLocationId
			,dblQty
			,intTransactionId
			,strTransactionId
			,intTransactionTypeId
            ,dtmDate
	)
	SELECT	intItemId = Lot.intItemId
			,intItemLocationId = Lot.intItemLocationId
			,intItemUOMId = Lot.intItemUOMId
			,intLotId = Lot.intLotId
			,intSubLocationId = Lot.intSubLocationId
			,intStorageLocationId = Lot.intStorageLocationId
			,dblQty = CASE WHEN @ysnClear = 1 THEN Lot.dblReleasedQty + SUM(PLDetail.dblLotPickedQty) ELSE Lot.dblReleasedQty - SUM(PLDetail.dblLotPickedQty) END
			,intTransactionId = PLHeader.intPickLotHeaderId
			,strTransactionId = CAST(PLHeader.[strPickLotNumber] AS VARCHAR(100))
			,intTransactionTypeId = @intInventoryTransactionType
            ,dtmDate = GETDATE()
	FROM	tblLGPickLotDetail PLDetail
    JOIN    tblLGPickLotHeader PLHeader ON PLHeader.intPickLotHeaderId = PLDetail.intPickLotHeaderId
    JOIN    tblICLot Lot ON Lot.intLotId = PLDetail.intLotId
	WHERE	PLHeader.intPickLotHeaderId = @intPickLotHeaderId
	GROUP BY
			Lot.intItemId
			,Lot.intItemLocationId
			,Lot.intItemUOMId
			,Lot.intLotId
			,Lot.intSubLocationId
			,Lot.intStorageLocationId
			,Lot.dblReleasedQty
			,PLHeader.intPickLotHeaderId
			,PLHeader.strPickLotNumber
END

-- Do the release of qty
BEGIN 

    EXEC [uspICCreateLotRelease]
        @LotsToRelease = @ItemsToRelease
        ,@intTransactionId = @intPickLotHeaderId
        ,@intTransactionTypeId = @intInventoryTransactionType
        ,@intUserId = @intUserSecurityId

END 

