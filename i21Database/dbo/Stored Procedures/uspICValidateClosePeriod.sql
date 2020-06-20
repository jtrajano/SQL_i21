CREATE PROCEDURE uspICValidateClosePeriod
	@strFYMonth AS NVARCHAR(100) = NULL 
AS 

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @dtmStartDate AS DATETIME 
	,@strTransactionId AS NVARCHAR(50)
	,@dtmDate AS DATETIME 

IF @strFYMonth IS NOT NULL 
BEGIN
	SELECT 
		@dtmStartDate = fyp.dtmStartDate
	FROM
		tblGLFiscalYearPeriod fyp
	WHERE
		fyp.strPeriod = @strFYMonth
END 

-- 'Unable to find an open fiscal year period to match the transaction date.'
IF (dbo.isOpenAccountingDate(@dtmStartDate) = 0) 
BEGIN 	
	EXEC uspICRaiseError 80177, @dtmStartDate; 
	RETURN -80177; 
END 

-- Unable to find an open fiscal year period for %s module to match the transaction date.
IF (dbo.isOpenAccountingDateByModule(@dtmStartDate, 'Inventory') = 0)
BEGIN 
	EXEC uspICRaiseError 80178, 'Inventory', @dtmStartDate; 
	RETURN -80178; 
END 

-- Unable to find an open fiscal year period for %s module to match the transaction date.
IF (dbo.isOpenAccountingDateByModule(@dtmStartDate, 'Accounts Receivable') = 0)
BEGIN 
	EXEC uspICRaiseError 80178, 'Accounts Receivable', @dtmStartDate; 
	RETURN -80178; 
END 

DECLARE @intInventoryTransactionId AS INT 
SELECT TOP 1 
	@intInventoryTransactionId = t.intInventoryTransactionId
FROM 
	tblICInventoryTransaction t INNER JOIN tblICItem i 
		ON t.intItemId = i.intItemId
	LEFT JOIN tblICCategory c
		ON c.intCategoryId = i.intCategoryId
WHERE
	t.dblQty <> 0 
	AND t.dblValue = 0  
	AND FLOOR(CAST(t.dtmDate AS FLOAT)) >= FLOOR(CAST(@dtmStartDate AS FLOAT))
ORDER BY
	t.intInventoryTransactionId ASC 

SELECT TOP 1
	@strTransactionId = strTransactionId
	,@dtmDate = dtmDate
FROM (
		SELECT 
			t.dtmDate
			,t.strTransactionId
			,correctSeq = ROW_NUMBER() OVER (ORDER BY t.intItemId, t.dtmDate, t.intInventoryTransactionId)
			,actualSeq = ROW_NUMBER() OVER (ORDER BY t.intItemId, t.intInventoryTransactionId)
		FROM 
			tblICInventoryTransaction t INNER JOIN tblICItem i 
				ON t.intItemId = i.intItemId
			LEFT JOIN tblICCategory c
				ON c.intCategoryId = i.intCategoryId
		WHERE
			t.dblQty <> 0 
			AND t.dblValue = 0  
			AND t.intInventoryTransactionId >= @intInventoryTransactionId
	)
	AS tblSequenced
WHERE
	tblSequenced.correctSeq <> tblSequenced.actualSeq 
ORDER BY
	tblSequenced.dtmDate ASC 

IF @strTransactionId IS NOT NULL 
BEGIN 
	-- '%s is a back-dated transaction. Please do a Rebuild Inventory from %d before closing the fiscal month.'
	EXEC uspICRaiseError 80254, @strTransactionId, @dtmDate; 

	RETURN -80254;
END 
