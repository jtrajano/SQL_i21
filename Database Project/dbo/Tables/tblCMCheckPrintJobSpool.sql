CREATE TABLE [dbo].[tblCMCheckPrintJobSpool] (
    [intBankAccountId]			INT NOT NULL,
	[intTransactionId]			INT NOT NULL,
    [strTransactionId]			NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL,
    [strBatchId]				NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL,
    [strCheckNo]				NVARCHAR (20) COLLATE Latin1_General_CI_AS NOT NULL,
    [dtmPrintJobCreated]		DATETIME NULL,
    [dtmCheckPrinted]			DATETIME NULL, 
    [intCreatedUserId]			INT NULL, 
    [ysnFail]					BIT NOT NULL DEFAULT 0, 
    [strReason]					NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, 
    CONSTRAINT [PK_tblCMCheckPrintJobSpool] PRIMARY KEY ([strTransactionId])
);

GO
CREATE NONCLUSTERED INDEX [IX_tblCMCheckNumberAudit_intTransactionId]
    ON [dbo].[tblCMCheckPrintJobSpool]([intTransactionId] ASC);

GO
CREATE NONCLUSTERED INDEX [IX_tblCMCheckNumberAudit_strTransactionId]
    ON [dbo].[tblCMCheckPrintJobSpool]([strTransactionId] ASC);

GO
CREATE NONCLUSTERED INDEX [IX_tblCMCheckNumberAudit_strBatchId]
    ON [dbo].[tblCMCheckPrintJobSpool]([strBatchId] ASC);

GO

CREATE NONCLUSTERED INDEX [IX_tblCMCheckNumberAudit_strCheckNo]
    ON [dbo].[tblCMCheckPrintJobSpool]([strCheckNo] ASC);

GO
