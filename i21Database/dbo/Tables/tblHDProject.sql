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
	[strProjectStatus] [nvarchar](255) COLLATE Latin1_General_CI_AS NOT NULL,
	[intInternalProjectManager] [int] null,
	[intInternalSalesPerson] [int] null,
	[ysnInitialDataCollectionComplete] [bit] NULL,
	[dtmConfirmedKeystoneDate] [datetime] null,
	[intCustomerProjectManager] [int] null,
	[intCustomerLeadershipSponsor] [int] null,
	[strCustomerKeyProjectGoal] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strCustomModification] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[dtmSalesDate] [datetime] null,
	[dtmSoftwareBillDate] [datetime] null,
	[strSoftwareBillDateComment] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[dtmHardwareOrderDate] [datetime] null,
	[strHardwareOrderDateComment] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[dtmInitialUserGroupDuesInvoice] [datetime] null,
	[ysnReceivedDownPayment] [bit] null,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,

	CONSTRAINT [PK_tblHDProject] PRIMARY KEY CLUSTERED ([intProjectId] ASC),
	CONSTRAINT [UNQ_ProjectName] UNIQUE ([strProjectName]),
    CONSTRAINT [FK_Project_Customer] FOREIGN KEY ([intCustomerId]) REFERENCES [dbo].[tblARCustomer] ([intEntityCustomerId]),
    CONSTRAINT [FK_Project_Contact] FOREIGN KEY ([intCustomerContactId]) REFERENCES [dbo].[tblEntityContact] ([intEntityContactId]),
    CONSTRAINT [FK_Project_TicketType] FOREIGN KEY ([intTicketTypeId]) REFERENCES [dbo].[tblHDTicketType] ([intTicketTypeId]),
    CONSTRAINT [FK_Project_IntProjMgr] FOREIGN KEY ([intInternalProjectManager]) REFERENCES [dbo].[tblEntity] ([intEntityId]),
	CONSTRAINT [FK_Project_IntSalesPerson] FOREIGN KEY ([intInternalSalesPerson]) REFERENCES [dbo].[tblEntity] ([intEntityId]),
	CONSTRAINT [FK_Project_CusProjMgr] FOREIGN KEY ([intCustomerProjectManager]) REFERENCES [dbo].[tblEntityContact] ([intEntityContactId]),
	CONSTRAINT [FK_Project_CusLeadSponsor] FOREIGN KEY ([intCustomerLeadershipSponsor]) REFERENCES [dbo].[tblEntityContact] ([intEntityContactId])
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
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Project Status',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProject',
    @level2type = N'COLUMN',
    @level2name = N'strProjectStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Internal Project Manager',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProject',
    @level2type = N'COLUMN',
    @level2name = N'intInternalProjectManager'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Internal Salesperson',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProject',
    @level2type = N'COLUMN',
    @level2name = N'intInternalSalesPerson'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Initial Data Collection Complete',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProject',
    @level2type = N'COLUMN',
    @level2name = N'ysnInitialDataCollectionComplete'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Confirmed Keystone Dates',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProject',
    @level2type = N'COLUMN',
    @level2name = 'dtmConfirmedKeystoneDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Customer Project Manager',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProject',
    @level2type = N'COLUMN',
    @level2name = N'intCustomerProjectManager'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Customer Leadership Sponsor',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProject',
    @level2type = N'COLUMN',
    @level2name = N'intCustomerLeadershipSponsor'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Customer Key Project Goals',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProject',
    @level2type = N'COLUMN',
    @level2name = 'strCustomerKeyProjectGoal'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Custom Modifications',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProject',
    @level2type = N'COLUMN',
    @level2name = 'strCustomModification'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sales Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProject',
    @level2type = N'COLUMN',
    @level2name = N'dtmSalesDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Software Bill Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProject',
    @level2type = N'COLUMN',
    @level2name = N'dtmSoftwareBillDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Software Bill Date Comment',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProject',
    @level2type = N'COLUMN',
    @level2name = N'strSoftwareBillDateComment'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Hardware Order Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProject',
    @level2type = N'COLUMN',
    @level2name = N'dtmHardwareOrderDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Hardware Order Date Comment',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProject',
    @level2type = N'COLUMN',
    @level2name = N'strHardwareOrderDateComment'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Initial User Group Dues Invoice',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProject',
    @level2type = N'COLUMN',
    @level2name = N'dtmInitialUserGroupDuesInvoice'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Received Down Payment',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProject',
    @level2type = N'COLUMN',
    @level2name = N'ysnReceivedDownPayment'