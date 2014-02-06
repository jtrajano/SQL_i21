CREATE TABLE [dbo].[tblGLCOAImportLogDetail] (
    [intImportLogDetailID] INT            IDENTITY (1, 1) NOT NULL,
    [intImportLogID]       INT            NULL,
    [strEventDescription]  NVARCHAR (200) COLLATE Latin1_General_CI_AS NULL,
    [strPeriod]            NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strSourceNumber]      NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strSourceSystem]      NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strJournalID]         NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]     INT            DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblGLCOAImportLogDetail] PRIMARY KEY CLUSTERED ([intImportLogDetailID] ASC),
    CONSTRAINT [FK_tblGLCOAImportLogDetail_tblGLCOAImportLog] FOREIGN KEY ([intImportLogID]) REFERENCES [dbo].[tblGLCOAImportLog] ([intImportLogID])
);

