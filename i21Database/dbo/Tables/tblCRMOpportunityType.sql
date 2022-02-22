CREATE TABLE [dbo].[tblCRMOpportunityType]
(
	[intOpportunityTypeId] INT IDENTITY(1,1) NOT NULL,
	[strOpportunityType] NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblCRMOpportunityType] PRIMARY KEY CLUSTERED ([intOpportunityTypeId] ASC),
	CONSTRAINT [UQ_tblCRMOpportunityType_strOpportunityType] UNIQUE ([strOpportunityType])
)
