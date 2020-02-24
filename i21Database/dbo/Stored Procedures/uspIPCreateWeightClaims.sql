Create PROCEDURE dbo.uspIPCreateWeightClaims @intLoadId INT,@intNewWeightClaimId int output
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
		,@strNewWeightClaimReferenceNo NVARCHAR(50)
		,@intUserId INT
		,@strDescription nvarchar(50)

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
		,dblClaimableAmount
		,intSeqPriceUOMId
		,NULL
		,NULL
		,WC.intContractDetailId
		,NULL
		,NULL
		,dblFranchise
		,dblSeqPriceConversionFactoryWeightUOM
	FROM vyuLGGetOpenWeightClaim WC
	WHERE intLoadId = @intLoadId

	SELECT @strDescription = 'Created from system : ' + @strNewWeightClaimReferenceNo

	EXEC uspSMAuditLog @keyValue = @intNewWeightClaimId
		,@screenName = 'Logistics.view.WeightClaims'
		,@entityId = @intUserId
		,@actionType = 'Created'
		,@actionIcon = 'small-new-plus'
		,@changeDescription = @strDescription
		,@fromValue = ''
		,@toValue = @strNewWeightClaimReferenceNo

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
