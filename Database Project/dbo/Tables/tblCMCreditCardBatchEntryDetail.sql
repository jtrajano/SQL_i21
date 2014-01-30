CREATE TABLE [dbo].[tblCMCreditCardBatchEntryDetail] (
    [intCreditCardBatchEntryDetailId]		INT            IDENTITY (1, 1) NOT NULL,
    [intCreditCardBatchEntryId]				INT			   NOT NULL,
    [dtmDate]								DATETIME       NOT NULL,
    [strPayee]								NVARCHAR (300) COLLATE Latin1_General_CI_AS NULL,
    [intPayeeId]							INT            NULL,
    [intGLAccountId]						INT            NOT NULL,
    [strMemo]								NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
	[intTransactionId]						INT NULL,
    [intCreatedUserId]						INT            NULL,
    [dtmCreated]							DATETIME       NULL,
    [intLastModifiedUserId]					INT            NULL,
    [dtmLastModified]						DATETIME       NULL,
    [intConcurrencyId]						INT            NOT NULL DEFAULT 1,
    CONSTRAINT [PK_tblCMCreditCardBatchEntryDetail] PRIMARY KEY CLUSTERED ([intCreditCardBatchEntryDetailId] ASC),
    CONSTRAINT [FK_tblCMCreditCardBatchEntrytblCMCreditCardBatchEntryDetail] FOREIGN KEY ([intCreditCardBatchEntryId]) REFERENCES [dbo].[tblCMCreditCardBatchEntry] ([intCreditCardBatchEntryId])
);


GO
CREATE NONCLUSTERED INDEX [IX_tblCMCreditCardBatchEntryDetail_intCreditCardBatchEntryId]
    ON [dbo].[tblCMCreditCardBatchEntryDetail]([intCreditCardBatchEntryId] ASC);

GO
CREATE NONCLUSTERED INDEX [IX_tblCMCreditCardBatchEntryDetail_intTransactionId]
    ON [dbo].[tblCMCreditCardBatchEntryDetail]([intTransactionId] ASC);

GO
CREATE NONCLUSTERED INDEX [IX_tblCMCreditCardBatchEntryDetail_intGLAccountId]
    ON [dbo].[tblCMCreditCardBatchEntryDetail]([intGLAccountId] ASC);
