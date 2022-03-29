CREATE OR ALTER PROCEDURE uspICDPRDiagnostics
	@emailProfileName AS NVARCHAR(MAX) = NULL
	,@emailRecipient AS NVARCHAR(MAX) = NULL
AS 

DECLARE 
	@strCommodityCode NVARCHAR(50) 
	,@strTransactionId NVARCHAR(50) 
	,@dblDPRQty NUMERIC(38, 20) 
	,@dblValuationQty NUMERIC(38, 20) 
	,@dblDifference NUMERIC(38, 20) 

DECLARE @dpr AS TABLE (
	intCommodityId INT 
	,strTransactionId NVARCHAR(50) 
	,dblTotal NUMERIC(38, 20) 
)

DECLARE @valuation AS TABLE (
	intCommodityId INT 
	,strTransactionId NVARCHAR(50) 
	,dblTotal NUMERIC(38, 20) 
)

DECLARE @intCommodityId INT
DECLARE @ysnInTransit BIT = 1

-------------------------------------------------------------
-- Run the data fix first before running the valuation
-------------------------------------------------------------
EXEC uspARDprInTransitFix
-------------------------------------------------------------

-- Get the in-transit total as per DPR 
INSERT INTO @dpr (
	intCommodityId 
	,strTransactionId
	,dblTotal 
)
SELECT 
	b.intCommodityId
	,a.strTransactionNumber
	,sum(a.dblTotal)
FROM 
	dbo.fnRKGetBucketInTransit(getdate(),@intCommodityId,null) a INNER JOIN tblICCommodity b 
		ON a.intCommodityId = b. intCommodityId
GROUP BY 
	b.intCommodityId
	,a.strTransactionNumber
HAVING 
	sum(a.dblTotal) <> 0 
ORDER BY 
	b.intCommodityId ASC
	,a.strTransactionNumber ASC 

-- Get the in-transit total sa per Valuation 
INSERT INTO @valuation (
	intCommodityId 
	,strTransactionId
	,dblTotal 
) 
SELECT 
	b.intCommodityId
	,a.strTransactionId
	,sum(dblQuantity)
FROM 
	vyuICGetInventoryValuation a INNER JOIN tblICCommodity b 
		ON a.intCommodityId = b. intCommodityId
WHERE  ysnInTransit = 1
GROUP BY 
	b.intCommodityId
	,a.strTransactionId
HAVING 
	sum(dblQuantity) <> 0
ORDER BY 
	b.intCommodityId ASC
	,a.strTransactionId ASC 

