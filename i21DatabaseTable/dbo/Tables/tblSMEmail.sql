CREATE TABLE [dbo].[tblSMEmail]
(
	[intEmailId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intEntityId] INT NOT NULL,
	[intSenderId] INT NULL,
	[strScreen] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strSubject] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
    [strMessage] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL,
	[strImageId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strMessageType] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL,
	[strStatus] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL,
	[strFilter] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL,
	[dtmDate] DATETIME NOT NULL,
	[intActivityId] INT NULL,
    [intConcurrencyId] INT NOT NULL DEFAULT 1, 
    CONSTRAINT [FK_tblSMEmail_tblEMEntity] FOREIGN KEY ([intEntityId]) REFERENCES [tblEMEntity]([intEntityId]),
	CONSTRAINT [FK_tblSMEmail_tblSMActivity] FOREIGN KEY ([intActivityId]) REFERENCES [tblSMActivity]([intActivityId]),
	CONSTRAINT [FK_tblSMEmail_tblEMEntitySender] FOREIGN KEY ([intSenderId]) REFERENCES [tblEMEntity]([intEntityId])
)
