CREATE TABLE [dbo].[tblCMBankFileFormatDetail] (
    [intBankFileFormatDetailId] INT            IDENTITY (1, 1) NOT NULL,
    [intBankFileFormatId]       INT            NOT NULL,
    [intRecordType]             INT            DEFAULT 1 NOT NULL,
    [intFieldNo]                INT            DEFAULT 1 NOT NULL,
    [intFieldLength]            INT            DEFAULT 0 NOT NULL,
    [intFieldType]              INT            DEFAULT 1 NOT NULL,
    [strFieldDescription]       NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strFieldName]              NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strFieldFormat]            NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [intFieldFillerSide]        INT            DEFAULT 1 NOT NULL,
    [ysnFieldActive]            BIT            DEFAULT 1 NOT NULL,
    [intCreatedUserId]          INT            NULL,
    [dtmCreated]                DATETIME       NULL,
    [intLastModifiedUserId]     INT            NULL,
    [dtmLastModified]           DATETIME       NULL,
    [intConcurrencyId]          INT            DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblCMBankFileFormatDetail] PRIMARY KEY CLUSTERED ([intBankFileFormatDetailId] ASC),
    CONSTRAINT [FK_tblCMBankFileFormattblCMBankFileFormatDetail] FOREIGN KEY ([intBankFileFormatId]) REFERENCES [dbo].[tblCMBankFileFormat] ([intBankFileFormatId]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_tblCMBankFileFormatDetail_intBankFileFormatId]
    ON [dbo].[tblCMBankFileFormatDetail]([intBankFileFormatId] ASC);

