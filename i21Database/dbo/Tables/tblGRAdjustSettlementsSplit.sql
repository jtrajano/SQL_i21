CREATE TABLE [dbo].[tblGRAdjustSettlementsSplit]
(
	[intAdjustSettlementsSplitId] INT NOT NULL IDENTITY(1,1)
	,[intAdjustSettlementId] INT
	,[intBillId] INT
	,CONSTRAINT [PK_tblGRAdjustSettlementsSplit_intAdjustSettlementsSplitId] PRIMARY KEY ([intAdjustSettlementsSplitId])
	,CONSTRAINT [FK_tblGRAdjustSettlementsSplit_intAdjustSettlementId] FOREIGN KEY ([intAdjustSettlementId]) REFERENCES [tblGRAdjustSettlements]([intAdjustSettlementId])
	CONSTRAINT [FK_tblGRAdjustSettlementsSplit_tblGRAdjustSettlements] FOREIGN KEY ([intAdjustSettlementId]) REFERENCES [tblGRAdjustSettlements]([intAdjustSettlementId]) ON DELETE CASCADE  
)

GO