CREATE PROCEDURE [dbo].[uspAPUpdateVoucherHistory]
	@voucherIds Id READONLY,
	@paymentDetailIds Id READONLY,
	@post BIT
AS

BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @startingRecordId INT;
DECLARE @transCount INT = @@TRANCOUNT;
IF OBJECT_ID(N'tempdb..#tmpVoucherHistory') IS NOT NULL DROP TABLE #tmpVoucherHistory
IF OBJECT_ID(N'tempdb..#tmpVoucherPaymentHistory') IS NOT NULL DROP TABLE #tmpVoucherPaymentHistory

IF @transCount = 0 BEGIN TRANSACTION

--voucher posting
IF EXISTS(SELECT 1 FROM @voucherIds)
BEGIN
	SELECT 
		[intBillId]				=	A.intBillId,
		[strBillId]				=	A.strBillId,
		[dblQtyReceived]		=	CASE WHEN @post = 0 THEN -B.dblQtyReceived ELSE B.dblQtyReceived END,
		[dblCost]				=	B.dblCost, 
		[dblTotal]				=	CASE WHEN @post = 0 THEN -B.dblTotal + -B.dblTax ELSE B.dblTotal + B.dblTax END,
		[dblAmountDue]			=	A.dblAmountDue,
		[strCommodity]			=	ISNULL(commodity.strCommodityCode, 'None'),
		[strItemNo]				=	ISNULL(item.strItemNo, B.strMiscDescription),
		[strLocation]			=	loc.strLocationName,
		[strTicketNumber]		=	ticket.strTicketNumber,
		[strQtyUnitMeasure]		=	unitMeasure.strUnitMeasure,
		[strCostUnitMeasure]	=	costUnitMeasure.strUnitMeasure,
		[strCurrency]			=	cur.strCurrency,
		[dtmTransactionDate]	=	GETDATE(),
		[dtmTicketDateTime]		=	ticket.dtmTicketDateTime,
		[dtmDateEntered]		=	A.dtmDateCreated
	INTO #tmpVoucherHistory
	FROM tblAPBill A 
	INNER JOIN @voucherIds ids ON A.intBillId = ids.intId
	INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
	INNER JOIN tblSMCompanyLocation loc ON A.intShipToId = loc.intCompanyLocationId
	INNER JOIN tblSMCurrency cur ON A.intCurrencyId = cur.intCurrencyID
	LEFT JOIN tblICItem item ON B.intItemId = item.intItemId
	LEFT JOIN tblICCommodity commodity ON item.intCommodityId = commodity.intCommodityId
	LEFT JOIN tblSCTicket ticket ON B.intScaleTicketId = ticket.intTicketId
	LEFT JOIN (tblICItemUOM uom INNER JOIN tblICUnitMeasure unitMeasure ON uom.intUnitMeasureId = unitMeasure.intUnitMeasureId)
			ON B.intUnitOfMeasureId = uom.intItemUOMId
	LEFT JOIN (tblICItemUOM costuom INNER JOIN tblICUnitMeasure costUnitMeasure ON costuom.intUnitMeasureId = costUnitMeasure.intUnitMeasureId)
			ON B.intCostUOMId = costuom.intItemUOMId

	INSERT INTO tblAPVoucherHistory (
		[intBillId]				
		,[strBillId]				
		,[dblQtyReceived]		
		,[dblCost]				
		,[dblTotal]				
		,[dblAmountDue]			
		,[strCommodity]			
		,[strItemNo]				
		,[strLocation]			
		,[strTicketNumber]		
		,[strQtyUnitMeasure]		
		,[strCostUnitMeasure]	
		,[strCurrency]			
		,[dtmTransactionDate]	
		,[dtmTicketDateTime]		
		,[dtmDateEntered]		
	)
	SELECT
		[intBillId]				
		,[strBillId]				
		,[dblQtyReceived]		
		,[dblCost]				
		,[dblTotal]				
		,[dblAmountDue]			
		,[strCommodity]			
		,[strItemNo]				
		,[strLocation]			
		,[strTicketNumber]		
		,[strQtyUnitMeasure]		
		,[strCostUnitMeasure]	
		,[strCurrency]			
		,[dtmTransactionDate]	
		,[dtmTicketDateTime]		
		,[dtmDateEntered]		
	FROM #tmpVoucherHistory
END

