CREATE TABLE [dbo].[tblRMCompanyInformations] (
    [intCompanyInformationId]   INT            IDENTITY (1, 1) NOT NULL,
    [strCompanyInformationName] NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strName]                   NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strAttention]              NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strAddress]                NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intZip]                    INT            NOT NULL,
    [strCity]                   NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strState]                  NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strCountry]                NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strPhone]                  NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strFax]                    NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strUserName]               NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    CONSTRAINT [PK_dbo.CompanyInformations] PRIMARY KEY CLUSTERED ([intCompanyInformationId] ASC)
);

