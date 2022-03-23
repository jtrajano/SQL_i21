CREATE PROCEDURE uspICDPRDiagnostics
	@emailProfileName AS NVARCHAR(MAX) = NULL
	,@emailRecipient AS NVARCHAR(MAX) = NULL
AS 

-- IR vs Valuation
BEGIN 
	DECLARE @ReceiptVersusValuation AS TABLE (
		strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,dtmReceiptDate DATETIME NULL 
		,dblReceiptQty NUMERIC(38, 20) NULL
		,dblValuationQty NUMERIC(38, 20) NULL
		,dblDifference NUMERIC(38, 20) NULL
	)

	INSERT INTO @ReceiptVersusValuation(
		strReceiptNumber
		,dtmReceiptDate
		,dblReceiptQty
		,dblValuationQty
		,dblDifference
	)
	SELECT TOP 20 
		r.strReceiptNumber
		,r.dtmReceiptDate
		,[Receipt Qty] = CASE WHEN ri.intWeightUOMId IS NOT NULL THEN ISNULL(ri.dblNet, 0) ELSE ri.dblOpenReceive END      
		,[Valuation Qty] = t.dblQty
		,[Difference] =
			CASE WHEN ri.intWeightUOMId IS NOT NULL THEN ISNULL(ri.dblNet, 0) ELSE ri.dblOpenReceive END
			- t.dblQty
	FROM
		tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptItem ri
			ON r.intInventoryReceiptId = ri.intInventoryReceiptId
		INNER JOIN tblICItem i
			ON i.intItemId = ri.intItemId
		OUTER APPLY (
			SELECT
				dblQty = SUM(ISNULL(t.dblQty, 0))
			FROM
				tblICInventoryTransaction t
			WHERE
				t.strTransactionId = r.strReceiptNumber
				AND t.intTransactionId = r.intInventoryReceiptId
				AND t.intTransactionDetailId = ri.intInventoryReceiptItemId
				AND t.intItemId = ri.intItemId
				AND t.intInTransitSourceLocationId IS NULL
		) t
	WHERE
		ri.intOwnershipType = 1
		AND r.ysnPosted = 1
		AND i.strType IN ('Inventory', 'Finished Good', 'Raw Material')
		AND CASE WHEN ri.intWeightUOMId IS NOT NULL THEN ISNULL(ri.dblNet, 0) ELSE ri.dblOpenReceive END <> t.dblQty
		AND r.strReceiptType <> 'Inventory Return'
END

-- Inventory Return vs Valuation 
BEGIN
	DECLARE @ReturnVersusValuation AS TABLE (
		strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,dtmReceiptDate DATETIME NULL 
		,dblReceiptQty NUMERIC(38, 20) NULL
		,dblValuationQty NUMERIC(38, 20) NULL
		,dblDifference NUMERIC(38, 20) NULL
	)

	INSERT INTO @ReturnVersusValuation(
		strReceiptNumber
		,dtmReceiptDate
		,dblReceiptQty
		,dblValuationQty
		,dblDifference
	)
	SELECT TOP 20
		r.strReceiptNumber
		,r.dtmReceiptDate
		,[Receipt Qty] = CASE WHEN ri.intWeightUOMId IS NOT NULL THEN ISNULL(ri.dblNet, 0) ELSE ri.dblOpenReceive END      
		,[Valuation Qty] = t.dblQty
		,[Difference] =
			CASE WHEN ri.intWeightUOMId IS NOT NULL THEN ISNULL(ri.dblNet, 0) ELSE ri.dblOpenReceive END
			- t.dblQty
	FROM
		tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptItem ri
			ON r.intInventoryReceiptId = ri.intInventoryReceiptId
		INNER JOIN tblICItem i
			ON i.intItemId = ri.intItemId
		OUTER APPLY (
			SELECT
				dblQty = SUM(ISNULL(-t.dblQty, 0))
			FROM
				tblICInventoryTransaction t
			WHERE
				t.strTransactionId = r.strReceiptNumber
				AND t.intTransactionId = r.intInventoryReceiptId
				AND t.intTransactionDetailId = ri.intInventoryReceiptItemId
				AND t.intItemId = ri.intItemId
				AND t.intInTransitSourceLocationId IS NULL
		) t
	WHERE
		ri.intOwnershipType = 1
		AND r.ysnPosted = 1
		AND i.strType IN ('Inventory', 'Finished Good', 'Raw Material')
		AND CASE WHEN ri.intWeightUOMId IS NOT NULL THEN ISNULL(ri.dblNet, 0) ELSE ri.dblOpenReceive END <> t.dblQty
		AND r.strReceiptType = 'Inventory Return'
END

-- Shipment vs Valuation
BEGIN
	DECLARE @ShipmentVersusValuation AS TABLE (
		strShipmentNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,dtmShipDate DATETIME NULL 
		,dblShipmentQty NUMERIC(38, 20) NULL
		,dblDestinationQty NUMERIC(38, 20) NULL
		,dblValuationQty NUMERIC(38, 20) NULL
		,dblDifference NUMERIC(38, 20) NULL
	)

	INSERT INTO @ShipmentVersusValuation (
		strShipmentNumber 
		,dtmShipDate 
		,dblShipmentQty 
		,dblDestinationQty 
		,dblValuationQty 
		,dblDifference 
	)
	SELECT TOP 20 
		s.strShipmentNumber
		,s.dtmShipDate
		,[Shipment Qty] = -si.dblQuantity
		,[Destination Qty] = -si.dblDestinationQuantity 
		,[Valuation Qty] = t.dblQty
		,[Difference] =
			-si.dblQuantity
			-t.dblQty
	FROM
		tblICInventoryShipment s INNER JOIN tblICInventoryShipmentItem si
			ON s.intInventoryShipmentId = si.intInventoryShipmentId
		INNER JOIN tblICItem i
			ON i.intItemId = si.intItemId
		OUTER APPLY (
			SELECT
				dblQty = SUM(ISNULL(t.dblQty, 0))
			FROM
				tblICInventoryTransaction t
			WHERE
				t.strTransactionId = s.strShipmentNumber
				AND t.intTransactionId = s.intInventoryShipmentId
				AND t.intTransactionDetailId = si.intInventoryShipmentItemId
				AND t.intItemId = si.intItemId
				AND t.intInTransitSourceLocationId IS NULL
		) t
	WHERE
		si.intOwnershipType = 1
		AND s.ysnPosted = 1
		AND i.strType IN ('Inventory', 'Finished Good', 'Raw Material')
		AND -si.dblQuantity <> t.dblQty
END

IF	@emailProfileName IS NULL 
	AND (
		EXISTS (SELECT TOP 1 1 FROM @ReceiptVersusValuation)
		OR EXISTS (SELECT TOP 1 1 FROM @ReturnVersusValuation)
		OR EXISTS (SELECT TOP 1 1 FROM @ShipmentVersusValuation)
	)
BEGIN 
	SELECT 'Receipt Vs Valuation', * FROM @ReceiptVersusValuation
	SELECT 'Return Vs Valuation', * FROM @ReturnVersusValuation
	SELECT 'Shipment Vs Valuation', * FROM @ShipmentVersusValuation
	RETURN -1 
END 

