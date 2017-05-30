IF NOT EXISTS(SELECT * FROM tblMFRecipeItemType WHERE intRecipeItemTypeId = 1)
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
IF NOT EXISTS(SELECT * FROM tblMFWorkOrderStatus WHERE intStatusId = 14)
BEGIN
    INSERT INTO tblMFWorkOrderStatus(intStatusId,strName)
    VALUES(14,'Cancel')
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
    VALUES(4,'Bag Off')
END
ELSE
BEGIN
	UPDATE tblMFAttributeType SET strAttributeTypeName='Bag Off' WHERE intAttributeTypeId = 4
END
GO
IF NOT EXISTS(SELECT * FROM tblMFAttributeType WHERE intAttributeTypeId = 5)
BEGIN
    INSERT INTO tblMFAttributeType(intAttributeTypeId,strAttributeTypeName)
    VALUES(5,'Process Production')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFAttributeType WHERE intAttributeTypeId = 6)
BEGIN
    INSERT INTO tblMFAttributeType(intAttributeTypeId,strAttributeTypeName)
    VALUES(6,'Others')
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
	Where intDefaultGanttChartViewDuration IS NULL
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
		FROM tblQMReportProperty
		WHERE strReportName = 'BagOff Label'
			AND intPropertyId = @intPropertyId
		)
BEGIN
	INSERT INTO tblQMReportProperty (
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
		FROM tblQMReportProperty
		WHERE strReportName = 'BagOff Label'
			AND intPropertyId = @intPropertyId
		)
BEGIN
	INSERT INTO tblQMReportProperty (
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
		FROM tblQMReportProperty
		WHERE strReportName = 'Tote Label'
			AND intPropertyId = @intPropertyId
		)
BEGIN
	INSERT INTO tblQMReportProperty (
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
		FROM tblQMReportProperty
		WHERE strReportName = 'Tote Label'
			AND intPropertyId = @intPropertyId
		)
BEGIN
	INSERT INTO tblQMReportProperty (
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
		FROM tblQMReportProperty
		WHERE strReportName = 'Tote Label'
			AND intPropertyId = @intPropertyId
		)
BEGIN
	INSERT INTO tblQMReportProperty (
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
		FROM tblQMReportProperty
		WHERE strReportName = 'Tote Label'
			AND intPropertyId = @intPropertyId
		)
BEGIN
	INSERT INTO tblQMReportProperty (
		strReportName
		,intPropertyId
		,intSequenceNo
		)
	SELECT 'Tote Label'
		,@intPropertyId
		,4
END
Go
GO
UPDATE tblMFCompanyPreference
SET ysnSanitizationInboundPutaway = 0
WHERE ysnSanitizationInboundPutaway IS NULL
--GO
--UPDATE tblMFCompanyPreference
--SET dblSanitizationOrderOutputQtyTolerancePercentage = 2
--WHERE dblSanitizationOrderOutputQtyTolerancePercentage IS NULL
GO
IF NOT EXISTS(SELECT * FROM tblMFReadingPoint WHERE intReadingPointId = 1)
BEGIN
    INSERT INTO tblMFReadingPoint(intReadingPointId,strName)
    VALUES(1,'Both')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFReadingPoint WHERE intReadingPointId = 2)
BEGIN
    INSERT INTO tblMFReadingPoint(intReadingPointId,strName)
    VALUES(2,'Consume')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFReadingPoint WHERE intReadingPointId = 3)
BEGIN
    INSERT INTO tblMFReadingPoint(intReadingPointId,strName)
    VALUES(3,'Produce')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFMeasurement WHERE intMeasurementId = 1)
BEGIN
    INSERT INTO tblMFMeasurement(intMeasurementId,strName,strType)
    VALUES(1,'Pulse Reading','F')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFMeasurement WHERE intMeasurementId = 2)
BEGIN
    INSERT INTO tblMFMeasurement(intMeasurementId,strName,strType)
    VALUES(2,'Tape Reading','T')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFMeasurement WHERE intMeasurementId = 3)
BEGIN
    INSERT INTO tblMFMeasurement(intMeasurementId,strName,strType)
    VALUES(3,'Totalizer Reading','F')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFRecipeType WHERE intRecipeTypeId = 1)
BEGIN
    INSERT INTO tblMFRecipeType(intRecipeTypeId,strName)
    VALUES(1,'By Quantity')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFRecipeType WHERE intRecipeTypeId = 2)
BEGIN
    INSERT INTO tblMFRecipeType(intRecipeTypeId,strName)
    VALUES(2,'By Percentage')
END
GO
Update tblMFRecipe Set intRecipeTypeId=1 Where intRecipeTypeId IS NULL
GO

IF EXISTS (SELECT * FROM tblWHCompanyPreference)
BEGIN
	DELETE FROM tblWHCompanyPreference
END

INSERT INTO tblWHCompanyPreference (intCompanyLocationId, intAllowablePickDayRange, ysnAllowMoveAssignedTask, ysnScanForkliftOnLogin, strHandheldType, strWarehouseType, intContainerMinimumLength, intLocationMinLength, ysnNegativeQtyAllowed, ysnPartialMoveAllowed, ysnGTINCaseCodeMandatory, ysnEnableMoveAndMergeSplit, ysnTicketLabelToPrinter, intNoOfCopiesToPrintforPalletSlip, strWebServiceServerURL, strWMSStatus, dblPalletWeight, intNumberOfDecimalPlaces, ysnCreateLoadTasks, intMaximumPalletsOnForklift)
SELECT intCompanyLocationId, 30, 1, 0, 'Small', 'Lite', 3, 3, 0, 0, 1, 1, 1, 3, '', 'Release,Hold', 50.000000, 4, 0, 3
FROM tblSMCompanyLocation

