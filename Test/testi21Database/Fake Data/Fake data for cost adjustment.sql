CREATE PROCEDURE [testi21Database].[Fake data for cost adjustment]
AS
BEGIN
	EXEC [testi21Database].[Fake transactions for item costing]; 
	EXEC [testi21Database].[Fake open fiscal year and accounting periods]; 
		
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransfer', @Identity = 1;	
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryTransferDetail', @Identity = 1;	

	-- Create mock data for the starting number 
	EXEC tSQLt.FakeTable 'dbo.tblSMStartingNumber';	
	INSERT	[dbo].[tblSMStartingNumber] (
			[intStartingNumberId] 
			,[strTransactionType]
			,[strPrefix]
			,[intNumber]
			,[strModule]
			,[ysnEnable]
			,[intConcurrencyId]
	)
	SELECT	[intStartingNumberId]	= 24
			,[strTransactionType]	= N'Lot Number'
			,[strPrefix]			= N'LOT-'
			,[intNumber]			= 10000
			,[strModule]			= 'Inventory'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	UNION ALL
	SELECT	[intStartingNumberId]	= 3
			,[strTransactionType]	= N'Batch Post'
			,[strPrefix]			= N'BATCH-'
			,[intNumber]			= 100001
			,[strModule]			= N'Posting'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1	
	UNION ALL
	SELECT	[intStartingNumberId]	= 41
			,[strTransactionType]	= N'Inventory Transfer'
			,[strPrefix]			= N'INVTRN-'
			,[intNumber]			= 1001
			,[strModule]			= N'Inventory'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1	
END 