﻿IF NOT EXISTS(SELECT * FROM tblMFRecipeItemType WHERE intRecipeItemTypeId = 1)
BEGIN
    INSERT INTO tblMFRecipeItemType(intRecipeItemTypeId,strName)
    VALUES(1,'INPUT')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFRecipeItemType WHERE intRecipeItemTypeId = 2)
BEGIN
    INSERT INTO tblMFRecipeItemType(intRecipeItemTypeId,strName)
    VALUES(2,'OUTPUT')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFConsumptionMethod WHERE intConsumptionMethodId = 1)
BEGIN
    INSERT INTO tblMFConsumptionMethod(intConsumptionMethodId,strName)
    VALUES(1,'By Lot')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFConsumptionMethod WHERE intConsumptionMethodId = 2)
BEGIN
    INSERT INTO tblMFConsumptionMethod(intConsumptionMethodId,strName)
    VALUES(2,'By Location')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFConsumptionMethod WHERE intConsumptionMethodId = 3)
BEGIN
    INSERT INTO tblMFConsumptionMethod(intConsumptionMethodId,strName)
    VALUES(3,'FIFO')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFConsumptionMethod WHERE intConsumptionMethodId = 4)
BEGIN
    INSERT INTO tblMFConsumptionMethod(intConsumptionMethodId,strName)
    VALUES(4,'None')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFCostDistributionMethod WHERE intCostDistributionMethodId = 1)
BEGIN
    INSERT INTO tblMFCostDistributionMethod(intCostDistributionMethodId,strName)
    VALUES(1,'By Quantity')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFCostDistributionMethod WHERE intCostDistributionMethodId = 2)
BEGIN
    INSERT INTO tblMFCostDistributionMethod(intCostDistributionMethodId,strName)
    VALUES(2,'By Percentage')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFBlendRequirementStatus WHERE intStatusId = 1)
BEGIN
    INSERT INTO tblMFBlendRequirementStatus(intStatusId,strName)
    VALUES(1,'New')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFBlendRequirementStatus WHERE intStatusId = 2)
BEGIN
    INSERT INTO tblMFBlendRequirementStatus(intStatusId,strName)
    VALUES(2,'Closed')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFWorkOrderProductionType WHERE intProductionTypeId = 1)
BEGIN
    INSERT INTO tblMFWorkOrderProductionType(intProductionTypeId,strName)
    VALUES(1,'Make To Order')
END
ELSE
BEGIN
	UPDATE tblMFWorkOrderProductionType
	SET strName = 'Make To Order'
	WHERE intProductionTypeId = 1
END
GO
IF NOT EXISTS(SELECT * FROM tblMFWorkOrderProductionType WHERE intProductionTypeId = 2)
BEGIN
    INSERT INTO tblMFWorkOrderProductionType(intProductionTypeId,strName)
    VALUES(2,'Stock')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFWorkOrderStatus WHERE intStatusId = 1)
BEGIN
    INSERT INTO tblMFWorkOrderStatus(intStatusId,strName,intSequenceNo)
    VALUES(1,'New',1)
END
ELSE
BEGIN
	UPDATE tblMFWorkOrderStatus SET intSequenceNo=1 WHERE intStatusId = 1
END
GO
IF NOT EXISTS(SELECT * FROM tblMFWorkOrderStatus WHERE intStatusId = 2)
BEGIN
    INSERT INTO tblMFWorkOrderStatus(intStatusId,strName)
    VALUES(2,'Not Released')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFWorkOrderStatus WHERE intStatusId = 3)
BEGIN
    INSERT INTO tblMFWorkOrderStatus(intStatusId,strName,intSequenceNo)
    VALUES(3,'Open',2)
END
ELSE
BEGIN
	UPDATE tblMFWorkOrderStatus SET intSequenceNo=2 WHERE intStatusId = 3
END

GO
IF NOT EXISTS(SELECT * FROM tblMFWorkOrderStatus WHERE intStatusId = 4)
BEGIN
    INSERT INTO tblMFWorkOrderStatus(intStatusId,strName,intSequenceNo)
    VALUES(4,'Frozen',3)
END
ELSE
BEGIN
	UPDATE tblMFWorkOrderStatus SET intSequenceNo=3 WHERE intStatusId = 4
END

GO
IF NOT EXISTS(SELECT * FROM tblMFWorkOrderStatus WHERE intStatusId = 5)
BEGIN
    INSERT INTO tblMFWorkOrderStatus(intStatusId,strName)
    VALUES(5,'Hold')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFWorkOrderStatus WHERE intStatusId = 6)
BEGIN
    INSERT INTO tblMFWorkOrderStatus(intStatusId,strName)
    VALUES(6,'Pre Kitted')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFWorkOrderStatus WHERE intStatusId = 7)
BEGIN
    INSERT INTO tblMFWorkOrderStatus(intStatusId,strName)
    VALUES(7,'Kitted')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFWorkOrderStatus WHERE intStatusId = 8)
BEGIN
    INSERT INTO tblMFWorkOrderStatus(intStatusId,strName)
    VALUES(8,'Kit Transferred')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFWorkOrderStatus WHERE intStatusId = 9)
BEGIN
    INSERT INTO tblMFWorkOrderStatus(intStatusId,strName,intSequenceNo)
    VALUES(9,'Released',3)
END
ELSE
BEGIN
	UPDATE tblMFWorkOrderStatus SET intSequenceNo=3 WHERE intStatusId = 9
END

GO
IF NOT EXISTS(SELECT * FROM tblMFWorkOrderStatus WHERE intStatusId = 10)
BEGIN
    INSERT INTO tblMFWorkOrderStatus(intStatusId,strName,intSequenceNo)
    VALUES(10,'Started',4)
END
ELSE
BEGIN
	UPDATE tblMFWorkOrderStatus SET intSequenceNo=4 WHERE intStatusId = 10
END

GO
IF NOT EXISTS(SELECT * FROM tblMFWorkOrderStatus WHERE intStatusId = 11)
BEGIN
    INSERT INTO tblMFWorkOrderStatus(intStatusId,strName,intSequenceNo)
    VALUES(11,'Paused',3)
END
ELSE
BEGIN
	UPDATE tblMFWorkOrderStatus SET intSequenceNo=3 WHERE intStatusId = 11
END

GO
IF NOT EXISTS(SELECT * FROM tblMFWorkOrderStatus WHERE intStatusId = 12)
BEGIN
    INSERT INTO tblMFWorkOrderStatus(intStatusId,strName)
    VALUES(12,'Staged')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFWorkOrderStatus WHERE intStatusId = 13)
BEGIN
    INSERT INTO tblMFWorkOrderStatus(intStatusId,strName)
    VALUES(13,'Completed')
END
GO
IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFReleaseStatus
		WHERE intReleaseStatusId=1
		)
BEGIN
	INSERT INTO dbo.tblMFReleaseStatus (
		intReleaseStatusId
		,strReleaseStatus
		)
	SELECT 1
		,'Release'
END
GO
IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFReleaseStatus
		WHERE intReleaseStatusId=2
		)
BEGIN
	INSERT INTO dbo.tblMFReleaseStatus (
		intReleaseStatusId
		,strReleaseStatus
		)
	SELECT 2
		,'Hold'
END
GO
IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFStationType
		WHERE intStationTypeId=1
		)
BEGIN
	INSERT INTO dbo.tblMFStationType (
		intStationTypeId
		,strStationTypeName
		)
	SELECT 1
		,'Sub Location'
END
GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFStationType
		WHERE intStationTypeId=2
		)
BEGIN
	INSERT INTO dbo.tblMFStationType (
		intStationTypeId
		,strStationTypeName
		)
	SELECT 2
		,'Parent Storage Location'
END
GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFStationType
		WHERE  intStationTypeId=3
		)
BEGIN
	INSERT INTO dbo.tblMFStationType (
		intStationTypeId
		,strStationTypeName
		)
	SELECT 3
		,'Storage Location'
END
GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFFloorMovementType
		WHERE intFloorMovementTypeId=1
		)
BEGIN
	INSERT INTO dbo.tblMFFloorMovementType (
		intFloorMovementTypeId
		,strFloorMovementTypeName
		)
	SELECT 1
		,'Storage Location'
END
GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFFloorMovementType
		WHERE intFloorMovementTypeId=2
		)
BEGIN
	INSERT INTO dbo.tblMFFloorMovementType (
		intFloorMovementTypeId
		,strFloorMovementTypeName
		)
	SELECT 2
		,'Machine'
END
GO
IF NOT EXISTS (
		SELECT *
		FROM tblMFAttributeDataType
		WHERE intAttributeDataTypeId = 1
		)
	INSERT INTO tblMFAttributeDataType (
		intAttributeDataTypeId
		,strAttributeDataTypeName
		)
	SELECT 1
		,'Bit'
GO
IF NOT EXISTS (
		SELECT *
		FROM tblMFAttributeDataType
		WHERE intAttributeDataTypeId = 2
		)
	INSERT INTO tblMFAttributeDataType (
		intAttributeDataTypeId
		,strAttributeDataTypeName
		)
	SELECT 2
		,'Integer'
GO
IF NOT EXISTS (
		SELECT *
		FROM tblMFAttributeDataType
		WHERE intAttributeDataTypeId = 3
		)
	INSERT INTO tblMFAttributeDataType (
		intAttributeDataTypeId
		,strAttributeDataTypeName
		)
	SELECT 3
		,'Decimal'
GO
IF NOT EXISTS (
		SELECT *
		FROM tblMFAttributeDataType
		WHERE intAttributeDataTypeId = 4
		)
	INSERT INTO tblMFAttributeDataType (
		intAttributeDataTypeId
		,strAttributeDataTypeName
		)
	SELECT 4
		,'DateTime'
