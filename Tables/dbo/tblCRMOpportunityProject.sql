CREATE TABLE [dbo].[tblCRMOpportunityProject]
(
	[intOpportunityProjectId] [int] IDENTITY(1,1) NOT NULL,
	[intOpportunityId] [int] NOT NULL,
	[intProjectId] [int] NOT NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblCRMOpportunityProject_intOpportunityProjectId] PRIMARY KEY CLUSTERED ([intOpportunityProjectId] ASC),
	CONSTRAINT [AK_tblCRMOpportunityProject_intOpportunityId_intProjectId] UNIQUE ([intOpportunityId],[intProjectId]),
    CONSTRAINT [FK_tblCRMOpportunityProject_tblCRMOpportunity_intOpportunityId] FOREIGN KEY ([intOpportunityId]) REFERENCES [dbo].[tblCRMOpportunity] ([intOpportunityId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblCRMOpportunityProject_tblHDProject_intProjectId] FOREIGN KEY ([intProjectId]) REFERENCES [dbo].[tblHDProject] ([intProjectId]) ON DELETE CASCADE
)
