﻿--tblGRDiscountCalculationOption
GO
IF NOT EXISTS(SELECT * FROM tblGRDiscountCalculationOption WHERE strDisplayField = 'Net Weight')
BEGIN
	INSERT INTO tblGRDiscountCalculationOption
	SELECT 1,'Net Weight',1	
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblGRDiscountCalculationOption WHERE strDisplayField = 'Wet Weight')
BEGIN
	INSERT INTO tblGRDiscountCalculationOption
	SELECT 2,'Wet Weight',1	
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblGRDiscountCalculationOption WHERE strDisplayField = 'Gross Weight')
BEGIN
	INSERT INTO tblGRDiscountCalculationOption
	SELECT 3,'Gross Weight',1	
END
GO

--tblGRShrinkCalculationOption
GO
IF NOT EXISTS(SELECT * FROM tblGRShrinkCalculationOption WHERE strDisplayField = 'Net Weight')
BEGIN
	INSERT INTO tblGRShrinkCalculationOption
	SELECT 1,'Net Weight',1	
END
GO

GO
IF NOT EXISTS(SELECT * FROM tblGRShrinkCalculationOption WHERE strDisplayField = 'Wet Weight')
BEGIN
	INSERT INTO tblGRShrinkCalculationOption
	SELECT 2,'Wet Weight',1	
END
GO
IF EXISTS(SELECT 1 FROM tblGRShrinkCalculationOption WHERE strDisplayField = 'Price Shrink')
BEGIN
	UPDATE tblGRShrinkCalculationOption SET strDisplayField = 'Gross Weight' WHERE strDisplayField = 'Price Shrink'	
END
GO
IF NOT EXISTS(SELECT * FROM tblGRShrinkCalculationOption WHERE strDisplayField = 'Gross Weight')
BEGIN
	INSERT INTO tblGRShrinkCalculationOption
	SELECT 3,'Gross Weight',1	
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
