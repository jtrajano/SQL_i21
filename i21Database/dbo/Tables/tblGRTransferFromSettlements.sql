CREATE TABLE [dbo].[tblGRTransferFromSettlements]
(
	[intTransferFromSettlementId] INT IDENTITY(1,1)
	,[intTransferSettlementHeaderId] INT	
	,[intBillId] INT NULL
	,[intBillDetailId] INT NULL
	,[dblSettlementAmountTransferred] DECIMAL(18, 6)
	,[intCurrencyId] INT
	,[dblUnits] DECIMAL(38,20)
	,[intAccountId] INT
	,[intConcurrencyId] INT DEFAULT(1)
	,CONSTRAINT [PK_tblGRTransferFromSettlements_intTransferFromSettlementId] PRIMARY KEY CLUSTERED ([intTransferFromSettlementId] ASC)
	,CONSTRAINT [FK_tblGRTransferFromSettlements_intTransferSettlementHeaderId_intTransferSettlementHeaderId] FOREIGN KEY ([intTransferSettlementHeaderId]) REFERENCES [dbo].tblGRTransferSettlementsHeader ([intTransferSettlementHeaderId]) ON DELETE CASCADE
)

GO