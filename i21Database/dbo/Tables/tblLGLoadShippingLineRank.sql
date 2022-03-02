CREATE TABLE [dbo].[tblLGLoadShippingLineRank]
(
	[intLoadShippingLineRankId] INT NOT NULL IDENTITY (1, 1),
	[intLoadId] INT NOT NULL,
	[intRank] INT NULL,
	[intShippingLineEntityId] INT NULL,
	[intShippingLineServiceContractDetailId] INT NULL,
	[intConcurrencyId] INT NOT NULL DEFAULT 0,
	CONSTRAINT [PK_tblLGLoadShippingLineRank_intLoadShippingLineRankId] PRIMARY KEY CLUSTERED ([intLoadShippingLineRankId] ASC),
	CONSTRAINT [FK_tblLGLoadShippingLineRank_tblLGLoad_intLoadId] FOREIGN KEY ([intLoadId]) REFERENCES [dbo].[tblLGLoad] ([intLoadId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblLGLoadShippingLineRank_tblEMEntity_intShippingLineEntityId] FOREIGN KEY ([intShippingLineEntityId]) REFERENCES [dbo].[tblEMEntity] ([intEntityId]),
	CONSTRAINT [FK_tblLGLoadShippingLineRank_tblLGShippingLineServiceContractDetail_intShippingLineServiceContractDetailId] 
		FOREIGN KEY ([intShippingLineServiceContractDetailId]) REFERENCES [dbo].[tblLGShippingLineServiceContractDetail] ([intShippingLineServiceContractDetailId])
)
