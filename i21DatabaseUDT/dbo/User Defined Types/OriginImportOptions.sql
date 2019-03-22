CREATE TYPE dbo.OriginImportOptions AS TABLE 
(
	[Name] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[Type] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[Value] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
)