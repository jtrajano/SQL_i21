﻿CREATE PROCEDURE [dbo].[uspCTContractApproved]
	@intContractHeaderId	INT,
	@intApprovedById		INT
AS

BEGIN TRY

	DECLARE @ErrMsg	NVARCHAR(MAX),
			@intApprovedContractId	INT

	DECLARE	@SCOPE_IDENTITY TABLE (intApprovedContractId INT)

	INSERT INTO tblCTApprovedContract
	(
			intContractHeaderId,	intContractDetailId,	intEntityId,
			intGradeId,				intWeightId,			intTermId,
			intPositionId,			intContractBasisId,		intContractStatusId,
			dtmStartDate,			dtmEndDate,				dtmPlannedAvailabilityDate,
			intItemId,				dblQuantity,			intQtyUOMId,
			intFutureMarketId,		intFutureMonthId,		dblFutures,
			dblBasis,				dblCashPrice,			intCurrencyId,
			intPriceUOMId,			intSubLocationId,		intStorageLocationId,
			intPurchasingGroupId,	intApprovedById,		dtmApproved
	)
	OUTPUT	inserted.intApprovedContractId INTO @SCOPE_IDENTITY
	SELECT	CD.intContractHeaderId,
			CD.intContractDetailId,
			CH.intEntityId,
			CH.intGradeId,
			CH.intWeightId,
			CH.intTermId,
			CH.intPositionId,
			CH.intContractBasisId,
			CD.intContractStatusId,
			CD.dtmStartDate,
			CD.dtmEndDate,
			CD.dtmPlannedAvailabilityDate,
			CD.intItemId,
			CD.dblQuantity,
			CD.intUnitMeasureId AS intQtyUOMId,
			CD.intFutureMarketId,
			CD.intFutureMonthId,
			CD.dblFutures,
			CD.dblBasis,
			CD.dblCashPrice,
			CD.intCurrencyId,
			PU.intUnitMeasureId AS intPriceUOMId,
			CD.intSubLocationId,
			CD.intStorageLocationId,
			CD.intPurchasingGroupId,
			@intApprovedById,
			GETDATE()

	FROM	tblCTContractDetail CD 
	JOIN	tblCTContractHeader CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId	LEFT
	JOIN	tblICItemUOM		PU	ON	PU.intItemUOMId			=	CD.intPriceItemUOMId
	WHERE	CD.intContractHeaderId	=	@intContractHeaderId

	SELECT @intApprovedContractId = MIN(intApprovedContractId) FROM @SCOPE_IDENTITY

	WHILE ISNULL(@intApprovedContractId,0) > 0 
	BEGIN
		EXEC uspCTProcessApprovedContractToFeed @intApprovedContractId
		
		SELECT @intApprovedContractId = MIN(intApprovedContractId) FROM @SCOPE_IDENTITY WHERE intApprovedContractId > @intApprovedContractId
	END

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH