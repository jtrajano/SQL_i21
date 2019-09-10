CREATE PROCEDURE [dbo].[uspIPStockVarianceEmailMessage]
AS
DECLARE @strStyle NVARCHAR(MAX)
	,@strHtml NVARCHAR(MAX)
	,@strHeader NVARCHAR(MAX)
	,@strDetail NVARCHAR(MAX) = ''
	,@strMessage NVARCHAR(MAX)

SET @strStyle = '<style type="text/css" scoped> 
table.GeneratedTable { 
width:80%; 
background-color:#FFFFFF; 
border-collapse:collapse;border-width:1px; 
border-color:#000000; 
border-style:solid; 
color:#000000; 
} 

table.GeneratedTable td { 
border-width:1px; 
border-color:#000000; 
border-style:solid; 
padding:3px; 
} 

table.GeneratedTable th { 
border-width:1px; 
border-color:#000000; 
border-style:solid; 
background-color:yellow; 
padding:3px; 
} 

table.GeneratedTable thead { 
background-color:#FFFFFF; 
} 
</style>'
SET @strHtml = '<html> 
<body> 

<table class="GeneratedTable"> 
<tbody> 
@header 
@detail 
</tbody> 
</table> 

</body> 
</html>'

BEGIN
	IF OBJECT_ID('tempdb..#i21Inventory') IS NOT NULL
		DROP TABLE #i21Inventory

	IF OBJECT_ID('tempdb..#i21Integration') IS NOT NULL
		DROP TABLE #i21Integration

	IF OBJECT_ID('tempdb..#i21InventoryReceipt') IS NOT NULL
		DROP TABLE #i21InventoryReceipt

	IF OBJECT_ID('tempdb..#i21Integration2') IS NOT NULL
		DROP TABLE #i21Integration2

	IF OBJECT_ID('tempdb..#i21FinalIntegration') IS NOT NULL
		DROP TABLE #i21FinalIntegration

	IF OBJECT_ID('tempdb..#StageStock') IS NOT NULL
		DROP TABLE #StageStock

	DECLARE @dtmDate DATETIME

	SELECT @dtmDate = Convert(DATETIME, Convert(CHAR, Getdate(), 101))

	SELECT I.strItemNo
		,I.strDescription
		,SUM(dblOnHand) dblQty
		,UM.strUnitMeasure
	INTO #i21Inventory
	FROM tblICItemStockUOM SU
	JOIN tblICItemUOM IU ON IU.intItemId = SU.intItemId
		AND SU.intItemUOMId = IU.intItemUOMId
		AND IU.ysnStockUnit = 1
	JOIN tblICItem I ON I.intItemId = SU.intItemId
	JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	GROUP BY I.strItemNo
		,I.strDescription
		,UM.strUnitMeasure

	SELECT Max(WB.intStageStockId) intStageStockId
	INTO #StageStock
	FROM tblIPStockArchive WB
	WHERE Convert(DATETIME, Convert(CHAR, WB.dtmTransactionDate, 101)) = @dtmDate
		AND WB.strStockType = 'WB'
	GROUP BY WB.strItemNo
		,WB.strSubLocation

	SELECT WB.strItemNo
		,suM((
				CASE 
					WHEN WB.dblUnrestrictedQuantity = WB.dblQuantity
						THEN WB.dblQuantity + WB.dblInTransitQuantity + WB.dblInspectionQuantity + WB.dblBlockedQuantity
					ELSE WB.dblQuantity + WB.dblInTransitQuantity + WB.dblBlockedQuantity
					END
				)) dblQty
	INTO #i21Integration
	FROM tblIPStockArchive WB
	JOIN #StageStock SS ON SS.intStageStockId = WB.intStageStockId
	GROUP BY WB.strItemNo

	SELECT WB.strItemNo
		,suM(IsNULL(LK.dblQuantity, 0)) dblQty
	INTO #i21Integration2
	FROM tblIPStockArchive WB
	LEFT JOIN tblIPStockArchive LK ON WB.strSessionId = LK.strSessionId
		AND LK.strStockType = 'LK'
	JOIN #StageStock SS ON SS.intStageStockId = WB.intStageStockId
	GROUP BY WB.strItemNo

	SELECT a.strItemNo
		,sum(a.dblQty + b.dblQty) dblQty
	INTO #i21FinalIntegration
	FROM #i21Integration a
	LEFT JOIN #i21Integration2 b ON a.strItemNo = b.strItemNo
	GROUP BY a.strItemNo

	SELECT I.strItemNo
		,SUM(RI.dblNet) AS dblNet
	INTO #i21InventoryReceipt
	FROM tblICInventoryReceipt IR
	JOIN tblICInventoryReceiptItem RI ON IR.intInventoryReceiptId = RI.intInventoryReceiptId
		AND IR.ysnPosted = 1
	JOIN tblICItem I ON I.intItemId = RI.intItemId
		AND dtmReceiptDate = @dtmDate
		AND strReceiptType <> 'Inventory Return'
	GROUP BY I.strItemNo

	--SELECT I.* 
	-- ,i21I.dblQty AS dblFeedQty 
	-- ,IsNULL(IR.dblNet, 0) AS dblIRQty 
	-- ,(I.dblQty - (IsNULL(i21I.dblQty, 0) + IsNULL(IR.dblNet, 0))) AS dblDiff 
	--FROM #i21Inventory I 
	--LEFT JOIN #i21FinalIntegration i21I ON i21I.strItemNo = I.strItemNo 
	--LEFT JOIN #i21InventoryReceipt IR ON IR.strItemNo = I.strItemNo 
	--WHERE I.dblQty <> (IsNULL(i21I.dblQty, 0) + IsNULL(IR.dblNet, 0)) 
	--ORDER BY I.strItemNo 
	SET @strHeader = '<tr> 
