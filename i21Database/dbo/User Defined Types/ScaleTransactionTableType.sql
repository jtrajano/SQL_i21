/*
	This is a user-defined table type used in the scale ticket posting stored procedures. 
*/
CREATE TYPE [dbo].[ScaleTransactionTableType] AS TABLE
(
	[intTicketId] INT NULL,
	[intContractDetailId] INT NULL,
	[dblUnitsDistributed] NUMERIC(12, 4) NULL,
	[dblUnitsRemaining] NUMERIC(12, 4) NULL,
	[dblCost] NUMERIC(9, 4) NULL	
)