GO

GO
IF NOT EXISTS(SELECT 1 FROM tblMFShiftActivityStatus WHERE intShiftActivityStatusId = 1)
BEGIN
    INSERT INTO tblMFShiftActivityStatus(intShiftActivityStatusId,strStatus)
    VALUES(1,'Not Started')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblMFShiftActivityStatus WHERE intShiftActivityStatusId = 2)
BEGIN
    INSERT INTO tblMFShiftActivityStatus(intShiftActivityStatusId,strStatus)
    VALUES(2,'Started')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblMFShiftActivityStatus WHERE intShiftActivityStatusId = 3)
BEGIN
    INSERT INTO tblMFShiftActivityStatus(intShiftActivityStatusId,strStatus)
    VALUES(3,'Completed')
END
GO

GO
IF NOT EXISTS(SELECT 1 FROM tblMFWastageType WHERE intWastageTypeId = 1)
BEGIN
    INSERT INTO tblMFWastageType(intWastageTypeId,strWastageTypeName)
    VALUES(1,'ReClaim')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblMFWastageType WHERE intWastageTypeId = 2)
BEGIN
    INSERT INTO tblMFWastageType(intWastageTypeId,strWastageTypeName)
    VALUES(2,'Waste')
END
GO

GO
IF NOT EXISTS(SELECT 1 FROM tblMFReasonType WHERE intReasonTypeId = 1)
BEGIN
    INSERT INTO tblMFReasonType(intReasonTypeId,strReasonName)
    VALUES(1,'Common')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblMFReasonType WHERE intReasonTypeId = 2)
BEGIN
    INSERT INTO tblMFReasonType(intReasonTypeId,strReasonName)
    VALUES(2,'Forecasting')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblMFReasonType WHERE intReasonTypeId = 3)
BEGIN
    INSERT INTO tblMFReasonType(intReasonTypeId,strReasonName)
    VALUES(3,'Inventory')
END
GO
GO
IF NOT EXISTS(SELECT 1 FROM tblMFReasonType WHERE intReasonTypeId = 4)
BEGIN
    INSERT INTO tblMFReasonType(intReasonTypeId,strReasonName)
    VALUES(4,'Efficiency')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFItemSubstitutionType WHERE intItemSubstitutionTypeId = 1)
BEGIN
    INSERT INTO tblMFItemSubstitutionType(intItemSubstitutionTypeId,strName)
    VALUES(1,'Replacement')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFItemSubstitutionType WHERE intItemSubstitutionTypeId = 2)
BEGIN
    INSERT INTO tblMFItemSubstitutionType(intItemSubstitutionTypeId,strName)
    VALUES(2,'Substitute')
END
GO
UPDATE tblMFCompanyPreference
SET ysnAutoPriorityOrderByDemandRatio = 0
WHERE ysnAutoPriorityOrderByDemandRatio IS NULL
Go

UPDATE tblMFCompanyPreference
SET dtmWorkOrderCreateDate = '2013-11-30 00:00:00.000'
WHERE dtmWorkOrderCreateDate IS NULL
Go

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFYieldTransaction
		WHERE strYieldTransactionName = 'Input'
		)
BEGIN
	INSERT INTO dbo.tblMFYieldTransaction (
		intYieldTransactionId
		,strYieldTransactionName
		,ysnProcessRelated
		,ysnInputTransaction
		)
	SELECT 1
		,'Input'
		,1
		,1
END
GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFYieldTransaction
		WHERE strYieldTransactionName = 'Output'
		)
BEGIN
	INSERT INTO dbo.tblMFYieldTransaction (
		intYieldTransactionId
		,strYieldTransactionName
		,ysnProcessRelated
		,ysnInputTransaction
		)
	SELECT 2
		,'Output'
		,1
		,0
END
GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFYieldTransaction
		WHERE strYieldTransactionName = 'Empty Out Adj'
		)
BEGIN
	INSERT INTO dbo.tblMFYieldTransaction (
		intYieldTransactionId
		,strYieldTransactionName
		,ysnProcessRelated
		,ysnInputTransaction
		)
	SELECT 3
		,'Empty Out Adj'
		,0
		,1
END
GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFYieldTransaction
		WHERE strYieldTransactionName = 'Cycle Count Adj'
		)
BEGIN
	INSERT INTO dbo.tblMFYieldTransaction (
		intYieldTransactionId
		,strYieldTransactionName
		,ysnProcessRelated
		,ysnInputTransaction
		)
	SELECT 4
		,'Cycle Count Adj'
		,0
		,0
END
GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFYieldTransaction
		WHERE strYieldTransactionName = 'Queued Qty Adj'
		)
BEGIN
	INSERT INTO dbo.tblMFYieldTransaction (
		intYieldTransactionId
		,strYieldTransactionName
		,ysnProcessRelated
		,ysnInputTransaction
		)
	SELECT 5
		,'Queued Qty Adj'
		,0
		,0
END
GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFYieldTransaction
		WHERE strYieldTransactionName = 'Output Opening Quantity'
		)
BEGIN
	INSERT INTO dbo.tblMFYieldTransaction (
		intYieldTransactionId
		,strYieldTransactionName
		,ysnProcessRelated
		,ysnInputTransaction
		)
	SELECT 6
		,'Output Opening Quantity'
		,1
		,0
