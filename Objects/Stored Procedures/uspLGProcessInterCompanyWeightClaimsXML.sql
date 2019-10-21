CREATE PROCEDURE uspLGProcessInterCompanyWeightClaimsXML
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(100)
	DECLARE @intId INT
	DECLARE @intWeightClaimId INT
	DECLARE @strWeightClaimNumber NVARCHAR(100)
	DECLARE @strWeightClaim NVARCHAR(MAX)
	DECLARE @strAckWeightClaimXML NVARCHAR(MAX)
	DECLARE @strWeightClaimDetails NVARCHAR(MAX)
	DECLARE @strAckWeightClaimDetailXML NVARCHAR(MAX)
	DECLARE @strReference NVARCHAR(100)
	DECLARE @strRowState NVARCHAR(100)
	DECLARE @strFeedStatus NVARCHAR(100)
	DECLARE @dtmFeedDate DATETIME
	DECLARE @strMessage NVARCHAR(MAX)
	DECLARE @intMultiCompanyId INT
	DECLARE @intReferenceId INT
	DECLARE @intEntityId INT
	DECLARE @strTransactionType NVARCHAR(100)
	DECLARE @intToBookId INT
	DECLARE @strNewWeightClaimNumber NVARCHAR(100)
	DECLARE @intNewWeightClaimId INT
	DECLARE @intStartingNumberType INT = 114
	DECLARE @strTagRelaceXML NVARCHAR(MAX)
	DECLARE @intWeightClaimsAcknowledgementStageId INT
	DECLARE @intLoadId INT
	DECLARE @intLoadRefId INT
	DECLARE @idoc INT
	DECLARE @intMinXMLWeightClaimDetailId INT
	DECLARE @intWeightClaimDetailId INT
	DECLARE @intContractDetailId INT
	DECLARE @intContractDetailRefId INT
	DECLARE @intContractHeaderId INT
	DECLARE @intContractHeaderRefId INT
	DECLARE @intPartyId INT
	DECLARE @intWeightClaimAcknowledgementStageId INT
	DECLARE @strWeightClaimHeaderCondition NVARCHAR(MAX)

	SELECT @intId = MIN(intId)
	FROM tblLGIntrCompWeightClaimsStg
	WHERE strFeedStatus IS NULL
		AND strRowState = 'Added'

	WHILE ISNULL(@intId, 0) > 0
	BEGIN
		SET @intWeightClaimId = NULL
		SET @strWeightClaimNumber = NULL
		SET @strWeightClaim = NULL
		SET @strWeightClaimDetails = NULL
		SET @strReference = NULL
		SET @strRowState = NULL
		SET @strFeedStatus = NULL
		SET @dtmFeedDate = NULL
		SET @strMessage = NULL
		SET @intMultiCompanyId = NULL
		SET @intReferenceId = NULL
		SET @intEntityId = NULL
		SET @strTransactionType = NULL
		SET @intToBookId = NULL

		SELECT @intWeightClaimId = intWeightClaimId
			,@strWeightClaimNumber = strWeightClaimNo
			,@strWeightClaim = strWeightClaim
			,@intLoadRefId = intLoadId
			,@strWeightClaimDetails = strWeightClaimDetail
			,@strReference = strReference
			,@strRowState = strRowState
			,@strFeedStatus = strFeedStatus
			,@dtmFeedDate = dtmFeedDate
			,@strMessage = strMessage
			,@intMultiCompanyId = intMultiCompanyId
			,@intReferenceId = intReferenceId
			,@intEntityId = intEntityId
			,@strTransactionType = strTransactionType
			,@intToBookId = intToBookId
		FROM tblLGIntrCompWeightClaimsStg
		WHERE intId = @intId

		--SELECT *
		--FROM tblLGIntrCompWeightClaimsStg

		SELECT @intLoadId = intLoadId
		FROM tblLGLoad
		WHERE intLoadRefId = @intLoadRefId

		IF @strTransactionType = 'Outbound Weight Claims'
		BEGIN
			SET @strNewWeightClaimNumber = NULL

			EXEC uspSMGetStartingNumber @intStartingNumberType
				,@strNewWeightClaimNumber OUTPUT

			SET @strTagRelaceXML = NULL
			SET @strWeightClaim = REPLACE(@strWeightClaim, 'intWeightClaimId>', 'intWeightClaimRefId>')
			SET @strWeightClaim = REPLACE(@strWeightClaim, 'intCompanyId>', 'CompanyId>')
			SET @strTagRelaceXML = '<root>
										<tags>
											<toFind>&lt;strReferenceNumber&gt;' + LTRIM(@strWeightClaimNumber) + '&lt;/strReferenceNumber&gt;</toFind>
											<toReplace>&lt;strReferenceNumber&gt;' + LTRIM(@strNewWeightClaimNumber) + '&lt;/strReferenceNumber&gt;</toReplace>
										</tags>
										<tags>
											<toFind>&lt;intLoadId&gt;' + LTRIM(@intLoadRefId) + '&lt;/intLoadId&gt;</toFind>
											<toReplace>&lt;intLoadId&gt;' + LTRIM(@intLoadId) + '&lt;/intLoadId&gt;</toReplace>
										</tags>
										<tags>
											<toFind>&lt;intPurchaseSale&gt;' + LTRIM(1) + '&lt;/intPurchaseSale&gt;</toFind>
											<toReplace>&lt;intPurchaseSale&gt;' + LTRIM(2) + '&lt;/intPurchaseSale&gt;</toReplace>
										</tags>
									</root>'

			EXEC uspCTInsertINTOTableFromXML 'tblLGWeightClaim'
				,@strWeightClaim
				,@intNewWeightClaimId OUTPUT
				,@strTagRelaceXML

			INSERT INTO tblLGIntrCompWeightClaimsAck (
				intWeightClaimId
				,intLoadId
				,strWeightClaimNo
				,dtmFeedDate
				,strMessage
				,strTransactionType
				,intMultiCompanyId
				)
			SELECT @intNewWeightClaimId
				,@intLoadId
				,@strNewWeightClaimNumber
				,GETDATE()
				,'Success'
				,@strTransactionType
				,@intMultiCompanyId

			SELECT @intWeightClaimAcknowledgementStageId = SCOPE_IDENTITY()

			SELECT @strWeightClaimHeaderCondition = 'intWeightClaimId = ' + LTRIM(@intNewWeightClaimId)

			EXEC uspCTGetTableDataInXML 'tblLGWeightClaim'
				,@strWeightClaimHeaderCondition
				,@strAckWeightClaimXML OUTPUT

			UPDATE tblLGIntrCompWeightClaimsAck
			SET strWeightClaim = @strAckWeightClaimXML
			WHERE intId = @intWeightClaimAcknowledgementStageId

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strWeightClaimDetails

			DECLARE @tempXMLWeightClaimDetail TABLE (
				intId INT IDENTITY(1, 1)
				,intWeightClaimDetailId INT
				,intConcurrencyId INT
				,intWeightClaimId INT
				,strCondition NVARCHAR(100)
				,intItemId INT
				,dblQuantity NUMERIC(18, 6)
				,dblFromNet NUMERIC(18, 6)
				,dblToNet NUMERIC(18, 6)
				,dblFranchiseWt NUMERIC(18, 6)
				,dblWeightLoss NUMERIC(18, 6)
				,dblClaimableWt NUMERIC(18, 6)
				,intPartyEntityId INT
				,dblUnitPrice NUMERIC(18, 6)
				,intCurrencyId INT
				,dblClaimAmount NUMERIC(18, 6)
				,intPriceItemUOMId INT
				,dblAdditionalCost NUMERIC(18, 6)
				,ysnNoClaim BIT
				,intContractDetailId INT
				,intBillId INT
				,intInvoiceId INT
				,dblFranchise NUMERIC(18, 6)
				,dblSeqPriceConversionFactoryWeightUOM NUMERIC(18, 6)
				,intWeightClaimDetailRefId INT
				)

			INSERT INTO @tempXMLWeightClaimDetail
			SELECT intWeightClaimDetailId
				,intConcurrencyId
				,intWeightClaimId
				,strCondition
				,intItemId
				,dblQuantity
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
				,NULL
			FROM OPENXML(@idoc, 'tblLGWeightClaimDetails/tblLGWeightClaimDetail', 2) WITH (
					intWeightClaimDetailId INT
					,intConcurrencyId INT
					,intWeightClaimId INT
					,strCondition NVARCHAR(100)
					,intItemId INT
					,dblQuantity NUMERIC(18, 6)
					,dblFromNet NUMERIC(18, 6)
					,dblToNet NUMERIC(18, 6)
					,dblFranchiseWt NUMERIC(18, 6)
					,dblWeightLoss NUMERIC(18, 6)
					,dblClaimableWt NUMERIC(18, 6)
					,intPartyEntityId INT
					,dblUnitPrice NUMERIC(18, 6)
					,intCurrencyId INT
					,dblClaimAmount NUMERIC(18, 6)
					,intPriceItemUOMId INT
					,dblAdditionalCost NUMERIC(18, 6)
					,ysnNoClaim BIT
					,intContractDetailId INT
					,intBillId INT
					,intInvoiceId INT
					,dblFranchise NUMERIC(18, 6)
					,dblSeqPriceConversionFactoryWeightUOM NUMERIC(18, 6)
					)

			SELECT @intMinXMLWeightClaimDetailId = MIN(intId)
			FROM @tempXMLWeightClaimDetail

			WHILE ISNULL(@intMinXMLWeightClaimDetailId, 0) > 0
			BEGIN
				SET @intWeightClaimDetailId = NULL
				SET @intContractDetailId = NULL

				SELECT @intContractDetailRefId = intContractDetailId
					,@intWeightClaimDetailId = intWeightClaimDetailId
				FROM @tempXMLWeightClaimDetail
				WHERE intId = @intMinXMLWeightClaimDetailId

				SELECT @intContractDetailId = intContractDetailId
					,@intContractHeaderId = intContractHeaderId
				FROM tblCTContractDetail
				WHERE intContractDetailRefId = @intContractDetailRefId

				SELECT @intPartyId = intEntityId
				FROM tblCTContractHeader
				WHERE intContractHeaderId = @intContractHeaderId

				UPDATE @tempXMLWeightClaimDetail
				SET intContractDetailId = @intContractDetailId
					,intPartyEntityId = @intPartyId
					,intWeightClaimId = @intNewWeightClaimId
					,intWeightClaimDetailRefId = intWeightClaimDetailId
				WHERE intWeightClaimDetailId = @intWeightClaimDetailId

				INSERT INTO tblLGWeightClaimDetail (
					intConcurrencyId
					,intWeightClaimId
					,strCondition
					,intItemId
					,dblQuantity
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
					,intWeightClaimDetailRefId
					)
				SELECT 1
					,@intNewWeightClaimId
					,strCondition
					,intItemId
					,dblQuantity
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
					,intWeightClaimDetailRefId
				FROM @tempXMLWeightClaimDetail
				WHERE intWeightClaimDetailId = @intWeightClaimDetailId

				SELECT @intMinXMLWeightClaimDetailId = MIN(intId)
				FROM @tempXMLWeightClaimDetail
				WHERE intId > @intMinXMLWeightClaimDetailId
			END
		END

		EXEC uspCTGetTableDataInXML 'tblLGWeightClaimDetail'
			,@strWeightClaimHeaderCondition
			,@strAckWeightClaimDetailXML OUTPUT

		UPDATE tblLGIntrCompWeightClaimsAck
		SET strWeightClaimDetail = @strAckWeightClaimDetailXML
		WHERE intId = @intWeightClaimAcknowledgementStageId

		EXEC sp_xml_removedocument @idoc

		UPDATE tblLGIntrCompWeightClaimsStg
		SET strFeedStatus = 'Processed'
		WHERE intId = @intId

		SELECT @intId = MIN(intId)
		FROM tblLGIntrCompWeightClaimsStg
		WHERE strFeedStatus IS NULL
			AND strRowState = 'Added'
			AND intId > @intId
	END
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH