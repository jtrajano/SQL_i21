﻿CREATE TABLE [dbo].[tblEntity] (
    [intEntityId]      INT             IDENTITY (1, 1) NOT NULL,
    [strName]          NVARCHAR (100)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strEmail]         NVARCHAR (75)   COLLATE Latin1_General_CI_AS CONSTRAINT [DF__tmp_ms_xx__strEm__503E4C21] DEFAULT ('') NOT NULL,
    [strWebsite]       NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [strInternalNotes] NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [ysnPrint1099]     BIT             NULL,
    [str1099Name]      NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [str1099Form]      NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [str1099Type]      NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strFederalTaxId]  NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [dtmW9Signed]      DATETIME        NULL,
    [imgPhoto]         VARBINARY (MAX) NULL,
    [intConcurrencyId] INT             CONSTRAINT [DF__tmp_ms_xx__intCo__5132705A] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dbo.tblEntity] PRIMARY KEY CLUSTERED ([intEntityId] ASC)
);







