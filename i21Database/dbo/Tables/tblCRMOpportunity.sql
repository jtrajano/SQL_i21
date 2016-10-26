CREATE TABLE [dbo].[tblCRMOpportunity]
(
	[intOpportunityId] [int] IDENTITY(1,1) NOT NULL,
	[strName] [nvarchar](255) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] [nvarchar](MAX) COLLATE Latin1_General_CI_AS NULL,
	[intCustomerId] [int] NOT NULL,
	[intCustomerContactId] [int] NOT NULL,
	[intSalesPipeStatusId] [int] NULL,
	[intStatusId] [int] NULL,
	[intSourceId] [int] NULL,
	[intTypeId] [int] NULL,
	[intCampaignId] [int] NULL,
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
	[strOpportunityStatus] [nvarchar](255) COLLATE Latin1_General_CI_AS NOT NULL,
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
	[strLinesOfBusinessId] [nvarchar](255) COLLATE Latin1_General_CI_AS NULL,
	[strLinesOfBusiness] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strRFPRFILink] [nvarchar](255) COLLATE Latin1_General_CI_AS NULL,
	[dtmLastDescriptionModified] [datetime] null,
	[strDirection] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[intMilestoneId] [int] null,
	[intCompanyLocationId] [int] null,
	[intEntityLocationId] [int] null,
	[strWinLossReasonId] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS null,
	[strWinLossReason] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS null,
	[dtmWinLossDate] [datetime] null,
	[intWinLossLengthOfCycle] [int] null,
	[strWinLossDetails] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strWinLossDidRight] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strWinLossDidWrong] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strWinLossActionItem] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[intLostToCompetitorId] [int] null,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,

	CONSTRAINT [PK_tblCRMOpportunity] PRIMARY KEY CLUSTERED ([intOpportunityId] ASC),
	CONSTRAINT [UQ_tblCRMOpportunity_strName] UNIQUE ([strName]),
    CONSTRAINT [FK_tblCRMOpportunity_tblEMEntity_intCustomerId] FOREIGN KEY ([intCustomerId]) REFERENCES [dbo].[tblEMEntity] ([intEntityId]),
    CONSTRAINT [FK_tblCRMOpportunity_tblEMEntity_intCustomerContactId] FOREIGN KEY ([intCustomerContactId]) REFERENCES [dbo].tblEMEntity ([intEntityId]),
    CONSTRAINT [FK_tblCRMOpportunity_tblCRMType_intTypeId] FOREIGN KEY ([intTypeId]) REFERENCES [dbo].[tblCRMType] ([intTypeId]),
    CONSTRAINT [FK_tblCRMOpportunity_tblEMEntity_intInternalProjectManager] FOREIGN KEY ([intInternalProjectManager]) REFERENCES [dbo].tblEMEntity ([intEntityId]),
	CONSTRAINT [FK_tblCRMOpportunity_tblEMEntity_intInternalSalesPerson] FOREIGN KEY ([intInternalSalesPerson]) REFERENCES [dbo].tblEMEntity ([intEntityId]),
	CONSTRAINT [FK_tblCRMOpportunity_tblEMEntity_intCustomerProjectManager] FOREIGN KEY ([intCustomerProjectManager]) REFERENCES [dbo].tblEMEntity ([intEntityId]),
	CONSTRAINT [FK_tblCRMOpportunity_tblEMEntity_intCustomerLeadershipSponsor] FOREIGN KEY ([intCustomerLeadershipSponsor]) REFERENCES [dbo].tblEMEntity ([intEntityId]),
	CONSTRAINT [FK_tblCRMOpportunity_tblCRMSalesPipeStatus_intSalesPipeStatusId] FOREIGN KEY ([intSalesPipeStatusId]) REFERENCES [dbo].[tblCRMSalesPipeStatus] ([intSalesPipeStatusId]),
	CONSTRAINT [FK_tblCRMOpportunity_tblCRMStatus_intStatusId] FOREIGN KEY ([intStatusId]) REFERENCES [dbo].[tblCRMStatus] ([intStatusId]),
	CONSTRAINT [FK_tblCRMOpportunity_tblCRMCampaign_intCampaignId] FOREIGN KEY ([intCampaignId]) REFERENCES [dbo].[tblCRMCampaign] ([intCampaignId]),
	CONSTRAINT [FK_tblCRMOpportunity_tblCRMSource_intSourceId] FOREIGN KEY (intSourceId) REFERENCES [dbo].[tblCRMSource] ([intSourceId]),
    CONSTRAINT [FK_tblCRMOpportunity_tblEMEntity_intReferredByEntityId] FOREIGN KEY ([intReferredByEntityId]) REFERENCES [dbo].[tblEMEntity] ([intEntityId]),
    CONSTRAINT [FK_tblCRMOpportunity_tblCRMMilestone_intMilestoneId] FOREIGN KEY ([intMilestoneId]) REFERENCES [dbo].[tblCRMMilestone] ([intMilestoneId]),
    CONSTRAINT [FK_tblCRMOpportunity_tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [dbo].[tblSMCompanyLocation] ([intCompanyLocationId]),
    CONSTRAINT [FK_tblCRMOpportunity_tblEMEntityLocation_intEntityLocationId] FOREIGN KEY ([intEntityLocationId]) REFERENCES [dbo].[tblEMEntityLocation] ([intEntityLocationId]),
    CONSTRAINT [FK_tblCRMOpportunity_tblEMEntity_intLostToCompetitorId] FOREIGN KEY ([intLostToCompetitorId]) REFERENCES [dbo].[tblEMEntity] ([intEntityId])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMOpportunity',
    @level2type = N'COLUMN',
    @level2name = N'intOpportunityId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Opportunity Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMOpportunity',
    @level2type = N'COLUMN',
    @level2name = 'strName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMOpportunity',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Customer Entity Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMOpportunity',
    @level2type = N'COLUMN',
    @level2name = N'intCustomerId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Customer Contact Entity Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMOpportunity',
    @level2type = N'COLUMN',
    @level2name = N'intCustomerContactId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sales Pipe Status Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMOpportunity',
    @level2type = N'COLUMN',
    @level2name = N'intSalesPipeStatusId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Status Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMOpportunity',
    @level2type = N'COLUMN',
    @level2name = N'intStatusId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Source Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMOpportunity',
    @level2type = N'COLUMN',
    @level2name = N'intSourceId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMOpportunity',
    @level2type = N'COLUMN',
    @level2name = N'intTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Campaign Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMOpportunity',
    @level2type = N'COLUMN',
    @level2name = N'intCampaignId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Competitor Entity Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMOpportunity',
    @level2type = N'COLUMN',
    @level2name = N'strCompetitorEntityId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Solution Entity Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMOpportunity',
    @level2type = N'COLUMN',
    @level2name = N'strCurrentSolutionId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Competitor Entity Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMOpportunity',
    @level2type = N'COLUMN',
    @level2name = N'strCompetitorEntity'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Solution Entity Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMOpportunity',
    @level2type = N'COLUMN',
    @level2name = N'strCurrentSolution'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Referred By Entity Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMOpportunity',
    @level2type = N'COLUMN',
    @level2name = N'intReferredByEntityId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date Created',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMOpportunity',
    @level2type = N'COLUMN',
    @level2name = N'dtmCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date Close',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMOpportunity',
    @level2type = N'COLUMN',
    @level2name = N'dtmClose'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date Go Live',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMOpportunity',
    @level2type = N'COLUMN',
    @level2name = N'dtmGoLive'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Percent Complete',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMOpportunity',
    @level2type = N'COLUMN',
    @level2name = N'intPercentComplete'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Completed',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMOpportunity',
    @level2type = N'COLUMN',
    @level2name = N'ysnCompleted'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Order',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMOpportunity',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Active',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMOpportunity',
    @level2type = N'COLUMN',
    @level2name = N'ysnActive'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Status Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMOpportunity',
    @level2type = N'COLUMN',
    @level2name = N'strOpportunityStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Internal Project Manager',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMOpportunity',
    @level2type = N'COLUMN',
    @level2name = N'intInternalProjectManager'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sales Person',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMOpportunity',
    @level2type = N'COLUMN',
    @level2name = N'intInternalSalesPerson'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Flag for Data Collection',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMOpportunity',
    @level2type = N'COLUMN',
    @level2name = N'ysnInitialDataCollectionComplete'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Confirmed Keystone Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMOpportunity',
    @level2type = N'COLUMN',
    @level2name = N'dtmConfirmedKeystoneDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Customer Project manager',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMOpportunity',
    @level2type = N'COLUMN',
    @level2name = N'intCustomerProjectManager'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Customer Leadership Sponsor',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMOpportunity',
    @level2type = N'COLUMN',
    @level2name = N'intCustomerLeadershipSponsor'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Customer Key Project Goal',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMOpportunity',
    @level2type = N'COLUMN',
    @level2name = N'strCustomerKeyProjectGoal'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Custom Modification',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMOpportunity',
    @level2type = N'COLUMN',
    @level2name = N'strCustomModification'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sales Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMOpportunity',
    @level2type = N'COLUMN',
    @level2name = N'dtmSalesDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Software Bill Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMOpportunity',
    @level2type = N'COLUMN',
    @level2name = N'dtmSoftwareBillDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Software Bill Date Comment',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMOpportunity',
    @level2type = N'COLUMN',
    @level2name = N'strSoftwareBillDateComment'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Hardware Order Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMOpportunity',
    @level2type = N'COLUMN',
    @level2name = N'dtmHardwareOrderDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Hardware Orde Date Comment',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMOpportunity',
    @level2type = N'COLUMN',
    @level2name = N'strHardwareOrderDateComment'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Initial Dues Invoice',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMOpportunity',
    @level2type = N'COLUMN',
    @level2name = N'dtmInitialUserGroupDuesInvoice'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Flag for Initial Down Payment',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMOpportunity',
    @level2type = N'COLUMN',
    @level2name = N'ysnReceivedDownPayment'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Lines of Business Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMOpportunity',
    @level2type = N'COLUMN',
    @level2name = N'strLinesOfBusinessId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Lines of Business',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMOpportunity',
    @level2type = N'COLUMN',
    @level2name = N'strLinesOfBusiness'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'RFP/RFI Link',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMOpportunity',
    @level2type = N'COLUMN',
    @level2name = N'strRFPRFILink'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Last Description Modified',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMOpportunity',
    @level2type = N'COLUMN',
    @level2name = N'dtmLastDescriptionModified'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Direction',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMOpportunity',
    @level2type = N'COLUMN',
    @level2name = N'strDirection'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Milestone Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMOpportunity',
    @level2type = N'COLUMN',
    @level2name = N'intMilestoneId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Company Location Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMOpportunity',
    @level2type = N'COLUMN',
    @level2name = N'intCompanyLocationId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Entity Location Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMOpportunity',
    @level2type = N'COLUMN',
    @level2name = N'intEntityLocationId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Win/Loss Reason Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMOpportunity',
    @level2type = N'COLUMN',
    @level2name = N'strWinLossReasonId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Win/Loss Reason',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMOpportunity',
    @level2type = N'COLUMN',
    @level2name = N'strWinLossReason'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Win/Loss Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblCRMOpportunity',
    @level2type = N'COLUMN',
    @level2name = N'dtmWinLossDate'