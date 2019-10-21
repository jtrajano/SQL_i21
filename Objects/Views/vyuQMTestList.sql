CREATE VIEW vyuQMTestList
AS
SELECT T.intTestId
	,T.strTestName
	,T.strDescription
	,AT.strAnalysisTypeName
	,T.strTestMethod
	,T.strIndustryStandards
	,T.strSensComments
	,T.intReplications
	,T.ysnActive
	,dbo.fnQMGetTemplateNames(T.intTestId) COLLATE Latin1_General_CI_AS AS strTemplateNames
FROM tblQMTest AS T
JOIN tblQMAnalysisType AS AT ON AT.intAnalysisTypeId = T.intAnalysisTypeId
