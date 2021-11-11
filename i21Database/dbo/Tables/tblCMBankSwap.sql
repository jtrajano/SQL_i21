

CREATE TABLE [dbo].[tblCMBankSwap](
	[intBankSwapId] [int] IDENTITY(1,1) NOT NULL,
	[intSwapShortId] [int] NULL,
	[intSwapLongId] [int] NULL,
	[ysnLockShort] [bit] NULL,
	[ysnLockLong] [bit] NULL,
	[strBankSwapId] [nvarchar](50) COLLATE Latin1_General_CI_AS  NULL,
	[intConcurrencyId] [int] NULL,
 CONSTRAINT [PK_tblCMBankSwap] PRIMARY KEY CLUSTERED 
(
	[intBankSwapId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

