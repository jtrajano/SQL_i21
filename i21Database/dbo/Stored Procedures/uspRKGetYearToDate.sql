CREATE PROC uspRKGetYearToDate
	@intEntityId INT,
	@intCommodityIds NVARCHAR(MAX),
	@dtmFrom DATE,
	@dtmTo DATE,
	@strPurchaseSales NVARCHAR(30)
AS	

DECLARE @NetValue NUMERIC(18,6),
		@PurchasedValue NUMERIC(18,6),
		@SoldValue NUMERIC(18,6),
		@PaidValue NUMERIC(18,6),
		@NetPayablesValue NUMERIC(18,6),
		@intCommodityId AS INT


IF @strPurchaseSales = 'Purchase'
BEGIN
SELECT * INTO #tmpSourcePurchase FROM (
SELECT   IR.intEntityVendorId as intEntityId
	,T.intCommodityId
	,'Paid' as FieldName
	,SUM(CASE WHEN Bill.dblTotal = Bill.dblAmountDue THEN 
		BD.dblQtyReceived
		ELSE
		(BD.dblQtyReceived/Bill.dblTotal) * (Bill.dblTotal - Bill.dblAmountDue)
	 END) as dblTotal 
	,0 as intSorting

FROM tblICInventoryReceipt IR 
INNER JOIN tblICInventoryReceiptItem INVRCPTITEM  ON INVRCPTITEM.intInventoryReceiptId = IR.intInventoryReceiptId
INNER JOIN  vyuSCGetScaleDistribution SC ON INVRCPTITEM.intInventoryReceiptItemId = SC.intInventoryReceiptItemId
INNER JOIN tblAPBillDetail BD ON BD.intInventoryReceiptItemId = INVRCPTITEM.intInventoryReceiptItemId
INNER JOIN tblAPBill Bill ON Bill.intBillId = BD.intBillId
INNER JOIN tblSCTicket T ON T.intTicketId = SC.intTicketId
LEFT JOIN tblICItem Itm ON INVRCPTITEM.intItemId = Itm.intItemId

WHERE BD.intInventoryReceiptChargeId IS NULL
AND Bill.ysnPosted = 1
AND CAST(Bill.dtmDate AS date) BETWEEN @dtmFrom AND @dtmTo
AND IR.intEntityVendorId = @intEntityId
AND T.intCommodityId IN (SELECT Item from [dbo].[fnSplitString](@intCommodityIds, ','))
GROUP BY  IR.intEntityVendorId,T.intCommodityId

UNION ALL
SELECT   IR.intEntityVendorId as intEntityId
	,T.intCommodityId
	,'Purchased' as FieldName
	, SUM(BD.dblQtyReceived) as dblTotal
	,1 as intSorting

FROM tblICInventoryReceipt IR 
INNER JOIN tblICInventoryReceiptItem INVRCPTITEM  ON INVRCPTITEM.intInventoryReceiptId = IR.intInventoryReceiptId
INNER JOIN  vyuSCGetScaleDistribution SC ON INVRCPTITEM.intInventoryReceiptItemId = SC.intInventoryReceiptItemId
INNER JOIN tblAPBillDetail BD ON BD.intInventoryReceiptItemId = INVRCPTITEM.intInventoryReceiptItemId
INNER JOIN tblAPBill Bill ON Bill.intBillId = BD.intBillId
INNER JOIN tblSCTicket T ON T.intTicketId = SC.intTicketId
LEFT JOIN tblICItem Itm ON INVRCPTITEM.intItemId = Itm.intItemId

WHERE BD.intInventoryReceiptChargeId IS NULL
AND Bill.ysnPosted = 1
AND CAST(Bill.dtmDate AS date) BETWEEN @dtmFrom AND @dtmTo
AND IR.intEntityVendorId = @intEntityId
AND T.intCommodityId IN (SELECT Item from [dbo].[fnSplitString](@intCommodityIds, ','))
GROUP BY  IR.intEntityVendorId,T.intCommodityId


UNION ALL
SELECT   IR.intEntityVendorId
	,T.intCommodityId
	,'Net' as FieldName
	, SUM(BD.dblTotal) as dblTotal
	,7 as intSorting

