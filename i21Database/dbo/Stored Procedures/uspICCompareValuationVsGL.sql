CREATE PROCEDURE uspICCompareValuationVsGL
	@dtmAsOfDate AS DATETIME = NULL 
	,@resultAsHTML AS NVARCHAR(MAX) OUTPUT
AS 

SET @dtmAsOfDate = dbo.fnRemoveTimeOnDate(ISNULL(@dtmAsOfDate, GETDATE())) 
 
DECLARE @icAmounts AS TABLE (
	strType NVARCHAR(500)
	,dblAmount NUMERIC(18, 6) 
 )

DECLARE @glAmounts AS TABLE (
	strType NVARCHAR(500)
	,dblAmount NUMERIC(18, 6) 
 )

 DECLARE @icVsGLResult AS TABLE (
	strType NVARCHAR(500)
	,dblICAmount NUMERIC(18, 6) NULL
	,dblGLAmount NUMERIC(18, 6) NULL 
	,dblDiff NUMERIC(18, 6) NULL 
) 

DECLARE 
	@companyName AS NVARCHAR(MAX) 
	,@strType AS NVARCHAR(500)
	,@dblICAmount AS NUMERIC(18, 6)
	,@dblGLAmount AS NUMERIC(18, 6)
	,@dblDiff AS NUMERIC(18, 6)

-- Get the company name
SELECT TOP 1 @companyName = ISNULL(strCompanyName, '') FROM tblSMCompanySetup

-- Get item valuation from the inventory table
BEGIN 
	INSERT INTO @icAmounts (
		strType
		,dblAmount
	)	
	SELECT	
			strType = ty.strName
			,dblAmount  = SUM (
				ROUND(
					dbo.fnMultiply(t.dblQty, t.dblCost) + t.dblValue
					, 2
				)
			)
	FROM	tblICInventoryTransaction t INNER JOIN tblICInventoryTransactionType ty
				ON t.intTransactionTypeId = ty.intTransactionTypeId
	WHERE	
			FLOOR(CAST(t.dtmDate AS FLOAT)) <= FLOOR(CAST(@dtmAsOfDate AS FLOAT))
	GROUP BY ty.strName 
	ORDER BY ty.strName  
END 
 
-- Get item valuation from the GL Detail table
BEGIN 
	INSERT INTO @glAmounts (
		strType
		,dblAmount
	)
	SELECT 
		gd.strTransactionType
		,[IGAmount] = SUM(ROUND(dblDebit - dblCredit,2))
	FROM	tblGLDetail gd INNER JOIN tblGLAccount ga
				ON gd.intAccountId = ga.intAccountId
			INNER JOIN tblGLAccountSegmentMapping gs
				ON gs.intAccountId = ga.intAccountId
			INNER JOIN tblGLAccountSegment gm
				ON gm.intAccountSegmentId = gs.intAccountSegmentId
			INNER JOIN tblGLAccountCategory ac 
				ON ac.intAccountCategoryId = gm.intAccountCategoryId 
			INNER JOIN tblGLAccountStructure gst
				ON gm.intAccountStructureId = gst.intAccountStructureId
	WHERE 
		FLOOR(CAST(gd.dtmDate AS FLOAT)) <= FLOOR(CAST(@dtmAsOfDate AS FLOAT))
		AND ac.strAccountCategory IN ('Inventory', 'Inventory In-Transit')	
		and gst.strType = 'Primary'
		AND gd.ysnIsUnposted = 0 
	GROUP BY 
		gd.strTransactionType
	ORDER BY 
		gd.strTransactionType
END 
	   
-- Overall total 
DECLARE @dblOverallDiff AS NUMERIC(18, 6)
SELECT 	
	@dblOverallDiff = ISNULL(icMfg.dblAmount, 0) - ISNULL(glMfg.dblAmount, 0) 
FROM 
	(SELECT dblAmount = SUM(dblAmount) FROM @icAmounts) icMfg
	OUTER APPLY 
	(SELECT dblAmount = SUM(dblAmount) FROM @glAmounts) glMfg