GO
IF NOT EXISTS (
		SELECT *
		FROM tblMFAttributeDataType
		WHERE intAttributeDataTypeId = 5
		)
	INSERT INTO tblMFAttributeDataType (
		intAttributeDataTypeId
		,strAttributeDataTypeName
		)
	SELECT 5
		,'List'
GO

IF NOT EXISTS (
		SELECT *
		FROM tblMFAttributeDataType
		WHERE intAttributeDataTypeId = 6
		)
	INSERT INTO tblMFAttributeDataType (
		intAttributeDataTypeId
		,strAttributeDataTypeName
		)
	SELECT 6
		,'String'
GO
IF NOT EXISTS (
		SELECT *
		FROM tblMFManufacturingProcessRunDuration
		WHERE intManufacturingProcessRunDurationId = 1
		)
	INSERT INTO tblMFManufacturingProcessRunDuration (
		intManufacturingProcessRunDurationId
		,strManufacturingProcessRunDurationName
		)
	SELECT 1
		,'Open'
GO
IF NOT EXISTS (
		SELECT *
		FROM tblMFManufacturingProcessRunDuration
		WHERE intManufacturingProcessRunDurationId = 2
		)
	INSERT INTO tblMFManufacturingProcessRunDuration (
		intManufacturingProcessRunDurationId
		,strManufacturingProcessRunDurationName
		)
	SELECT 2
		,'By Shift'
GO
IF NOT EXISTS (
		SELECT *
		FROM tblMFManufacturingProcessRunDuration
		WHERE intManufacturingProcessRunDurationId = 3
		)
	INSERT INTO tblMFManufacturingProcessRunDuration (
		intManufacturingProcessRunDurationId
		,strManufacturingProcessRunDurationName
		)
	SELECT 3
		,'By Day'
GO
IF NOT EXISTS (
		SELECT *
		FROM tblMFManufacturingProcessRunDuration
		WHERE intManufacturingProcessRunDurationId = 4
		)
	INSERT INTO tblMFManufacturingProcessRunDuration (
		intManufacturingProcessRunDurationId
		,strManufacturingProcessRunDurationName
		)
	SELECT 4
		,'By Week'
GO
IF NOT EXISTS(SELECT * FROM tblMFBlendSheetRule WHERE intBlendSheetRuleId = 1)
BEGIN
    INSERT INTO tblMFBlendSheetRule(intBlendSheetRuleId,strName,intSequenceNo)
    VALUES(1,'Pick Order',1)
END
GO
IF NOT EXISTS(SELECT * FROM tblMFBlendSheetRule WHERE intBlendSheetRuleId = 2)
BEGIN
    INSERT INTO tblMFBlendSheetRule(intBlendSheetRuleId,strName,intSequenceNo)
    VALUES(2,'Is Cost Applicable?',2)
END
GO
IF NOT EXISTS(SELECT * FROM tblMFBlendSheetRule WHERE intBlendSheetRuleId = 3)
BEGIN
    INSERT INTO tblMFBlendSheetRule(intBlendSheetRuleId,strName,intSequenceNo)
    VALUES(3,'Is Quality Data Applicable?',3)
END
GO
IF NOT EXISTS(SELECT * FROM tblMFBlendSheetRuleValue WHERE intBlendSheetRuleId = 1 AND strValue='FIFO')
BEGIN
    INSERT INTO tblMFBlendSheetRuleValue(intBlendSheetRuleId,strValue,strDescription,ysnDefault)
    VALUES(1,'FIFO','FIFO',1)
END
GO
IF NOT EXISTS(SELECT * FROM tblMFBlendSheetRuleValue WHERE intBlendSheetRuleId = 1 AND strValue='FEFO')
BEGIN
    INSERT INTO tblMFBlendSheetRuleValue(intBlendSheetRuleId,strValue,strDescription,ysnDefault)
    VALUES(1,'FEFO','FEFO',0)
END
GO
IF NOT EXISTS(SELECT * FROM tblMFBlendSheetRuleValue WHERE intBlendSheetRuleId = 1 AND strValue='LIFO')
BEGIN
    INSERT INTO tblMFBlendSheetRuleValue(intBlendSheetRuleId,strValue,strDescription,ysnDefault)
    VALUES(1,'LIFO','LIFO',0)
END
GO
IF NOT EXISTS(SELECT * FROM tblMFBlendSheetRuleValue WHERE intBlendSheetRuleId = 1 AND strValue='LEFO')
BEGIN
    INSERT INTO tblMFBlendSheetRuleValue(intBlendSheetRuleId,strValue,strDescription,ysnDefault)
    VALUES(1,'LEFO','LEFO',0)
END
GO
IF NOT EXISTS(SELECT * FROM tblMFBlendSheetRuleValue WHERE intBlendSheetRuleId = 2 AND strValue='Yes')
BEGIN
    INSERT INTO tblMFBlendSheetRuleValue(intBlendSheetRuleId,strValue,strDescription,ysnDefault)
    VALUES(2,'Yes','Yes',0)
