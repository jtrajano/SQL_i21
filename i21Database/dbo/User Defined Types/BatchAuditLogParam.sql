CREATE TYPE BatchAuditLogParam AS TABLE ( 
  [Id]			INT, 
  [Namespace]	NVARCHAR(MAX),
  [Action]		NVARCHAR(MAX),
  [Description]	NVARCHAR(MAX),
  [From]		NVARCHAR(MAX),
  [To]			NVARCHAR(MAX),
  [EntityId]	INT
)