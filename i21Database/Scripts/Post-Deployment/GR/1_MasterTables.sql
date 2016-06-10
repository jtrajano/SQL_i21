--tblGRDiscountCalculationOption
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

GO
IF NOT EXISTS(SELECT * FROM tblGRShrinkCalculationOption WHERE strDisplayField = 'Price Shrink')
BEGIN
	INSERT INTO tblGRShrinkCalculationOption
	SELECT 3,'Price Shrink',1	
END
GO
IF EXISTS(SELECT 1 FROM tblGRShrinkCalculationOption WHERE strDisplayField = 'Price Shrink')
BEGIN
	UPDATE tblGRShrinkCalculationOption SET strDisplayField = 'Gross Weight' WHERE strDisplayField = 'Price Shrink'	
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
DECLARE @intDTotalRows INT
DECLARE @intDRowsWithSortOne INT
SELECT @intDTotalRows=COUNT(1) FROM tblGRDiscountScheduleCode 
SELECT @intDRowsWithSortOne=COUNT(1) FROM tblGRDiscountScheduleCode WHERE ISNULL(intSort,1)=1

IF  @intDTotalRows=@intDRowsWithSortOne
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
	) AS b ON a.intDiscountScheduleId = b.intDiscountScheduleId AND a.intDiscountScheduleCodeId = b.intDiscountScheduleCodeId
END
GO
GO
DECLARE @intQTotalRows INT
DECLARE @intQRowsWithSortOne INT
SELECT @intQTotalRows=COUNT(1) FROM tblQMTicketDiscount 
SELECT @intQRowsWithSortOne=COUNT(1) FROM tblQMTicketDiscount WHERE ISNULL(intSort,1)=1

IF  @intQTotalRows=@intQRowsWithSortOne
BEGIN	
	UPDATE a
	SET a.intSort=b.[Rank]
	FROM tblQMTicketDiscount a
	JOIN 
	(
		  SELECT
		  intTicketDiscountId,
		  intTicketFileId,
		  strSourceType,	   
		  DENSE_RANK() OVER ( PARTITION BY intTicketFileId, strSourceType ORDER BY intTicketDiscountId) AS [Rank]
		  FROM tblQMTicketDiscount
	) as b 
	  ON a.intTicketDiscountId = b.intTicketDiscountId 
	  AND a.intTicketFileId = b.intTicketFileId 
	  AND a.strSourceType = b.strSourceType
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
