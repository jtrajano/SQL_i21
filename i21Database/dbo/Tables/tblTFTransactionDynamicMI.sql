CREATE TABLE [dbo].[tblTFTransactionDynamicMI]
(
	[intTransactionId] INT NOT NULL , 
    [intTransactionDynamicId] INT IDENTITY NOT NULL, 
    [strMIOriginAddress] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strMIOriginZipCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strMIOriginCountry] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strMIDestinationTCN] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strMIDestinationAddress] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strMIDestinationZipCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strMIDestinationCountry] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [FK_tblTFTransactionDynamicMI_tblTFTransaction] FOREIGN KEY ([intTransactionId]) REFERENCES [tblTFTransaction]([intTransactionId]) ON DELETE CASCADE, 
    CONSTRAINT [PK_tblTFTransactionDynamicMI] PRIMARY KEY ([intTransactionDynamicId])
)
