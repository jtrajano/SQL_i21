CREATE PROCEDURE uspQMGetTestProperty
	@intTestId INT
	,@intProductId INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

SELECT TP.intTestId
	,TP.intPropertyId
	,T.strTestName
	,PR.strPropertyName
	,D.intDataTypeId
	,@intProductId AS intProductId
FROM tblQMTestProperty TP
JOIN tblQMTest T ON T.intTestId = TP.intTestId
JOIN tblQMProperty PR ON PR.intPropertyId = TP.intPropertyId
JOIN tblQMDataType D ON D.intDataTypeId = PR.intDataTypeId
WHERE TP.intTestId = @intTestId

UNION

SELECT TP.intTestId
	,TP.intFormulaID AS intPropertyId
	,T.strTestName
	,PR.strPropertyName
	,D.intDataTypeId
	,@intProductId AS intProductId
FROM tblQMTestProperty TP
JOIN tblQMTest T ON T.intTestId = TP.intTestId
JOIN tblQMProperty PR ON PR.intPropertyId = TP.intFormulaID
JOIN tblQMDataType D ON D.intDataTypeId = PR.intDataTypeId
WHERE TP.intTestId = @intTestId
