CREATE TYPE [dbo].[TMOrderHistoryStagingTable] AS TABLE
(
	 [intDispatchId]					INT	NOT NULL				-- Order/Dispatch Id
	,[ysnDelete]						BIT	DEFAULT 1 NOT NULL		-- Delete/Restore Record
	,[intSourceType]					INT NULL					--	Valid Values
																	--	1-"Invoice"
																	--	2-"Transport Load"
	,[intDeliveryHistoryId]				INT NULL	
)
