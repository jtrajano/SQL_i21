CREATE TABLE [dbo].[tblHDOpportunityWinLossReason]
(
	[intOpportunityWinLossReasonId] INT IDENTITY (1, 1) NOT NULL,
	[strReason] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDOpportunityWinLossReason] PRIMARY KEY CLUSTERED ([intOpportunityWinLossReasonId] ASC),
    CONSTRAINT [UNQ_tblHDOpportunityWinLossReason_strReason] UNIQUE ([strReason])
)