END
GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFYieldTransaction
		WHERE strYieldTransactionName = 'Output Count Quantity'
		)
BEGIN
	INSERT INTO dbo.tblMFYieldTransaction (
		intYieldTransactionId
		,strYieldTransactionName
		,ysnProcessRelated
		,ysnInputTransaction
		)
	SELECT 7
		,'Output Count Quantity'
		,1
		,0
END
GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFYieldTransaction
		WHERE strYieldTransactionName = 'Opening Quantity'
		)
BEGIN
	INSERT INTO dbo.tblMFYieldTransaction (
		intYieldTransactionId
		,strYieldTransactionName
		,ysnProcessRelated
		,ysnInputTransaction
		)
	SELECT 8
		,'Opening Quantity'
		,1
		,1
END
GO

IF NOT EXISTS (
		SELECT *
		FROM dbo.tblMFYieldTransaction
		WHERE strYieldTransactionName = 'Count Quantity'
		)
BEGIN
	INSERT INTO dbo.tblMFYieldTransaction (
		intYieldTransactionId
		,strYieldTransactionName
		,ysnProcessRelated
		,ysnInputTransaction
		)
	SELECT 9
		,'Count Quantity'
		,1
		,1
END
ELSE

BEGIN
	UPDATE tblMFYieldTransaction
	SET ysnInputTransaction = 1
	WHERE intYieldTransactionId = 9
END

GO

IF NOT EXISTS (
		SELECT *
		FROM tblMFSubPatternType
		WHERE intSubPatternTypeId = 1
		)
BEGIN
	INSERT INTO tblMFSubPatternType (
		intSubPatternTypeId
		,strSubPatternTypeName
		)
	SELECT 1
		,'STRING'
END
GO

IF NOT EXISTS (
		SELECT *
		FROM tblMFSubPatternType
		WHERE intSubPatternTypeId = 2
		)
BEGIN
	INSERT INTO tblMFSubPatternType (
		intSubPatternTypeId
		,strSubPatternTypeName
		)
	SELECT 2
		,'NUMBER'
END
GO
IF NOT EXISTS (
		SELECT *
		FROM tblMFSubPatternType
		WHERE intSubPatternTypeId = 3
		)
BEGIN
	INSERT INTO tblMFSubPatternType (
		intSubPatternTypeId
		,strSubPatternTypeName
		)
	SELECT 3
		,'DATETIME'
END
GO
IF NOT EXISTS (
		SELECT *
		FROM tblMFSubPatternType
		WHERE intSubPatternTypeId = 4
		)
BEGIN
	INSERT INTO tblMFSubPatternType (
		intSubPatternTypeId
		,strSubPatternTypeName
		)
	SELECT 4
		,'TABLECOLUMN'
END
GO
IF NOT EXISTS (
		SELECT *
		FROM tblMFSubPatternType
		WHERE intSubPatternTypeId = 5
		)
BEGIN
	INSERT INTO tblMFSubPatternType (
		intSubPatternTypeId
		,strSubPatternTypeName
		)
	SELECT 5
		,'SPLCHAR'
END
GO
IF NOT EXISTS (
		SELECT *
		FROM tblMFSubPatternType
		WHERE intSubPatternTypeId = 6
		)
BEGIN
	INSERT INTO tblMFSubPatternType (
		intSubPatternTypeId
		,strSubPatternTypeName
		)
	SELECT 6
		,'SEQUENCE'
END
GO
IF NOT EXISTS (
		SELECT *
		FROM tblMFSubPatternType
		WHERE intSubPatternTypeId = 7
		)
BEGIN
	INSERT INTO tblMFSubPatternType (
		intSubPatternTypeId
		,strSubPatternTypeName
		)
	SELECT 7
		,'UDA'
END
GO
GO

IF NOT EXISTS (
		SELECT *
		FROM tblMFPatternCode
		WHERE intPatternCode = 33
		)
BEGIN
	INSERT INTO tblMFPatternCode (
		intPatternCode
		,strName
		)
	SELECT 33
		,'Batch Production'
END
GO

IF NOT EXISTS (
		SELECT *
		FROM tblMFPatternCode
		WHERE intPatternCode = 34
		)
BEGIN
	INSERT INTO tblMFPatternCode (
		intPatternCode
		,strName
		)
	SELECT 34
		,'Work Order'
END
GO

IF NOT EXISTS (
		SELECT *
		FROM tblMFPatternCode
		WHERE intPatternCode = 46
		)
BEGIN
	INSERT INTO tblMFPatternCode (
		intPatternCode
		,strName
		)
	SELECT 46
		,'Demand Number'
END
GO

IF NOT EXISTS (
		SELECT *
		FROM tblMFPatternCode
		WHERE intPatternCode = 55
		)
BEGIN
	INSERT INTO tblMFPatternCode (
		intPatternCode
		,strName
		)
	SELECT 55
		,'Stage Lot Number'
END
GO

IF NOT EXISTS (
		SELECT *
		FROM tblMFPatternCode
		WHERE intPatternCode = 59
		)
BEGIN
	INSERT INTO tblMFPatternCode (
		intPatternCode
		,strName
		)
	SELECT 59
		,'Bag Off Order'
END
GO

IF NOT EXISTS (
		SELECT *
		FROM tblMFPatternCode
		WHERE intPatternCode = 63
		)