-- Process the email
IF	@emailProfileName IS NOT NULL 
	AND @emailRecipient IS NOT NULL 
	AND (
		EXISTS (SELECT TOP 1 1 FROM @ReceiptVersusValuation)
		OR EXISTS (SELECT TOP 1 1 FROM @ReturnVersusValuation)
		OR EXISTS (SELECT TOP 1 1 FROM @ShipmentVersusValuation)
	)
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

	-- Receipt versus Valuation
	BEGIN			
		SET @resultAsHTML = @resultAsHTML + N'<h2>Receipt versus Valuation</h2>' +
			N'<table border="1">' + 
			N'<tr>' +
				N'<th>Receipt No.</th>' +
				N'<th>Receipt Date</th>' +
				N'<th align=''right''>Receipt Qty</th>' +
				N'<th align=''right''>Valuation Qty</th>' +
				N'<th align=''right''>Difference</th>' +
			N'</tr>'

		DECLARE 
			@strReceiptNumber NVARCHAR(50) 
			,@dtmReceiptDate DATETIME 
			,@dblReceiptQty NUMERIC(38, 20) 
			,@dblValuationQty NUMERIC(38, 20) 
			,@dblDifference NUMERIC(38, 20) 

		DECLARE loopResult CURSOR LOCAL FAST_FORWARD
		FOR 
		SELECT  
			*
		FROM	
			@ReceiptVersusValuation

		OPEN loopResult
		FETCH NEXT FROM loopResult INTO 
			@strReceiptNumber
			,@dtmReceiptDate 
			,@dblReceiptQty 
			,@dblValuationQty 
			,@dblDifference 

		WHILE @@FETCH_STATUS = 0
		BEGIN 
			SET @resultAsHTML += 
				N'<tr>' + 
				N'<td>'+ @strReceiptNumber +'</td>' + 
				N'<td>'+ CONVERT(NVARCHAR,@dtmReceiptDate,101) +'</td>' + 
				N'<td align=''right''>'+ ISNULL(dbo.fnICFormatNumber(@dblReceiptQty), '') +'</td>' + 
				N'<td align=''right''>'+ ISNULL(dbo.fnICFormatNumber(@dblValuationQty),'') +'</td>' + 
				N'<td align=''right''> '+ ISNULL(dbo.fnICFormatNumber(@dblDifference), '') +'</td>' + 
				N'</tr>'

			FETCH NEXT FROM loopResult INTO 
				@strReceiptNumber
				,@dtmReceiptDate 
				,@dblReceiptQty 
				,@dblValuationQty 
				,@dblDifference 
		END 

		SET @resultAsHTML += N'</table>'; 

		CLOSE loopResult;
		DEALLOCATE loopResult;
	END 

	-- Return versus Valuation
	BEGIN			
		SET @resultAsHTML = @resultAsHTML + N'<h2>Return versus Valuation</h2>' +
			N'<table border="1">' + 
			N'<tr>' +
				N'<th>Receipt No.</th>' +
				N'<th>Receipt Date</th>' +
				N'<th align=''right''>Receipt Qty</th>' +
				N'<th align=''right''>Valuation Qty</th>' +
				N'<th align=''right''>Difference</th>' +
			N'</tr>'

		SELECT 
			@strReceiptNumber = NULL
			,@dtmReceiptDate = NULL
			,@dblReceiptQty = NULL
			,@dblValuationQty = NULL
			,@dblDifference = NULL

		DECLARE loopResult CURSOR LOCAL FAST_FORWARD
		FOR 
		SELECT  
			*
		FROM	
			@ReturnVersusValuation

		OPEN loopResult
		FETCH NEXT FROM loopResult INTO 
			@strReceiptNumber
			,@dtmReceiptDate 
			,@dblReceiptQty 
			,@dblValuationQty 
			,@dblDifference 

		WHILE @@FETCH_STATUS = 0
		BEGIN 
			SET @resultAsHTML += 
				N'<tr>' + 
				N'<td>'+ @strReceiptNumber +'</td>' + 
				N'<td>'+ CONVERT(NVARCHAR,@dtmReceiptDate,101) +'</td>' + 
				N'<td align=''right''>'+ ISNULL(dbo.fnICFormatNumber(@dblReceiptQty), '') +'</td>' + 
				N'<td align=''right''>'+ ISNULL(dbo.fnICFormatNumber(@dblValuationQty), '') +'</td>' + 
				N'<td align=''right''> '+ ISNULL(dbo.fnICFormatNumber(@dblDifference), '') +'</td>' + 
				N'</tr>'

			FETCH NEXT FROM loopResult INTO 
				@strReceiptNumber
				,@dtmReceiptDate 
				,@dblReceiptQty 
				,@dblValuationQty 
				,@dblDifference 
		END 

		SET @resultAsHTML += N'</table>'; 

		CLOSE loopResult;
		DEALLOCATE loopResult;
	END 

	-- Shipment versus Valuation
	BEGIN			
		SET @resultAsHTML = @resultAsHTML + N'<h2>Shipment versus Valuation</h2>' +
			N'<table border="1">' + 
			N'<tr>' +
				N'<th>Shipment No.</th>' +
				N'<th>Ship Date</th>' +
				N'<th align=''right''>Ship Qty</th>' +
				N'<th align=''right''>Destination Qty</th>' +
				N'<th align=''right''>Valuation Qty</th>' +
				N'<th align=''right''>Difference</th>' +
			N'</tr>'

		DECLARE 
			@strShipmentNumber NVARCHAR(50) 
			,@dtmShipDate DATETIME 
			,@dblShipmentQty NUMERIC(38, 20) 
			,@dblDestinationQty NUMERIC(38, 20) 
		
		SET @dblValuationQty = 0 
		SET @dblDifference = 0

		DECLARE loopResult CURSOR LOCAL FAST_FORWARD
		FOR 
		SELECT  
			*
		FROM	
			@ShipmentVersusValuation

		OPEN loopResult
		FETCH NEXT FROM loopResult INTO 
			@strShipmentNumber 
			,@dtmShipDate 
			,@dblShipmentQty 
			,@dblDestinationQty 		
			,@dblValuationQty 
			,@dblDifference 

		WHILE @@FETCH_STATUS = 0
		BEGIN 
			SET @resultAsHTML += 
				N'<tr>' + 
				N'<td>'+ @strShipmentNumber +'</td>' + 
				N'<td>'+ CONVERT(NVARCHAR,@dtmShipDate,101) +'</td>' + 
				N'<td align=''right''>'+ ISNULL(dbo.fnICFormatNumber(@dblShipmentQty), '') +'</td>' + 
				N'<td align=''right''>'+ ISNULL(dbo.fnICFormatNumber(@dblDestinationQty), '') +'</td>' + 
				N'<td align=''right''>'+ ISNULL(dbo.fnICFormatNumber(@dblValuationQty), '') +'</td>' + 
				N'<td align=''right''> '+ ISNULL(dbo.fnICFormatNumber(@dblDifference), '') +'</td>' + 
				N'</tr>'

			FETCH NEXT FROM loopResult INTO 
				@strShipmentNumber 
				,@dtmShipDate 
				,@dblShipmentQty 
				,@dblDestinationQty 		
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


	RETURN 0;
END 

PRINT 'Cheers! IC diagnostics did not find any issues.'