CREATE PROCEDURE [dbo].[uspCTItemContractShipped]
	@ItemsFromInventoryShipment ShipmentItemTableType READONLY
	, @intUserId INT
	, @ysnPosted BIT

AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN
	DECLARE		@intInventoryShipmentItemId		INT,
				@intItemContractDetailId		INT,
				@intFromItemUOMId				INT,
				@intToItemUOMId					INT,
				@intUniqueId					INT,
				@dblQty							NUMERIC(18, 6),
				@dblFinalQty					NUMERIC(18, 6),
				@dblQuantityToUpdate			NUMERIC(18, 6),
				@intOrderType					INT,
				@ysnPO							BIT,
				@ysnLoad						BIT,
				@intPricingTypeId				INT,
				@intSourceId					INT,
				@strScreenName					NVARCHAR(50) =	'Inventory Shipment'

	SELECT TOP 1 @intOrderType = intOrderType FROM @ItemsFromInventoryShipment

	IF(@intOrderType <> 5) RETURN

	DECLARE @tblToProcess TABLE (intUniqueId INT IDENTITY
		, intInventoryShipmentItemId INT
		, intItemContractDetailId INT
		, intItemUOMId INT
		, dblQty NUMERIC(18, 6)
		, ysnLoad BIT)

	IF(@intOrderType = 5)
	BEGIN
		INSERT	INTO @tblToProcess (intInventoryShipmentItemId
			, intItemContractDetailId
			, intItemUOMId
			, dblQty
			, ysnLoad)
		SELECT 	intInventoryShipmentItemId
			, intItemContractDetailId
			, intItemUOMId
			, CASE WHEN ysnLoad = 1 THEN intLoadShipped ELSE dblQty END
			, ysnLoad
		FROM	@ItemsFromInventoryShipment
		WHERE	ISNULL(intItemContractDetailId, 0) > 0 
	END

	SELECT @intUniqueId = MIN(intUniqueId) FROM @tblToProcess

	WHILE ISNULL(@intUniqueId, 0) > 0
	BEGIN
		SELECT	@intItemContractDetailId		=	NULL,
				@intFromItemUOMId				=	NULL,
				@dblQty							=	NULL,
				@intInventoryShipmentItemId		=	NULL,
				@ysnLoad						=	NULL

		SELECT	@intItemContractDetailId		=	intItemContractDetailId,
				@intFromItemUOMId				=	intItemUOMId,
				@dblQty							=	- dblQty,
				@intInventoryShipmentItemId		=	intInventoryShipmentItemId,
				@ysnLoad						=	ysnLoad
		FROM	@tblToProcess 
		WHERE	intUniqueId						=	 @intUniqueId

		SELECT @intToItemUOMId = intItemUOMId FROM tblCTItemContractDetail WHERE intItemContractDetailId = @intItemContractDetailId
		SELECT @dblFinalQty = dbo.fnCalculateQtyBetweenUOM(@intFromItemUOMId, @intToItemUOMId, @dblQty) 

		SET @dblQuantityToUpdate = @dblFinalQty

		DECLARE @dblContracted NUMERIC(18, 6)
			, @dblOrigBalance NUMERIC(18, 6)
			, @dblTolerance NUMERIC(18, 6) = 0.0001
			, @dblNewBalance NUMERIC(18, 6)
			, @ysnCompleted BIT	= 0
			, @intAllocatedPurchaseContractDetailId INT
			, @ErrMsg NVARCHAR(MAX)			
		
		SELECT @dblContracted = ISNULL(CD.dblContracted, 0)
			, @dblOrigBalance = ISNULL(CD.dblBalance, 0)
		FROM tblCTItemContractDetail CD
		JOIN tblCTItemContractHeader CH ON CH.intItemContractHeaderId = CD.intItemContractHeaderId
		WHERE intItemContractDetailId = @intItemContractDetailId


		IF NOT EXISTS(SELECT TOP 1 1 FROM tblCTItemContractDetail WHERE intItemContractDetailId = @intItemContractDetailId)
		BEGIN
			RAISERROR('Item Contract Sequence no longer exists.', 16, 1)
		END 

		SELECT @dblNewBalance = @dblOrigBalance - @dblFinalQty
			, @dblQuantityToUpdate = @dblFinalQty

		IF @dblNewBalance < 0
		BEGIN
			IF ABS(@dblNewBalance) > @dblTolerance
			BEGIN
				SET @ErrMsg = 'Current balance of ' + CAST(@dblOrigBalance AS NVARCHAR) + ' is less than ' + CAST(@dblFinalQty AS NVARCHAR) + '.'
				RAISERROR(@ErrMsg, 16, 1)
			END
			ELSE
			BEGIN
				SET @dblQuantityToUpdate =  @dblQuantityToUpdate + @dblNewBalance
				SET	@dblNewBalance		 =	@dblOrigBalance - @dblQuantityToUpdate
			END
		END
	
		IF @dblNewBalance > @dblContracted
		BEGIN
			IF @dblNewBalance > @dblContracted + @dblTolerance
			BEGIN
				RAISERROR('Balance cannot be more than quantity.', 16, 1)
			END
			ELSE
			BEGIN
				SET @dblNewBalance = @dblContracted
			END
		END
			
		IF @dblNewBalance = 0 
		BEGIN
			SET @ysnCompleted = 1
		END

		UPDATE tblCTItemContractDetail
		SET intConcurrencyId = intConcurrencyId + 1
			, dblBalance = @dblNewBalance
			, dblScheduled = CASE WHEN @dblQuantityToUpdate > 0 THEN dblScheduled - @dblQuantityToUpdate ELSE dblScheduled END
			, dblApplied = CASE WHEN @dblQuantityToUpdate > 0 THEN dblApplied + @dblQuantityToUpdate ELSE dblApplied END
			, intContractStatusId = CASE WHEN @ysnCompleted = 0
											THEN CASE WHEN intContractStatusId = 5 THEN 1
													ELSE intContractStatusId  END
										ELSE 5 END
		WHERE intItemContractDetailId = @intItemContractDetailId
		
		/*
		CT-4516
		Check if the Sales Contract is allocated and get the Purchase Contract allocated on it and update the Status
		considering the quantity is the same.
		*/
		SET @intAllocatedPurchaseContractDetailId = (SELECT intPContractDetailId FROM tblLGAllocationDetail WHERE intSContractDetailId = @intItemContractDetailId)
		IF (@intAllocatedPurchaseContractDetailId IS NOT NULL AND @intAllocatedPurchaseContractDetailId > 0)
		BEGIN
			UPDATE tblCTItemContractDetail
			SET intConcurrencyId = intConcurrencyId + 1
				, intContractStatusId = CASE WHEN @ysnCompleted = 0
												THEN CASE WHEN intContractStatusId = 5 THEN 1
														ELSE intContractStatusId END
											ELSE 5 END
			WHERE intItemContractDetailId = @intAllocatedPurchaseContractDetailId
		END
		
		SELECT @dblQuantityToUpdate = - @dblFinalQty
				
		DECLARE @dblCurrentContracted NUMERIC(18, 6)
			, @dblCurrentScheduled NUMERIC(18, 6)
			, @dblCurrentAvailable NUMERIC(18, 6)
			, @dblCurrentApplied NUMERIC(18, 6)
			, @dblCurrentBalance NUMERIC(18, 6)
			, @intContractStatusId INT
			, @dtmOrigLastDeliveryDate DATETIME
			, @intTransactionId INT
			, @intTransactionDetailId INT
			, @strTransactionId NVARCHAR(50)
			, @dtmTransactionDate DATETIME = GETDATE()

		SELECT @dblCurrentContracted = ISNULL(D.dblContracted, 0)
			, @dblCurrentScheduled = ISNULL(D.dblScheduled, 0)
			, @dblCurrentAvailable = ISNULL(D.dblAvailable, 0)
			, @dblCurrentApplied = ISNULL(D.dblApplied, 0)
			, @dblCurrentBalance = ISNULL(D.dblBalance, 0)
			, @intContractStatusId = D.intContractStatusId
			, @dtmOrigLastDeliveryDate = D.dtmLastDeliveryDate
		FROM tblCTItemContractDetail D
		JOIN tblCTItemContractHeader H ON H.intItemContractHeaderId = D.intItemContractHeaderId
		WHERE intItemContractDetailId = @intItemContractDetailId
		
		SELECT @intTransactionId = item.intInventoryShipmentId
			, @intTransactionDetailId = item.intInventoryShipmentItemId
			, @strTransactionId = shipment.strShipmentNumber
		FROM tblICInventoryShipmentItem item
		INNER JOIN tblICInventoryShipment shipment ON shipment.intInventoryShipmentId = item.intInventoryShipmentId
		WHERE item.intInventoryShipmentItemId = @intInventoryShipmentItemId
		
		-- Usage History
		EXEC uspCTItemContractCreateHistory @intItemContractDetailId = @intItemContractDetailId
			, @intTransactionId			=	@intTransactionId
			, @intTransactionDetailId	=	@intTransactionDetailId
			, @strTransactionId			=	@strTransactionId
			, @intUserId				=	@intUserId
			, @strTransactionType		=	@strScreenName
			, @dblNewContracted			=	@dblCurrentContracted
			, @dblNewScheduled			=	@dblCurrentScheduled
			, @dblNewAvailable			=	@dblCurrentAvailable
			, @dblNewApplied			=	@dblCurrentApplied
			, @dblNewBalance			=	@dblCurrentBalance
			, @intNewContractStatusId	=	@intContractStatusId
			, @dtmNewLastDeliveryDate	=	@dtmOrigLastDeliveryDate
			, @dtmTransactionDate		=	@dtmTransactionDate


		SELECT @intUniqueId = MIN(intUniqueId) FROM @tblToProcess WHERE intUniqueId > @intUniqueId
	END
END