CREATE TABLE [dbo].[tblMBConsignmentGroup]
(
	[intConsignmentGroupId] INT NOT NULL IDENTITY, 
    [strConsignmentGroup] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
	[strRateType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblMBConsignmentGroup] PRIMARY KEY ([intConsignmentGroupId]), 
    CONSTRAINT [AK_tblMBConsignmentGroup_strConsignmentGroup] UNIQUE ([strConsignmentGroup]) 
)
