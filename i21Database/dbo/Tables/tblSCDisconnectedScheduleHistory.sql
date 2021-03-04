CREATE TABLE [tblSCDisconnectedScheduleHistory]
(
[intHistoryId]  INT IDENTITY (1, 1) ,
[strFrequency] NVARCHAR(MAX) NULL,
[strJobName] NVARCHAR(MAX) NULL,
[dtmDate] DATETIME NULL,
[intConcurrencyId] INT NOT NULL DEFAULT(1),
CONSTRAINT [PK_tblSCDisconnectedScheduleHistory] primary key clustered ([intHistoryId] ASC)

)