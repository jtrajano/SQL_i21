CREATE TABLE [dbo].[tblCMBankFileFormat] (
    [intBankFileFormatId]   INT            IDENTITY (1, 1) NOT NULL,
    [strName]               NVARCHAR (250) COLLATE Latin1_General_CI_AS NOT NULL,
    [intBankFileType]       INT            DEFAULT 1 NOT NULL,
    [intFileFormat]         INT            DEFAULT 1 NOT NULL,
    [intCreatedUserId]      INT            NULL,
    [dtmCreated]            DATETIME       NULL,
    [intLastModifiedUserId] INT            NULL,
    [dtmLastModified]       DATETIME       NULL,
    [intConcurrencyId]      INT            DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblCMBankFileFormat] PRIMARY KEY CLUSTERED ([intBankFileFormatId] ASC),
    UNIQUE NONCLUSTERED ([strName] ASC)
);

