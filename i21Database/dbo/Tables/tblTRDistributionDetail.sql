CREATE TABLE [dbo].[tblTRDistributionDetail]
(
	[intDistributionDetailId] INT NOT NULL IDENTITY,
	[intDistributionHeaderId] INT NOT NULL,
	[intItemId] INT NOT NULL,	
	[intContractDetailId] INT NULL,
	[dblUnits] DECIMAL(18, 6) NULL DEFAULT 0, 
	[dblPrice] DECIMAL(18, 6) NULL DEFAULT 0, 
	[dblFreightRate] DECIMAL(18, 6) NULL DEFAULT 0,
	[intConcurrencyId] [int] NOT NULL,
	CONSTRAINT [PK_tblTRDistributionDetail] PRIMARY KEY ([intDistributionDetailId]),
	CONSTRAINT [FK_tblTRDistributionDetail_tblTRDistributionHeader_intDistributionHeaderId] FOREIGN KEY ([intDistributionHeaderId]) REFERENCES [dbo].[tblTRDistributionHeader] ([intDistributionHeaderId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblTRDistributionDetail_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [dbo].[tblICItem] ([intItemId]),	
	CONSTRAINT [FK_tblTRDistributionDetail_tblCTContractDetail_intContractDetailId] FOREIGN KEY ([intContractDetailId]) REFERENCES [tblCTContractDetail]([intContractDetailId])
)
