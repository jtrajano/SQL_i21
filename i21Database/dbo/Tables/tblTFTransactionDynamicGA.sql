CREATE TABLE [dbo].[tblTFTransactionDynamicGA]
(
	[intTransactionDynamicId] [int] IDENTITY(1,1) NOT NULL,
	[intTransactionId] [int] NOT NULL,
	[strGAOriginFacilityNumber] [nvarchar](50) NULL,
	[strGAOriginAddress] [nvarchar](250) NULL,
	[strGADestinationFacilityNumber] [nvarchar](50) NULL,
	[strGADestinationAddress] [nvarchar](250) NULL,
	CONSTRAINT [FK_tblTFTransactionDynamicGA_tblTFTransaction] FOREIGN KEY ([intTransactionId]) REFERENCES [tblTFTransaction]([intTransactionId]) ON DELETE CASCADE,
	CONSTRAINT [PK_tblTFTransactionDynamicGA] PRIMARY KEY ([intTransactionDynamicId])
)
