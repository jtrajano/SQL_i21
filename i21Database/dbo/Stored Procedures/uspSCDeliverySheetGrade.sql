CREATE PROCEDURE [dbo].[uspSCDeliverySheetGrade]
	@intDeliverySheetId AS INT,
	@ysnPivot AS BIT = NULL
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF
SET NOCOUNT ON
IF 1=0 
BEGIN
	SET FMTONLY OFF
END

IF OBJECT_ID (N'tempdb.dbo.#DeliverySheetGrade') IS NOT NULL
   DROP TABLE #DeliverySheetGrade

DECLARE @strItemNo AS NVARCHAR(MAX)
		,@counter AS INT;
CREATE TABLE #DeliverySheetGrade (Item VARCHAR(50),Amount NUMERIC(38,6),intDecimalPrecision INT,intDeliverySheetId INT)

INSERT INTO #DeliverySheetGrade (Item)
SELECT DISTINCT strItemNo FROM tblSCDeliverySheet SCD
LEFT JOIN tblSCTicket SCT ON SCD.intDeliverySheetId = SCT.intDeliverySheetId
LEFT JOIN tblQMTicketDiscount QM ON QM.intTicketId = SCT.intTicketId
LEFT JOIN tblGRDiscountScheduleCode GR ON GR.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
LEFT JOIN tblICItem IC ON IC.intItemId = GR.intItemId
WHERE SCT.intDeliverySheetId = @intDeliverySheetId

UPDATE #DeliverySheetGrade SET intDeliverySheetId = @intDeliverySheetId

--FOR grade
DECLARE intListCursor CURSOR LOCAL FAST_FORWARD
FOR
SELECT Item FROM #DeliverySheetGrade

OPEN intListCursor;

-- Initial fetch attempt
FETCH NEXT FROM intListCursor INTO @strItemNo;

WHILE @@FETCH_STATUS = 0
BEGIN
	DECLARE @total AS DECIMAL(38,20);
	SELECT @total = SUM(SCT.dblNetUnits) FROM tblSCDeliverySheet SCD
	LEFT JOIN tblSCTicket SCT ON SCD.intDeliverySheetId = SCT.intDeliverySheetId
	WHERE SCT.intDeliverySheetId = @intDeliverySheetId

	UPDATE #DeliverySheetGrade SET Amount = 
	ISNULL((SELECT SUM(((SCT.dblNetUnits / @total) * QM.dblGradeReading))  FROM tblSCDeliverySheet SCD
	LEFT JOIN tblSCTicket SCT ON SCD.intDeliverySheetId = SCT.intDeliverySheetId
	LEFT JOIN tblQMTicketDiscount QM ON QM.intTicketId = SCT.intTicketId
	LEFT JOIN tblGRDiscountScheduleCode GR ON GR.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
	LEFT JOIN tblICItem IC ON IC.intItemId = GR.intItemId
	WHERE SCT.intDeliverySheetId = @intDeliverySheetId AND IC.strItemNo = @strItemNo), 0) WHERE Item = @strItemNo;
	
	UPDATE #DeliverySheetGrade SET intDecimalPrecision = (SELECT TOP 1 intCurrencyDecimal FROM tblSMCompanyPreference)

	FETCH NEXT FROM intListCursor INTO @strItemNo;
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