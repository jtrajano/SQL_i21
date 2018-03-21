CREATE PROCEDURE [dbo].[uspAPUpdateVoucherHistory]
	@voucherIds Id READONLY
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
IF @transCount = 0 BEGIN TRANSACTION

MERGE INTO tblAPVoucherHistory AS targetTable
USING (
	SELECT 
		[intBillId]				=	A.intBillId,
		[strBillId]				=	A.strBillId,
		[dblQtyReceived]		=	B.dblQtyReceived,
		[dblCost]				=	B.dblCost, 
		[dblAmountDue]			=	A.dblAmountDue,
		[strCommodity]			=	ISNULL(commodity.strCommodityCode, 'None'),
		[strItemNo]				=	item.strItemNo,
		[strLocation]			=	loc.strLocationName,
		[strTicketNumber]		=	ticket.strTicketNumber,
		[strUnitMeasure]		=	unitMeasure.strUnitMeasure,
		[strCurrency]			=	currency.strCurrency,
		[dtmTransactionDate]	=	A.dtmDate,
		[dtmTicketDateTime]		=	ticket.dtmTicketDateTime,
		[dtmDateEntered]		=	A.dtmDateCreated
	FROM tblAPBill A 
	INNER JOIN @voucherIds ids ON A.intBillId = ids.intId
	INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
	CROSS APPLY [dbo].[fnAPGetVoucherCommodity](A.intBillId) commodity
	INNER JOIN tblSMCompanyLocation loc ON A.intShipToId = loc.intCompanyLocationId
	INNER JOIN tblSMCurrency cur ON A.intCurrencyId = cur.intCurrencyID
	LEFT JOIN tblICItem item ON B.intItemId = item.intItemId
	LEFT JOIN tblSCTicket ticket ON B.intScaleTicketId = ticket.intTicketId
	LEFT JOIN (tblICItemUOM uom INNER JOIN tblICUnitMeasure unitMeasure ON uom.intUnitMeasureId = unitMeasure.intUnitMeasureId)
			ON B.intUnitMeasureId = uom.intItemUOMId
) AS sourceData
ON (targetTable.intBillId = sourceData.intBillId)
WHEN NOT MATCHED BY TARGET THEN
INSERT (
	[intBillId]				,
	[strBillId]				,
	[dblQtyReceived]		,
	[dblCost]				, 
	[dblAmountDue]			,
	[strCommodity]			,
	[strItemNo]				,
	[strLocation]			,
	[strTicketNumber]		,
	[strUnitMeasure]		,
	[strCurrency]			,
	[dtmTransactionDate]	,
	[dtmTicketDateTime]		,
	[dtmDateEntered]		
)
VALUES (
	[intBillId]				,
	[strBillId]				,
	[dblQtyReceived]		,
	[dblCost]				, 
	[dblAmountDue]			,
	[strCommodity]			,
	[strItemNo]				,
	[strLocation]			,
	[strTicketNumber]		,
	[strUnitMeasure]		,
	[strCurrency]			,
	[dtmTransactionDate]	,
	[dtmTicketDateTime]		,
	[dtmDateEntered]		
);
--ON (B.intBillId <>)
--WHEN NOT MATCHED THEN
--	INSERT(
--		[intBillId],
--		[strMiscDescription],
--		[strComment], 
--		[intAccountId],
--		[intItemId],
--		[intInventoryReceiptItemId],
--		[intInventoryReceiptChargeId],
--		[intPurchaseDetailId],
--		[intContractHeaderId],
--		[intContractDetailId],
--		[intPrepayTypeId],
--		[intTaxGroupId],
--		[dblTotal],
--		[intConcurrencyId], 
--		[dblQtyOrdered], 
--		[dblQtyReceived], 
--		[dblDiscount], 
--		[dblCost], 
--		[dblLandedCost], 
--		[dblTax], 
--		[dblPrepayPercentage], 
--		[dblWeight], 
--		[dblVolume], 
--		[dtmExpectedDate], 
--		[int1099Form], 
--		[int1099Category], 
--		[intLineNo]
--	)
--	VALUES
--	(
--		[intBillId],
--		[strMiscDescription],
--		[strComment], 
--		[intAccountId],
--		[intItemId],
--		[intInventoryReceiptItemId],
--		[intInventoryReceiptChargeId],
--		[intPurchaseDetailId],
--		[intContractHeaderId],
--		[intContractDetailId],
--		[intPrepayTypeId],
--		[intTaxGroupId],
--		[dblTotal],
--		[intConcurrencyId], 
--		[dblQtyOrdered], 
--		[dblQtyReceived], 
--		[dblDiscount], 
--		[dblCost], 
--		[dblLandedCost], 
--		[dblTax], 
--		[dblPrepayPercentage], 
--		[dblWeight], 
--		[dblVolume], 
--		[dtmExpectedDate], 
--		[int1099Form], 
--		[int1099Category], 
--		[intLineNo]
--	)

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