--payment posting
--calling this stored procedure assumes that the payment detail data has been updated ex. dblAmountDue
IF EXISTS(SELECT 1 FROM @paymentDetailIds)
BEGIN
	SELECT 
		[intBillId]				=	A.intBillId,
		[strBillId]				=	A.strBillId,
		[dblQtyReceived]		=	(pd.dblPayment + (CASE WHEN (pd.dblAmountDue = 0) THEN pd.dblDiscount ELSE 0 END))
		 							--get the percentage of payment made to total amount due
									/ (CASE WHEN @post = 1 THEN (voucher.dblAmountDue + pd.dblPayment) 
											ELSE (voucher.dblAmountDue) END) --get the percentage of payment
									* voucherDetail.dblQtyReceived
									* (CASE WHEN @post = 1 THEN -1 ELSE 1 END),
		[dblCost]				=	voucherDetail.dblCost, 
		[dblTotal]				=	CAST(CASE WHEN @post = 1 
											THEN -dbo.fnAPGetPaymentAmountFactor(voucherDetail.dblTotal + voucherDetail.dblTax, pd.dblPayment 
																		+ (CASE WHEN (pd.dblAmountDue = 0) THEN pd.dblDiscount ELSE 0 END)
																		, voucher.dblTotal) 
									ELSE dbo.fnAPGetPaymentAmountFactor(voucherDetail.dblTotal + voucherDetail.dblTax, pd.dblPayment 
																		+ (CASE WHEN (pd.dblAmountDue = 0) THEN pd.dblDiscount ELSE 0 END)
																		, voucher.dblTotal) END AS DECIMAL(18,2)),
		[dblAmountDue]			=	pd.dblAmountDue,
		[strCommodity]			=	ISNULL(commodity.strCommodityCode, 'None'),
		[strItemNo]				=	ISNULL(item.strItemNo, voucherDetail.strMiscDescription),
		[strLocation]			=	loc.strLocationName,
		[strTicketNumber]		=	ticket.strTicketNumber,
		[strQtyUnitMeasure]		=	unitMeasure.strUnitMeasure,
		[strCostUnitMeasure]	=	costUnitMeasure.strUnitMeasure,
		[strCurrency]			=	cur.strCurrency,
		[dtmTransactionDate]	=	GETDATE(),
		[dtmTicketDateTime]		=	ticket.dtmTicketDateTime,
		[dtmDateEntered]		=	A.dtmDateCreated
	INTO #tmpVoucherPaymentHistory
	FROM tblAPBill A 
	INNER JOIN tblAPPaymentDetail pd ON A.intBillId = ISNULL(pd.intBillId, pd.intOrigBillId)
	INNER JOIN @paymentDetailIds ids ON pd.intPaymentDetailId = ids.intId
	INNER JOIN tblAPBill voucher ON pd.intBillId = voucher.intBillId
	INNER JOIN tblAPBillDetail voucherDetail ON voucher.intBillId = voucherDetail.intBillId
	LEFT JOIN tblICItem item ON voucherDetail.intItemId = item.intItemId
	LEFT JOIN tblICCommodity commodity ON item.intCommodityId = commodity.intCommodityId
	INNER JOIN tblSMCompanyLocation loc ON voucher.intShipToId = loc.intCompanyLocationId
	INNER JOIN tblSMCurrency cur ON voucher.intCurrencyId = cur.intCurrencyID
	LEFT JOIN tblSCTicket ticket ON voucherDetail.intScaleTicketId = ticket.intTicketId
	LEFT JOIN (tblICItemUOM uom INNER JOIN tblICUnitMeasure unitMeasure ON uom.intUnitMeasureId = unitMeasure.intUnitMeasureId)
			ON voucherDetail.intUnitOfMeasureId = uom.intItemUOMId
	LEFT JOIN (tblICItemUOM costuom INNER JOIN tblICUnitMeasure costUnitMeasure ON costuom.intUnitMeasureId = costUnitMeasure.intUnitMeasureId)
			ON voucherDetail.intCostUOMId = costuom.intItemUOMId


	INSERT INTO tblAPVoucherHistory (
		[intBillId]				
		,[strBillId]				
		,[dblQtyReceived]		
		,[dblCost]				
		,[dblTotal]				
		,[dblAmountDue]			
		,[strCommodity]			
		,[strItemNo]				
		,[strLocation]			
		,[strTicketNumber]		
		,[strQtyUnitMeasure]		
		,[strCostUnitMeasure]	
		,[strCurrency]			
		,[dtmTransactionDate]	
		,[dtmTicketDateTime]		
		,[dtmDateEntered]		
	)
	SELECT
		[intBillId]				
		,[strBillId]				
		,[dblQtyReceived]		
		,[dblCost]				
		,[dblTotal]				
		,[dblAmountDue]			
		,[strCommodity]			
		,[strItemNo]				
		,[strLocation]			
		,[strTicketNumber]		
		,[strQtyUnitMeasure]		
		,[strCostUnitMeasure]	
		,[strCurrency]			
		,[dtmTransactionDate]	
		,[dtmTicketDateTime]		
		,[dtmDateEntered]		
	FROM #tmpVoucherPaymentHistory
END

IF @transCount = 0 COMMIT TRANSACTION
END TRY
BEGIN CATCH
	DECLARE @ErrorSeverity INT,
			@ErrorNumber   INT,
			@ErrorMessage nvarchar(4000),
			@ErrorState INT,
			@ErrorLine  INT,
			@ErrorProc nvarchar(200);
	-- Grab error information from SQL functions
	SET @ErrorSeverity = ERROR_SEVERITY()
	SET @ErrorNumber   = ERROR_NUMBER()
	SET @ErrorMessage  = ERROR_MESSAGE()
	SET @ErrorState    = ERROR_STATE()
	SET @ErrorLine     = ERROR_LINE()
	IF @transCount = 0 AND XACT_STATE() <> 0 ROLLBACK TRANSACTION
	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH
END