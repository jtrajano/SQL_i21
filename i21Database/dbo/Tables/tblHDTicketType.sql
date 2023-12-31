﻿CREATE TABLE [dbo].[tblHDTicketType]
(
	[intTicketTypeId] [int] IDENTITY(1,1) NOT NULL,
	[strType] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] [nvarchar](150) COLLATE Latin1_General_CI_AS NOT NULL,
	[strJIRAType] [nvarchar](255) COLLATE Latin1_General_CI_AS NULL,
	[strIcon] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[ysnTicket] [bit] NULL,
	[ysnDefaultTicket] [bit] NULL,
	[ysnActivity] [bit] NULL,
	[ysnOpportunity] [bit] NULL,
	[ysnProject] [bit] NULL,
	[ysnDefaultProject] [bit] NULL,
	[ysnCampaign] [bit] NULL,
	[ysnSupported] [bit] NOT NULL DEFAULT 1,
	[intSort] [int] NULL,
	[intConcurrencyId] [int] NOT NULL,
 CONSTRAINT [PK_tblHDTicketType] PRIMARY KEY CLUSTERED ([intTicketTypeId] ASC),
 CONSTRAINT [UNQ_tblHDTicketType] UNIQUE ([strType])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketType',
    @level2type = N'COLUMN',
    @level2name = N'intTicketTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Type Name (Unique)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketType',
    @level2type = N'COLUMN',
    @level2name = N'strType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketType',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Associated JIRA Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketType',
    @level2type = N'COLUMN',
    @level2name = N'strJIRAType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Icon',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketType',
    @level2type = N'COLUMN',
    @level2name = N'strIcon'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Order',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketType',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketType',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'True = show in Ticket screen',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketType',
    @level2type = N'COLUMN',
    @level2name = N'ysnTicket'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'True = show in Activity screen',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketType',
    @level2type = N'COLUMN',
    @level2name = N'ysnActivity'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'True = show in Opportunity screen',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketType',
    @level2type = N'COLUMN',
    @level2name = N'ysnOpportunity'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Supported',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketType',
    @level2type = N'COLUMN',
    @level2name = N'ysnSupported'