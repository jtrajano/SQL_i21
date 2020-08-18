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
			@ParamDetailId		INT,
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

	if (@intPriceFixationId is null or @intPriceFixationId < 1)
	begin
		set @intContractDetailId = (select top 1 intContractDetailId from tblCTPriceFixation where intPriceFixationId = (select top 1 intPriceFixationId from tblCTPriceFixationDetail where intPriceFixationDetailId = @intPriceFixationDetailId))
	end
	ELSE
	begin
		set @intContractDetailId = (select top 1 intContractDetailId from tblCTPriceFixation where intPriceFixationId = @intPriceFixationId)
	end

	declare @intDWGIdId int
			,@ysnDestinationWeightsAndGrades bit;

	select @intDWGIdId = intWeightGradeId from tblCTWeightGrade where strWhereFinalized = 'Destination';
			
	select
		@ysnDestinationWeightsAndGrades = (case when ch.intWeightId = @intDWGIdId or ch.intGradeId = @intDWGIdId then 1 else 0 end)
	from
		tblCTContractDetail cd
		,tblCTContractHeader ch
	where
		cd.intContractDetailId = @intContractDetailId
		and ch.intContractHeaderId = cd.intContractHeaderId

	if (@ysnDestinationWeightsAndGrades = 0)
	begin
		UPDATE	tblCTContractDetail
		SET		intContractStatusId	=	case when intContractStatusId = 5 then 1 else intContractStatusId end
		where intContractDetailId = @intContractDetailId
	end

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

	SELECT * FROM #ItemBill
	SELECT @Id = MIN(Id), @DetailId = MIN(ISNULL(DetailId, BillDetailId)) FROM #ItemBill
	WHILE ISNULL(@Id,0) > 0
	BEGIN
		SELECT @Count = COUNT(*) FROM tblCTPriceFixationDetailAPAR WHERE intBillId = @Id 
		IF @Count > 1--@intPriceFixationTicketId IS NOT NULL AND @Count > 1 
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
				[dblToBillQty],
				[dblAmountToBill]
			)
			SELECT * FROM dbo.fnCTGenerateReceiptDetail(@ItemId, @Id, @DetailId, @Quantity * -1, 0)

			EXEC uspICUpdateBillQty @updateDetails = @receiptDetails	
			-----------------------------------------
			-- CT-4094	
			DELETE FROM tblCTPriceFixationDetailAPAR WHERE intBillId = @Id AND intBillDetailId = @DetailId
			DELETE FROM tblAPBillDetail WHERE intBillDetailId = @DetailId
			
			INSERT INTO @voucherIds			
			SELECT @Id

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

		SELECT @Id = MIN(Id) FROM #ItemBill WHERE Id > @Id
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
	AND		ISNULL(IV.ysnPosted,0) = 0
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
			CD.dblFutures			=	NULL,
			CD.dblCashPrice			=	NULL,
			CD.dblTotalCost			=	NULL,
			CD.intConcurrencyId		=	CD.intConcurrencyId + 1,
			CD.intContractStatusId	=	case when CD.intContractStatusId = 5 and @ysnDestinationWeightsAndGrades = 0 then 1 else CD.intContractStatusId end
	FROM	tblCTContractDetail	CD
	JOIN	tblCTContractHeader	CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId
	JOIN	tblCTPriceFixation	PF	ON	CD.intContractDetailId = PF.intContractDetailId OR CD.intSplitFromId = PF.intContractDetailId
	AND EXISTS(SELECT * FROM tblCTPriceFixation WHERE intContractDetailId = ISNULL(CD.intContractDetailId,0))
	WHERE	PF.intPriceFixationId	=	@intPriceFixationId

	select @intContractHeaderId = intContractHeaderId, @intContractDetailId = intContractDetailId from tblCTPriceFixation where intPriceFixationId = @intPriceFixationId;
	exec uspCTCreateDetailHistory @intContractHeaderId,@intContractDetailId,null,null;
	
	--if EXISTS (select top 1 1 from #ItemInvoice where isnull(ysnPosted,convert(bit,0)) = convert(bit,1))
	if EXISTS (select top 1 1 from #ItemInvoice)
	select @DetailId = MIN(DetailId) FROM #ItemInvoice
	while (@DetailId is not null)
	begin
		
		set @ParamDetailId = @DetailId;

		select @Id = Id FROM #ItemInvoice where DetailId = @ParamDetailId;
		select @Count = COUNT(*) FROM tblARInvoiceDetail WHERE intInvoiceId = @Id
		DELETE FROM tblCTPriceFixationDetailAPAR WHERE intInvoiceDetailId = @ParamDetailId
		
		if (@Count = 1)
		begin
			set @ParamDetailId = null
		end
		ELSE
		BEGIN
			DELETE FROM tblCTPriceFixationDetailAPAR WHERE intInvoiceId = @Id AND intInvoiceDetailId = @DetailId
		END
		EXEC uspARDeleteInvoice @Id,@intUserId,@ParamDetailId

		select @DetailId = MIN(DetailId) FROM #ItemInvoice where DetailId > @DetailId;
	end

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH