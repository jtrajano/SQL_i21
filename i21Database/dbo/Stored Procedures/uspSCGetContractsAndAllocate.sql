CREATE PROCEDURE uspSCGetContractsAndAllocate

	@intTicketId			INT,
	@intEntityId			INT,
	@dblNetUnits			NUMERIC(18,6),
	@intContractDetailId	INT,
	@intUserId				INT,
	@ysnDP					BIT,
	@ysnDeliverySheet		BIT = 0,
	@ysnAutoDistribution	BIT = 1,
	@strDistributionOption AS NVARCHAR(3)	 = ''
	,@intLoadDetailId		INT = NULL
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
			@ysnLoad				BIT,
			@dblBalanceLoad			NUMERIC(18,6),
			@ysnAutoIncreaseQty		BIT = 0, 
			@ysnAutoIncreaseSchQty	BIT = 0,
			@intTicketContractDetailId INT,
			@dblNetUnitsToCompare	NUMERIC(18,6),
			@intDistributionMethod	INT,
			@locationId				INT

	DECLARE @dblTicketScheduledQuantity NUMERIC(18,6)
	DECLARE @intTicketLoadDetailId	INT
	DECLARE @intLoadId	INT
	DECLARE @LoadContractsDetailId Id
	DECLARE @LoadDetailUsedId Id
	
	SET @ErrMsg =	'uspSCGetContractsAndAllocate '+ 
					LTRIM(@intTicketId) +',' + 
					LTRIM(@intEntityId) +',' +
					LTRIM(ISNULL(@dblNetUnits,0)) +',' +
					LTRIM(ISNULL(@intContractDetailId,0)) +',' +
					LTRIM(ISNULL(@intUserId,0)) +',' +			
					LTRIM(ISNULL(@ysnDP,0)) +',' +				
					LTRIM(ISNULL(@ysnDeliverySheet,0)) +',' +	
					LTRIM(ISNULL(@ysnAutoDistribution,0))	+',' +
					'''' + LTRIM(ISNULL(@strDistributionOption,0))	+''',' +
					LTRIM(ISNULL(@intLoadDetailId,0))	
	PRINT(@ErrMsg)

	DECLARE @Processed TABLE
	(
			intContractDetailId INT,
			dblUnitsDistributed NUMERIC(18,6),
			dblUnitsRemaining	NUMERIC(18,6),
			dblCost				NUMERIC(18,6),
			ysnIgnore			BIT,
			intLoadDetailId		INT
	)			
	
	DECLARE @LoadDetailTable TABLE
	(
		intLoadDetailId INT,
		intContractDetailId INT
	)

	SELECT	@ysnAutoCreateDP = ysnAutoCreateDP FROM tblCTCompanyPreference
	/*
		Manual		1 
		Auto		2 
		Batch		3 
		In Transit	4
		Print Only	5
	*/
	SELECT  @intDistributionMethod = intDistributionMethod
		, @intTicketContractDetailId = intContractId
		, @UseScheduleForAvlCalc = CASE WHEN intStorageScheduleTypeId = -6 THEN 0 ELSE 1 END 
		,@intTicketLoadDetailId = intLoadDetailId
		,@dblTicketScheduledQuantity = dblScheduleQty
	FROM tblSCTicket 
	WHERE intTicketId = @intTicketId

	IF @ysnDeliverySheet = 0
		BEGIN
			IF NOT EXISTS(SELECT * FROM tblSCTicket WHERE intTicketId = @intTicketId)
			BEGIN
				RAISERROR ('Ticket is deleted by other user.',16,1,'WITH NOWAIT')  
			END
			
			SELECT	@intItemId		=	intItemId,
					@strInOutFlag	=	strInOutFlag,
					@locationId		=	intProcessingLocationId
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

	--Get all contract used for the load shipment if load type distribution
	IF(@strDistributionOption = 'LOD')
	BEGIN
		INSERT INTO @LoadContractsDetailId
		SELECT CASE WHEN @strInOutFlag = 'I' THEN intPContractDetailId ELSE intSContractDetailId END
		FROM tblLGLoadDetail
		WHERE intLoadId = (SELECT TOP 1 intLoadId FROM tblLGLoadDetail WHERE intLoadDetailId = @intLoadDetailId)
	END

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

	---DP 
	IF	@ysnDP = 1 AND ISNULL(@intContractDetailId,0) = 0
	BEGIN
		SELECT	TOP	1	@intContractDetailId	=	intContractDetailId
		FROM	vyuCTContractDetailView CD
		WHERE	CD.intContractTypeId	=	CASE WHEN @strInOutFlag = 'I' THEN 1 ELSE 2 END
		AND		CD.intEntityId			=	@intEntityId
		AND		CD.intItemId			=	@intItemId
		AND		CD.intPricingTypeId		=	5
		AND		CD.ysnAllowedToShow		=	1
		ORDER BY CD.dtmStartDate DESC

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

				SELECT * INTO #FutureAndBasisPrice FROM dbo.fnRKGetFutureAndBasisPrice(@intContractTypeId,@intCommodityId,@strSeqMonth,3,null,null,@locationId,null,0,@intItemId,null)

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
				@dblAvailable	=	CASE	WHEN	@UseScheduleForAvlCalc = 1 --OR @intContractDetailId <> @intTicketContractDetailId
											THEN	dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,@intScaleUOMId,ISNULL(CD.dblBalance,0) - ISNULL(CD.dblScheduleQty,0))
											ELSE	dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,@intScaleUOMId,ISNULL(CD.dblBalance,0))
									END,
				@ysnUnlimitedQuantity = CH.ysnUnlimitedQuantity,
				@intItemUOMId	=	CD.intItemUOMId,
				@dblScheduleQty	=	ISNULL(CD.dblScheduleQty,0),
				@ysnLoad		=	ISNULL(CH.ysnLoad,0),
				@dblBalanceLoad = ISNULL(CD.dblBalanceLoad,0)
		FROM	tblCTContractDetail CD
		INNER JOIN	tblCTContractHeader CH	ON CH.intContractHeaderId = CD.intContractHeaderId 
		CROSS  APPLY	dbo.fnCTGetAdditionalColumnForDetailView(CD.intContractDetailId) AD
		WHERE	CD.intContractDetailId = @intContractDetailId

		SELECT @dblNetUnitsToCompare = dbo.fnCTConvertQtyToTargetItemUOM(@intScaleUOMId,@intItemUOMId,@dblNetUnits)

		IF @ysnDP = 1
		BEGIN

			SELECT @dblNetUnits = dbo.fnCTConvertQtyToTargetItemUOM(@intScaleUOMId,@intItemUOMId,@dblNetUnits)			
			
			INSERT	INTO @Processed SELECT @intContractDetailId,0,NULL,@dblCost,0,NULL

			SELECT	@dblNetUnits = 0

			BREAK
		END
		
		SET @dblNetUnits = @dblNetUnitsToCompare

		/*Fixes for CT-3365 always accept ticket if contract is load base and with remaining load balance*/
		IF @ysnLoad = 1-- AND @intStorageScheduleTypeId = -6
		BEGIN
			IF @dblBalanceLoad > 0
			BEGIN
				INSERT	INTO @Processed SELECT @intContractDetailId,@dblNetUnits,NULL,@dblCost,0,NULL
				SELECT @dblNetUnits = 0
				BREAK
			END
			ELSE
			BEGIN
				INSERT	INTO @Processed (intContractDetailId,ysnIgnore) SELECT @intContractDetailId,1
				GOTO CONTINUEISH
			END
		END
		IF NOT (@dblAvailable > 0 OR (@strDistributionOption = 'CNT' AND @intContractDetailId = @intTicketContractDetailId AND (@dblAvailable + ISNULL(@dblTicketScheduledQuantity,0)) > 0 ))
		BEGIN
			INSERT	INTO @Processed (intContractDetailId,ysnIgnore) SELECT @intContractDetailId,1
			GOTO CONTINUEISH
		END

		IF	@dblNetUnits <= @dblAvailable OR @ysnUnlimitedQuantity = 1
			OR (@strDistributionOption = 'CNT' AND @intContractDetailId = @intTicketContractDetailId AND @dblNetUnits <= (@dblAvailable + ISNULL(@dblTicketScheduledQuantity,0)) )
		BEGIN
			INSERT	INTO @Processed SELECT @intContractDetailId,@dblNetUnits,NULL,@dblCost,0,@intLoadDetailId
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
			ELSE
			BEGIN
				IF(@strDistributionOption = 'LOD') AND @dblScheduleQty > @dblNetUnits AND @intContractDetailId = @intTicketContractDetailId
				BEGIN 
					-- REmove all the remaining scheduled quantity for the LS
					SET @dblInreaseSchBy  = (@dblScheduleQty - @dblNetUnits) * -1
					IF(@dblInreaseSchBy <> 0)
					BEGIN
						EXEC	uspCTUpdateScheduleQuantity 
								@intContractDetailId	=	@intContractDetailId,
								@dblQuantityToUpdate	=	@dblInreaseSchBy,
								@intUserId				=	@intUserId,
								@intExternalId			=	@intTicketId,
								@strScreenName			=	'Auto - Scale'
					END
				END
				ELSE
				BEGIN
					
					IF(@intContractDetailId = @intTicketContractDetailId)
					BEGIN
						-- Adjust the scheduled quantity based on the ticket scheduled and net units
						SET @dblInreaseSchBy  = @dblNetUnits - ISNULL(@dblTicketScheduledQuantity,0)
						IF(@dblInreaseSchBy <> 0)
						BEGIN
							EXEC	uspCTUpdateScheduleQuantity 
									@intContractDetailId	=	@intContractDetailId,
									@dblQuantityToUpdate	=	@dblInreaseSchBy,
									@intUserId				=	@intUserId,
									@intExternalId			=	@intTicketId,
									@strScreenName			=	'Auto - Scale'
						END
					END
				END
			END


			SELECT	@dblNetUnits = 0

			BREAK
		END
		----Overage Scenario
		ELSE
		BEGIN
			IF @ysnAutoIncreaseQty = 1
			BEGIN
				SET		@dblInreaseSchBy  = @dblNetUnitsToCompare - @dblAvailable

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

				INSERT	INTO @Processed SELECT @intContractDetailId,@dblNetUnits,NULL,@dblCost,0,@intLoadDetailId
				SELECT	@dblNetUnits = 0
				BREAK
			END		
			ELSE
			BEGIN
				IF(@strDistributionOption = 'LOD')
				BEGIN
				
					IF(@intContractDetailId = @intTicketContractDetailId OR @intLoadDetailId IS NOT NULl)
					BEGIN
						SET @dblInreaseSchBy  = @dblAvailable - @dblScheduleQty
					END
					ELSE
					BEGIN
						SET @dblInreaseSchBy  = @dblAvailable
					END

					EXEC	uspCTUpdateScheduleQuantity 
							@intContractDetailId	=	@intContractDetailId,
							@dblQuantityToUpdate	=	@dblInreaseSchBy,
							@intUserId				=	@intUserId,
							@intExternalId			=	@intTicketId,
							@strScreenName			=	'Auto - Scale'
				
				END
				ELSE
				BEGIN
					IF @intDistributionMethod = 1 AND @dblScheduleQty < @dblAvailable AND @ysnAutoIncreaseSchQty = 1
					BEGIN
						SET @dblInreaseSchBy  = @dblAvailable - @dblScheduleQty
						EXEC	uspCTUpdateScheduleQuantity 
								@intContractDetailId	=	@intContractDetailId,
								@dblQuantityToUpdate	=	@dblInreaseSchBy,
								@intUserId				=	@intUserId,
								@intExternalId			=	@intTicketId,
								@strScreenName			=	'Auto - Scale'
					END
				END
				INSERT	INTO @Processed SELECT @intContractDetailId,@dblAvailable,NULL,@dblCost,0,@intLoadDetailId

				SELECT	@dblNetUnits	=	@dblNetUnits - @dblAvailable			
			END
		END
		
		CONTINUEISH:

		SELECT	@intContractDetailId = NULL
		

		IF(@strDistributionOption = 'LOD')
		BEGIN

			INSERT INTO @LoadDetailUsedId
			SELECT @intLoadDetailId
			WHERE NOT EXISTS(SELECT TOP 1 1 FROM @LoadDetailUsedId WHERE intId = @intLoadDetailId)
	
			IF(EXISTS(SELECT TOP 1 1 FROM @LoadDetailTable))
			BEGIN
				DELETE FROM @LoadDetailTable
			END

			SELECT @intLoadId = intLoadId
			FROM tblLGLoadDetail
			WHERE intLoadDetailId = @intLoadDetailId


			INSERT INTO @LoadDetailTable
			(
				intLoadDetailId
				,intContractDetailId
			)
			SELECT 
				intLoadDetailId
				,intContractDetailId = CASE WHEN @strInOutFlag = 'I' THEN intPContractDetailId ELSE intSContractDetailId END
			FROM vyuSCScaleLoadView
			WHERE intLoadId = @intLoadId
				AND ysnInProgress = 0
				AND NOT EXISTS (SELECT TOP 1 1 FROM  @LoadDetailUsedId WHERE intId = vyuSCScaleLoadView.intLoadDetailId)
			ORDER BY intLoadDetailId

			SET @intLoadDetailId = NULL

			SELECT TOP 1  @intLoadDetailId = intLoadDetailId
				,@intContractDetailId = intContractDetailId
			FROM @LoadDetailTable
			ORDER BY intLoadDetailId
		END	

		
		--Apply to next contract available
		IF	ISNULL(@intContractDetailId,0) = 0
		BEGIN
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
			AND		NOT EXISTS (SELECT TOP 1 intId FROM @LoadContractsDetailId WHERE intId = CD.intContractDetailId)
			ORDER 
			BY		CD.dtmStartDate, CD.intContractDetailId ASC
		END

		--For Apply to Basis Option
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
			AND		NOT EXISTS (SELECT TOP 1  intId FROM @LoadContractsDetailId WHERE intId = CD.intContractDetailId)
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
			,PR.intLoadDetailId
	FROM	@Processed	PR
	JOIN	tblCTContractDetail	CD	ON	CD.intContractDetailId	=	PR.intContractDetailId
	WHERE	ISNULL(ysnIgnore,0) <> 1
	
END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
	
END CATCH
