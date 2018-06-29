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
	CROSS APPLY [dbo].[fnAPGetVoucherCommodity](A.intBillId) commodity
	INNER JOIN tblSMCompanyLocation loc ON A.intShipToId = loc.intCompanyLocationId
	INNER JOIN tblSMCurrency cur ON A.intCurrencyId = cur.intCurrencyID
	LEFT JOIN tblICItem item ON B.intItemId = item.intItemId
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
IF EXISTS(SELECT 1 FROM @paymentDetailIds)
BEGIN
	SELECT 
		[intBillId]				=	A.intBillId,
		[strBillId]				=	A.strBillId,
		[dblQtyReceived]		=	CASE WHEN @post = 0 THEN -pd.dblPayment ELSE pd.dblPayment END,
		[dblCost]				=	pd.dblPayment, 
		[dblTotal]				=	CASE WHEN @post = 0 THEN -pd.dblPayment ELSE pd.dblPayment END,
		[dblAmountDue]			=	A.dblAmountDue,
		[strCommodity]			=	NULL,
		[strItemNo]				=	NULL,
		[strLocation]			=	loc.strLocationName,
		[strTicketNumber]		=	NULL,
		[strQtyUnitMeasure]		=	NULL,
		[strCostUnitMeasure]	=	NULL,
		[strCurrency]			=	cur.strCurrency,
		[dtmTransactionDate]	=	A.dtmDate,
		[dtmTicketDateTime]		=	NULL,
		[dtmDateEntered]		=	A.dtmDateCreated
	INTO #tmpVoucherPaymentHistory
	FROM tblAPBill A 
	INNER JOIN tblAPPaymentDetail pd ON A.intBillId = ISNULL(pd.intBillId, pd.intOrigBillId)
	INNER JOIN @paymentDetailIds ids ON pd.intPaymentDetailId = ids.intId
	INNER JOIN tblSMCompanyLocation loc ON A.intShipToId = loc.intCompanyLocationId
	INNER JOIN tblSMCurrency cur ON A.intCurrencyId = cur.intCurrencyID

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