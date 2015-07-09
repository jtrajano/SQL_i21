CREATE TABLE [dbo].[tblHDOutOfOfficeReply]
(
	[intOutOfOfficeReplyId] [int] IDENTITY(1,1) NOT NULL,
	[intEntityId] [int] NOT NULL,
	[dtmDateFrom] [date] NOT NULL,
	[dtmDateTo] [date] NOT NULL,
	[strMessage] [nvarchar](255) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDOutOfOfficeReply] PRIMARY KEY CLUSTERED ([intOutOfOfficeReplyId] ASC),
    CONSTRAINT [FK_tblHDOutOfOfficeReply_tblEntity] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEntity] ([intEntityId])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDOutOfOfficeReply',
    @level2type = N'COLUMN',
    @level2name = N'intOutOfOfficeReplyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Agent Entity Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDOutOfOfficeReply',
    @level2type = N'COLUMN',
    @level2name = N'intEntityId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Start Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDOutOfOfficeReply',
    @level2type = N'COLUMN',
    @level2name = N'dtmDateFrom'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'End Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDOutOfOfficeReply',
    @level2type = N'COLUMN',
    @level2name = N'dtmDateTo'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Reply Message',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDOutOfOfficeReply',
    @level2type = N'COLUMN',
    @level2name = N'strMessage'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDOutOfOfficeReply',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'