﻿CREATE TABLE [dbo].[tblCFImportFromCSVLog] (
    [intImportFromCSVId] INT            IDENTITY (1, 1) NOT NULL,
    [strImportFromCSVId] NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strNote]            NVARCHAR (500) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]   INT            CONSTRAINT [DF_tblCFImportFromCSVLog_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFImportFromCSVLog] PRIMARY KEY CLUSTERED ([intImportFromCSVId] ASC)
);