END
GO
IF NOT EXISTS(SELECT * FROM tblMFBlendSheetRuleValue WHERE intBlendSheetRuleId = 2 AND strValue='No')
BEGIN
    INSERT INTO tblMFBlendSheetRuleValue(intBlendSheetRuleId,strValue,strDescription,ysnDefault)
    VALUES(2,'No','No',1)
END
GO
IF NOT EXISTS(SELECT * FROM tblMFBlendSheetRuleValue WHERE intBlendSheetRuleId = 3 AND strValue='Yes')
BEGIN
    INSERT INTO tblMFBlendSheetRuleValue(intBlendSheetRuleId,strValue,strDescription,ysnDefault)
    VALUES(3,'Yes','Yes',0)
END
GO
IF NOT EXISTS(SELECT * FROM tblMFBlendSheetRuleValue WHERE intBlendSheetRuleId = 3 AND strValue='No')
BEGIN
    INSERT INTO tblMFBlendSheetRuleValue(intBlendSheetRuleId,strValue,strDescription,ysnDefault)
    VALUES(3,'No','No',1)
END
GO
IF NOT EXISTS(SELECT * FROM tblMFAttributeType WHERE intAttributeTypeId = 1)
BEGIN
    INSERT INTO tblMFAttributeType(intAttributeTypeId,strAttributeTypeName)
    VALUES(1,'Common')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFAttributeType WHERE intAttributeTypeId = 2)
BEGIN
    INSERT INTO tblMFAttributeType(intAttributeTypeId,strAttributeTypeName)
    VALUES(2,'Blending')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFAttributeType WHERE intAttributeTypeId = 3)
BEGIN
    INSERT INTO tblMFAttributeType(intAttributeTypeId,strAttributeTypeName)
    VALUES(3,'Packaging')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFAttributeType WHERE intAttributeTypeId = 4)
BEGIN
    INSERT INTO tblMFAttributeType(intAttributeTypeId,strAttributeTypeName)
    VALUES(4,'Others')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFBlendDemandStatus WHERE intStatusId = 1)
BEGIN
    INSERT INTO tblMFBlendDemandStatus(intStatusId,strName)
    VALUES(1,'New')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFBlendDemandStatus WHERE intStatusId = 2)
BEGIN
    INSERT INTO tblMFBlendDemandStatus(intStatusId,strName)
    VALUES(2,'Closed')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFMachineIssuedUOMType WHERE intIssuedUOMTypeId = 1)
BEGIN
    INSERT INTO tblMFMachineIssuedUOMType(intIssuedUOMTypeId,strName)
    VALUES(1,'Weight')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFMachineIssuedUOMType WHERE intIssuedUOMTypeId = 2)
BEGIN
    INSERT INTO tblMFMachineIssuedUOMType(intIssuedUOMTypeId,strName)
    VALUES(2,'Packed')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFBlendValidationMessageType WHERE intMessageTypeId = 1)
BEGIN
    INSERT INTO tblMFBlendValidationMessageType(intMessageTypeId,strName)
    VALUES(1,'Warning')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFBlendValidationMessageType WHERE intMessageTypeId = 2)
BEGIN
    INSERT INTO tblMFBlendValidationMessageType(intMessageTypeId,strName)
    VALUES(2,'Error')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFBlendValidationDefault WHERE intBlendValidationDefaultId = 1)
BEGIN
    INSERT INTO tblMFBlendValidationDefault(intBlendValidationDefaultId,strBlendValidationName,strMessage)
    VALUES(1,'Input Item Exist Validation','The system has detected that you have not selected any ingredient input lot(s) for item @1.')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFBlendValidationDefault WHERE intBlendValidationDefaultId = 2)
BEGIN
    INSERT INTO tblMFBlendValidationDefault(intBlendValidationDefaultId,strBlendValidationName,strMessage)
    VALUES(2,'Lot Expiry Date Validation','The selected lot @1 is expired.')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFBlendValidationDefault WHERE intBlendValidationDefaultId = 3)
BEGIN
    INSERT INTO tblMFBlendValidationDefault(intBlendValidationDefaultId,strBlendValidationName,strMessage)
    VALUES(3,'Lot Quarantine Status Validation','The selected lot @1 has quarantined status.')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFBlendValidationDefault WHERE intBlendValidationDefaultId = 4)
BEGIN
    INSERT INTO tblMFBlendValidationDefault(intBlendValidationDefaultId,strBlendValidationName,strMessage)
    VALUES(4,'Substitute Item Configuration Validation',
	'The system has detected that you have selected one substitute lot @1 for item @2. Is this correct?')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFBlendValidationDefault WHERE intBlendValidationDefaultId = 5)
