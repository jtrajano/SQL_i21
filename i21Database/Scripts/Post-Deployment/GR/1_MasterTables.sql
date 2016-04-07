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

GO
IF NOT EXISTS(SELECT * FROM tblGRShrinkCalculationOption WHERE strDisplayField = 'Price Shrink')
BEGIN
	INSERT INTO tblGRShrinkCalculationOption
	SELECT 3,'Price Shrink',1	
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
SELECT @intDRowsWithSortOne=COUNT(1) FROM tblGRDiscountScheduleCode WHERE intSort=1

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
SELECT @intQRowsWithSortOne=COUNT(1) FROM tblQMTicketDiscount WHERE intSort=1

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
IF EXISTS(SELECT * FROM tblGRDiscountScheduleCode WHERE strDiscountChargeType IS NULL)
BEGIN
	UPDATE tblGRDiscountScheduleCode SET strDiscountChargeType='Dollar' WHERE strDiscountChargeType IS NULL
END