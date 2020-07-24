CREATE TABLE [dbo].[tblSCDisconnectedGeneratedLog]
(
    [intDisconnectedGeneratedLogId] INT IDENTITY(1,1) NOT NULL,
    [intRecordId] INT NOT NULL,
    [intLogId] INT NULL,
    [strType] NVARCHAR(100)  COLLATE Latin1_General_CI_AS NULL ,
    [dtmDate] DATETIME NULL,
    [intConcurrencyId] INT DEFAULT(1),
    CONSTRAINT [PK_dbo.tblSCDisconnectedGeneratedLog] PRIMARY KEY CLUSTERED ([intDisconnectedGeneratedLogId] ASC)

)