CREATE VIEW [dbo].[vyuMFProcessAttributeDetail]
AS
/****************************************************************
	Title: Manufacturing Process Attribute Value & Detail
	Description: Simplified retrieval of value from Manufacturing Process Attribute.
	JIRA: MFG-4936
	Created By: Jonathan Valenzuela
	Date: 03/28/2023
*****************************************************************/
SELECT ProcessAttribute.intManufacturingProcessAttributeId
	 , ProcessAttribute.intManufacturingProcessId
	 , ProcessAttribute.strAttributeValue
	 , ProcessAttribute.intAttributeId
	 , ProcessAttribute.intLocationId
     , Attribute.strAttributeName
	 , Attribute.intAttributeDataTypeId
	 , AttributeType.strAttributeTypeName
FROM tblMFManufacturingProcessAttribute AS ProcessAttribute
JOIN tblMFAttribute AS Attribute ON ProcessAttribute.intAttributeId = Attribute.intAttributeId
JOIN tblMFAttributeType AS AttributeType ON Attribute.intAttributeTypeId = AttributeType.intAttributeTypeId;


