CREATE PROCEDURE [dbo].[uspCTItemContractShipped]
	@ItemsFromInventoryShipment ShipmentItemTableType READONLY
	,@intUserId  INT
	,@ysnPosted BIT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE		@intInventoryShipmentItemId		INT,
			@intItemContractDetailId		INT,
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
			@dblReverseSchQty				NUMERIC(18,6),
			@intSContractDetailId			INT,
			@dblAppliedQty					NUMERIC(18,6),
			@dblDistributedLoadQty			NUMERIC(18,6)

SELECT TOP 1 		
	@intOrderType = intOrderType
	,@intSourceType = intSourceType 
	,@strShipmentId = strShipmentId 
FROM 
	@ItemsFromInventoryShipment

IF(@intOrderType <> 5)
	RETURN

DECLARE @tblToProcess TABLE
(
	intUniqueId					INT IDENTITY,
	intInventoryShipmentItemId	INT,
	intItemContractDetailId		INT,
	intItemUOMId				INT,
	dblQty						NUMERIC(18,6),
	ysnLoad						BIT
)

IF(@intOrderType = 5)
BEGIN
	INSERT	INTO @tblToProcess (intInventoryShipmentItemId,intItemContractDetailId,intItemUOMId,dblQty, ysnLoad)
	SELECT 	intInventoryShipmentItemId, intItemContractDetailId, intItemUOMId, CASE WHEN ysnLoad = 1 THEN intLoadShipped ELSE dblQty END, ysnLoad
	FROM	@ItemsFromInventoryShipment
	WHERE	ISNULL(intItemContractDetailId, 0) > 0 
END

SELECT @intUniqueId = MIN(intUniqueId) FROM @tblToProcess

WHILE ISNULL(@intUniqueId,0) > 0
BEGIN
	SELECT	@intItemContractDetailId		=	NULL,
			@intFromItemUOMId				=	NULL,
			@dblQty							=	NULL,
			@intInventoryShipmentItemId		=	NULL,
			@ysnLoad						=	NULL,
			@strTicketNumber				=	NULL

	SELECT	@intItemContractDetailId		=	intItemContractDetailId,
			@intFromItemUOMId				=	intItemUOMId,
			@dblQty							=	-dblQty,
			@intInventoryShipmentItemId		=	intInventoryShipmentItemId,
			@ysnLoad						=	ysnLoad
	FROM	@tblToProcess 
	WHERE	intUniqueId						=	 @intUniqueId

	SELECT @intToItemUOMId = intItemUOMId FROM tblCTItemContractDetail WHERE intItemContractDetailId = @intItemContractDetailId
	SELECT @dblConvertedQty = dbo.fnCalculateQtyBetweenUOM(@intFromItemUOMId, @intToItemUOMId, @dblQty) 

	BEGIN
		EXEC [dbo].[uspCTUpdateItemContractSequenceBalance]
			@intItemContractDetailId = @intItemContractDetailId
			,@dblQuantityToUpdate = @dblConvertedQty
			,@intUserId = @intUserId
			,@intExternalId = @intInventoryShipmentItemId
			,@strScreenName = @strScreenName
			,@ysnFromInvoice = 0
	END

	BEGIN
		SET @dblConvertedQty = -@dblConvertedQty
		EXEC [dbo].[uspCTUpdateItemContractSequenceQuantity]
			@intItemContractDetailId = @intItemContractDetailId
			,@dblQuantityToUpdate = @dblConvertedQty
			,@intUserId = @intUserId
			,@intExternalId = @intInventoryShipmentItemId
			,@strScreenName = @strScreenName
	END


	SELECT @intUniqueId = MIN(intUniqueId) FROM @tblToProcess WHERE intUniqueId > @intUniqueId
END
