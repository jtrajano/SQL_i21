CREATE TABLE [dbo].[tblTFTransactionDynamicOR]
(
	[intTransactionId] INT NOT NULL , 
    [intTransactionDynamicId] INT IDENTITY NOT NULL, 
    [strOriginAltFacilityNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [strDestinationAltFacilityNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [strAltDocumentNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [strExplanation] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [strInvoiceNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
	[strBeginningReading] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL,
	[strEndingReading] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL,
	[strLicenseNumber] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL,
	[strLicenseState] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL,
	[strPumpNumber] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL,
	[strTransferType] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblTFTransactionDynamicOR] PRIMARY KEY ([intTransactionDynamicId]), 
    CONSTRAINT [FK_tblTFTransactionDynamicOR_tblTFTransaction] FOREIGN KEY ([intTransactionId]) REFERENCES [tblTFTransaction]([intTransactionId]) ON DELETE CASCADE
)
