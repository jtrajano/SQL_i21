CREATE TABLE [dbo].[tblTRPostResult](
	[intResult] [int] IDENTITY(1,1) NOT NULL,
	[strBatchId] [nvarchar](55) COLLATE Latin1_General_CI_AS NOT NULL,
	[intTransactionId] [int] NOT NULL,
	[strTransactionId] [nvarchar](40) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] [nvarchar](250) COLLATE Latin1_General_CI_AS NULL,
	[dtmDate] [datetime] NULL,
	[strTransactionType] [nvarchar](40) COLLATE Latin1_General_CI_AS NULL,
	[intUserId] [int] NULL,
	[intEntityId] [int] NULL,
    CONSTRAINT [PK_tblTRPostResult] PRIMARY KEY CLUSTERED ([intResult] ASC),
    CONSTRAINT [UK_tblTRPostResult_1] UNIQUE ([strBatchId] ASC,[intTransactionId] ASC)
)
