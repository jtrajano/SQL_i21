﻿CREATE PROCEDURE [dbo].[uspCTUpdateSequenceBalance]
	@intContractDetailId			INT,
	@dblQuantityToUpdate			NUMERIC(38,20),
	@intUserId						INT,
	@intExternalId					INT,
	@strScreenName					NVARCHAR(50),
	@ysnFromInvoice					bit = 0,
	@ysnDWG 						bit = 0,
	@ysnPostDWG						bit = 0
AS

BEGIN TRY
	
	DECLARE @ErrMsg					NVARCHAR(MAX),
			@dblQuantity			NUMERIC(38,20),
			@dblOldBalance			NUMERIC(38,20),
			@dblNewBalance			NUMERIC(38,20),
			@strAdjustmentNo		NVARCHAR(50),
			@dblTransactionQuantity	NUMERIC(38,20),
			@dblQuantityToIncrease	NUMERIC(38,20),
			@ysnUnlimitedQuantity	BIT,
			@ysnCompleted			BIT	= 0,
			@intPricingTypeId		INT,
			@dblTolerance			NUMERIC(18,6) = 0.0001,
			@ysnLoad				BIT,
			@intSequenceUsageHistoryId	INT,  
			@dblQuantityPerLoad NUMERIC(18,6),
   			@intAllocatedPurchaseContractDetailId int,
			@intPostedTicketDestinationWeightsAndGrades int,
			@intUnPostedTicketDestinationWeightsAndGrades int,
			@ysnLogSequenceHistory	BIT = 1,
			@intContractHeaderId	INT,
			@process				NVARCHAR(50),
			@intHeaderUOMId				INT,
			@intCommodityId				INT,
			@dblHeaderQuantity	NUMERIC(18,6),
			@dblTotalHeaderApplied NUMERIC(18,6),
			@ysnQuantityAtHeaderLevel bit = 0,
			@dblSequenceOrigBalance NUMERIC(18,6),
			@ysnIsDWG				BIT = 0
	
	BEGINING:

	SELECT	@dblQuantity			=	CASE WHEN ISNULL(CH.ysnLoad,0) = 0 THEN ISNULL(CD.dblQuantity,0) ELSE ISNULL(CD.intNoOfLoad,0) END,
			@dblSequenceOrigBalance			=	CASE WHEN ISNULL(CH.ysnLoad,0) = 0 THEN ISNULL(CD.dblBalance,0) ELSE ISNULL(CD.dblBalanceLoad,0) END,
			@dblOldBalance			=	CASE WHEN ISNULL(CH.ysnLoad,0) = 0 THEN ISNULL((case when isnull(CH.ysnQuantityAtHeaderLevel,0) = 1 then cds.dblHeaderBalance else CD.dblBalance end),0) ELSE ISNULL(CD.dblBalanceLoad,0) END,
			@ysnUnlimitedQuantity	=	ISNULL(CH.ysnUnlimitedQuantity,0),
			@intPricingTypeId		=	CD.intPricingTypeId,
			@ysnLoad				=	CH.ysnLoad,
			@intContractHeaderId	=	CH.intContractHeaderId,
			@dblQuantityPerLoad = CH.dblQuantityPerLoad,
			@intHeaderUOMId = CH.intCommodityUOMId,
			@intCommodityId = CH.intCommodityId,
			@dblHeaderQuantity = CH.dblQuantity,
			@ysnQuantityAtHeaderLevel = isnull(CH.ysnQuantityAtHeaderLevel,0)

	FROM	tblCTContractDetail		CD
	JOIN	tblCTContractHeader		CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId 
    cross apply (
		select
		dblHeaderBalance = CH.dblQuantity - sum(cd.dblQuantity - cd.dblBalance)
		,dblHeaderAvailable = CH.dblQuantity - (sum(cd.dblQuantity - cd.dblBalance) + sum(isnull(cd.dblScheduleQty,0)))
		,dblHeaderScheduleQty = sum(isnull(cd.dblScheduleQty,0))
		from tblCTContractDetail cd
		where cd.intContractHeaderId = CH.intContractHeaderId
    ) cds
	WHERE	intContractDetailId		=	@intContractDetailId 

	 if (@ysnLoad = 1 and @ysnFromInvoice = convert(bit,1)) 
	 begin
		set @dblQuantityToUpdate = case when @dblQuantityToUpdate < 0 then -1 else 1 end;
	 end

	IF @ysnLoad = 1 and @ysnDWG = 1
	BEGIN
		set @dblQuantityToUpdate = 0
	END
	
	SELECT	@dblTransactionQuantity	=	- @dblQuantityToUpdate
	SELECT	@dblNewBalance			=	@dblOldBalance - @dblQuantityToUpdate
	
	IF @dblNewBalance < 0
	BEGIN
		IF @ysnUnlimitedQuantity = 1
		BEGIN
			SET		@dblQuantityToIncrease	= @dblNewBalance * -1

			EXEC	uspCTUpdateSequenceQuantity
					@intContractDetailId	=	@intContractDetailId,
					@dblQuantityToUpdate	=	@dblQuantityToIncrease,
					@intUserId				=	@intUserId,
					@intExternalId			=	@intExternalId,
					@strScreenName			=	@strScreenName

			GOTO BEGINING
		END
		ELSE
		BEGIN
			IF ABS(@dblNewBalance) > @dblTolerance
			BEGIN
				RAISERROR('Balance cannot be less than zero.',16,1)
			END
			ELSE
			BEGIN
				SET @dblQuantityToUpdate =  @dblQuantityToUpdate + @dblNewBalance
				SET	@dblNewBalance		 =	@dblOldBalance - @dblQuantityToUpdate
			END
		END
	END
	
	IF @dblNewBalance > @dblQuantity
	BEGIN
		IF @dblNewBalance > @dblQuantity +@dblTolerance
		BEGIN
			RAISERROR('Balance cannot be more than quantity.',16,1)
		END
		ELSE
		BEGIN
			SET @dblNewBalance = @dblQuantity
		END
	END
	
	IF	@ysnUnlimitedQuantity = 1 OR @intPricingTypeId IN (2,3,5)
	BEGIN
		SET @ysnCompleted = 0
	END
	ELSE IF @intPricingTypeId IN (1,6,7) AND @dblNewBalance = 0 
	BEGIN
		SET @ysnCompleted = 1
	END

	/*
		Check if the Contract is DWG.
		If the sequence balance = 0 and all tickets DWG associated with it is already posted, mark the sequence as complete.
	*/	
	
	IF @dblNewBalance = 0 
	BEGIN	
		IF EXISTS 
		(
			SELECT
				TOP 1 1
			FROM
				tblCTContractDetail cd
				JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
				LEFT JOIN tblCTWeightGrade w ON w.intWeightGradeId = ch.intWeightId
				LEFT JOIN tblCTWeightGrade g ON g.intWeightGradeId = ch.intGradeId
			WHERE
				cd.intContractDetailId = @intContractDetailId
				AND ch.intContractTypeId = 2
				AND (w.strWhereFinalized = 'Destination' OR g.strWhereFinalized = 'Destination')
		)
		BEGIN
			SELECT @intPostedTicketDestinationWeightsAndGrades = COUNT(intContractId)
			FROM tblSCTicket
			WHERE ISNULL(ysnDestinationWeightGradePost,0) = 1 AND intContractId = @intContractDetailId

			SELECT @intUnPostedTicketDestinationWeightsAndGrades = COUNT(intContractId)
			FROM tblSCTicket
			WHERE ISNULL(ysnDestinationWeightGradePost,0) = 0 AND intContractId = @intContractDetailId

			SELECT @ysnCompleted = CASE WHEN @intPostedTicketDestinationWeightsAndGrades > 0 AND @intUnPostedTicketDestinationWeightsAndGrades = 0 THEN 1 ELSE 0 END
			SELECT @ysnIsDWG = 1;
		END
	END

	UPDATE	tblCTContractDetail
	SET		intConcurrencyId	=	intConcurrencyId + 1,
			dblBalance			=	CASE WHEN ISNULL(@ysnLoad,0) = 0 THEN (case when isnull(@ysnQuantityAtHeaderLevel,0) = 1 then @dblSequenceOrigBalance - @dblQuantityToUpdate else @dblNewBalance end) ELSE @dblNewBalance * dblQuantityPerLoad END,
			dblBalanceLoad		=	CASE WHEN ISNULL(@ysnLoad,0) = 0 THEN NULL ELSE @dblNewBalance END,
			intContractStatusId	=	CASE	WHEN @ysnCompleted = 0 and (CASE WHEN ISNULL(@ysnLoad,0) = 0 THEN @dblNewBalance ELSE @dblNewBalance * dblQuantityPerLoad END) > 0
											THEN	(CASE	WHEN intContractStatusId = 5
															THEN 1
															ELSE intContractStatusId
													END)
											ELSE
												case
													when (@ysnIsDWG = 1 and @ysnCompleted = 0) or intPricingTypeId = 5
													then intContractStatusId
													else 5
												end
									END
	WHERE	intContractDetailId =	@intContractDetailId

	update ch set ch.intConcurrencyId = ch.intConcurrencyId + 1
	from tblCTContractDetail cd
	join tblCTContractHeader ch on ch.intContractHeaderId = cd.intContractHeaderId
	where cd.intContractDetailId = @intContractDetailId

	if (@ysnQuantityAtHeaderLevel = 1)
	begin
		select @dblTotalHeaderApplied = sum(cd.dblQuantity - isnull(cd.dblBalance,0))
		from tblCTContractDetail cd
		where cd.intContractHeaderId = @intContractHeaderId

		if (@dblHeaderQuantity = @dblTotalHeaderApplied)
		begin
			update tblCTContractDetail set intContractStatusId = 5, dblQuantity = (dblQuantity - isnull(dblBalance,0)), dblBalance = 0, dblBalanceLoad = 0 where intContractHeaderId = @intContractHeaderId;
		end
		else
		begin
			if (@dblQuantityToUpdate < 0 and exists (select top 1 1 from tblCTContractDetail where intContractStatusId = 5 and intContractHeaderId = @intContractHeaderId))
			begin
				update tblCTContractDetail
				set
				intContractStatusId = 1
				, dblQuantity = @dblHeaderQuantity
				, dblBalance = case when intContractStatusId = 5 then (@dblHeaderQuantity - dblQuantity) else @dblHeaderQuantity - (dblQuantity - abs(@dblQuantityToUpdate)) end
				where intContractHeaderId = @intContractHeaderId
			end
		end
	end

	 /*
	 CT-4516
	 Check if the Sales Contract is allocated and get the Purchase Contract allocated on it and update the Status
	 considering the quantity is the same.
	 */ 
	set @intAllocatedPurchaseContractDetailId = null;
	select @intAllocatedPurchaseContractDetailId = min(intPContractDetailId) from tblLGAllocationDetail where intSContractDetailId = @intContractDetailId;
	while (@intAllocatedPurchaseContractDetailId is not null)
	begin  

		UPDATE tblCTContractDetail    
		SET
			intConcurrencyId = intConcurrencyId + 1,     
			intContractStatusId = 	CASE WHEN @ysnCompleted = 0 and dblBalance > 0
									THEN 	CASE WHEN intContractStatusId = 5     
											THEN 1     
											ELSE intContractStatusId     
											END     
									ELSE 5     
									END    
		WHERE intContractDetailId = @intAllocatedPurchaseContractDetailId  


		update ch set ch.intConcurrencyId = ch.intConcurrencyId + 1
		from tblCTContractDetail cd
		join tblCTContractHeader ch on ch.intContractHeaderId = cd.intContractHeaderId
		where cd.intContractDetailId = @intAllocatedPurchaseContractDetailId
	
		select @intAllocatedPurchaseContractDetailId = min(intPContractDetailId) from tblLGAllocationDetail where intSContractDetailId = @intContractDetailId and intPContractDetailId > @intAllocatedPurchaseContractDetailId;

	end  

	IF @ysnLoad = 1 and @ysnDWG = 1
	BEGIN
		DECLARE @contractDetails AS [dbo].[ContractDetailTable]
		SELECT @process = CASE WHEN @ysnPostDWG = 1 THEN 'Post Load-based DWG' ELSE 'Unpost Load-based DWG' END

		EXEC uspCTLogSummary @intContractHeaderId 	= 	@intContractHeaderId,
							 @intContractDetailId 	= 	@intContractDetailId,
							 @strSource			 	= 	'Inventory',
							 @strProcess		 	= 	@process,
							 @contractDetail 		= 	@contractDetails,
							 @intUserId				= 	@intUserId,
							 @intTransactionId		= 	@intExternalId
	END
	ELSE
	BEGIN
		EXEC	uspCTCreateSequenceUsageHistory
				@intContractDetailId	=	@intContractDetailId,
				@strScreenName			=	@strScreenName,
				@intExternalId			=	@intExternalId,
				@strFieldName			=	'Balance',
				@dblOldValue			=	@dblOldBalance,
				@dblTransactionQuantity =	@dblTransactionQuantity,
				@dblNewValue			=	@dblNewBalance,	
				@intUserId				=	@intUserId,
				@dblBalance				=   @dblNewBalance,
				@intSequenceUsageHistoryId	=	@intSequenceUsageHistoryId	OUTPUT
	END

	EXEC	uspCTCreateCollateralAdjustment
			@intContractDetailId	=	@intContractDetailId,
			@dblQuantityToUpdate	=	@dblQuantityToUpdate,
			@intUserId				=	@intUserId,
			@intExternalId			=	@intExternalId,
			@strScreenName			=	@strScreenName
	
	SELECT @process = CASE WHEN @ysnDWG = 1 
							THEN (CASE WHEN ISNULL(@ysnLoad,0) = 1 THEN 'Update Sequence Balance - DWG (Load-based)' ELSE 'Update Sequence Balance - DWG' END) 
							ELSE 'Update Sequence Balance'
					  END

	EXEC	uspCTCreateDetailHistory	
			@intContractHeaderId		=	NULL,
			@intContractDetailId		=	@intContractDetailId,
			@strComment				    =	NULL,
			@intSequenceUsageHistoryId  =	@intSequenceUsageHistoryId,
			@strSource	 				= 	'Inventory',
			@strProcess 				= 	@process,
			@intUserId					= 	@intUserId

	exec uspCTUpdateAppliedAndPrice
		@intContractDetailId = @intContractDetailId
		,@dblBalance = @dblNewBalance

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
	
END CATCH