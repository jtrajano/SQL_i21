CREATE TABLE [dbo].[tblSMAlternateApproverGroup]
(
	[intAlternateApproverGroupId]	INT											NOT NULL	PRIMARY KEY IDENTITY, 
    [strAlternateApproverGroup]		NVARCHAR(50) COLLATE Latin1_General_CI_AS	NOT NULL, 
    [intConcurrencyId]				INT											NOT NULL	DEFAULT 1, 
    CONSTRAINT [AK_tblSMAlternateApproverGroup_strAlternateApproverGroup] UNIQUE ([strAlternateApproverGroup])
)