WHERE
	ISNULL(icMfg.dblAmount, 0) <> ISNULL(glMfg.dblAmount, 0) 

-- Inspect the details if the overall total has a discrepancy. 
IF ISNULL(@dblOverallDiff, 0) <> 0 
BEGIN 
	DECLARE @result AS INT = 0 
	DECLARE @return AS INT = 0 

	-- IC vs GL for common types. 
	INSERT INTO @icVsGLResult (
		strType
		,dblICAmount
		,dblGLAmount 
		,dblDiff
	)
	SELECT 
		ic.strType
		,ic.dblAmount
		,gl.dblAmount
		,ISNULL(ic.dblAmount, 0) - ISNULL(gl.dblAmount, 0) 
	FROM 
		@icAmounts ic LEFT JOIN @glAmounts gl
			ON ic.strType = gl.strType
	WHERE
		ISNULL(ic.dblAmount, 0) <> ISNULL(gl.dblAmount, 0) 
		AND ic.strType NOT IN ('Consume', 'Produce', 'Inventory Adjustment - Opening Inventory')

	SET @result = @@ROWCOUNT
	IF ISNULL(@result, 0) > 0 SET @return = -1
	
	-- IC vs GL for Consume and Produce
	INSERT INTO @icVsGLResult (
		strType
		,dblICAmount
		,dblGLAmount 
		,dblDiff
	)
	SELECT 
		'Consume and Produce'
		,[IC Amount] = icMfg.dblAmount
		,[GL Amount] = glMfg.dblAmount
		,dblDifference = ISNULL(icMfg.dblAmount, 0) - ISNULL(glMfg.dblAmount, 0) 
	FROM 
		(SELECT dblAmount = SUM(dblAmount) FROM @icAmounts WHERE strType IN ('Consume', 'Produce')) icMfg
		OUTER APPLY 
		(SELECT dblAmount = SUM(dblAmount) FROM @glAmounts WHERE strType IN ('Consume', 'Produce')) glMfg
	WHERE
		ISNULL(icMfg.dblAmount, 0) <> ISNULL(glMfg.dblAmount, 0) 

	SET @result = @@ROWCOUNT
	IF ISNULL(@result, 0) > 0 SET @return = -1
	
	-- Return -1 to signify an error. 
	
	IF @return < 0
	BEGIN 
		PRINT 'Valuation does not match. Emailing the details for inspection.'

		-- Assemble the result as html table 
		BEGIN			
			SET @resultAsHTML = 
				N'<h1>IC vs GL Result for ' + @companyName +'</h1>'+
				N'<table border="1">' + 
				N'<tr><th>Type</th><th align=''right''>IC Amount</th><th align=''right''>GL Amount</th><th align=''right''>Difference</th></tr>' 

			DECLARE loopResult CURSOR LOCAL FAST_FORWARD
			FOR 
			SELECT  
				strType
				,dblICAmount
				,dblGLAmount 
				,dblDiff
			FROM	
				@icVsGLResult

			OPEN loopResult
			FETCH NEXT FROM loopResult INTO 
				@strType
				,@dblICAmount
				,@dblGLAmount
				,@dblDiff

			WHILE @@FETCH_STATUS = 0
			BEGIN 
				SET @resultAsHTML += 
					N'<tr>' + 
					N'<td>'+ @strType +'</td>' + 
					N'<td align=''right''>'+ dbo.fnICFormatNumber(@dblICAmount) +'</td>' + 
					N'<td align=''right''>'+ dbo.fnICFormatNumber(@dblGLAmount) +'</td>' + 
					N'<td align=''right''> '+ dbo.fnICFormatNumber(@dblDiff) +'</td>' + 
					N'</tr>'

				FETCH NEXT FROM loopResult INTO 
					@strType
					,@dblICAmount
					,@dblGLAmount
					,@dblDiff
			END 

			SET @resultAsHTML += N'</table>'; 
		END 
		RETURN 0; 
	END 	
END

PRINT 'Cheers! The valuation between IC and GL matches.'