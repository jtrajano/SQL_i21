CREATE TABLE [dbo].[tblTRLoadDistributionDetail]
(
	[intLoadDistributionDetailId] INT NOT NULL IDENTITY,
	[intLoadDistributionHeaderId] INT NOT NULL,
	[intItemId] INT NOT NULL,	
	[intContractDetailId] INT NULL,
	[dblUnits] DECIMAL(18, 6) NULL DEFAULT 0, 
	[dblPrice] DECIMAL(18, 6) NULL DEFAULT 0, 
	[dblFreightRate] DECIMAL(18, 6) NULL DEFAULT 0,
	[dblDistSurcharge] DECIMAL(18, 6) NULL DEFAULT 0,
	[ysnFreightInPrice] BIT  DEFAULT ((0)) NOT NULL,
	[intTaxGroupId] INT	NULL,
	[strReceiptLink] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL,
	[intLoadDetailId] INT NULL,
	[ysnBlendedItem] BIT NOT NULL DEFAULT((0)),
	[intConcurrencyId] INT NOT NULL,
	CONSTRAINT [PK_tblTRLoadDistributionDetail] PRIMARY KEY ([intLoadDistributionDetailId]),
	CONSTRAINT [FK_tblTRLoadDistributionDetail_tblTRLoadDistributionHeader_intLoadDistributionHeaderId] FOREIGN KEY ([intLoadDistributionHeaderId]) REFERENCES [dbo].[tblTRLoadDistributionHeader] ([intLoadDistributionHeaderId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblTRLoadDistributionDetail_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [dbo].[tblICItem] ([intItemId]),	
	CONSTRAINT [FK_tblTRLoadDistributionDetail_tblCTContractDetail_intContractDetailId] FOREIGN KEY ([intContractDetailId]) REFERENCES [tblCTContractDetail]([intContractDetailId]),
	CONSTRAINT [FK_tblTRLoadDistributionDetail_tblSMTaxGroup_intTaxGroupId] FOREIGN KEY ([intTaxGroupId]) REFERENCES [dbo].[tblSMTaxGroup] ([intTaxGroupId]),
	CONSTRAINT [FK_tblTRLoadDistributionDetail_tblLGLoadDetail_intLoadDetailId] FOREIGN KEY ([intLoadDetailId]) REFERENCES [dbo].[tblLGLoadDetail] ([intLoadDetailId])
)
