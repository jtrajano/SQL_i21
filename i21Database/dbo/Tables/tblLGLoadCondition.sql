CREATE TABLE [dbo].[tblLGLoadCondition]
(
	[intLoadConditionId] INT NOT NULL IDENTITY (1, 1),
	[intLoadId] INT NOT NULL, 
    [intConditionId] INT NOT NULL, 
    [strConditionDescription] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
    [intConcurrencyId] INT NOT NULL,
	CONSTRAINT [PK_tblLGLoadCondition_intLoadConditionId] PRIMARY KEY CLUSTERED ([intLoadConditionId] ASC),
	CONSTRAINT [FK_tblLGLoadCondition_tblLGLoad_intLoadId] FOREIGN KEY ([intLoadId]) REFERENCES [tblLGLoad]([intLoadId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblLGLoadCondition_tblCTCondition_intConditionId] FOREIGN KEY ([intConditionId]) REFERENCES [tblCTCondition]([intConditionId])
)
