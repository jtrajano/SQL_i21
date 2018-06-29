CREATE TABLE [dbo].[tblGRSellContract]
(
	[intSellContractId] INT NOT NULL IDENTITY,
	[intConcurrencyId] INT NULL,
	[intSellOffsiteId] INT NOT NULL, 
    [intContractDetailId] INT NULL,
	[dblUnits] DECIMAL(24, 10) NULL
	CONSTRAINT [PK_tblGRSellContract_intSellContractId] PRIMARY KEY ([intSellContractId]),
	CONSTRAINT [FK_tblGRSellContract_tblGRSellOffsite_intSellOffsiteId] FOREIGN KEY ([intSellOffsiteId]) REFERENCES [dbo].[tblGRSellOffsite] ([intSellOffsiteId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblGRSellContract_tblCTContractDetail_intContractDetailId] FOREIGN KEY ([intContractDetailId]) REFERENCES [tblCTContractDetail]([intContractDetailId]),	
)