﻿CREATE PROCEDURE [dbo].[uspCTPriceFixationDetailDelete]
	
	@intPriceFixationId			INT = NULL,
	@intPriceFixationDetailId	INT = NULL,
	@intPriceFixationTicketId	INT = NULL,
	@intUserId					INT
	
AS
BEGIN TRY
	
	DECLARE @ErrMsg			NVARChAR(MAX),
			@List			NVARChAR(MAX),
			@Id				INT,
			@DetailId		INT,
			@Count			INT,
			@voucherIds		AS Id,
			@BillDetailId	INT,
			@ItemId			INT,
			@Quantity		NUMERIC(18,6),
			@ysnSuccess		BIT;
	
	DECLARE @tblItemBillDetail TABLE
	(
		intInventoryReceiptItemId	INT,
		intBillId					INT,
		intBillDetailId				INT,
		dblReceived					NUMERIC(26,16)
	)

	-- UNPOST BILL
	SELECT  DISTINCT BL.intBillId
	INTO	#ItemBillPosted
	FROM	tblCTPriceFixationDetailAPAR	DA	LEFT
	JOIN    vyuCTPriceFixationTicket        FT	ON  FT.intDetailId				=   DA.intBillDetailId
	JOIN	tblCTPriceFixationDetail		FD	ON	FD.intPriceFixationDetailId =	DA.intPriceFixationDetailId
	JOIN	tblCTPriceFixation				PF	ON	PF.intPriceFixationId		=	FD.intPriceFixationId
	JOIN	tblAPBill						BL	ON	BL.intBillId				=	DA.intBillId
	WHERE	BL.ysnPosted =	1
	AND		PF.intPriceFixationId =	ISNULL(@intPriceFixationId, PF.intPriceFixationId)
	AND		FD.intPriceFixationDetailId	= ISNULL(@intPriceFixationDetailId,FD.intPriceFixationDetailId)

	WHILE EXISTS(SELECT 1 FROM #ItemBillPosted)
	BEGIN
		SELECT TOP 1 @Id = intBillId FROM #ItemBillPosted

		-- Check if paid and printed
		IF EXISTS(SELECT 1 FROM vyuAPBillPayment WHERE intBillId = @Id)
		BEGIN
			EXEC uspAPDeletePayment @Id, @intUserId
		END

		EXEC [dbo].[uspAPPostBill] @transactionType = 'Contract',@post = 0,@recap = 0,@isBatch = 0,@param = @Id,@userId = @intUserId,@success = @ysnSuccess OUTPUT
		DELETE #ItemBillPosted WHERE intBillId = @Id
	END

	-- GET UNPOSTED BILL
	SELECT  BL.intBillId AS Id, FT.intDetailId AS DetailId, DA.intBillDetailId AS BillDetailId, FD.dblQuantity AS Quantity
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
	AND		ISNULL(BL.ysnPosted,0) = 0


	SELECT @DetailId = MIN(ISNULL(DetailId, BillDetailId)) FROM #ItemBill	
	WHILE ISNULL(@DetailId,0) > 0
	BEGIN
		
		SELECT @Id = Id FROM #ItemBill WHERE ISNULL(DetailId, BillDetailId) = @DetailId
		SELECT @Count = COUNT(*) FROM tblCTPriceFixationDetailAPAR WHERE intBillDetailId = @DetailId
		
		IF @Count > 0--@intPriceFixationTicketId IS NOT NULL AND @Count > 1
		BEGIN	
		
			-- UPDATE ITEM BILL QTY
			SELECT @ItemId = intInventoryReceiptItemId, @Quantity = dblQtyReceived
			FROM tblAPBillDetail 
			WHERE intBillDetailId = @DetailId

			DECLARE @receiptDetails AS InventoryUpdateBillQty
			DELETE FROM @receiptDetails
			INSERT INTO @receiptDetails
			(
				[intInventoryReceiptItemId],
				[intInventoryReceiptChargeId],
				[intInventoryShipmentChargeId],
				[intSourceTransactionNoId],
				[strSourceTransactionNo],
				[intItemId],
				[intToBillUOMId],
				[dblToBillQty]
			)
			SELECT * FROM dbo.fnCTGenerateReceiptDetail(@ItemId, @Id, @DetailId, @Quantity * -1, 0)

			EXEC uspICUpdateBillQty @updateDetails = @receiptDetails	
			-----------------------------------------
			-- CT-4094	
			DELETE FROM tblCTPriceFixationDetailAPAR WHERE intBillId = @Id AND intBillDetailId = @DetailId
			DELETE FROM tblAPBillDetail WHERE intBillDetailId = @DetailId
			
			INSERT INTO @voucherIds			
			SELECT @DetailId

			EXEC uspAPUpdateVoucherTotal @voucherIds

			--Audit Log
			DECLARE @details NVARCHAR(max) = '{"change": "tblAPBillDetails", "iconCls": "small-tree-grid","changeDescription": "Details", "children": [{"action": "Deleted", "change": "Deleted-Record: '+CAST(@DetailId as varchar(15))+'", "keyValue": '+CAST(@DetailId as varchar(15))+', "iconCls": "small-new-minus", "leaf": true}]}';

			EXEC uspSMAuditLog
			@screenName = 'AccountsPayable.view.Voucher',
			@entityId = @intUserId,
			@actionType = 'Updated',
			@actionIcon = 'small-tree-modified',
			@keyValue = @Id,
			@details = @details

			-- DELETE VOUCHER IF ALL TICKETS WHERE DELETED
			IF (SELECT COUNT(*) FROM tblCTPriceFixationDetailAPAR WHERE intBillId = @Id) = 0
			BEGIN
			
				SELECT 'Delete 1', * FROM tblAPBill ORDER BY intBillId DESC
				EXEC uspAPDeleteVoucher @Id,@intUserId,4
		
				--Audit Log
				EXEC uspSMAuditLog
				@screenName = 'AccountsPayable.view.Voucher',
				@entityId = @intUserId,
				@actionType = 'Deleted',
				@actionIcon = 'small-tree-deleted',
				@keyValue = @Id
			END	
		END
		ELSE
		BEGIN
			-- Adjust Item Bill Quantity			
			--INSERT INTO @tblItemBillDetail
			--SELECT intInventoryReceiptItemId, @Id, intBillDetailId, dblQtyReceived
			--FROM tblAPBillDetail a
			--INNER JOIN #ItemBill b ON a.intBillDetailId = b.BillDetailId
			--WHERE intBillId = @Id

			--SELECT @BillDetailId = MIN(intBillDetailId) FROM @tblItemBillDetail
			--WHILE ISNULL(@BillDetailId,0) > 0
			--BEGIN
			--	SELECT @ItemId = intInventoryReceiptItemId, @BillDetailId = intBillDetailId, @Quantity = dblReceived
			--	FROM @tblItemBillDetail
			--	WHERE intBillDetailId = @BillDetailId
				
			--	DECLARE @receiptDetails AS InventoryUpdateBillQty
			--	DELETE FROM @receiptDetails
			--	INSERT INTO @receiptDetails
			--	(
			--		[intInventoryReceiptItemId],
			--		[intInventoryReceiptChargeId],
			--		[intInventoryShipmentChargeId],
			--		[intSourceTransactionNoId],
			--		[strSourceTransactionNo],
			--		[intItemId],
			--		[intToBillUOMId],
			--		[dblToBillQty]
			--	)
			--	SELECT * FROM dbo.fnCTGenerateReceiptDetail(@ItemId, @Id, @BillDetailId, @Quantity * -1, 0)
			
			--	EXEC uspICUpdateBillQty @updateDetails = @receiptDetails

			--	SELECT @BillDetailId = MIN(intBillDetailId) FROM @tblItemBillDetail WHERE intBillDetailId > @BillDetailId
			--END
			--DELETE FROM @tblItemBillDetail

			----------------------------------------
			EXEC uspAPDeleteVoucher @Id,@intUserId,4
			DELETE FROM tblCTPriceFixationDetailAPAR WHERE intBillId = @Id
		END
		SELECT @DetailId = MIN(ISNULL(DetailId, BillDetailId)) FROM #ItemBill WHERE ISNULL(DetailId, BillDetailId) > @DetailId
	END

	SELECT @List = NULL

	SELECT  DA.intInvoiceId AS Id, isnull(FT.intDetailId,DA.intInvoiceDetailId) AS DetailId, IV.ysnPosted
	INTO	#ItemInvoice
	FROM	tblCTPriceFixationDetailAPAR	DA	LEFT
	JOIN    vyuCTPriceFixationTicket        FT	ON  FT.intDetailId				=   DA.intInvoiceDetailId
	JOIN	tblCTPriceFixationDetail		FD	ON	FD.intPriceFixationDetailId =	DA.intPriceFixationDetailId
	JOIN	tblCTPriceFixation				PF	ON	PF.intPriceFixationId		=	FD.intPriceFixationId
	JOIN	tblARInvoice					IV	ON	IV.intInvoiceId				=	DA.intInvoiceId
	WHERE	PF.intPriceFixationId		=	ISNULL(@intPriceFixationId, PF.intPriceFixationId)
	AND		FD.intPriceFixationDetailId	=	ISNULL(@intPriceFixationDetailId,FD.intPriceFixationDetailId)
	-- Perfomance hit
	AND		ISNULL(FT.intPriceFixationTicketId, 0)	=   CASE WHEN @intPriceFixationTicketId IS NOT NULL THEN @intPriceFixationTicketId ELSE ISNULL(FT.intPriceFixationTicketId,0) END
	--AND		ISNULL(IV.ysnPosted,0) = 0

	if EXISTS (select top 1 1 from #ItemInvoice where isnull(ysnPosted,convert(bit,0)) = convert(bit,1))
	begin
		SET @ErrMsg = 'Posted invoice exists for the price. Please try to unpost them and try again.'
		RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')
	END
	SELECT @Id = MIN(Id), @DetailId = MIN(DetailId) FROM #ItemInvoice
	WHILE ISNULL(@Id,0) > 0
	BEGIN
		SELECT @Count = COUNT(*) FROM tblCTPriceFixationDetailAPAR WHERE intInvoiceId = @Id
		IF @Count = 1
			SELECT @DetailId = NULL
		ELSE
			DELETE FROM tblCTPriceFixationDetailAPAR WHERE intInvoiceId = @Id AND intInvoiceDetailId = @DetailId

		EXEC uspARDeleteInvoice @Id,@intUserId,@DetailId
		SELECT @Id = MIN(Id) FROM #ItemInvoice WHERE Id > @Id
	END

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH