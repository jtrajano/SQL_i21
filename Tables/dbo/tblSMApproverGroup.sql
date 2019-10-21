CREATE TABLE [dbo].[tblSMApproverGroup]
(
	[intApproverGroupId]	INT											NOT NULL	PRIMARY KEY IDENTITY, 
    [strApproverGroup]		NVARCHAR(200) COLLATE Latin1_General_CI_AS	NOT NULL, 
    [intConcurrencyId]		INT											NOT NULL	DEFAULT 1, 
    CONSTRAINT [AK_tblSMApproverGroup_strApproverGroup] UNIQUE ([strApproverGroup])
)
