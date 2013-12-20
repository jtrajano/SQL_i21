CREATE TABLE [dbo].[tblCMBankFileFormat] (
    [intBankFileFormatID]   INT            IDENTITY (1, 1) NOT NULL,
    [strName]               NVARCHAR (250) COLLATE Latin1_General_CI_AS NOT NULL,
    [intBankFileType]       INT            NOT NULL,
    [intFileFormat]         INT            NOT NULL,
    [intCreatedUserID]      INT            NULL,
    [dtmCreated]            DATETIME       NULL,
    [intLastModifiedUserID] INT            NULL,
    [dtmLastModified]       DATETIME       NULL,
    [intConcurrencyID]      INT            NOT NULL,
    CONSTRAINT [PK_tblCMBankFileFormat] PRIMARY KEY CLUSTERED ([intBankFileFormatID] ASC)
);

