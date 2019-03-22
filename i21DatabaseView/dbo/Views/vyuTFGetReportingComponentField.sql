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
	, ysnFromConfiguration = ISNULL(RCField.ysnFromConfiguration, 0)
	, strConfigurationValue = Fields.strConfigurationValue
	, RCField.intConcurrencyId
FROM tblTFReportingComponentField RCField
LEFT JOIN vyuTFGetOutputDesignerField Fields ON Fields.strColumnName = RCField.strColumn
	AND Fields.intReportingComponentId = RCField.intReportingComponentId
	AND Fields.ysnFromConfiguration = 1
