/*Settle Storage*/
IF EXISTS(SELECT 1 FROM sys.columns WHERE Name = N'ysnReversed' AND Object_ID = Object_ID(N'dbo.tblGRSettleStorage'))
BEGIN
    PRINT '--Start updating ysnReversed to 0 in tblGRSettleStorage'
    IF EXISTS(SELECT TOP 1 1 FROM tblGRSettleStorage WHERE ysnReversed IS NULL AND intParentSettleStorageId IS NOT NULL)
    BEGIN
        UPDATE tblGRSettleStorage SET ysnReversed = 0 WHERE ysnReversed IS NULL AND intParentSettleStorageId IS NOT NULL
    END
    PRINT 'End updating ysnReversed to 0 in tblGRSettleStorage--'
END


IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND  TABLE_NAME = 'tblGRSettledItemsToStorage')
BEGIN
    --SAVE EXISTING SETTLED STORAGES IN tblGRSettledItemsToStorage FOR ITEMS TO BE POSTED IN THE INVENTORY
    PRINT '--Start saving settled items in tblGRSettledItemsToStorage'
    IF EXISTS(SELECT TOP 1 1 FROM tblGRSettleStorage WHERE ISNULL(ysnReversed,0) = 0 AND intParentSettleStorageId IS NOT NULL)
    BEGIN
        INSERT INTO [dbo].[tblGRSettledItemsToStorage]
		(
			intItemId
			,intItemLocationId
			,intItemUOMId
			,dtmDate
			,dblQty
			,dblUOMQty
			,dblCost
			,intCurrencyId
			,intTransactionId
			,intTransactionDetailId
			,strTransactionId
			,intLotId
			,intSubLocationId
			,intStorageLocationId
			,ysnIsStorage
		)
		--STORAGE
		SELECT ITS.intItemId
			,ITS.intItemLocationId
			,ITS.intItemUOMId
			,ITS.dtmDate
			,ITS.dblQty
			,ITS.dblUOMQty
			,ITS.dblCost
			,ITS.intCurrencyId
			,ITS.intTransactionId
			,ITS.intTransactionDetailId
			,ITS.strTransactionId
			,ITS.intLotId
			,ITS.intSubLocationId
			,ITS.intStorageLocationId
			,1 
		FROM tblICInventoryTransactionStorage ITS
		INNER JOIN tblGRSettleStorage SS
			ON SS.intSettleStorageId = ITS.intTransactionId
				AND SS.ysnReversed = 0
				AND ITS.strTransactionForm = 'Storage Settlement'
		WHERE SS.intSettleStorageId NOT IN (SELECT intTransactionId FROM tblGRSettledItemsToStorage)
		UNION ALL
		--COSTING
		SELECT IT.intItemId
			,IT.intItemLocationId
			,IT.intItemUOMId
			,IT.dtmDate
			,IT.dblQty
			,IT.dblUOMQty
			,IT.dblCost
			,IT.intCurrencyId
			,IT.intTransactionId
			,IT.intTransactionDetailId
			,IT.strTransactionId
			,IT.intLotId
			,IT.intSubLocationId
			,IT.intStorageLocationId
			,0
		FROM tblICInventoryTransaction IT
		INNER JOIN tblGRSettleStorage SS
			ON SS.intSettleStorageId = IT.intTransactionId
				AND SS.ysnReversed = 0
				AND IT.strTransactionForm = 'Storage Settlement'
		WHERE SS.intSettleStorageId NOT IN (SELECT intTransactionId FROM tblGRSettledItemsToStorage)
    END
    PRINT 'End saving settled items in tblGRSettledItemsToStorage--'
END

/*Transfer Storage*/
IF EXISTS (SELECT 1 FROM sys.columns WHERE Name = N'ysnReversed' AND Object_ID = Object_ID(N'dbo.tblGRTransferStorage'))
BEGIN
    PRINT '--Start updating ysnReversed to 0 in tblGRTransferStorage'
    IF EXISTS(SELECT TOP 1 1 FROM tblGRTransferStorage WHERE ysnReversed IS NULL)
    BEGIN
        UPDATE tblGRTransferStorage SET ysnReversed = 0 WHERE ysnReversed IS NULL
    END
    PRINT 'End updating ysnReversed to 0 in tblGRTransferStorage--'
END