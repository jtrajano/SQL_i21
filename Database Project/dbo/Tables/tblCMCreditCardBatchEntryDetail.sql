CREATE TABLE [dbo].[tblCMCreditCardBatchEntryDetail] (
    [intCreditCardBatchEntryDetailID] INT            IDENTITY (1, 1) NOT NULL,
    [strBatchID]                      NVARCHAR (20)  COLLATE Latin1_General_CI_AS NOT NULL,
    [dtmDate]                         DATETIME       NOT NULL,
    [strPayee]                        NVARCHAR (300) COLLATE Latin1_General_CI_AS NOT NULL,
    [intPayeeID]                      INT            NULL,
    [intGLAccountID]                  INT            NOT NULL,
    [strMemo]                         NVARCHAR (250) COLLATE Latin1_General_CI_AS NOT NULL,
    [strTransactionID]                NVARCHAR (40)  COLLATE Latin1_General_CI_AS NOT NULL,
    [intCreatedUserID]                INT            NULL,
    [dtmCreated]                      DATETIME       NULL,
    [intLastModifiedUserID]           INT            NULL,
    [dtmLastModified]                 DATETIME       NULL,
    [intConcurrencyId]                INT            NOT NULL DEFAULT 1,
    CONSTRAINT [PK_tblCMCreditCardBatchEntryDetail] PRIMARY KEY CLUSTERED ([intCreditCardBatchEntryDetailID] ASC),
    CONSTRAINT [FK_tblCMCreditCardBatchEntrytblCMCreditCardBatchEntryDetail] FOREIGN KEY ([strBatchID]) REFERENCES [dbo].[tblCMCreditCardBatchEntry] ([strBatchID])
);


GO
CREATE NONCLUSTERED INDEX [IX_FK_tblCMCreditCardBatchEntrytblCMCreditCardBatchEntryDetail]
    ON [dbo].[tblCMCreditCardBatchEntryDetail]([strBatchID] ASC);

