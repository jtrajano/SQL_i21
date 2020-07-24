CREATE PROCEDURE [dbo].[uspCTPriceFixationDetailDelete]
	
	@intPriceFixationId			INT = NULL,
	@intPriceFixationDetailId	INT = NULL,
	@intPriceFixationTicketId	INT = NULL,
	@intUserId					INT,
	@ysnDeleteFromInvoice bit = 0
	
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
			@ysnSuccess		BIT,
			@intContractHeaderId int,
			@intContractDetailId int;

			declare @strFinalMessage nvarchar(max);
			declare @AffectedInvoices table
			(
				strMessage nvarchar(50)
			)
	
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

		if exists (
				SELECT 1
				FROM vyuAPBillPayment a
				JOIN tblAPPayment b on b.intPaymentId = a.intPaymentId
				JOIN tblSMPaymentMethod c on c.intPaymentMethodID = b.intPaymentMethodId
				WHERE a.intBillId = @Id and c.strPaymentMethod in ('Cash','Check','eCheck')
			)
		begin
			EXEC uspAPDeletePayment @Id, @intUserId
		end

		EXEC [dbo].[uspAPPostBill] @transactionType = 'Contract', @post = 0,@recap = 0,@isBatch = 0,@param = @Id,@userId = @intUserId,@success = @ysnSuccess OUTPUT
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
		SELECT @Count = COUNT(1) FROM tblCTPriceFixationDetailAPAR WHERE intBillDetailId = @DetailId

		DECLARE @ysnDeleteVoucher BIT = 0
		IF ISNULL(@intPriceFixationDetailId,0) <> 0
		BEGIN
			DECLARE @totalAPAR INT,
					@totalBill INT

			SELECT @totalAPAR = COUNT(1) FROM tblCTPriceFixationDetailAPAR WHERE intBillId = @Id
			SELECT @totalBill = COUNT(1) FROM #ItemBill WHERE Id = @Id

			IF @totalAPAR = @totalBill
				SET @ysnDeleteVoucher = 1
			ELSE
				SET @ysnDeleteVoucher = 0
		END
		
		IF @Count > 0 AND ISNULL(@intPriceFixationId,0) = 0 AND @ysnDeleteVoucher = 0--@Count > 0 AND @intPriceFixationTicketId IS NOT NULL AND @Count > 1
		BEGIN	
			-- -- UPDATE ITEM BILL QTY
			-- SELECT @ItemId = intInventoryReceiptItemId, @Quantity = dblQtyReceived
			-- FROM tblAPBillDetail 
			-- WHERE intBillDetailId = @DetailId

			-- DECLARE @receiptDetails AS InventoryUpdateBillQty
			-- DELETE FROM @receiptDetails
			-- INSERT INTO @receiptDetails
			-- (
			-- 	[intInventoryReceiptItemId],
			-- 	[intInventoryReceiptChargeId],
			-- 	[intInventoryShipmentChargeId],
			-- 	[intSourceTransactionNoId],
			-- 	[strSourceTransactionNo],
			-- 	[intItemId],
			-- 	[intToBillUOMId],
			-- 	[dblToBillQty]
			-- )
			-- SELECT * FROM dbo.fnCTGenerateReceiptDetail(@ItemId, @Id, @DetailId, @Quantity * -1, 0)

			-- EXEC uspICUpdateBillQty @updateDetails = @receiptDetails	
			-- -----------------------------------------
			-- -- CT-4094	
			DELETE FROM tblCTPriceFixationDetailAPAR WHERE intBillId = @Id AND intBillDetailId = @DetailId
			--DELETE FROM tblAPBillDetail WHERE intBillDetailId = @DetailId
			
			INSERT INTO @voucherIds			
			SELECT @DetailId

			-- EXEC uspAPUpdateVoucherTotal @voucherIds

			-- --Audit Log
			-- DECLARE @details NVARCHAR(max) = '{"change": "tblAPBillDetails", "iconCls": "small-tree-grid","changeDescription": "Details", "children": [{"action": "Deleted", "change": "Deleted-Record: '+CAST(@DetailId as varchar(15))+'", "keyValue": '+CAST(@DetailId as varchar(15))+', "iconCls": "small-new-minus", "leaf": true}]}';

			-- EXEC uspSMAuditLog
			-- @screenName = 'AccountsPayable.view.Voucher',
			-- @entityId = @intUserId,
			-- @actionType = 'Updated',
			-- @actionIcon = 'small-tree-modified',
			-- @keyValue = @Id,
			-- @details = @details

			EXEC uspAPDeleteVoucherDetail @voucherIds, @intUserId

			---- DELETE VOUCHER IF ALL TICKETS WHERE DELETED
			--IF (SELECT COUNT(*) FROM tblCTPriceFixationDetailAPAR WHERE intBillId = @Id) = 0
			--BEGIN
				-- -- Disable constraints
				-- ALTER TABLE tblCTPriceFixationDetailAPAR NOCHECK CONSTRAINT FK_tblCTPriceFixationDetailAPAR_tblAPBill_intBillId  
				-- ALTER TABLE tblCTPriceFixationDetailAPAR NOCHECK CONSTRAINT FK_tblCTPriceFixationDetailAPAR_tblAPBillDetail_intBillDetailId

				-- EXEC uspAPDeleteVoucher @Id,@intUserId,4

				-- -- Enable constraints
				-- ALTER TABLE tblCTPriceFixationDetailAPAR CHECK CONSTRAINT FK_tblCTPriceFixationDetailAPAR_tblAPBill_intBillId  
				-- ALTER TABLE tblCTPriceFixationDetailAPAR CHECK CONSTRAINT FK_tblCTPriceFixationDetailAPAR_tblAPBillDetail_intBillDetailId        

				-- --Audit Log
				-- EXEC uspSMAuditLog
				-- @screenName = 'AccountsPayable.view.Voucher',
				-- @entityId = @intUserId,
				-- @actionType = 'Deleted',
				-- @actionIcon = 'small-tree-deleted',
				-- @keyValue = @Id
				-- END	
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
			-- Disable constraints
			ALTER TABLE tblCTPriceFixationDetailAPAR NOCHECK CONSTRAINT FK_tblCTPriceFixationDetailAPAR_tblAPBill_intBillId  
			ALTER TABLE tblCTPriceFixationDetailAPAR NOCHECK CONSTRAINT FK_tblCTPriceFixationDetailAPAR_tblAPBillDetail_intBillDetailId

			EXEC uspAPDeleteVoucher @Id,@intUserId,4
			
			-- Enable constraints
			ALTER TABLE tblCTPriceFixationDetailAPAR CHECK CONSTRAINT FK_tblCTPriceFixationDetailAPAR_tblAPBill_intBillId  
			ALTER TABLE tblCTPriceFixationDetailAPAR CHECK CONSTRAINT FK_tblCTPriceFixationDetailAPAR_tblAPBillDetail_intBillDetailId		
			DELETE FROM tblCTPriceFixationDetailAPAR WHERE intBillId = @Id
			DELETE FROM #ItemBill WHERE Id = @Id

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
	AND @ysnDeleteFromInvoice = 0

	 if (@intPriceFixationId is null or @intPriceFixationId < 1)
	 begin
		select @intPriceFixationId = intPriceFixationId from tblCTPriceFixationDetail where intPriceFixationDetailId = @intPriceFixationDetailId;
	 end

	UPDATE	CD
	SET		CD.dblBasis				=	ISNULL(CD.dblOriginalBasis,0),
			CD.intFutureMarketId	=	PF.intOriginalFutureMarketId,
			CD.intFutureMonthId		=	PF.intOriginalFutureMonthId,
			CD.intPricingTypeId		=	CASE WHEN CH.intPricingTypeId <> 8 THEN 2 ELSE 8 END,
			CD.dblFutures			=	CASE WHEN CH.intPricingTypeId = 3 THEN CD.dblFutures ELSE NULL END,
			CD.dblCashPrice			=	NULL,
			CD.dblTotalCost			=	NULL,
			CD.intConcurrencyId		=	CD.intConcurrencyId + 1,
			CD.intContractStatusId	=	case when CD.intContractStatusId = 5 then 1 else CD.intContractStatusId end
	FROM	tblCTContractDetail	CD
	JOIN	tblCTContractHeader	CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId
	JOIN	tblCTPriceFixation	PF	ON	CD.intContractDetailId = PF.intContractDetailId OR CD.intSplitFromId = PF.intContractDetailId
	AND EXISTS(SELECT * FROM tblCTPriceFixation WHERE intContractDetailId = ISNULL(CD.intContractDetailId,0))
	WHERE	PF.intPriceFixationId	=	@intPriceFixationId

	select @intContractHeaderId = intContractHeaderId, @intContractDetailId = intContractDetailId from tblCTPriceFixation where intPriceFixationId = @intPriceFixationId;

	IF ISNULL(@intPriceFixationId,0) = 0 AND ISNULL(@intPriceFixationDetailId, 0) <> 0
	BEGIN
		UPDATE tblCTPriceFixationDetail SET ysnToBeDeleted = 1
		WHERE intPriceFixationDetailId = @intPriceFixationDetailId

		exec uspCTCreateDetailHistory @intContractHeaderId 	= @intContractHeaderId, 
								  @intContractDetailId 	= @intContractDetailId, 
								  @strSource 			= 'Pricing',
								  @strProcess 			= 'Fixation Detail Delete',
								  @intUserId			=  @intUserId
	END
	
	--if EXISTS (select top 1 1 from #ItemInvoice where isnull(ysnPosted,convert(bit,0)) = convert(bit,1))
	if EXISTS (select top 1 1 from #ItemInvoice)
	begin

		if (@intPriceFixationDetailId is not null)
		begin
			insert into @AffectedInvoices
			select
			strMessage = d.strInvoiceNumber + ' line item ' + convert(nvarchar(20),t.intInvoiceLineItemId) 
			from
			tblCTPriceFixationDetailAPAR c
			left join 
			(
			select
			intInvoiceLineItemId = ROW_NUMBER() over (partition by b.intInvoiceId order by b.intInvoiceDetailId)
			,a.intPriceFixationDetailId
			,b.intInvoiceId
			,b.intInvoiceDetailId
			from tblCTPriceFixationDetailAPAR a
			,tblARInvoiceDetail b
			where a.intPriceFixationDetailId = @intPriceFixationDetailId
			and b.intInvoiceId = a.intInvoiceId
			)t on t.intInvoiceId = c.intInvoiceId and t.intInvoiceDetailId = c.intInvoiceDetailId
			left join tblARInvoice d on d.intInvoiceId = c.intInvoiceId
			where c.intPriceFixationDetailId = @intPriceFixationDetailId

			select
			top 1 @strFinalMessage = 'Invoice/s' + stuff((SELECT ', ' + strMessage FROM @AffectedInvoices FOR XML PATH ('')), 1, 1, '') + ' is using the price. Please delete that first.'
			from @AffectedInvoices
		end
		ELSE
		begin
			set @strFinalMessage = 'Invoice/s exists for the price. Please try to delete them first to delete the pricing.';
		end

		SET @ErrMsg = @strFinalMessage
		RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')
	END
	DECLARE @dId INT
	SELECT @DetailId = MIN(DetailId) FROM #ItemInvoice
	WHILE ISNULL(@DetailId,0) > 0
	BEGIN
		SELECT @Id = intInvoiceId FROM tblCTPriceFixationDetailAPAR WHERE intInvoiceDetailId = @DetailId
		SELECT @Count = COUNT(*) FROM tblCTPriceFixationDetailAPAR WHERE intInvoiceId = @Id

		IF @Count > 1
		BEGIN
			SELECT @dId = @DetailId
		END
		ELSE
		BEGIN
			SELECT @dId = NULL
		END

		DELETE FROM tblCTPriceFixationDetailAPAR WHERE intInvoiceDetailId = @DetailId
		EXEC uspARDeleteInvoice @Id,@intUserId, @dId

		SELECT @DetailId = MIN(DetailId) FROM #ItemInvoice WHERE DetailId > @DetailId
	END

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH