CREATE TABLE [dbo].[tblHDTicketComment]
(
	[intTicketCommentId] [int] IDENTITY(1,1) NOT NULL,
	[intTicketId] [int] NOT NULL,
	[strTicketCommentImageId] [nvarchar](36) COLLATE Latin1_General_CI_AS NULL,
	[strComment] [nvarchar](max) COLLATE Latin1_General_CI_AS NOT NULL,
	[intCreatedUserId] [int] NULL,
	[intCreatedUserEntityId] [int] NULL,
	[dtmCreated] [datetime] NULL,
	[intLastModifiedUserId] [int] NULL,
	[intLastModifiedUserEntityId] [int] NULL,
	[dtmLastModified] [datetime] NULL,
	[ysnSent] [bit] NOT NULL,
	[ysnCreatedByAgent] [bit]  NULL,
	[dtmSent] [datetime] NULL,
	[ysnEncoded] [bit]  NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDTicketComment] PRIMARY KEY CLUSTERED ([intTicketCommentId] ASC),
    CONSTRAINT [FK_TicketComment_Ticket] FOREIGN KEY ([intTicketId]) REFERENCES [dbo].[tblHDTicket] ([intTicketId]) on delete cascade
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketComment',
    @level2type = N'COLUMN',
    @level2name = N'intTicketCommentId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketComment',
    @level2type = N'COLUMN',
    @level2name = N'intTicketId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Comment Image Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketComment',
    @level2type = N'COLUMN',
    @level2name = N'strTicketCommentImageId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Comment',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketComment',
    @level2type = N'COLUMN',
    @level2name = N'strComment'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Created By (User Id)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketComment',
    @level2type = N'COLUMN',
    @level2name = N'intCreatedUserId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Created By (Entity Id)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketComment',
    @level2type = N'COLUMN',
    @level2name = N'intCreatedUserEntityId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date Created',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketComment',
    @level2type = N'COLUMN',
    @level2name = N'dtmCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Last Modified By (User Id)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketComment',
    @level2type = N'COLUMN',
    @level2name = N'intLastModifiedUserId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Last Modified By (Entity Id)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketComment',
    @level2type = N'COLUMN',
    @level2name = N'intLastModifiedUserEntityId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date Last Modified',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketComment',
    @level2type = N'COLUMN',
    @level2name = N'dtmLastModified'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sent?',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketComment',
    @level2type = N'COLUMN',
    @level2name = N'ysnSent'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Created By Agent?',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketComment',
    @level2type = N'COLUMN',
    @level2name = N'ysnCreatedByAgent'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date Sent',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketComment',
    @level2type = N'COLUMN',
    @level2name = N'dtmSent'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Encoded (or Encrypted)?',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketComment',
    @level2type = N'COLUMN',
    @level2name = N'ysnEncoded'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketComment',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'