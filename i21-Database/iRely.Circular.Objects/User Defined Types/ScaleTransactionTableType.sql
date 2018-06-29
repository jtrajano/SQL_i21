/*
	This is a user-defined table type used in the scale ticket posting stored procedures. 
*/
CREATE TYPE [dbo].[ScaleTransactionTableType] AS TABLE
(
	[intTicketId] INT NULL,
	[intContractDetailId] INT NULL,
	[dblUnitsDistributed] NUMERIC(38, 20) NULL,
	[dblUnitsRemaining] NUMERIC(38, 20) NULL,
	[dblCost] NUMERIC(38, 20) NULL,
	[intCurrencyId] INT NULL
)
