CREATE VIEW vyuQMSampleTestResultView
AS
SELECT TR.intTestResultId
	,TR.intConcurrencyId
	,TR.intSampleId
	,TR.intProductId
	,TR.intProductTypeId
	,TR.intProductValueId
	,TR.intTestId
	,TR.intPropertyId
	,TR.strPanelList
	,TR.strPropertyValue
	,TR.dtmCreateDate
	,TR.strResult
	,TR.ysnFinal
	,TR.strComment
	,TR.intSequenceNo
	,TR.dtmValidFrom
	,TR.dtmValidTo
	,TR.strPropertyRangeText
	,TR.dblMinValue
	,TR.dblMaxValue
	,TR.dblLowValue
	,TR.dblHighValue
	,TR.intUnitMeasureId
	,TR.strFormulaParser
	,TR.dblCrdrPrice
	,TR.dblCrdrQty
	,NULL AS intProductPropertyValidityPeriodId
	,NULL AS intPropertyValidityPeriodId
	,TR.intControlPointId
	,TR.intParentPropertyId
	,TR.intRepNo
	,TR.strFormula
	,TR.intListItemId
	,TR.strIsMandatory
	,TR.intPropertyItemId
	,TR.dtmPropertyValueCreated
	,TR.intTestResultRefId
	,TR.intCreatedUserId
	,TR.dtmCreated
	,TR.intLastModifiedUserId
	,TR.dtmLastModified
	,PRD.intProductTypeId AS intTemplateProductTypeId
	,CASE 
		WHEN PRD.intProductTypeId = 2
			THEN PRDI.strItemNo
		WHEN PRD.intProductTypeId = 1
			THEN PRDC.strCategoryCode
		ELSE ''
		END AS strTemplateProductValue
	,T.strTestName
	,P.strPropertyName
	,UOM.strUnitMeasure
	,P1.strPropertyName AS strParentPropertyName
	,LI.strListItemName AS strTestListItemName
	,PRTI.strItemNo AS strPropertyItemNo
FROM tblQMTestResult TR WITH (NOLOCK)
JOIN tblQMSample S WITH (NOLOCK) ON S.intSampleId = TR.intSampleId
JOIN tblQMTest T WITH (NOLOCK) ON T.intTestId = TR.intTestId
JOIN tblQMProperty P WITH (NOLOCK) ON P.intPropertyId = TR.intPropertyId
JOIN tblQMProduct PRD WITH (NOLOCK) ON PRD.intProductId = TR.intProductId
LEFT JOIN tblICUnitMeasure UOM WITH (NOLOCK) ON UOM.intUnitMeasureId = TR.intUnitMeasureId
LEFT JOIN tblQMProperty P1 WITH (NOLOCK) ON P1.intPropertyId = TR.intParentPropertyId
LEFT JOIN tblQMListItem LI WITH (NOLOCK) ON LI.intListItemId = TR.intListItemId
LEFT JOIN tblICItem PRTI WITH (NOLOCK) ON PRTI.intItemId = TR.intPropertyItemId
LEFT JOIN tblICItem PRDI WITH (NOLOCK) ON PRDI.intItemId = PRD.intProductValueId
LEFT JOIN tblICCategory PRDC WITH (NOLOCK) ON PRDC.intCategoryId = PRD.intProductValueId
