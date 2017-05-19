CREATE TYPE [dbo].[AuditLogStagingTable] AS TABLE
(
	[Id]					INT NOT NULL  IDENTITY,
	[strScreenName]			NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[intKeyValueId]			INT NOT NULL,
	[intEntityId]			INT NOT NULL,
	[strActionType]			NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strDescription]		NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL,
	[strActionIcon]			NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strChangeDescription]	NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL,
	[strFromValue]			NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL,
	[strToValue]			NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL,
	[strDetails]			NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL
)
