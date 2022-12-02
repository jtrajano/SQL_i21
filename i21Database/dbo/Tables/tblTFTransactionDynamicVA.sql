CREATE TABLE [dbo].[tblTFTransactionDynamicVA]
(
	[intTransactionDynamicId] [int] IDENTITY(1,1) NOT NULL,	
	[intTransactionId] [int] NOT NULL,
	[strVALocalityCode] [nvarchar](10) COLLATE Latin1_General_CI_AS NULL,
	[strVALocalityName] [nvarchar](150) COLLATE Latin1_General_CI_AS NULL,
	[strVADestinationAddress] [nvarchar](250) COLLATE Latin1_General_CI_AS NULL,
	[strVADestinationZipCode] [nvarchar](10) COLLATE Latin1_General_CI_AS NULL,
	[dblVADollarValue] [numeric](18, 6) NULL,
	[intConcurrencyId] [int] NULL,
	CONSTRAINT [FK_tblTFTransactionDynamicVA_tblTFTransaction] FOREIGN KEY ([intTransactionId]) REFERENCES [tblTFTransaction]([intTransactionId]) ON DELETE CASCADE,
	CONSTRAINT [PK_tblTFTransactionDynamicVA] PRIMARY KEY ([intTransactionDynamicId])
)
