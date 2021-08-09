CREATE TABLE [dbo].[tblTFTransactionDynamicFL]
(
	[intTransactionDynamicId] [int] IDENTITY(1,1) NOT NULL,
	[intTransactionId] [int] NOT NULL,
	[strFLCountyCode] [nvarchar](250) COLLATE Latin1_General_CI_AS NULL,
	[strFLCounty] [nvarchar](250) COLLATE Latin1_General_CI_AS NULL,
	[dblFLRate1] [numeric](18, 6) NULL,
	[dblFLRate2] [numeric](18, 6) NULL,
	[dblFLEntitled] [numeric](18, 6) NULL,
	[dblFLNotEntitled] [numeric](18, 6) NULL,
	[intConcurrencyId] [int] NULL,
	CONSTRAINT [FK_tblTFTransactionDynamicFL_tblTFTransaction] FOREIGN KEY ([intTransactionId]) REFERENCES [tblTFTransaction]([intTransactionId]) ON DELETE CASCADE,
	CONSTRAINT [PK_tblTFTransactionDynamicFL] PRIMARY KEY ([intTransactionDynamicId])
)
