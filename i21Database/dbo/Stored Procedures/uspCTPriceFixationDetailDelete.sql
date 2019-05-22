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
			@Quantity		NUMERIC(18,6);
	
	DECLARE @tblItemBillDetail TABLE
	(
		intInventoryReceiptItemId	INT,
		intBillId					INT,
		intBillDetailId				INT,
		dblReceived					NUMERIC(26,16)
	)

	SELECT  BL.intBillId AS Id, FT.intDetailId AS DetailId, DA.intBillDetailId AS BillDetailId, FD.dblQuantity AS Quantity
	INTO	#ItemBill
	FROM	tblCTPriceFixationDetailAPAR	DA
	JOIN    vyuCTPriceFixationTicket        FT	ON  FT.intDetailId				=   DA.intBillDetailId
	JOIN	tblCTPriceFixationDetail		FD	ON	FD.intPriceFixationDetailId =	DA.intPriceFixationDetailId
	JOIN	tblCTPriceFixation				PF	ON	PF.intPriceFixationId		=	FD.intPriceFixationId
	JOIN	tblAPBill						BL	ON	BL.intBillId				=	DA.intBillId
	WHERE	PF.intPriceFixationId		=	ISNULL(@intPriceFixationId, PF.intPriceFixationId)
	AND		FD.intPriceFixationDetailId	=	ISNULL(@intPriceFixationDetailId,FD.intPriceFixationDetailId)
	AND		FT.intPriceFixationTicketId	=	ISNULL(@intPriceFixationTicketId,FT.intPriceFixationTicketId)
	AND		ISNULL(BL.ysnPosted,0) = 0
	
	SELECT @Id = MIN(Id), @DetailId = MIN(DetailId) FROM #ItemBill
	WHILE ISNULL(@Id,0) > 0
	BEGIN
		SELECT @Count = COUNT(*) FROM tblCTPriceFixationDetailAPAR WHERE intBillId = @Id
		IF @intPriceFixationTicketId IS NOT NULL AND @Count > 1
		BEGIN
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
			IF NOT EXISTS (SELECT TOP 1 1 FROM tblCTPriceFixationDetailAPAR WHERE intBillId = @Id)
			BEGIN
				EXEC uspAPDeleteVoucher @Id,@intUserId
		
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
			INSERT INTO @tblItemBillDetail
			SELECT intInventoryReceiptItemId, @Id, intBillDetailId, dblQtyReceived
			FROM tblAPBillDetail a
			INNER JOIN #ItemBill b ON a.intBillDetailId = b.BillDetailId
			WHERE intBillId = @Id

			SELECT @BillDetailId = MIN(intBillDetailId) FROM @tblItemBillDetail
			WHILE ISNULL(@BillDetailId,0) > 0
			BEGIN
				SELECT @ItemId = intInventoryReceiptItemId, @BillDetailId = intBillDetailId, @Quantity = dblReceived
				FROM @tblItemBillDetail
				WHERE intBillDetailId = @BillDetailId
				
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
				SELECT * FROM dbo.fnCTGenerateReceiptDetail(@ItemId, @Id, @BillDetailId, @Quantity * -1, 0)
			
				EXEC uspICUpdateBillQty @updateDetails = @receiptDetails

				SELECT @BillDetailId = MIN(intBillDetailId) FROM @tblItemBillDetail WHERE intBillDetailId > @BillDetailId
			END
			DELETE FROM @tblItemBillDetail

			----------------------------------------
			DELETE FROM tblCTPriceFixationDetailAPAR WHERE intBillId = @Id
			EXEC uspAPDeleteVoucher @Id,@intUserId	
		END

		SELECT @Id = MIN(Id) FROM #ItemBill WHERE Id > @Id
	END

	SELECT @List = NULL

	SELECT  DA.intInvoiceId AS Id, FT.intDetailId AS DetailId
	INTO	#ItemInvoice
	FROM	tblCTPriceFixationDetailAPAR	DA
	JOIN    vyuCTPriceFixationTicket        FT	ON  FT.intDetailId				=   DA.intInvoiceDetailId
	JOIN	tblCTPriceFixationDetail		FD	ON	FD.intPriceFixationDetailId =	DA.intPriceFixationDetailId
	JOIN	tblCTPriceFixation				PF	ON	PF.intPriceFixationId		=	FD.intPriceFixationId
	JOIN	tblARInvoice					IV	ON	IV.intInvoiceId				=	DA.intInvoiceId
	WHERE	PF.intPriceFixationId		=	ISNULL(@intPriceFixationId, PF.intPriceFixationId)
	AND		FD.intPriceFixationDetailId	=	ISNULL(@intPriceFixationDetailId,FD.intPriceFixationDetailId)
	AND		FT.intPriceFixationTicketId	=	ISNULL(@intPriceFixationTicketId,FT.intPriceFixationTicketId)
	AND		ISNULL(IV.ysnPosted,0) = 0

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