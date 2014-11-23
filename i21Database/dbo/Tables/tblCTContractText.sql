CREATE TABLE [dbo].[tblCTContractText](
	[intContractTextId] [int] IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
	[intContractType] [int] NOT NULL,
	[intContractPriceType] [int] NOT NULL,
	[intTextCode] [int] NOT NULL,
	[strTextDescription] [nvarchar](30) COLLATE Latin1_General_CI_AS NOT NULL,
	[strText] [nvarchar](250) COLLATE Latin1_General_CI_AS NULL,
	[ysnActive] [bit] NOT NULL CONSTRAINT [DF_tblCTContractText_ysnActive]  DEFAULT ((1)),
 CONSTRAINT [PK_tblCTContractText_intContractTextId] PRIMARY KEY CLUSTERED 
(
	[intContractTextId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

