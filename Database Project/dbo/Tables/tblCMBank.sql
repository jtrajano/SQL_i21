CREATE TABLE [dbo].[tblCMBank] (
    [strBankName]           NVARCHAR (250) COLLATE Latin1_General_CI_AS NOT NULL,
    [strContact]            NVARCHAR (150) COLLATE Latin1_General_CI_AS NOT NULL,
    [strAddress]            NVARCHAR (60)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strZipCode]            NVARCHAR (42)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strCity]               NVARCHAR (85)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strState]              NVARCHAR (60)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strCountry]            NVARCHAR (75)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strPhone]              NVARCHAR (30)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strFax]                NVARCHAR (30)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strWebsite]            NVARCHAR (125) COLLATE Latin1_General_CI_AS NOT NULL,
    [strEmail]              NVARCHAR (225) COLLATE Latin1_General_CI_AS NOT NULL,
    [strRTN]                NVARCHAR (12)  COLLATE Latin1_General_CI_AS NOT NULL,
    [intCreatedUserID]      INT            NULL,
    [dtmCreated]            DATETIME       NULL,
    [intLastModifiedUserID] INT            NULL,
    [dtmLastModified]       DATETIME       NULL,
    [intConcurrencyID]      INT            NOT NULL,
    CONSTRAINT [PK_tblCMBank] PRIMARY KEY CLUSTERED ([strBankName] ASC)
);

