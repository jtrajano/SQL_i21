CREATE PROCEDURE [dbo].[uspICRebuildInventoryValuation2]
	@dtmStartDate AS DATETIME 
	,@strCategoryCode AS NVARCHAR(50) = NULL 
	,@strItemNo AS NVARCHAR(50) = NULL 
	,@isPeriodic AS BIT = 1
	,@ysnRegenerateBillGLEntries AS BIT = 0
	,@intUserId AS INT = NULL
	,@ysnAcceptBackDate AS BIT = 0
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

DECLARE @dtmNewStartDate AS DATETIME = @dtmStartDate
DECLARE @backDateTransaction AS TABLE (
	dtmDate DATETIME
)

INSERT INTO @backDateTransaction (
	dtmDate
)
EXEC @intReturnValue = uspICGetBackDatedTransaction
	@strItemNo = @strItemNo
	,@strCategoryCode = @strCategoryCode
	,@dtmStartDate = @dtmStartDate
	,@strFYMonth = NULL 	

IF @intReturnValue <> 0 
BEGIN 
	RETURN @intReturnValue;
END 

IF EXISTS (SELECT TOP 1 1 FROM @backDateTransaction WHERE dbo.fnRemoveTimeOnDate(dtmDate) < dbo.fnRemoveTimeOnDate(@dtmStartDate)) 
BEGIN 
	SELECT TOP 1 
		@dtmNewStartDate = dbo.fnRemoveTimeOnDate(dtmDate)  
	FROM 
		@backDateTransaction 
	WHERE 
		dbo.fnRemoveTimeOnDate(dtmDate) < dbo.fnRemoveTimeOnDate(@dtmStartDate)		
		
	IF ISNULL(@ysnAcceptBackDate, 0) = 0
	BEGIN 
		-- There are backdated transactions made in <Month> <Year>. Do you want to rebuild from <Month> <Year>??
		DECLARE @rebuildMonth AS NVARCHAR(50) 
				,@suggestedRebuildMonth AS NVARCHAR(50) 
				,@rebuildYear AS INT
				,@suggestedRebuildYear AS INT 

		
		SELECT
			@rebuildMonth = dbo.fnMonthName(MONTH(@dtmStartDate))  
			,@suggestedRebuildMonth = dbo.fnMonthName(MONTH(@dtmNewStartDate))  
			,@rebuildYear = YEAR(@dtmStartDate)
			,@suggestedRebuildYear = YEAR(@dtmNewStartDate)


		EXEC uspICRaiseError 80252, @rebuildMonth, @rebuildYear, @suggestedRebuildMonth, @suggestedRebuildYear; 
		RETURN -80252; 
	END 

	SET @dtmNewStartDate = ISNULL(@dtmNewStartDate, dbo.fnRemoveTimeOnDate(@dtmStartDate)) 			
END 

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
ELSE
BEGIN 
	-- Create the backup header
	DECLARE @strRemarks VARCHAR(200)
	DECLARE @strRebuildFilter VARCHAR(50)	

	SET @strRebuildFilter = (CASE WHEN @intItemId IS NOT NULL THEN '"' + @strItemNo + '" item' ELSE 'all items' END)
	SET @strRebuildFilter = (CASE WHEN @strCategoryCode IS NOT NULL THEN '"' + @strCategoryCode + '" category' ELSE @strRebuildFilter END)

	SET @strRemarks = 'Stocks are up to date. Rebuild is skipped for ' + @strRebuildFilter + ' in '+
		(CASE @isPeriodic WHEN 1 THEN 'periodic' ELSE 'perpetual' END) + ' order' +
		' from '+ CONVERT(VARCHAR(10), @dtmStartDate, 101) + ' onwards.' 

	INSERT INTO tblICBackup(dtmDate, intUserId, strOperation, strRemarks, ysnRebuilding, dtmStart, dtmEnd, strItemNo, strCategoryCode)
	SELECT @dtmStartDate, @intUserId, 'Rebuild Inventory', @strRemarks, 0, GETDATE(), GETDATE(), @strItemNo, @strCategoryCode
		
END 
_CLEAN_UP: 
BEGIN 
	IF OBJECT_ID('tempdb..#tmpICTransactionForDateSorting') IS NOT NULL  
		DROP TABLE #tmpICTransactionForDateSorting
END

RETURN ISNULL(@intReturnValue, 0);