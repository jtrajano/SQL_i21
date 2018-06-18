CREATE PROCEDURE uspLGCreateLoadForPickLot @intPickLotHeaderId INT
	,@intEntityUserSecurityId INT
	,@intLoadId INT OUTPUT
AS
BEGIN TRY
	DECLARE @strErrMsg NVARCHAR(MAX)
	DECLARE @intAllocationDetailId INT
	DECLARE @intMinAllocationRecordId INT
	DECLARE @intAllocationHeaderId INT
	DECLARE @intSContractDetailId INT
	DECLARE @strLoadNumber NVARCHAR(100)
	DECLARE @strPickLotNumber NVARCHAR(100)
	DECLARE @dblScheduledQty NUMERIC(18,6)

	--DECLARE @intLoadId INT
	DECLARE @intLoadDetailId INT
	DECLARE @intPurchaseSaleId INT
	DECLARE @intCurrencyId INT
	DECLARE @intPositionId INT
	DECLARE @intTransportationMode INT
	DECLARE @intTransUsedBy INT
	DECLARE @intWeightUnitMeasureId INT
	DECLARE @intItemId INT
	DECLARE @intWeightItemUOMId INT
	
	DECLARE @intSubLocationId INT
	DECLARE @dtmPickupDate DATETIME
	DECLARE @dtmDeliveryDate DATETIME
	DECLARE @strDeliveryNoticeNumber NVARCHAR(100)
	DECLARE @intBookId INT
	DECLARE @intSubBookId INT
	DECLARE @intPickLotDetailId INT

	SELECT @intTransportationMode = intDefaultTransportationMode
		,@intTransUsedBy = intTransUsedBy
		,@intPositionId = intDefaultPositionId
	FROM tblLGCompanyPreference

	SELECT @intCurrencyId = intDefaultCurrencyId
	FROM tblSMCompanyPreference

	SELECT @strPickLotNumber = strPickLotNumber,
		   @intWeightUnitMeasureId = intWeightUnitMeasureId,
		   @intBookId = intBookId,
		   @intSubBookId = intSubBookId
	FROM tblLGPickLotHeader
	WHERE intPickLotHeaderId = @intPickLotHeaderId

	IF EXISTS (
			SELECT TOP 1 1
			FROM tblLGLoadDetail LD
			JOIN tblLGPickLotDetail PLD ON PLD.intPickLotDetailId = LD.intPickLotDetailId
			JOIN tblLGPickLotHeader PLH ON PLH.intPickLotHeaderId = PLD.intPickLotHeaderId
			WHERE ISNULL(PLH.intPickLotHeaderId, 0) = @intPickLotHeaderId
			)
	BEGIN
		SET @strErrMsg = 'Shipment has already been created for ''' + @strPickLotNumber + '''.'

		RAISERROR (@strErrMsg,16,1)
	END

	DECLARE @tblAllocationInfo TABLE (
		intAllocationRecordId INT IDENTITY(1,1)
		,intAllocationHeaderId INT
		,intAllocationDetailId INT
		,strAllocationHeaderNo NVARCHAR(100)
		,intPickLotDetailId INT
		)

	EXEC uspSMGetStartingNumber 39
		,@strLoadNumber OUTPUT

	INSERT INTO @tblAllocationInfo
	SELECT AD.intAllocationHeaderId
		,AD.intAllocationDetailId
		,AH.strAllocationNumber
		,PLH.intPickLotDetailId
	FROM vyuLGOpenPickLots PLH
	JOIN tblLGAllocationDetail AD ON AD.intAllocationDetailId= PLH.intAllocationDetailId
	JOIN tblLGAllocationHeader AH ON AH.intAllocationHeaderId = AD.intAllocationHeaderId
	WHERE PLH.intPickLotHeaderId = @intPickLotHeaderId 

	INSERT INTO tblLGLoad (
		dtmScheduledDate
		,intConcurrencyId
		,intCurrencyId
		,intPositionId
		,intPurchaseSale
		,intShipmentStatus
		,intShipmentType
		,intSourceType
		,intTransportationMode
		,intTransUsedBy
		,intUserSecurityId
		,intWeightUnitMeasureId
		,strLoadNumber
		,intBookId
		,intSubBookId
		)
	SELECT GETDATE()
		,1
		,@intCurrencyId
		,NULL
		,2
		,1
		,1
		,5
		,1
		,@intTransUsedBy
		,@intEntityUserSecurityId
		,@intWeightUnitMeasureId
		,@strLoadNumber
		,@intBookId
		,@intSubBookId

	SELECT @intLoadId = SCOPE_IDENTITY()

	SELECT @intMinAllocationRecordId = MIN(intAllocationRecordId)
	FROM @tblAllocationInfo

	WHILE (ISNULL(@intMinAllocationRecordId, 0) > 0)
	BEGIN
		SET @intSContractDetailId = NULL
		SET @intAllocationDetailId = NULL

		SELECT @intAllocationDetailId = intAllocationDetailId,
			   @intPickLotDetailId = intPickLotDetailId
		FROM @tblAllocationInfo WHERE intAllocationRecordId = @intMinAllocationRecordId

		SELECT @intSContractDetailId = intSContractDetailId
		FROM tblLGAllocationDetail
		WHERE intAllocationDetailId = @intAllocationDetailId

		SELECT @intItemId = intItemId
		FROM tblCTContractDetail
		WHERE intContractDetailId = @intSContractDetailId

		SELECT @intWeightItemUOMId = intItemUOMId
		FROM tblICItemUOM
		WHERE intItemId = @intItemId
			AND intUnitMeasureId = @intWeightUnitMeasureId

		INSERT INTO tblLGLoadDetail (
			dblGross
			,dblNet
			,dblQuantity
			,dblTare
			,intAllocationDetailId
			,intConcurrencyId
			,intCustomerEntityId
			,intItemId
			,intItemUOMId
			,intLoadId
			,intPickLotDetailId
			,intSCompanyLocationId
			,intSContractDetailId
			,intWeightItemUOMId
			,strPriceStatus
			,intPriceCurrencyId
			,intPriceUOMId
			,dblUnitPrice
			)
		SELECT PLD.dblGrossWt
			,PLD.dblNetWt
			,PLD.dblSalePickedQty
			,0
			,AD.intAllocationDetailId
			,1
			,PLH.intCustomerEntityId
			,CD.intItemId
			,CD.intItemUOMId
			,@intLoadId
			,PLD.intPickLotDetailId
			,CD.intCompanyLocationId
			,CD.intContractDetailId
			,@intWeightItemUOMId
			,PT.strPricingType
			,A.intSeqCurrencyId
			,A.intSeqPriceUOMId
			,A.dblSeqPrice
		FROM tblLGAllocationDetail AD
		JOIN tblLGAllocationHeader AH ON AH.intAllocationHeaderId = AD.intAllocationHeaderId
		JOIN tblLGPickLotDetail PLD ON PLD.intAllocationDetailId = AD.intAllocationDetailId
		JOIN tblLGPickLotHeader PLH ON PLH.intPickLotHeaderId = PLD.intPickLotHeaderId
		JOIN tblCTContractDetail CD ON CD.intContractDetailId = AD.intSContractDetailId
		JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
		CROSS APPLY dbo.fnCTGetAdditionalColumnForDetailView(CD.intContractDetailId) A
		WHERE AD.intAllocationDetailId = @intAllocationDetailId
			AND PLD.intPickLotDetailId = @intPickLotDetailId

		SELECT @intLoadDetailId = SCOPE_IDENTITY()

		SELECT @dblScheduledQty = dblQuantity
		FROM tblLGLoadDetail
		WHERE intLoadDetailId = @intLoadDetailId

		IF (ISNULL(@intLoadDetailId,0) <> 0  )
		BEGIN
			EXEC uspCTUpdateScheduleQuantity @intContractDetailId = @intSContractDetailId
				,@dblQuantityToUpdate = @dblScheduledQty
				,@intUserId = @intEntityUserSecurityId
				,@intExternalId = @intLoadDetailId
				,@strScreenName = 'Load Schedule'
		END

		INSERT INTO tblLGLoadDetailLot (
			dblGross
			,dblLotQuantity
			,dblNet
			,dblTare
			,intConcurrencyId
			,intItemUOMId
			,intLoadDetailId
			,intLotId
			,intWeightUOMId
			,strWarehouseCargoNumber
			)
		SELECT dblGrossWt
			,dblLotPickedQty
			,dblNetWt
			,dblTareWt
			,1
			,CD.intItemUOMId
			,@intLoadDetailId
			,PLD.intLotId
			,@intWeightItemUOMId
			,''
		FROM tblLGPickLotDetail PLD
		JOIN tblLGAllocationDetail AD ON PLD.intAllocationDetailId = AD.intAllocationDetailId
		JOIN tblCTContractDetail CD ON CD.intContractDetailId = AD.intPContractDetailId
		WHERE AD.intAllocationDetailId = @intAllocationDetailId
			AND PLD.intPickLotDetailId = @intPickLotDetailId

		SELECT @intMinAllocationRecordId = MIN(intAllocationRecordId)
		FROM @tblAllocationInfo
		WHERE intAllocationRecordId > @intMinAllocationRecordId
	END

	EXEC uspLGReserveStockForInventoryShipment @intLoadId = @intLoadId
											  ,@ysnReserveStockForInventoryShipment = 1

	--- CREATE LOAD WAREHOUSE

	EXEC uspSMGetStartingNumber 86
		,@strDeliveryNoticeNumber OUT

	SELECT @intSubLocationId = intSubLocationId
	FROM tblLGPickLotHeader
	WHERE intPickLotHeaderId = @intPickLotHeaderId

	INSERT INTO tblLGLoadWarehouse (
		intConcurrencyId
		,intLoadId
		,strDeliveryNoticeNumber
		,dtmDeliveryNoticeDate
		,intSubLocationId
		,dtmPickupDate
		,dtmDeliveryDate
		)
	SELECT 1
		,@intLoadId
		,@strDeliveryNoticeNumber
		,GETDATE()
		,@intSubLocationId
		,GETDATE()
		,GETDATE()

END TRY

BEGIN CATCH
	IF XACT_STATE() != 0
		AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	SET @strErrMsg = ERROR_MESSAGE()

	RAISERROR (@strErrMsg,16,1,'WITH NOWAIT')
END CATCH