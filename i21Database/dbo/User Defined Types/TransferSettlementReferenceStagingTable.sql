CREATE TYPE [dbo].[TransferSettlementReferenceStagingTable] AS TABLE
(
	[intTransferSettlementReferenceId] INT
	,[intTransferSettlementHeaderId] INT
	,[intTransferToSettlementId] INT
	,[intBillFromId] INT
	,[intBillDetailFromId] INT
	,[intBillToId] INT
	,[dblTransferPercent] DECIMAL(18,6)
	,[dblSettlementAmount] DECIMAL(18,6)
	,[dblUnits] DECIMAL(38,20)
	,[intTransferToBillId] INT
	,[intAccountId] INT
)