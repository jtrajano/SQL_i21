CREATE TABLE [dbo].[tblTFTransactionDynamicGA]
(
	[intTransactionDynamicId] [int] IDENTITY(1,1) NOT NULL,
	[intTransactionId] [int] NOT NULL,
	[strGAOriginAddress] [nvarchar](250) COLLATE Latin1_General_CI_AS NULL,
	[strGADestinationAddress] [nvarchar](250) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] [int] NULL,
	CONSTRAINT [FK_tblTFTransactionDynamicGA_tblTFTransaction] FOREIGN KEY ([intTransactionId]) REFERENCES [tblTFTransaction]([intTransactionId]) ON DELETE CASCADE,
	CONSTRAINT [PK_tblTFTransactionDynamicGA] PRIMARY KEY ([intTransactionDynamicId])
)
