CREATE PROCEDURE uspCTUpdationFromTicketDistribution

	@intTicketId			INT,
	@intEntityId			INT,
	@dblNetUnits			NUMERIC(18,6),
	@intContractDetailId	INT,
	@intUserId				INT,
	@ysnDP					BIT,
	@ysnDeliverySheet		BIT = 0,
	@ysnAutoDistribution	BIT = 1
	
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
			@strContractStatus		NVARCHAR(MAX),
			@intScaleUOMId			INT,
			@intScaleUnitMeasureId	INT,
			@intItemUOMId			INT,
			@intNewContractHeaderId	INT,
			@ysnAutoCreateDP		BIT,
			@strScreenName			NVARCHAR(20),
			@XML					NVARCHAR(MAX),
			@dtmEndDate				DATETIME,
			@intContractTypeId		INT,
			@intCommodityId			INT,
			@strSeqMonth			NVARCHAR(50),
			@UseScheduleForAvlCalc	BIT = 1,
			@dblScheduleQty			NUMERIC(18,6),
			@dblInreaseSchBy		NUMERIC(18,6),
			@intStorageScheduleTypeId	INT,
			@ysnLoad				BIT,
			@dblBalanceLoad			NUMERIC(18,6),
			@ysnAutoIncreaseQty		BIT = 0,
			@ysnAutoIncreaseSchQty	BIT = 0,
			@intTicketContractDetailId INT
	
	SET @ErrMsg =	'uspCTUpdationFromTicketDistribution '+ 
					LTRIM(@intTicketId) +',' + 
					LTRIM(@intEntityId) +',' +
					LTRIM(ISNULL(@dblNetUnits,0)) +',' +
					LTRIM(ISNULL(@intContractDetailId,0)) +',' +
					LTRIM(ISNULL(@intUserId,0)) +',' +			
					LTRIM(ISNULL(@ysnDP,0)) +',' +				
					LTRIM(ISNULL(@ysnDeliverySheet,0))	
	PRINT(@ErrMsg)

	DECLARE @Processed TABLE
	(
			intContractDetailId INT,
			dblUnitsDistributed NUMERIC(18,6),
			dblUnitsRemaining	NUMERIC(18,6),
			dblCost				NUMERIC(18,6),
			ysnIgnore			BIT
	)			
	
	SELECT	@ysnAutoCreateDP = ysnAutoCreateDP FROM tblCTCompanyPreference
	SELECT  @intTicketContractDetailId = intContractId, @intStorageScheduleTypeId = intStorageScheduleTypeId, @UseScheduleForAvlCalc = CASE WHEN intStorageScheduleTypeId = -6 THEN 0 ELSE 1 END FROM tblSCTicket WHERE intTicketId = @intTicketId

	IF @ysnDeliverySheet = 0
		BEGIN
			IF NOT EXISTS(SELECT * FROM tblSCTicket WHERE intTicketId = @intTicketId)
			BEGIN
				RAISERROR ('Ticket is deleted by other user.',16,1,'WITH NOWAIT')  
			END
			
			SELECT	@intItemId		=	intItemId,
					@strInOutFlag	=	strInOutFlag 
			FROM	tblSCTicket
			WHERE	intTicketId		=	@intTicketId

			SELECT  @intScaleUOMId			=	IU.intItemUOMId,
					@intScaleUnitMeasureId  =   IU.intUnitMeasureId
			FROM    tblICItemUOM	IU    
			JOIN	tblSCTicket		SC	ON	SC.intItemId = IU.intItemId  
			WHERE   SC.intTicketId = @intTicketId AND IU.ysnStockUnit = 1
		END
	ELSE
		BEGIN
			IF NOT EXISTS(SELECT * FROM tblSCDeliverySheet WHERE intDeliverySheetId = @intTicketId)
			BEGIN
				RAISERROR ('Delivery Sheet is deleted by other user.',16,1,'WITH NOWAIT')  
			END

			SELECT	@intItemId				=	SCD.intItemId,
					@strInOutFlag			= CASE WHEN SCD.intTicketTypeId = 1 THEN 'I' ELSE 'O' END,
					@intScaleUOMId			=	IUOM.intItemUOMId,
					@intScaleUnitMeasureId  =   IUOM.intUnitMeasureId
			FROM	tblSCDeliverySheet SCD
			INNER JOIN tblICItemUOM IUOM ON IUOM.intItemId = SCD.intItemId
			WHERE	SCD.intDeliverySheetId = @intTicketId AND IUOM.ysnStockUnit = 1
		END

	SELECT	@ApplyScaleToBasis = ISNULL(ysnApplyScaleToBasis,0) FROM tblCTCompanyPreference

	IF	ISNULL(@intContractDetailId,0) > 0
	BEGIN
		SELECT	@ysnAllowedToShow	=	ysnAllowedToShow,
				@strContractStatus	=	strContractStatus,
				@ysnLoad			=	ysnLoad
		FROM	vyuCTContractDetailView
		WHERE	intContractDetailId =	@intContractDetailId

		SELECT  @ysnAutoIncreaseQty = CASE WHEN intStorageScheduleTypeId = -6 AND @ysnLoad = 1 THEN 1 ELSE 0 END FROM tblSCTicket WHERE intTicketId = @intTicketId
		SELECT  @ysnAutoIncreaseSchQty = CASE WHEN intStorageScheduleTypeId = -6 THEN 1 ELSE 0 END FROM tblSCTicket WHERE intTicketId = @intTicketId

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
			IF ISNULL(@ysnAutoCreateDP ,0) = 1
			BEGIN
				SET @strScreenName = CASE WHEN ISNULL(@ysnDeliverySheet,0) = 0 THEN 'Scale' ELSE 'Delivery Sheet' END
				SET @XML = '<overrides><intEntityId>' + LTRIM(@intEntityId) + '</intEntityId></overrides>'
				
				EXEC uspCTCreateContract @intTicketId,@strScreenName,@intUserId,@XML,@intNewContractHeaderId OUTPUT
				
				SELECT	@intContractDetailId	=	intContractDetailId, 
						@intContractTypeId		=	intContractTypeId,
						@intCommodityId			=	intCommodityId,
						@strSeqMonth			=	RIGHT(CONVERT(varchar, dtmEndDate, 106),8),
						@intItemId				=	intItemId
				FROM	vyuCTContractSequence 
				WHERE	intContractHeaderId = @intNewContractHeaderId

				IF OBJECT_ID('tempdb..#FutureAndBasisPrice') IS NOT NULL  						
					DROP TABLE #FutureAndBasisPrice						

				SELECT * INTO #FutureAndBasisPrice FROM dbo.fnRKGetFutureAndBasisPrice(@intContractTypeId,@intCommodityId,@strSeqMonth,3,null,null,null,null,0,@intItemId,null)

				IF NOT EXISTS(SELECT * FROM #FutureAndBasisPrice)
				BEGIN
					RAISERROR ('Settlement price in risk management is not available. Cannot create DP contract.',16,1,'WITH NOWAIT') 
				END

				IF EXISTS(SELECT * FROM #FutureAndBasisPrice WHERE ISNULL(dblSettlementPrice,0) = 0)
				BEGIN
					RAISERROR ('Settlement price in risk management is not available. Cannot create DP contract.',16,1,'WITH NOWAIT') 
				END
				
				IF EXISTS(SELECT * FROM #FutureAndBasisPrice WHERE ISNULL(dblBasis,0) = 0)
				BEGIN
					RAISERROR ('Basis price in risk management is not available. Cannot create DP contract.',16,1,'WITH NOWAIT') 
				END

				IF EXISTS(SELECT * FROM #FutureAndBasisPrice WHERE ISNULL(intSettlementUOMId,0) = 0)
				BEGIN
					RAISERROR ('Settlement UOM in risk management is not available. Cannot create DP contract.',16,1,'WITH NOWAIT') 
				END

				IF EXISTS(SELECT * FROM #FutureAndBasisPrice WHERE ISNULL(intBasisUOMId,0) = 0)
				BEGIN
					RAISERROR ('Basis UOM in risk management is not available. Cannot create DP contract.',16,1,'WITH NOWAIT') 
				END
			END
			IF	ISNULL(@intContractDetailId,0) = 0
			BEGIN
				RAISERROR ('No DP contract available.',16,1,'WITH NOWAIT') 
			END 
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

		SELECT	@intContractHeaderId = CD.intContractHeaderId,
				@dblBalance		=	dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,@intScaleUOMId,CD.dblBalance),
				@dblQuantity	=	dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,@intScaleUOMId,CD.dblQuantity),
				@dblCost		=	CASE	WHEN	CD.intPricingTypeId = 2
											THEN	ISNULL(dblSeqBasis,0)
											WHEN	CD.intPricingTypeId = 3
											THEN	ISNULL(dblSeqFutures,0)
											ELSE	ISNULL(CD.dblCashPrice,0)
									END,
				@dblAvailable	=	CASE	WHEN	@UseScheduleForAvlCalc = 1 
											THEN	dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,@intScaleUOMId,ISNULL(CD.dblBalance,0) - ISNULL(CD.dblScheduleQty,0))
											ELSE	dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,@intScaleUOMId,ISNULL(CD.dblBalance,0))
									END,
				@ysnUnlimitedQuantity = CH.ysnUnlimitedQuantity,
				@intItemUOMId	=	CD.intItemUOMId,
				@dblScheduleQty	=	ISNULL(CD.dblScheduleQty,0),
				@ysnLoad		=	ISNULL(CH.ysnLoad,0),
				@dblBalanceLoad = ISNULL(CD.dblBalanceLoad,0)
		FROM	tblCTContractDetail CD
		JOIN	tblCTContractHeader CH	ON CH.intContractHeaderId = CD.intContractHeaderId 
 CROSS  APPLY	dbo.fnCTGetAdditionalColumnForDetailView(CD.intContractDetailId) AD
		WHERE	CD.intContractDetailId = @intContractDetailId

		IF @ysnDP = 1
		BEGIN

			SELECT @dblNetUnits = dbo.fnCTConvertQtyToTargetItemUOM(@intScaleUOMId,@intItemUOMId,@dblNetUnits)			
			
			INSERT	INTO @Processed SELECT @intContractDetailId,0,NULL,@dblCost,0

			--EXEC	uspCTUpdateSequenceQuantity 
			--		@intContractDetailId	=	@intContractDetailId,
			--		@dblQuantityToUpdate	=	@dblNetUnits,
			--		@intUserId				=	@intUserId,
			--		@intExternalId			=	@intTicketId,
			--		@strScreenName			=	'Scale'

			SELECT	@dblNetUnits = 0

			BREAK
		END

		IF @ysnLoad = 1 AND @intStorageScheduleTypeId = -6
		BEGIN
			IF @dblBalanceLoad > 0
			BEGIN
				INSERT	INTO @Processed SELECT @intContractDetailId,@dblNetUnits,NULL,@dblCost,0
				SELECT @dblNetUnits = 0
				BREAK
			END
			ELSE
			BEGIN
				INSERT	INTO @Processed (intContractDetailId,ysnIgnore) SELECT @intContractDetailId,1
				GOTO CONTINUEISH
			END
		END
		IF NOT @dblAvailable > 0
		BEGIN
			INSERT	INTO @Processed (intContractDetailId,ysnIgnore) SELECT @intContractDetailId,1
			GOTO CONTINUEISH
		END

		IF	@dblNetUnits <= @dblAvailable OR @ysnUnlimitedQuantity = 1
		BEGIN
			INSERT	INTO @Processed SELECT @intContractDetailId,@dblNetUnits,NULL,@dblCost,0
			IF (@ysnAutoIncreaseQty = 1 OR @ysnAutoIncreaseSchQty = 1) AND  @dblScheduleQty < @dblNetUnits AND @intTicketContractDetailId = @intContractDetailId
			BEGIN
				SET @dblInreaseSchBy  = @dblNetUnits - @dblScheduleQty
				EXEC	uspCTUpdateScheduleQuantity 
						@intContractDetailId	=	@intContractDetailId,
						@dblQuantityToUpdate	=	@dblInreaseSchBy,
						@intUserId				=	@intUserId,
						@intExternalId			=	@intTicketId,
						@strScreenName			=	'Auto - Scale'
			END

			SELECT	@dblNetUnits = 0

			BREAK
		END
		ELSE
		BEGIN
			IF @ysnAutoIncreaseQty = 1
			BEGIN
				SET		@dblInreaseSchBy  = @dblNetUnits - @dblAvailable

				EXEC	uspCTUpdateSequenceQuantity 
						@intContractDetailId	=	@intContractDetailId,
						@dblQuantityToUpdate	=	@dblInreaseSchBy,
						@intUserId				=	@intUserId,
						@intExternalId			=	@intTicketId,
						@strScreenName			=	'Scale'

				EXEC	uspCTUpdateScheduleQuantity 
						@intContractDetailId	=	@intContractDetailId,
						@dblQuantityToUpdate	=	@dblInreaseSchBy,
						@intUserId				=	@intUserId,
						@intExternalId			=	@intTicketId,
						@strScreenName			=	'Auto - Scale'

				INSERT	INTO @Processed SELECT @intContractDetailId,@dblNetUnits,NULL,@dblCost,0
				SELECT	@dblNetUnits = 0
				BREAK
			END		
			ELSE
			BEGIN
				INSERT	INTO @Processed SELECT @intContractDetailId,@dblAvailable,NULL,@dblCost,0
			
				SELECT	@dblNetUnits	=	@dblNetUnits - @dblAvailable			
			END
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
	
	IF(		SELECT	MAX(dblUnitsRemaining) 
			FROM	@Processed	PR
			JOIN	tblCTContractDetail	CD	ON	CD.intContractDetailId	=	PR.intContractDetailId
			WHERE	ISNULL(ysnIgnore,0) <> 1) > 0 AND @ysnAutoDistribution = 1
	BEGIN
		RAISERROR ('The entire ticket quantity can not be applied to the contract.',16,1,'WITH NOWAIT') 
	END

	SELECT	PR.intContractDetailId,
			PR.dblUnitsDistributed,
			PR.dblUnitsRemaining,
			PR.dblCost,
			CD.intInvoiceCurrencyId
	FROM	@Processed	PR
	JOIN	tblCTContractDetail	CD	ON	CD.intContractDetailId	=	PR.intContractDetailId
	WHERE	ISNULL(ysnIgnore,0) <> 1
	
END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
	
END CATCH
GO