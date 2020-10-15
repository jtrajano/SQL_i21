CREATE TABLE [dbo].[tblTFTransactionDynamicMD]
(
	[intTransactionId] [int] NOT NULL,
	[intTransactionDynamicId] [int] IDENTITY(1,1) NOT NULL,	
	[strMDDeliveryMethod] [nvarchar](50) NULL,
	[strMDFreightPaidBy] [nvarchar](100) NULL,
	[strMDConsignorAddress] [nvarchar](250) NULL,
	[strMDProductCode] [nvarchar](50) NULL,
	[strMDTransportationMode] [nvarchar](10) NULL,
	[intConcurrencyId] [int] NULL,
	CONSTRAINT [FK_tblTFTransactionDynamicMD_tblTFTransaction] FOREIGN KEY ([intTransactionId]) REFERENCES [tblTFTransaction]([intTransactionId]) ON DELETE CASCADE,
	CONSTRAINT [PK_tblTFTransactionDynamicMD] PRIMARY KEY ([intTransactionDynamicId])
)

