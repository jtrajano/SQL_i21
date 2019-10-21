CREATE TABLE [dbo].[tblGLCOAImportLogDetail] (
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

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOAImportLogDetail', @level2type=N'COLUMN',@level2name=N'intImportLogDetailId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foeign Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOAImportLogDetail', @level2type=N'COLUMN',@level2name=N'intImportLogId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Event Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOAImportLogDetail', @level2type=N'COLUMN',@level2name=N'strEventDescription' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Period' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOAImportLogDetail', @level2type=N'COLUMN',@level2name=N'strPeriod' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Source Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOAImportLogDetail', @level2type=N'COLUMN',@level2name=N'strSourceNumber' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Source System' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOAImportLogDetail', @level2type=N'COLUMN',@level2name=N'strSourceSystem' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fiscal Year' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOAImportLogDetail', @level2type=N'COLUMN',@level2name=N'strFiscalYear' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fiscal Year Period' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOAImportLogDetail', @level2type=N'COLUMN',@level2name=N'strFiscalYearPeriod' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'External Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOAImportLogDetail', @level2type=N'COLUMN',@level2name=N'strExternalId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Line Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOAImportLogDetail', @level2type=N'COLUMN',@level2name=N'strLineNumber' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Transaction Date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOAImportLogDetail', @level2type=N'COLUMN',@level2name=N'strTransactionDate' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Transaction Time' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOAImportLogDetail', @level2type=N'COLUMN',@level2name=N'strTransactionTime' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Reference' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOAImportLogDetail', @level2type=N'COLUMN',@level2name=N'strReference' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Document' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOAImportLogDetail', @level2type=N'COLUMN',@level2name=N'strDocument' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Comments' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOAImportLogDetail', @level2type=N'COLUMN',@level2name=N'strComments' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Debit Credit' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOAImportLogDetail', @level2type=N'COLUMN',@level2name=N'strDebitCredit' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'dec Amount' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOAImportLogDetail', @level2type=N'COLUMN',@level2name=N'decAmount' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'dec Units' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOAImportLogDetail', @level2type=N'COLUMN',@level2name=N'decUnits' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Correction' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOAImportLogDetail', @level2type=N'COLUMN',@level2name=N'blnCorrection' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Journal Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOAImportLogDetail', @level2type=N'COLUMN',@level2name=N'strJournalId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOAImportLogDetail', @level2type=N'COLUMN',@level2name=N'intConcurrencyId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Post Date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOAImportLogDetail', @level2type=N'COLUMN',@level2name=N'dtePostDate' 
GO