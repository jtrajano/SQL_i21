CREATE TABLE [dbo].[tblTFCompanyPreference] (
    [intCompanyPreferenceId] INT            IDENTITY (1, 1) NOT NULL,
    [strCompanyName]         NVARCHAR (300) COLLATE Latin1_General_CI_AS NULL,
    [strTaxAddress]          NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strCity]                NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strState]               NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strZipCode]             NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strContactName]         NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strContactPhone]        NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strContactEmail]        NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]       INT            CONSTRAINT [DF_tblTFPreference_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblTFPreference] PRIMARY KEY CLUSTERED ([intCompanyPreferenceId] ASC)
);

