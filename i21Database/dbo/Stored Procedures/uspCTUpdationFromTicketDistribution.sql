CREATE PROCEDURE uspCTUpdationFromTicketDistribution

	@intTicketId			INT,
	@intEntityId			INT,
	@dblNetUnits			NUMERIC(18,6),
	@intContractDetailId	INT,
	@intUserId				INT,
	@ysnDP					BIT
	
AS

BEGIN TRY
	
	DECLARE @ErrMsg					NVARCHAR(MAX),
			@dblBalance				NUMERIC(18,6),			
			@dblAvailable			NUMERIC(18,6),	
			@intItemId				INT,
			@dblNewBalance			NUMERIC(18,6),
			@strInOutFlag			NVARCHAR(4),
			@dblQuantity			NUMERIC(18,6),
			@strAdjustmentNo		NVARCHAR(50),
			@dblCost				NUMERIC(18,6),
			@ApplyScaleToBasis		BIT,
			@intContractHeaderId	INT,
			@ysnAllowedToShow		BIT,
			@ysnUnlimitedQuantity	BIT,
			@strContractStatus		NVARCHAR(MAX)

	DECLARE @Processed TABLE
	(
			intContractDetailId INT,
			dblUnitsDistributed NUMERIC(18,6),
			dblUnitsRemaining	NUMERIC(18,6),
			dblOldQuantity		NUMERIC(18,6),
			dblOldBalance		NUMERIC(18,6),			
			dblAdjAmount		NUMERIC(18,6),			
			dblNewBalance		NUMERIC(18,6),				
			dblNewQuantity		NUMERIC(18,6),	
			strAdjustmentNo		NVARCHAR(50),
			dblCost				NUMERIC(18,6)
	)			
	
	IF NOT EXISTS(SELECT * FROM tblSCTicket WHERE intTicketId = @intTicketId)
	BEGIN
		RAISERROR ('Ticket is deleted by other user.',16,1,'WITH NOWAIT')  
	END
	
	SELECT	@intItemId		=	intItemId,
			@strInOutFlag	=	strInOutFlag 
	FROM	tblSCTicket
	WHERE	intTicketId = @intTicketId
	
	SELECT	@ApplyScaleToBasis = CAST(strValue AS BIT) FROM tblSMPreferences WHERE strPreference = 'ApplyScaleToBasis'
	SELECT	@ApplyScaleToBasis = ISNULL(@ApplyScaleToBasis,0)

	IF	ISNULL(@intContractDetailId,0) > 0
	BEGIN
		SELECT	@ysnAllowedToShow	=	ysnAllowedToShow,
				@strContractStatus	=	strContractStatus 
		FROM	vyuCTContractDetailView
		WHERE	intContractDetailId =	@intContractDetailId

		IF	ISNULL(@ysnAllowedToShow,0) = 0
		BEGIN
			SET @ErrMsg = 'Using of contract having status '''+@strContractStatus+''' is not allowed.'
			RAISERROR(@ErrMsg,16,1)
		END
	END

	IF	@ysnDP = 1 AND ISNULL(@intContractDetailId,0) = 0
	BEGIN
		SELECT	TOP	1	@intContractDetailId	=	intContractDetailId
		FROM	vyuCTContractDetailView CD
		WHERE	CD.intContractTypeId	=	CASE WHEN @strInOutFlag = 'I' THEN 1 ELSE 2 END
		AND		CD.intEntityId			=	@intEntityId
		AND		CD.intItemId			=	@intItemId
		AND		CD.intPricingTypeId		=	5
		AND		CD.ysnAllowedToShow		=	1
		ORDER BY CD.dtmStartDate, CD.intContractDetailId ASC

		IF	ISNULL(@intContractDetailId,0) = 0
		BEGIN
			RAISERROR ('No DP contract available.',16,1,'WITH NOWAIT')  
		END
	END

	IF	ISNULL(@intContractDetailId,0) = 0
	BEGIN
		SELECT	TOP	1	
				@intContractDetailId	=	CD.intContractDetailId,
				@intContractHeaderId	=	CD.intContractHeaderId
		FROM	vyuCTContractDetailView CD
		WHERE	CD.intContractTypeId	=	CASE WHEN @strInOutFlag = 'I' THEN 1 ELSE 2 END
		AND		CD.intEntityId			=	@intEntityId
		AND		CD.intItemId			=	@intItemId
		AND		CD.intPricingTypeId		=	1
		AND		CD.ysnAllowedToShow		=	1
		AND		(CD.dblAvailableQty		>	0 OR CD.ysnUnlimitedQuantity = 1)
		AND		CD.ysnEarlyDayPassed	=	1
		ORDER BY CD.dtmStartDate, CD.intContractDetailId ASC
	END
	
	IF	ISNULL(@intContractDetailId,0) = 0
	BEGIN
		SELECT	TOP	1	
				@intContractDetailId	=	intContractDetailId
		FROM	vyuCTContractDetailView CD
		WHERE	CD.intContractTypeId	=	CASE WHEN @strInOutFlag = 'I' THEN 1 ELSE 2 END
		AND		CD.intEntityId			=	@intEntityId
		AND		CD.intItemId			=	@intItemId
		AND	    (CD.intPricingTypeId	=	1 OR CD.intPricingTypeId = CASE WHEN @ApplyScaleToBasis = 0 THEN 1 ELSE 2 END)
		AND		CD.ysnAllowedToShow		=	1
		AND		(CD.dblAvailableQty		>	0 OR CD.ysnUnlimitedQuantity = 1)
		AND		CD.ysnEarlyDayPassed	=	1
		ORDER BY CD.dtmStartDate, CD.intContractDetailId ASC
	END
		
	WHILE	@dblNetUnits > 0 AND ISNULL(@intContractDetailId,0) > 0
	BEGIN
		SELECT	@dblBalance		=	NULL,
				@dblQuantity	=	NULL,
				@dblCost		=	NULL,
				@dblAvailable	=	NULL,
				@ysnUnlimitedQuantity = NULL

		SELECT	@dblBalance		=	CD.dblBalance,
				@dblQuantity	=	CD.dblQuantity,
				@dblCost		=	ISNULL(CD.dblBasis,0) + ISNULL(CD.dblFutures,0),
				@dblAvailable	=	ISNULL(CD.dblBalance,0) - ISNULL(CD.dblScheduleQty,0),
				@ysnUnlimitedQuantity = CH.ysnUnlimitedQuantity
		FROM	tblCTContractDetail CD
		JOIN	tblCTContractHeader CH	ON CH.intContractHeaderId = CD.intContractHeaderId 
		WHERE	CD.intContractDetailId = @intContractDetailId

		IF @ysnDP = 1
		BEGIN
			
			SELECT	@strAdjustmentNo = strPrefix+LTRIM(intNumber) 
			FROM	tblSMStartingNumber 
			WHERE	strModule = 'Contract Management' AND strTransactionType = 'ContractAdjNo'

			UPDATE	tblSMStartingNumber
			SET		intNumber = intNumber+1
			WHERE	strModule = 'Contract Management' AND strTransactionType = 'ContractAdjNo'
			

			UPDATE	tblCTContractDetail 
			SET		dblBalance	= dblBalance + @dblNetUnits,
					dblQuantity = dblQuantity + @dblNetUnits
			WHERE	intContractDetailId = @intContractDetailId
			
			UPDATE	tblCTContractHeader
			SET		dblQuantity = dblQuantity + @dblNetUnits
			WHERE	intContractHeaderId = @intContractHeaderId

			INSERT	INTO @Processed SELECT @intContractDetailId,@dblNetUnits,NULL,@dblQuantity,@dblBalance,@dblNetUnits,@dblBalance - @dblNetUnits,@dblQuantity,@strAdjustmentNo,@dblCost

			SELECT	@dblNetUnits = 0

			UPDATE	@Processed SET dblUnitsRemaining = @dblNetUnits
			
			EXEC	uspCTUpdateSequenceBalance 
					@intContractDetailId	=	@intContractDetailId,
					@dblQuantityToUpdate	=	@dblNetUnits,
					@intUserId				=	@intUserId,
					@intExternalId			=	@intTicketId,
					@strScreenName			=	'Scale'

			BREAK
		END

		IF NOT @dblAvailable > 0
		BEGIN
			GOTO CONTINUEISH
		END

		IF	@dblNetUnits <= @dblAvailable OR @ysnUnlimitedQuantity = 1
		BEGIN
			INSERT	INTO @Processed SELECT @intContractDetailId,@dblNetUnits,NULL,@dblQuantity,@dblAvailable,@dblNetUnits,@dblAvailable - @dblNetUnits,@dblQuantity,@strAdjustmentNo,@dblCost

			SELECT	@dblNetUnits = 0

			BREAK
		END
		ELSE
		BEGIN
			INSERT	INTO @Processed SELECT @intContractDetailId,@dblAvailable,NULL,@dblQuantity,@dblAvailable,@dblAvailable,0,@dblQuantity,@strAdjustmentNo,@dblCost

			SELECT	@dblNetUnits	=	@dblNetUnits - @dblAvailable					
		END
		
		CONTINUEISH:

		SELECT	@intContractDetailId = NULL
		
		SELECT	TOP	1	
				@intContractDetailId	=	intContractDetailId
		FROM	vyuCTContractDetailView CD
		WHERE	CD.intContractTypeId	=	CASE WHEN @strInOutFlag = 'I' THEN 1 ELSE 2 END
		AND		CD.intEntityId			=	@intEntityId
		AND		CD.intItemId			=	@intItemId
		AND		CD.intPricingTypeId		=	1
		AND		CD.ysnAllowedToShow		=	1
		AND		(CD.dblAvailableQty		>	0 OR CD.ysnUnlimitedQuantity = 1)
		AND		CD.ysnEarlyDayPassed	=	1
		AND		CD.intContractDetailId NOT IN (SELECT intContractDetailId FROM @Processed)
		ORDER 
		BY		CD.dtmStartDate, CD.intContractDetailId ASC

		IF	ISNULL(@intContractDetailId,0) = 0
		BEGIN
			SELECT	TOP	1	
					@intContractDetailId	=	intContractDetailId
			FROM	vyuCTContractDetailView CD
			WHERE	CD.intContractTypeId	=	CASE WHEN @strInOutFlag = 'I' THEN 1 ELSE 2 END
			AND		CD.intEntityId			=	@intEntityId
			AND		CD.intItemId			=	@intItemId
			AND	   (CD.intPricingTypeId		=	1 OR CD.intPricingTypeId = CASE WHEN @ApplyScaleToBasis = 0 THEN 1 ELSE 2 END)
			AND		CD.ysnAllowedToShow		=	1
			AND		(CD.dblAvailableQty		>	0 OR CD.ysnUnlimitedQuantity = 1)
			AND		CD.ysnEarlyDayPassed	=	1
			AND		CD.intContractDetailId NOT IN (SELECT intContractDetailId FROM @Processed)
			ORDER 
			BY		CD.dtmStartDate, CD.intContractDetailId ASC
		END
	END	
	
	UPDATE	@Processed SET dblUnitsRemaining = @dblNetUnits
	
	SELECT	intContractDetailId,
			dblUnitsDistributed,
			dblUnitsRemaining,
			dblCost
	FROM	@Processed
	
END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
	
END CATCH
GO