FROM tblICInventoryReceipt IR 
INNER JOIN tblICInventoryReceiptItem INVRCPTITEM  ON INVRCPTITEM.intInventoryReceiptId = IR.intInventoryReceiptId
INNER JOIN  vyuSCGetScaleDistribution SC ON INVRCPTITEM.intInventoryReceiptItemId = SC.intInventoryReceiptItemId
INNER JOIN tblAPBillDetail BD ON BD.intInventoryReceiptItemId = INVRCPTITEM.intInventoryReceiptItemId
INNER JOIN tblAPBill Bill ON Bill.intBillId = BD.intBillId
INNER JOIN tblSCTicket T ON T.intTicketId = SC.intTicketId
LEFT JOIN tblICItem Itm ON INVRCPTITEM.intItemId = Itm.intItemId

WHERE BD.intInventoryReceiptChargeId IS NULL
AND Bill.ysnPosted = 1
AND CAST(Bill.dtmDate AS date) BETWEEN @dtmFrom AND @dtmTo
AND IR.intEntityVendorId = @intEntityId
AND T.intCommodityId IN (SELECT Item from [dbo].[fnSplitString](@intCommodityIds, ','))
GROUP BY  IR.intEntityVendorId,T.intCommodityId

UNION ALL
SELECT   IR.intEntityVendorId
	,T.intCommodityId
	,'Tax' as FieldName
	, SUM(ISNULL(BD.dblTax,0)) as dblTotal
	,5 as intSorting

FROM tblICInventoryReceipt IR 
INNER JOIN tblICInventoryReceiptItem INVRCPTITEM  ON INVRCPTITEM.intInventoryReceiptId = IR.intInventoryReceiptId
INNER JOIN  vyuSCGetScaleDistribution SC ON INVRCPTITEM.intInventoryReceiptItemId = SC.intInventoryReceiptItemId
INNER JOIN tblAPBillDetail BD ON BD.intInventoryReceiptItemId = INVRCPTITEM.intInventoryReceiptItemId
--INNER JOIN tblAPBillDetailTax Tax on BD.intBillDetailId = Tax.intBillDetailId
INNER JOIN tblAPBill Bill ON Bill.intBillId = BD.intBillId
INNER JOIN tblSCTicket T ON T.intTicketId = SC.intTicketId
LEFT JOIN tblICItem Itm ON INVRCPTITEM.intItemId = Itm.intItemId

WHERE 
--BD.intInventoryReceiptChargeId IS NULL
--AND Tax.ysnCheckOffTax = 1
Bill.ysnPosted = 1
AND CAST(Bill.dtmDate AS date) BETWEEN @dtmFrom AND @dtmTo
AND IR.intEntityVendorId = @intEntityId
AND T.intCommodityId IN (SELECT Item from [dbo].[fnSplitString](@intCommodityIds, ','))
GROUP BY  IR.intEntityVendorId,T.intCommodityId

UNION ALL
SELECT   IR.intEntityVendorId
	,T.intCommodityId
	,'Discounts'
	, SUM(BD.dblTotal)  as dblDiscount
	,3 as intSorting

FROM tblICInventoryReceipt IR 
INNER JOIN tblICInventoryReceiptItem INVRCPTITEM  ON INVRCPTITEM.intInventoryReceiptId = IR.intInventoryReceiptId
INNER JOIN  vyuSCGetScaleDistribution SC ON INVRCPTITEM.intInventoryReceiptItemId = SC.intInventoryReceiptItemId
INNER JOIN tblAPBillDetail BD ON BD.intInventoryReceiptItemId = INVRCPTITEM.intInventoryReceiptItemId
INNER JOIN tblAPBill Bill ON Bill.intBillId = BD.intBillId
INNER JOIN tblICInventoryReceiptCharge InvCharge ON BD.intInventoryReceiptChargeId = InvCharge.intInventoryReceiptChargeId
INNER JOIN tblICItem Itm ON InvCharge.intChargeId = Itm.intItemId
INNER JOIN tblSCTicket T ON T.intTicketId = SC.intTicketId
INNER JOIN tblSCScaleSetup SS ON T.intScaleSetupId = SS.intScaleSetupId

