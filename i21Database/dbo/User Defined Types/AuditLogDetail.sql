CREATE TYPE [dbo].[AuditLogDetail] AS TABLE
(
	intParent	INT,
	intKeyValue INT,
	strAction	NVARCHAR(MAX),
	strChange	NVARCHAR(MAX),
	strFrom		NVARCHAR(MAX),
	strTo		NVARCHAR(MAX),
	strAlias	NVARCHAR(MAX),
	ysnField	BIT,
	ysnHidden	BIT,
	ysnParent	BIT
)
