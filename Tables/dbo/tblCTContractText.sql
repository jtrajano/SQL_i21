CREATE TABLE [dbo].[tblCTContractText](
	[intContractTextId]		INT IDENTITY(1,1) NOT NULL,
	[intCommodityId]		INT	NULL,
	[intContractType]		INT	NULL,
	[intContractPriceType]	INT	NULL,
	[strTextCode]			NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strTextDescription]	NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strText]				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strAmendmentText]		NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[ysnActive]				BIT NOT NULL CONSTRAINT [DF_tblCTContractText_ysnActive]  DEFAULT ((1)),
	[intConcurrencyId]		INT NOT NULL,
 CONSTRAINT [PK_tblCTContractText_intContractTextId] PRIMARY KEY CLUSTERED 
(
	[intContractTextId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY], 
    CONSTRAINT [UQ_tblCTContractText_intCommodityId_intContractType_intContractPriceType_strTextCode] UNIQUE ([intCommodityId],[intContractType],[intContractPriceType],[strTextCode])
) ON [PRIMARY]

GO

