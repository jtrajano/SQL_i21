﻿--tblGRDiscountCalculationOption
GO
IF NOT EXISTS(SELECT * FROM tblGRDiscountCalculationOption WHERE strDiscountCalculationOption = 'Net Weight')
BEGIN
	INSERT INTO tblGRDiscountCalculationOption
	SELECT 1,'Net Weight','1. X = (loaded vehicle scale weight - tare) * shrink factor tagged as gross<br />2. Y = x * shrink factors tagged as wet<br />3. y * factors tagged as net',1    ,3

END
ELSE
BEGIN
	UPDATE tblGRDiscountCalculationOption
	SET strDescription = '1. X = (loaded vehicle scale weight - tare) * shrink factor tagged as gross<br />2. Y = x * shrink factors tagged as wet<br />3. y * factors tagged as net'
		, intOrderById = 3
	WHERE strDiscountCalculationOption = 'Net Weight' 
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblGRDiscountCalculationOption WHERE strDiscountCalculationOption = 'Wet Weight')
BEGIN
	INSERT INTO tblGRDiscountCalculationOption
	SELECT 2,'Wet Weight','1. X = (loaded vehicle scale weight - tare) * shrink factor tagged as gross<br />2. x * shrink factors tagged as wet',1    ,2
END
ELSE
BEGIN
	UPDATE tblGRDiscountCalculationOption
	SET strDescription = '1. X = (loaded vehicle scale weight - tare) * shrink factor tagged as gross<br />2. x * shrink factors tagged as wet'
		, intOrderById = 2
	WHERE strDiscountCalculationOption = 'Wet Weight' 
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblGRDiscountCalculationOption WHERE strDiscountCalculationOption = 'Gross Weight')
BEGIN
	INSERT INTO tblGRDiscountCalculationOption
	SELECT 3,'Gross Weight','(loaded vehicle scale weight - tare) * shrink factor',1    ,1
END
ELSE
BEGIN
	UPDATE tblGRDiscountCalculationOption
	SET strDescription = '(loaded vehicle scale weight - tare) * shrink factor'
		, intOrderById = 1
	WHERE strDiscountCalculationOption = 'Gross Weight' 
END
GO

--tblGRShrinkCalculationOption
GO
IF NOT EXISTS(SELECT * FROM tblGRShrinkCalculationOption WHERE strShrinkCalculationOption = 'Net Weight')
BEGIN
	INSERT INTO tblGRShrinkCalculationOption
	SELECT 1,'Net Weight','1. X = (loaded vehicle scale weight - tare) * shrink factor tagged as gross<br />2. Y = x * shrink factors tagged as wet<br />3. y * factors tagged as net',1    ,3
END
ELSE
BEGIN
	UPDATE tblGRShrinkCalculationOption
	SET strDescription = '1. X = (loaded vehicle scale weight - tare) * shrink factor tagged as gross<br />2. Y = x * shrink factors tagged as wet<br />3. y * factors tagged as net'
		, intOrderById = 3
	WHERE strShrinkCalculationOption = 'Net Weight' 
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblGRShrinkCalculationOption WHERE strShrinkCalculationOption = 'Wet Weight')
BEGIN
	INSERT INTO tblGRShrinkCalculationOption
	SELECT 2,'Wet Weight','1. X = (loaded vehicle scale weight - tare) * shrink factor tagged as gross<br />2. x * shrink factors tagged as wet',1    ,2
END
ELSE
BEGIN
	UPDATE tblGRShrinkCalculationOption
	SET strDescription = '1. X = (loaded vehicle scale weight - tare) * shrink factor tagged as gross<br />2. x * shrink factors tagged as wet'
		, intOrderById = 2
	WHERE strShrinkCalculationOption = 'Wet Weight' 
END
GO

IF EXISTS(SELECT 1 FROM tblGRShrinkCalculationOption WHERE strShrinkCalculationOption = 'Price Shrink')
BEGIN
	UPDATE tblGRShrinkCalculationOption SET strShrinkCalculationOption = 'Gross Weight' WHERE strShrinkCalculationOption = 'Price Shrink'	
END
GO
IF NOT EXISTS(SELECT * FROM tblGRShrinkCalculationOption WHERE strShrinkCalculationOption = 'Gross Weight')
BEGIN
	INSERT INTO tblGRShrinkCalculationOption
	SELECT 3,'Gross Weight','(loaded vehicle scale weight - tare) * shrink factor',1    ,1
