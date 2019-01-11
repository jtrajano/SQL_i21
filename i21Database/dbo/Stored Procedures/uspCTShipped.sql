CREATE PROCEDURE [dbo].[uspCTShipped]
	@ItemsFromInventoryShipment ShipmentItemTableType READONLY,
	@intUserId  INT
AS

BEGIN TRY

	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE		@intInventoryShipmentItemId		INT,
				@intContractDetailId			INT,
				@intFromItemUOMId				INT,
				@intToItemUOMId					INT,
				@intUniqueId					INT,
				@dblQty							NUMERIC(18,6),
				@dblConvertedQty				NUMERIC(18,6),
				@ErrMsg							NVARCHAR(MAX),
				@intOrderType					INT,
				@dblSchQuantityToUpdate			NUMERIC(18,6),
				@intSourceType					INT,
				@ysnPO							BIT,
				@ysnLoad						BIT,
				@intPricingTypeId				INT,
				@intSourceId					INT,
				@strShipmentId					NVARCHAR(50),
				@strTicketNumber				NVARCHAR(50),
				@intSequenceUsageHistoryId		INT,
				@strScreenName					NVARCHAR(50) =	'Inventory Shipment',
				@ysnReduceScheduleByLogisticsLoad BIT,
				@intLoadId						INT,
				@dblLoadQuantity				NUMERIC(18,6),
				@intLoadDetailId				INT,
				@dblReduceSchQty				NUMERIC(18,6),
				@dblReverseSchQty				NUMERIC(18,6)

	SELECT @intOrderType = intOrderType,@intSourceType = intSourceType,@strShipmentId= strShipmentId FROM @ItemsFromInventoryShipment
	SELECT @ysnReduceScheduleByLogisticsLoad = ysnReduceScheduleByLogisticsLoad FROM tblCTCompanyPreference

	IF @intSourceType = -1
	BEGIN
		SELECT @strScreenName = 'Load Schedule'
	END

	IF(@intOrderType <> 1)
		RETURN

	DECLARE @tblToProcess TABLE
	(
		intUniqueId					INT IDENTITY,
		intInventoryShipmentItemId	INT,
		intContractDetailId			INT,
		intItemUOMId				INT,
		dblQty						NUMERIC(18,6),
		ysnLoad						BIT
	)

	IF(@intOrderType = 1)
	BEGIN
		INSERT	INTO @tblToProcess (intInventoryShipmentItemId,intContractDetailId,intItemUOMId,dblQty, ysnLoad)
		SELECT 	intInventoryShipmentItemId,intLineNo,intItemUOMId,CASE WHEN ysnLoad = 1 THEN intLoadShipped ELSE dblQty END, ysnLoad
		FROM	@ItemsFromInventoryShipment
		WHERE	ISNULL(intLineNo,0) > 0
	END

	SELECT @intUniqueId = MIN(intUniqueId) FROM @tblToProcess

	WHILE ISNULL(@intUniqueId,0) > 0
	BEGIN
		SELECT	@intContractDetailId			=	NULL,
				@intFromItemUOMId				=	NULL,
				@dblQty							=	NULL,
				@intInventoryShipmentItemId		=	NULL,
				@ysnLoad						=	NULL,
				@strTicketNumber				=	NULL

		SELECT	@intContractDetailId			=	intContractDetailId,
				@intFromItemUOMId				=	intItemUOMId,
				@dblQty							=	dblQty * -1,
				@intInventoryShipmentItemId		=	intInventoryShipmentItemId,
				@ysnLoad						=	ysnLoad
		FROM	@tblToProcess 
		WHERE	intUniqueId						=	 @intUniqueId

		SELECT	@intPricingTypeId = intPricingTypeId FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId
		SELECT @intSourceId = intSourceId FROM tblICInventoryShipmentItem WHERE intInventoryShipmentItemId = @intInventoryShipmentItemId

		IF NOT EXISTS(SELECT * FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId)
		BEGIN
			RAISERROR('Contract does not exist.',16,1)
		END

		SELECT @intToItemUOMId	=	intItemUOMId FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId

		SELECT @dblConvertedQty =	CASE WHEN @ysnLoad = 1 THEN @dblQty ELSE dbo.fnCalculateQtyBetweenUOM(@intFromItemUOMId,@intToItemUOMId,@dblQty) END

		IF ISNULL(@dblConvertedQty,0) = 0
		BEGIN
			RAISERROR('UOM does not exist.',16,1)
		END
		
		/*
			intSourceType: 
			0 = 'None'
			1 = 'Scale'
			2 = 'Inbound Shipment'
			3 = 'Pick Lot'
			4 = 'Delivery Sheet'
		*/
		
		IF @intSourceType IN (1) AND @intPricingTypeId = 5
		BEGIN
			EXEC	uspCTUpdateSequenceQuantity 
					@intContractDetailId	=	@intContractDetailId,
					@dblQuantityToUpdate	=	@dblConvertedQty,
					@intUserId				=	@intUserId,
					@intExternalId			=	@intInventoryShipmentItemId,
					@strScreenName			=	@strScreenName
		END
		ELSE
		BEGIN
			EXEC	uspCTUpdateSequenceBalance
					@intContractDetailId	=	@intContractDetailId,
					@dblQuantityToUpdate	=	@dblConvertedQty,
					@intUserId				=	@intUserId,
					@intExternalId			=	@intInventoryShipmentItemId,
					@strScreenName			=	@strScreenName

			SELECT	@dblSchQuantityToUpdate = -@dblConvertedQty

			IF @intSourceType IN (-1,0,1,2,3,5)
			BEGIN					
				EXEC	uspCTUpdateScheduleQuantity
						@intContractDetailId	=	@intContractDetailId,
						@dblQuantityToUpdate	=	@dblSchQuantityToUpdate,
						@intUserId				=	@intUserId,
						@intExternalId			=	@intInventoryShipmentItemId,
						@strScreenName			=	@strScreenName

				IF	@ysnReduceScheduleByLogisticsLoad = 1 AND @intSourceType = 1 AND @intOrderType = 1
				BEGIN
					SELECT @intLoadId = intLoadId from tblSCTicket WHERE intTicketId = @intSourceId
					SELECT @intLoadDetailId = intLoadDetailId FROM tblLGLoadDetail WHERE intLoadId = @intLoadId AND intSContractDetailId = @intContractDetailId
					IF @intLoadId IS NOT NULL
					BEGIN
						SELECT @dblLoadQuantity = dblQuantity FROM tblLGLoadDetail WHERE intLoadId = @intLoadId
						IF ABS(@dblSchQuantityToUpdate) < @dblLoadQuantity AND @dblSchQuantityToUpdate < 0
						BEGIN
							
							SELECT  @dblReduceSchQty = (@dblLoadQuantity - ABS(@dblSchQuantityToUpdate)) * -1
							EXEC	uspCTUpdateScheduleQuantity 
							@intContractDetailId	=	@intContractDetailId,
							@dblQuantityToUpdate	=	@dblReduceSchQty,
							@intUserId				=	@intUserId,
							@intExternalId			=	@intLoadDetailId,
							@strScreenName			=	'Auto - Load Schedule'
						END

						IF	EXISTS(SELECT TOP 1 1 FROM tblCTSequenceUsageHistory WHERE intContractDetailId = @intContractDetailId AND strScreenName = 'Auto - Load Schedule' AND intExternalId = @intLoadDetailId) AND
						@dblSchQuantityToUpdate > 0
						BEGIN
							SELECT @strTicketNumber = strLoadNumber FROM tblLGLoad WHERE intLoadId = @intLoadId
							IF @strTicketNumber IS NOT NULL
							BEGIN
								SELECT @intSequenceUsageHistoryId = intSequenceUsageHistoryId FROM tblCTSequenceUsageHistory WHERE intContractDetailId = @intContractDetailId AND strScreenName = 'Auto - Load Schedule' AND intExternalId = @intLoadDetailId
								UPDATE tblCTSequenceUsageHistory SET  strScreenName =  strScreenName + ' - ' + @strTicketNumber WHERE intSequenceUsageHistoryId = @intSequenceUsageHistoryId
								SELECT @dblReverseSchQty = dblTransactionQuantity * -1,@strTicketNumber = 'Reverse ' + strScreenName FROM tblCTSequenceUsageHistory WHERE intSequenceUsageHistoryId = @intSequenceUsageHistoryId

								EXEC	uspCTUpdateScheduleQuantity
										@intContractDetailId	=	@intContractDetailId,
										@dblQuantityToUpdate	=	@dblReverseSchQty,
										@intUserId				=	@intUserId,
										@intExternalId			=	@intSourceId,
										@strScreenName			=	@strTicketNumber
							END
						END
					END
				END
			END
			
			IF	@intSourceType = 1 AND 
			EXISTS(SELECT TOP 1 1 FROM tblCTSequenceUsageHistory WHERE intContractDetailId = @intContractDetailId AND strScreenName = 'Auto - Scale' AND intExternalId = @intSourceId) AND
			@dblSchQuantityToUpdate > 0
			BEGIN
				SELECT @strTicketNumber = strTicketNumber FROM tblSCTicket WHERE intTicketId = @intSourceId
				IF @strTicketNumber IS NOT NULL
				BEGIN
					SELECT @intSequenceUsageHistoryId = intSequenceUsageHistoryId FROM tblCTSequenceUsageHistory WHERE intContractDetailId = @intContractDetailId AND strScreenName = 'Auto - Scale' AND intExternalId = @intSourceId
					UPDATE tblCTSequenceUsageHistory SET  strScreenName =  strScreenName + ' - ' + @strTicketNumber WHERE intSequenceUsageHistoryId = @intSequenceUsageHistoryId
					SELECT @dblSchQuantityToUpdate = dblTransactionQuantity * -1,@strTicketNumber = 'Reverse ' + strScreenName FROM tblCTSequenceUsageHistory WHERE intSequenceUsageHistoryId = @intSequenceUsageHistoryId

					EXEC	uspCTUpdateScheduleQuantity
							@intContractDetailId	=	@intContractDetailId,
							@dblQuantityToUpdate	=	@dblSchQuantityToUpdate,
							@intUserId				=	@intUserId,
							@intExternalId			=	@intSourceId,
							@strScreenName			=	@strTicketNumber
				END
			END
		END
		SELECT @intUniqueId = MIN(intUniqueId) FROM @tblToProcess WHERE intUniqueId > @intUniqueId
	END

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
	
END CATCH