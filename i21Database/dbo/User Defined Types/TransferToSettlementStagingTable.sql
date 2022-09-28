CREATE TYPE [dbo].[TransferToSettlementStagingTable] AS TABLE
(
	[intTransferToSettlementId] INT NULL
	,[intTransferSettlementHeaderId] INT NULL
	,[intEntityId] INT NULL
	,[dblTotalTransferPercent] DECIMAL(18,6) NULL
	,[dblTotalSettlementAmount] DECIMAL(18,6) NULL
	,[dblTotalUnits] DECIMAL(38,20) NULL
)