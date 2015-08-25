CREATE PROCEDURE [dbo].[uspLGGetQuantitiesForAllocatedDetail]
	@intAllocationDetailId INT,
	@dblPLoadScheduledQty DECIMAL(18, 6) = 0 OUTPUT,
	@dblSLoadScheduledQty DECIMAL(18, 6) = 0 OUTPUT,
	@dblPLoadDeliveredQty DECIMAL(18, 6) = 0 OUTPUT,
	@dblSLoadDeliveredQty DECIMAL(18, 6) = 0 OUTPUT,
	@dblPDropShippedQty DECIMAL(18, 6) = 0 OUTPUT,
	@dblSDropShippedQty DECIMAL(18, 6) = 0 OUTPUT,
	@dblPLotPickedQty DECIMAL(18, 6) = 0 OUTPUT,
	@dblSLotPickedQty DECIMAL(18, 6) = 0 OUTPUT,
	@dblPWeightPerUnit DECIMAL(18, 6) = 0 OUTPUT,
	@dblSWeightPerUnit DECIMAL(18, 6) = 0 OUTPUT,
	@strPUnitType		NVARCHAR (MAX) = '' OUTPUT,
	@strSUnitType		NVARCHAR (MAX) = '' OUTPUT

AS
DECLARE @ErrMsg NVARCHAR(MAX)

BEGIN TRY
	IF NOT EXISTS(SELECT 1 FROM tblLGAllocationDetail WHERE intAllocationDetailId=@intAllocationDetailId) AND @intAllocationDetailId IS NOT NULL
	BEGIN
		RETURN
	END

	SELECT	
			@dblPLoadScheduledQty = IsNull((SELECT SUM(Load.dblQuantity) FROM tblLGLoad Load LEFT JOIN tblLGGenerateLoad GL ON GL.intGenerateLoadId = Load.intGenerateLoadId AND IsNull(Load.dblDeliveredQuantity, 0) <= 0 Group By GL.intAllocationDetailId, Load.intContractDetailId Having GL.intAllocationDetailId = AD.intAllocationDetailId AND Load.intContractDetailId = AD.intPContractDetailId), 0.0),
			@dblSLoadScheduledQty = IsNull((SELECT SUM(Load.dblQuantity) FROM tblLGLoad Load LEFT JOIN tblLGGenerateLoad GL ON GL.intGenerateLoadId = Load.intGenerateLoadId AND IsNull(Load.dblDeliveredQuantity, 0) <= 0 Group By GL.intAllocationDetailId, Load.intContractDetailId Having GL.intAllocationDetailId = AD.intAllocationDetailId AND Load.intContractDetailId = AD.intSContractDetailId), 0.0),
			@dblPLoadDeliveredQty = IsNull((SELECT SUM(Load.dblDeliveredQuantity) FROM tblLGLoad Load LEFT JOIN tblLGGenerateLoad GL ON GL.intGenerateLoadId = Load.intGenerateLoadId AND IsNull(Load.dblDeliveredQuantity, 0) > 0 Group By GL.intAllocationDetailId, Load.intContractDetailId Having GL.intAllocationDetailId = AD.intAllocationDetailId AND Load.intContractDetailId = AD.intPContractDetailId), 0.0),
			@dblSLoadDeliveredQty = IsNull((SELECT SUM(Load.dblDeliveredQuantity) FROM tblLGLoad Load LEFT JOIN tblLGGenerateLoad GL ON GL.intGenerateLoadId = Load.intGenerateLoadId AND IsNull(Load.dblDeliveredQuantity, 0) > 0 Group By GL.intAllocationDetailId, Load.intContractDetailId Having GL.intAllocationDetailId = AD.intAllocationDetailId AND Load.intContractDetailId = AD.intSContractDetailId), 0.0),

			@dblPLotPickedQty	  = IsNull((SELECT SUM(PL.dblLotPickedQty) FROM tblLGPickLotDetail PL Group By PL.intAllocationDetailId Having PL.intAllocationDetailId = AD.intAllocationDetailId), 0.0),
			@dblSLotPickedQty	  = IsNull((SELECT SUM(PL.dblSalePickedQty) FROM tblLGPickLotDetail PL Group By PL.intAllocationDetailId Having PL.intAllocationDetailId = AD.intAllocationDetailId), 0.0),

			@dblPDropShippedQty	  = IsNull((SELECT SUM(DS.dblPAllocatedQty) FROM tblLGShipmentPurchaseSalesContract DS Group By DS.intAllocationDetailId Having DS.intAllocationDetailId = AD.intAllocationDetailId), 0.0),
			@dblSDropShippedQty	  = IsNull((SELECT SUM(DS.dblSAllocatedQty) FROM tblLGShipmentPurchaseSalesContract DS Group By DS.intAllocationDetailId Having DS.intAllocationDetailId = AD.intAllocationDetailId), 0.0),

			@dblPWeightPerUnit	  = IsNull([dbo].fnLGGetItemUnitConversion (CTP.intItemId, CTP.intItemUOMId, AH.intWeightUnitMeasureId), 0.0),
			@dblSWeightPerUnit	  = IsNull([dbo].fnLGGetItemUnitConversion (CTS.intItemId, CTS.intItemUOMId, AH.intWeightUnitMeasureId), 0.0),
			@strPUnitType		  = (SELECT UOM.strUnitType FROM tblICUnitMeasure UOM WHERE UOM.intUnitMeasureId = AD.intPUnitMeasureId),
			@strSUnitType		  = (SELECT UOM.strUnitType FROM tblICUnitMeasure UOM WHERE UOM.intUnitMeasureId = AD.intSUnitMeasureId)
			
	FROM 	tblLGAllocationDetail AD 
			JOIN tblLGAllocationHeader AH ON AH.intAllocationHeaderId = AD.intAllocationHeaderId
			JOIN vyuCTContractDetailView CTP ON CTP.intContractDetailId = AD.intPContractDetailId
			JOIN vyuCTContractDetailView CTS ON CTS.intContractDetailId = AD.intSContractDetailId
	WHERE AD.intAllocationDetailId = @intAllocationDetailId

	SELECT	@dblPLoadScheduledQty as dblPLoadScheduledQty, 
			@dblSLoadScheduledQty as dblSLoadScheduledQty, 
			@dblPLoadDeliveredQty as dblPLoadDeliveredQty, 
			@dblSLoadDeliveredQty as dblSLoadDeliveredQty,
			@dblPLotPickedQty     as dblPLotPickedQty,
			@dblSLotPickedQty     as dblSLotPickedQty,
			@dblPDropShippedQty	  as dblPDropShippedQty,
			@dblSDropShippedQty	  as dblSDropShippedQty,
			@dblPWeightPerUnit	  as dblPWeightPerUnit,
			@dblSWeightPerUnit	  as dblSWeightPerUnit,
			@strPUnitType		  as strPUnitType,
			@strSUnitType		  as strSUnitType
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')
END CATCH
