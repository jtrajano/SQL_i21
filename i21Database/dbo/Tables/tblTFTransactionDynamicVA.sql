CREATE TABLE [dbo].[tblTFTransactionDynamicVA]
(
	[intTransactionDynamicId] [int] IDENTITY(1,1) NOT NULL,	
	[intTransactionId] [int] NOT NULL,
	[strVALocalityCode] [nvarchar](10) NULL,
	[strVALocalityName] [nvarchar](150) NULL,
	[strVADestinationAddress] [nvarchar](250) NULL,
	[strVADestinationZipCode] [nvarchar](10) NULL,
	[strVAReturnType] [nvarchar](5) NULL,
	[intConcurrencyId] [int] NULL,
	CONSTRAINT [FK_tblTFTransactionDynamicVA_tblTFTransaction] FOREIGN KEY ([intTransactionId]) REFERENCES [tblTFTransaction]([intTransactionId]) ON DELETE CASCADE,
	CONSTRAINT [PK_tblTFTransactionDynamicVA] PRIMARY KEY ([intTransactionDynamicId])
)
