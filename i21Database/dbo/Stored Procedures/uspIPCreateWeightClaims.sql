Create PROCEDURE dbo.uspIPCreateWeightClaims @intLoadId INT,@intNewWeightClaimId int output
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
		,@strNewWeightClaimReferenceNo NVARCHAR(50)
		--,@intNewWeightClaimId INT

	SET @strNewWeightClaimReferenceNo = NULL

	EXEC uspSMGetStartingNumber 114
		,@strNewWeightClaimReferenceNo OUTPUT

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
	SELECT DISTINCT 1
		,@strNewWeightClaimReferenceNo
		,GETDATE()
		,intLoadId
		,'' strComments
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
	FROM vyuIPGetOpenWeightClaim
	WHERE intLoadId = @intLoadId

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
		,WC.intItemId
		,dblShippedNetWt
		,dblReceivedNetWt
		,dblFranchiseWt
		,dblWeightLoss
		,dblWeightLoss + dblFranchiseWt
		,intPartyEntityId
		,dblSeqPrice
		,intSeqCurrencyId
		,(dbo.[fnCTConvertQuantityToTargetItemUOM](WC.intItemId, intWeightUnitMeasureId, IU.intUnitMeasureId, ABS((dblWeightLoss) + dblFranchiseWt)) * dblSeqPrice) / CASE 
			WHEN CU.ysnSubCurrency = 1
				THEN 100
			ELSE 1
			END
		,intSeqPriceUOMId
		,NULL
		,NULL
		,WC.intContractDetailId
		,NULL
		,NULL
		,dblFranchise
		,dblSeqPriceConversionFactoryWeightUOM
	FROM vyuIPGetOpenWeightClaim WC
	JOIN tblSMCurrency CU ON CU.intCurrencyID = WC.intSeqCurrencyId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = WC.intSeqPriceUOMId
	WHERE intLoadId = @intLoadId

END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
