CREATE PROCEDURE [dbo].[uspSCDeliverySheetGrade]
	@intDeliverySheetId AS INT,
	@ysnPivot AS BIT = NULL
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON
SET NOCOUNT ON
IF 1=0 
BEGIN
	SET FMTONLY OFF
END

IF OBJECT_ID (N'tempdb.dbo.#DeliverySheetGrade') IS NOT NULL
   DROP TABLE #DeliverySheetGrade

DECLARE @strItemNo AS NVARCHAR(MAX)
		,@intDiscountScheduleCodeId AS INT
		,@total AS DECIMAL(38,20)
		,@counter AS INT;
CREATE TABLE #DeliverySheetGrade (Item VARCHAR(50),intDiscountScheduleCodeId INT, Amount NUMERIC(38,6),intDecimalPrecision INT,intDeliverySheetId INT,DiscountAmount NUMERIC(38,6), ShrinkPercent NUMERIC(38,6))

INSERT INTO #DeliverySheetGrade (Item, intDiscountScheduleCodeId)
SELECT DISTINCT IC.strItemNo,GR.intDiscountScheduleCodeId FROM tblSCDeliverySheet SCD
LEFT JOIN tblGRDiscountCrossReference GRCR ON GRCR.intDiscountId = SCD.intDiscountId
LEFT JOIN tblICItem ICItem ON ICItem.intItemId = SCD.intItemId
LEFT JOIN tblGRDiscountSchedule GRDS ON GRDS.intDiscountScheduleId = GRCR.intDiscountScheduleId AND GRDS.intCurrencyId = SCD.intCurrencyId AND GRDS.intCommodityId = ICItem.intCommodityId
LEFT JOIN tblGRDiscountScheduleCode GR ON GR.intDiscountScheduleId = GRDS.intDiscountScheduleId
INNER JOIN tblICItem IC ON IC.intItemId = GR.intItemId
WHERE SCD.intDeliverySheetId = @intDeliverySheetId AND GR.intStorageTypeId = -1

SELECT @total = SUM(SCT.dblNetUnits) FROM tblSCDeliverySheet SCD
LEFT JOIN tblSCTicket SCT ON SCD.intDeliverySheetId = SCT.intDeliverySheetId
WHERE SCT.intDeliverySheetId = @intDeliverySheetId

UPDATE #DeliverySheetGrade SET intDeliverySheetId = @intDeliverySheetId

--FOR grade
DECLARE intListCursor CURSOR LOCAL FAST_FORWARD
FOR
SELECT Item, intDiscountScheduleCodeId FROM #DeliverySheetGrade

OPEN intListCursor;

-- Initial fetch attempt
FETCH NEXT FROM intListCursor INTO @strItemNo, @intDiscountScheduleCodeId;

WHILE @@FETCH_STATUS = 0
BEGIN
	
	UPDATE #DeliverySheetGrade 
	SET Amount = A.dblAmount
		,DiscountAmount = A.dblDiscountAmount	
        ,ShrinkPercent = A.dblShrinkPercent
	FROM ( 
		SELECT dblAmount = ISNULL(SUM(((SCT.dblNetUnits / @total) * QM.dblGradeReading)),0) 
			,dblDiscountAmount = MAX(QM.dblDiscountAmount)
            ,dblShrinkPercent = MAX(QM.dblShrinkPercent)
		FROM 
		tblSCDeliverySheet SCD
		INNER JOIN tblSCTicket SCT ON SCT.intDeliverySheetId = SCD.intDeliverySheetId
		LEFT JOIN tblQMTicketDiscount QM ON QM.intTicketFileId = SCD.intDeliverySheetId AND QM.strSourceType = 'Delivery Sheet'
		WHERE SCD.intDeliverySheetId = @intDeliverySheetId 
		AND QM.intDiscountScheduleCodeId = @intDiscountScheduleCodeId) A
	WHERE Item = @strItemNo
	
	UPDATE #DeliverySheetGrade SET intDecimalPrecision = (SELECT TOP 1 intCurrencyDecimal FROM tblSMCompanyPreference)

	FETCH NEXT FROM intListCursor INTO @strItemNo, @intDiscountScheduleCodeId;
END;

CLOSE intListCursor;
DEALLOCATE intListCursor;

IF ISNULL(@ysnPivot,0) = 1
BEGIN
	UPDATE #DeliverySheetGrade SET Item = REPLACE(Item,' ','')

	DECLARE @DynamicPivotQuery AS NVARCHAR(MAX)
	DECLARE @ColumnName AS NVARCHAR(MAX)
 
	SELECT @ColumnName= ISNULL(@ColumnName + ',','') + QUOTENAME(Item)
	FROM (SELECT DISTINCT Item FROM #DeliverySheetGrade) AS Courses
 
	SET @DynamicPivotQuery = 
	  N'SELECT *
		FROM #DeliverySheetGrade
		PIVOT(SUM(Amount) 
			  FOR Item IN (' + @ColumnName + ')) AS PVTTable'
	EXEC sp_executesql @DynamicPivotQuery
END
ELSE
BEGIN
	SELECT * FROM #DeliverySheetGrade
END