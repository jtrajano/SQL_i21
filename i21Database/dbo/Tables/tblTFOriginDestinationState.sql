CREATE TABLE [dbo].[tblTFOriginDestinationState](
	[intOriginDestinationStateId] INT IDENTITY NOT NULL,
	[strOriginDestinationState] NVARCHAR(10) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] INT DEFAULT ((1)) NULL,
	CONSTRAINT [PK_tblTFOriginDestination] PRIMARY KEY ([intOriginDestinationStateId]) 
)
GO