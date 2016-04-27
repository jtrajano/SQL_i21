CREATE TABLE [dbo].[tblIPStepType]
(
	[intStepTypeId] INT NOT NULL , 
    [strName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	CONSTRAINT [PK_tblIPStepType_intStepTypeId] PRIMARY KEY ([intStepTypeId]), 
    CONSTRAINT [UQ_tblIPStepType_strName] UNIQUE ([strName])
)