BEGIN
    INSERT INTO tblMFBlendValidationDefault(intBlendValidationDefaultId,strBlendValidationName,strMessage)
    VALUES(5,'Reserve Quantity Greater Than Quantity To Produce Validation',
	'The system has detected that blend @1 is scheduled for @2 which is greater than the quantity to produce @3. Is this correct?')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFBlendValidationDefault WHERE intBlendValidationDefaultId = 6)
BEGIN
    INSERT INTO tblMFBlendValidationDefault(intBlendValidationDefaultId,strBlendValidationName,strMessage)
    VALUES(6,'Reserve Quantity Less Than Quantity To Produce Validation',
	'The system has detected that blend @1 is scheduled for @2 which is less than the quantity to produce @3. Is this correct?')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFBlendValidationDefault WHERE intBlendValidationDefaultId = 7)
BEGIN
    INSERT INTO tblMFBlendValidationDefault(intBlendValidationDefaultId,strBlendValidationName,strMessage)
    VALUES(7,'Available Quantity With Over-Commitment Greater Than Weight per Unit Validation',
	'The system has detected that the ingredient lot @1 has an available qty of @2 of item @3.'
	+'You are trying to schedule a requirement of @4 from this ingredient lot.'
	+'The over-commitment quantity is @5 which is greater than the weight per unit value of this ingredient lot.'
	+'It is suggested that you revise your choice of lots for item @6 for the sheet.'
	)
END
GO
IF NOT EXISTS(SELECT * FROM tblMFBlendValidationDefault WHERE intBlendValidationDefaultId = 8)
BEGIN
    INSERT INTO tblMFBlendValidationDefault(intBlendValidationDefaultId,strBlendValidationName,strMessage)
    VALUES(8,'Available Quantity With Over-Commitment Less Than Weight per Unit Validation',
	'The system has detected that the ingredient lot @1 has an available qty of @2 of item @3.'
	+'You are trying to schedule a requirement of @4 from this ingredient lot.'
	+'The over-commitment quantity is @5 which is less than the weight per unit value of this ingredient lot.'
	+'In this case the system will allow you to release the Blend sheet to finish off the ingredient lot.'
	+'You may still revise the blend sheet.'
	)
END
GO
UPDATE dbo.tblMFWorkOrderStatus
SET strBackColorName = 'bc-palegreen'
WHERE strBackColorName IS NULL
	AND intStatusId = 10
GO

UPDATE dbo.tblMFWorkOrderStatus
SET strBackColorName = 'bc-sandybrown'
WHERE strBackColorName IS NULL
	AND intStatusId = 11
GO

GO

IF NOT EXISTS (
		SELECT *
		FROM tblMFLotTransactionType
		WHERE intTransactionTypeId = 1
		)
BEGIN
	INSERT INTO tblMFLotTransactionType (
		intTransactionTypeId
		,ysnUndoneAllowed
		)
	VALUES (
		1
		,0
		)
END
GO

IF NOT EXISTS (
		SELECT *
		FROM tblMFLotTransactionType
		WHERE intTransactionTypeId = 2
		)
BEGIN
	INSERT INTO tblMFLotTransactionType (
		intTransactionTypeId
		,ysnUndoneAllowed
		)
	VALUES (
		2
		,0
		)
END
GO

IF NOT EXISTS (
		SELECT *
		FROM tblMFLotTransactionType
		WHERE intTransactionTypeId = 3
		)
BEGIN
	INSERT INTO tblMFLotTransactionType (
		intTransactionTypeId
		,ysnUndoneAllowed
		)
	VALUES (
		3
		,0
		)
END
GO

IF NOT EXISTS (
		SELECT *
		FROM tblMFLotTransactionType
		WHERE intTransactionTypeId = 4
		)
BEGIN
	INSERT INTO tblMFLotTransactionType (
		intTransactionTypeId
		,ysnUndoneAllowed
		)
	VALUES (
		4
		,0
		)
END
GO

IF NOT EXISTS (
		SELECT *
		FROM tblMFLotTransactionType
		WHERE intTransactionTypeId = 5
		)
BEGIN
	INSERT INTO tblMFLotTransactionType (
		intTransactionTypeId
		,ysnUndoneAllowed
		)
	VALUES (
		5
		,0
		)
END
GO

IF NOT EXISTS (
		SELECT *
		FROM tblMFLotTransactionType
		WHERE intTransactionTypeId = 6
		)
BEGIN
	INSERT INTO tblMFLotTransactionType (
		intTransactionTypeId
		,ysnUndoneAllowed
		)
	VALUES (
		6
		,0
		)
END
GO

IF NOT EXISTS (
		SELECT *
		FROM tblMFLotTransactionType
		WHERE intTransactionTypeId = 7
		)
BEGIN
	INSERT INTO tblMFLotTransactionType (
		intTransactionTypeId
		,ysnUndoneAllowed
		)
	VALUES (
		7
		,0
		)
END
GO

IF NOT EXISTS (
		SELECT *
		FROM tblMFLotTransactionType
		WHERE intTransactionTypeId = 8
		)
