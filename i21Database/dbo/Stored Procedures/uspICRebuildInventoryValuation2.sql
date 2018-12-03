CREATE PROCEDURE [dbo].[uspICRebuildInventoryValuation2]
	@dtmStartDate AS DATETIME 
	,@strCategoryCode AS NVARCHAR(50) = NULL 
	,@strItemNo AS NVARCHAR(50) = NULL 
	,@isPeriodic AS BIT = 1
	,@ysnRegenerateBillGLEntries AS BIT = 0
	,@intUserId AS INT = NULL
AS

DECLARE @intItemId AS INT
		,@intCategoryId AS INT 
		,@intReturnValue AS INT 

SELECT @intItemId = intItemId FROM tblICItem WHERE strItemNo = @strItemNo
SELECT @intCategoryId = intCategoryId FROM tblICCategory WHERE strCategoryCode = @strCategoryCode 

IF @intItemId IS NULL AND @strItemNo IS NOT NULL 
BEGIN 
	-- 'Item id is invalid or missing.'
	EXEC uspICRaiseError 80001;
	RETURN -80001; 
END

IF @intCategoryId IS NULL AND @strCategoryCode IS NOT NULL 
BEGIN 
	-- 'Category Code is invalid or missing.'
	EXEC uspICRaiseError 80216;
	RETURN -80216; 
END

-- 'Unable to find an open fiscal year period to match the transaction date.'
IF (dbo.isOpenAccountingDate(@dtmStartDate) = 0) 
BEGIN 	
	EXEC uspICRaiseError 80177, @dtmStartDate; 
	RETURN -1; 
END 

-- Unable to find an open fiscal year period for %s module to match the transaction date.
IF (dbo.isOpenAccountingDateByModule(@dtmStartDate,'Inventory') = 0)
BEGIN 
	EXEC uspICRaiseError 80178, 'Inventory', @dtmStartDate; 
	RETURN -1; 
END 

-- Unable to find an open fiscal year period for %s module to match the transaction date.
IF (dbo.isOpenAccountingDateByModule(@dtmStartDate,'Accounts Receivable') = 0)
BEGIN 
	EXEC uspICRaiseError 80178, 'Accounts Receivable', @dtmStartDate; 
	RETURN -1; 
END 

IF OBJECT_ID('tempdb..#tmpICTransactionForDateSorting') IS NOT NULL  
	DROP TABLE #tmpICTransactionForDateSorting

SELECT	id = IDENTITY(INT, 1, 1) 
		,dtmDate = CASE WHEN @isPeriodic = 0 THEN dtmCreated ELSE dtmDate END
INTO	#tmpICTransactionForDateSorting
FROM	tblICInventoryTransaction t INNER JOIN tblICItem i
			ON t.intItemId = i.intItemId
		LEFT JOIN tblICInventoryTransactionType ty
			ON t.intTransactionTypeId = ty.intTransactionTypeId
WHERE	1 = CASE	WHEN ty.strName = 'Cost Adjustment' THEN 1 
					WHEN ISNULL(dblQty, 0) <> 0 THEN 1
					ELSE 0
			END 	
		AND ISNULL(ysnIsUnposted, 0) = 0 -- This part of the 'WHERE' clause will exclude any unposted transactions during the re-post. 
		AND dbo.fnDateGreaterThanEquals(
			CASE WHEN @isPeriodic = 0 THEN dtmCreated ELSE dtmDate END
			, @dtmStartDate
		) = 1
		AND t.intItemId = ISNULL(@intItemId, t.intItemId) 
		AND ISNULL(i.intCategoryId, 0) = COALESCE(@intCategoryId, i.intCategoryId, 0) 
ORDER BY t.intInventoryTransactionId ASC 

CREATE CLUSTERED INDEX [IX_tmpICTransactionForDateSorting] 
	ON #tmpICTransactionForDateSorting(id ASC);

BEGIN 
	DECLARE @dtmDate AS DATETIME 
			,@dtmDatePrevious AS DATETIME 
			,@dtmNewStartDate AS DATETIME = @dtmStartDate
			,@id AS INT 

	DECLARE loopICTransactionForDateSorting CURSOR LOCAL FAST_FORWARD
	FOR SELECT id, dtmDate FROM #tmpICTransactionForDateSorting

	OPEN loopICTransactionForDateSorting;

	FETCH NEXT FROM loopICTransactionForDateSorting INTO @id, @dtmDate;

	WHILE @@FETCH_STATUS = 0
	BEGIN 

		-- Check for invalid date sequence. 
		-- If invalid, break the loop immediately
		IF	@dtmDatePrevious IS NOT NULL 
			AND dbo.fnDateLessThan(@dtmDate, @dtmDatePrevious) = 1
		BEGIN 
			GOTO _exit_loopICTransactionForDateSorting
		END
		
		SET @dtmDatePrevious = @dtmDate
		FETCH NEXT FROM loopICTransactionForDateSorting INTO @id, @dtmDate;
	END 

	_exit_loopICTransactionForDateSorting:

	CLOSE loopICTransactionForDateSorting;
	DEALLOCATE loopICTransactionForDateSorting;
END

-- Get the new start date. 
SELECT	@dtmNewStartDate = dbo.fnRemoveTimeOnDate(MIN(dtmDate))
FROM	#tmpICTransactionForDateSorting
WHERE	id >= @id

-- Null the new date if it is invalid.  
SELECT	@dtmNewStartDate = NULL 
FROM	#tmpICTransactionForDateSorting
HAVING	dbo.fnDateEquals(MAX(dtmDate),  @dtmNewStartDate) = 1
		AND MAX(id) = @id 

IF @dtmNewStartDate IS NOT NULL 
BEGIN 
	EXEC @intReturnValue = [dbo].[uspICRebuildInventoryValuation]
		@dtmNewStartDate 
		,@strCategoryCode
		,@strItemNo
		,@isPeriodic
		,@ysnRegenerateBillGLEntries
		,@intUserId
END 

_CLEAN_UP: 
BEGIN 
	IF OBJECT_ID('tempdb..#tmpICTransactionForDateSorting') IS NOT NULL  
		DROP TABLE #tmpICTransactionForDateSorting
END

RETURN ISNULL(@intReturnValue, 0);