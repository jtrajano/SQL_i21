CREATE TABLE [dbo].[tblSMApprovalList]
(
	[intApprovalListId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [strApprovalList] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1
)
