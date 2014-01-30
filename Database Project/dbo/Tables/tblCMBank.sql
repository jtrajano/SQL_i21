CREATE TABLE [dbo].[tblCMBank] (
	[intBankId]      INT NOT NULL IDENTITY(1, 1),
    [strBankName]           NVARCHAR (250) COLLATE Latin1_General_CI_AS NOT NULL UNIQUE,
    [strContact]            NVARCHAR (150) COLLATE Latin1_General_CI_AS NULL,
    [strAddress]            NVARCHAR (65)  COLLATE Latin1_General_CI_AS NULL,
    [strZipCode]            NVARCHAR (42)  COLLATE Latin1_General_CI_AS NULL,
    [strCity]               NVARCHAR (85)  COLLATE Latin1_General_CI_AS NULL,
    [strState]              NVARCHAR (60)  COLLATE Latin1_General_CI_AS NULL,
    [strCountry]            NVARCHAR (75)  COLLATE Latin1_General_CI_AS NULL,
    [strPhone]              NVARCHAR (30)  COLLATE Latin1_General_CI_AS NULL,
    [strFax]                NVARCHAR (30)  COLLATE Latin1_General_CI_AS NULL,
    [strWebsite]            NVARCHAR (125) COLLATE Latin1_General_CI_AS NULL,
    [strEmail]              NVARCHAR (225) COLLATE Latin1_General_CI_AS NULL,
    [strRTN]                NVARCHAR (12)  COLLATE Latin1_General_CI_AS NULL,
    [intCreatedUserId]      INT            NULL,
    [dtmCreated]            DATETIME       NULL,
    [intLastModifiedUserId] INT            NULL,
    [dtmLastModified]       DATETIME       NULL,
    [intConcurrencyId]      INT            NOT NULL DEFAULT 1,
    CONSTRAINT [PK_tblCMBank] PRIMARY KEY CLUSTERED ([intBankId])
);

