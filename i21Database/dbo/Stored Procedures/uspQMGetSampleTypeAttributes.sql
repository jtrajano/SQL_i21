CREATE PROCEDURE uspQMGetSampleTypeAttributes
	@intSampleTypeId INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

SELECT DISTINCT A.intAttributeId
	,A.strAttributeName
	,A.intAttributeId AS ValueMember
	,A.strAttributeName AS DisplayMember
	,A.strDescription
	,'' AS strAttributeValue
	,ST.ysnIsMandatory
	,ISNULL(A.intDataTypeId, 0) AS intDataTypeId
	,ISNULL(AD.strDataTypeName, 'Text') AS strDataTypeName
	,ISNULL(A.intListId, 0) AS intListId
	,'' AS DocFile
	,'' AS DocType
	,0 AS DocSize
FROM tblQMAttribute A
LEFT JOIN tblQMAttributeDataType AD ON AD.intDataTypeId = A.intDataTypeId
JOIN tblQMSampleTypeDetail ST ON ST.intAttributeId = A.intAttributeId
WHERE ST.intSampleTypeId = @intSampleTypeId
ORDER BY A.strAttributeName
