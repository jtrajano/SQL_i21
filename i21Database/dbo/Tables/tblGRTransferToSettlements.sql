CREATE TABLE [dbo].[tblGRTransferToSettlements]
(
	[intTransferToSettlementId] INT IDENTITY(1,1)
	,[intTransferSettlementHeaderId] INT
	--,[intTransferFromSettlementId] INT
	,[intEntityId] INT	
	,[dblTotalTransferPercent] DECIMAL(18,6)
	,[dblTotalSettlementAmount] DECIMAL(18,6)
	,[dblTotalUnits] DECIMAL(38,20)
	,[intConcurrencyId] INT DEFAULT(1)
	,CONSTRAINT [PK_tblGRTransferToSettlements_intTransferToSettlementId] PRIMARY KEY CLUSTERED ([intTransferToSettlementId] ASC)
	,CONSTRAINT [FK_tblGRTransferToSettlements_intTransferSettlementHeaderId_intTransferSettlementHeaderId] FOREIGN KEY ([intTransferSettlementHeaderId]) REFERENCES [dbo].tblGRTransferSettlementsHeader ([intTransferSettlementHeaderId]) ON DELETE CASCADE
	--,CONSTRAINT [FK_tblGRTransferToSettlements_intTransferFromSettlementId_intTransferFromSettlementId] FOREIGN KEY ([intTransferFromSettlementId]) REFERENCES [dbo].[tblGRTransferFromSettlements] ([intTransferFromSettlementId])
	,CONSTRAINT [FK_tblGRTransferToSettlements_intEntityId_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].tblEMEntity ([intEntityId])
)

GO