CREATE TYPE [dbo].[TFValidDestinationStates] AS TABLE (
	intValidDestinationStateId INT NOT NULL
	, strFormCode NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL
	, strScheduleCode NVARCHAR (20)  COLLATE Latin1_General_CI_AS NULL
	, strType NVARCHAR (200) COLLATE Latin1_General_CI_AS NULL
	, strState NVARCHAR(10) COLLATE Latin1_General_CI_AS NOT NULL
	, strStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	, intMasterId INT NULL
)