BEGIN
	INSERT INTO tblMFLotTransactionType (
		intTransactionTypeId
		,ysnUndoneAllowed
		)
	VALUES (
		8
		,0
		)
END
GO

IF NOT EXISTS (
		SELECT *
		FROM tblMFLotTransactionType
		WHERE intTransactionTypeId = 9
		)
BEGIN
	INSERT INTO tblMFLotTransactionType (
		intTransactionTypeId
		,ysnUndoneAllowed
		)
	VALUES (
		9
		,0
		)
END
GO

IF NOT EXISTS (
		SELECT *
		FROM tblMFLotTransactionType
		WHERE intTransactionTypeId = 10
		)
BEGIN
	INSERT INTO tblMFLotTransactionType (
		intTransactionTypeId
		,ysnUndoneAllowed
		)
	VALUES (
		10
		,0
		)
END
GO

IF NOT EXISTS (
		SELECT *
		FROM tblMFLotTransactionType
		WHERE intTransactionTypeId = 11
		)
BEGIN
	INSERT INTO tblMFLotTransactionType (
		intTransactionTypeId
		,ysnUndoneAllowed
		)
	VALUES (
		11
		,0
		)
END
GO

IF NOT EXISTS (
		SELECT *
		FROM tblMFLotTransactionType
		WHERE intTransactionTypeId = 12
		)
BEGIN
	INSERT INTO tblMFLotTransactionType (
		intTransactionTypeId
		,ysnUndoneAllowed
		)
	VALUES (
		12
		,0
		)
END
GO

IF NOT EXISTS (
		SELECT *
		FROM tblMFLotTransactionType
		WHERE intTransactionTypeId = 13
		)
BEGIN
	INSERT INTO tblMFLotTransactionType (
		intTransactionTypeId
		,ysnUndoneAllowed
		)
	VALUES (
		13
		,0
		)
END
GO

IF NOT EXISTS (
		SELECT *
		FROM tblMFLotTransactionType
		WHERE intTransactionTypeId = 14
		)
BEGIN
	INSERT INTO tblMFLotTransactionType (
		intTransactionTypeId
		,ysnUndoneAllowed
		)
	VALUES (
		14
		,0
		)
END
GO

IF NOT EXISTS (
		SELECT *
		FROM tblMFLotTransactionType
		WHERE intTransactionTypeId = 15
		)
BEGIN
	INSERT INTO tblMFLotTransactionType (
		intTransactionTypeId
		,ysnUndoneAllowed
		)
	VALUES (
		15
		,0
		)
END
GO

IF NOT EXISTS (
		SELECT *
		FROM tblMFLotTransactionType
		WHERE intTransactionTypeId = 16
		)
BEGIN
	INSERT INTO tblMFLotTransactionType (
		intTransactionTypeId
		,ysnUndoneAllowed
		)
	VALUES (
		16
		,0
		)
END
GO

IF NOT EXISTS (
		SELECT *
		FROM tblMFLotTransactionType
		WHERE intTransactionTypeId = 17
		)
BEGIN
	INSERT INTO tblMFLotTransactionType (
		intTransactionTypeId
		,ysnUndoneAllowed
		)
	VALUES (
		17
		,0
		)
END
GO

IF NOT EXISTS (
		SELECT *
		FROM tblMFLotTransactionType
		WHERE intTransactionTypeId = 18
		)
BEGIN
	INSERT INTO tblMFLotTransactionType (
		intTransactionTypeId
		,ysnUndoneAllowed
		)
	VALUES (
		18
		,0
		)
END
GO

IF NOT EXISTS (
		SELECT *
		FROM tblMFLotTransactionType
		WHERE intTransactionTypeId = 19
		)
BEGIN
	INSERT INTO tblMFLotTransactionType (
		intTransactionTypeId
		,ysnUndoneAllowed
		)
	VALUES (
		19
		,0
		)
END
GO

IF NOT EXISTS (
		SELECT *
		FROM tblMFLotTransactionType
		WHERE intTransactionTypeId = 20
		)
BEGIN
	INSERT INTO tblMFLotTransactionType (
		intTransactionTypeId
		,ysnUndoneAllowed
		)
	VALUES (
		20
		,0
		)
END
GO

IF NOT EXISTS (
		SELECT *
		FROM tblMFLotTransactionType
		WHERE intTransactionTypeId = 21
		)
BEGIN
	INSERT INTO tblMFLotTransactionType (
		intTransactionTypeId
		,ysnUndoneAllowed
		)
	VALUES (
		21
		,0
		)
END
GO
IF NOT EXISTS (
		SELECT *
		FROM tblMFScheduleAttribute
		WHERE intScheduleAttributeId = 1
		)
BEGIN
	INSERT INTO tblMFScheduleAttribute (
		intScheduleAttributeId
		,strName
		,strTableName
		,strColumnName
		)
	VALUES (
		1
		,'Pack Type Change'
		,'vyuMFGetPackType'
		,'strPackName'
		)