END
ELSE
BEGIN
	UPDATE tblGRShrinkCalculationOption
	SET strDescription = '(loaded vehicle scale weight - tare) * shrink factor'
		, intOrderById = 1
	WHERE strShrinkCalculationOption = 'Gross Weight' 
END
GO
IF EXISTS(SELECT intUnitMeasureId FROM tblSCScaleSetup)
BEGIN
	declare @intUnitMeasureId int
	declare @strSymbol varchar(20)
	SELECT @intUnitMeasureId = intUnitMeasureId, @strSymbol = strSymbol FROM tblICUnitMeasure WHERE (strSymbol LIKE '%LB%' OR strUnitMeasure LIKE '%Pound%') AND strUnitType = 'Weight'
	IF @intUnitMeasureId IS NOT NULL
		UPDATE tblSCScaleSetup SET intUnitMeasureId = @intUnitMeasureId,strWeightDescription = @strSymbol  WHERE intUnitMeasureId IS NULL
END
GO
IF  EXISTS(SELECT 1 FROM tblGRDiscountScheduleCode WHERE intSort IS NULL)
BEGIN	
	UPDATE a
	SET a.intSort=b.[Rank]
	FROM tblGRDiscountScheduleCode a
	JOIN
	(	  SELECT
		  intDiscountScheduleCodeId,
		  intDiscountScheduleId,
		  DENSE_RANK() OVER ( PARTITION BY intDiscountScheduleId ORDER BY intDiscountScheduleCodeId) AS [Rank]
		  FROM tblGRDiscountScheduleCode
	) AS b ON a.intDiscountScheduleId = b.intDiscountScheduleId 
	      AND a.intDiscountScheduleCodeId = b.intDiscountScheduleCodeId
		  AND a.intSort IS NULL
END
GO
IF   EXISTS(SELECT 1 FROM tblQMTicketDiscount WHERE intSort IS NULL)
BEGIN	
	UPDATE a
	SET a.intSort=b.intSort
	FROM tblQMTicketDiscount a
	JOIN tblGRDiscountScheduleCode b ON b.intDiscountScheduleCodeId=a.intDiscountScheduleCodeId
END
GO
IF EXISTS(SELECT * FROM tblGRDiscountScheduleCode WHERE ISNULL(strDiscountChargeType,'')='')
BEGIN
	UPDATE tblGRDiscountScheduleCode SET strDiscountChargeType='Dollar' WHERE ISNULL(strDiscountChargeType,'')=''
END
GO
IF EXISTS(SELECT * FROM tblQMTicketDiscount WHERE ISNULL(strDiscountChargeType,'')='')
BEGIN
	UPDATE tblQMTicketDiscount SET strDiscountChargeType='Dollar' WHERE ISNULL(strDiscountChargeType,'')=''
END

IF EXISTS(SELECT intItemUOMIdFrom FROM tblSCTicket)
BEGIN
	UPDATE tblSCTicket SET intItemUOMIdFrom = ItemUOM.intItemUOMId
	FROM tblSCTicket SCT
	INNER JOIN tblICItemUOM ItemUOM ON SCT.intItemId = ItemUOM.intItemId
	INNER JOIN tblSCScaleSetup SCS  ON SCT.intScaleSetupId = SCS.intScaleSetupId AND SCS.intUnitMeasureId = ItemUOM.intUnitMeasureId
END

IF EXISTS(SELECT intItemUOMIdTo FROM tblSCTicket)
BEGIN
	UPDATE tblSCTicket SET intItemUOMIdTo = ItemUOM.intItemUOMId
	FROM tblSCTicket SCT
	INNER JOIN tblICItemUOM ItemUOM ON SCT.intItemId = ItemUOM.intItemId
	WHERE ItemUOM.ysnStockUnit = 1
END
GO
IF EXISTS(SELECT 1 FROM tblGRStorageScheduleRule WHERE strAllowancePeriod IS NULL)
BEGIN
	UPDATE tblGRStorageScheduleRule SET strAllowancePeriod='Day(s)',dtmAllowancePeriodFrom=NULL,dtmAllowancePeriodTo=NULL WHERE strAllowancePeriod IS NULL