BEGIN
	INSERT INTO tblMFPatternCode (
		intPatternCode
		,strName
		)
	SELECT 63
		,'Schedule Number'
END
GO

IF NOT EXISTS (
		SELECT *
		FROM tblMFPatternCode
		WHERE intPatternCode = 68
		)
BEGIN
	INSERT INTO tblMFPatternCode (
		intPatternCode
		,strName
		)
	SELECT 68
		,'Pick List Number'
END
GO

IF NOT EXISTS (
		SELECT *
		FROM tblMFPatternCode
		WHERE intPatternCode = 70
		)
BEGIN
	INSERT INTO tblMFPatternCode (
		intPatternCode
		,strName
		)
	SELECT 70
		,'Sanitization Order Number'
END
GO

IF NOT EXISTS (
		SELECT *
		FROM tblMFPatternCode
		WHERE intPatternCode = 78
		)
BEGIN
	INSERT INTO tblMFPatternCode (
		intPatternCode
		,strName
		)
	SELECT 78
		,'Parent Lot Number'
END
GO

IF NOT EXISTS (
		SELECT *
		FROM tblMFForecastItemType
		WHERE intForecastItemTypeId = 1
		)
BEGIN
	INSERT INTO tblMFForecastItemType (
		intForecastItemTypeId
		,strType
		,strBackColorName
		)
	SELECT 1
		,'F'
		,'bc-palegreen'
END
GO

IF NOT EXISTS (
		SELECT *
		FROM tblMFForecastItemType
		WHERE intForecastItemTypeId = 2
		)
BEGIN
	INSERT INTO tblMFForecastItemType (
		intForecastItemTypeId
		,strType
		,strBackColorName
		)
	SELECT 2
		,'O'
		,'bc-skyblue'
END
ELSE
BEGIN
	UPDATE tblMFForecastItemType
	SET strBackColorName = 'bc-skyblue'
	WHERE intForecastItemTypeId = 2
END
GO

IF NOT EXISTS (
		SELECT *
		FROM tblMFForecastItemType
		WHERE intForecastItemTypeId = 3
		)
BEGIN
	INSERT INTO tblMFForecastItemType (
		intForecastItemTypeId
		,strType
		,strBackColorName
		)
	SELECT 3
		,'S'
		,'bc-yellow'
END
ELSE
BEGIN
	UPDATE tblMFForecastItemType
	SET strBackColorName = 'bc-yellow'
	WHERE intForecastItemTypeId = 3
END
GO
UPDATE tblMFCompanyPreference
SET intForecastFirstEditableMonth = 0
WHERE intForecastFirstEditableMonth IS NULL
GO
IF NOT EXISTS(SELECT * FROM tblMFMarginBy WHERE intMarginById = 1)
BEGIN
    INSERT INTO tblMFMarginBy(intMarginById,strName)
    VALUES(1,'Percentage')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFMarginBy WHERE intMarginById = 2)
BEGIN
    INSERT INTO tblMFMarginBy(intMarginById,strName)
    VALUES(2,'Amount')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFCostSource WHERE intCostSourceId = 1)
BEGIN
    INSERT INTO tblMFCostSource(intCostSourceId,strName)
    VALUES(1,'Item')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFCostSource WHERE intCostSourceId = 2)
BEGIN
    INSERT INTO tblMFCostSource(intCostSourceId,strName)
    VALUES(2,'Sales Contract')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFCostSource WHERE intCostSourceId = 3)
BEGIN
    INSERT INTO tblMFCostSource(intCostSourceId,strName)
    VALUES(3,'Customer Storage')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFCostType WHERE intCostTypeId = 1)
BEGIN
    INSERT INTO tblMFCostType(intCostTypeId,strName)
    VALUES(1,'Standard')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFCostType WHERE intCostTypeId = 2)
BEGIN
    INSERT INTO tblMFCostType(intCostTypeId,strName)
    VALUES(2,'Average')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFCostType WHERE intCostTypeId = 3)
BEGIN
    INSERT INTO tblMFCostType(intCostTypeId,strName)
    VALUES(3,'Last')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFOneLinePrint WHERE intOneLinePrintId = 1)
BEGIN
    INSERT INTO tblMFOneLinePrint(intOneLinePrintId,strName)
    VALUES(1,'No')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFOneLinePrint WHERE intOneLinePrintId = 2)
BEGIN
    INSERT INTO tblMFOneLinePrint(intOneLinePrintId,strName)
    VALUES(2,'Yes')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFOneLinePrint WHERE intOneLinePrintId = 3)
BEGIN
    INSERT INTO tblMFOneLinePrint(intOneLinePrintId,strName)
    VALUES(3,'Yes - With Quantity')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFCommentType WHERE intCommentTypeId = 1)
BEGIN
    INSERT INTO tblMFCommentType(intCommentTypeId,strName)
    VALUES(1,'General')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFCommentType WHERE intCommentTypeId = 2)
BEGIN
    INSERT INTO tblMFCommentType(intCommentTypeId,strName)
    VALUES(2,'Pick List')
END
GO
IF NOT EXISTS(SELECT * FROM tblMFCommentType WHERE intCommentTypeId = 3)
BEGIN
    INSERT INTO tblMFCommentType(intCommentTypeId,strName)
    VALUES(3,'Invoice')
END
GO
UPDATE dbo.tblMFWorkOrder
SET intBatchID = NULL
WHERE intBlendRequirementId IS NULL
	AND intBatchID IS NOT NULL
