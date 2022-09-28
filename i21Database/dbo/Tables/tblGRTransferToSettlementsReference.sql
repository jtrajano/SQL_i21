CREATE TABLE [dbo].[tblGRTransferSettlementReference]
(
	[intTransferSettlementReferenceId] INT IDENTITY(1,1)
	,[intTransferSettlementHeaderId] INT
	,[intTransferToSettlementId] INT
	,[intBillFromId] INT
	,[intBillToId] INT
	,[dblTransferPercent] DECIMAL(18,6)
	,[dblSettlementAmount] DECIMAL(18,6)
	,[dblUnits] DECIMAL(38,20)
	,[intTransferToBillId] INT
	,CONSTRAINT [PK_tblGRTransferSettlementReference_intTransferSettlementReferenceId] PRIMARY KEY CLUSTERED ([intTransferSettlementReferenceId] ASC)
)

GO