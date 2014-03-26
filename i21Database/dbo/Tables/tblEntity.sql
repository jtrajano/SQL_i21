CREATE TABLE [dbo].[tblEntity] (
    [intEntityId]      INT            IDENTITY (1, 1) NOT NULL,
    [strName]          NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NOT NULL,
    [strWebsite]       NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NOT NULL,
    [strInternalNotes] NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NOT NULL,
    [ysnPrint1099]     BIT            NULL,
    [str1099Name]      NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [str1099Form]      NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [str1099Type]      NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strFederalTaxId]  NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [dtmW9Signed]      DATETIME       NULL,
    [intConcurrencyId] INT            CONSTRAINT [DF_tblEntity_intConcurrencyId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dbo.tblEntity] PRIMARY KEY CLUSTERED ([intEntityId] ASC)
);

