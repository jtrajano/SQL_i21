CREATE FUNCTION fnSMGetAuditsFromDetails
(
	@details	NVARCHAR(MAX)
)
RETURNS 
@audits TABLE 
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
AS
BEGIN
	INSERT @audits
	SELECT parent,
		MIN(CASE name WHEN 'keyValue' THEN value END) AS intKeyValue,
		MIN(CASE name WHEN 'action' THEN value END) AS strAction,
		MIN(CASE name WHEN 'change' THEN value END) AS strChange,
		MIN(CASE name WHEN 'from' THEN value END) AS strFrom,
		MIN(CASE name WHEN 'to' THEN value END) AS strTo,
		MIN(CASE name WHEN 'changeDescription' THEN value END) AS strAlias,
		MIN(CASE name WHEN 'isField' THEN value END) AS ysnField,
		MIN(CASE name WHEN 'hidden' THEN value END) AS ysnHidden,
		MIN(CASE name WHEN 'children' THEN 1 END) AS ysnParent
	FROM fnSMJson_Parse(REPLACE(REPLACE(@details, ':null', ':"null"'), ',"children":[]', ''))
	WHERE [name] NOT IN ('leaf', 'iconCls') AND ([kind] <> 'OBJECT') 
	GROUP BY parent

	RETURN 
END
GO