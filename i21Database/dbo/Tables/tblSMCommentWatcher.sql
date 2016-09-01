CREATE TABLE [dbo].[tblSMCommentWatcher](
	[intCommentWatcherId] [int] IDENTITY(1,1) NOT NULL,
	[intEntityId] [int] NULL,
	[strScreen] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strRecordNo] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,	
    [intTransactionId] INT NULL, 
	[intActivityId]	INT NULL,
	[intConcurrencyId] [int] NOT NULL, 
    CONSTRAINT [PK_tblSMCommentWatcher] PRIMARY KEY ([intCommentWatcherId]),
	CONSTRAINT [FK_tblSMCommentWatcher_tblSMTransaction] FOREIGN KEY ([intTransactionId]) REFERENCES [tblSMTransaction]([intTransactionId]), 
	CONSTRAINT [FK_tblSMCommentWatcher_tblSMActivity] FOREIGN KEY ([intActivityId]) REFERENCES [tblSMActivity]([intActivityId])
)