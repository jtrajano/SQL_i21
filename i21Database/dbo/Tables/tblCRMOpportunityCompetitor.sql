CREATE TABLE [dbo].[tblCRMOpportunityCompetitor]
(
	[intOpportunityCompetitorId] [int] IDENTITY(1,1) NOT NULL,
	[intOpportunityId] [int] NOT NULL,
	[intEntityId] [int] NOT NULL,
	[strReferenceType] nvarchar(50) COLLATE Latin1_General_CI_AS not null default 'Competitor',
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblCRMOpportunityCompetitor_intOpportunityCompetitorId] PRIMARY KEY CLUSTERED ([intOpportunityCompetitorId] ASC),
	CONSTRAINT [UQ_tblCRMOpportunityCompetitor_intOpportunityId_intEnityId] UNIQUE ([intOpportunityId],[intEntityId]),
    CONSTRAINT [FK_tblCRMOpportunityCompetitor_tblCRMOpportunity_intOpportunityId] FOREIGN KEY ([intOpportunityId]) REFERENCES [dbo].[tblCRMOpportunity] ([intOpportunityId]) on delete cascade,
	CONSTRAINT [FK_tblCRMOpportunityCompetitor_tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].tblEMEntity ([intEntityId])
)
