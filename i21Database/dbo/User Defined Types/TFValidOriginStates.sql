CREATE TYPE [dbo].[TFValidOriginStates] AS TABLE (
	[intValidOriginStateId]	INT NOT NULL,
    [strFormCode]			NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strScheduleCode]		NVARCHAR (20)  COLLATE Latin1_General_CI_AS NULL,
    [strType]				NVARCHAR (200) COLLATE Latin1_General_CI_AS NULL,
    [strState]				NVARCHAR (200) COLLATE Latin1_General_CI_AS NULL,
    [strStatus]				NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL
)