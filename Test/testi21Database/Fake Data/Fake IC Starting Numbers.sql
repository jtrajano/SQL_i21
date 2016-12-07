CREATE PROCEDURE [testi21Database].[Fake IC Starting Numbers]
AS
BEGIN	
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
				,[intNumber]			= 1
				,[strModule]			= N'Posting'
				,[ysnEnable]			= 1
				,[intConcurrencyId]		= 1	
		UNION ALL
		SELECT	[intStartingNumberId]	= 31
				,[strTransactionType]	= N'Inventory Shipment'
				,[strPrefix]			= N'T-INVSHP-'
				,[intNumber]			= 1001
				,[strModule]			= N'Inventory'
				,[ysnEnable]			= 1
				,[intConcurrencyId]		= 1	
		UNION ALL
		SELECT	[intStartingNumberId]	= 78
				,[strTransactionType]	= N'Parent Lot Number'
				,[strPrefix]			= N'PLOT-'
				,[intNumber]			= 1
				,[strModule]			= N'Manufacturing'
				,[ysnEnable]			= 1
				,[intConcurrencyId]		= 1	
END