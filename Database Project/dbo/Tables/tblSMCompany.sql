CREATE TABLE [dbo].[tblSMCompany] (
    [intCompanyID] INT            IDENTITY (1, 1) NOT NULL,
    [strName]      NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strAddress]   NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strZipCode]   NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strCity]      NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strState]     NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strCountry]   NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strPhone]     NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strFax]       NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strEmail]     NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strWebsite]   NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT NOT NULL DEFAULT (1), 
    CONSTRAINT [PK_Company] PRIMARY KEY CLUSTERED ([intCompanyID] ASC)
);

