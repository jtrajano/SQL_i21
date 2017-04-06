CREATE TABLE [dbo].[tblCTEvent]
(
	[intEventId] [int] IDENTITY(1,1) NOT NULL,
	[strEventName] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strEventDescription] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[intActionId] INT,
	[strAlertType] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strNotificationType] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[ysnSummarized] bit NULL, 
	[ysnActive] bit NULL, 
	[intDaysToRemind] INT NULL DEFAULT 0, 
	[strReminderCondition] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[intAlertFrequency] INT NULL DEFAULT 0, 
	[strSubject] [nvarchar](200) COLLATE Latin1_General_CI_AS NULL,
	[strMessage] [nvarchar](MAX) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] INT NOT NULL, 
	CONSTRAINT [PK_tblCTEvent_intActionId] PRIMARY KEY CLUSTERED ([intEventId] ASC),
	CONSTRAINT [UK_tblCTEvent_strActionName] UNIQUE ([strEventName]),
	CONSTRAINT [FK_tblCTEvent_tblCTAction_intActionId] FOREIGN KEY ([intActionId]) REFERENCES [tblCTAction]([intActionId])
)
