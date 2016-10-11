CREATE TABLE [dbo].[tblICFobPoint]
(
	[intFobPointId] TINYINT NOT NULL	
	,[strFobPoint]  NVARCHAR(255) COLLATE Latin1_General_CI_AS
	,CONSTRAINT [PK_tblICFobPoint] PRIMARY KEY CLUSTERED ([intFobPointId])
	,CONSTRAINT [UN_tblICFobPoint] UNIQUE NONCLUSTERED ([strFobPoint] ASC)
)