Go
UPDATE tblMFCompanyPreference
SET ysnLotHistoryByStorageLocation = 1
WHERE ysnLotHistoryByStorageLocation IS NULL
GO
IF NOT EXISTS(SELECT 1 FROM tblMFOrderType WHERE strOrderType = 'WO PROD STAGING')
BEGIN
	INSERT INTO tblMFOrderType (intConcurrencyId,strInternalCode,strOrderType,ysnDefault,ysnLocked,intLastUpdateId,dtmLastUpdateOn)
	VALUES(1,'PS','WO PROD STAGING',0,1,1,GETDATE())
END
GO
IF NOT EXISTS(SELECT 1 FROM tblMFOrderType WHERE strOrderType = 'WO PROD RETURN')
BEGIN
	INSERT INTO tblMFOrderType (intConcurrencyId,strInternalCode,strOrderType,ysnDefault,ysnLocked,intLastUpdateId,dtmLastUpdateOn)
	VALUES(1,'PR','WO PROD RETURN',0,1,1,GETDATE())
END
GO	 
IF NOT EXISTS(SELECT 1 FROM tblMFOrderType WHERE strOrderType = 'SANITIZATION STAGING')
BEGIN 
	INSERT INTO tblMFOrderType (intConcurrencyId,strInternalCode,strOrderType,ysnDefault,ysnLocked,intLastUpdateId,dtmLastUpdateOn)
	VALUES(1,'SS','SANITIZATION STAGING',0,1,1,GETDATE())
END
GO	 
IF NOT EXISTS(SELECT 1 FROM tblMFOrderType WHERE strOrderType = 'SANITIZATION PRODUCTION')
BEGIN 
	INSERT INTO tblMFOrderType (intConcurrencyId,strInternalCode,strOrderType,ysnDefault,ysnLocked,intLastUpdateId,dtmLastUpdateOn)
	VALUES(1,'SP','SANITIZATION PRODUCTION',0,1,1,GETDATE())
END
GO
IF NOT EXISTS(SELECT 1 FROM tblMFOrderStatus WHERE strOrderStatus = 'OPEN')
BEGIN 
	INSERT INTO tblMFOrderStatus (intConcurrencyId,strInternalCode,strOrderStatus,ysnDefault,ysnLocked,intLastUpdateId,dtmLastUpdateOn)
	VALUES(1,'OPEN','OPEN',0,1,1,GETDATE())
END
GO
IF NOT EXISTS(SELECT 1 FROM tblMFOrderStatus WHERE strOrderStatus = 'RELEASED')
BEGIN 
	INSERT INTO tblMFOrderStatus (intConcurrencyId,strInternalCode,strOrderStatus,ysnDefault,ysnLocked,intLastUpdateId,dtmLastUpdateOn)
	VALUES(1,'RELEASED','RELEASED',0,1,1,GETDATE())
END
GO
IF NOT EXISTS(SELECT 1 FROM tblMFOrderStatus WHERE strOrderStatus = 'CANCELED')
BEGIN 
	INSERT INTO tblMFOrderStatus (intConcurrencyId,strInternalCode,strOrderStatus,ysnDefault,ysnLocked,intLastUpdateId,dtmLastUpdateOn)
	VALUES (1,'CANCELED','CANCELED',0,1,1,GETDATE())
END
GO
IF NOT EXISTS(SELECT 1 FROM tblMFOrderStatus WHERE strOrderStatus = 'INTRANSIT')
BEGIN 
	INSERT INTO tblMFOrderStatus (intConcurrencyId,strInternalCode,strOrderStatus,ysnDefault,ysnLocked,intLastUpdateId,dtmLastUpdateOn)
	VALUES (1,'INTRANSIT','INTRANSIT',0,1,1,GETDATE())
END
GO
IF NOT EXISTS(SELECT 1 FROM tblMFOrderStatus WHERE strOrderStatus = 'PICKING')
BEGIN 
	INSERT INTO tblMFOrderStatus (intConcurrencyId,strInternalCode,strOrderStatus,ysnDefault,ysnLocked,intLastUpdateId,dtmLastUpdateOn)
	VALUES (1,'PROCESSING','PICKING',0,1,1,GETDATE())
END
GO
IF NOT EXISTS(SELECT 1 FROM tblMFOrderStatus WHERE strOrderStatus = 'STAGED')
BEGIN 
	INSERT INTO tblMFOrderStatus (intConcurrencyId,strInternalCode,strOrderStatus,ysnDefault,ysnLocked,intLastUpdateId,dtmLastUpdateOn)
	VALUES (1,'PROCESSING','STAGED',0,1,1,GETDATE())
END
GO
IF NOT EXISTS(SELECT 1 FROM tblMFOrderStatus WHERE strOrderStatus = 'LOADED')
BEGIN 
	INSERT INTO tblMFOrderStatus (intConcurrencyId,strInternalCode,strOrderStatus,ysnDefault,ysnLocked,intLastUpdateId,dtmLastUpdateOn)
	VALUES (1,'PROCESSING','LOADED',0,1,1,GETDATE())
END
GO
IF NOT EXISTS(SELECT 1 FROM tblMFOrderStatus WHERE strOrderStatus = 'CHECK-IN')
BEGIN 
	INSERT INTO tblMFOrderStatus (intConcurrencyId,strInternalCode,strOrderStatus,ysnDefault,ysnLocked,intLastUpdateId,dtmLastUpdateOn)
	VALUES (1,'PROCESSING','CHECK-IN',0,1,1,GETDATE())