IF EXISTS (
	SELECT TOP 1 1
	FROM 
		@dpr d FULL OUTER JOIN @valuation v
			ON d.intCommodityId = v.intCommodityId
			AND d.strTransactionId = v.strTransactionId
	WHERE
		ISNULL(d.dblTotal, 0) <> ISNULL(v.dblTotal, 0) 
)
BEGIN 
	IF	@emailProfileName IS NULL OR  @emailRecipient IS NULL 
	BEGIN
		SELECT 
			c.strCommodityCode
			,dpr = dpr.dblTotal
			,valuation = valuation.dblTotal
			,[difference] = ISNULL(dpr.dblTotal, 0) - ISNULL(valuation.dblTotal, 0) 
		FROM 
			tblICCommodity c 
			OUTER APPLY 
			(	
				SELECT 
					dblTotal = SUM(ISNULL(d.dblTotal, 0))
				FROM
					@dpr d
				WHERE
					d.intCommodityId = c.intCommodityId
			) dpr 
			OUTER APPLY 
			(
				SELECT 
					dblTotal = SUM(ISNULL(v.dblTotal, 0))
				FROM
					@valuation v
				WHERE
					v.intCommodityId = c.intCommodityId			
			) valuation 				
		WHERE
			ISNULL(dpr.dblTotal, 0) - ISNULL(valuation.dblTotal, 0) <> 0
		ORDER BY
			c.strCommodityCode

		SELECT 
			strTransactionId = ISNULL(dpr.strTransactionId, v.strTransactionId) 
			,dpr = dpr.dblTotal
			,valuation = v.dblTotal
			,[difference] = ISNULL(dpr.dblTotal, 0) - ISNULL(v.dblTotal, 0) 
		FROM 
			@dpr dpr FULL OUTER JOIN @valuation v
				ON dpr.intCommodityId = v.intCommodityId
				AND dpr.strTransactionId = v.strTransactionId			
		WHERE
			ISNULL(dpr.dblTotal, 0) - ISNULL(v.dblTotal, 0) <> 0
		ORDER BY
			ISNULL(dpr.strTransactionId, v.strTransactionId) 

		RETURN -1; 
	END
	
	IF	@emailProfileName IS NOT NULL 
		AND @emailRecipient IS NOT NULL 
	BEGIN 
		PRINT 'Discrepancy found and email will be sent.'		

		DECLARE 
			@resultAsHTML AS NVARCHAR(MAX) 
			,@companyName AS NVARCHAR(MAX) 
	
		-- Get the company name
		SELECT TOP 1 @companyName = ISNULL(strCompanyName, '') FROM tblSMCompanySetup

		-- Assemble the result as html table 
		SET @resultAsHTML = 
			N'<h1>Diagnostic result for ' + @companyName +'</h1>'

		-- Format the details
		BEGIN			
			SET @resultAsHTML = @resultAsHTML + N'<h2>DPR In-Transit versus Valuation In-Transit</h2>' +
				N'<table border="1">' + 
				N'<tr>' +
					N'<th>Commodity</th>' +
					N'<th align=''right''>DPR Qty</th>' +
					N'<th align=''right''>Valuation Qty</th>' +
					N'<th align=''right''>Difference</th>' +
				N'</tr>'

			DECLARE loopResult CURSOR LOCAL FAST_FORWARD
			FOR 
			SELECT 
				c.strCommodityCode
				,dpr = dpr.dblTotal
				,valuation = valuation.dblTotal
				,[difference] = ISNULL(dpr.dblTotal, 0) - ISNULL(valuation.dblTotal, 0) 
			FROM 
				tblICCommodity c 
				OUTER APPLY 
				(	
					SELECT 
						dblTotal = SUM(ISNULL(d.dblTotal, 0))
					FROM
						@dpr d
					WHERE
						d.intCommodityId = c.intCommodityId
				) dpr 
				OUTER APPLY 
				(
					SELECT 
						dblTotal = SUM(ISNULL(v.dblTotal, 0))
					FROM
						@valuation v
					WHERE
						v.intCommodityId = c.intCommodityId			
				) valuation 				
			WHERE
				ISNULL(dpr.dblTotal, 0) - ISNULL(valuation.dblTotal, 0) <> 0
			ORDER BY
				c.strCommodityCode			

			OPEN loopResult
			FETCH NEXT FROM loopResult INTO 
				@strCommodityCode
				,@dblDPRQty 
				,@dblValuationQty 
				,@dblDifference 

			WHILE @@FETCH_STATUS = 0
			BEGIN 
				SET @resultAsHTML += 
					N'<tr>' + 
					N'<td>'+ @strCommodityCode +'</td>' + 
					N'<td align=''right''>'+ ISNULL(dbo.fnICFormatNumber(@dblDPRQty), '') +'</td>' + 
					N'<td align=''right''>'+ ISNULL(dbo.fnICFormatNumber(@dblValuationQty),'') +'</td>' + 
					N'<td align=''right''> '+ ISNULL(dbo.fnICFormatNumber(@dblDifference), '') +'</td>' + 
					N'</tr>'

				FETCH NEXT FROM loopResult INTO 
					@strCommodityCode
					,@dblDPRQty 
					,@dblValuationQty 
					,@dblDifference 
			END 

			SET @resultAsHTML += N'</table>'; 

			CLOSE loopResult;
			DEALLOCATE loopResult;
		END 

		SET @resultAsHTML += '</br>'

		-- Format the 2ND details
		BEGIN			
			SET @resultAsHTML = @resultAsHTML + N'<h2>DPR In-Transit Transaction versus Valuation In-Transit Transaction</h2>' +
				N'<table border="1">' + 
				N'<tr>' +
					N'<th>Transaction Id</th>' +
					N'<th align=''right''>DPR Qty</th>' +
					N'<th align=''right''>Valuation Qty</th>' +
					N'<th align=''right''>Difference</th>' +
				N'</tr>'


			DECLARE loopResult CURSOR LOCAL FAST_FORWARD
			FOR 
			SELECT 
				strTransactionId = ISNULL(dpr.strTransactionId, v.strTransactionId) 
				,dpr = dpr.dblTotal
				,valuation = v.dblTotal
				,[difference] = ISNULL(dpr.dblTotal, 0) - ISNULL(v.dblTotal, 0) 
			FROM 
				@dpr dpr FULL OUTER JOIN @valuation v
					ON dpr.intCommodityId = v.intCommodityId
					AND dpr.strTransactionId = v.strTransactionId			
			WHERE
				ISNULL(dpr.dblTotal, 0) - ISNULL(v.dblTotal, 0) <> 0
			ORDER BY
				ISNULL(dpr.strTransactionId, v.strTransactionId) 	

			OPEN loopResult
			FETCH NEXT FROM loopResult INTO 
				@strTransactionId 
				,@dblDPRQty 
				,@dblValuationQty 
				,@dblDifference 

			WHILE @@FETCH_STATUS = 0
			BEGIN 
				SET @resultAsHTML += 
					N'<tr>' + 
					N'<td>'+ @strTransactionId +'</td>' + 
					N'<td align=''right''>'+ ISNULL(dbo.fnICFormatNumber(@dblDPRQty), '') +'</td>' + 
					N'<td align=''right''>'+ ISNULL(dbo.fnICFormatNumber(@dblValuationQty),'') +'</td>' + 
					N'<td align=''right''> '+ ISNULL(dbo.fnICFormatNumber(@dblDifference), '') +'</td>' + 
					N'</tr>'

				FETCH NEXT FROM loopResult INTO 
					@strTransactionId
					,@dblDPRQty 
					,@dblValuationQty 
					,@dblDifference 
			END 

			SET @resultAsHTML += N'</table>'; 

			CLOSE loopResult;
			DEALLOCATE loopResult;
		END 
		
		-- Send the email 
		EXEC msdb.dbo.sp_send_dbmail
			@profile_name = @emailProfileName
			,@recipients = @emailRecipient
			,@subject = 'IC Diagnostics for DPR'
			,@body = @resultAsHTML
			,@body_format = 'HTML'			

		PRINT 'Email Sent to Queue.'
	END 

	RETURN 0;
END 

PRINT 'Cheers! IC diagnostics did not find any issues.'
RETURN 0; 