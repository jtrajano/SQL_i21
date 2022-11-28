CREATE TABLE [dbo].[tblGRTransferSettlementReference]
(
	[intTransferSettlementReferenceId] INT IDENTITY(1,1)
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
	,CONSTRAINT [PK_tblGRTransferSettlementReference_intTransferSettlementReferenceId] PRIMARY KEY CLUSTERED ([intTransferSettlementReferenceId] ASC)
	,CONSTRAINT [FK_tblGRTransferSettlementReference_tblGRTransferSettlementsHeader_intTransferSettlementHeaderId] FOREIGN KEY ([intTransferSettlementHeaderId]) REFERENCES [dbo].[tblGRTransferSettlementsHeader] ([intTransferSettlementHeaderId]) ON DELETE CASCADE
)

GO