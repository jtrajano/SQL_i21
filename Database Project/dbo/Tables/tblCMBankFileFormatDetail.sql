CREATE TABLE [dbo].[tblCMBankFileFormatDetail] (
    [intBankFileFormatDetailId] INT            IDENTITY (1, 1) NOT NULL,
    [intBankFileFormatId]       INT            NOT NULL,
    [intRecordType]             INT            NOT NULL DEFAULT 1,
    [intFieldNo]                INT            NOT NULL DEFAULT 1,
    [intFieldLength]            INT            NOT NULL DEFAULT 0,
    [intFieldType]              INT            NOT NULL DEFAULT 1,
    [strFieldDescription]       NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strFieldName]              NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strFieldFormat]            NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [intFieldFillerSide]        INT            NOT NULL DEFAULT 1,
    [ysnFieldActive]            BIT            NOT NULL DEFAULT 1,
    [intCreatedUserId]          INT            NULL,
    [dtmCreated]                DATETIME       NULL,
    [intLastModifiedUserId]     INT            NULL,
    [dtmLastModified]           DATETIME       NULL,
    [intConcurrencyId]          INT            NOT NULL DEFAULT 1,
    CONSTRAINT [PK_tblCMBankFileFormatDetail] PRIMARY KEY CLUSTERED ([intBankFileFormatDetailId] ASC),
    CONSTRAINT [FK_tblCMBankFileFormattblCMBankFileFormatDetail] FOREIGN KEY ([intBankFileFormatId]) REFERENCES [dbo].[tblCMBankFileFormat] ([intBankFileFormatId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_tblCMBankFileFormatDetail_intBankFileFormatId]
    ON [dbo].[tblCMBankFileFormatDetail]([intBankFileFormatId] ASC);

