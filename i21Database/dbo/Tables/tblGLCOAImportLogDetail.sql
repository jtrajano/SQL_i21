CREATE TABLE [dbo].[tblGLCOAImportLogDetail] (
    [intImportLogDetailId] INT            IDENTITY (1, 1) NOT NULL,
    [intImportLogId]       INT            NULL,
    [strEventDescription]  NVARCHAR (200) COLLATE Latin1_General_CI_AS NULL,
    [strPeriod]            NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strSourceNumber]      NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strSourceSystem]      NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strJournalId]         NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]     INT            DEFAULT 1 NOT NULL,
    [dtePostDate] DATE NULL, 
    CONSTRAINT [PK_tblGLCOAImportLogDetail] PRIMARY KEY CLUSTERED ([intImportLogDetailId] ASC),
    CONSTRAINT [FK_tblGLCOAImportLogDetail_tblGLCOAImportLog] FOREIGN KEY ([intImportLogId]) REFERENCES [dbo].[tblGLCOAImportLog] ([intImportLogId])
);

