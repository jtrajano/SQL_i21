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