END
GO
IF EXISTS(SELECT 1 FROM tblGRCustomerStorage WHERE intUnitMeasureId IS NULL)
BEGIN
	UPDATE a 
	SET a.intUnitMeasureId=b.intUnitMeasureId
	FROM tblGRCustomerStorage a
	JOIN tblICCommodityUnitMeasure b ON b.intCommodityId=a.intCommodityId AND b.ysnStockUnit=1   
END
GO
IF EXISTS(SELECT intStorageScheduleTypeId FROM tblSCDistributionOption)
BEGIN
	update tblSCDistributionOption set intStorageScheduleTypeId = (SELECT intStorageScheduleTypeId  from tblGRStorageType WHERE strStorageTypeCode = strDistributionOption)
END
GO
IF EXISTS(SELECT 1 FROM tblGRStorageSchedulePeriod WHERE strFeeType IN('Price','Weight'))
BEGIN
	UPDATE tblGRStorageSchedulePeriod SET strFeeType='Per Unit' WHERE strFeeType IN('Price','Weight')
END
GO
IF NOT EXISTS(SELECT 1 FROM tblGRStorageType WHERE strStorageTypeCode = 'SO')
BEGIN
	SET IDENTITY_INSERT [dbo].[tblGRStorageType] ON

	INSERT INTO tblGRStorageType
	(
	 intStorageScheduleTypeId
	,strStorageTypeDescription
	,strStorageTypeCode
	,ysnReceiptedStorage
	,intConcurrencyId
	,strOwnedPhysicalStock
	,ysnDPOwnedType
	,ysnGrainBankType
	,ysnActive
	,ysnCustomerStorage
	)
	SELECT 
	-7 AS intStorageScheduleTypeId
	,'Sales Order' AS strStorageTypeDescription
	,'SO'strStorageTypeCode
	, 0 AS ysnReceiptedStorage
	,1 AS intConcurrencyId
	,'Customer' AS strOwnedPhysicalStock
	,0 AS ysnDPOwnedType
	,0 AS ysnGrainBankType
	,1 AS ysnActive
	,0 AS ysnCustomerStorage

    SET IDENTITY_INSERT [dbo].[tblGRStorageType] OFF
END
GO
IF NOT EXISTS(SELECT 1 FROM tblGRStorageType WHERE strStorageTypeCode IN ('DEF','CNT','SPT','SPL','HLD','LOD'))
BEGIN
	SET IDENTITY_INSERT [dbo].[tblGRStorageType] ON

	INSERT INTO tblGRStorageType
	(
	 intStorageScheduleTypeId
	,strStorageTypeDescription
	,strStorageTypeCode
	,ysnReceiptedStorage
	,intConcurrencyId
	,strOwnedPhysicalStock
	,ysnDPOwnedType
	,ysnGrainBankType
	,ysnActive
	,ysnCustomerStorage
	)
	SELECT 
	-1 AS intStorageScheduleTypeId
	,'Default' AS strStorageTypeDescription
	,'DEF'strStorageTypeCode
	, 0 AS ysnReceiptedStorage
	,1 AS intConcurrencyId
	,'Customer' AS strOwnedPhysicalStock
	,0 AS ysnDPOwnedType
	,0 AS ysnGrainBankType
	,1 AS ysnActive
	,0 AS ysnCustomerStorage

	UNION

	SELECT 
	-2 AS intStorageScheduleTypeId
	,'Contract' AS strStorageTypeDescription
	,'CNT'strStorageTypeCode
	, 0 AS ysnReceiptedStorage
	,1 AS intConcurrencyId
	,'Customer' AS strOwnedPhysicalStock
	,0 AS ysnDPOwnedType
	,0 AS ysnGrainBankType
	,1 AS ysnActive
	,0 AS ysnCustomerStorage

	UNION

	SELECT 
	-3 AS intStorageScheduleTypeId
	,'Spot Sale' AS strStorageTypeDescription
	,'SPT'strStorageTypeCode
	,0 AS ysnReceiptedStorage
	,1 AS intConcurrencyId
	,'Customer' AS strOwnedPhysicalStock
	,0 AS ysnDPOwnedType
	,0 AS ysnGrainBankType
	,1 AS ysnActive
	,0 AS ysnCustomerStorage

	UNION

	SELECT 
	-4 AS intStorageScheduleTypeId
	,'Split' AS strStorageTypeDescription
	,'SPL'strStorageTypeCode
	, 0 AS ysnReceiptedStorage
	,1 AS intConcurrencyId
	,'Customer' AS strOwnedPhysicalStock
	,0 AS ysnDPOwnedType
	,0 AS ysnGrainBankType
	,1 AS ysnActive
	,0 AS ysnCustomerStorage

	UNION

	SELECT 
	-5 AS intStorageScheduleTypeId
	,'Hold' AS strStorageTypeDescription
	,'HLD'strStorageTypeCode
	, 0 AS ysnReceiptedStorage
	,1 AS intConcurrencyId
	,'Customer' AS strOwnedPhysicalStock
	,0 AS ysnDPOwnedType
	,0 AS ysnGrainBankType
	,1 AS ysnActive
	,0 AS ysnCustomerStorage

	UNION

	SELECT 
	-6 AS intStorageScheduleTypeId
	,'Load' AS strStorageTypeDescription
	,'LOD'strStorageTypeCode
	, 0 AS ysnReceiptedStorage
	,1 AS intConcurrencyId
	,'Customer' AS strOwnedPhysicalStock
	,0 AS ysnDPOwnedType
	,0 AS ysnGrainBankType
	,1 AS ysnActive
	,0 AS ysnCustomerStorage
	
    SET IDENTITY_INSERT [dbo].[tblGRStorageType] OFF
