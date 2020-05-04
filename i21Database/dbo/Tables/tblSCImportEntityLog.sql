CREATE TABLE [dbo].[tblSCImportEntityLog]
(
    [intImportEntityLogId] INT IDENTITY(1,1) NOT NULL,
    [strFileName] NVARCHAR(MAX) NULL,
    [dtmDate] DATETIME NOT NULL,
    [intConcurrencyId] INT NOT NULL DEFAULT(0)
    CONSTRAINT [PK_dbo.tblSCImportEntityLog] PRIMARY KEY CLUSTERED ([intImportEntityLogId] ASC)

)