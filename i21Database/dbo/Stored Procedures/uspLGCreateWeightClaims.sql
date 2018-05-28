CREATE PROCEDURE uspLGCreateWeightClaims
	@intWeightClaimId INT
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intLoadId INT
	DECLARE @intPurchaseSale INT
	DECLARE @intContractDetailId INT
	DECLARE @intPContractDetailId INT
	DECLARE @intLoadDetailId INT
	DECLARE @intWeightClaimDetailId INT
	DECLARE @intMinId INT
	DECLARE @strNewWeightClaimReferenceNo NVARCHAR(100)
	DECLARE @intNewWeightClaimId INT
	DECLARE @tblWeightClaimContract TABLE (
		intId INT IDENTITY
		,intWeightClaimId INT
		,intWeightClaimDetailId INT
		,intContractDetailId INT
		,intLoadId INT
		)

	INSERT INTO @tblWeightClaimContract
	SELECT WC.intWeightClaimId
		,WCD.intWeightClaimDetailId
		,WCD.intContractDetailId
		,WC.intLoadId
	FROM tblLGWeightClaim WC
	JOIN tblLGWeightClaimDetail WCD ON WCD.intWeightClaimId = WC.intWeightClaimId
	WHERE WC.intWeightClaimId = @intWeightClaimId

	SELECT @intLoadId = intLoadId
	FROM tblLGWeightClaim
	WHERE intWeightClaimId = @intWeightClaimId

	SELECT @intPurchaseSale = intPurchaseSale
	FROM tblLGLoad
	WHERE intLoadId = @intLoadId

	IF (ISNULL(@intPurchaseSale, 0) <> 3)
		RETURN;

	SELECT @intMinId = MIN(intId)
	FROM @tblWeightClaimContract

	WHILE ISNULL(@intMinId, 0) > 0
	BEGIN
		SET @intContractDetailId = NULL
		SET @intLoadDetailId = NULL
		SET @intWeightClaimDetailId = NULL
		SET @strNewWeightClaimReferenceNo = NULL

		EXEC uspSMGetStartingNumber 114
			,@strNewWeightClaimReferenceNo OUTPUT

		SELECT @intContractDetailId = intContractDetailId
			,@intWeightClaimDetailId = intWeightClaimDetailId
		FROM @tblWeightClaimContract
		WHERE intId = @intMinId

		SELECT @intPContractDetailId = intPContractDetailId
		FROM tblLGLoadDetail
		WHERE intLoadId = @intLoadId
			AND intSContractDetailId = @intContractDetailId

		INSERT INTO tblLGWeightClaim (
			intConcurrencyId
			,strReferenceNumber
			,dtmTransDate
			,intLoadId
			,strComments
			,dtmETAPOD
			,dtmLastWeighingDate
			,dtmActualWeighingDate
			,dtmClaimValidTill
			,intPurchaseSale
			,ysnPosted
			,dtmPosted
			,intCompanyId
			,intBookId
			,intSubBookId
			)
		SELECT 1
			,@strNewWeightClaimReferenceNo
			,GETDATE()
			,@intLoadId
			,strComments
			,dtmETAPOD
			,dtmLastWeighingDate
			,dtmActualWeighingDate
			,dtmClaimValidTill
			,intPurchaseSale
			,NULL
			,NULL
			,intCompanyId
			,intBookId
			,intSubBookId
		FROM tblLGWeightClaim
		WHERE intWeightClaimId = @intWeightClaimId

		SET @intNewWeightClaimId = SCOPE_IDENTITY();

		INSERT INTO tblLGWeightClaimDetail (
			intConcurrencyId
			,intWeightClaimId
			,intItemId
			,dblFromNet
			,dblToNet
			,dblFranchiseWt
			,dblWeightLoss
			,dblClaimableWt
			,intPartyEntityId
			,dblUnitPrice
			,intCurrencyId
			,dblClaimAmount
			,intPriceItemUOMId
			,dblAdditionalCost
			,ysnNoClaim
			,intContractDetailId
			,intBillId
			,intInvoiceId
			,dblFranchise
			,dblSeqPriceConversionFactoryWeightUOM
			)
		SELECT 1
			,@intNewWeightClaimId
			,vyuLGGetOpenWeightClaim.intItemId
			,dblShippedNetWt
			,(SELECT dblToNet FROM tblLGWeightClaimDetail WHERE intWeightClaimDetailId = @intWeightClaimDetailId)
			,dblFranchiseWt
			,(SELECT dblWeightLoss FROM tblLGWeightClaimDetail WHERE intWeightClaimDetailId = @intWeightClaimDetailId)
			,(SELECT dblWeightLoss FROM tblLGWeightClaimDetail WHERE intWeightClaimDetailId = @intWeightClaimDetailId) + dblFranchiseWt
			,intPartyEntityId
			,dblSeqPrice
			,intSeqCurrencyId
			,(
				dbo.[fnCTConvertQuantityToTargetItemUOM](vyuLGGetOpenWeightClaim.intItemId, intWeightUnitMeasureId, IU.intUnitMeasureId, ABS((
							SELECT dblWeightLoss
							FROM tblLGWeightClaimDetail
							WHERE intWeightClaimDetailId = @intWeightClaimDetailId
							) + dblFranchiseWt)) * dblSeqPrice
				) / CASE 
				WHEN CU.ysnSubCurrency = 1
					THEN 100
				ELSE 1
				END
			,intSeqPriceUOMId
			,NULL
			,NULL
			,@intPContractDetailId
			,NULL
			,NULL
			,dblFranchise
			,dblSeqPriceConversionFactoryWeightUOM
		FROM vyuLGGetOpenWeightClaim
		JOIN tblSMCurrency CU ON CU.intCurrencyID = vyuLGGetOpenWeightClaim.intSeqCurrencyId
		JOIN tblICItemUOM IU ON IU.intItemUOMId = vyuLGGetOpenWeightClaim.intSeqPriceUOMId
		WHERE intLoadId = @intLoadId
			AND intContractDetailId = @intPContractDetailId

		SELECT @intMinId = MIN(intId)
		FROM @tblWeightClaimContract
		WHERE intId > @intMinId
	END
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH
