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
				@ysnPO							BIT

	SELECT @intOrderType = intOrderType,@intSourceType = intSourceType FROM @ItemsFromInventoryShipment

	IF(@intOrderType <> 1)
		RETURN

	DECLARE @tblToProcess TABLE
	(
		intUniqueId					INT IDENTITY,
		intInventoryShipmentItemId	INT,
		intContractDetailId			INT,
		intItemUOMId				INT,
		dblQty						NUMERIC(18,6)	
	)

	IF(@intOrderType = 1)
	BEGIN
		INSERT	INTO @tblToProcess (intInventoryShipmentItemId,intContractDetailId,intItemUOMId,dblQty)
		SELECT 	intInventoryShipmentItemId,intLineNo,intItemUOMId,dblQty
		FROM	@ItemsFromInventoryShipment
		WHERE	ISNULL(intLineNo,0) > 0
	END

	SELECT @intUniqueId = MIN(intUniqueId) FROM @tblToProcess

	WHILE ISNULL(@intUniqueId,0) > 0
	BEGIN
		SELECT	@intContractDetailId			=	NULL,
				@intFromItemUOMId				=	NULL,
				@dblQty							=	NULL,
				@intInventoryShipmentItemId		=	NULL

		SELECT	@intContractDetailId			=	intContractDetailId,
				@intFromItemUOMId				=	intItemUOMId,
				@dblQty							=	dblQty * -1,
				@intInventoryShipmentItemId		=	intInventoryShipmentItemId
		FROM	@tblToProcess 
		WHERE	intUniqueId						=	 @intUniqueId

		IF NOT EXISTS(SELECT * FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId)
		BEGIN
			RAISERROR('Contract does not exist.',16,1)
		END

		SELECT @intToItemUOMId	=	intItemUOMId FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId

		SELECT @dblConvertedQty =	dbo.fnCalculateQtyBetweenUOM(@intFromItemUOMId,@intToItemUOMId,@dblQty)

		IF ISNULL(@dblConvertedQty,0) = 0
		BEGIN
			RAISERROR('UOM does not exist.',16,1)
		END

		EXEC	uspCTUpdateSequenceBalance
				@intContractDetailId	=	@intContractDetailId,
				@dblQuantityToUpdate	=	@dblConvertedQty,
				@intUserId				=	@intUserId,
				@intExternalId			=	@intInventoryShipmentItemId,
				@strScreenName			=	'Inventory Shipment' 

		SELECT	@dblSchQuantityToUpdate = -@dblConvertedQty

		IF @intSourceType IN (0,1,2,3)
		BEGIN					
			EXEC	uspCTUpdateScheduleQuantity
					@intContractDetailId	=	@intContractDetailId,
					@dblQuantityToUpdate	=	@dblSchQuantityToUpdate,
					@intUserId				=	@intUserId,
					@intExternalId			=	@intInventoryShipmentItemId,
					@strScreenName			=	'Inventory Shipment' 
		END

		SELECT @intUniqueId = MIN(intUniqueId) FROM @tblToProcess WHERE intUniqueId > @intUniqueId
	END

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
	
END CATCH