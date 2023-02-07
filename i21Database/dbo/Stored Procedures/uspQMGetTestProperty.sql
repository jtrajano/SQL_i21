CREATE PROCEDURE [dbo].[uspQMGetTestProperty] 
( 
	@intTestId		INT
  , @intProductId	INT
)
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

SELECT TestProperty.intTestId
	 , TestProperty.intPropertyId
	 , Test.strTestName
	 , Property.strPropertyName
	 , DataType.intDataTypeId
	 , @intProductId AS intProductId
	 , Property.strIsMandatory
	 , DataType.strDataTypeName
	 , PropertyPeriod.dblPinpointValue
	 , PropertyPeriod.dblMaxValue
	 , PropertyPeriod.dblMinValue
FROM tblQMTestProperty AS TestProperty
JOIN tblQMTest AS Test ON Test.intTestId = TestProperty.intTestId
JOIN tblQMProperty AS Property ON Property.intPropertyId = TestProperty.intPropertyId
JOIN tblQMDataType AS DataType ON DataType.intDataTypeId = Property.intDataTypeId
LEFT JOIN tblQMPropertyValidityPeriod AS PropertyPeriod ON TestProperty.intPropertyId = PropertyPeriod.intPropertyId
WHERE TestProperty.intTestId = @intTestId
ORDER BY TestProperty.intSequenceNo;