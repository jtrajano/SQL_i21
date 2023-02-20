CREATE PROCEDURE uspCTUpdateScheduleQuantity

	@intContractDetailId	INT, 
	@dblQuantityToUpdate	NUMERIC(38,20),
	@intUserId				INT,
	@intExternalId			INT,
	@strScreenName			NVARCHAR(50)
	/*
	All the parameters are required. I am going to remove default value from the parameter in future.
	So provide all the parameter while calling the sp.
	*/
AS

BEGIN TRY
	
	DECLARE @ErrMsg					NVARCHAR(MAX),
			@dblQuantity			NUMERIC(38,20),
			@dblScheduleQty			NUMERIC(38,20),
			@dblOrgScheduleQty		NUMERIC(38,20),
			@dblBalance				NUMERIC(38,20),
			@dblNewScheduleQty		NUMERIC(38,20),
			@dblQuantityToIncrease	NUMERIC(38,20),
			@ysnUnlimitedQuantity	BIT,
			@intPricingTypeId		INT,
			@strContractNumber		NVARCHAR(100),
			@strContractSeq			NVARCHAR(100),
			@strAvailableQty		NVARCHAR(100),
			@strBalanceQty			NVARCHAR(100),
			@strQuantityToUpdate	NVARCHAR(100) = LTRIM(@dblQuantityToUpdate),
			@dblTolerance			NUMERIC(18,6) = 0.0001,
			@ysnAllowOverSchedule	BIT,
			@strReason				NVARCHAR(MAX),
			@ysnLoad				BIT,
			@intSequenceUsageHistoryId	INT,
			@intContractStatusId	INT,
			@ysnQuantityAtHeaderLevel bit = 0,
			@dblSequenceOrigSchedule NUMERIC(18,6),
			@intQuantityDecimals int = 2

	IF NOT EXISTS(SELECT * FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId)
	BEGIN
		RAISERROR('Sequence is deleted by other user.',16,1)
	END 
	
	SELECT @ysnAllowOverSchedule = ysnAllowOverSchedule, @intQuantityDecimals = case when intQuantityDecimals = 0 then 2 else isnull(intQuantityDecimals,2) end FROM tblCTCompanyPreference

	BEGINING:

	SELECT	@dblQuantityToUpdate	=	CASE WHEN ISNULL(ysnLoad,0) = 0 THEN @dblQuantityToUpdate ELSE @dblQuantityToUpdate / ABS(@dblQuantityToUpdate) END,
			@intContractStatusId	=	CD.intContractStatusId,
			@ysnQuantityAtHeaderLevel = CH.ysnQuantityAtHeaderLevel
	FROM	tblCTContractDetail		CD
	JOIN	tblCTContractHeader		CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId 
	WHERE	intContractDetailId		=	@intContractDetailId

	SELECT	@strQuantityToUpdate	=	LTRIM(@dblQuantityToUpdate)

	SELECT	@dblQuantity			=	CASE WHEN ISNULL(ysnLoad,0) = 0 THEN ISNULL(CD.dblQuantity,0) ELSE ISNULL(CD.intNoOfLoad,0) END,
			@dblSequenceOrigSchedule			=	CASE WHEN ISNULL(ysnLoad,0) = 0 THEN ISNULL(CD.dblScheduleQty,0) ELSE ISNULL(CD.dblScheduleLoad,0) END,
			@dblScheduleQty			=	CASE WHEN ISNULL(ysnLoad,0) = 0 THEN ISNULL((case when isnull(CH.ysnQuantityAtHeaderLevel,0) = 1 then cds.dblHeaderScheduleQty else CD.dblScheduleQty end),0) ELSE ISNULL(CD.dblScheduleLoad,0) END,
			@dblOrgScheduleQty		=	CASE WHEN ISNULL(ysnLoad,0) = 0 THEN ISNULL((case when isnull(CH.ysnQuantityAtHeaderLevel,0) = 1 then cds.dblHeaderScheduleQty else CD.dblScheduleQty end),0) ELSE ISNULL(CD.dblScheduleLoad,0) END,
			@dblBalance				=	CASE WHEN ISNULL(ysnLoad,0) = 0 THEN ISNULL((case when isnull(CH.ysnQuantityAtHeaderLevel,0) = 1 then cds.dblHeaderBalance else CD.dblBalance end),0) ELSE ISNULL(CD.dblBalanceLoad,0) END,
			@ysnUnlimitedQuantity	=	ISNULL(CH.ysnUnlimitedQuantity,0),
			@intPricingTypeId		=	CD.intPricingTypeId,
			@strContractNumber		=	CH.strContractNumber,
			@strContractSeq			=	LTRIM(CD.intContractSeq),
			@strAvailableQty		=	CASE WHEN ISNULL(ysnLoad,0) = 0 THEN LTRIM(ISNULL((case when isnull(CH.ysnQuantityAtHeaderLevel,0) = 1 then cds.dblHeaderBalance else CD.dblBalance end),0) - ISNULL((case when isnull(CH.ysnQuantityAtHeaderLevel,0) = 1 then cds.dblHeaderScheduleQty else CD.dblScheduleQty end),0)) ELSE LTRIM(ISNULL(CD.dblBalanceLoad,0) - ISNULL(CD.dblScheduleLoad,0)) END,
			@strBalanceQty			=	CASE WHEN ISNULL(ysnLoad,0) = 0 THEN LTRIM(ISNULL((case when isnull(CH.ysnQuantityAtHeaderLevel,0) = 1 then cds.dblHeaderBalance else CD.dblBalance end),0)) ELSE LTRIM(ISNULL(CD.intNoOfLoad,0)) END,
			@ysnLoad				=	CH.ysnLoad
	FROM	tblCTContractDetail	CD
	JOIN	tblCTContractHeader	CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId 
    cross apply (
		select
		dblHeaderBalance = CH.dblQuantity - sum(cd.dblQuantity - cd.dblBalance)
		,dblHeaderAvailable = CH.dblQuantity - (sum(cd.dblQuantity - cd.dblBalance) + sum(isnull(cd.dblScheduleQty,0)))
		,dblHeaderScheduleQty = sum(isnull(cd.dblScheduleQty,0))
		from tblCTContractDetail cd
		where cd.intContractHeaderId = CH.intContractHeaderId
    ) cds
	WHERE	intContractDetailId = @intContractDetailId
	
	IF	@dblScheduleQty + @dblQuantityToUpdate > @dblBalance 
	BEGIN
		IF @ysnUnlimitedQuantity = 1 OR @intPricingTypeId = 5
		BEGIN
			SET		@dblQuantityToIncrease	= (@dblBalance - (@dblScheduleQty + @dblQuantityToUpdate)) * -1

			EXEC	uspCTUpdateSequenceQuantity
					@intContractDetailId	=	@intContractDetailId,
					@dblQuantityToUpdate	=	@dblQuantityToIncrease,
					@intUserId				=	@intUserId,
					@intExternalId			=	@intExternalId,
					@strScreenName			=	@strScreenName

			GOTO BEGINING
		END
		ELSE IF @ysnAllowOverSchedule = 1
		BEGIN
			IF @dblQuantityToUpdate <= @dblBalance
			BEGIN
				SELECT @dblScheduleQty = (@dblQuantity + @dblQuantityToUpdate - @dblScheduleQty) - (@dblQuantity - @dblScheduleQty)
				SELECT @strReason = 'Over Schedule'
			END
			ELSE
			BEGIN
				if (@strBalanceQty is not null and (CHARINDEX('.',@strBalanceQty) + @intQuantityDecimals) > @intQuantityDecimals)begin select @strBalanceQty = SUBSTRING(@strBalanceQty,1,CHARINDEX('.',@strBalanceQty) + @intQuantityDecimals); end
				if (@strQuantityToUpdate is not null and (CHARINDEX('.',@strQuantityToUpdate) + @intQuantityDecimals) > @intQuantityDecimals)begin select @strQuantityToUpdate = SUBSTRING(@strQuantityToUpdate,1,CHARINDEX('.',@strQuantityToUpdate) + @intQuantityDecimals); end
				RAISERROR('Balance quantity for the contract %s and sequence %s is %s, which is insufficient to Save/Post a quantity of %s therefore could not Save/Post this transaction.',16,1,@strContractNumber,@strContractSeq,@strBalanceQty,@strQuantityToUpdate)
			END
		END
		ELSE
		BEGIN
			IF ((@dblScheduleQty + @dblQuantityToUpdate) - @dblBalance) > @dblTolerance
			BEGIN
				if (@strAvailableQty is not null and (CHARINDEX('.',@strAvailableQty) + @intQuantityDecimals) > @intQuantityDecimals)begin select @strAvailableQty = SUBSTRING(@strAvailableQty,1,CHARINDEX('.',@strAvailableQty) + @intQuantityDecimals); end
				if (@strQuantityToUpdate is not null and (CHARINDEX('.',@strQuantityToUpdate) + @intQuantityDecimals) > @intQuantityDecimals)begin select @strQuantityToUpdate = SUBSTRING(@strQuantityToUpdate,1,CHARINDEX('.',@strQuantityToUpdate) + @intQuantityDecimals); end
				RAISERROR('Available quantity for the contract %s and sequence %s is %s, which is insufficient to Save/Post a quantity of %s therefore could not Save/Post this transaction.',16,1,@strContractNumber,@strContractSeq,@strAvailableQty,@strQuantityToUpdate)
			END
			ELSE
			BEGIN
				SET @dblQuantityToUpdate = @dblQuantityToUpdate - ((@dblScheduleQty + @dblQuantityToUpdate) - @dblBalance)
			END
		END
	END
	
	IF	@dblScheduleQty + @dblQuantityToUpdate < 0 
	BEGIN
		IF @ysnAllowOverSchedule = 1
		BEGIN
			SET @dblScheduleQty = 0;
			SET @dblQuantityToUpdate = 0;
			SELECT @strReason = 'Over Schedule'
		END
		ELSE
		BEGIN
			IF ABS(@dblScheduleQty + @dblQuantityToUpdate) > @dblTolerance
			BEGIN
				IF @intContractStatusId IN (5,6) AND @strScreenName = 'Load Schedule'
				BEGIN
					SET @dblQuantityToUpdate = @dblQuantityToUpdate - (@dblScheduleQty + @dblQuantityToUpdate)
				END
				ELSE
				BEGIN
					SET @ErrMsg = 'Total scheduled quantity cannot be less than zero for contract '+@strContractNumber + ' and sequence ' +	@strContractSeq	+'.'
					RAISERROR(@ErrMsg,16,1)
				END
			END
			ELSE
			BEGIN
				SET @dblQuantityToUpdate = @dblQuantityToUpdate - (@dblScheduleQty + @dblQuantityToUpdate)
			END 
		END
	END
	
	SELECT	@dblNewScheduleQty =	(case when isnull(@ysnQuantityAtHeaderLevel,0) = 1 then @dblSequenceOrigSchedule else @dblScheduleQty end) + @dblQuantityToUpdate

	UPDATE 	tblCTContractDetail
	SET		dblScheduleQty		=	CASE WHEN ISNULL(@ysnLoad,0) = 0 THEN ISNULL(@dblNewScheduleQty,0) ELSE ISNULL(@dblNewScheduleQty,0) * ISNULL(dblQuantityPerLoad,0) END, 
			dblScheduleLoad		=	CASE WHEN ISNULL(@ysnLoad,0) = 0 THEN NULL ELSE ISNULL(@dblNewScheduleQty,0) END, 
			intConcurrencyId	=	intConcurrencyId + 1
	WHERE	intContractDetailId =	@intContractDetailId
	
	IF ISNULL(@intUserId,0) <> 0 AND ISNULL(@strScreenName,'') <> '' AND ISNULL(@intExternalId,0) <> 0 
	BEGIN
		EXEC	uspCTCreateSequenceUsageHistory 
				@intContractDetailId	=	@intContractDetailId,
				@strScreenName			=	@strScreenName,
				@intExternalId			=	@intExternalId,
				@strFieldName			=	'Scheduled Quantity',
				@dblOldValue			=	@dblOrgScheduleQty,
				@dblTransactionQuantity =	@dblQuantityToUpdate,
				@dblNewValue			=	@dblNewScheduleQty,	
				@intUserId				=	@intUserId,
				@strReason				=	@strReason,
				@dblBalance				=   @dblBalance,
				@intSequenceUsageHistoryId	=	@intSequenceUsageHistoryId	OUTPUT
	END

	EXEC	uspCTCreateDetailHistory	
			@intContractHeaderId		=	NULL,
			@intContractDetailId		=	@intContractDetailId,
			@strComment				    =	NULL,
			@intSequenceUsageHistoryId  =	@intSequenceUsageHistoryId,
			@strSource	 				= 	'Inventory',
			@strProcess 				= 	'Update Scheduled Quantity',
			@intUserId					= 	@intUserId


	exec uspCTUpdateAppliedAndPrice
		@intContractDetailId = @intContractDetailId
		,@dblBalance = @dblBalance



END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
	
END CATCH
GO