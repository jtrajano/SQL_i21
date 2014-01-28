CREATE TABLE [dbo].[tblFREmailFinancials] (
    [intEmailFinancialID] INT            IDENTITY (1, 1) NOT NULL,
    [strContactID]        NVARCHAR (40)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strContactType]      NVARCHAR (40)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strReportName]       NVARCHAR (255) COLLATE Latin1_General_CI_AS NOT NULL,
    [strIdentifierID]     NVARCHAR (40)  COLLATE Latin1_General_CI_AS NULL,
    [strExtraNotes]       NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strEmail]            NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]    INT            DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblFREmailFinancials] PRIMARY KEY CLUSTERED ([strContactID] ASC, [strContactType] ASC, [strReportName] ASC)
);

