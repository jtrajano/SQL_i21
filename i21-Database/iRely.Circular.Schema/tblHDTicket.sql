CREATE TABLE [dbo].[tblHDTicket]
(
	[intTicketId] [int] IDENTITY(1,1) NOT NULL,
	[strTicketNumber] [nvarchar](20) COLLATE Latin1_General_CI_AS NOT NULL,
	[strSubject] [nvarchar](MAX) COLLATE Latin1_General_CI_AS NOT NULL,
	[strSubjectOverride] [nvarchar](255) COLLATE Latin1_General_CI_AS NULL,
	[ysnSendLink] [bit] null,
	[strCustomerNumber] [nvarchar](15) COLLATE Latin1_General_CI_AS NULL,
	[intCustomerContactId] [int] NULL,
	[intCustomerId] [int] NULL,
	[intMilestoneId] [int] NULL,
	[intTicketTypeId] [int] NULL,
	[intTicketStatusId] [int] NULL,
	[intLineOfBusinessId] [int] NULL,
	[strLineOfBusinessId] [nvarchar](255) COLLATE Latin1_General_CI_AS NULL,
	[intOpportunityCampaignId] [int] NULL,
	[intTicketPriorityId] [int] NULL,
	[intTicketProductId] [int] NULL,
	[intModuleId] [int] NULL,
	[intVersionId] [int] NULL,
	[intAssignedTo] [int] NULL,
	[intAssignedToEntity] [int] NULL,
	[intCreatedUserId] [int] NULL,
	[intCreatedUserEntityId] [int] NULL,
	[dtmCreated] [datetime] NULL,
	[dtmDueDate] [datetime] Null,
	[dtmCompleted] [datetime] NULL,
	[intLastModifiedUserId] [int] NULL,
	[intLastModifiedUserEntityId] [int] NULL,
	[intLastCommentedByEntityId] [int] NULL,
	[dtmLastModified] [datetime] NULL,
	[dtmLastCommented] [datetime] NULL,
	[dblQuotedHours] [numeric](18, 6) NULL,
	[dblActualHours] [numeric](18, 6) NULL,
	[strJiraKey] [nvarchar](MAX) COLLATE Latin1_General_CI_AS NULL,
	[strCompany] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strOperatingSystem] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strAcuVersion] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strDatabase] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strType] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strMultipleActivityId] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[intCompanyLocationId] [int] null,
	[intEntityLocationId] [int] null,
	[intSequenceInProject] [int] null,
	[intCurrencyId] [int] null,
	[intCurrencyExchangeRateId] [int] null,
	[intCurrencyExchangeRateTypeId] [int] null,
	[dtmExchangeRateDate] datetime null,
	[dblCurrencyRate] [numeric](18,6) null,
	[intFeedbackWithSolutionId] [int] null,
	[intFeedbackWithRepresentativeId] [int] null,
	[strFeedbackComment] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strDescription] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strResolution] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strImageId] [nvarchar](36) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDTicket] PRIMARY KEY CLUSTERED ([intTicketId] ASC),
	CONSTRAINT [UNQ_tblHDTicketNumber] UNIQUE ([strTicketNumber]),
	CONSTRAINT [FK_Ticket_Milestone] FOREIGN KEY ([intMilestoneId]) REFERENCES [dbo].[tblHDMilestone] ([intMilestoneId]),
    CONSTRAINT [FK_Ticket_TicketType] FOREIGN KEY ([intTicketTypeId]) REFERENCES [dbo].[tblHDTicketType] ([intTicketTypeId]),
    CONSTRAINT [FK_Ticket_TicketStatus] FOREIGN KEY ([intTicketStatusId]) REFERENCES [dbo].[tblHDTicketStatus] ([intTicketStatusId]),
    CONSTRAINT [FK_Ticket_TicketPriority] FOREIGN KEY ([intTicketPriorityId]) REFERENCES [dbo].[tblHDTicketPriority] ([intTicketPriorityId]),
    CONSTRAINT [FK_Ticket_TicketProduct] FOREIGN KEY ([intTicketProductId]) REFERENCES [dbo].[tblHDTicketProduct] ([intTicketProductId]),
    CONSTRAINT [FK_Ticket_Module] FOREIGN KEY ([intModuleId]) REFERENCES [dbo].[tblHDModule] ([intModuleId]),
    CONSTRAINT [FK_Ticket_Version] FOREIGN KEY ([intVersionId]) REFERENCES [dbo].[tblHDVersion] ([intVersionId]),
    CONSTRAINT [FK_Ticket_Customer] FOREIGN KEY ([intCustomerId]) REFERENCES [dbo].[tblARCustomer] ([intEntityId]),
    CONSTRAINT [FK_tblHDTicket_tblSMLineOfBusiness] FOREIGN KEY ([intLineOfBusinessId]) REFERENCES [dbo].[tblSMLineOfBusiness] ([intLineOfBusinessId]),
    --CONSTRAINT [FK_tblHDTicket_ttblHDOpportunityCampaign] FOREIGN KEY ([intOpportunityCampaignId]) REFERENCES [dbo].[tblCRMCampaign] ([intCampaignId]),
    CONSTRAINT [FK_tblHDTicket_tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [dbo].[tblSMCompanyLocation] ([intCompanyLocationId]),
    CONSTRAINT [FK_tblHDTicket_tblEMEntityLocation_intEntityLocationId] FOREIGN KEY ([intEntityLocationId]) REFERENCES [dbo].[tblEMEntityLocation] ([intEntityLocationId]),
    CONSTRAINT [FK_tblHDTicket_tblSMCurrency_intCurrencyId] FOREIGN KEY ([intCurrencyId]) REFERENCES [dbo].[tblSMCurrency] ([intCurrencyID]),
    CONSTRAINT [FK_tblHDTicket_tblSMCurrencyExchangeRate_intCurrencyExchangeRateId] FOREIGN KEY ([intCurrencyExchangeRateId]) REFERENCES [dbo].[tblSMCurrencyExchangeRate] ([intCurrencyExchangeRateId]),
    CONSTRAINT [FK_tblHDTicket_tblSMCurrencyExchangeRateType_intCurrencyExchangeRateTypeId] FOREIGN KEY ([intCurrencyExchangeRateTypeId]) REFERENCES [dbo].[tblSMCurrencyExchangeRateType] ([intCurrencyExchangeRateTypeId])
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
GO



EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Customer Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'intCustomerId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Quoted Hours',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'dblQuotedHours'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Actual Hours',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'dblActualHours'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Milestone Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'intMilestoneId'

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Associated JIRA Key',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'strJiraKey'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Company',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'strCompany'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Customer OS',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'strOperatingSystem'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Customer Acu Version',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'strAcuVersion'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Customer Database',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'strDatabase'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Due Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'dtmDueDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Line Of Business Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'intLineOfBusinessId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date Completed',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'dtmCompleted'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Campaign Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'intOpportunityCampaignId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Lines of Business',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicket',
    @level2type = N'COLUMN',
    @level2name = N'strLineOfBusinessId'