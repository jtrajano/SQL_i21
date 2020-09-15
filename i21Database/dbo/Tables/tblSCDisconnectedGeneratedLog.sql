CREATE TABLE [dbo].[tblSCDisconnectedGeneratedLog]
(
    [intDisconnectedGeneratedLogId] INT IDENTITY(1,1) NOT NULL,
    [intRecordId] INT NOT NULL,
    [intLogId] INT NULL,
    [strType] NVARCHAR(100) NULL,
    [dtmDate] DATETIME NULL,
    [strZipFileName] NVARCHAR(MAX) NULL,
    [strMessage] NVARCHAR(MAX) NULL,
    [strStatus] NVARCHAR(15) NULL, 
    [intConcurrencyId] INT DEFAULT(1),
    CONSTRAINT [PK_dbo.tblSCDisconnectedGeneratedLog] PRIMARY KEY CLUSTERED ([intDisconnectedGeneratedLogId] ASC)

)