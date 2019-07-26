PRINT 'BEGIN UPDATING THE PRICE OF SETTLED STORAGE AGAINST CONTRACTS IN tblGRSettleContract'
GO

IF EXISTS(
			SELECT 1 
			FROM sys.columns 
			WHERE name  = N'dblPrice'
				AND object_id = object_id(N'dbo.tblGRSettleContract')
		)
BEGIN

IF EXISTS(
			SELECT 1 
			FROM tblGRSettleContract SC 
			INNER JOIN tblGRSettleStorage SS 
				ON SS.intSettleStorageId = SC.intSettleStorageId 
					AND SS.intParentSettleStorageId IS NOT NULL 
			WHERE SC.dblPrice IS NULL
		)
BEGIN
	UPDATE SC
	SET SC.dblPrice = IT.dblCost
	FROM tblGRSettleContract SC
	INNER JOIN tblGRSettleStorage SS
		ON SS.intSettleStorageId = SC.intSettleStorageId
			AND SS.intParentSettleStorageId IS NOT NULL
	INNER JOIN tblICInventoryTransaction IT
		ON IT.intTransactionId = SS.intSettleStorageId
	WHERE IT.strTransactionForm = 'Storage Settlement'
		AND IT.intTransactionTypeId = 44
END

END

PRINT 'END UPDATING THE PRICE OF SETTLED STORAGE AGAINST CONTRACTS IN tblGRSettleContract'
GO