WHERE BD.intInventoryReceiptChargeId IS NOT NULL
AND Bill.ysnPosted = 1
AND Itm.strCostType = 'Discount'
AND Itm.intItemId <> SS.intDefaultFeeItemId
AND CAST(Bill.dtmDate AS date) BETWEEN @dtmFrom AND @dtmTo
AND IR.intEntityVendorId = @intEntityId
AND T.intCommodityId IN (SELECT Item from [dbo].[fnSplitString](@intCommodityIds, ','))
GROUP BY  IR.intEntityVendorId,T.intCommodityId

UNION ALL
SELECT  IR.intEntityVendorId
		,T.intCommodityId
		,'Fees'
		,SUM(BD.dblTotal) as dblFees
		,6 as intSorting

FROM tblICInventoryReceipt IR 
INNER JOIN tblICInventoryReceiptItem INVRCPTITEM  ON INVRCPTITEM.intInventoryReceiptId = IR.intInventoryReceiptId
INNER JOIN  vyuSCGetScaleDistribution SC ON INVRCPTITEM.intInventoryReceiptItemId = SC.intInventoryReceiptItemId
INNER JOIN tblAPBillDetail BD ON BD.intInventoryReceiptItemId = INVRCPTITEM.intInventoryReceiptItemId
INNER JOIN tblAPBill Bill ON Bill.intBillId = BD.intBillId
INNER JOIN tblICInventoryReceiptCharge InvCharge ON BD.intInventoryReceiptChargeId = InvCharge.intInventoryReceiptChargeId
INNER JOIN tblICItem Itm ON InvCharge.intChargeId = Itm.intItemId
INNER JOIN tblSCTicket T ON T.intTicketId = SC.intTicketId
INNER JOIN tblSCScaleSetup SS ON T.intScaleSetupId = SS.intScaleSetupId

WHERE BD.intInventoryReceiptChargeId IS NOT NULL
AND Bill.ysnPosted = 1
AND Itm.strCostType = 'Other Charges'
AND Itm.intItemId = SS.intDefaultFeeItemId 
AND CAST(Bill.dtmDate AS date) BETWEEN @dtmFrom AND @dtmTo
AND IR.intEntityVendorId = @intEntityId
AND T.intCommodityId IN (SELECT Item from [dbo].[fnSplitString](@intCommodityIds, ','))
GROUP BY
IR.intEntityVendorId,T.intCommodityId

UNION ALL
SELECT   IR.intEntityVendorId
		,T.intCommodityId
		,Itm.strItemNo
		,SUM(BD.dblTotal) as dblTotal
		,9 as intSorting

FROM tblICInventoryReceipt IR 
INNER JOIN tblICInventoryReceiptItem INVRCPTITEM  ON INVRCPTITEM.intInventoryReceiptId = IR.intInventoryReceiptId
INNER JOIN  vyuSCGetScaleDistribution SC ON INVRCPTITEM.intInventoryReceiptItemId = SC.intInventoryReceiptItemId
INNER JOIN tblAPBillDetail BD ON BD.intInventoryReceiptItemId = INVRCPTITEM.intInventoryReceiptItemId
INNER JOIN tblAPBill Bill ON Bill.intBillId = BD.intBillId
INNER JOIN tblICInventoryReceiptCharge InvCharge ON BD.intInventoryReceiptChargeId = InvCharge.intInventoryReceiptChargeId
INNER JOIN tblICItem Itm ON InvCharge.intChargeId = Itm.intItemId
INNER JOIN tblSCTicket T ON T.intTicketId = SC.intTicketId
INNER JOIN tblSCScaleSetup SS ON T.intScaleSetupId = SS.intScaleSetupId

WHERE BD.intInventoryReceiptChargeId IS NOT NULL
AND Bill.ysnPosted = 1
AND Itm.strCostType <> 'Discount'
AND BD.intItemId <> SS.intDefaultFeeItemId
AND CAST(Bill.dtmDate AS date) BETWEEN @dtmFrom AND @dtmTo
AND IR.intEntityVendorId = @intEntityId
AND T.intCommodityId IN (SELECT Item from [dbo].[fnSplitString](@intCommodityIds, ','))
GROUP BY
IR.intEntityVendorId
,Itm.strItemNo
,T.intCommodityId

UNION ALL
SELECT   T.intEntityId as intEntityVendorId
		,T.intCommodityId
		,'Storage'
		,SUM(ISNULL(ID.dblTotal,0)) as dblTotal
		,4 as intSorting

