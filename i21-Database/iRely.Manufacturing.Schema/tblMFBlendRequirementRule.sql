CREATE TABLE [dbo].[tblMFBlendRequirementRule]
(
	[intBlendRequirementRuleId] INT NOT NULL IDENTITY, 
	[intBlendRequirementId] INT NOT NULL,
    [intBlendSheetRuleId] INT NOT NULL, 
    [strValue] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intSequenceNo] INT NOT NULL,
	[intConcurrencyId] INT NULL CONSTRAINT [DF_tblMFBlendRequirementRule_intConcurrencyId] DEFAULT 0,
	CONSTRAINT [PK_tblMFBlendRequirementRule_intBlendRequirementRuleId] PRIMARY KEY ([intBlendRequirementRuleId]), 
	CONSTRAINT [UQ_tblMFBlendRequirementRule_intBlendRequirementId_intBlendSheetRuleId] UNIQUE ([intBlendRequirementId],[intBlendSheetRuleId]),
	CONSTRAINT [FK_tblMFBlendRequirementRule_tblMFBlendRequirement_intBlendRequirementId] FOREIGN KEY ([intBlendRequirementId]) REFERENCES [tblMFBlendRequirement]([intBlendRequirementId]) ON DELETE CASCADE,	 
	CONSTRAINT [FK_tblMFBlendRequirementRule_tblMFBlendSheetRule_intBlendSheetRuleId] FOREIGN KEY ([intBlendSheetRuleId]) REFERENCES [tblMFBlendSheetRule]([intBlendSheetRuleId])	 
)
