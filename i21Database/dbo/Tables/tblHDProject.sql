CREATE TABLE [dbo].[tblHDProject]
(
	[intProjectId] [int] IDENTITY(1,1) NOT NULL,
	[strProjectName] [nvarchar](255) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] [nvarchar](255) COLLATE Latin1_General_CI_AS NULL,
	[intCustomerId] [int] NOT NULL,
	[intCustomerContactId] [int] NOT NULL,
	[intTicketTypeId] [int] NOT NULL,
	[dtmGoLive] [datetime] NULL,
	[intPercentComplete] [int] NULL,
	[ysnCompleted] [bit] NULL,
	[intSort] [int] NULL,
	[ysnActive] [bit] NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,

	CONSTRAINT [PK_tblHDProject] PRIMARY KEY CLUSTERED ([intProjectId] ASC),
	CONSTRAINT [UNQ_ProjectName] UNIQUE ([strProjectName]),
    CONSTRAINT [FK_Project_Customer] FOREIGN KEY ([intCustomerId]) REFERENCES [dbo].[tblARCustomer] ([intCustomerId]),
    CONSTRAINT [FK_Project_Contact] FOREIGN KEY ([intCustomerContactId]) REFERENCES [dbo].[tblEntityContact] ([intContactId]),
    CONSTRAINT [FK_Project_TicketType] FOREIGN KEY ([intTicketTypeId]) REFERENCES [dbo].[tblHDTicketType] ([intTicketTypeId])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Project Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProject',
    @level2type = N'COLUMN',
    @level2name = N'intProjectId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Project Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProject',
    @level2type = N'COLUMN',
    @level2name = N'strProjectName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Project Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProject',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Customer Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProject',
    @level2type = N'COLUMN',
    @level2name = N'intCustomerId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Entity Contact Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProject',
    @level2type = N'COLUMN',
    @level2name = N'intCustomerContactId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProject',
    @level2type = N'COLUMN',
    @level2name = N'intTicketTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Go Live Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProject',
    @level2type = N'COLUMN',
    @level2name = N'dtmGoLive'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Completed',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProject',
    @level2type = N'COLUMN',
    @level2name = N'ysnCompleted'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Order',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProject',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Active',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProject',
    @level2type = N'COLUMN',
    @level2name = N'ysnActive'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProject',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Percent Complete',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProject',
    @level2type = N'COLUMN',
    @level2name = N'intPercentComplete'