<th>&nbsp;Item No</th> 
<th>&nbsp;Description</th> 
<th>&nbsp;i21 Qty</th> 
<th>&nbsp;UOM</th> 
<th>&nbsp;Feed Qty</th> 
<th>&nbsp;IR Qty</th> 
<th>&nbsp;Difference</th> 
</tr>'

	SELECT @strDetail = @strDetail + '<tr> 
<td>&nbsp;' + ISNULL(I.strItemNo, '') + '</td>' + '<td>&nbsp;' + ISNULL(I.strDescription, '') + '</td>' + '<td>&nbsp;' + ISNULL(CONVERT(VARCHAR, I.dblQty), '') + '</td>' + '<td>&nbsp;' + ISNULL(I.strUnitMeasure, '') + '</td>' + '<td>&nbsp;' + ISNULL(CONVERT(VARCHAR, i21I.dblQty), '') + '</td>' + '<td>&nbsp;' + ISNULL(CONVERT(VARCHAR, IsNULL(IR.dblNet, 0)), '') + '</td>' + '<td>&nbsp;' + ISNULL(CONVERT(VARCHAR, (I.dblQty - (IsNULL(i21I.dblQty, 0) + IsNULL(IR.dblNet, 0)))), '') + '</td> 
</tr>'
	FROM #i21Inventory I
	LEFT JOIN #i21FinalIntegration i21I ON i21I.strItemNo = I.strItemNo
	LEFT JOIN #i21InventoryReceipt IR ON IR.strItemNo = I.strItemNo
	WHERE I.dblQty <> (IsNULL(i21I.dblQty, 0) + IsNULL(IR.dblNet, 0))
	ORDER BY I.strItemNo
END

SET @strHtml = REPLACE(@strHtml, '@header', @strHeader)
SET @strHtml = REPLACE(@strHtml, '@detail', @strDetail)
SET @strMessage = @strStyle + @strHtml

--IF ISNULL(@strDetail, '') = '' 
-- SET @strMessage = '' 
SELECT @strMessage AS strMessage
