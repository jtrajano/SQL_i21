CREATE TABLE [dbo].[tblCMBankFileFormat] (
    [intBankFileFormatId]   INT            IDENTITY (1, 1) NOT NULL,
    [strName]               NVARCHAR (250) COLLATE Latin1_General_CI_AS NOT NULL UNIQUE,
    [intBankFileType]       INT            NOT NULL DEFAULT 1,
    [intFileFormat]         INT            NOT NULL DEFAULT 1,
    [intCreatedUserId]      INT            NULL,
    [dtmCreated]            DATETIME       NULL,
    [intLastModifiedUserId] INT            NULL,
    [dtmLastModified]       DATETIME       NULL,
    [intConcurrencyId]      INT            NOT NULL DEFAULT 1,
    CONSTRAINT [PK_tblCMBankFileFormat] PRIMARY KEY CLUSTERED ([intBankFileFormatId] ASC)
);

