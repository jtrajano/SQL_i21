CREATE TABLE [dbo].[tblMFBlendSheetRule]
(
	[intBlendSheetRuleId] INT NOT NULL , 
    [strName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intSequenceNo] INT NOT NULL, 
    CONSTRAINT [PK_tblMFBlendSheetRule_intBlendSheetRuleId] PRIMARY KEY ([intBlendSheetRuleId]), 
    CONSTRAINT [UQ_tblMFBlendSheetRule_strName] UNIQUE ([strName])
)
