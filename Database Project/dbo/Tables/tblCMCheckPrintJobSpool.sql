CREATE TABLE [dbo].[tblCMCheckPrintJobSpool] (
    [intBankAccountID]			INT NOT NULL,
    [strTransactionID]			NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL,
    [strBatchID]				NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL,
    [strCheckNo]				NVARCHAR (20) COLLATE Latin1_General_CI_AS NOT NULL,
    [dtmPrintJobCreated]		DATETIME NULL,
    [dtmCheckPrinted]			DATETIME NULL, 
    [intCreatedUserID]			INT NULL, 
    [ysnFail]					BIT NOT NULL DEFAULT 0, 
    [strReason]					NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, 
    CONSTRAINT [PK_tblCMCheckPrintJobSpool] PRIMARY KEY ([strTransactionID])
);

GO
CREATE NONCLUSTERED INDEX [IX_FK_tblCMBankAccounttblCMCheckNumberAudit]
    ON [dbo].[tblCMCheckPrintJobSpool]([strTransactionID] ASC);

