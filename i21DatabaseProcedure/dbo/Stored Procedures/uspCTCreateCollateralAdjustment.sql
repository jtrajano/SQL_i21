CREATE PROCEDURE [dbo].[uspCTCreateCollateralAdjustment]
	@intContractDetailId			INT,
	@dblQuantityToUpdate			NUMERIC(18,6),
	@intUserId						INT,
	@intExternalId					INT,
	@strScreenName					NVARCHAR(50)
AS

BEGIN TRY
	
	DECLARE @idoc			INT,			@ErrMsg				NVARCHAR(MAX),	@intQtyUnitMeasureId		INT,
			@intItemId		INT,			@XML				NVARCHAR(MAX),	@intContractHeaderId		INT,
			@strNumber		NVARCHAR(100),	@intCollateralId	INT,			@dblCollateralQty			NUMERIC(18,6),
			@strUnitMeasure	NVARCHAR(100),	@intCollateralUOMId	INT,			@dblRemainingQuantity		NUMERIC(18,6),
			@strTransNo		NVARCHAR(100),	@strItemNo			NVARCHAR(100),	@strAdjustmentNo			NVARCHAR(100),	
																				@intCollateralAdjustmentId	INT

	SELECT	@intItemId				=	CD.intItemId,
			@intQtyUnitMeasureId	=	QU.intUnitMeasureId,
			@intContractHeaderId	=	CD.intContractHeaderId,
			@strItemNo				=	IM.strItemNo
	FROM	tblCTContractDetail	CD	LEFT
	JOIN	tblICItem			IM	ON	IM.intItemId	= CD.intItemId
	JOIN	tblICItemUOM		QU	ON	QU.intItemUOMId	= CD.intItemUOMId
	WHERE	intContractDetailId	= @intContractDetailId	

	SELECT	@strNumber				=	strNumber
	FROM	dbo.fnCTGetSequenceUsageHistoryAdditionalParam(@intContractDetailId,@strScreenName,@intExternalId,@intUserId)

	SELECT	@intCollateralId		=	intCollateralId,
			@dblCollateralQty		=	dblOriginalQuantity,
			@dblRemainingQuantity	=	dblRemainingQuantity,
			@intCollateralUOMId		=	UM.intUnitMeasureId,
			@strTransNo				=	LTRIM(intTransNo),
			@strUnitMeasure			=	UM.strUnitMeasure	
	FROM	tblRKCollateral		CL
	JOIN	tblICUnitMeasure	UM	ON UM.intUnitMeasureId = CL.intUnitMeasureId
	WHERE	intContractHeaderId	=	@intContractHeaderId

	IF	@intCollateralId IS NULL 
		RETURN

	IF NOT EXISTS(SELECT * FROM tblICItemUOM WHERE intItemId = @intItemId AND intUnitMeasureId	= @intCollateralUOMId)
	BEGIN
		RAISERROR('UOM %s selected in Collateral %s is not configured for the item %s.',16,1,@strUnitMeasure,@strTransNo,@strItemNo)
	END

	SELECT @dblQuantityToUpdate = dbo.fnCTConvertQuantityToTargetItemUOM(@intItemId,@intQtyUnitMeasureId,@intCollateralUOMId,@dblQuantityToUpdate)	

	IF @dblRemainingQuantity - @dblQuantityToUpdate < 0
	BEGIN
		RAISERROR('Remaining quantity for Collateral %s cannot be negative.',16,1,@strTransNo)
	END

	IF @dblRemainingQuantity - @dblQuantityToUpdate > @dblCollateralQty
	BEGIN
		RAISERROR('Remaining quantity for Collateral %s cannot be negative.',16,1,@strTransNo)
	END

	SELECT	@strAdjustmentNo = @strTransNo + 'A' + LTRIM(CAST(ISNULL(MAX(RIGHT(strAdjustmentNo, CHARINDEX('A', REVERSE(strAdjustmentNo)) - 1)),0) AS INT) + 1)
	FROM	tblRKCollateralAdjustment 
	WHERE	intCollateralId = @intCollateralId

	SET @XML =	'<tblRKCollateralAdjustments>'
	SET @XML +=		'<tblRKCollateralAdjustment>'
	SET @XML +=			'<intCollateralId>'+LTRIM(@intCollateralId)+'</intCollateralId>'
	SET @XML +=			'<intConcurrencyId>1</intConcurrencyId>'
	SET @XML +=			'<dtmAdjustmentDate>'+LTRIM(GETDATE())+'</dtmAdjustmentDate>'
	SET @XML +=			'<dblAdjustmentAmount>'+LTRIM(@dblQuantityToUpdate)+'</dblAdjustmentAmount>'
	SET @XML +=			'<strComments>'+@strScreenName + ' ' + @strNumber +'</strComments>'
	SET @XML +=			'<strAdjustmentNo>'+@strAdjustmentNo+'</strAdjustmentNo>'
	SET @XML +=		'</tblRKCollateralAdjustment>'
	SET @XML += '</tblRKCollateralAdjustments>'

	EXEC uspCTInsertINTOTableFromXML 'tblRKCollateralAdjustment',@XML,@intCollateralAdjustmentId OUTPUT

	UPDATE	tblRKCollateral
	SET		dblRemainingQuantity -= @dblQuantityToUpdate
	WHERE	intCollateralId	= @intCollateralId

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH