CREATE TABLE [dbo].[tblTFTransactionDynamicOR]
(
	[intTransactionId] INT NOT NULL , 
    [intTransactionDynamicId] INT IDENTITY NOT NULL, 
    [strOriginAltFacilityNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [strDestinationAltFacilityNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [strAltDocumentNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [strExplanation] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [strInvoiceNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblTFTransactionDynamicOR] PRIMARY KEY ([intTransactionDynamicId]), 
    CONSTRAINT [FK_tblTFTransactionDynamicOR_tblTFTransaction] FOREIGN KEY ([intTransactionId]) REFERENCES [tblTFTransaction]([intTransactionId]) ON DELETE CASCADE
)
