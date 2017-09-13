CREATE PROCEDURE uspMFGetAttributesByType @intAttributeTypeId INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

SELECT A.intAttributeId
	,A.strAttributeName
	,A.intAttributeDataTypeId
	,A.intAttributeTypeId
	,A.ysnMultiSelect
	,A.strSQL
	,AD.strAttributeDataTypeName
	,ADV.strAttributeDefaultValue
	,ADV.strAttributeDisplayValue
FROM tblMFAttribute A
JOIN tblMFAttributeDataType AD ON AD.intAttributeDataTypeId = A.intAttributeDataTypeId
LEFT JOIN tblMFAttributeDefaultValue ADV ON ADV.intAttributeId = A.intAttributeId
	AND ADV.intAttributeTypeId = A.intAttributeTypeId
WHERE A.intAttributeTypeId = 1
	OR A.intAttributeTypeId = @intAttributeTypeId
