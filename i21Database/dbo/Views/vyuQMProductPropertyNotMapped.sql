CREATE VIEW vyuQMProductPropertyNotMapped
AS
SELECT PP.intProductPropertyId
	,T.strTestName
	,P.strPropertyName
	,P.strDescription
	,P.intAnalysisTypeId
	,P.intDataTypeId
	,P.intListId
	,P.intDecimalPlaces
	,P.ysnActive
	,P.ysnNotify
	,A.strAnalysisTypeName
	,D.strDataTypeName
	,L.strListName
	,P.intItemId
	,I.strItemNo
	,PPVP.dblMinValue
	,PPVP.dblPinpointValue
	,PPVP.dblMaxValue
FROM tblQMProductProperty PP
JOIN tblQMTest T ON T.intTestId = PP.intTestId
JOIN tblQMProperty P ON P.intPropertyId = PP.intPropertyId
JOIN tblQMAnalysisType A ON A.intAnalysisTypeId = P.intAnalysisTypeId
JOIN tblQMDataType D ON D.intDataTypeId = P.intDataTypeId
LEFT JOIN tblQMList L ON L.intListId = P.intListId
LEFT JOIN tblICItem I ON I.intItemId = P.intItemId
LEFT JOIN tblQMProductPropertyValidityPeriod PPVP
	ON PP.intProductPropertyId = PPVP.intProductPropertyId
	AND DATEPART(dayofyear , GETDATE()) BETWEEN DATEPART(dayofyear , PPVP.dtmValidFrom) AND DATEPART(dayofyear , PPVP.dtmValidTo)
