CREATE PROCEDURE dbo.uspLGUpdateReleasedQtyForShipmentWithLot
	@intLoadId AS INT,
    @intUserSecurityId AS INT,
    @ysnClear AS BIT -- This will determine if the release qty will be increased or decreased
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ItemsToRelease AS dbo.LotReleaseTableType;
DECLARE @intOutboundShipmentTransactionType AS INT
DECLARE @intPickLotTransactionType AS INT

-- Get the transaction type id
BEGIN 
	SELECT TOP 1 
			@intPickLotTransactionType = intTransactionTypeId
	FROM	dbo.tblICInventoryTransactionType
	WHERE	strName = 'Pick Lots'

    SELECT TOP 1 
			@intOutboundShipmentTransactionType = intTransactionTypeId
	FROM	dbo.tblICInventoryTransactionType
	WHERE	strName = 'Outbound Shipment'
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
			,dblQty = CASE WHEN @ysnClear = 1 THEN Lot.dblReleasedQty + SUM(LDL.dblLotQuantity) ELSE Lot.dblReleasedQty - SUM(LDL.dblLotQuantity) END
			,intTransactionId = L.intLoadId
			,strTransactionId = CAST(L.strLoadNumber AS VARCHAR(100))
			,intTransactionTypeId = @intOutboundShipmentTransactionType
            ,dtmDate = GETDATE()
	FROM	tblLGLoad L
    JOIN    tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
    JOIN    tblLGLoadDetailLot LDL ON LD.intLoadDetailId = LDL.intLoadDetailId
    JOIN    tblICLot Lot ON Lot.intLotId = LDL.intLotId
    WHERE	L.intLoadId = @intLoadId
    AND     L.intPurchaseSale = 2 -- Outbound
    AND     L.intSourceType IN (6, 7) -- 'Pick Lots' and 'Pick Lots w/o Contract'
	GROUP BY
			Lot.intItemId
			,Lot.intItemLocationId
			,Lot.intItemUOMId
			,Lot.intLotId
			,Lot.intSubLocationId
			,Lot.intStorageLocationId
			,Lot.dblReleasedQty
			,L.intLoadId
			,L.strLoadNumber
END

-- Do the release of qty
BEGIN 

    EXEC [uspICCreateLotRelease]
        @LotsToRelease = @ItemsToRelease
        ,@intTransactionId = @intLoadId
        ,@intTransactionTypeId = @intOutboundShipmentTransactionType
        ,@intUserId = @intUserSecurityId

END 

