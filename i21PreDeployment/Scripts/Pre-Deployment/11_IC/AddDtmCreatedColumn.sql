IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblICInventoryReturned]') AND type in (N'U')) 
BEGIN 
    IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME = N'dtmCreated' AND OBJECT_ID = OBJECT_ID(N'tblICInventoryReturned')) 
    BEGIN
		EXEC('ALTER TABLE tblICInventoryReturned ADD dtmCreated DATETIME NULL')
    END
    IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME = N'dtmCreated' AND OBJECT_ID = OBJECT_ID(N'tblICInventoryReturned')) 
    BEGIN
		EXEC('
			UPDATE r
			SET 
				r.dtmCreated = t.dtmCreated 
			FROM	
				tblICInventoryReturned r LEFT JOIN tblICInventoryTransaction t
					ON r.intInventoryTransactionId = t.intInventoryTransactionId
			WHERE
				r.dtmCreated IS NULL 				
		')
    END
END 

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblICInventoryActualCostOut]') AND type in (N'U')) 
BEGIN 
    IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME = N'dtmCreated' AND OBJECT_ID = OBJECT_ID(N'tblICInventoryActualCostOut')) 
    BEGIN
		EXEC('ALTER TABLE tblICInventoryActualCostOut ADD dtmCreated DATETIME NULL')
    END
    IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME = N'dtmCreated' AND OBJECT_ID = OBJECT_ID(N'tblICInventoryActualCostOut')) 
    BEGIN
		EXEC('
			UPDATE r
			SET 
				r.dtmCreated = ISNULL(t.dtmCreated, cb.dtmCreated) 
			FROM	
				tblICInventoryActualCostOut r LEFT JOIN tblICInventoryTransaction t
					ON r.intInventoryTransactionId = t.intInventoryTransactionId
				LEFT JOIN tblICInventoryActualCost cb
					ON cb.intInventoryActualCostId = r.intInventoryActualCostId
			WHERE
				r.dtmCreated IS NULL 		
		')
    END
END 

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblICInventoryFIFOOut]') AND type in (N'U')) 
BEGIN 
    IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME = N'dtmCreated' AND OBJECT_ID = OBJECT_ID(N'tblICInventoryFIFOOut')) 
    BEGIN
		EXEC('ALTER TABLE tblICInventoryFIFOOut ADD dtmCreated DATETIME NULL')
    END
    IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME = N'dtmCreated' AND OBJECT_ID = OBJECT_ID(N'tblICInventoryFIFOOut')) 
    BEGIN
		EXEC('
			UPDATE r
			SET 
				r.dtmCreated = ISNULL(t.dtmCreated, cb.dtmCreated)
			FROM	
				tblICInventoryFIFOOut r LEFT JOIN tblICInventoryTransaction t
					ON r.intInventoryTransactionId = t.intInventoryTransactionId
				LEFT JOIN tblICInventoryFIFO cb
					ON cb.intInventoryFIFOId = r.intInventoryFIFOId					
			WHERE
				r.dtmCreated IS NULL 		
		')
    END
END 

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblICInventoryFIFOStorageOut]') AND type in (N'U')) 
BEGIN 
    IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME = N'dtmCreated' AND OBJECT_ID = OBJECT_ID(N'tblICInventoryFIFOStorageOut')) 
    BEGIN
		EXEC('ALTER TABLE tblICInventoryFIFOStorageOut ADD dtmCreated DATETIME NULL')
    END
    IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME = N'dtmCreated' AND OBJECT_ID = OBJECT_ID(N'tblICInventoryFIFOStorageOut')) 
    BEGIN
		EXEC('
			UPDATE r
			SET 
				r.dtmCreated = ISNULL(t.dtmCreated, cb.dtmCreated) 
			FROM	
				tblICInventoryFIFOStorageOut r LEFT JOIN tblICInventoryTransactionStorage t
					ON r.intInventoryTransactionStorageId = t.intInventoryTransactionStorageId
				LEFT JOIN tblICInventoryFIFOStorage cb
					ON cb.intInventoryFIFOStorageId = r.intInventoryFIFOStorageId
			WHERE
				r.dtmCreated IS NULL 		
		')
    END
END 

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblICInventoryLIFOOut]') AND type in (N'U')) 
BEGIN 
    IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME = N'dtmCreated' AND OBJECT_ID = OBJECT_ID(N'tblICInventoryLIFOOut')) 
    BEGIN
		EXEC('ALTER TABLE tblICInventoryLIFOOut ADD dtmCreated DATETIME NULL')
    END
    IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME = N'dtmCreated' AND OBJECT_ID = OBJECT_ID(N'tblICInventoryLIFOOut')) 
    BEGIN
		EXEC('
			UPDATE r
			SET 
				r.dtmCreated = ISNULL(t.dtmCreated, cb.dtmCreated) 
			FROM	
				tblICInventoryLIFOOut r LEFT JOIN tblICInventoryTransaction t
					ON r.intInventoryTransactionId = t.intInventoryTransactionId
				LEFT JOIN tblICInventoryLIFO cb
					ON cb.intInventoryLIFOId = r.intInventoryLIFOId
			WHERE
				r.dtmCreated IS NULL 		
		')
    END
END 

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblICInventoryLIFOStorageOut]') AND type in (N'U')) 
BEGIN 
    IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME = N'dtmCreated' AND OBJECT_ID = OBJECT_ID(N'tblICInventoryLIFOStorageOut')) 
    BEGIN
		EXEC('ALTER TABLE tblICInventoryLIFOStorageOut ADD dtmCreated DATETIME NULL')
    END
    IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME = N'dtmCreated' AND OBJECT_ID = OBJECT_ID(N'tblICInventoryLIFOStorageOut')) 
    BEGIN
		EXEC('
			UPDATE r
			SET 
				r.dtmCreated = ISNULL(t.dtmCreated, cb.dtmCreated) 
			FROM	
				tblICInventoryLIFOStorageOut r LEFT JOIN tblICInventoryTransactionStorage t
					ON r.intInventoryTransactionStorageId = t.intInventoryTransactionStorageId
				LEFT JOIN tblICInventoryLIFOStorage cb
					ON cb.intInventoryLIFOStorageId = r.intInventoryLIFOStorageId
			WHERE
				r.dtmCreated IS NULL 		
		')
    END
END 

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblICInventoryLotOut]') AND type in (N'U')) 
BEGIN 
    IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME = N'dtmCreated' AND OBJECT_ID = OBJECT_ID(N'tblICInventoryLotOut')) 
    BEGIN
		EXEC('ALTER TABLE tblICInventoryLotOut ADD dtmCreated DATETIME NULL')
    END
    IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME = N'dtmCreated' AND OBJECT_ID = OBJECT_ID(N'tblICInventoryLotOut')) 
    BEGIN
		EXEC('
			UPDATE r
			SET 
				r.dtmCreated = ISNULL(t.dtmCreated, cb.dtmCreated) 
			FROM	
				tblICInventoryLotOut r LEFT JOIN tblICInventoryTransaction t
					ON r.intInventoryTransactionId = t.intInventoryTransactionId
				LEFT JOIN tblICInventoryLot cb
					ON cb.intInventoryLotId = r.intInventoryLotId
			WHERE
				r.dtmCreated IS NULL 		
		')
    END
END 

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblICInventoryLotStorageOut]') AND type in (N'U')) 
BEGIN 
    IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME = N'dtmCreated' AND OBJECT_ID = OBJECT_ID(N'tblICInventoryLotStorageOut')) 
    BEGIN
		EXEC('ALTER TABLE tblICInventoryLotStorageOut ADD dtmCreated DATETIME NULL')
    END
    IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME = N'dtmCreated' AND OBJECT_ID = OBJECT_ID(N'tblICInventoryLotStorageOut')) 
    BEGIN
		EXEC('
			UPDATE r
			SET 
				r.dtmCreated = ISNULL(t.dtmCreated, cb.dtmCreated) 
			FROM	
				tblICInventoryLotStorageOut r LEFT JOIN tblICInventoryTransactionStorage t
					ON r.intInventoryTransactionStorageId = t.intInventoryTransactionStorageId
				LEFT JOIN tblICInventoryLotStorage cb
					ON cb.intInventoryLotStorageId = r.intInventoryLotStorageId				
			WHERE
				r.dtmCreated IS NULL 		
		')
    END
END 