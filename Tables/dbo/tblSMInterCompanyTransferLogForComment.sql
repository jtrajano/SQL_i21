CREATE TABLE [dbo].[tblSMInterCompanyTransferLogForComment]
(
	[intInterCompanyTransferLogForCommentId]		INT IDENTITY(1,1) NOT NULL,
	[strTable]										NVARCHAR(250) COLLATE Latin1_General_CI_AS NOT NULL,
	[intSourceRecordId]								INT NOT NULL,
	[intDestinationRecordId]						INT NOT NULL,
	[intDestinationCompanyId]						INT NULL,
	[intSourceActivityId]							INT NULL,
	[intDestinationActivityId]						INT NULL,
	[dtmCreated]									DATETIME NULL DEFAULT(GETDATE())
	
	CONSTRAINT [PK_tblSMInterCompanyTransferLogForComment_intInterCompanyTransferLogForCommentId] PRIMARY KEY CLUSTERED ([intInterCompanyTransferLogForCommentId] ASC)
)
