﻿CREATE PROCEDURE [dbo].[uspAPProcessRecurring]
	@recurrings NVARCHAR(MAX),
	@userId INT
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

CREATE TABLE #tmpRecurringData (
	[intRecurringId] [int] PRIMARY KEY,
	UNIQUE ([intRecurringId])
);

INSERT INTO #tmpRecurringData SELECT [intID] FROM [dbo].fnGetRowsFromDelimitedValues(@recurrings)

SELECT 
* 
INTO #tmpRecurringBill
FROM tblAPRecurringTransaction 
WHERE intRecurringId IN (SELECT intRecurringId FROM #tmpRecurringData)
AND intTransactionType = 1

--SELECT 
--* 
--INTO #tmpRecurringPayable
--FROM tblAPRecurringTransaction 
--WHERE intRecurringId IN (SELECT intRecurringId FROM #tmpRecurringData)
--AND intTransactionType = 2

IF EXISTS(SELECT 1 FROM #tmpRecurringBill)
BEGIN

	DECLARE @billRecurringIds NVARCHAR(MAX);
	SELECT @billRecurringIds = COALESCE(@billRecurringIds + ',', '') +  CONVERT(VARCHAR(12),intTransactionId) FROM #tmpRecurringBill
	EXEC uspAPBillRecurring @recurrings = @billRecurringIds, @userId = @userId

END


END