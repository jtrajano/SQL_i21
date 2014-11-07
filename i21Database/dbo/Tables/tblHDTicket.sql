CREATE TABLE [dbo].[tblHDTicket]
(
	[intTicketId] [int] IDENTITY(1,1) NOT NULL,
	[strTicketNumber] [nvarchar](20) COLLATE Latin1_General_CI_AS NOT NULL,
	[strSubject] [nvarchar](MAX) COLLATE Latin1_General_CI_AS NOT NULL,
	[strCustomerNumber] [nvarchar](15) COLLATE Latin1_General_CI_AS NULL,
	[intCustomerContactId] [int] NULL,
	[intTicketTypeId] [int] NOT NULL,
	[intTicketStatusId] [int] NOT NULL,
	[intTicketPriorityId] [int] NOT NULL,
	[intTicketProductId] [int] NULL,
	[intModuleId] [int] NULL,
	[intVersionId] [int] NULL,
	[intAssignedTo] [int] NULL,
	[intAssignedToEntity] [int] NULL,
	[intCreatedUserId] [int] NULL,
	[intCreatedUserEntityId] [int] NULL,
	[dtmCreated] [datetime] NULL,
	[intLastModifiedUserId] [int] NULL,
	[intLastModifiedUserEntityId] [int] NULL,
	[dtmLastModified] [datetime] NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDTicket] PRIMARY KEY CLUSTERED ([intTicketId] ASC),
	CONSTRAINT [UNQ_tblHDTicketNumber] UNIQUE ([strTicketNumber]),
	--CONSTRAINT [UNQ_tblHDTicket] UNIQUE ([strSubject],[intCreatedUserId]),
    CONSTRAINT [FK_Ticket_TicketType] FOREIGN KEY ([intTicketTypeId]) REFERENCES [dbo].[tblHDTicketType] ([intTicketTypeId]),
    CONSTRAINT [FK_Ticket_TicketStatus] FOREIGN KEY ([intTicketStatusId]) REFERENCES [dbo].[tblHDTicketStatus] ([intTicketStatusId]),
    CONSTRAINT [FK_Ticket_TicketPriority] FOREIGN KEY ([intTicketPriorityId]) REFERENCES [dbo].[tblHDTicketPriority] ([intTicketPriorityId]),
    CONSTRAINT [FK_Ticket_TicketProduct] FOREIGN KEY ([intTicketProductId]) REFERENCES [dbo].[tblHDTicketProduct] ([intTicketProductId]),
    CONSTRAINT [FK_Ticket_Module] FOREIGN KEY ([intModuleId]) REFERENCES [dbo].[tblHDModule] ([intModuleId]),
    CONSTRAINT [FK_Ticket_Version] FOREIGN KEY ([intVersionId]) REFERENCES [dbo].[tblHDVersion] ([intVersionId])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'intTicketId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Number (Unique)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'strTicketNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Subject',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'strSubject'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Customer Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'strCustomerNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Customer Contact Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'intCustomerContactId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'intTicketTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Status Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'intTicketStatusId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Priority Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'intTicketPriorityId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Product Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'intTicketProductId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Module Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'intModuleId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Version Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'intVersionId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Assigned To (User Id)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'intAssignedTo'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Assigned To (Entity Id)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'intAssignedToEntity'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Created By (User Id)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'intCreatedUserId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Created By (Entity Id)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'intCreatedUserEntityId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date Created',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'dtmCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Last Modified By (User Id)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'intLastModifiedUserId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Last Modified By (Entity Id)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'intLastModifiedUserEntityId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date Last Modified',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'dtmLastModified'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'