END
ELSE
BEGIN
	UPDATE tblMFScheduleAttribute SET strTableName ='vyuMFGetPackType' WHERE  intScheduleAttributeId = 1
END
GO

IF NOT EXISTS (
		SELECT *
		FROM tblMFScheduleAttribute
		WHERE intScheduleAttributeId = 2
		)
BEGIN
	INSERT INTO tblMFScheduleAttribute (
		intScheduleAttributeId
		,strName
		,strTableName
		,strColumnName
		)
	VALUES (
		2
		,'Blend Change'
		,'vyuMFGetBlendItem'
		,'strWIPItemNo'
		)
END
Else
Begin
	Update tblMFScheduleAttribute Set strColumnName='strWIPItemNo' Where intScheduleAttributeId=2
End
Go
IF NOT EXISTS (
		SELECT *
		FROM tblMFHolidayType
		WHERE intHolidayTypeId = 1
		)
BEGIN
	INSERT INTO tblMFHolidayType (
		intHolidayTypeId
		,strName
		)
	VALUES (
		1
		,'General/Public'
		)
END
GO

IF NOT EXISTS (
		SELECT *
		FROM tblMFHolidayType
		WHERE intHolidayTypeId = 2
		)
BEGIN
	INSERT INTO tblMFHolidayType (
		intHolidayTypeId
		,strName
		)
	VALUES (
		2
		,'Weekly'
		)
END
GO
IF NOT EXISTS(SELECT * FROM tblMFWorkOrderRecipeComputationType WHERE intTypeId = 1)
BEGIN
	INSERT INTO tblMFWorkOrderRecipeComputationType(intTypeId,strName)
	VALUES(1,'Blend Management')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFWorkOrderRecipeComputationType WHERE intTypeId = 2)
BEGIN
	INSERT INTO tblMFWorkOrderRecipeComputationType(intTypeId,strName)
	VALUES(2,'Blend Production')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFWorkOrderRecipeComputationMethod WHERE intMethodId = 1)
BEGIN
	INSERT INTO tblMFWorkOrderRecipeComputationMethod(intMethodId,strName)
	VALUES(1,'Weighted Average')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFBudgetType WHERE intBudgetTypeId = 1)
BEGIN
    INSERT INTO tblMFBudgetType(intBudgetTypeId,strName,strDescription)
    VALUES(1,'B','Budget')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFBudgetType WHERE intBudgetTypeId = 2)
BEGIN
    INSERT INTO tblMFBudgetType(intBudgetTypeId,strName,strDescription)
    VALUES(2,'A','Affordability')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFBudgetType WHERE intBudgetTypeId = 3)
BEGIN
    INSERT INTO tblMFBudgetType(intBudgetTypeId,strName,strDescription)
    VALUES(3,'M','Month Average')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFBudgetType WHERE intBudgetTypeId = 4)
BEGIN
    INSERT INTO tblMFBudgetType(intBudgetTypeId,strName,strDescription)
    VALUES(4,'V','Variance')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFBudgetType WHERE intBudgetTypeId = 5)
BEGIN
    INSERT INTO tblMFBudgetType(intBudgetTypeId,strName,strDescription)
    VALUES(5,'P','Total Pounds')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFBudgetType WHERE intBudgetTypeId = 6)
BEGIN
    INSERT INTO tblMFBudgetType(intBudgetTypeId,strName,strDescription)
    VALUES(6,'I','Impact (USD)')
END
GO
DELETE
FROM tblMFManufacturingProcessRunDuration
WHERE intManufacturingProcessRunDurationId IN (
		1
		,4
		)
GO
--Open
GO
UPDATE dbo.tblMFWorkOrderStatus
SET strBackColorName = 'bc-paleturquoise'
WHERE intStatusId = 3
GO

--Released
UPDATE dbo.tblMFWorkOrderStatus
SET strBackColorName = 'bc-gold'
WHERE  intStatusId = 9
GO

--Frozen
UPDATE dbo.tblMFWorkOrderStatus
SET strBackColorName = 'bc-gainsboro'
WHERE  intStatusId = 4
GO
IF EXISTS (
		SELECT *
		FROM tblMFCompanyPreference
		)
BEGIN
	UPDATE tblMFCompanyPreference
	SET intDefaultGanttChartViewDuration = 7
END
ELSE
BEGIN
	INSERT INTO tblMFCompanyPreference (intDefaultGanttChartViewDuration)
	SELECT 7
END
GO
IF NOT EXISTS(SELECT * FROM tblMFPickListPreference WHERE intPickListPreferenceId = 1)
BEGIN
    INSERT INTO tblMFPickListPreference(intPickListPreferenceId,strName)
    VALUES(1,'Best Match')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFPickListPreference WHERE intPickListPreferenceId = 2)
BEGIN
    INSERT INTO tblMFPickListPreference(intPickListPreferenceId,strName)
    VALUES(2,'Partial Match')
