CREATE TABLE [dbo].[tblCTCondition]
(
	[intConditionId] INT NOT NULL IDENTITY, 
    [intConcurrencyId] INT NOT NULL, 
    [strConditionName] NVARCHAR(200) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strConditionDesc] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL, 
    [ysnActive] BIT NULL,
	CONSTRAINT [PK_tblCTCondition_intConditionId] PRIMARY KEY CLUSTERED (intConditionId ASC), 
    CONSTRAINT [UK_tblCTCondition_strConditionName] UNIQUE ([strConditionName])
)