CREATE TABLE [dbo].[tblCFTransactionNote] (
    [intTransactionNoteId] INT            IDENTITY (1, 1) NOT NULL,
    [intTransactionId]     INT            NULL,
    [strProcess]           NVARCHAR (50)  NULL,
    [dtmProcessDate]       DATETIME       NULL,
    [strNote]              NVARCHAR (MAX) NULL,
    [strGuid]              NVARCHAR (MAX) NULL,
    [intConcurrencyId]     INT            CONSTRAINT [DF_tblCFTransactionNote_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFTransactionNote] PRIMARY KEY CLUSTERED ([intTransactionNoteId] ASC),
    CONSTRAINT [FK_tblCFTransactionNote_tblCFTransaction] FOREIGN KEY ([intTransactionId]) REFERENCES [dbo].[tblCFTransaction] ([intTransactionId]) ON DELETE CASCADE
);



