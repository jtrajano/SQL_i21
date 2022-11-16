CREATE TYPE [dbo].[TransferFromSettlementStagingTable] AS TABLE
(
	[intTransferFromSettlementId] INT NULL
	,[intTransferSettlementHeaderId] INT NULL
	,[intBillId] INT NULL
	,[intBillDetailId] INT NULL
	,[dblSettlementAmountTransferred] DECIMAL(18, 6) NULL
	,[intCurrencyId] INT NULL
	,[dblUnits] DECIMAL(38,20) NULL
	,[intAccountId] INT NULL
)