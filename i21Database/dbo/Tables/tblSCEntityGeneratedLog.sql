CREATE TABLE [dbo].[tblSCEntityGeneratedLog]
(
    [intEntityGeneratedLogId] INT IDENTITY(1,1) NOT NULL,
    [intRecordId] INT NOT NULL,
    [intLogId] INT NOT NULL,
    [dtmDate] DATETIME NULL,
    [intConcurrencyId] INT DEFAULT(1),
    CONSTRAINT [PK_dbo.tblSCEntityGeneratedLog] PRIMARY KEY CLUSTERED ([intEntityGeneratedLogId] ASC)

)