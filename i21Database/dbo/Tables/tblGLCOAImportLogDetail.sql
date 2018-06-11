﻿CREATE TABLE [dbo].[tblGLCOAImportLogDetail] (
    [intImportLogDetailId] INT            IDENTITY (1, 1) NOT NULL,
    [intImportLogId]       INT            NULL,
    [strEventDescription]  NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strPeriod]            NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strSourceNumber]      NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strSourceSystem]      NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
	[strFiscalYear] NVARCHAR(4) COLLATE Latin1_General_CI_AS NULL,
	[strFiscalYearPeriod] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL,
	[strExternalId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strLineNumber] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL,
	[strTransactionDate] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL,
	[strTransactionTime] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL,
	[strReference] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strDocument] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strComments] NVARCHAR(max) COLLATE Latin1_General_CI_AS NULL,
	[strDebitCredit] NVARCHAR(1) COLLATE Latin1_General_CI_AS NULL,
	[decAmount] [decimal](11, 2) NULL,
	[decUnits] [decimal](16, 4) NULL,
	[blnCorrection] [bit] NULL,
	[strJournalId]         NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]     INT            DEFAULT 1 NOT NULL,
    [dtePostDate] DATE NULL, 
    CONSTRAINT [PK_tblGLCOAImportLogDetail] PRIMARY KEY CLUSTERED ([intImportLogDetailId] ASC),
    CONSTRAINT [FK_tblGLCOAImportLogDetail_tblGLCOAImportLog] FOREIGN KEY ([intImportLogId]) REFERENCES [dbo].[tblGLCOAImportLog] ([intImportLogId])
);
GO

