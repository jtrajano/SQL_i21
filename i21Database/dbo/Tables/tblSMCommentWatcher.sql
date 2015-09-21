CREATE TABLE [dbo].[tblSMCommentWatcher](
	[intCommentWatcherId] [int] IDENTITY(1,1) NOT NULL,
	[intEntityId] [int] NULL,
	[strScreen] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strRecordNo] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[ysnWatched] [bit] NULL,
	[intConcurrencyId] [int] NOT NULL, 
    CONSTRAINT [PK_tblSMCommentWatcher] PRIMARY KEY ([intCommentWatcherId])
)