CREATE PROCEDURE [dbo].[uspCTPriceFixationDetailDelete]
	
	@intPriceFixationId			INT = NULL,
	@intPriceFixationDetailId	INT = NULL,
	@intPriceFixationTicketId	INT = NULL,
	@intUserId					INT,
	@ysnDeleteFromInvoice bit = 0,
	@ysnDeleteWholePricing bit = 0
	
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
			@intContractDetailId int,
			@strSummaryLogProcess nvarchar(50);

			DECLARE @contractDetails AS [dbo].[ContractDetailTable]
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
		set @intContractDetailId = (select top 1 pf.intContractDetailId from tblCTPriceFixationDetail pfd inner join tblCTPriceFixation pf on pfd.intPriceFixationId = pf.intPriceFixationId where intPriceFixationDetailId = @intPriceFixationDetailId)
	end
	else
	begin
		set @intContractDetailId = (select top 1 intContractDetailId from tblCTPriceFixation where intPriceFixationId = @intPriceFixationId)
	end

	declare @intDWGIdId int
			,@ysnDestinationWeightsAndGrades bit = 0;
			
	if exists 
	(
		select top 1 1 
		from tblCTContractDetail cd
		inner join tblCTContractHeader ch on ch.intContractHeaderId = cd.intContractHeaderId
		inner join tblCTWeightGrade wg on wg.intWeightGradeId in (ch.intWeightId, ch.intGradeId)
			and wg.strWhereFinalized = 'Destination'
		where cd.intContractDetailId = @intContractDetailId
  		and ch.intContractTypeId = 2
	)
	begin
		set @ysnDestinationWeightsAndGrades = 1
	end

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

		if exists (
				SELECT 1
				FROM vyuAPBillPayment a
				JOIN tblAPPayment b on b.intPaymentId = a.intPaymentId
				JOIN tblSMPaymentMethod c on c.intPaymentMethodID = b.intPaymentMethodId
				WHERE a.intBillId = @Id and c.strPaymentMethod in ('Cash','Check','eCheck','ACH')
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
		
		IF @Count > 0 AND ISNULL(@intPriceFixationId,0) = 0 AND @ysnDeleteVoucher = 0
		BEGIN	
			-- -- CT-4094	
			DELETE FROM tblCTPriceFixationDetailAPAR WHERE intBillId = @Id AND intBillDetailId = @DetailId
			
			INSERT INTO @voucherIds			
			SELECT @DetailId

			EXEC uspAPDeleteVoucherDetail @voucherIds, @intUserId
		END
		ELSE
		BEGIN
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
	AND		ISNULL(IV.ysnPosted,0) = 0
	AND @ysnDeleteFromInvoice = 0
	
	IF (@intPriceFixationId IS NULL OR @intPriceFixationId < 1)
	BEGIN
		DECLARE @tempPriceFixationId INT
		SELECT @tempPriceFixationId = intPriceFixationId FROM tblCTPriceFixationDetail WHERE intPriceFixationDetailId = @intPriceFixationDetailId
		
		UPDATE	CD
		SET		CD.dblBasis				=	ISNULL(CD.dblOriginalBasis,0),
				CD.intPricingTypeId		=	CASE WHEN CH.intPricingTypeId <> 8 THEN 2 ELSE 8 END,
				CD.dblFutures			=	CASE WHEN CH.intPricingTypeId = 3 THEN CD.dblFutures ELSE NULL END,
				CD.dblCashPrice			=	NULL,
				CD.dblTotalCost			=	NULL,
				CD.intConcurrencyId		=	CD.intConcurrencyId + 1,
				CD.intContractStatusId	=	case when CD.intContractStatusId = 5 and @ysnDestinationWeightsAndGrades = 0 then 1 else CD.intContractStatusId end
		FROM	tblCTContractDetail	CD
		-- JOIN	tblCTContractHeader	CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId
		-- JOIN	tblCTPriceFixation	PF	ON	CD.intContractDetailId = PF.intContractDetailId OR CD.intSplitFromId = PF.intContractDetailId
		-- AND EXISTS(SELECT TOP 1 1 FROM tblCTPriceFixation WHERE intContractDetailId = ISNULL(CD.intContractDetailId,0))
		JOIN	tblCTContractHeader	CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId
		JOIN	tblCTPriceFixation	PF	ON PF.intContractHeaderId = CH.intContractHeaderId and	isnull(PF.intContractDetailId,0) = (case when CH.ysnMultiplePriceFixation = 1 then isnull(PF.intContractDetailId,0) else CD.intContractDetailId end) OR PF.intContractDetailId = CD.intSplitFromId
		AND EXISTS(SELECT TOP 1 1 FROM tblCTPriceFixation pff WHERE pff.intContractHeaderId = CH.intContractHeaderId and isnull(pff.intContractDetailId,0) = (case when CH.ysnMultiplePriceFixation = 1 then isnull(pff.intContractDetailId,0) else ISNULL(CD.intContractDetailId,0) end))
		WHERE	PF.intPriceFixationId	=	@tempPriceFixationId

		SELECT @intContractHeaderId = intContractHeaderId
			, @intContractDetailId = intContractDetailId
		FROM tblCTPriceFixation WHERE intPriceFixationId = @tempPriceFixationId
	END

	IF ISNULL(@intPriceFixationId,0) = 0 AND ISNULL(@intPriceFixationDetailId, 0) <> 0
	BEGIN
		UPDATE tblCTPriceFixationDetail SET ysnToBeDeleted = 1
		WHERE intPriceFixationDetailId = @intPriceFixationDetailId

		DECLARE @QtyToDelete NUMERIC(24, 10)
		SELECT @QtyToDelete = dblQuantity FROM tblCTPriceFixationDetail
		WHERE intPriceFixationDetailId = @intPriceFixationDetailId

		select @strSummaryLogProcess = (case when @ysnDeleteWholePricing = 1 then 'Price Delete' else 'Fixation Detail Delete' end)

		EXEC uspCTCreateDetailHistory @intContractHeaderId 	= @intContractHeaderId, 
								  @intContractDetailId 	= @intContractDetailId, 
								  @strSource 			= 'Pricing',
								  @strProcess 			= @strSummaryLogProcess,
								  @intUserId			=  @intUserId

		-- Summary Log
		if (@ysnDeleteWholePricing <> 1)
		begin
			EXEC uspCTLogSummary @intContractHeaderId 	= 	@intContractHeaderId,
								@intContractDetailId 	= 	@intContractDetailId,
								@strSource			 	= 	'Pricing',
								@strProcess		 	    = 	'Fixation Detail Delete',
								@contractDetail 		= 	@contractDetails,
								@intUserId				= 	@intUserId,
								@intTransactionId		= 	@intPriceFixationDetailId,
								@dblTransactionQty		= 	@QtyToDelete
		end

		-- Summary Log
		IF EXISTS 
		(
			select top 1 1 
			from tblCTContractHeader ch
			inner join tblCTWeightGrade wg on wg.intWeightGradeId in (ch.intWeightId, ch.intGradeId)
			and wg.strWhereFinalized = 'Destination'
			where intContractHeaderId = @intContractHeaderId
		)
		BEGIN
			declare @QtyToDeleteNegative numeric(18,6) = @QtyToDelete * -1;
			EXEC uspCTLogSummary @intContractHeaderId 	= 	@intContractHeaderId,
								@intContractDetailId 	= 	@intContractDetailId,
								@strSource			 	= 	'Pricing',
								@strProcess		 	    = 	'Price Delete DWG',
								@contractDetail 		= 	@contractDetails,
								@intUserId				= 	@intUserId,
								@intTransactionId		= 	@intPriceFixationDetailId,
								@dblTransactionQty		= 	@QtyToDeleteNegative
		END
	END

	IF ISNULL(@intPriceFixationDetailId,0) = 0 AND ISNULL(@intPriceFixationId, 0) <> 0
	begin

		SELECT @intContractHeaderId = intContractHeaderId
			, @intContractDetailId = intContractDetailId
		FROM tblCTPriceFixation WHERE intPriceFixationId = @intPriceFixationId

		IF EXISTS 
		(
			select top 1 1 
			from tblCTContractHeader ch
			inner join tblCTWeightGrade wg on wg.intWeightGradeId in (ch.intWeightId, ch.intGradeId)
			and wg.strWhereFinalized = 'Destination'
			where intContractHeaderId = @intContractHeaderId
		)
		BEGIN
			declare @intPriceFixationDetailIdToDelete int = 0;
			
			SELECT	@intPriceFixationDetailIdToDelete = MIN(intPriceFixationDetailId)	FROM	tblCTPriceFixationDetail WHERE intPriceFixationId = @intPriceFixationId
			WHILE	ISNULL(@intPriceFixationDetailIdToDelete,0) > 0
			BEGIN
				select @QtyToDelete = dblQuantity from tblCTPriceFixationDetail where intPriceFixationDetailId = @intPriceFixationDetailIdToDelete;

				select @QtyToDeleteNegative = @QtyToDelete * -1;
				EXEC uspCTLogSummary @intContractHeaderId 	= 	@intContractHeaderId,
									@intContractDetailId 	= 	@intContractDetailId,
									@strSource			 	= 	'Pricing',
									@strProcess		 	    = 	'Price Delete DWG',
									@contractDetail 		= 	@contractDetails,
									@intUserId				= 	@intUserId,
									@intTransactionId		= 	@intPriceFixationDetailIdToDelete,
									@dblTransactionQty		= 	@QtyToDeleteNegative
				 
				SELECT	@intPriceFixationDetailIdToDelete = MIN(intPriceFixationDetailId)	FROM	tblCTPriceFixationDetail WHERE intPriceFixationId = @intPriceFixationId AND intPriceFixationDetailId > @intPriceFixationDetailIdToDelete
			END
		END



	end
	
	declare @strInvoiceDiscountsChargesIds nvarchar(500);
	declare @InvoiceDiscountsChargesIds table (
		intId nvarchar(20)
	)
	declare @intActiveId int = 0;

	if EXISTS (select top 1 1 from #ItemInvoice)
	select @DetailId = MIN(DetailId) FROM #ItemInvoice
	while (@DetailId is not null)
	begin
		
		set @ParamDetailId = @DetailId;

		select @Id = Id FROM #ItemInvoice where DetailId = @ParamDetailId;
		select @Count = COUNT(*) FROM tblARInvoiceDetail WHERE intInvoiceId = @Id
		
		select @strInvoiceDiscountsChargesIds = strInvoiceDiscountsChargesIds from tblCTPriceFixationDetailAPAR WHERE intInvoiceDetailId = @ParamDetailId
		DELETE FROM tblCTPriceFixationDetailAPAR WHERE intInvoiceDetailId = @ParamDetailId
		
		if (@Count = 1)
		begin
			set @ParamDetailId = null
		end

		/*THis will also delete the charges/discounts*/
		if (isnull(@strInvoiceDiscountsChargesIds,'') <> '')
		begin
			insert into @InvoiceDiscountsChargesIds select Item from fnSplitString(@strInvoiceDiscountsChargesIds,',');
			if exists (select top 1 1 from @InvoiceDiscountsChargesIds)
			begin
				select @intActiveId = min(convert(int,intId)) from @InvoiceDiscountsChargesIds where convert(int,intId) > @intActiveId;
				while (@intActiveId is not null)
				begin
					EXEC uspARDeleteInvoice @Id,@intUserId,@intActiveId;
					select @intActiveId = min(convert(int,intId)) from @InvoiceDiscountsChargesIds where convert(int,intId) > @intActiveId;
				end
			end

		end

		EXEC uspARDeleteInvoice @Id,@intUserId,@ParamDetailId
		select @DetailId = MIN(DetailId) FROM #ItemInvoice where DetailId > @DetailId;
	end

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH