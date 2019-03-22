CREATE TABLE [dbo].[tblMFBlendSheetRuleValue]
(
	[intBlendSheetRuleValueId] INT NOT NULL IDENTITY, 
    [intBlendSheetRuleId] INT NOT NULL, 
    [strValue] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
	[strDescription] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
    [ysnDefault] BIT NOT NULL CONSTRAINT [DF_tblMFBlendSheetRuleValue_ysnDefault] DEFAULT 0,
	CONSTRAINT [PK_tblMFBlendSheetRuleValue_intBlendSheetRuleValueId] PRIMARY KEY ([intBlendSheetRuleValueId]), 
    CONSTRAINT [UQ_tblMFBlendSheetRuleValue_intBlendSheetRuleId_strValue] UNIQUE ([intBlendSheetRuleId],[strValue]),
	CONSTRAINT [FK_tblMFBlendSheetRuleValue_tblMFBlendSheetRule_intBlendSheetRuleId] FOREIGN KEY ([intBlendSheetRuleId]) REFERENCES [tblMFBlendSheetRule]([intBlendSheetRuleId])	 
)