END
GO
UPDATE tblMFCompanyPreference
SET ysnConsiderSumOfChangeoverTime = 0
WHERE ysnConsiderSumOfChangeoverTime IS NULL
GO
UPDATE tblMFCompanyPreference
SET intStandardSetUpDuration = 0
WHERE intStandardSetUpDuration IS NULL
GO
IF NOT EXISTS (
		SELECT *
		FROM dbo.tblICLotStatus
		WHERE strSecondaryStatus = 'Pre-Sanitized'
		)
BEGIN
	INSERT INTO dbo.tblICLotStatus (
		strSecondaryStatus
		,strDescription
		,strPrimaryStatus
		,intConcurrencyId
		)
	SELECT 'Pre-Sanitized'
		,'Pre-Sanitized'
		,'Quarantine'
		,0
END
Go
UPDATE dbo.tblMFCompanyPreference
SET strDefaultStatusForSanitizedLot ='SANITIZED'
WHERE strDefaultStatusForSanitizedLot IS NULL
Go
GO

DECLARE @intPropertyId INT

SELECT @intPropertyId = intPropertyId
FROM tblQMProperty
WHERE strPropertyName = 'Caffeine'

IF @intPropertyId IS NOT NULL
	AND NOT EXISTS (
		SELECT *
		FROM tblMFReportProperty
		WHERE strReportName = 'BagOff Label'
			AND intPropertyId = @intPropertyId
			AND intSequenceNo = 1
		)
BEGIN
	INSERT INTO tblMFReportProperty (
		strReportName
		,intPropertyId
		,intSequenceNo
		)
	SELECT 'BagOff Label'
		,@intPropertyId
		,1
END
GO

DECLARE @intPropertyId INT

SELECT @intPropertyId = intPropertyId
FROM tblQMProperty
WHERE strPropertyName = 'Moisture'

IF @intPropertyId IS NOT NULL
	AND NOT EXISTS (
		SELECT *
		FROM tblMFReportProperty
		WHERE strReportName = 'BagOff Label'
			AND intPropertyId = @intPropertyId
			AND intSequenceNo = 2
		)
BEGIN
	INSERT INTO tblMFReportProperty (
		strReportName
		,intPropertyId
		,intSequenceNo
		)
	SELECT 'BagOff Label'
		,@intPropertyId
		,2
END

GO

DECLARE @intPropertyId INT

SELECT @intPropertyId = intPropertyId
FROM tblQMProperty
WHERE strPropertyName = 'Moisture'

IF @intPropertyId IS NOT NULL
	AND NOT EXISTS (
		SELECT *
		FROM tblMFReportProperty
		WHERE strReportName = 'Tote Label'
			AND intPropertyId = @intPropertyId
			AND intSequenceNo = 1
		)
BEGIN
	INSERT INTO tblMFReportProperty (
		strReportName
		,intPropertyId
		,intSequenceNo
		)
	SELECT 'Tote Label'
		,@intPropertyId
		,1
END
GO

DECLARE @intPropertyId INT

SELECT @intPropertyId = intPropertyId
FROM tblQMProperty
WHERE strPropertyName = 'Density'

IF @intPropertyId IS NOT NULL
	AND NOT EXISTS (
		SELECT *
		FROM tblMFReportProperty
		WHERE strReportName = 'Tote Label'
			AND intPropertyId = @intPropertyId
			AND intSequenceNo = 2
		)
BEGIN
	INSERT INTO tblMFReportProperty (
		strReportName
		,intPropertyId
		,intSequenceNo
		)
	SELECT 'Tote Label'
		,@intPropertyId
		,2
END
Go
GO

DECLARE @intPropertyId INT

SELECT @intPropertyId = intPropertyId
FROM tblQMProperty
WHERE strPropertyName = 'Color'

IF @intPropertyId IS NOT NULL
	AND NOT EXISTS (
		SELECT *
		FROM tblMFReportProperty
		WHERE strReportName = 'Tote Label'
			AND intPropertyId = @intPropertyId
			AND intSequenceNo = 3
		)
BEGIN
	INSERT INTO tblMFReportProperty (
		strReportName
		,intPropertyId
		,intSequenceNo
		)
	SELECT 'Tote Label'
		,@intPropertyId
		,3
END
GO

DECLARE @intPropertyId INT

SELECT @intPropertyId = intPropertyId
FROM tblQMProperty
WHERE strPropertyName = 'Rework Comments'

IF @intPropertyId IS NOT NULL
	AND NOT EXISTS (
		SELECT *
		FROM tblMFReportProperty
		WHERE strReportName = 'Tote Label'
			AND intPropertyId = @intPropertyId
			AND intSequenceNo = 4
		)
BEGIN
	INSERT INTO tblMFReportProperty (
		strReportName
		,intPropertyId
		,intSequenceNo
		)
	SELECT 'Tote Label'
		,@intPropertyId
		,4
END
Go