CREATE PROCEDURE dbo.uspIPCreateWeightClaims @intLoadId INT
	,@intNewWeightClaimId INT OUTPUT
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
		,@strNewWeightClaimReferenceNo NVARCHAR(50)
		,@intUserId INT
		,@strDescription NVARCHAR(50)

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
	/*SELECT DISTINCT 1
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
	WHERE intLoadId = @intLoadId*/
	SELECT DISTINCT 1
		,@strNewWeightClaimReferenceNo
		,GETDATE()
		,PC.intLoadId
		,'' strComments
		,L.dtmETAPOD
		,L.dtmETAPOD + ISNULL(ASN.intLastWeighingDays, 0) AS dtmLastWeighingDate
		,NULL dtmActualWeighingDate
		,NULL dtmClaimValidTill
		,PC.intPurchaseSale
		,(
			CASE 
				WHEN dblClaimableWt < 0
					THEN NULL
				ELSE 1
				END
			)
		,(
			CASE 
				WHEN dblClaimableWt < 0
					THEN NULL
				ELSE GETDATE()
				END
			)
		,L.intCompanyId
		,L.intBookId
		,L.intSubBookId
	FROM tblLGPendingClaim PC
	JOIN tblLGLoad L ON L.intLoadId = PC.intLoadId
		AND L.intLoadId = @intLoadId
	LEFT JOIN tblCTContractDetail AS CD ON CD.intContractDetailId = PC.intContractDetailId
	LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	LEFT JOIN tblCTAssociation ASN ON ASN.intAssociationId = CH.intAssociationId
	WHERE L.intLoadId = @intLoadId

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
		,intContractDetailId
		,intBillId
		,intInvoiceId
		,dblFranchise
		,dblSeqPriceConversionFactoryWeightUOM
		,dblToGross
		,dblToTare
		,ysnNoClaim
		)
	/*SELECT 1
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
		,dblReceivedGrossWt
		,dblReceivedGrossWt-dblReceivedNetWt
	FROM vyuLGGetOpenWeightClaim WC
	WHERE intLoadId = @intLoadId*/
	SELECT 1
		,@intNewWeightClaimId
		,intItemId
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
		,intContractDetailId
		,NULL
		,NULL
		,dblFranchise
		,dblSeqPriceConversionFactoryWeightUOM
		,dblReceivedGrossWt
		,dblReceivedGrossWt - dblReceivedNetWt
		,(
			CASE 
				WHEN dblClaimableWt < 0
					THEN 0
				ELSE 1
				END
			)
	FROM tblLGPendingClaim
	WHERE intLoadId = @intLoadId

	IF EXISTS (
			SELECT *
			FROM tblLGPendingClaim
			WHERE intLoadId = @intLoadId
				AND dblClaimableWt < 0
			)
		INSERT INTO tblLGWeightClaimPreStage (intWeightClaimId)
		SELECT @intNewWeightClaimId

	DELETE
	FROM tblLGPendingClaim
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
