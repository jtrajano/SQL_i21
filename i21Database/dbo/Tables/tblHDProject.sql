CREATE TABLE [dbo].[tblHDProject]
(
	[intProjectId] [int] IDENTITY(1,1) NOT NULL,
	[strProjectName] [nvarchar](255) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] [nvarchar](MAX) COLLATE Latin1_General_CI_AS NULL,
	[intCustomerId] [int] NOT NULL,
	[intCustomerContactId] [int] NOT NULL,
	[intSalesPipeStatusId] [int] NULL,
	[intTicketStatusId] [int] NULL,
	[intOpportunitySourceId] [int] NULL,
	[intTicketTypeId] [int] NULL,
	[intOpportunityCampaignId] [int] NULL,
	[strCompetitorEntityId] [nvarchar](255) COLLATE Latin1_General_CI_AS NULL,
	[strCurrentSolutionId] [nvarchar](255) COLLATE Latin1_General_CI_AS NULL,
	[strCompetitorEntity] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strCurrentSolution] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[intReferredByEntityId] [int] null,
	[dtmCreated] [datetime] NULL,
	[dtmClose] [datetime] NULL,
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
	[ysnGenerateTicket] [bit] null,
	[strType] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strLinesOfBusinessId] [nvarchar](255) COLLATE Latin1_General_CI_AS NULL,
	[strLinesOfBusiness] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strRFPRFILink] [nvarchar](255) COLLATE Latin1_General_CI_AS NULL,
	[dtmLastDescriptionModified] [datetime] null,
	[strDirection] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[intMilestoneId] [int] null,
	[intCompanyLocationId] [int] null,
	[intEntityLocationId] [int] null,
	[strOpportunityWinLossReasonId] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS null,
	[strOpportunityWinLossReason] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS null,
	[dtmWinLossDate] [datetime] null,
	[intWinLossLengthOfCycle] [int] null,
	[strWinLossDetails] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strWinLossDidRight] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strWinLossDidWrong] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strWinLossActionItem] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[intLostToCompetitorId] [int] null,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,

	CONSTRAINT [PK_tblHDProject] PRIMARY KEY CLUSTERED ([intProjectId] ASC),
	CONSTRAINT [UNQ_ProjectName] UNIQUE ([strProjectName], [strType]),
    CONSTRAINT [FK_Project_Customer] FOREIGN KEY ([intCustomerId]) REFERENCES [dbo].[tblEMEntity] ([intEntityId]),
    --CONSTRAINT [FK_Project_Contact] FOREIGN KEY ([intCustomerContactId]) REFERENCES [dbo].[tblEMEntityContact] ([intEntityContactId]),
    CONSTRAINT [FK_Project_Contact] FOREIGN KEY ([intCustomerContactId]) REFERENCES [dbo].tblEMEntity ([intEntityId]),
    CONSTRAINT [FK_Project_TicketType] FOREIGN KEY ([intTicketTypeId]) REFERENCES [dbo].[tblHDTicketType] ([intTicketTypeId]),
    CONSTRAINT [FK_Project_IntProjMgr] FOREIGN KEY ([intInternalProjectManager]) REFERENCES [dbo].tblEMEntity ([intEntityId]),
	CONSTRAINT [FK_Project_IntSalesPerson] FOREIGN KEY ([intInternalSalesPerson]) REFERENCES [dbo].tblEMEntity ([intEntityId]),
	--CONSTRAINT [FK_Project_CusProjMgr] FOREIGN KEY ([intCustomerProjectManager]) REFERENCES [dbo].[tblEMEntityContact] ([intEntityContactId]),
	CONSTRAINT [FK_Project_CusProjMgr] FOREIGN KEY ([intCustomerProjectManager]) REFERENCES [dbo].tblEMEntity ([intEntityId]),
	--CONSTRAINT [FK_Project_CusLeadSponsor] FOREIGN KEY ([intCustomerLeadershipSponsor]) REFERENCES [dbo].[tblEMEntityContact] ([intEntityContactId])
	CONSTRAINT [FK_Project_CusLeadSponsor] FOREIGN KEY ([intCustomerLeadershipSponsor]) REFERENCES [dbo].tblEMEntity ([intEntityId]),
	CONSTRAINT [FK_tblHDProject_tblHDSalesPipeStatus] FOREIGN KEY ([intSalesPipeStatusId]) REFERENCES [dbo].[tblCRMSalesPipeStatus] ([intSalesPipeStatusId]),
	CONSTRAINT [FK_tblHDProject_tblHDTicketStatus] FOREIGN KEY ([intTicketStatusId]) REFERENCES [dbo].[tblHDTicketStatus] ([intTicketStatusId]),
	CONSTRAINT [FK_tblHDProject_tblHDOpportunityCampaign] FOREIGN KEY ([intOpportunityCampaignId]) REFERENCES [dbo].[tblCRMCampaign] ([intCampaignId]),
	CONSTRAINT [FK_tblHDProject_tblHDOpportunitySource] FOREIGN KEY (intOpportunitySourceId) REFERENCES [dbo].[tblCRMSource] ([intSourceId]),
    CONSTRAINT [FK_tblHDProjectProject_tblEMEntity_intReferredByEntityId] FOREIGN KEY ([intReferredByEntityId]) REFERENCES [dbo].[tblEMEntity] ([intEntityId]),
    CONSTRAINT [FK_tblHDProjectProject_tblHDMilestone_intMilestoneId] FOREIGN KEY ([intMilestoneId]) REFERENCES [dbo].[tblHDMilestone] ([intMilestoneId]),
    CONSTRAINT [FK_tblHDProjectProject_tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [dbo].[tblSMCompanyLocation] ([intCompanyLocationId]),
    CONSTRAINT [FK_tblHDProjectProject_tblEMEntityLocation_intEntityLocationId] FOREIGN KEY ([intEntityLocationId]) REFERENCES [dbo].[tblEMEntityLocation] ([intEntityLocationId]),
    CONSTRAINT [FK_tblHDProject_tblEMEntity_intLostToCompetitorId] FOREIGN KEY ([intLostToCompetitorId]) REFERENCES [dbo].[tblEMEntity] ([intEntityId])
	--[intOpportunitySourceId]
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
    @value = N'Ticket Type Reference Id',
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
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Generate Tickets',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProject',
    @level2type = N'COLUMN',
    @level2name = N'ysnGenerateTicket'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sales Pipe Status Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProject',
    @level2type = N'COLUMN',
    @level2name = N'intSalesPipeStatusId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Project Type CRM or HD',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProject',
    @level2type = N'COLUMN',
    @level2name = N'strType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Close Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProject',
    @level2type = N'COLUMN',
    @level2name = N'dtmClose'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Line of Business Reference Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProject',
    @level2type = N'COLUMN',
    @level2name = N'strLinesOfBusinessId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Line of Business Reference',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProject',
    @level2type = N'COLUMN',
    @level2name = N'strLinesOfBusiness'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'RFR / RFI Link',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProject',
    @level2type = N'COLUMN',
    @level2name = N'strRFPRFILink'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Last Description Modified',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProject',
    @level2type = N'COLUMN',
    @level2name = N'dtmLastDescriptionModified'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Direction',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProject',
    @level2type = N'COLUMN',
    @level2name = N'strDirection'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Milestone Reference Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProject',
    @level2type = N'COLUMN',
    @level2name = N'intMilestoneId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Company Location Refernce Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProject',
    @level2type = N'COLUMN',
    @level2name = N'intCompanyLocationId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Entity Location Reference  Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProject',
    @level2type = N'COLUMN',
    @level2name = N'intEntityLocationId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Opportunity Win/Loss Reason Reference Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProject',
    @level2type = N'COLUMN',
    @level2name = 'strOpportunityWinLossReasonId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Win/Loss Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProject',
    @level2type = N'COLUMN',
    @level2name = N'dtmWinLossDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Win/Loss Length of Cycle',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProject',
    @level2type = N'COLUMN',
    @level2name = N'intWinLossLengthOfCycle'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Win/Loss Details',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProject',
    @level2type = N'COLUMN',
    @level2name = N'strWinLossDetails'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Win/Loss Did Right',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProject',
    @level2type = N'COLUMN',
    @level2name = N'strWinLossDidRight'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Win/Loss Did Wrong',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProject',
    @level2type = N'COLUMN',
    @level2name = N'strWinLossDidWrong'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Win/LossActionItem',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProject',
    @level2type = N'COLUMN',
    @level2name = N'strWinLossActionItem'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Status Reference Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProject',
    @level2type = N'COLUMN',
    @level2name = N'intTicketStatusId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Opportunity Source Reference Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProject',
    @level2type = N'COLUMN',
    @level2name = N'intOpportunitySourceId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Opportunity Campaign Referebce Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProject',
    @level2type = N'COLUMN',
    @level2name = N'intOpportunityCampaignId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Competitor Entity Reference Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProject',
    @level2type = N'COLUMN',
    @level2name = N'strCompetitorEntityId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Current Solution Reference Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProject',
    @level2type = N'COLUMN',
    @level2name = N'strCurrentSolutionId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Competitor Entity Reference',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProject',
    @level2type = N'COLUMN',
    @level2name = N'strCompetitorEntity'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Current Solution Reference',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProject',
    @level2type = N'COLUMN',
    @level2name = N'strCurrentSolution'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Referred By Entity Reference Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProject',
    @level2type = N'COLUMN',
    @level2name = N'intReferredByEntityId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Creadted Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDProject',
    @level2type = N'COLUMN',
    @level2name = N'dtmCreated'