FROM 
vyuSCGetScaleDistribution SC 
INNER JOIN tblSCTicket T ON T.intTicketId = SC.intTicketId
INNER JOIN tblGRCustomerStorage CS ON SC.intTicketId = CS.intTicketId
INNER JOIN tblARInvoiceDetail ID ON CS.intCustomerStorageId =  ID.intCustomerStorageId
INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId
WHERE I.ysnPosted = 1
AND CAST(T.dtmTicketDateTime AS date) BETWEEN @dtmFrom AND @dtmTo
AND T.intEntityId = @intEntityId
AND T.intCommodityId IN (SELECT Item from [dbo].[fnSplitString](@intCommodityIds, ','))
GROUP BY
T.intEntityId
,T.intCommodityId

) src


--Add the columns with 0 value if there are no records found.
--This is to make sure we are still returning the columns
SELECT * INTO #tmpCommodityIdPurchase
FROM [dbo].[fnSplitString](@intCommodityIds, ',')
WHILE EXISTS (SELECT * FROM #tmpCommodityIdPurchase)
BEGIN
	SELECT TOP 1 @intCommodityId = Item FROM #tmpCommodityIdPurchase
	IF @intCommodityId <> 0 
	BEGIN

		IF NOT EXISTS (SELECT TOP 1 * FROM #tmpSourcePurchase WHERE FieldName = 'Discounts' AND intCommodityId = @intCommodityId)
		BEGIN
			INSERT INTO #tmpSourcePurchase (intEntityId,intCommodityId,FieldName,dblTotal,intSorting)
			VALUES(@intEntityId,@intCommodityId,'Discounts',0,3)
		END

		IF NOT EXISTS (SELECT TOP 1 * FROM #tmpSourcePurchase WHERE FieldName = 'Storage'  AND intCommodityId = @intCommodityId)
		BEGIN
			INSERT INTO #tmpSourcePurchase (intEntityId,intCommodityId,FieldName,dblTotal,intSorting)
			VALUES(@intEntityId,@intCommodityId,'Storage',0,4)
		END

		
		IF NOT EXISTS (SELECT TOP 1 * FROM #tmpSourcePurchase WHERE FieldName = 'Tax' AND intCommodityId = @intCommodityId)
		BEGIN
			INSERT INTO #tmpSourcePurchase (intEntityId,intCommodityId,FieldName,dblTotal,intSorting)
			VALUES(@intEntityId,@intCommodityId,'Tax',0,5)
		END

		IF NOT EXISTS (SELECT TOP 1 * FROM #tmpSourcePurchase WHERE FieldName = 'Fees' AND intCommodityId = @intCommodityId)
		BEGIN
			INSERT INTO #tmpSourcePurchase (intEntityId,intCommodityId,FieldName,dblTotal,intSorting	)
			VALUES(@intEntityId,@intCommodityId,'Fees',0,6)
		END

		INSERT INTO #tmpSourcePurchase (intEntityId,intCommodityId,FieldName,dblTotal,intSorting)
		VALUES(@intEntityId,@intCommodityId,'Gross Dollars',(SELECT SUM(dblTotal) FROM #tmpSourcePurchase WHERE FieldName IN  ('Net','Discounts','Tax','Storage','Fees') AND intCommodityId = @intCommodityId),2)

		SELECT @NetValue = dblTotal FROM #tmpSourcePurchase WHERE FieldName = 'Net' AND intCommodityId = @intCommodityId
		SELECT @PurchasedValue = dblTotal FROM #tmpSourcePurchase WHERE FieldName = 'Purchased' AND intCommodityId = @intCommodityId
		SELECT @PaidValue = dblTotal FROM #tmpSourcePurchase WHERE FieldName = 'Paid' AND intCommodityId = @intCommodityId
		SET @NetPayablesValue = (SELECT SUM(dblTotal) FROM #tmpSourcePurchase WHERE FieldName NOT IN ('Purchased','Paid','W.A.P','Gross Dollars','Discounts','Tax','Storage','Fees') AND intCommodityId = @intCommodityId)
	
		INSERT INTO #tmpSourcePurchase (intEntityId,intCommodityId,FieldName,dblTotal,intSorting)
		VALUES(@intEntityId,@intCommodityId,'W.A.P',@NetValue/@PurchasedValue,8)

		INSERT INTO #tmpSourcePurchase (intEntityId,intCommodityId,FieldName,dblTotal,intSorting)
		VALUES(@intEntityId,@intCommodityId,'Net Payables',@NetPayablesValue,99)
	
		INSERT INTO #tmpSourcePurchase (intEntityId,intCommodityId,FieldName,dblTotal,intSorting)
		VALUES(@intEntityId,@intCommodityId,'Unpaid Qty',ABS(@PurchasedValue - @PaidValue),100)

	END
	DELETE FROM #tmpCommodityIdPurchase WHERE Item = @intCommodityId
END

select 
	 CONVERT(INT,ROW_NUMBER() OVER(ORDER BY t.intEntityId ASC)) AS intRowNumber 
	,t.intEntityId
	,t.intCommodityId
	,c.strCommodityCode
	,t.FieldName
	,t.dblTotal 
from #tmpSourcePurchase t
inner join tblICCommodity c on t.intCommodityId = c.intCommodityId
where FieldName NOT IN('Paid') 
and isnull(dblTotal,0) != 0 --Remove all the fields that has 0 value
order by intSorting

END
--===================================
--			SALES
--===================================
ELSE
SELECT * INTO #tmpSourceSales FROM (
SELECT    InvShp.intEntityCustomerId as intEntityId
	,T.intCommodityId
	,'Paid' as FieldName
	,SUM(CASE WHEN I.dblInvoiceTotal = I.dblPayment THEN 
		ID.dblQtyShipped
		ELSE
		(ID.dblQtyShipped/I.dblInvoiceTotal) *  I.dblPayment
	 END) as dblTotal 
	,0 as intSorting

FROM tblICInventoryShipment InvShp 
INNER JOIN tblICInventoryShipmentItem InvShpItm  ON InvShpItm.intInventoryShipmentId = InvShp.intInventoryShipmentId
INNER JOIN tblSCTicket T ON T.intTicketId = InvShpItm.intSourceId
INNER JOIN tblARInvoiceDetail ID ON ID.intInventoryShipmentItemId = InvShpItm.intInventoryShipmentItemId
INNER JOIN tblARInvoice I ON I.intInvoiceId = ID.intInvoiceId
LEFT JOIN tblICItem Itm ON InvShpItm.intItemId = Itm.intItemId

WHERE ID.intInventoryShipmentChargeId IS NULL
AND I.ysnPosted = 1
AND CAST(I.dtmDate AS date) BETWEEN @dtmFrom AND @dtmTo
AND InvShp.intEntityCustomerId = @intEntityId
AND T.intCommodityId IN (SELECT Item from [dbo].[fnSplitString](@intCommodityIds, ','))
GROUP BY  InvShp.intEntityCustomerId,T.intCommodityId

UNION ALL
SELECT  InvShp.intEntityCustomerId as intEntityId
	,T.intCommodityId
	,'Sold' as FieldName
	,SUM(ID.dblQtyShipped) as dblTotal
	,1 as intSorting

FROM tblICInventoryShipment InvShp 
INNER JOIN tblICInventoryShipmentItem InvShpItm  ON InvShpItm.intInventoryShipmentId = InvShp.intInventoryShipmentId
INNER JOIN tblSCTicket T ON T.intTicketId = InvShpItm.intSourceId
INNER JOIN tblARInvoiceDetail ID ON ID.intInventoryShipmentItemId = InvShpItm.intInventoryShipmentItemId
INNER JOIN tblARInvoice I ON I.intInvoiceId = ID.intInvoiceId
LEFT JOIN tblICItem Itm ON InvShpItm.intItemId = Itm.intItemId

WHERE ID.intInventoryShipmentChargeId IS NULL
AND I.ysnPosted = 1
AND CAST(I.dtmDate AS date) BETWEEN @dtmFrom AND @dtmTo
AND InvShp.intEntityCustomerId = @intEntityId
AND T.intCommodityId IN (SELECT Item from [dbo].[fnSplitString](@intCommodityIds, ','))
GROUP BY  InvShp.intEntityCustomerId,T.intCommodityId


UNION ALL
SELECT   InvShp.intEntityCustomerId as intEntityId
	,T.intCommodityId
	,'Net' as FieldName
	, SUM(ID.dblTotal) as dblTotal
	,7 as intSorting

FROM tblICInventoryShipment InvShp 
INNER JOIN tblICInventoryShipmentItem InvShpItm  ON InvShpItm.intInventoryShipmentId = InvShp.intInventoryShipmentId
INNER JOIN tblSCTicket T ON T.intTicketId = InvShpItm.intSourceId
INNER JOIN tblARInvoiceDetail ID ON ID.intInventoryShipmentItemId = InvShpItm.intInventoryShipmentItemId
INNER JOIN tblARInvoice I ON I.intInvoiceId = ID.intInvoiceId
LEFT JOIN tblICItem Itm ON InvShpItm.intItemId = Itm.intItemId

WHERE ID.intInventoryShipmentChargeId IS NULL
AND I.ysnPosted = 1
AND CAST(I.dtmDate AS date) BETWEEN @dtmFrom AND @dtmTo
AND InvShp.intEntityCustomerId = @intEntityId
AND T.intCommodityId IN (SELECT Item from [dbo].[fnSplitString](@intCommodityIds, ','))
GROUP BY  InvShp.intEntityCustomerId,T.intCommodityId

UNION ALL
SELECT  InvShp.intEntityCustomerId as intEntityId
	,T.intCommodityId
	,'Tax' as FieldName
	, SUM(I.dblTax) as dblTotal
	,5 as intSorting

FROM tblICInventoryShipment InvShp 
INNER JOIN tblICInventoryShipmentItem InvShpItm  ON InvShpItm.intInventoryShipmentId = InvShp.intInventoryShipmentId
INNER JOIN tblSCTicket T ON T.intTicketId = InvShpItm.intSourceId
INNER JOIN tblARInvoiceDetail ID ON ID.intInventoryShipmentItemId = InvShpItm.intInventoryShipmentItemId
INNER JOIN tblARInvoice I ON I.intInvoiceId = ID.intInvoiceId
LEFT JOIN tblICItem Itm ON InvShpItm.intItemId = Itm.intItemId

WHERE ID.intInventoryShipmentChargeId IS NULL
AND I.ysnPosted = 1
AND CAST(I.dtmDate AS date) BETWEEN @dtmFrom AND @dtmTo
AND InvShp.intEntityCustomerId = @intEntityId
AND T.intCommodityId IN (SELECT Item from [dbo].[fnSplitString](@intCommodityIds, ','))
GROUP BY  InvShp.intEntityCustomerId,T.intCommodityId

UNION ALL
SELECT  InvShp.intEntityCustomerId as intEntityId
	,T.intCommodityId
	,'Discounts'
	, SUM(ID.dblTotal)  as dblDiscount
	,3 as intSorting

FROM tblICInventoryShipment InvShp 
INNER JOIN tblICInventoryShipmentCharge ShpCharge ON InvShp.intInventoryShipmentId = ShpCharge.intInventoryShipmentId
INNER JOIN tblICInventoryShipmentItem InvShpItm  ON InvShpItm.intInventoryShipmentId = InvShp.intInventoryShipmentId
INNER JOIN tblSCTicket T ON T.intTicketId = InvShpItm.intSourceId
INNER JOIN tblARInvoiceDetail ID ON ID.intInventoryShipmentChargeId = ShpCharge.intInventoryShipmentChargeId
INNER JOIN tblARInvoice I ON I.intInvoiceId = ID.intInvoiceId
INNER JOIN tblICItem Itm ON ShpCharge.intChargeId = Itm.intItemId
INNER JOIN tblSCScaleSetup SS ON T.intScaleSetupId = SS.intScaleSetupId

WHERE ID.intInventoryShipmentChargeId IS NOT NULL
AND I.ysnPosted = 1
AND Itm.strCostType = 'Discount'
AND Itm.intItemId <> SS.intDefaultFeeItemId
AND CAST(I.dtmDate AS date) BETWEEN @dtmFrom AND @dtmTo
AND InvShp.intEntityCustomerId = @intEntityId
AND T.intCommodityId IN (SELECT Item from [dbo].[fnSplitString](@intCommodityIds, ','))
GROUP BY  InvShp.intEntityCustomerId,T.intCommodityId

UNION ALL
SELECT  InvShp.intEntityCustomerId as intEntityId
		,T.intCommodityId
		,'Fees'
		,SUM(ID.dblTotal) as dblFees
		,6 as intSorting

FROM tblICInventoryShipment InvShp 
INNER JOIN tblICInventoryShipmentCharge ShpCharge ON InvShp.intInventoryShipmentId = ShpCharge.intInventoryShipmentId
INNER JOIN tblICInventoryShipmentItem InvShpItm  ON InvShpItm.intInventoryShipmentId = InvShp.intInventoryShipmentId
INNER JOIN tblSCTicket T ON T.intTicketId = InvShpItm.intSourceId
INNER JOIN tblARInvoiceDetail ID ON ID.intInventoryShipmentChargeId = ShpCharge.intInventoryShipmentChargeId
INNER JOIN tblARInvoice I ON I.intInvoiceId = ID.intInvoiceId
INNER JOIN tblICItem Itm ON ShpCharge.intChargeId = Itm.intItemId
INNER JOIN tblSCScaleSetup SS ON T.intScaleSetupId = SS.intScaleSetupId

WHERE ID.intInventoryShipmentChargeId IS NOT NULL
AND I.ysnPosted = 1
AND Itm.strCostType = 'Other Charges'
AND Itm.intItemId = SS.intDefaultFeeItemId 
AND CAST(I.dtmDate AS date) BETWEEN @dtmFrom AND @dtmTo
AND InvShp.intEntityCustomerId = @intEntityId
AND T.intCommodityId IN (SELECT Item from [dbo].[fnSplitString](@intCommodityIds, ','))
GROUP BY  InvShp.intEntityCustomerId,T.intCommodityId

UNION ALL
SELECT   InvShp.intEntityCustomerId as intEntityId
		,T.intCommodityId
		,Itm.strItemNo
		,SUM(ID.dblTotal) as dblTotal
		,9 as intSorting

FROM tblICInventoryShipment InvShp 
INNER JOIN tblICInventoryShipmentCharge ShpCharge ON InvShp.intInventoryShipmentId = ShpCharge.intInventoryShipmentId
INNER JOIN tblICInventoryShipmentItem InvShpItm  ON InvShpItm.intInventoryShipmentId = InvShp.intInventoryShipmentId
INNER JOIN tblSCTicket T ON T.intTicketId = InvShpItm.intSourceId
INNER JOIN tblARInvoiceDetail ID ON ID.intInventoryShipmentChargeId = ShpCharge.intInventoryShipmentChargeId
INNER JOIN tblARInvoice I ON I.intInvoiceId = ID.intInvoiceId
INNER JOIN tblICItem Itm ON ShpCharge.intChargeId = Itm.intItemId
INNER JOIN tblSCScaleSetup SS ON T.intScaleSetupId = SS.intScaleSetupId

WHERE ID.intInventoryShipmentChargeId IS NOT NULL
AND I.ysnPosted = 1
AND Itm.strCostType <> 'Discount'
AND ID.intItemId <> SS.intDefaultFeeItemId
AND InvShp.intEntityCustomerId = @intEntityId
AND T.intCommodityId IN (SELECT Item from [dbo].[fnSplitString](@intCommodityIds, ','))
GROUP BY  InvShp.intEntityCustomerId,T.intCommodityId,Itm.strItemNo

--No Storage yet for Sales
--UNION ALL
--SELECT   T.intEntityId as intEntityVendorId
--		,T.intCommodityId
--		,'Storage'
--		,SUM(ISNULL(ID.dblTotal,0)) as dblTotal
--		,4 as intSorting

--FROM 
--vyuSCGetScaleDistribution SC 
--INNER JOIN tblSCTicket T ON T.intTicketId = SC.intTicketId
--INNER JOIN tblGRCustomerStorage CS ON SC.intTicketId = CS.intTicketId
--INNER JOIN tblARInvoiceDetail ID ON CS.intCustomerStorageId =  ID.intCustomerStorageId
--INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId
--WHERE I.ysnPosted = 1
--AND CAST(T.dtmTicketDateTime AS date) BETWEEN @dtmFrom AND @dtmTo
--AND T.intEntityId = @intEntityId
--AND T.intCommodityId IN (SELECT Item from [dbo].[fnSplitString](@intCommodityIds, ','))
--GROUP BY
--T.intEntityId
--,T.intCommodityId

) src


--Add the columns with 0 value if there are no records found.
--This is to make sure we are still returning the columns
SELECT * INTO #tmpCommodityIdSales
FROM [dbo].[fnSplitString](@intCommodityIds, ',')
WHILE EXISTS (SELECT * FROM #tmpCommodityIdSales)
BEGIN
	SELECT TOP 1 @intCommodityId = Item FROM #tmpCommodityIdSales
	IF @intCommodityId <> 0 
	BEGIN

		IF NOT EXISTS (SELECT TOP 1 * FROM #tmpSourceSales WHERE FieldName = 'Discounts' AND intCommodityId = @intCommodityId)
		BEGIN
			INSERT INTO #tmpSourceSales (intEntityId,intCommodityId,FieldName,dblTotal,intSorting)
			VALUES(@intEntityId,@intCommodityId,'Discounts',0,3)
		END

		IF NOT EXISTS (SELECT TOP 1 * FROM #tmpSourceSales WHERE FieldName = 'Storage'  AND intCommodityId = @intCommodityId)
		BEGIN
			INSERT INTO #tmpSourceSales (intEntityId,intCommodityId,FieldName,dblTotal,intSorting)
			VALUES(@intEntityId,@intCommodityId,'Storage',0,4)
		END

		
		IF NOT EXISTS (SELECT TOP 1 * FROM #tmpSourceSales WHERE FieldName = 'Tax' AND intCommodityId = @intCommodityId)
		BEGIN
			INSERT INTO #tmpSourceSales (intEntityId,intCommodityId,FieldName,dblTotal,intSorting)
			VALUES(@intEntityId,@intCommodityId,'Tax',0,5)
		END

		IF NOT EXISTS (SELECT TOP 1 * FROM #tmpSourceSales WHERE FieldName = 'Fees' AND intCommodityId = @intCommodityId)
		BEGIN
			INSERT INTO #tmpSourceSales (intEntityId,intCommodityId,FieldName,dblTotal,intSorting	)
			VALUES(@intEntityId,@intCommodityId,'Fees',0,6)
		END


		INSERT INTO #tmpSourceSales (intEntityId,intCommodityId,FieldName,dblTotal,intSorting)
		VALUES(@intEntityId,@intCommodityId,'Gross Dollars',(SELECT SUM(dblTotal) FROM #tmpSourceSales WHERE FieldName IN  ('Net','Discounts','Tax','Storage','Fees') AND intCommodityId = @intCommodityId),2)

		SELECT @NetValue = dblTotal FROM #tmpSourceSales WHERE FieldName = 'Net' AND intCommodityId = @intCommodityId
		SELECT @SoldValue = dblTotal FROM #tmpSourceSales WHERE FieldName = 'Sold' AND intCommodityId = @intCommodityId
		SELECT @PaidValue = dblTotal FROM #tmpSourceSales WHERE FieldName = 'Paid' AND intCommodityId = @intCommodityId
		SET @NetPayablesValue = (SELECT SUM(dblTotal) FROM #tmpSourceSales WHERE FieldName NOT IN ('Sold','Paid','W.A.P','Gross Dollars','Discounts','Tax','Storage','Fees') AND intCommodityId = @intCommodityId)
	
		INSERT INTO #tmpSourceSales (intEntityId,intCommodityId,FieldName,dblTotal,intSorting)
		VALUES(@intEntityId,@intCommodityId,'W.A.P',@NetValue/@SoldValue,8)

		INSERT INTO #tmpSourceSales (intEntityId,intCommodityId,FieldName,dblTotal,intSorting)
		VALUES(@intEntityId,@intCommodityId,'Net Payables',@NetPayablesValue,99)
	
		INSERT INTO #tmpSourceSales (intEntityId,intCommodityId,FieldName,dblTotal,intSorting)
		VALUES(@intEntityId,@intCommodityId,'Unpaid Qty',ABS(@SoldValue - @PaidValue),100)


	END
	DELETE FROM #tmpCommodityIdSales WHERE Item = @intCommodityId
END


select 
	 CONVERT(INT,ROW_NUMBER() OVER(ORDER BY t.intEntityId ASC)) AS intRowNumber 
	,t.intEntityId
	,t.intCommodityId
	,c.strCommodityCode
	,t.FieldName
	,t.dblTotal 
from #tmpSourceSales t
inner join tblICCommodity c on t.intCommodityId = c.intCommodityId
where FieldName NOT IN('Paid') 
and isnull(dblTotal,0) != 0 --Remove all the fields that has 0 value
order by intSorting

