CREATE TABLE tblGRSettleContractPriceFixationDetail
(
	intSettleContractPriceFixationDetailId INT IDENTITY(1,1)
	,intSettleStorageId INT
	,intSettleContractId INT
	,intPriceFixationDetailId INT
	,dblUnits DECIMAL(38,20)
	,dblCashPrice DECIMAL(38,20)
    ,intContractDetailId INT
	,CONSTRAINT [PK_tblGRSettleContractPriceFixationDetail_intSettleContractPriceFixationDetailId] PRIMARY KEY ([intSettleContractPriceFixationDetailId])
	,CONSTRAINT [FK_tblGRSettleContractPriceFixationDetail_tblGRSettleStorage_intSettleStorageId] FOREIGN KEY ([intSettleStorageId]) REFERENCES [dbo].[tblGRSettleStorage] ([intSettleStorageId]) ON DELETE CASCADE
)
GO

CREATE NONCLUSTERED INDEX IX_tblGRSettleContractPriceFixationDetail_intPriceFixationDetailId
	ON tblGRSettleContractPriceFixationDetail (intPriceFixationDetailId ASC);
GO