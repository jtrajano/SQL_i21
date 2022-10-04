CREATE TYPE [dbo].[TransferSettlementReferenceStagingTable] AS TABLE
(
	[intTransferSettlementReferenceId] INT
	,[intTransferToSettlementId] INT
	,[intBillFromId] INT
	,[intBillToId] INT
	,[dblTransferPercent] DECIMAL(18,6)
	,[dblSettlementAmount] DECIMAL(18,6)
	,[dblUnits] DECIMAL(38,20)
	,[intTransferToBillId] INT
	,[intAccountId] INT
)