END
GO
IF NOT EXISTS(SELECT 1 FROM tblMFOrderStatus WHERE strOrderStatus = 'PUT-AWAY')
BEGIN 
	INSERT INTO tblMFOrderStatus (intConcurrencyId,strInternalCode,strOrderStatus,ysnDefault,ysnLocked,intLastUpdateId,dtmLastUpdateOn)
	VALUES (1,'PROCESSING','PUT-AWAY',0,1,1,GETDATE())
END
GO
IF NOT EXISTS(SELECT 1 FROM tblMFOrderStatus WHERE strOrderStatus = 'CLOSED')
BEGIN 
	INSERT INTO tblMFOrderStatus (intConcurrencyId,strInternalCode,strOrderStatus,ysnDefault,ysnLocked,intLastUpdateId,dtmLastUpdateOn)
	VALUES (1,'CLOSED','CLOSED',0,1,1,GETDATE())
END
GO
IF NOT EXISTS(SELECT 1 FROM tblMFOrderStatus WHERE strOrderStatus = 'LOADING')
BEGIN 
	INSERT INTO tblMFOrderStatus (intConcurrencyId,strInternalCode,strOrderStatus,ysnDefault,ysnLocked,intLastUpdateId,dtmLastUpdateOn)
	VALUES (1,'PROCESSING','LOADING',0,1,1,GETDATE())
END
GO
IF NOT EXISTS(SELECT 1 FROM tblMFOrderDirection WHERE strOrderDirection = 'INBOUND')
BEGIN 
	INSERT INTO tblMFOrderDirection (intConcurrencyId,strInternalCode,strOrderDirection,ysnIsDefault,ysnLocked,intCreatedUserId,dtmCreated)
	VALUES(1,'INBOUND','INBOUND',0,1,1,GETDATE())
END
GO
IF NOT EXISTS(SELECT 1 FROM tblMFOrderDirection WHERE strOrderDirection = 'OUTBOUND')
BEGIN 
	INSERT INTO tblMFOrderDirection (intConcurrencyId,strInternalCode,strOrderDirection,ysnIsDefault,ysnLocked,intCreatedUserId,dtmCreated)
	VALUES(1,'OUTBOUND','OUTBOUND',0,1,1,GETDATE())
END
GO
IF NOT EXISTS(SELECT 1 FROM tblMFPickPreference WHERE strPickPreference = 'EXACT')
BEGIN 
	INSERT INTO tblMFPickPreference(intConcurrencyId,strPickPreference,ysnIsDefault)
	VALUES(1,'EXACT',0)
END
GO
IF NOT EXISTS(SELECT 1 FROM tblMFPickPreference WHERE strPickPreference = 'PARTIAL')
BEGIN 
	INSERT INTO tblMFPickPreference(intConcurrencyId,strPickPreference,ysnIsDefault)
	VALUES(1,'PARTIAL',0)
END
GO
IF NOT EXISTS(SELECT 1 FROM tblMFPickPreference WHERE strPickPreference = 'BEST MATCH')
BEGIN 
	INSERT INTO tblMFPickPreference(intConcurrencyId,strPickPreference,ysnIsDefault)
	VALUES(1,'BEST MATCH',1)
END
GO
IF NOT EXISTS(SELECT 1 FROM tblMFTaskPriority WHERE strTaskPriority = 'LOW')
BEGIN 
	INSERT INTO tblMFTaskPriority(intConcurrencyId,strInternalCode,strTaskPriority,ysnIsDefault,ysnLocked,intCreatedUserId,dtmCreated)
	VALUES(1,'LOW','LOW',1,1,1,GETDATE())
END
GO
IF NOT EXISTS(SELECT 1 FROM tblMFTaskPriority WHERE strTaskPriority = 'NORMAL')
BEGIN 
	INSERT INTO tblMFTaskPriority(intConcurrencyId,strInternalCode,strTaskPriority,ysnIsDefault,ysnLocked,intCreatedUserId,dtmCreated)
	VALUES(1,'NORMAL','NORMAL',1,1,1,GETDATE())
END
GO
IF NOT EXISTS(SELECT 1 FROM tblMFTaskPriority WHERE strTaskPriority = 'HIGH')
BEGIN 
	INSERT INTO tblMFTaskPriority(intConcurrencyId,strInternalCode,strTaskPriority,ysnIsDefault,ysnLocked,intCreatedUserId,dtmCreated)
	VALUES(1,'HIGH','HIGH',1,1,1,GETDATE())
END
GO 
IF NOT EXISTS(SELECT 1 FROM tblMFTaskState WHERE strTaskState = 'UNASSIGNED')
BEGIN 
	INSERT INTO tblMFTaskState(intConcurrencyId,strInternalCode,strTaskState,intCreatedUserId,dtmCreated)
	VALUES(1,'UNASSIGNED','UNASSIGNED',1,GETDATE())
END
GO
IF NOT EXISTS(SELECT 1 FROM tblMFTaskState WHERE strTaskState = 'ASSIGNED')
BEGIN 
	INSERT INTO tblMFTaskState(intConcurrencyId,strInternalCode,strTaskState,intCreatedUserId,dtmCreated)
	VALUES(1,'ASSIGNED','ASSIGNED',1,GETDATE())
END
GO
IF NOT EXISTS(SELECT 1 FROM tblMFTaskState WHERE strTaskState = 'IN-PROGRESS')
BEGIN 
	INSERT INTO tblMFTaskState(intConcurrencyId,strInternalCode,strTaskState,intCreatedUserId,dtmCreated)
	VALUES(1,'IN-PROGRESS','IN-PROGRESS',1,GETDATE())
