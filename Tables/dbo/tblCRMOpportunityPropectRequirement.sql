CREATE TABLE [dbo].[tblCRMOpportunityPropectRequirement]
(
	[intOpportunityPropectRequirementId] [int] IDENTITY(1,1) NOT NULL,
	[intOpportunityId] [int] NOT NULL,
	[intProspectRequirementId] [int] NOT NULL,
	[intEntityId] [int] NOT NULL,
	[strRespondentAnswer] [nvarchar](MAX) COLLATE Latin1_General_CI_AS NOT NULL,
	[dtmDate] [datetime] null,
	[strDirection] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblCRMOpportunityPropectRequirement_intOpportunityPropectRequirementId] PRIMARY KEY CLUSTERED ([intOpportunityPropectRequirementId] ASC),
	CONSTRAINT [FK_tblCRMOpportunityPropectRequirement_tblCRMOpportunity_intOpportunityId] FOREIGN KEY ([intOpportunityId]) REFERENCES [dbo].[tblCRMOpportunity] ([intOpportunityId]) on delete cascade,
    CONSTRAINT [FK_tblCRMOpportunityPropectRequirement_tblCRMProspectRequirement_intProspectRequirementId] FOREIGN KEY ([intProspectRequirementId]) REFERENCES [dbo].[tblCRMProspectRequirement] ([intProspectRequirementId]),
    CONSTRAINT [FK_tblCRMOpportunityPropectRequirement_tblEMENtity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEMEntity] ([intEntityId])
)
