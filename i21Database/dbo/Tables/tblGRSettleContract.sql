CREATE TABLE [dbo].[tblGRSettleContract]
(
	[intSettleContractId] INT NOT NULL IDENTITY,
	[intConcurrencyId] INT NULL,
	[intSettleStorageId] INT NOT NULL, 
    [intContractDetailId] INT NULL,
	[dblUnits] DECIMAL(24, 10) NULL,
	[dblPrice] DECIMAL(24, 10) NULL,
	[dblCost] DECIMAL(24, 10) NULL,
	CONSTRAINT [PK_tblGRSettleContract_intSettleContractId] PRIMARY KEY ([intSettleContractId]),
	CONSTRAINT [FK_tblGRSettleContract_tblGRSettleStorage_intSettleStorageId] FOREIGN KEY ([intSettleStorageId]) REFERENCES [dbo].[tblGRSettleStorage] ([intSettleStorageId]) ON DELETE CASCADE,	
	CONSTRAINT [FK_tblGRSettleContract_tblCTContractDetail_intContractDetailId] FOREIGN KEY ([intContractDetailId]) REFERENCES [tblCTContractDetail]([intContractDetailId]),	
)
GO
CREATE NONCLUSTERED INDEX [IX_tblGRSettleContract_intSettleStorageId] ON [dbo].[tblGRSettleContract](
	[intSettleStorageId] ASC
);
GO
CREATE NONCLUSTERED INDEX [IX_tblGRSettleContract_intContractDetailId] ON [dbo].[tblGRSettleContract](
	[intContractDetailId] ASC
);
GO