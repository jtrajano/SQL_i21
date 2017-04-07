CREATE TABLE [dbo].[tblCRMOpportunityContact]
(
	[intOpportunityContactId] [int] IDENTITY(1,1) NOT NULL,
	[intOpportunityId] [int] NOT NULL,
	[intEntityId] [int] NOT NULL,
	[strDecisionRole] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strAttitude] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strExtent] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strConcerns] [nvarchar](MAX) COLLATE Latin1_General_CI_AS NULL,
	[strExpectations] [nvarchar](MAX) COLLATE Latin1_General_CI_AS NULL,
	[intSort] [int] NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblCRMOpportunityContact_intOpportunityContactId] PRIMARY KEY CLUSTERED ([intOpportunityContactId] ASC),
	CONSTRAINT [UQ_tblCRMOpportunityContact_intOpportunityId_intEnityId] UNIQUE ([intOpportunityId],[intEntityId]),
    CONSTRAINT [FK_tblCRMOpportunityContact_tblCRMOpportunity_intOpportunityId] FOREIGN KEY ([intOpportunityId]) REFERENCES [dbo].[tblCRMOpportunity] ([intOpportunityId]) on delete cascade,
	CONSTRAINT [FK_tblCRMOpportunityContact_tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].tblEMEntity ([intEntityId]) ON DELETE CASCADE
)