END
GO
IF NOT EXISTS(SELECT 1 FROM tblMFTaskState WHERE strTaskState = 'COMPLETED')
BEGIN 
	INSERT INTO tblMFTaskState(intConcurrencyId,strInternalCode,strTaskState,intCreatedUserId,dtmCreated)
	VALUES(1,'COMPLETED','COMPLETED',1,GETDATE())
END
GO
IF NOT EXISTS(SELECT 1 FROM tblMFTaskState WHERE strTaskState = 'CANCELLED')
BEGIN 
	INSERT INTO tblMFTaskState(intConcurrencyId,strInternalCode,strTaskState,intCreatedUserId,dtmCreated)
	VALUES(1,'CANCELLED','CANCELLED',1,GETDATE())
END
GO
IF NOT EXISTS(SELECT 1 FROM tblMFTaskType WHERE strTaskType = 'MOVE')
BEGIN 
	INSERT INTO tblMFTaskType(intConcurrencyId,strInternalCode,strTaskType,intCreatedUserId,dtmCreated)
	VALUES(1,'MOVE','MOVE',1,GETDATE())
END
GO
IF NOT EXISTS(SELECT 1 FROM tblMFTaskType WHERE strTaskType = 'PICK')
BEGIN 
	INSERT INTO tblMFTaskType(intConcurrencyId,strInternalCode,strTaskType,intCreatedUserId,dtmCreated)
	VALUES(1,'PICK','PICK',1,GETDATE())
END
GO
IF NOT EXISTS(SELECT 1 FROM tblMFTaskType WHERE strTaskType = 'LOAD')
BEGIN 
	INSERT INTO tblMFTaskType(intConcurrencyId,strInternalCode,strTaskType,intCreatedUserId,dtmCreated)
	VALUES(1,'LOAD','LOAD',1,GETDATE())
END
GO
IF NOT EXISTS(SELECT 1 FROM tblMFTaskType WHERE strTaskType = 'SHIP')
BEGIN 
	INSERT INTO tblMFTaskType(intConcurrencyId,strInternalCode,strTaskType,intCreatedUserId,dtmCreated)
	VALUES(1,'SHIP','SHIP',1,GETDATE())
END
GO
IF NOT EXISTS(SELECT 1 FROM tblMFTaskType WHERE strTaskType = 'PUT AWAY')
BEGIN 
	INSERT INTO tblMFTaskType(intConcurrencyId,strInternalCode,strTaskType,intCreatedUserId,dtmCreated)
	VALUES(1,'PUT_AWAY','PUT AWAY',1,GETDATE())
END
GO
IF NOT EXISTS(SELECT 1 FROM tblMFTaskType WHERE strTaskType = 'MERGE')
BEGIN 
	INSERT INTO tblMFTaskType(intConcurrencyId,strInternalCode,strTaskType,intCreatedUserId,dtmCreated)
	VALUES(1,'MERGE','MERGE',1,GETDATE())
END
GO
IF NOT EXISTS(SELECT 1 FROM tblMFTaskType WHERE strTaskType = 'SPLIT')
BEGIN 
	INSERT INTO tblMFTaskType(intConcurrencyId,strInternalCode,strTaskType,intCreatedUserId,dtmCreated)
	VALUES(1,'SPLIT','SPLIT',1,GETDATE())
END
GO
IF NOT EXISTS(SELECT 1 FROM tblMFTaskType WHERE strTaskType = 'COUNT')
BEGIN 
	INSERT INTO tblMFTaskType(intConcurrencyId,strInternalCode,strTaskType,intCreatedUserId,dtmCreated)
	VALUES(1,'COUNT','COUNT',1,GETDATE())
END
GO
IF NOT EXISTS(SELECT 1 FROM tblMFTaskType WHERE strTaskType = 'CHECK-IN')
BEGIN 
	INSERT INTO tblMFTaskType(intConcurrencyId,strInternalCode,strTaskType,intCreatedUserId,dtmCreated)
	VALUES(1,'CHECK-IN','CHECK-IN',1,GETDATE())
END
GO
IF NOT EXISTS(SELECT 1 FROM tblMFTaskType WHERE strTaskType = 'UPDATE')
BEGIN 
	INSERT INTO tblMFTaskType(intConcurrencyId,strInternalCode,strTaskType,intCreatedUserId,dtmCreated)
	VALUES(1,'UPDATE','UPDATE',1,GETDATE())
END
GO
IF NOT EXISTS(SELECT 1 FROM tblMFTaskType WHERE strTaskType = 'CREATE')
BEGIN 
	INSERT INTO tblMFTaskType(intConcurrencyId,strInternalCode,strTaskType,intCreatedUserId,dtmCreated)
	VALUES(1,'CREATE','CREATE',1,GETDATE())
END
GO
IF NOT EXISTS(SELECT 1 FROM tblMFTaskType WHERE strTaskType = 'DELETE')
BEGIN 
	INSERT INTO tblMFTaskType(intConcurrencyId,strInternalCode,strTaskType,intCreatedUserId,dtmCreated)
	VALUES(1,'DELETE','DELETE',1,GETDATE())
END
GO
IF NOT EXISTS(SELECT 1 FROM tblMFTaskType WHERE strTaskType = 'PUT BACK')
BEGIN 
	INSERT INTO tblMFTaskType(intConcurrencyId,strInternalCode,strTaskType,intCreatedUserId,dtmCreated)
	VALUES(1,'PUT_BACK','PUT BACK',1,GETDATE())
