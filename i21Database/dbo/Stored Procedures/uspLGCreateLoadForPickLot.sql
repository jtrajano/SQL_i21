CREATE PROCEDURE uspLGCreateLoadForPickLot 
	@intPickLotHeaderId INT
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
	DECLARE @intItemUOMId NUMERIC(18,6)

	--DECLARE @intLoadId INT
	DECLARE @intLoadDetailId INT
	DECLARE @intPurchaseSaleId INT
	DECLARE @intCurrencyId INT
	DECLARE @intPositionId INT
	DECLARE @intFreightTerm INT
	DECLARE @intTransportationMode INT
	DECLARE @intTransUsedBy INT
	DECLARE @intWeightUnitMeasureId INT
	--DECLARE @intItemId INT
	DECLARE @intWeightItemUOMId INT
	
	DECLARE @intSubLocationId INT
	DECLARE @dtmPickupDate DATETIME
	DECLARE @dtmDeliveryDate DATETIME
	DECLARE @strDeliveryNoticeNumber NVARCHAR(100)
	DECLARE @intBookId INT
	DECLARE @intSubBookId INT
	DECLARE @intPickLotDetailId INT
	DECLARE @ysnDefaultFreightTermsFromCt BIT
	DECLARE @intNumAllocInfo INT

	SELECT @intTransportationMode = intDefaultTransportationMode
		,@intTransUsedBy = intTransUsedBy
		,@intPositionId = intDefaultPositionId
		,@intFreightTerm = intDefaultFreightTermId
		,@ysnDefaultFreightTermsFromCt = ysnDefaultFreightTermsFromCt
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

	SELECT @intMinAllocationRecordId = MIN(intAllocationRecordId)
	FROM @tblAllocationInfo

	SELECT @intNumAllocInfo = COUNT(*) FROM @tblAllocationInfo

	IF (@ysnDefaultFreightTermsFromCt = 1)
	BEGIN
		IF (@intNumAllocInfo = 1)
		BEGIN
			SELECT @intSContractDetailId = intSContractDetailId
			FROM tblLGAllocationDetail AD
			INNER JOIN @tblAllocationInfo AI ON AI.intAllocationDetailId = AD.intAllocationDetailId

			SELECT @intFreightTerm = CH.intFreightTermId
			FROM tblCTContractHeader CH
			INNER JOIN tblCTContractDetail CD ON CD.intContractHeaderId = CH.intContractHeaderId
			WHERE CD.intContractDetailId = @intSContractDetailId
		END
		ELSE
		BEGIN
			SET @intFreightTerm = NULL
		END
	END

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
		,intFreightTermId
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
		,@intFreightTerm
		,@intTransUsedBy
		,@intEntityUserSecurityId
		,@intWeightUnitMeasureId
		,@strLoadNumber
		,@intBookId
		,@intSubBookId

	SELECT @intLoadId = SCOPE_IDENTITY()

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
			,dtmDeliveryFrom
			,dtmDeliveryTo
			,dblAmount
			)
		SELECT PLD.dblGrossWt
			,PLD.dblNetWt
			,PLD.dblLotPickedQty
			,PLD.dblTareWt
			,AD.intAllocationDetailId
			,1
			,PLH.intCustomerEntityId
			,Lot.intItemId
			,Lot.intItemUOMId
			,@intLoadId
			,PLD.intPickLotDetailId
			,CD.intCompanyLocationId
			,CD.intContractDetailId
			,WUOM.intItemUOMId
			,PT.strPricingType
			,A.intSeqCurrencyId
			,A.intSeqPriceUOMId
			,A.dblSeqPrice
			,CD.dtmStartDate
			,CD.dtmEndDate
			,dbo.fnMultiply(dbo.fnCalculateQtyBetweenUOM(WUOM.intItemUOMId, A.intSeqPriceUOMId,PLD.dblNetWt), A.dblSeqPrice)
		FROM tblLGAllocationDetail AD
		JOIN tblLGAllocationHeader AH ON AH.intAllocationHeaderId = AD.intAllocationHeaderId
		JOIN tblLGPickLotDetail PLD ON PLD.intAllocationDetailId = AD.intAllocationDetailId
		JOIN tblLGPickLotHeader PLH ON PLH.intPickLotHeaderId = PLD.intPickLotHeaderId
		JOIN tblCTContractDetail CD ON CD.intContractDetailId = AD.intSContractDetailId
		JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
		LEFT JOIN vyuICGetLot Lot ON Lot.intLotId = PLD.intLotId
		CROSS APPLY dbo.fnCTGetAdditionalColumnForDetailView(CD.intContractDetailId) A
		OUTER APPLY (SELECT IU.intItemUOMId from tblICItemUOM IU WHERE IU.intItemId = Lot.intItemId AND IU.intUnitMeasureId = PLD.intWeightUnitMeasureId) WUOM
		WHERE AD.intAllocationDetailId = @intAllocationDetailId
			AND PLD.intPickLotDetailId = @intPickLotDetailId

		SELECT @intLoadDetailId = SCOPE_IDENTITY()

		SELECT 
			@dblScheduledQty = dblQuantity,
			@intItemUOMId = intItemUOMId
		FROM tblLGLoadDetail
		WHERE intLoadDetailId = @intLoadDetailId

		IF (ISNULL(@intLoadDetailId,0) <> 0  )
		BEGIN
			EXEC uspCTUpdateScheduleQuantityUsingUOM @intContractDetailId = @intSContractDetailId
				,@dblQuantityToUpdate = @dblScheduledQty
				,@intUserId = @intEntityUserSecurityId
				,@intExternalId = @intLoadDetailId
				,@intSourceItemUOMId = @intItemUOMId
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
			,Lot.intItemUOMId
			,@intLoadDetailId
			,PLD.intLotId
			,WUOM.intItemUOMId
			,''
		FROM tblLGPickLotDetail PLD
		JOIN tblLGAllocationDetail AD ON PLD.intAllocationDetailId = AD.intAllocationDetailId
		JOIN tblCTContractDetail CD ON CD.intContractDetailId = AD.intPContractDetailId
		LEFT JOIN vyuICGetLot Lot ON Lot.intLotId = PLD.intLotId
		OUTER APPLY (SELECT IU.intItemUOMId from tblICItemUOM IU WHERE IU.intItemId = Lot.intItemId AND IU.intUnitMeasureId = PLD.intWeightUnitMeasureId) WUOM
		WHERE AD.intAllocationDetailId = @intAllocationDetailId
			AND PLD.intPickLotDetailId = @intPickLotDetailId

		SELECT @intMinAllocationRecordId = MIN(intAllocationRecordId)
		FROM @tblAllocationInfo
		WHERE intAllocationRecordId > @intMinAllocationRecordId

		INSERT INTO tblLGLoadCost (
			intConcurrencyId,
			intLoadId,
			intItemId,
			intVendorId,
			strEntityType,
			strCostMethod,
			intCurrencyId,
			dblRate,
			dblAmount,
			dblFX,
			intItemUOMId,
			ysnAccrue,
			ysnMTM,
			ysnPrice
			)
		SELECT
			intConcurrencyId,
			@intLoadId,
			intItemId,
			intVendorId,
			strEntityType,
			strCostMethod,
			intCurrencyId,
			dblRate,
			dblAmount,
			dblFX,
			intItemUOMId,
			ysnAccrue,
			ysnMTM,
			ysnPrice
		FROM vyuLGContractCostView
		WHERE intContractDetailId = @intSContractDetailId
			AND ISNULL(ysnBasis, 0) = 0 AND ISNULL(ysnBilled, 0) = 0

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