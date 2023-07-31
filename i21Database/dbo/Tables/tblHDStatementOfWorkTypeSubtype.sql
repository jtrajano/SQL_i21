CREATE TABLE [dbo].[tblHDStatementOfWorkTypeSubtype]
(
	[intSubtypeId]		INT IDENTITY(1,1) NOT NULL,
	[intTypeId]			INT NOT NULL,
	[strSubtype]		NVARCHAR(50)		COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription]	NVARCHAR(100)		COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId]  INT NOT NULL,
	CONSTRAINT [PK_tblHDStatementOfWorkTypeSubtype_intSubtypeId] PRIMARY KEY CLUSTERED ([intSubtypeId] ASC),
	CONSTRAINT [UQ_tblHDStatementOfWorkTypeSubtype_intTypeId_strSubtype] UNIQUE ([intTypeId],[strSubtype])
)
GO