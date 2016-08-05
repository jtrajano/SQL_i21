CREATE TABLE [dbo].[tblSMDocumentMessage]
(
	[intDocumentMessageId] INT NOT NULL  IDENTITY, 
    [intTransactionId] INT NOT NULL, 
    [intDocumentMaintenanceId] INT NULL, 
    [strHeaderMessage] NVARCHAR(MAX) NULL, 
    [strFooterMessage] NVARCHAR(MAX) NULL, 
    [dtmDateModified] DATETIME NULL, 
    [intConcurrencyId] INT NOT NULL, 
    CONSTRAINT [PK_tblSMDocumentMessage] PRIMARY KEY ([intDocumentMessageId]), 
    CONSTRAINT [FK_tblSMDocumentMessage_tblSMTransaction] FOREIGN KEY ([intTransactionId]) REFERENCES [tblSMTransaction]([intTransactionId])
)
