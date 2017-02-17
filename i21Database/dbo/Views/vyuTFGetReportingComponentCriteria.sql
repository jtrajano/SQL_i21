CREATE VIEW [dbo].[vyuTFGetReportingComponentCriteria]
	AS 

SELECT RCCR.intReportingComponentCriteriaId
	, RCCR.intReportingComponentId
	, RCCR.strCriteria
	, RCCR.intTaxCategoryId
	, strTaxCategory = TCT.strTaxCategory
	, strState = TCT.strState
FROM tblTFReportingComponentCriteria RCCR
LEFT JOIN tblTFTaxCategory TCT ON TCT.intTaxCategoryId = RCCR.intTaxCategoryId
LEFT JOIN tblTFReportingComponent RC ON RC.intReportingComponentId = RCCR.intReportingComponentId
