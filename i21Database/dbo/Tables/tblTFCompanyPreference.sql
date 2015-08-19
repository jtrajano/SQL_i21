CREATE TABLE [dbo].[tblTFCompanyPreference] (
    [intCompanyPreferenceId] INT            IDENTITY (1, 1) NOT NULL,
    [strCompanyName]         NVARCHAR (300) NULL,
    [strTaxAddress]          NVARCHAR (MAX) NULL,
    [strCity]                NVARCHAR (100) NULL,
    [strState]               NVARCHAR (100) NULL,
    [strZipCode]             NVARCHAR (100) NULL,
    [strContactName]         NVARCHAR (100) NULL,
    [strContactPhone]        NVARCHAR (100) NULL,
    [strContactEmail]        NVARCHAR (100) NULL,
    [intConcurrencyId]       INT            CONSTRAINT [DF_tblTFPreference_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblTFPreference] PRIMARY KEY CLUSTERED ([intCompanyPreferenceId] ASC)
);