END
GO
IF EXISTS(SELECT 1 FROM tblGRStorageType WHERE strStorageTypeCode IN ('DEF','CNT','SPT','SPL','HLD','LOD','SO'))
BEGIN
	UPDATE tblSCTicket set intStorageScheduleTypeId = (SELECT GR.intStorageScheduleTypeId FROM tblGRStorageType GR WHERE GR.strStorageTypeCode = strDistributionOption) WHERE intStorageScheduleTypeId < 0
END
GO
IF EXISTS(SELECT 1 FROM tblGRDiscountScheduleCode WHERE intStorageTypeId IS NULL)
BEGIN
	UPDATE tblGRDiscountScheduleCode SET intStorageTypeId= -1 WHERE intStorageTypeId IS NULL
END
GO
IF EXISTS(SELECT 1 FROM tblSCTicketType WHERE intNextTicketNumber = 0)
BEGIN
	UPDATE tblSCTicketType set intNextTicketNumber = 1 WHERE intNextTicketNumber = 0
END
GO
IF EXISTS(SELECT 1 FROM tblGRCustomerStorage WHERE intItemUOMId IS NULL)
BEGIN
	UPDATE  CS 
	SET		CS.intItemUOMId = UOM.intItemUOMId 
	FROM    tblGRCustomerStorage CS
	JOIN	tblICItemUOM UOM ON UOM.intItemId = CS.intItemId AND UOM.intUnitMeasureId = CS.intUnitMeasureId
	WHERE   CS.intItemUOMId IS NULL
END
GO
IF EXISTS(SELECT 1 FROM tblGRStorageHistory WHERE intTransactionTypeId = 4 AND strVoucher IS NULL AND intBillId > 0)
BEGIN
	UPDATE SH
	SET SH.strVoucher = Bill.strBillId
	FROM tblGRStorageHistory SH
	JOIN tblAPBill Bill ON Bill.intBillId = SH.intBillId
	WHERE SH.intTransactionTypeId = 4 AND SH.strVoucher IS NULL
END
GO
IF EXISTS(SELECT t1.intLastScaleSetupId FROM tblSCLastScaleSetup t1 LEFT JOIN tblSMUserSecurity t2 ON t1.intEntityId = 	t2.intEntityId WHERE t2.intEntityId IS NULL)
BEGIN
	PRINT 'Begin checking intEntityId'
	DELETE FROM tblSCLastScaleSetup WHERe intLastScaleSetupId IN
	(
		SELECT t1.intLastScaleSetupId
		FROM tblSCLastScaleSetup t1
			LEFT JOIN tblSMUserSecurity t2 ON t1.intEntityId = 	t2.intEntityId
		WHERE t2.intEntityId IS NULL
	)
	PRINT 'End checking intEntityId'

	UPDATE SCS SET SCS.intEntityScaleOperatorId = ISNULL(SM.intEntityScaleOperatorId , SCS.intEntityId)
	FROM tblSCLastScaleSetup SCS
	LEFT JOIN tblSMUserSecurity SM ON SM.intEntityId = SCS.intEntityId
	WHERE SCS.intEntityScaleOperatorId IS NULL
END
GO

