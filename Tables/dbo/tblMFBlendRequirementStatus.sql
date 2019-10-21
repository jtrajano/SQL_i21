CREATE TABLE [dbo].[tblMFBlendRequirementStatus]
(
	[intStatusId] INT NOT NULL , 
    [strName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	CONSTRAINT [PK_tblMFBlendRequirementStatus_intBlendRequirementStatusId] PRIMARY KEY ([intStatusId]), 
    CONSTRAINT [UQ_tblMFBlendRequirementStatus_strName] UNIQUE ([strName]) 
)
