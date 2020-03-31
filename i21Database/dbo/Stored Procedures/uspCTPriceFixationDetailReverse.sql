﻿CREATE PROCEDURE [dbo].[uspCTPriceFixationDetailReverse]
	@intPriceFixationId			INT = NULL,
	@intPriceFixationDetailId	INT = NULL,
	@intPriceFixationTicketId	INT = NULL,
	@intUserId					INT
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
			@TransQty				NUMERIC(18,6),
			@ysnSuccess				BIT,
			@intContractHeaderId 	INT,
			@intContractDetailId 	INT;

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
		SELECT @Quantity = SUM(Quantity) FROM #ItemBill WHERE Id = @Id
		SELECT @TransQty = SUM(dblQtyReceived) FROM tblAPBillDetail WHERE intBillId = @Id AND intInventoryReceiptChargeId IS NULL
		-- If equal debit memo the voucher
		IF @Quantity = @TransQty
		BEGIN
			DECLARE	@billCreatedId INT		
			EXEC uspAPReverseTransaction @Id, @intUserId, null, @billCreatedId OUTPUT
		END
		ELSE
		BEGIN
			-- Else create a debit memo for line items
			--EXEC uspCTCreateDebitMemo
		END

		SELECT DISTINCT @Id = MIN(Id) FROM #ItemBill WHERE Id > @Id
	END

	-- Tag APAR as reverse
	UPDATE  tblCTPriceFixationDetailAPAR SET ysnReverse = 1
	WHERE intPriceFixationDetailAPARId IN 
	(
		SELECT intPriceFixationDetailAPARId FROM #ItemBill
	)

	IF (@intPriceFixationId IS NULL OR @intPriceFixationId < 1)
	BEGIN
		SELECT @intPriceFixationId = intPriceFixationId FROM  tblCTPriceFixationDetail WHERE intPriceFixationDetailId = @intPriceFixationDetailId
	END

	SELECT @intContractHeaderId = intContractHeaderId, @intContractDetailId = intContractDetailId from tblCTPriceFixation where intPriceFixationId = @intPriceFixationId

	IF ISNULL(@intPriceFixationId,0) = 0
	BEGIN
		EXEC uspCTCreateDetailHistory @intContractHeaderId 	= @intContractHeaderId, 
								  @intContractDetailId 	= @intContractDetailId, 
								  @strSource 			= 'Pricing',
								  @strProcess 			= 'Fixation Detail Delete'
	END

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH