CREATE TABLE [dbo].[tblGRSettleContract]
(
	[intSettleContractId] INT NOT NULL IDENTITY,
	[intConcurrencyId] INT NULL,
	[intSettleStorageId] INT NOT NULL, 
    [intContractDetailId] INT NULL,
	[dblUnits] DECIMAL(24, 10) NULL
	CONSTRAINT [PK_tblGRSettleContract_intSettleContractId] PRIMARY KEY ([intSettleContractId]),
	CONSTRAINT [FK_tblGRSettleContract_tblGRSettleStorage_intSettleStorageId] FOREIGN KEY ([intSettleStorageId]) REFERENCES [dbo].[tblGRSettleStorage] ([intSettleStorageId]) ON DELETE CASCADE,	
	CONSTRAINT [FK_tblGRSettleContract_tblCTContractDetail_intContractDetailId] FOREIGN KEY ([intContractDetailId]) REFERENCES [tblCTContractDetail]([intContractDetailId]),	
)