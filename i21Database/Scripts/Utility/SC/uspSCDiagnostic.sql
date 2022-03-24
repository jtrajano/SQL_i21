CREATE OR ALTER PROCEDURE [dbo].[uspSCScaleDiagnostic]
(
    @emailProfileName AS NVARCHAR(MAX)
    ,@emailRecipient AS NVARCHAR(MAX)
)
as
SET ANSI_WARNINGS ON
begin
	DECLARE
		@xhtmlBody XML
    	,@body NVARCHAR(MAX)
		,@strSubject NVARCHAR(MAX)
	
	SELECT @strSubject = 'Scale Diagnostic for ' + strCompanyName FROM tblSMCompanySetup

	set @body = '<html><head><meta charset="utf-8"/></head><body>'

	--Single unit

	--Start Summation Per Commodity



	Select '***-**********--********** START Summation Per Commodity **********--**********-***' 
	SELECT '***-**********--********** PART I **********--**********-***'
	SET @body = @body + '<h2>START Summation Per Commodity</h2>'
	SET @body = @body + '<h3>PART I</h3>'

	DECLARE @intCommodity INT
	DECLARE @strCommodity NVARCHAR(200)
 
	IF OBJECT_ID('tempdb..#tmpCOMM') IS NOT NULL DROP TABLE #tmpCOMM
 
	SELECT
		intCommodityId
		,strCommodityCode
	INTO #tmpCOMM
	FROM tblICCommodity
	WHERE intCommodityId IN (1,2,3)
 
	SET @intCommodity = NULL
	SELECT TOP 1
		@intCommodity = intCommodityId
		,@strCommodity = strCommodityCode
	FROM #tmpCOMM
	ORDER BY strCommodityCode
 
	WHILE (ISNULL(@intCommodity,0) > 0)
	BEGIN
 
 
 
		 ---Get all the IR for tickets
		IF OBJECT_ID('tempdb..#tmpTKTIR') IS NOT NULL DROP TABLE #tmpTKTIR
   
		SELECT DISTINCT
			A.intSourceId
			,B.intInventoryReceiptId
		INTO #tmpTKTIR
		FROM tblICInventoryReceiptItem A
		INNER JOIN tblSCTicket Z
			ON A.intSourceId = Z.intTicketId
		INNER JOIN tblICInventoryReceipt B
			ON A.intInventoryReceiptId = B.intInventoryReceiptId
		INNER JOIN tblICItem C
			ON A.intItemId = C.intItemId
		WHERE B.intSourceType = 1
			AND C.intCommodityId = @intCommodity

		
		-- SELECT
		-- 	@strCommodity strCommodity
		-- 	,Z.IRTotal
		-- 	,Diff = Z.IRTotal - Z.TicketTotal
		-- FROM(
		-- 	SELECT
		-- 		TicketTotal = SUM(dblNetUnits)
		-- 		,IRTotal = (SELECT SUM(AA.dblReceived)
		-- 					FROM tblICInventoryReceiptItem AA
		-- 					INNER JOIN tblICItem BB
		-- 						ON AA.intItemId = BB.intItemId
		-- 					WHERE intInventoryReceiptId IN (SELECT intInventoryReceiptId FROM  #tmpTKTIR)
		-- 					AND BB.intCommodityId = @intCommodity)
		-- 	FROM tblSCTicket A
		-- 	WHERE A.intCommodityId = @intCommodity
		-- 		AND A.strTicketStatus = 'C'
		-- 		AND A.intTicketType = 1
		-- 		AND A.strInOutFlag = 'I'
		-- )Z
   
   
		SET @xhtmlBody = (SELECT (
			--Get the difference of IR vs Ticket units
			SELECT
				@strCommodity strCommodity
				,Z.*
				,Diff = Z.IRTotal - Z.TicketTotal
			FROM(
				SELECT
					TicketTotal = SUM(dblNetUnits)
					,IRTotal = (SELECT SUM(AA.dblReceived)
								FROM tblICInventoryReceiptItem AA
								INNER JOIN tblICItem BB
									ON AA.intItemId = BB.intItemId
								WHERE intInventoryReceiptId IN (SELECT intInventoryReceiptId FROM  #tmpTKTIR)
								AND BB.intCommodityId = @intCommodity)
				FROM tblSCTicket A
				WHERE A.intCommodityId = @intCommodity
					AND A.strTicketStatus = 'C'
					AND A.intTicketType = 1
					AND A.strInOutFlag = 'I'
			)Z
			FOR XML PATH('row'), TYPE, ROOT('root'))
.query('<table border="1">
	<thead>
	<tr>
		<th>Commodity</th>
		<th>IR Total</th>
		<th>Ticket Total</th>
		<th>Diff</th>
	</tr>
	</thead>
	<tbody>
{
	for $row in /root/row
	return <tr>
			<td>{data($row/strCommodity)}</td>
			<td>{data($row/IRTotal)}</td>
			<td>{data($row/TicketTotal)}</td>
			<td>{data($row/Diff)}</td>
		</tr>
}
</tbody></table>'));

	SET @body = @body + ISNULL(CAST(@xhtmlBody AS NVARCHAR(MAX)), '')
 
 
		SET @intCommodity = NULL
		SELECT TOP 1
			@intCommodity = intCommodityId
			,@strCommodity = strCommodityCode
		FROM #tmpCOMM
		WHERE strCommodityCode > @strCommodity
		ORDER BY strCommodityCode
	END
  
	SELECT '***-**********--********** PART II **********--**********-***'
	 SELECT @intCommodity = NULL
		, @strCommodity = ''

	SET @body = @body + '<h3>PART II</h3>'
 
	--IF OBJECT_ID('tempdb..#tmpCOMM') IS NOT NULL DROP TABLE #tmpCOMM

	--SELECT
	--    intCommodityId
	--    ,strCommodityCode
	--INTO #tmpCOMM
	--FROM tblICCommodity
	--WHERE intCommodityId IN (1,2,3)



	SET @intCommodity = NULL
	SELECT TOP 1
		@intCommodity = intCommodityId
		,@strCommodity = strCommodityCode
	FROM #tmpCOMM
	ORDER BY strCommodityCode
 
	WHILE (ISNULL(@intCommodity,0) > 0)
	BEGIN
 
 
 
		---Get all the IS for tickets
		IF OBJECT_ID('tempdb..#tmpTKTIS') IS NOT NULL DROP TABLE #tmpTKTIS
		SELECT DISTINCT
			A.intSourceId
			,B.intInventoryShipmentId
		INTO #tmpTKTIS
		FROM tblICInventoryShipmentItem A
		INNER JOIN tblICItem AA
			On A.intItemId = AA.intItemId
		INNER JOIN tblSCTicket Z
			ON A.intSourceId = Z.intTicketId
		INNER JOIN tblICInventoryShipment B
			ON A.intInventoryShipmentId = B.intInventoryShipmentId
		LEFT JOIN tblARInvoiceDetail C
			ON A.intInventoryShipmentItemId = ISNULL(C.intInventoryShipmentItemId,0)
		LEFT JOIN tblARInvoice D
			ON ISNULL(D.intInvoiceId,0) = ISNULL(C.intInvoiceId,0)
		LEFT JOIN tblARInvoiceDetail E
			ON ISNULL(C.intInvoiceDetailId,0) = ISNULL(E.intOriginalInvoiceDetailId,0)
		LEFT JOIN tblARInvoice F
			ON ISNULL(F.intInvoiceId,0) = ISNULL(E.intInvoiceId,0)
		WHERE B.intSourceType = 1
			AND AA.intCommodityId = @intCommodity
   
   
		--Get All IS with credit Memo
		IF OBJECT_ID('tempdb..#tmpISCM') IS NOT NULL DROP TABLE #tmpISCM
		SELECT DISTINCT
			A.intSourceId
			,B.intInventoryShipmentId
		INTO #tmpISCM
		FROM tblICInventoryShipmentItem A
		INNER JOIN tblICItem AA
			On A.intItemId = AA.intItemId
		INNER JOIN tblSCTicket Z
			ON A.intSourceId = Z.intTicketId
		INNER JOIN tblICInventoryShipment B
			ON A.intInventoryShipmentId = B.intInventoryShipmentId
		LEFT JOIN tblARInvoiceDetail C
			ON A.intInventoryShipmentItemId = ISNULL(C.intInventoryShipmentItemId,0)
		LEFT JOIN tblARInvoice D
			ON ISNULL(D.intInvoiceId,0) = ISNULL(C.intInvoiceId,0)
		LEFT JOIN tblARInvoiceDetail E
			ON ISNULL(C.intInvoiceDetailId,0) = ISNULL(E.intOriginalInvoiceDetailId,0)
		LEFT JOIN tblARInvoice F
			ON ISNULL(F.intInvoiceId,0) = ISNULL(E.intInvoiceId,0)
		WHERE B.intSourceType = 1
			AND AA.intCommodityId = @intCommodity
			AND F. strTransactionType = 'Credit Memo'
       
   
   
   
   
		--Get the difference of IS vs Ticket units
		-- SELECT
		-- 	 @strCommodity
		-- 	,Z.*
		-- 	,Diff = Z.ISTotal - Z.TicketTotal
		-- 	,DiffDWG = Z.ISTotalDWG - Z.TicketTotal
		-- FROM(
		-- 	SELECT
		-- 		TicketTotal = SUM(dblNetUnits)
		-- 		,ISTotalDWG = (SELECT SUM(ISNULL(dblDestinationQuantity,dblQuantity))
		-- 					FROM tblICInventoryShipmentItem AA
		-- 					INNER JOIN tblICItem BB
		-- 						ON AA.intItemId = BB.intItemId
		-- 					WHERE intInventoryShipmentId IN (SELECT intInventoryShipmentId FROM  #tmpTKTIS)
		-- 					AND BB.intCommodityId = @intCommodity)
		-- 		,ISTotal = (SELECT SUM(dblQuantity)
		-- 					FROM tblICInventoryShipmentItem AA
		-- 					INNER JOIN tblICItem BB
		-- 						ON AA.intItemId = BB.intItemId
		-- 					WHERE intInventoryShipmentId IN (SELECT intInventoryShipmentId FROM  #tmpTKTIS)
		-- 					AND BB.intCommodityId = @intCommodity)
		-- 	FROM tblSCTicket A
		-- 	WHERE A.intCommodityId = @intCommodity
		-- 		AND A.strTicketStatus = 'C'
		-- 		AND A.intTicketType = 1
		-- 		AND A.strInOutFlag = 'O'
		-- )Z

		SET @xhtmlBody = (SELECT (
			SELECT
				@strCommodity strCommodity
				,Z.*
				,Diff = Z.ISTotal - Z.TicketTotal
				,DiffDWG = Z.ISTotalDWG - Z.TicketTotal
			FROM(
				SELECT
					TicketTotal = SUM(dblNetUnits)
					,ISTotalDWG = (SELECT SUM(ISNULL(dblDestinationQuantity,dblQuantity))
								FROM tblICInventoryShipmentItem AA
								INNER JOIN tblICItem BB
									ON AA.intItemId = BB.intItemId
								WHERE intInventoryShipmentId IN (SELECT intInventoryShipmentId FROM  #tmpTKTIS)
								AND BB.intCommodityId = @intCommodity)
					,ISTotal = (SELECT SUM(dblQuantity)
								FROM tblICInventoryShipmentItem AA
								INNER JOIN tblICItem BB
									ON AA.intItemId = BB.intItemId
								WHERE intInventoryShipmentId IN (SELECT intInventoryShipmentId FROM  #tmpTKTIS)
								AND BB.intCommodityId = @intCommodity)
				FROM tblSCTicket A
				WHERE A.intCommodityId = @intCommodity
					AND A.strTicketStatus = 'C'
					AND A.intTicketType = 1
					AND A.strInOutFlag = 'O'
			)Z
			FOR XML PATH('row'), TYPE, ROOT('root'))
.query('<table border="1">
	<thead>
	<tr>
		<th>Commodity</th>
		<th>Ticket Total</th>
		<th>IS Total DWG</th>
		<th>IS Total</th>
		<th>Diff</th>
		<th>Diff DWG</th>
	</tr>
	</thead>
	<tbody>
{
	for $row in /root/row
	return <tr>
			<td>{data($row/strCommodity)}</td>
			<td>{data($row/TicketTotal)}</td>
			<td>{data($row/ISTotalDWG)}</td>
			<td>{data($row/ISTotal)}</td>
			<td>{data($row/Diff)}</td>
			<td>{data($row/DiffDWG)}</td>
		</tr>
}
</tbody></table>'));
   
 SET @body = @body + ISNULL(CAST(@xhtmlBody AS NVARCHAR(MAX)), '')
 
		SET @intCommodity = NULL
		SELECT TOP 1
			@intCommodity = intCommodityId
			,@strCommodity = strCommodityCode
		FROM #tmpCOMM
		WHERE strCommodityCode > @strCommodity
		ORDER BY strCommodityCode
	END
  

	Select '***-**********--********** END Summation Per Commodity **********--**********-***' 
	SET @body = @body + '<h2>END Summation Per Commodity</h2></hr>'

	select '***-**********--********** Start 1 - Scale (Contract) SC-4353 **********--**********-***'
	SET @body = @body + '<h2>START 1 Scale (Contract) SC-4353</h2>'

	-- SELECT
	-- 	A.intTicketId
	-- 	,A.strTicketNumber
	-- 	,C.strReceiptNumber
	-- 	,C.intInventoryReceiptId
	-- 	,ReceiptEntity = C.intEntityVendorId
	-- 	,C.dtmReceiptDate
	-- 	,A.dtmTicketDateTime
	-- FROM tblSCTicket A
	-- INNER JOIN tblICInventoryReceiptItem B
	-- 	ON B.intSourceId = A.intTicketId
	-- INNER JOIN tblICInventoryReceipt C
	-- 	ON C.intInventoryReceiptId = B.intInventoryReceiptId
	-- INNER JOIN tblSCTicketSplit D
	-- 	ON A.intTicketId = D.intTicketId
	-- 	AND D.intCustomerId = C.intEntityVendorId
	-- WHERE A.strDistributionOption = 'SPL'
	-- 	AND C.intSourceType = 1
	-- 	AND (B.intContractDetailId IS NULL OR B.intContractDetailId = 0)
	-- 	AND B.intOwnershipType = 1
	-- 	AND (D.intStorageScheduleTypeId = -2)
	-- 	AND (B.ysnAllowVoucher = 0 OR B.ysnAllowVoucher IS NULL)

	SET @xhtmlBody = (SELECT (
			SELECT
				A.intTicketId
				,A.strTicketNumber
				,C.strReceiptNumber
				,C.intInventoryReceiptId
				,ReceiptEntity = C.intEntityVendorId
				,C.dtmReceiptDate
				,A.dtmTicketDateTime
			FROM tblSCTicket A
			INNER JOIN tblICInventoryReceiptItem B
				ON B.intSourceId = A.intTicketId
			INNER JOIN tblICInventoryReceipt C
				ON C.intInventoryReceiptId = B.intInventoryReceiptId
			INNER JOIN tblSCTicketSplit D
				ON A.intTicketId = D.intTicketId
				AND D.intCustomerId = C.intEntityVendorId
			WHERE A.strDistributionOption = 'SPL'
				AND C.intSourceType = 1
				AND (B.intContractDetailId IS NULL OR B.intContractDetailId = 0)
				AND B.intOwnershipType = 1
				AND (D.intStorageScheduleTypeId = -2)
				AND (B.ysnAllowVoucher = 0 OR B.ysnAllowVoucher IS NULL)
			FOR XML PATH('row'), TYPE, ROOT('root'))
.query('<table border="1">
	<thead>
	<tr>
		<th>intTicketId</th>
		<th>strTicketNumber</th>
		<th>strReceiptNumber</th>
		<th>intInventoryReceiptId</th>
		<th>ReceiptEntity</th>
		<th>dtmReceiptDate</th>
		<th>dtmTicketDateTime</th>
	</tr>
	</thead>
	<tbody>
{
	for $row in /root/row
	return <tr>
			<td>{data($row/intTicketId)}</td>
			<td>{data($row/strTicketNumber)}</td>
			<td>{data($row/strReceiptNumber)}</td>
			<td>{data($row/intInventoryReceiptId)}</td>
			<td>{data($row/ReceiptEntity)}</td>
			<td>{data($row/dtmReceiptDate)}</td>
			<td>{data($row/dtmTicketDateTime)}</td>
		</tr>
}
</tbody></table>'));
SET @body = @body + ISNULL(CAST(@xhtmlBody AS NVARCHAR(MAX)), '')

	select '***-**********--********** End 1 - Scale (Contract) SC-4353 **********--**********-***'
	SET @body = @body + '<h2>END 1 Scale (Contract) SC-4353</h2></hr>'

	select '***-**********--********** Start 2 - IR vs TicketUnits **********--**********-***'
	SET @body = @body + '<h2>START 2 IR vs Ticket Units</h2>'

	DECLARE @intItemId INT
	DECLARE @strItemNo NVARCHAR(200)
  
 
	
	IF OBJECT_ID('tempdb..#tmpITM') IS NOT NULL DROP TABLE #tmpITM_diag_2
 
	SELECT
		strItemNo
		,intItemId
	INTO #tmpITM_diag_2
	FROM tblICItem
	WHERE intCommodityId IN (1,2,3)
		AND strType = 'Inventory'
	ORDER BY strItemNo ASC
 
	SELECT TOP 1
		@strItemNo = strItemNo
		,@intItemId = intItemId
	FROM #tmpITM_diag_2
	ORDER BY strItemNo ASC
			--SET @strItemNo = '#2 Yellow Soybeans'
			--SELECT @intItemId = intItemId FROM tblICItem WHERE strItemNo = @strItemNo
	WHILE ISNULL(@intItemId ,0) > 0
	BEGIN
		SELECT @strItemNo
		SET @body = @body + '<h3><b>' + @strItemNo + '</b></h3>'
  
		---Get all the IR for tickets
		IF OBJECT_ID('tempdb..#tmpTKTIR_diag_2') IS NOT NULL DROP TABLE #tmpTKTIR_diag_2
  
		SELECT DISTINCT
			A.intSourceId
			,B.intInventoryReceiptId
		INTO #tmpTKTIR_diag_2
		FROM tblICInventoryReceiptItem A
		INNER JOIN tblSCTicket Z
			ON A.intSourceId = Z.intTicketId
		INNER JOIN tblICInventoryReceipt B
			ON A.intInventoryReceiptId = B.intInventoryReceiptId
		WHERE B.intSourceType = 1
			AND A.intItemId = @intItemId
  
  
		--Get the difference of IR vs Ticket units
		-- SELECT
		-- 	Z.*
		-- 	,Diff = Z.IRTotal - Z.TicketTotal
		-- FROM(
		-- 	SELECT
		-- 		TicketTotal = SUM(dblNetUnits)
		-- 		,IRTotal = (SELECT SUM(dblReceived)
		-- 					FROM tblICInventoryReceiptItem
		-- 					WHERE intInventoryReceiptId IN (SELECT intInventoryReceiptId FROM  #tmpTKTIR_diag_2)
		-- 					AND intItemId = @intItemId)
		-- 	FROM tblSCTicket A
		-- 	WHERE A.intItemId = @intItemId
		-- 		AND A.strTicketStatus = 'C'
		-- 		AND A.intTicketType = 1
		-- 		AND A.strInOutFlag = 'I'
		-- )Z

	SET @xhtmlBody = (SELECT (
		--Get the difference of IR vs Ticket units
		SELECT
			Z.*
			,Diff = Z.IRTotal - Z.TicketTotal
		FROM(
			SELECT
				TicketTotal = SUM(dblNetUnits)
				,IRTotal = (SELECT SUM(dblReceived)
							FROM tblICInventoryReceiptItem
							WHERE intInventoryReceiptId IN (SELECT intInventoryReceiptId FROM  #tmpTKTIR_diag_2)
							AND intItemId = @intItemId)
			FROM tblSCTicket A
			WHERE A.intItemId = @intItemId
				AND A.strTicketStatus = 'C'
				AND A.intTicketType = 1
				AND A.strInOutFlag = 'I'
		)Z
		FOR XML PATH('row'), TYPE, ROOT('root'))
.query('<table border="1">
	<thead>
	<tr>
		<th>TicketTotal</th>
		<th>IRTotal</th>
		<th>Diff</th>
	</tr>
	</thead>
	<tbody>
{
	for $row in /root/row
	return <tr>
			<td>{data($row/TicketTotal)}</td>
			<td>{data($row/IRTotal)}</td>
			<td>{data($row/Diff)}</td>
		</tr>
}
</tbody></table>'));
  SET @body = @body + ISNULL(CAST(@xhtmlBody AS NVARCHAR(MAX)), '')
  
		--Get the Tickets that are Completed but dont have IR
		-- SELECT
		-- 	A.strTicketNumber
		-- 	,strRemark = 'Completed Ticket that dont have IR'
		-- FROM tblSCTicket A
		-- WHERE intTicketId NOT IN (SELECT intSourceId FROM #tmpTKTIR_diag_2)
		-- 	AND A.intItemId = @intItemId
		-- 	AND A.strTicketStatus = 'C'
		-- 	AND A.intTicketType = 1
		-- 	AND A.strInOutFlag = 'I'
  
	SET @xhtmlBody = (SELECT (
		--Get the Tickets that are Completed but dont have IR
		SELECT
			A.strTicketNumber
			,strRemark = 'Completed Ticket that dont have IR'
		FROM tblSCTicket A
		WHERE intTicketId NOT IN (SELECT intSourceId FROM #tmpTKTIR_diag_2)
			AND A.intItemId = @intItemId
			AND A.strTicketStatus = 'C'
			AND A.intTicketType = 1
			AND A.strInOutFlag = 'I'
		FOR XML PATH('row'), TYPE, ROOT('root'))
.query('<table border="1">
	<thead>
	<tr>
		<th>strTicketNumber</th>
		<th>strRemark</th>
	</tr>
	</thead>
	<tbody>
{
	for $row in /root/row
	return <tr>
			<td>{data($row/strTicketNumber)}</td>
			<td>{data($row/strRemark)}</td>
		</tr>
}
</tbody></table>'));
  SET @body = @body + ISNULL(CAST(@xhtmlBody AS NVARCHAR(MAX)), '')
  
		---Compare Ticket units vs IR units
		-- SELECT
		-- 	X.*
		-- 	,DIFF = IRQty - TicketQty
		-- 	,strRemark = 'Ticket Quantity is not equal to IR'
		-- FROM (
		-- SELECT DISTINCT
		-- 	Z.intTicketId
		-- 	,Z.strTicketNumber
		-- 	,IRQty = SUM(A.dblReceived)
		-- 	,TicketQty = Z.dblNetUnits
		-- FROM tblICInventoryReceiptItem A
		-- INNER JOIN tblSCTicket Z
		-- 	ON A.intSourceId = Z.intTicketId
		-- INNER JOIN tblICInventoryReceipt B
		-- 	ON A.intInventoryReceiptId = B.intInventoryReceiptId
		-- WHERE B.intSourceType = 1
		-- 	AND A.intItemId = @intItemId
		-- GROUP BY Z.intTicketId,Z.strTicketNumber,Z.dblNetUnits
		-- ) X
		-- WHERE IRQty <> TicketQty
		-- ORDER BY DIFF DESC

	SET @xhtmlBody = (SELECT (
		---Compare Ticket units vs IR units
		SELECT
			X.*
			,DIFF = IRQty - TicketQty
			,strRemark = 'Ticket Quantity is not equal to IR'
		FROM (
		SELECT DISTINCT
			Z.intTicketId
			,Z.strTicketNumber
			,IRQty = SUM(A.dblReceived)
			,TicketQty = Z.dblNetUnits
		FROM tblICInventoryReceiptItem A
		INNER JOIN tblSCTicket Z
			ON A.intSourceId = Z.intTicketId
		INNER JOIN tblICInventoryReceipt B
			ON A.intInventoryReceiptId = B.intInventoryReceiptId
		WHERE B.intSourceType = 1
			AND A.intItemId = @intItemId
		GROUP BY Z.intTicketId,Z.strTicketNumber,Z.dblNetUnits
		) X
		WHERE IRQty <> TicketQty
		ORDER BY DIFF DESC
		FOR XML PATH('row'), TYPE, ROOT('root'))
.query('<table border="1">
	<thead>
	<tr>
		<th>intTicketId</th>
		<th>strTicketNumber</th>
		<th>IRQty</th>
		<th>TicketQty</th>
		<th>DIFF</th>
		<th>strRemark</th>
	</tr>
	</thead>
	<tbody>
{
	for $row in /root/row
	return <tr>
			<td>{data($row/intTicketId)}</td>
			<td>{data($row/strTicketNumber)}</td>
			<td>{data($row/IRQty)}</td>
			<td>{data($row/TicketQty)}</td>
			<td>{data($row/DIFF)}</td>
			<td>{data($row/strRemark)}</td>
		</tr>
}
</tbody></table>'));
  SET @body = @body + ISNULL(CAST(@xhtmlBody AS NVARCHAR(MAX)), '')
 
 
		SET @intItemId = NULL
		SELECT TOP 1
			@strItemNo = strItemNo
			,@intItemId = intItemId
		FROM #tmpITM_diag_2
		WHERE strItemNo > @strItemNo
		ORDER BY strItemNo ASC
 
	END
	select '***-**********--********** End 2- IR vs TicketUnits **********--**********-***'
	SET @body = @body + '<h2>END 2 IR vs Ticket Units</h2></hr>'


	select '***-**********--********** Start 3- Check Double IR And IS **********--**********-***'
	SET @body = @body + '<h2>START 3 - Check Double IR And IS</h2>'
	BEGIN
		IF OBJECT_ID('tempdb..#tmpIS_diag_3a') IS NOT NULL DROP TABLE #tmpIS_diag_3a
 
		SELECT DISTINCT
			B.strShipmentNumber
			,Z.intTicketId
			,Z.strTicketNumber
			,B.intEntityCustomerId
		INTO #tmpIS_diag_3a
		FROM tblICInventoryShipmentItem A
		INNER JOIN tblSCTicket Z
			ON A.intSourceId = Z.intTicketId
		INNER JOIN tblICInventoryShipment B
			ON A.intInventoryShipmentId = B.intInventoryShipmentId
		LEFT JOIN tblARInvoiceDetail C
			ON A.intInventoryShipmentItemId = ISNULL(C.intInventoryShipmentItemId,0)
		LEFT JOIN tblARInvoice D
			ON ISNULL(D.intInvoiceId,0) = ISNULL(C.intInvoiceId,0)
		LEFT JOIN tblARInvoiceDetail E
			ON ISNULL(C.intInvoiceDetailId,0) = ISNULL(E.intOriginalInvoiceDetailId,0)
		WHERE B.intSourceType = 1
			AND D.strTransactionType = 'Invoice'
			AND E.intInvoiceDetailId IS NULL
		ORDER BY Z.intTicketId
 
		IF OBJECT_ID('tempdb..#tmpTKT_diag_3a') IS NOT NULL DROP TABLE #tmpTKT_diag_3a
 
		SELECT intTicketId
		INTO #tmpTKT_diag_3a
		FROM #tmpIS_diag_3a
		GROUP BY intTicketId
		HAVING COUNT(intTicketId) > 1
 
		-- SELECT DISTINCT
		-- 	Z.intTicketId
		-- 	,Z.strTicketNumber
		-- 	,B.intInventoryShipmentId
		-- 	,B.strShipmentNumber
		-- 	,strRemark = 'Ticket Have Multiple IS'
		-- FROM tblICInventoryShipmentItem A
		-- INNER JOIN tblSCTicket Z
		-- 	ON A.intSourceId = Z.intTicketId
		-- INNER JOIN tblICInventoryShipment B
		-- 	ON A.intInventoryShipmentId = B.intInventoryShipmentId
		-- LEFT JOIN tblARInvoiceDetail C
		-- 	ON A.intInventoryShipmentItemId = ISNULL(C.intInventoryShipmentItemId,0)
		-- LEFT JOIN tblARInvoice D
		-- 	ON ISNULL(D.intInvoiceId,0) = ISNULL(C.intInvoiceId,0)
		-- LEFT JOIN tblARInvoiceDetail E
		-- 	ON ISNULL(C.intInvoiceDetailId,0) = ISNULL(E.intOriginalInvoiceDetailId,0)
		-- WHERE B.intSourceType = 1
		-- 	AND D.strTransactionType = 'Invoice'
		-- 	AND E.intInvoiceDetailId IS NULL
		-- 	AND Z.intTicketId IN (SELECT intTicketId FROM #tmpTKT_diag_3a)
		-- ORDER BY Z.intTicketId

	SET @xhtmlBody = (SELECT (
		SELECT DISTINCT
			Z.intTicketId
			,Z.strTicketNumber
			,B.intInventoryShipmentId
			,B.strShipmentNumber
			,strRemark = 'Ticket Have Multiple IS'
		FROM tblICInventoryShipmentItem A
		INNER JOIN tblSCTicket Z
			ON A.intSourceId = Z.intTicketId
		INNER JOIN tblICInventoryShipment B
			ON A.intInventoryShipmentId = B.intInventoryShipmentId
		LEFT JOIN tblARInvoiceDetail C
			ON A.intInventoryShipmentItemId = ISNULL(C.intInventoryShipmentItemId,0)
		LEFT JOIN tblARInvoice D
			ON ISNULL(D.intInvoiceId,0) = ISNULL(C.intInvoiceId,0)
		LEFT JOIN tblARInvoiceDetail E
			ON ISNULL(C.intInvoiceDetailId,0) = ISNULL(E.intOriginalInvoiceDetailId,0)
		WHERE B.intSourceType = 1
			AND D.strTransactionType = 'Invoice'
			AND E.intInvoiceDetailId IS NULL
			AND Z.intTicketId IN (SELECT intTicketId FROM #tmpTKT_diag_3a)
		ORDER BY Z.intTicketId
	FOR XML PATH('row'), TYPE, ROOT('root'))
.query('<table border="1">
	<thead>
	<tr>
		<th>intTicketId</th>
		<th>strTicketNumber</th>
		<th>intInventoryShipmentId</th>
		<th>strShipmentNumber</th>
		<th>strRemark</th>
	</tr>
	</thead>
	<tbody>
{
	for $row in /root/row
	return <tr>
			<td>{data($row/intTicketId)}</td>
			<td>{data($row/strTicketNumber)}</td>
			<td>{data($row/intInventoryShipmentId)}</td>
			<td>{data($row/strShipmentNumber)}</td>
			<td>{data($row/strRemark)}</td>
		</tr>
}
</tbody></table>'));
  SET @body = @body + ISNULL(CAST(@xhtmlBody AS NVARCHAR(MAX)), '')

	END
	 
	---Check for Duplicate IR
	BEGIN
		IF OBJECT_ID('tempdb..#tmpIR_diag_3b') IS NOT NULL DROP TABLE #tmpIR_diag_3b
		SELECT DISTINCT
			Z.intTicketId
			,intEntityId = B.intEntityVendorId
			,B.intInventoryReceiptId
		INTO #tmpIR_diag_3b
		FROM tblICInventoryReceiptItem A
		INNER JOIN tblSCTicket Z
			ON A.intSourceId = Z.intTicketId
		INNER JOIN tblICInventoryReceipt B
			ON A.intInventoryReceiptId = B.intInventoryReceiptId
		WHERE B.intSourceType = 1

 
		IF OBJECT_ID('tempdb..#tmpTKT_diag_3b') IS NOT NULL DROP TABLE #tmpTKT_diag_3b
 
		SELECT
			intTicketId
		INTO #tmpTKT_diag_3b
		FROM #tmpIR_diag_3b
		GROUP BY intTicketId,intEntityId
		HAVING COUNT(intTicketId) > 1
 
		-- SELECT DISTINCT
		-- 	Z.intTicketId
		-- 	,Z.strTicketNumber
		-- 	,B.intInventoryReceiptId
		-- 	,B.strReceiptNumber
		-- 	,strRemark = 'Ticket Have Multiple IR'
		-- FROM tblICInventoryReceiptItem A
		-- INNER JOIN tblSCTicket Z
		-- 	ON A.intSourceId = Z.intTicketId
		-- INNER JOIN tblICInventoryReceipt B
		-- 	ON A.intInventoryReceiptId = B.intInventoryReceiptId
		-- INNER JOIN #tmpTKT_diag_3b X
		-- 	ON Z.intTicketId = X.intTicketId
		-- WHERE B.intSourceType = 1

	SET @xhtmlBody = (SELECT (
		SELECT DISTINCT
			Z.intTicketId
			,Z.strTicketNumber
			,B.intInventoryReceiptId
			,B.strReceiptNumber
			,strRemark = 'Ticket Have Multiple IR'
		FROM tblICInventoryReceiptItem A
		INNER JOIN tblSCTicket Z
			ON A.intSourceId = Z.intTicketId
		INNER JOIN tblICInventoryReceipt B
			ON A.intInventoryReceiptId = B.intInventoryReceiptId
		INNER JOIN #tmpTKT_diag_3b X
			ON Z.intTicketId = X.intTicketId
		WHERE B.intSourceType = 1
	FOR XML PATH('row'), TYPE, ROOT('root'))
.query('<table border="1">
	<thead>
	<tr>
		<th>intTicketId</th>
		<th>strTicketNumber</th>
		<th>intInventoryReceiptId</th>
		<th>strReceiptNumber</th>
		<th>strRemark</th>
	</tr>
	</thead>
	<tbody>
{
	for $row in /root/row
	return <tr>
			<td>{data($row/intTicketId)}</td>
			<td>{data($row/strTicketNumber)}</td>
			<td>{data($row/intInventoryReceiptId)}</td>
			<td>{data($row/strReceiptNumber)}</td>
			<td>{data($row/strRemark)}</td>
		</tr>
}
</tbody></table>'));
  SET @body = @body + ISNULL(CAST(@xhtmlBody AS NVARCHAR(MAX)), '')
     
	END


	select '***-**********--********** End 3- Check Double IR And IS **********--**********-***'
	SET @body = @body + '<h2>END 3 - Check Double IR And IS</h2></hr>'

	select '***-**********--********** Start 4- IS vs Ticket Units **********--**********-***'
	SET @body = @body + '<h2>START 4 - IS vs Ticket Units</h2>'
	begin
		select @intItemId = null, @strItemNo = ''
 
 
		IF OBJECT_ID('tempdb..#tmpITM_diag_4') IS NOT NULL DROP TABLE #tmpITM_diag_4
 
		SELECT
			strItemNo
			,intItemId
		INTO #tmpITM_diag_4
		FROM tblICItem
		WHERE intCommodityId IN (1,2,3)
			AND strType = 'Inventory'
		ORDER BY strItemNo ASC
 
		SELECT TOP 1
			@strItemNo = strItemNo
			,@intItemId = intItemId
		FROM #tmpITM_diag_4
		ORDER BY strItemNo ASC
				--SET @strItemNo = '#2 Yellow Soybeans'
				--SELECT @intItemId = intItemId FROM tblICItem WHERE strItemNo = @strItemNo
		WHILE ISNULL(@intItemId ,0) > 0
		BEGIN
			SELECT @strItemNo
			SET @body = @body + '<h3><b>' + @strItemNo + '</b></h3>'
  
		--SET @strItemNo = 'Soybean Meal GMO'
		--SELECT @intItemId = intItemId FROM tblICItem WHERE strItemNo = @strItemNo
  
  
			---Get all the IS for tickets
			IF OBJECT_ID('tempdb..#tmpTKTIS_diag_4') IS NOT NULL DROP TABLE #tmpTKTIS_diag_4
			SELECT DISTINCT
				A.intSourceId
				,B.intInventoryShipmentId
			INTO #tmpTKTIS_diag_4
			FROM tblICInventoryShipmentItem A
			INNER JOIN tblSCTicket Z
				ON A.intSourceId = Z.intTicketId
			INNER JOIN tblICInventoryShipment B
				ON A.intInventoryShipmentId = B.intInventoryShipmentId
			LEFT JOIN tblARInvoiceDetail C
				ON A.intInventoryShipmentItemId = ISNULL(C.intInventoryShipmentItemId,0)
			LEFT JOIN tblARInvoice D
				ON ISNULL(D.intInvoiceId,0) = ISNULL(C.intInvoiceId,0)
			LEFT JOIN tblARInvoiceDetail E
				ON ISNULL(C.intInvoiceDetailId,0) = ISNULL(E.intOriginalInvoiceDetailId,0)
			LEFT JOIN tblARInvoice F
				ON ISNULL(F.intInvoiceId,0) = ISNULL(E.intInvoiceId,0)
			WHERE B.intSourceType = 1
				AND A.intItemId = @intItemId
  
  
			--Get All IS with credit Memo
			IF OBJECT_ID('tempdb..#tmpISCM_diag_4') IS NOT NULL DROP TABLE #tmpISCM_diag_4
			SELECT DISTINCT
				A.intSourceId
				,B.intInventoryShipmentId
			INTO #tmpISCM_diag_4
			FROM tblICInventoryShipmentItem A
			INNER JOIN tblSCTicket Z
				ON A.intSourceId = Z.intTicketId
			INNER JOIN tblICInventoryShipment B
				ON A.intInventoryShipmentId = B.intInventoryShipmentId
			LEFT JOIN tblARInvoiceDetail C
				ON A.intInventoryShipmentItemId = ISNULL(C.intInventoryShipmentItemId,0)
			LEFT JOIN tblARInvoice D
				ON ISNULL(D.intInvoiceId,0) = ISNULL(C.intInvoiceId,0)
			LEFT JOIN tblARInvoiceDetail E
				ON ISNULL(C.intInvoiceDetailId,0) = ISNULL(E.intOriginalInvoiceDetailId,0)
			LEFT JOIN tblARInvoice F
				ON ISNULL(F.intInvoiceId,0) = ISNULL(E.intInvoiceId,0)
			WHERE B.intSourceType = 1
				AND A.intItemId = @intItemId
				AND F. strTransactionType = 'Credit Memo'
      
  
  
  
  
			--Get the difference of IS vs Ticket units
			-- SELECT
			-- 	Z.*
			-- 	,Diff = Z.ISTotal - Z.TicketTotal
			-- 	,DiffDWG = Z.ISTotalDWG - Z.TicketTotal
			-- 	,Diff = Z.ISTotal - Z.TicketTotal
			-- 	,DiffDWG = Z.ISTotalDWG - Z.TicketTotal
			-- 	--,DiffWitoutCM = Z.ISTotalWithoutCM - Z.TicketTotal
			-- 	--,DiffDWGWithoutCM = Z.ISTotalDWGWithoutCM - Z.TicketTotal
			-- FROM(
			-- 	SELECT
			-- 		TicketTotal = SUM(dblNetUnits)
			-- 		,ISTotalDWG = (SELECT SUM(ISNULL(dblDestinationQuantity,dblQuantity))
			-- 					FROM tblICInventoryShipmentItem
			-- 					WHERE intInventoryShipmentId IN (SELECT intInventoryShipmentId FROM  #tmpTKTIS_diag_4)
			-- 					AND intItemId = @intItemId)
			-- 		,ISTotal = (SELECT SUM(dblQuantity)
			-- 					FROM tblICInventoryShipmentItem
			-- 					WHERE intInventoryShipmentId IN (SELECT intInventoryShipmentId FROM  #tmpTKTIS_diag_4)
			-- 					AND intItemId = @intItemId)
			-- 		,ISTotalDWGWithoutCM = (SELECT SUM(ISNULL(dblDestinationQuantity,dblQuantity))
			-- 					FROM tblICInventoryShipmentItem
			-- 					WHERE intInventoryShipmentId IN (SELECT intInventoryShipmentId FROM  #tmpTKTIS_diag_4)
			-- 						AND intInventoryShipmentId NOT IN (SELECT intInventoryShipmentId FROM  #tmpISCM_diag_4)
			-- 					AND intItemId = @intItemId)
			-- 		,ISTotalWithoutCM = (SELECT SUM(dblQuantity)
			-- 					FROM tblICInventoryShipmentItem
			-- 					WHERE intInventoryShipmentId IN (SELECT intInventoryShipmentId FROM  #tmpTKTIS_diag_4)
			-- 						AND intInventoryShipmentId NOT IN (SELECT intInventoryShipmentId FROM  #tmpISCM_diag_4)
			-- 					AND intItemId = @intItemId)
			-- 	FROM tblSCTicket A
			-- 	WHERE A.intItemId = @intItemId
			-- 		AND A.strTicketStatus = 'C'
			-- 		AND A.intTicketType = 1
			-- 		AND A.strInOutFlag = 'O'
			-- )Z

	SET @xhtmlBody = (SELECT (
		--Get the difference of IS vs Ticket units
		SELECT
			Z.*
			,Diff = Z.ISTotal - Z.TicketTotal
			,DiffDWG = Z.ISTotalDWG - Z.TicketTotal
			-- ,Diff = Z.ISTotal - Z.TicketTotal
			-- ,DiffDWG = Z.ISTotalDWG - Z.TicketTotal
			--,DiffWitoutCM = Z.ISTotalWithoutCM - Z.TicketTotal
			--,DiffDWGWithoutCM = Z.ISTotalDWGWithoutCM - Z.TicketTotal
		FROM(
			SELECT
				TicketTotal = SUM(dblNetUnits)
				,ISTotalDWG = (SELECT SUM(ISNULL(dblDestinationQuantity,dblQuantity))
							FROM tblICInventoryShipmentItem
							WHERE intInventoryShipmentId IN (SELECT intInventoryShipmentId FROM  #tmpTKTIS_diag_4)
							AND intItemId = @intItemId)
				,ISTotal = (SELECT SUM(dblQuantity)
							FROM tblICInventoryShipmentItem
							WHERE intInventoryShipmentId IN (SELECT intInventoryShipmentId FROM  #tmpTKTIS_diag_4)
							AND intItemId = @intItemId)
				,ISTotalDWGWithoutCM = (SELECT SUM(ISNULL(dblDestinationQuantity,dblQuantity))
							FROM tblICInventoryShipmentItem
							WHERE intInventoryShipmentId IN (SELECT intInventoryShipmentId FROM  #tmpTKTIS_diag_4)
								AND intInventoryShipmentId NOT IN (SELECT intInventoryShipmentId FROM  #tmpISCM_diag_4)
							AND intItemId = @intItemId)
				,ISTotalWithoutCM = (SELECT SUM(dblQuantity)
							FROM tblICInventoryShipmentItem
							WHERE intInventoryShipmentId IN (SELECT intInventoryShipmentId FROM  #tmpTKTIS_diag_4)
								AND intInventoryShipmentId NOT IN (SELECT intInventoryShipmentId FROM  #tmpISCM_diag_4)
							AND intItemId = @intItemId)
			FROM tblSCTicket A
			WHERE A.intItemId = @intItemId
				AND A.strTicketStatus = 'C'
				AND A.intTicketType = 1
				AND A.strInOutFlag = 'O'
		)Z
	FOR XML PATH('row'), TYPE, ROOT('root'))
.query('<table border="1">
	<thead>
	<tr>
		<th>TicketTotal</th>
		<th>ISTotalDWG</th>
		<th>ISTotal</th>
		<th>ISTotalDWGWithoutCM</th>
		<th>ISTotalWithoutCM</th>
		<th>Diff</th>
		<th>DiffDWG</th>
	</tr>
	</thead>
	<tbody>
{
	for $row in /root/row
	return <tr>
			<td>{data($row/TicketTotal)}</td>
			<td>{data($row/ISTotalDWG)}</td>
			<td>{data($row/ISTotal)}</td>
			<td>{data($row/ISTotalDWGWithoutCM)}</td>
			<td>{data($row/ISTotalWithoutCM)}</td>
			<td>{data($row/Diff)}</td>
			<td>{data($row/DiffDWG)}</td>
		</tr>
}
</tbody></table>'));
  SET @body = @body + ISNULL(CAST(@xhtmlBody AS NVARCHAR(MAX)), '')
  
  
			--Get the Tickets that are Completed but dont have IS
			-- SELECT
			-- 	A.strTicketNumber
			-- 	,strRemark = 'Completed Ticket that dont have IS'
			-- FROM tblSCTicket A
			-- WHERE intTicketId NOT IN (SELECT intSourceId FROM #tmpTKTIS_diag_4)
			-- 	AND A.intItemId = @intItemId
			-- 	AND A.strTicketStatus = 'C'
			-- 	AND A.intTicketType = 1
			-- 	AND A.strInOutFlag = 'O'
			
	SET @xhtmlBody = (SELECT (
		--Get the Tickets that are Completed but dont have IS
		SELECT
			A.strTicketNumber
			,strRemark = 'Completed Ticket that dont have IS'
		FROM tblSCTicket A
		WHERE intTicketId NOT IN (SELECT intSourceId FROM #tmpTKTIS_diag_4)
			AND A.intItemId = @intItemId
			AND A.strTicketStatus = 'C'
			AND A.intTicketType = 1
			AND A.strInOutFlag = 'O'
	FOR XML PATH('row'), TYPE, ROOT('root'))
.query('<table border="1">
	<thead>
	<tr>
		<th>strTicketNumber</th>
		<th>strRemark</th>
	</tr>
	</thead>
	<tbody>
{
	for $row in /root/row
	return <tr>
			<td>{data($row/strTicketNumber)}</td>
			<td>{data($row/strRemark)}</td>
		</tr>
}
</tbody></table>'));
  SET @body = @body + ISNULL(CAST(@xhtmlBody AS NVARCHAR(MAX)), '')
  
  
			---Compare Ticket units vs IS units
			-- SELECT
			-- 	X.*
			-- 	,DIFF = ISQty - TicketQty
			-- 	,strRemark = CASE WHEN ISNULL(ysnHasCM,0) = 1 THEN 'Has IS with Credit Memo' ELSE 'Ticket Quantity is not equal to IS' END
			-- FROM (
			-- SELECT DISTINCT
			-- 	Z.intTicketId
			-- 	,Z.strTicketNumber
			-- 	,ISQty = SUM(A.dblQuantity)
			-- 	,TicketQty = Z.dblNetUnits
			-- 	,ysnHasCM = ( 
			-- 					SELECT TOP 1 1 FROM #tmpISCM_diag_4 WHERE intSourceId = Z.intTicketId
  
			-- 					--SELECT TOP 1 1
			-- 					--FROM tblICInventoryShipmentItem AA
			-- 					--INNER JOIN tblICInventoryShipment BB
			-- 					--  ON AA.intInventoryShipmentId = BB.intInventoryShipmentId
			-- 					--INNER JOIN tblARInvoiceDetail CC
			-- 					--  ON CC.intInventoryShipmentItemId = AA.intInventoryShipmentItemId
			-- 					--INNER JOIN tblARInvoiceDetail DD
			-- 					--  ON CC.intInvoiceDetailId = ISNULL(DD.intOriginalInvoiceDetailId,0)
			-- 					--WHERE AA.intItemId = @intItemId
			-- 					--  AND AA.intSourceId = Z.intTicketId
			-- 					--  AND BB.intSourceType = 1
			-- 				)
			-- FROM tblICInventoryShipmentItem A
			-- INNER JOIN tblSCTicket Z
			-- 	ON A.intSourceId = Z.intTicketId
			-- INNER JOIN tblICInventoryShipment B
			-- 	ON A.intInventoryShipmentId = B.intInventoryShipmentId
			-- WHERE A.intItemId = @intItemId
			-- 	AND B.intSourceType = 1
			-- GROUP BY Z.intTicketId,Z.strTicketNumber,Z.dblNetUnits
			-- ) X
			-- WHERE ISQty <> TicketQty
			-- ORDER BY DIFF DESC

	SET @xhtmlBody = (SELECT (
		---Compare Ticket units vs IS units
		SELECT
			X.*
			,DIFF = ISQty - TicketQty
			,strRemark = CASE WHEN ISNULL(ysnHasCM,0) = 1 THEN 'Has IS with Credit Memo' ELSE 'Ticket Quantity is not equal to IS' END
		FROM (
		SELECT DISTINCT
			Z.intTicketId
			,Z.strTicketNumber
			,ISQty = SUM(A.dblQuantity)
			,TicketQty = Z.dblNetUnits
			,ysnHasCM = ( 
							SELECT TOP 1 1 FROM #tmpISCM_diag_4 WHERE intSourceId = Z.intTicketId

							--SELECT TOP 1 1
							--FROM tblICInventoryShipmentItem AA
							--INNER JOIN tblICInventoryShipment BB
							--  ON AA.intInventoryShipmentId = BB.intInventoryShipmentId
							--INNER JOIN tblARInvoiceDetail CC
							--  ON CC.intInventoryShipmentItemId = AA.intInventoryShipmentItemId
							--INNER JOIN tblARInvoiceDetail DD
							--  ON CC.intInvoiceDetailId = ISNULL(DD.intOriginalInvoiceDetailId,0)
							--WHERE AA.intItemId = @intItemId
							--  AND AA.intSourceId = Z.intTicketId
							--  AND BB.intSourceType = 1
						)
		FROM tblICInventoryShipmentItem A
		INNER JOIN tblSCTicket Z
			ON A.intSourceId = Z.intTicketId
		INNER JOIN tblICInventoryShipment B
			ON A.intInventoryShipmentId = B.intInventoryShipmentId
		WHERE A.intItemId = @intItemId
			AND B.intSourceType = 1
		GROUP BY Z.intTicketId,Z.strTicketNumber,Z.dblNetUnits
		) X
		WHERE ISQty <> TicketQty
		ORDER BY DIFF DESC
	FOR XML PATH('row'), TYPE, ROOT('root'))
.query('<table border="1">
	<thead>
	<tr>
		<th>intTicketId</th>
		<th>strTicketNumber</th>
		<th>ISQty</th>
		<th>TicketQty</th>
		<th>ysnHasCM</th>
		<th>DIFF</th>
		<th>strRemark</th>
	</tr>
	</thead>
	<tbody>
{
	for $row in /root/row
	return <tr>
			<td>{data($row/intTicketId)}</td>
			<td>{data($row/strTicketNumber)}</td>
			<td>{data($row/ISQty)}</td>
			<td>{data($row/TicketQty)}</td>
			<td>{data($row/ysnHasCM)}</td>
			<td>{data($row/DIFF)}</td>
			<td>{data($row/strRemark)}</td>
		</tr>
}
</tbody></table>'));
  SET @body = @body + ISNULL(CAST(@xhtmlBody AS NVARCHAR(MAX)), '')
 
 
			SET @intItemId = NULL
			SELECT TOP 1
				@strItemNo = strItemNo
				,@intItemId = intItemId
			FROM #tmpITM_diag_4
			WHERE strItemNo > @strItemNo
			ORDER BY strItemNo ASC
		END

	end
	select '***-**********--********** End 4- IS vs Ticket Units **********--**********-***'
	SET @body = @body + '<h2>END 4 - IS vs Ticket Units</h2></hr>'


	select '***-**********--********** Start 5 -Ticket And IR Vs Storage **********--**********-***'
	SET @body = @body + '<h2>START 5 - Ticket And IR Vs Storage</h2>'
	IF OBJECT_ID('tempdb..#tmpTKTStorage_diag_5') IS NOT NULL DROP TABLE #tmpTKTStorage_diag_5
	BEGIN --- NON SPLIT
		--- GEt all ticket with Storage Distribution
		SELECT DISTINCT
			A.intTicketId
		INTO #tmpTKTStorage_diag_5
		FROM tblSCTicket A
		INNER JOIN tblICInventoryReceiptItem D
			ON A.intTicketId = D.intSourceId
		INNER JOIN tblICInventoryReceipt E
			ON D.intInventoryReceiptId = E.intInventoryReceiptId
		WHERE A.intTicketTypeId = 1 ----Load IN
			AND strTicketStatus = 'C'
			AND (A.intStorageScheduleTypeId > 0) AND  strDistributionOption <> 'SPL'
			AND E.intSourceType = 1
 
 
 
		--GET tickets that dont have storage record
		-- SELECT DISTINCT
		-- 	'Storage Distribution Tickets that dont have storage record'
		-- 	,A.strTicketNumber
		-- 	,A.intTicketId
		-- FROM tblSCTicket A
		-- INNER JOIN #tmpTKTStorage_diag_5 B
		-- 	ON A.intTicketId = B.intTicketId
		-- INNER JOIN tblICInventoryReceiptItem D
		-- 	ON A.intTicketId = D.intSourceId
		-- INNER JOIN tblICInventoryReceipt E
		-- 	ON D.intInventoryReceiptId = E.intInventoryReceiptId
		-- LEFT JOIN tblGRCustomerStorage C
		-- 	ON A.intTicketId = C.intTicketId
		-- 		AND A.intItemId = C.intItemId
		-- 		AND A.intEntityId = C.intEntityId
		-- 		AND A.intStorageScheduleTypeId = C.intStorageTypeId
		-- 		AND A.intStorageScheduleId = C.intStorageScheduleId
		-- WHERE A.intItemId = D.intItemId
		-- 	AND C.intCustomerStorageId IS NULL
		-- 	AND (D.intOwnershipType = 2)
		-- 	AND E.intSourceType = 1
	
	SET @xhtmlBody = (SELECT (
		--GET tickets that dont have storage record
		SELECT DISTINCT
			'Storage Distribution Tickets that dont have storage record' strDescription
			,A.strTicketNumber
			,A.intTicketId
		FROM tblSCTicket A
		INNER JOIN #tmpTKTStorage_diag_5 B
			ON A.intTicketId = B.intTicketId
		INNER JOIN tblICInventoryReceiptItem D
			ON A.intTicketId = D.intSourceId
		INNER JOIN tblICInventoryReceipt E
			ON D.intInventoryReceiptId = E.intInventoryReceiptId
		LEFT JOIN tblGRCustomerStorage C
			ON A.intTicketId = C.intTicketId
				AND A.intItemId = C.intItemId
				AND A.intEntityId = C.intEntityId
				AND A.intStorageScheduleTypeId = C.intStorageTypeId
				AND A.intStorageScheduleId = C.intStorageScheduleId
		WHERE A.intItemId = D.intItemId
			AND C.intCustomerStorageId IS NULL
			AND (D.intOwnershipType = 2)
			AND E.intSourceType = 1
	FOR XML PATH('row'), TYPE, ROOT('root'))
.query('<table border="1">
	<thead>
	<tr>
		<th>strDescription</th>
		<th>strTicketNumber</th>
		<th>intTicketId</th>
	</tr>
	</thead>
	<tbody>
{
	for $row in /root/row
	return <tr>
			<td>{data($row/strDescription)}</td>
			<td>{data($row/strTicketNumber)}</td>
			<td>{data($row/intTicketId)}</td>
		</tr>
}
</tbody></table>'));
  SET @body = @body + ISNULL(CAST(@xhtmlBody AS NVARCHAR(MAX)), '')
 
		-- SELECT
		-- 	'Storage that have different Units from IR'
		-- 	,Z.*
		-- 	,Diff = Z.IRTotal - Z.dblOriginalBalance
		-- FROM (
		-- 	SELECT
		-- 		A.strTicketNumber
		-- 		,A.intTicketId
		-- 		,C.intCustomerStorageId
		-- 		,C.dblOriginalBalance
		-- 		,E.strReceiptNumber
		-- 		,E.intInventoryReceiptId
		-- 		,IRTotal = SUM(D.dblReceived)
		-- 	FROM tblSCTicket A
		-- 	INNER JOIN #tmpTKTStorage_diag_5 B
		-- 		ON A.intTicketId = B.intTicketId
		-- 	INNER JOIN tblICInventoryReceiptItem D
		-- 		ON A.intTicketId = D.intSourceId
		-- 			AND A.intItemId = D.intItemId
		-- 	INNER JOIN tblICInventoryReceipt E
		-- 		ON D.intInventoryReceiptId = E.intInventoryReceiptId
		-- 	LEFT JOIN tblGRCustomerStorage C
		-- 		ON A.intTicketId = C.intTicketId
		-- 			AND A.intItemId = C.intItemId
		-- 			AND A.intEntityId = C.intEntityId
		-- 			AND A.intStorageScheduleTypeId = C.intStorageTypeId
		-- 			AND A.intStorageScheduleId = C.intStorageScheduleId
		-- 	WHERE A.intItemId = D.intItemId
		-- 		AND C.intCustomerStorageId IS NOT NULL
		-- 		AND (D.intOwnershipType = 2)
		-- 		AND E.intSourceType = 1
		-- 		AND (C.ysnTransferStorage = 0 OR C.ysnTransferStorage IS NULL)
		-- 	GROUP BY A.strTicketNumber
		-- 		,A.intTicketId
		-- 		,C.intCustomerStorageId
		-- 		,C.dblOriginalBalance
		-- 		,E.strReceiptNumber
		-- 		,E.intInventoryReceiptId
		-- ) Z
		-- WHERE Z.dblOriginalBalance <> Z.IRTotal
		-- ORDER by intCustomerStorageId, Diff DESC

	SET @xhtmlBody = (SELECT (
		SELECT
			'Storage that have different Units from IR' strDescription
			,Z.*
			,Diff = Z.IRTotal - Z.dblOriginalBalance
		FROM (
			SELECT
				A.strTicketNumber
				,A.intTicketId
				,C.intCustomerStorageId
				,C.dblOriginalBalance
				,E.strReceiptNumber
				,E.intInventoryReceiptId
				,IRTotal = SUM(D.dblReceived)
			FROM tblSCTicket A
			INNER JOIN #tmpTKTStorage_diag_5 B
				ON A.intTicketId = B.intTicketId
			INNER JOIN tblICInventoryReceiptItem D
				ON A.intTicketId = D.intSourceId
					AND A.intItemId = D.intItemId
			INNER JOIN tblICInventoryReceipt E
				ON D.intInventoryReceiptId = E.intInventoryReceiptId
			LEFT JOIN tblGRCustomerStorage C
				ON A.intTicketId = C.intTicketId
					AND A.intItemId = C.intItemId
					AND A.intEntityId = C.intEntityId
					AND A.intStorageScheduleTypeId = C.intStorageTypeId
					AND A.intStorageScheduleId = C.intStorageScheduleId
			WHERE A.intItemId = D.intItemId
				AND C.intCustomerStorageId IS NOT NULL
				AND (D.intOwnershipType = 2)
				AND E.intSourceType = 1
				AND (C.ysnTransferStorage = 0 OR C.ysnTransferStorage IS NULL)
			GROUP BY A.strTicketNumber
				,A.intTicketId
				,C.intCustomerStorageId
				,C.dblOriginalBalance
				,E.strReceiptNumber
				,E.intInventoryReceiptId
		) Z
		WHERE Z.dblOriginalBalance <> Z.IRTotal
		ORDER by intCustomerStorageId, Diff DESC
	FOR XML PATH('row'), TYPE, ROOT('root'))
.query('<table border="1">
	<thead>
	<tr>
		<th>strDescription</th>
		<th>strTicketNumber</th>
		<th>intTicketId</th>
		<th>intCustomerStorageId</th>
		<th>dblOriginalBalance</th>
		<th>strReceiptNumber</th>
		<th>intInventoryReceiptId</th>
		<th>IRTotal</th>
	</tr>
	</thead>
	<tbody>
{
	for $row in /root/row
	return <tr>
			<td>{data($row/strDescription)}</td>
			<td>{data($row/strTicketNumber)}</td>
			<td>{data($row/intTicketId)}</td>
			<td>{data($row/intCustomerStorageId)}</td>
			<td>{data($row/dblOriginalBalance)}</td>
			<td>{data($row/strReceiptNumber)}</td>
			<td>{data($row/intInventoryReceiptId)}</td>
			<td>{data($row/IRTotal)}</td>
		</tr>
}
</tbody></table>'));
  SET @body = @body + ISNULL(CAST(@xhtmlBody AS NVARCHAR(MAX)), '')
	END

 
	BEGIN ---SPLIT Tickets
		-- SELECT DISTINCT
		-- 	'Split-Storage Distribution Tickets that dont have storage record'
		-- 	,A.strTicketNumber
		-- 	,A.intTicketId
		-- FROM tblSCTicket A
		-- INNER JOIN tblICInventoryReceiptItem D
		-- 	ON A.intTicketId = D.intSourceId
		-- INNER JOIN tblSCTicketSplit F
		-- 	ON A.intTicketId = F.intTicketId
		-- INNER JOIN tblICInventoryReceipt E
		-- 	ON D.intInventoryReceiptId = E.intInventoryReceiptId
		-- 		AND E.intEntityVendorId = F.intCustomerId
		-- LEFT JOIN tblGRCustomerStorage C
		-- 	ON A.intTicketId = C.intTicketId
		-- 		AND A.intItemId = C.intItemId
		-- 		AND F.intCustomerId = C.intEntityId
		-- 		AND F.intStorageScheduleTypeId = C.intStorageTypeId
		-- 		AND F.intStorageScheduleId = C.intStorageScheduleId
		-- WHERE A.intTicketTypeId = 1 ----Load IN
		-- 	AND strTicketStatus = 'C'
		-- 	AND (A.intStorageScheduleTypeId = -4 OR A.strDistributionOption = 'SPL')
		-- 	AND E.intSourceType = 1
		-- 	AND F.intStorageScheduleTypeId > 0
		-- 	AND C.intCustomerStorageId IS NULL
		-- 	AND (D.intOwnershipType = 2)
		-- ORDER by intTicketId

	SET @xhtmlBody = (SELECT (
		SELECT DISTINCT
			'Split-Storage Distribution Tickets that dont have storage record' strDescription
			,A.strTicketNumber
			,A.intTicketId
		FROM tblSCTicket A
		INNER JOIN tblICInventoryReceiptItem D
			ON A.intTicketId = D.intSourceId
		INNER JOIN tblSCTicketSplit F
			ON A.intTicketId = F.intTicketId
		INNER JOIN tblICInventoryReceipt E
			ON D.intInventoryReceiptId = E.intInventoryReceiptId
				AND E.intEntityVendorId = F.intCustomerId
		LEFT JOIN tblGRCustomerStorage C
			ON A.intTicketId = C.intTicketId
				AND A.intItemId = C.intItemId
				AND F.intCustomerId = C.intEntityId
				AND F.intStorageScheduleTypeId = C.intStorageTypeId
				AND F.intStorageScheduleId = C.intStorageScheduleId
		WHERE A.intTicketTypeId = 1 ----Load IN
			AND strTicketStatus = 'C'
			AND (A.intStorageScheduleTypeId = -4 OR A.strDistributionOption = 'SPL')
			AND E.intSourceType = 1
			AND F.intStorageScheduleTypeId > 0
			AND C.intCustomerStorageId IS NULL
			AND (D.intOwnershipType = 2)
		ORDER by intTicketId
	FOR XML PATH('row'), TYPE, ROOT('root'))
.query('<table border="1">
	<thead>
	<tr>
		<th>strDescription</th>
		<th>strTicketNumber</th>
		<th>intTicketId</th>
	</tr>
	</thead>
	<tbody>
{
	for $row in /root/row
	return <tr>
			<td>{data($row/strDescription)}</td>
			<td>{data($row/strTicketNumber)}</td>
			<td>{data($row/intTicketId)}</td>
		</tr>
}
</tbody></table>'));
  SET @body = @body + ISNULL(CAST(@xhtmlBody AS NVARCHAR(MAX)), '')
 
 
		-- SELECT
		-- 	'Split-Storage that are not equal to its IR'
		-- 	,Z.*
		-- 	,Diff = Z.IRTotal - Z.dblOriginalBalance
		-- FROM (
		-- 	SELECT
		-- 		A.strTicketNumber
		-- 		,A.intTicketId
		-- 		,C.intCustomerStorageId
		-- 		,C.dblOriginalBalance
		-- 		,E.strReceiptNumber
		-- 		,E.intInventoryReceiptId
		-- 		,IRTotal = SUM(D.dblReceived)
		-- 	FROM tblSCTicket A
		-- 	INNER JOIN tblSCTicketSplit F
		-- 		ON A.intTicketId = F.intTicketId
		-- 	INNER JOIN tblICInventoryReceiptItem D
		-- 		ON A.intTicketId = D.intSourceId
		-- 			AND A.intItemId = D.intItemId
		-- 	INNER JOIN tblICInventoryReceipt E
		-- 		ON D.intInventoryReceiptId = E.intInventoryReceiptId
		-- 			AND E.intEntityVendorId = F.intCustomerId
		-- 	LEFT JOIN tblGRCustomerStorage C
		-- 		ON A.intTicketId = C.intTicketId
		-- 			AND A.intItemId = C.intItemId
		-- 			AND F.intCustomerId = C.intEntityId
		-- 			AND F.intStorageScheduleTypeId = C.intStorageTypeId
		-- 			AND F.intStorageScheduleId = C.intStorageScheduleId
		-- 	WHERE  A.intTicketTypeId = 1 ----Load IN
		-- 		AND strTicketStatus = 'C'
		-- 		AND (A.intStorageScheduleTypeId = -4 OR A.strDistributionOption = 'SPL')
		-- 		AND E.intSourceType = 1
		-- 		AND F.intStorageScheduleTypeId > 0 -- split storage distribution
		-- 		AND (D.intOwnershipType = 2)
		-- 		AND E.intSourceType = 1
		-- 		AND (C.ysnTransferStorage = 0 OR C.ysnTransferStorage IS NULL)
		-- 	GROUP BY A.strTicketNumber
		-- 		,A.intTicketId
		-- 		,C.intCustomerStorageId
		-- 		,C.dblOriginalBalance
		-- 		,E.strReceiptNumber
		-- 		,E.intInventoryReceiptId
		-- ) Z
		-- WHERE Z.dblOriginalBalance <> Z.IRTotal OR Z.intCustomerStorageId IS NULL
		-- ORDER by Diff DESC

	SET @xhtmlBody = (SELECT (
		SELECT
			'Split-Storage that are not equal to its IR' strDescription
			,Z.*
			,Diff = Z.IRTotal - Z.dblOriginalBalance
		FROM (
			SELECT
				A.strTicketNumber
				,A.intTicketId
				,C.intCustomerStorageId
				,C.dblOriginalBalance
				,E.strReceiptNumber
				,E.intInventoryReceiptId
				,IRTotal = SUM(D.dblReceived)
			FROM tblSCTicket A
			INNER JOIN tblSCTicketSplit F
				ON A.intTicketId = F.intTicketId
			INNER JOIN tblICInventoryReceiptItem D
				ON A.intTicketId = D.intSourceId
					AND A.intItemId = D.intItemId
			INNER JOIN tblICInventoryReceipt E
				ON D.intInventoryReceiptId = E.intInventoryReceiptId
					AND E.intEntityVendorId = F.intCustomerId
			LEFT JOIN tblGRCustomerStorage C
				ON A.intTicketId = C.intTicketId
					AND A.intItemId = C.intItemId
					AND F.intCustomerId = C.intEntityId
					AND F.intStorageScheduleTypeId = C.intStorageTypeId
					AND F.intStorageScheduleId = C.intStorageScheduleId
			WHERE  A.intTicketTypeId = 1 ----Load IN
				AND strTicketStatus = 'C'
				AND (A.intStorageScheduleTypeId = -4 OR A.strDistributionOption = 'SPL')
				AND E.intSourceType = 1
				AND F.intStorageScheduleTypeId > 0 -- split storage distribution
				AND (D.intOwnershipType = 2)
				AND E.intSourceType = 1
				AND (C.ysnTransferStorage = 0 OR C.ysnTransferStorage IS NULL)
			GROUP BY A.strTicketNumber
				,A.intTicketId
				,C.intCustomerStorageId
				,C.dblOriginalBalance
				,E.strReceiptNumber
				,E.intInventoryReceiptId
		) Z
		WHERE Z.dblOriginalBalance <> Z.IRTotal OR Z.intCustomerStorageId IS NULL
		ORDER by Diff DESC
	FOR XML PATH('row'), TYPE, ROOT('root'))
.query('<table border="1">
	<thead>
	<tr>
		<th>strDescription</th>
		<th>strTicketNumber</th>
		<th>intTicketId</th>
		<th>intCustomerStorageId</th>
		<th>dblOriginalBalance</th>
		<th>strReceiptNumber</th>
		<th>intInventoryReceiptId</th>
		<th>IRTotal</th>
	</tr>
	</thead>
	<tbody>
{
	for $row in /root/row
	return <tr>
			<td>{data($row/strDescription)}</td>
			<td>{data($row/strTicketNumber)}</td>
			<td>{data($row/intTicketId)}</td>
			<td>{data($row/intCustomerStorageId)}</td>
			<td>{data($row/dblOriginalBalance)}</td>
			<td>{data($row/strReceiptNumber)}</td>
			<td>{data($row/intInventoryReceiptId)}</td>
			<td>{data($row/IRTotal)}</td>
		</tr>
}
</tbody></table>'));
  SET @body = @body + ISNULL(CAST(@xhtmlBody AS NVARCHAR(MAX)), '')
 
	END
	
	select '***-**********--********** End 5 -Ticket And IR Vs Storage **********--**********-***'
	SET @body = @body + '<h2>END 5 - Ticket And IR Vs Storage</h2></hr>'

	set @body = @body + '</body></html>'

	-- Send the email 
	EXEC msdb.dbo.sp_send_dbmail
		@profile_name = @emailProfileName
		,@recipients = @emailRecipient
		,@subject = @strSubject
		,@body = @body
		,@body_format = 'HTML'
end
