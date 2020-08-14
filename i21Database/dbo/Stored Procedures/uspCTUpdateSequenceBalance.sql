CREATE PROCEDURE [dbo].[uspCTUpdateSequenceBalance]
	@intContractDetailId			INT,
	@dblQuantityToUpdate			NUMERIC(18,6),
	@intUserId						INT,
	@intExternalId					INT,
	@strScreenName					NVARCHAR(50),
	@ysnFromInvoice					bit = 0
AS

BEGIN TRY
	
	DECLARE @ErrMsg					NVARCHAR(MAX),
			@dblQuantity			NUMERIC(18,6),
			@dblOldBalance			NUMERIC(18,6),
			@dblNewBalance			NUMERIC(18,6),
			@strAdjustmentNo		NVARCHAR(50),
			@dblTransactionQuantity	NUMERIC(18,6),
			@dblQuantityToIncrease	NUMERIC(18,6),
			@ysnUnlimitedQuantity	BIT,
			@ysnCompleted			BIT	= 0,
			@intPricingTypeId		INT,
			@dblTolerance			NUMERIC(18,6) = 0.0001,
			@ysnLoad				BIT,
			@intSequenceUsageHistoryId	INT,  
			@dblQuantityPerLoad NUMERIC(18,6),
			@intPostedTicketDestinationWeightsAndGrades int,
			@intUnPostedTicketDestinationWeightsAndGrades int
	
	BEGINING:

	SELECT	@dblQuantity			=	CASE WHEN ISNULL(CH.ysnLoad,0) = 0 THEN ISNULL(CD.dblQuantity,0) ELSE ISNULL(CD.intNoOfLoad,0) END,
			@dblOldBalance			=	CASE WHEN ISNULL(CH.ysnLoad,0) = 0 THEN ISNULL(CD.dblBalance,0) ELSE ISNULL(CD.dblBalanceLoad,0) END,
			@ysnUnlimitedQuantity	=	ISNULL(CH.ysnUnlimitedQuantity,0),
			@intPricingTypeId		=	CD.intPricingTypeId,
			@ysnLoad				=	CH.ysnLoad,
			@dblQuantityPerLoad = CH.dblQuantityPerLoad

	FROM	tblCTContractDetail		CD
	JOIN	tblCTContractHeader		CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId 
	WHERE	intContractDetailId		=	@intContractDetailId 

	 if (@ysnLoad = 1 and @ysnFromInvoice = convert(bit,1)) 
	 begin
		set @dblQuantityToUpdate = case when @dblQuantityToUpdate < 0 then -1 else 1 end;
	 end
	
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
		END
	END

	UPDATE	tblCTContractDetail
	SET		intConcurrencyId	=	intConcurrencyId + 1,
			dblBalance			=	CASE WHEN ISNULL(@ysnLoad,0) = 0 THEN @dblNewBalance ELSE @dblNewBalance * dblQuantityPerLoad END,
			dblBalanceLoad		=	CASE WHEN ISNULL(@ysnLoad,0) = 0 THEN NULL ELSE @dblNewBalance END,
			intContractStatusId	=	CASE	WHEN @ysnCompleted = 0
											THEN	(CASE	WHEN intContractStatusId = 5
															THEN 1
															ELSE intContractStatusId
													END)
											ELSE 5
									END
	WHERE	intContractDetailId =	@intContractDetailId

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
	
	EXEC	uspCTCreateCollateralAdjustment
			@intContractDetailId	=	@intContractDetailId,
			@dblQuantityToUpdate	=	@dblQuantityToUpdate,
			@intUserId				=	@intUserId,
			@intExternalId			=	@intExternalId,
			@strScreenName			=	@strScreenName

	EXEC	uspCTCreateDetailHistory	
	@intContractHeaderId		=	NULL,
    @intContractDetailId		=	@intContractDetailId,
	@strComment				    =	NULL,
	@intSequenceUsageHistoryId  =	@intSequenceUsageHistoryId

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
	
END CATCH