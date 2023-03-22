CREATE TYPE BatchAuditLogParamNested AS TABLE ( 
  [Id]			INT, 
  [Action]		NVARCHAR(MAX),
  [Description]	NVARCHAR(MAX),
  [From]		NVARCHAR(MAX),
  [To]			NVARCHAR(MAX),
  [ParentId]	INT
)