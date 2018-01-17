CREATE VIEW [dbo].[vyuTFGetReportingComponentField]
	AS
	
SELECT RCField.intReportingComponentFieldId
	, RCField.intReportingComponentId
	, RCField.strColumn
	, RCField.strCaption
	, RCField.strFormat
	, RCField.strFooter
	, RCField.intWidth
	, RCField.intMasterId
FROM tblTFReportingComponentField RCField