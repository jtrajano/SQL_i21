CREATE TABLE [dbo].[tblGLMaskedAccountStructureTemp]
(
	[intMaskedAccountStructureTempId]	INT IDENTITY(1, 1)	NOT NULL,
	[strMaskedSegmentId]				NVARCHAR(50)	COLLATE Latin1_General_CI_AS NOT NULL,
	[strMaskedSegment]					NVARCHAR(100)	COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId]					INT DEFAULT (1)		NOT NULL,

	CONSTRAINT [PK_tblGLMaskedAccountStructureTemp] PRIMARY KEY CLUSTERED ([intMaskedAccountStructureTempId] ASC)
)
