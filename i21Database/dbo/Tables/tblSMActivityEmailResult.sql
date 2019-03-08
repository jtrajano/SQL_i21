CREATE TABLE [dbo].[tblSMActivityEmailResult]
(
	[intActivityEmailResultId]          INT NOT NULL PRIMARY KEY IDENTITY,
	[intActivityId]                     INT NOT NULL,
    [strResult]                         NVARCHAR(4000) COLLATE Latin1_General_CI_AS NULL,
    [dtmTransactionDate]                DATETIME NOT NULL DEFAULT(GETDATE()),
    [intEntityUserId]                   INT NULL,
	[intConcurrencyId]		            INT NOT NULL DEFAULT ((1)), 
    CONSTRAINT [FK_tblSMActivityEmailResult_tblSMActivity] FOREIGN KEY ([intActivityId]) REFERENCES [tblSMActivity]([intActivityId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblSMActivityEmailResult_tblEMEntity] FOREIGN KEY ([intEntityUserId]) REFERENCES [tblEMEntity]([intEntityId]) ON DELETE SET NULL,
)