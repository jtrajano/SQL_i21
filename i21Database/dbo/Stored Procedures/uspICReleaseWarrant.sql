CREATE PROCEDURE [dbo].[uspICReleaseWarrant]
  @records IdQuantity READONLY,
  @intUserId INT
AS
BEGIN
    --UPDATE tblICLot
    --SET dblReleasedQty = A.dblQuantity
    --FROM @records A
    --WHERE tblICLot.intLotId = A.intId


   -- - Update the released lots
    BEGIN
        DECLARE @LotsToRelease AS LotReleaseTableType 

        INSERT INTO @LotsToRelease (
            [intItemId] 
            ,[intItemLocationId] 
            ,[intItemUOMId] 
            ,[intLotId] 
            ,[intSubLocationId] 
            ,[intStorageLocationId] 
            ,[dblQty] 
            ,[intTransactionId] 
            ,[strTransactionId] 
            ,[intTransactionTypeId] 
            ,[intOwnershipTypeId] 
            ,[dtmDate] 
        )
        SELECT 
            [intItemId] = lot.intItemId
            ,[intItemLocationId] = lot.intItemLocationId
            ,[intItemUOMId] = lot.intItemUOMId
            ,[intLotId] = lot.intLotId
            ,[intSubLocationId] = lot.intSubLocationId
            ,[intStorageLocationId] = lot.intStorageLocationId
            ,[dblQty] = rectoupdate.dblQuantity
            ,[intTransactionId] = lot.intLotId -- Use the lot id. 
            ,[strTransactionId] = lot.strLotNumber -- Use the lot number. 
            ,[intTransactionTypeId] = 61 -- Use 61 for a release coming from the Warrant screen. 
            ,[intOwnershipTypeId] = lot.intOwnershipType
            ,[dtmDate] = GETDATE()
        FROM tblICLot lot
        INNER JOIN @records rectoupdate
            ON lot.intLotId = rectoupdate.intId
        LEFT JOIN tblICWarrantStatus warrantStatus
            ON warrantStatus.intWarrantStatus = lot.intWarrantStatus    
        WHERE lot.strCondition NOT IN ('Missing', 'Swept', 'Skimmed')

        EXEC [uspICCreateLotRelease]
            @LotsToRelease = @LotsToRelease 
            ,@intTransactionId = 0 -- Since warrant does not have a transaction id, you can use the lot id. 
            ,@intTransactionTypeId = 61 -- Use 61 for Warrant. 
            ,@intUserId = @intUserId
    END 
END