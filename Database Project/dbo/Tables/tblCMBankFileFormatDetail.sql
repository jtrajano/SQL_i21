CREATE TABLE [dbo].[tblCMBankFileFormatDetail] (
    [intBankFileFormatDetailID] INT            IDENTITY (1, 1) NOT NULL,
    [intBankFileFormatID]       INT            NOT NULL,
    [intRecordType]             INT            NOT NULL,
    [intFieldNo]                INT            NOT NULL,
    [intFieldLength]            INT            NOT NULL,
    [intFieldType]              INT            NOT NULL,
    [strFieldDescription]       NVARCHAR (250) COLLATE Latin1_General_CI_AS NOT NULL,
    [strFieldName]              NVARCHAR (100) COLLATE Latin1_General_CI_AS NOT NULL,
    [strFieldFormat]            NVARCHAR (100) COLLATE Latin1_General_CI_AS NOT NULL,
    [intFieldFillerSide]        INT            NOT NULL,
    [ysnFieldActive]            BIT            NOT NULL,
    [intCreatedUserID]          INT            NULL,
    [dtmCreated]                DATETIME       NULL,
    [intLastModifiedUserID]     INT            NULL,
    [dtmLastModified]           DATETIME       NULL,
    [intConcurrencyId]          INT            NOT NULL DEFAULT 1,
    CONSTRAINT [PK_tblCMBankFileFormatDetail] PRIMARY KEY CLUSTERED ([intBankFileFormatDetailID] ASC),
    CONSTRAINT [FK_tblCMBankFileFormattblCMBankFileFormatDetail] FOREIGN KEY ([intBankFileFormatID]) REFERENCES [dbo].[tblCMBankFileFormat] ([intBankFileFormatID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_FK_tblCMBankFileFormattblCMBankFileFormatDetail]
    ON [dbo].[tblCMBankFileFormatDetail]([intBankFileFormatID] ASC);

