CREATE TYPE SingleAuditLogParam 
AS TABLE ( 
  [Id]			INT, 
  [Action]		NVARCHAR(MAX),
  [Change]		NVARCHAR(MAX),
  [From]		NVARCHAR(MAX),
  [To]			NVARCHAR(MAX),
  [Alias]		NVARCHAR(MAX),
  [Field]		BIT,
  [Hidden]		BIT,
  [ParentId]	INT
)