END
GO

GO
IF NOT EXISTS(SELECT 1 FROM tblMFScheduleRuleType WHERE intScheduleRuleTypeId = 1)
BEGIN
    INSERT INTO tblMFScheduleRuleType(intScheduleRuleTypeId,strName)
    VALUES(1,'Resource Constraint')
END
GO
IF NOT EXISTS(SELECT 1 FROM tblMFScheduleRuleType WHERE intScheduleRuleTypeId = 2)
BEGIN
    INSERT INTO tblMFScheduleRuleType(intScheduleRuleTypeId,strName)
    VALUES(2,'Finite Constraint')
END
GO
UPDATE ri 
SET ri.intSequenceNo = t.intSequenceNo
FROM tblMFRecipeItem ri 
Join
(
SELECT intRecipeItemId, ROW_NUMBER() OVER (PARTITION BY intRecipeId ORDER BY [intRecipeItemId]) AS intSequenceNo
FROM tblMFRecipeItem Where intSequenceNo is null AND intRecipeItemTypeId=1 Group By intRecipeId,intRecipeItemId
) t ON ri.intRecipeItemId=t.intRecipeItemId
GO

GO
UPDATE tblMFCompanyPreference
SET intWastageWorkOrderDuration = 2
WHERE intWastageWorkOrderDuration IS NULL
GO
UPDATE tblICStorageLocation
SET intRestrictionId = 1
WHERE intRestrictionId IS NULL
Go
UPDATE tblMFCompanyPreference
SET ysnPickByLotCode = 0
	,intLotCodeStartingPosition = 2
	,intLotCodeNoOfDigits = 5
WHERE ysnPickByLotCode IS NULL
Go
GO
UPDATE tblMFCompanyPreference
SET ysnDisplayRecipeTitleByItem = 0
WHERE ysnDisplayRecipeTitleByItem IS NULL
GO

-- Need to remove this block once Inventory team added the transaction type. This is temporary
GO
IF NOT EXISTS(SELECT 1 FROM tblICInventoryTransactionType WHERE intTransactionTypeId = 41)
BEGIN 
	INSERT INTO tblICInventoryTransactionType(intTransactionTypeId,strName,strTransactionForm)
	VALUES(41,'Inventory Adjustment - Ownership Change','Inventory Adjustment')
END
GO
UPDATE tblMFWorkOrderRecipeItem
SET ysnPartialFillConsumption = 1
WHERE ysnPartialFillConsumption IS NULL
GO
UPDATE tblMFRecipeItem
SET ysnPartialFillConsumption = 1
WHERE ysnPartialFillConsumption IS NULL
GO
Go
IF NOT EXISTS(SELECT 1 FROM tblMFOrderType WHERE strOrderType = 'INVENTORY SHIPMENT STAGING')
BEGIN 
	INSERT INTO tblMFOrderType (intConcurrencyId,strInternalCode,strOrderType,ysnDefault,ysnLocked,intLastUpdateId,dtmLastUpdateOn)
	VALUES(5,'INVS','INVENTORY SHIPMENT STAGING',0,1,1,GETDATE())
END
GO
UPDATE tblMFCompanyPreference
SET ysnPickByItemOwner = 0
WHERE ysnPickByItemOwner IS NULL
GO
GO
UPDATE tblMFCompanyPreference
SET ysnDisplayLotIdAsPalletId = 0
WHERE ysnDisplayLotIdAsPalletId IS NULL
GO
GO
UPDATE tblMFCompanyPreference
SET strLotTextInReport = 'Lot No'
WHERE strLotTextInReport IS NULL
GO

INSERT INTO tblMFLotInventory (intLotId)
SELECT L.intLotId
FROM tblICLot L
WHERE NOT EXISTS (
		SELECT *
		FROM tblMFLotInventory LI
		WHERE LI.intLotId = L.intLotId
		)
GO
UPDATE tblMFPatternDetail
SET ysnPaddingZero = 1
WHERE ysnPaddingZero IS NULL
GO
UPDATE tblMFCompanyPreference
SET ysnSetExpiryDateByParentLot = 1
WHERE ysnSetExpiryDateByParentLot IS NULL
GO
UPDATE tblMFCompanyPreference
SET ysnAddQtyOnExistingLot = 1
WHERE ysnAddQtyOnExistingLot IS NULL
GO
UPDATE tblMFCompanyPreference
SET ysnNotifyInventoryShortOnCreateWorkOrder = 0,ysnNotifyInventoryShortOnReleaseWorkOrder=0
WHERE ysnNotifyInventoryShortOnCreateWorkOrder IS NULL
GO
UPDATE tblMFCompanyPreference
SET ysnSetDefaultQtyOnHandheld = 1
WHERE ysnSetDefaultQtyOnHandheld IS NULL
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFCustomerLabelType
		WHERE intCustomerLabelTypeId = 1
		)
BEGIN
	INSERT INTO tblMFCustomerLabelType (
		intCustomerLabelTypeId
		,strLabelType
		)
	SELECT 1
		,'Pallet Label'
END
GO

IF NOT EXISTS (
		SELECT 1
		FROM tblMFCustomerLabelType
		WHERE intCustomerLabelTypeId = 2
		)
BEGIN
	INSERT INTO tblMFCustomerLabelType (
		intCustomerLabelTypeId
		,strLabelType
		)
	SELECT 2
		,'Case Label'
END
