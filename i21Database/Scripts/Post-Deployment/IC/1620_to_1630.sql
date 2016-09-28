
PRINT N'BEGIN INVENTORY PATH from 16.02.x.x to 16.03.x.x'

-- Rename RWIP to RCON
IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblGLDetail'))
BEGIN	
	EXEC ('
		UPDATE	tblGLDetail
		SET		strCode = ''RCON''
		FROM	tblGLDetail 
		WHERE	strCode = ''RWIP''
	');
END

-- Rename RWIP to RCON
IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblGLSummary'))
BEGIN	
	EXEC ('
		UPDATE	tblGLSummary
		SET		strCode = ''RCON''
		FROM	tblGLSummary 
		WHERE	strCode = ''RWIP''
	');
END

-- Change the transaction type from 35 to 36 (Revalue Item Change) 
IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblICInventoryTransaction'))
BEGIN	
	EXEC ('
		update	t
		set		intTransactionTypeId = 36 
		from	tblICInventoryTransaction t inner join tblICInventoryTransactionType ty
					on t.intTransactionTypeId = ty.intTransactionTypeId
				left join tblICInventoryAdjustment a
					on a.strAdjustmentNo = t.strRelatedTransactionId
					and a.intInventoryAdjustmentId = t.intRelatedTransactionId
		where	t.intTransactionTypeId = 35 
				and a.intAdjustmentType = 3
	');
END

-- Change the transaction type from 36 to 37 (Revalue Split Lot)
IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblICInventoryTransaction'))
BEGIN	
	EXEC ('
		update	t
		set		intTransactionTypeId = 37
		from	tblICInventoryTransaction t inner join tblICInventoryTransactionType ty
					on t.intTransactionTypeId = ty.intTransactionTypeId
				left join tblICInventoryAdjustment a
					on a.strAdjustmentNo = t.strRelatedTransactionId
					and a.intInventoryAdjustmentId = t.intRelatedTransactionId
		where	t.intTransactionTypeId = 36 
				and a.intAdjustmentType = 5
	');
END

-- Change the transaction type from 37 to 38 (Revalue Lot Merge)
IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblICInventoryTransaction'))
BEGIN	
	EXEC ('
		update	t
		set		intTransactionTypeId = 38
		from	tblICInventoryTransaction t inner join tblICInventoryTransactionType ty
					on t.intTransactionTypeId = ty.intTransactionTypeId
				left join tblICInventoryAdjustment a
					on a.strAdjustmentNo = t.strRelatedTransactionId
					and a.intInventoryAdjustmentId = t.intRelatedTransactionId
		where	t.intTransactionTypeId = 37 
				and a.intAdjustmentType = 7
	');
END

-- Change the transaction type from 38 to 39 (Revalue Lot Move)
IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblICInventoryTransaction'))
BEGIN	
	EXEC ('
		update	t
		set		intTransactionTypeId = 39
		from	tblICInventoryTransaction t inner join tblICInventoryTransactionType ty
					on t.intTransactionTypeId = ty.intTransactionTypeId
				left join tblICInventoryAdjustment a
					on a.strAdjustmentNo = t.strRelatedTransactionId
					and a.intInventoryAdjustmentId = t.intRelatedTransactionId
		where	t.intTransactionTypeId = 38 
				and a.intAdjustmentType = 8
	');
END


-- Change the transaction type in tblICInventoryLotTransaction
IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblICInventoryLotTransaction'))
BEGIN	
	EXEC ('
		update	lt
		set		lt.intTransactionTypeId = t.intTransactionTypeId
		from	tblICInventoryLotTransaction lt inner join tblICInventoryTransaction t
					on lt.intLotId = t.intLotId
					and lt.intTransactionId = t.intTransactionId
					and lt.strTransactionId = t.strTransactionId
					and lt.strBatchId = t.strBatchId
		where	lt.intTransactionTypeId <> t.intTransactionTypeId
				and t.strTransactionId like ''BL%''
				and t.intTransactionTypeId in (36, 37, 38, 39) 
				and lt.intTransactionTypeId in (35, 36, 37, 38) 
	');
END