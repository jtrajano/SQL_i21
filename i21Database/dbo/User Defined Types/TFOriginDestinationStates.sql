CREATE TYPE [dbo].[TFOriginDestinationStates] AS TABLE (
	intOriginDestinationStateId INT NOT NULL
	, strOriginDestinationState NVARCHAR(10) NOT NULL
	, intMasterId INT NULL
)