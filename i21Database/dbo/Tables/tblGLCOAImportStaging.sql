CREATE TABLE [dbo].[tblGLCOAImportStaging]
(
	[intImportStagingId]	INT IDENTITY(1, 1),
	[strAccountPartition]	NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,  
	[intPartitionType]		INT NOT NULL,  
	[strPartitionGroup]		NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL,
	[strGUID]				NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL,
	[strRawString]			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[intLineNumber]			INT DEFAULT (1) NOT NULL,

	CONSTRAINT [PK_tblGLCOAImportStaging] PRIMARY KEY CLUSTERED ([intImportStagingId] ASC)
)
