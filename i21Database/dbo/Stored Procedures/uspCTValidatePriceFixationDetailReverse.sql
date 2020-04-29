CREATE PROCEDURE [dbo].[uspCTValidatePriceFixationDetailReverse]
		
	@intPriceFixationId			INT = NULL,
	@intPriceFixationDetailId	INT = NULL,
	@intPriceFixationTicketId	INT = NULL
	
AS
BEGIN TRY
	
	DECLARE @ErrMsg					NVARChAR(MAX),
			@List					NVARChAR(MAX),
			@Id						INT,
			@DetailId				INT,
			@Count					INT,
			@voucherIds				AS Id,
			@BillDetailId			INT,
			@ItemId					INT,
			@Quantity				NUMERIC(18,6),
			@TransQty				NUMERIC(18,6)

	SELECT  DA.intPriceFixationDetailAPARId
			,BL.intBillId AS Id
			,FT.intDetailId AS DetailId
			,DA.intBillDetailId AS BillDetailId
			,FD.dblQuantity AS Quantity
	INTO	#ItemBill
	FROM	tblCTPriceFixationDetailAPAR	DA	LEFT
	JOIN    vyuCTPriceFixationTicket        FT	ON  FT.intDetailId				=   DA.intBillDetailId
	JOIN	tblCTPriceFixationDetail		FD	ON	FD.intPriceFixationDetailId =	DA.intPriceFixationDetailId
	JOIN	tblCTPriceFixation				PF	ON	PF.intPriceFixationId		=	FD.intPriceFixationId
	JOIN	tblAPBill						BL	ON	BL.intBillId				=	DA.intBillId
	WHERE	PF.intPriceFixationId		=	ISNULL(@intPriceFixationId, PF.intPriceFixationId)
	AND		FD.intPriceFixationDetailId	=	ISNULL(@intPriceFixationDetailId,FD.intPriceFixationDetailId)
	-- Perfomance hit
	AND		ISNULL(FT.intPriceFixationTicketId, 0)	=   CASE WHEN @intPriceFixationTicketId IS NOT NULL THEN @intPriceFixationTicketId ELSE ISNULL(FT.intPriceFixationTicketId,0) END
	
	-- Loop through Voucher
	SELECT DISTINCT @Id = MIN(Id) FROM #ItemBill
	WHILE ISNULL(@Id,0) > 0
	BEGIN
		-- Check if received is equal with the delete pricing
		SELECT @Quantity = ABS(SUM(Quantity)) FROM #ItemBill WHERE Id = @Id
		SELECT @TransQty = ABS(SUM(dblQtyReceived)) FROM tblAPBillDetail WHERE intBillId = @Id AND intInventoryReceiptChargeId IS NULL
		-- If equal debit memo the voucher
		IF @Quantity <> @TransQty
		BEGIN
			SET @ErrMsg = 'Unable to delete pricing, try to delete the whole pricing.'
			RAISERROR(@ErrMsg,16,1)
		END
		SELECT DISTINCT @Id = MIN(Id) FROM #ItemBill WHERE Id > @Id
	END

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH