﻿CREATE TABLE [dbo].[tblHDTicketPriority]
(
	[intTicketPriorityId] [int] IDENTITY(1,1) NOT NULL,
	[strPriority] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] [nvarchar](150) COLLATE Latin1_General_CI_AS NOT NULL,
	[ysnTicket] [bit] NULL DEFAULT 0,
	[ysnActivity] [bit] NULL DEFAULT 0,
	[ysnProject] [bit] NULL DEFAULT 0,
	[ysnOpportunity] [bit] NULL DEFAULT 0,
	[ysnDefaultTicket] [bit] NULL DEFAULT 0,
	[ysnDefaultActivity] [bit] NULL DEFAULT 0,
	[ysnDefaultProject] [bit] NULL DEFAULT 0,
	[ysnDefaultOpportunity] [bit] NULL DEFAULT 0,
	[strJIRAPriority] [nvarchar](255) COLLATE Latin1_General_CI_AS NULL,
	[strIcon] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strFontColor] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strBackColor] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[intSort] [int] NULL,
	[intTurnAroundDays] [int] NULL,
	[ysnUpdated] [bit] NULL,
	[intConcurrencyId] [int] NOT NULL,
 CONSTRAINT [PK_tblHDTicketPriority] PRIMARY KEY CLUSTERED ([intTicketPriorityId] ASC),
 CONSTRAINT [UNQ_tblHDTicketPriority] UNIQUE ([strPriority])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketPriority',
    @level2type = N'COLUMN',
    @level2name = N'intTicketPriorityId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Priority Name (Unique)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketPriority',
    @level2type = N'COLUMN',
    @level2name = N'strPriority'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketPriority',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Associated JIRA Priority',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketPriority',
    @level2type = N'COLUMN',
    @level2name = N'strJIRAPriority'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Icon',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketPriority',
    @level2type = N'COLUMN',
    @level2name = N'strIcon'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Font Color',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketPriority',
    @level2type = N'COLUMN',
    @level2name = N'strFontColor'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Background Color',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketPriority',
    @level2type = N'COLUMN',
    @level2name = N'strBackColor'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Order',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketPriority',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketPriority',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Turn Around Days',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketPriority',
    @level2type = N'COLUMN',
    @level2name = N'intTurnAroundDays'