CREATE PROCEDURE uspLGValidateUpdatePickedLot
	@dblUpdatedQty NUMERIC(18,6),
	@intPickLotDetailId INT
AS
BEGIN TRY
	DECLARE @dblPickedQty NUMERIC(18,6)
	DECLARE @strErrMsg NVARCHAR(MAX)
	DECLARE @intSaleUnitMeasureId INT
	DECLARE @strSalesUnitMeasure NVARCHAR(100)
	DECLARE @intLotUnitMeasureId INT
	DECLARE @strLotUnitMeasure NVARCHAR(100)
	DECLARE @intPickLotHeaderId INT
	DECLARE @intLotId INT
	DECLARE @strLotNo NVARCHAR(100)
	DECLARE @dblLotWeightPerQty NUMERIC(18,6)

	SELECT @dblPickedQty = dblLotPickedQty,
		   @intSaleUnitMeasureId = intSaleUnitMeasureId,
		   @intLotUnitMeasureId = intLotUnitMeasureId,
		   @intPickLotHeaderId = intPickLotHeaderId,
		   @intLotId = intLotId
	FROM tblLGPickLotDetail
	WHERE intPickLotDetailId = @intPickLotDetailId

	SELECT @strSalesUnitMeasure = strUnitMeasure
	FROM tblICUnitMeasure
	WHERE intUnitMeasureId = @intSaleUnitMeasureId
	
	SELECT @strLotUnitMeasure = strUnitMeasure
	FROM tblICUnitMeasure
	WHERE intUnitMeasureId = @intLotUnitMeasureId

	SELECT @strLotNo = strLotNumber,
	       @dblLotWeightPerQty = dblWeightPerQty
	FROM tblICLot
	WHERE intLotId = @intLotId
	
	IF (@intSaleUnitMeasureId <> @intLotUnitMeasureId)
	BEGIN
		SET @strErrMsg = 'Lot''s uom is ''' + @strLotUnitMeasure + ''' and order''s uom is ''' + @strSalesUnitMeasure + '''. Cannot update the qty. Please remove the pick lot detail and try to pick again from the ''Pick'' tab.'

		RAISERROR (@strErrMsg,11,1)
	END

	IF @dblUpdatedQty > @dblPickedQty
	BEGIN
		SET @strErrMsg = 'Entered qty for lot ''' + @strLotNo +''' cannot be greater than ''' + LTRIM(dbo.fnRemoveTrailingZeroes(@dblPickedQty)) + ' ' + @strLotUnitMeasure +'''.'

		RAISERROR(@strErrMsg,11,1)
	END

BEGIN TRANSACTION

	UPDATE tblLGPickLotDetail 
	SET dblLotPickedQty = @dblUpdatedQty,
		dblSalePickedQty = @dblUpdatedQty,
		dblGrossWt = CASE WHEN ISNULL(@dblLotWeightPerQty,0) > 0 
					 THEN @dblUpdatedQty * @dblLotWeightPerQty
					 ELSE @dblUpdatedQty 
					 END,
		dblNetWt   = CASE WHEN ISNULL(@dblLotWeightPerQty,0) > 0 
					 THEN @dblUpdatedQty * @dblLotWeightPerQty
					 ELSE @dblUpdatedQty 
					 END
	WHERE intPickLotDetailId = @intPickLotDetailId

	EXEC uspLGReserveStockForPickLots @intPickLotHeaderId 

COMMIT TRANSACTION

END TRY
BEGIN CATCH
	SET @strErrMsg = ERROR_MESSAGE()
	IF XACT_STATE() != 0
		ROLLBACK TRANSACTION
	RAISERROR (@strErrMsg ,11,1,'WITH NOWAIT')
END CATCH