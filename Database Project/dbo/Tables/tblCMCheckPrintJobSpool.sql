CREATE TABLE [dbo].[tblCMCheckPrintJobSpool] (
    [intBankAccountID]           INT            NOT NULL,
    [strTransactionID]     NVARCHAR(40)            NOT NULL,
    [strBatchID] NVARCHAR(20)            NOT NULL,
    [strCheckNumber]           NVARCHAR (20) COLLATE Latin1_General_CI_AS NOT NULL,
    [dtmPrintJobCreated]     DATETIME            NULL,
    [dtmCheckPrinted] DATETIME NULL, 
    [intCreatedUserID] INT NULL, 
    CONSTRAINT [PK_tblCMCheckPrintJobSpool] PRIMARY KEY ([strTransactionID])
);

GO
CREATE NONCLUSTERED INDEX [IX_FK_tblCMBankAccounttblCMCheckNumberAudit]
    ON [dbo].[tblCMCheckPrintJobSpool]([strTransactionID] ASC);

