CREATE PROCEDURE [dbo].[uspIPWeightClaimProcessStgXML] @intCompanyId INT
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
		,@intWeightClaimId INT
		,@strWeightClaimXML NVARCHAR(MAX)
		,@strWeightClaimDetailXML NVARCHAR(MAX)
		,@strRowState NVARCHAR(50)
		,@intNewWeightClaimId INT
		,@intWeightClaimRefId INT
		,@intTransactionCount INT
		,@dtmDate DATETIME
		,@strBook NVARCHAR(50)
		,@strSubBook NVARCHAR(50)
		,@ysnTest BIT
		,@strPlanNo NVARCHAR(50)
		,@ysnAllItem BIT
		,@strComment NVARCHAR(50)
		,@ysnPost BIT
		,@dtmCreated DATETIME
		,@dtmLastModified DATETIME
		,@strCreatedBy NVARCHAR(50)
		,@strModifiedBy NVARCHAR(50)
		,@strErrorMessage NVARCHAR(MAX)
		,@intCategoryId INT
		,@intUnitMeasureId INT
		,@intUserId INT
		,@intBookId INT
		,@intSubBookId INT
		,@idoc INT
		,@intWeightClaimStageId INT
		,@intLocationId INT
		,@intReportMasterID INT
		,@strItemList NVARCHAR(MAX)
		,@intTransactionId INT
		,@intLoadScreenId INT
		,@intTransactionRefId INT
		,@intCompanyRefId INT
		,@strDescription NVARCHAR(50)
		,@intWeightClaimScreenId INT
		,@strPaymentMethod NVARCHAR(50)
		,@intPaymentMethodId INT
		,@intLoadId INT
		,@intNewWeightClaimId2 INT
		,@strReferenceNumber NVARCHAR(50)
		,@intContractDetailId INT
		,@dblUnitPriceInSupplierContract NUMERIC(18, 6)
		,@dblClaimAmountInSupplierContract NUMERIC(18, 6)
		,@intCurrentCompanyId INT

	SELECT @intCurrentCompanyId = intCompanyId
	FROM dbo.tblIPMultiCompany
	WHERE ysnCurrentCompany = 1

	DECLARE @tblLGWeightClaimStage TABLE (intWeightClaimStageId INT)

	INSERT INTO @tblLGWeightClaimStage (intWeightClaimStageId)
	SELECT intWeightClaimStageId
	FROM tblLGWeightClaimStage
	WHERE strFeedStatus IS NULL

	SELECT @intWeightClaimStageId = MIN(intWeightClaimStageId)
	FROM @tblLGWeightClaimStage

	IF @intWeightClaimStageId IS NULL
	BEGIN
		RETURN
	END

	UPDATE S
	SET S.strFeedStatus = 'In-Progress'
	FROM tblLGWeightClaimStage S
	JOIN @tblLGWeightClaimStage TS ON TS.intWeightClaimStageId = S.intWeightClaimStageId

	WHILE @intWeightClaimStageId > 0
	BEGIN
		SELECT @intWeightClaimId = NULL
			,@strWeightClaimXML = NULL
			,@strWeightClaimDetailXML = NULL
			,@strRowState = NULL
			,@intTransactionId = NULL
			,@intCompanyId = NULL
			,@intLoadId = NULL
			,@strErrorMessage = ''

		SELECT @intWeightClaimId = intWeightClaimId
			,@strWeightClaimXML = strWeightClaimXML
			,@strWeightClaimDetailXML = strWeightClaimDetailXML
			,@strRowState = strRowState
			,@intTransactionId = intTransactionId
			,@intCompanyId = intCompanyId
		FROM tblLGWeightClaimStage
		WHERE intWeightClaimStageId = @intWeightClaimStageId

		BEGIN TRY
			SELECT @intTransactionCount = @@TRANCOUNT

			IF @intTransactionCount = 0
				BEGIN TRANSACTION

			------------------Header------------------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strWeightClaimXML

			SELECT @strBook = strBook
				,@strSubBook = strSubBook
				,@strPaymentMethod = strPaymentMethod
				,@intLoadId = intLoadId
			FROM OPENXML(@idoc, 'vyuIPGetWeightClaims/vyuIPGetWeightClaim', 2) WITH (
					strBook NVARCHAR(50) Collate Latin1_General_CI_AS
					,strSubBook NVARCHAR(50) Collate Latin1_General_CI_AS
					,strPaymentMethod NVARCHAR(50) Collate Latin1_General_CI_AS
					,intLoadId INT
					) x

			IF @strBook IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblCTBook B
					WHERE B.strBook = @strBook
					)
			BEGIN
				IF @strErrorMessage <> ''
				BEGIN
					SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Book ' + @strBook + ' is not available.'
				END
				ELSE
				BEGIN
					SELECT @strErrorMessage = 'Book ' + @strBook + ' is not available.'
				END
			END

			IF @strSubBook IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblCTSubBook SB
					WHERE SB.strSubBook = @strSubBook
					)
			BEGIN
				IF @strErrorMessage <> ''
				BEGIN
					SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Sub Book ' + @strSubBook + ' is not available.'
				END
				ELSE
				BEGIN
					SELECT @strErrorMessage = 'Sub Book ' + @strSubBook + ' is not available.'
				END
			END

			IF @strPaymentMethod IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblSMPaymentMethod PM
					WHERE PM.strPaymentMethod = @strPaymentMethod
					)
			BEGIN
				IF @strErrorMessage <> ''
				BEGIN
					SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Payment Method ' + @strPaymentMethod + ' is not available.'
				END
				ELSE
				BEGIN
					SELECT @strErrorMessage = 'Payment Method ' + @strPaymentMethod + ' is not available.'
				END
			END

			SELECT @intBookId = NULL

			SELECT @intSubBookId = NULL

			SELECT @intPaymentMethodId = NULL

			SELECT @intBookId = intBookId
			FROM tblCTBook
			WHERE strBook = @strBook

			SELECT @intSubBookId = intSubBookId
			FROM tblCTSubBook SB
			WHERE strSubBook = @strSubBook

			IF NOT EXISTS (
					SELECT *
					FROM tblLGLoad
					WHERE intLoadRefId = @intLoadId
						AND intBookId = @intBookId
						AND IsNULL(intSubBookId, 0) = IsNULL(@intSubBookId, 0)
					)
			BEGIN
				IF @strErrorMessage <> ''
				BEGIN
					SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Unable to find Outbound shipment.'
				END
				ELSE
				BEGIN
					SELECT @strErrorMessage = 'Unable to find Outbound shipment.'
				END
			END

			IF @strErrorMessage <> ''
			BEGIN
				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			SELECT @intPaymentMethodId = intPaymentMethodID
			FROM tblSMPaymentMethod PM
			WHERE PM.strPaymentMethod = @strPaymentMethod

			SELECT @intUserId = CE.intEntityId
			FROM tblEMEntity CE
			JOIN tblEMEntityType ET1 ON ET1.intEntityId = CE.intEntityId
			WHERE ET1.strType = 'User'
				AND CE.strName = @strCreatedBy
				AND CE.strEntityNo <> ''

			IF @intUserId IS NULL
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM tblSMUserSecurity
						WHERE strUserName = 'irelyadmin'
						)
					SELECT TOP 1 @intUserId = intEntityId
					FROM tblSMUserSecurity
					WHERE strUserName = 'irelyadmin'
				ELSE
					SELECT TOP 1 @intUserId = intEntityId
					FROM tblSMUserSecurity
			END

			IF @strRowState = 'Delete'
			BEGIN
				DELETE
				FROM tblLGWeightClaim
				WHERE intWeightClaimRefId = @intWeightClaimId
					AND intBookId = @intBookId
					AND IsNULL(intSubBookId, 0) = IsNULL(@intSubBookId, 0)

				GOTO x
			END

			EXEC uspSMGetStartingNumber 114
				,@strReferenceNumber OUTPUT

			--Inbound Weight Claim
			IF NOT EXISTS (
					SELECT *
					FROM tblLGWeightClaim
					WHERE intWeightClaimRefId = @intWeightClaimId
						AND intBookId = @intBookId
						AND IsNULL(intSubBookId, 0) = IsNULL(@intSubBookId, 0)
					)
			BEGIN
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
					,intBookId
					,intSubBookId
					,intPaymentMethodId
					,intWeightClaimRefId
					,intCompanyId
					)
				SELECT 1 intConcurrencyId
					,@strReferenceNumber
					,dtmTransDate
					,(
						SELECT intLoadId
						FROM tblLGLoad
						WHERE intLoadRefId = x.intLoadId
							AND intBookId = @intBookId
							AND IsNULL(intSubBookId, 0) = IsNULL(@intSubBookId, 0)
						) AS intLoadId
					,strComments
					,dtmETAPOD
					,dtmLastWeighingDate
					,dtmActualWeighingDate
					,dtmClaimValidTill
					,intPurchaseSale
					,@intBookId
					,@intSubBookId
					,@intPaymentMethodId
					,@intWeightClaimId
					,@intCurrentCompanyId
				FROM OPENXML(@idoc, 'vyuIPGetWeightClaims/vyuIPGetWeightClaim', 2) WITH (
						strReferenceNumber NVARCHAR(50) Collate Latin1_General_CI_AS
						,dtmTransDate DATETIME
						,intLoadId INT
						,strComments NVARCHAR(MAX) Collate Latin1_General_CI_AS
						,dtmETAPOD DATETIME
						,dtmLastWeighingDate DATETIME
						,dtmActualWeighingDate DATETIME
						,dtmClaimValidTill DATETIME
						,intPurchaseSale INT
						) x

				SELECT @intNewWeightClaimId = SCOPE_IDENTITY()

				SELECT @strReferenceNumber = strReferenceNumber
				FROM tblLGWeightClaim
				WHERE intWeightClaimId = @intNewWeightClaimId

				SELECT @strDescription = 'Created from inter company : ' + @strReferenceNumber

				EXEC uspSMAuditLog @keyValue = @intNewWeightClaimId
					,@screenName = 'Logistics.view.WeightClaims'
					,@entityId = @intUserId
					,@actionType = 'Created'
					,@actionIcon = 'small-new-plus'
					,@changeDescription = @strDescription
					,@fromValue = ''
					,@toValue = @strReferenceNumber
			END
			ELSE
			BEGIN
				UPDATE tblLGWeightClaim
				SET intConcurrencyId = tblLGWeightClaim.intConcurrencyId + 1
					,dtmTransDate = x.dtmTransDate
					,intLoadId = (
						SELECT intLoadId
						FROM tblLGLoad
						WHERE intLoadRefId = x.intLoadId
							AND intBookId = @intBookId
							AND IsNULL(intSubBookId, 0) = IsNULL(@intSubBookId, 0)
						)
					,strComments = x.strComments
					,dtmETAPOD = x.dtmETAPOD
					,dtmLastWeighingDate = x.dtmLastWeighingDate
					,dtmActualWeighingDate = x.dtmActualWeighingDate
					,dtmClaimValidTill = x.dtmClaimValidTill
					,intPurchaseSale = x.intPurchaseSale
					,intBookId = @intBookId
					,intSubBookId = @intSubBookId
					,intPaymentMethodId = @intPaymentMethodId
				FROM OPENXML(@idoc, 'vyuIPGetWeightClaims/vyuIPGetWeightClaim', 2) WITH (
						strReferenceNumber NVARCHAR(50) Collate Latin1_General_CI_AS
						,dtmTransDate DATETIME
						,intLoadId INT
						,strComments NVARCHAR(MAX) Collate Latin1_General_CI_AS
						,dtmETAPOD DATETIME
						,dtmLastWeighingDate DATETIME
						,dtmActualWeighingDate DATETIME
						,dtmClaimValidTill DATETIME
						,intPurchaseSale INT
						) x
				WHERE tblLGWeightClaim.intWeightClaimRefId = @intWeightClaimId
					AND intBookId = @intBookId
					AND IsNULL(intSubBookId, 0) = IsNULL(@intSubBookId, 0)

				SELECT @intNewWeightClaimId = intWeightClaimId
				FROM tblLGWeightClaim
				WHERE intWeightClaimRefId = @intWeightClaimId
					AND intBookId = @intBookId
					AND IsNULL(intSubBookId, 0) = IsNULL(@intSubBookId, 0)
			END

			SELECT @intCompanyRefId = intCompanyId
			FROM tblLGWeightClaim
			WHERE intWeightClaimId = @intNewWeightClaimId

			EXEC sp_xml_removedocument @idoc

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strWeightClaimDetailXML

			DECLARE @tblLGWeightClaimDetail TABLE (
				intWeightClaimDetailId INT identity(1, 1)
				,intConcurrencyId INT
				,intWeightClaimId INT
				,strCondition NVARCHAR(100) collate Latin1_General_CI_AS
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
				,intItemRefId INT
				,strItemNo NVARCHAR(50) collate Latin1_General_CI_AS
				,strCurrency NVARCHAR(50) collate Latin1_General_CI_AS
				,strPartyName NVARCHAR(100) collate Latin1_General_CI_AS
				,strPriceUOM NVARCHAR(50) collate Latin1_General_CI_AS
				,dblToGross NUMERIC(18, 6)
				,dblToTare NUMERIC(18, 6)
				)
			DECLARE @tblLGFinalWeightClaimDetail TABLE (
				intWeightClaimDetailId INT identity(1, 1)
				,intConcurrencyId INT
				,intWeightClaimId INT
				,strCondition NVARCHAR(100) collate Latin1_General_CI_AS
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
				,intItemRefId INT
				,dblUnitPriceInSupplierContract NUMERIC(18, 6)
				,dblClaimAmountInSupplierContract NUMERIC(18, 6)
				,dblToGross NUMERIC(18, 6)
				,dblToTare NUMERIC(18, 6)
				)

			INSERT INTO @tblLGWeightClaimDetail (
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
				,intItemRefId
				,strItemNo
				,strCurrency
				,strPartyName
				,strPriceUOM
				,dblToGross
				,dblToTare
				)
			SELECT intConcurrencyId
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
				,intItemRefId
				,strItemNo
				,strCurrency
				,strPartyName
				,strPriceUOM
				,dblToGross
				,dblToTare
			FROM OPENXML(@idoc, 'vyuIPGetWeightClaimDetails/vyuIPGetWeightClaimDetail', 2) WITH (
					intConcurrencyId INT
					,intWeightClaimId INT
					,strCondition NVARCHAR(100) collate Latin1_General_CI_AS
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
					--,strUnitMeasure NVARCHAR(50) collate Latin1_General_CI_AS
					,dblAdditionalCost NUMERIC(18, 6)
					,ysnNoClaim BIT
					,intContractDetailId INT
					,intBillId INT
					,intInvoiceId INT
					,dblFranchise NUMERIC(18, 6)
					,dblSeqPriceConversionFactoryWeightUOM NUMERIC(18, 6)
					,intWeightClaimDetailRefId INT
					,intItemRefId INT
					,strItemNo NVARCHAR(50) collate Latin1_General_CI_AS
					,strCurrency NVARCHAR(50) collate Latin1_General_CI_AS
					,strPartyName NVARCHAR(100) collate Latin1_General_CI_AS
					,strPriceUOM NVARCHAR(50) collate Latin1_General_CI_AS
					,dblToGross NUMERIC(18, 6)
					,dblToTare NUMERIC(18, 6)
					)

			DECLARE @intWeightClaimDetailId INT
				,@strItemNo NVARCHAR(50)
				,@strCurrency NVARCHAR(50)
				,@strPartyName NVARCHAR(100)
				,@strUnitMeasure NVARCHAR(50)
				,@strPriceUOM NVARCHAR(50)
				,@intItemId INT
				,@intCurrencyId INT
				,@intEntityId INT
				,@intPriceItemUOMId INT
				,@intPartyEntityId INT

			SELECT @intWeightClaimDetailId = min(intWeightClaimDetailId)
			FROM @tblLGWeightClaimDetail

			WHILE @intWeightClaimDetailId IS NOT NULL
			BEGIN
				SELECT @strItemNo = NULL
					,@strCurrency = NULL
					,@strPartyName = NULL
					,@strPriceUOM = NULL
					,@strErrorMessage = ''
					,@intContractDetailId = NULL

				SELECT @strItemNo = strItemNo
					,@strCurrency = strCurrency
					,@strPartyName = strPartyName
					,@strPriceUOM = strPriceUOM
					,@intContractDetailId = intContractDetailId
				FROM @tblLGWeightClaimDetail
				WHERE intWeightClaimDetailId = @intWeightClaimDetailId

				SELECT @intItemId = NULL

				SELECT @intItemId = intItemId
				FROM tblICItem
				WHERE strItemNo = @strItemNo

				IF @strItemNo IS NOT NULL
					AND @intItemId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Item ' + @strItemNo + ' is not available.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Item ' + @strItemNo + ' is not available.'
					END
				END

				SELECT @intCurrencyId = NULL

				SELECT @intCurrencyId = intCurrencyID
				FROM [tblSMCurrency]
				WHERE strCurrency = @strCurrency

				IF @strCurrency IS NOT NULL
					AND @intCurrencyId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Currency ' + @strCurrency + ' is not available.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Currency ' + @strCurrency + ' is not available.'
					END
				END

				SELECT @intEntityId = NULL

				SELECT @intEntityId = E.intEntityId
				FROM tblEMEntity E
				JOIN tblEMEntityType ET ON ET.intEntityId = E.intEntityId
				WHERE strName = @strPartyName
					AND ET.strType = 'Vendor'

				IF @strPartyName IS NOT NULL
					AND @intEntityId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Party Name ' + @strPartyName + ' is not available.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Party Name ' + @strPartyName + ' is not available.'
					END
				END

				SELECT @intUnitMeasureId = NULL

				SELECT @intUnitMeasureId = intUnitMeasureId
				FROM tblICUnitMeasure
				WHERE strUnitMeasure = @strPriceUOM

				IF @strPriceUOM IS NOT NULL
					AND @intUnitMeasureId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Price UOM ' + @strPriceUOM + ' is not available.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Price UOM ' + @strPriceUOM + ' is not available.'
					END
				END

				SELECT @intPriceItemUOMId = intItemUOMId
				FROM tblICItemUOM
				WHERE intItemId = @intItemId
					AND intUnitMeasureId = @intUnitMeasureId

				IF @intPriceItemUOMId IS NULL
				BEGIN
					SELECT @strItemNo = strItemNo
					FROM tblICItem
					WHERE intItemId = @intItemId

					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Price UOM ' + @strPriceUOM + ' is not associated for the item ' + @strItemNo + '.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Price UOM ' + @strPriceUOM + ' is not associated for the item ' + @strItemNo + '.'
					END
				END

				IF @strErrorMessage <> ''
				BEGIN
					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				SELECT @dblUnitPriceInSupplierContract = AD.dblSeqPrice
					,@dblClaimAmountInSupplierContract = (WUI.dblUnitQty / PUI.dblUnitQty) * AD.dblSeqPrice / (
						CASE 
							WHEN ysnSeqSubCurrency = 1
								THEN 100
							ELSE 1
							END
						)
				FROM tblLGLoad L
				JOIN tblICUnitMeasure WUOM ON WUOM.intUnitMeasureId = L.intWeightUnitMeasureId
					AND L.intLoadRefId = @intLoadId
					AND L.intBookId = @intBookId
					AND IsNULL(L.intSubBookId, 0) = IsNULL(@intSubBookId, 0)
				JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
				JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
				JOIN tblCTContractDetail SCD ON SCD.intContractDetailId = LD.intSContractDetailId
					AND SCD.intContractDetailRefId = @intContractDetailId
					AND SCD.intBookId = @intBookId
					AND IsNULL(SCD.intSubBookId, 0) = IsNULL(@intSubBookId, 0)
				JOIN vyuLGAdditionalColumnForContractDetailView AD ON AD.intContractDetailId = CD.intContractDetailId
				OUTER APPLY (
					SELECT TOP 1 intWeightUOMId = IU.intItemUOMId
						,dblUnitQty
					FROM tblICItemUOM IU
					WHERE IU.intItemId = CD.intItemId
						AND IU.intUnitMeasureId = WUOM.intUnitMeasureId
					) WUI
				OUTER APPLY (
					SELECT TOP 1 intPriceUOMId = IU.intItemUOMId
						,dblUnitQty
					FROM tblICItemUOM IU
					WHERE IU.intItemUOMId = AD.intSeqPriceUOMId
					) PUI

				INSERT INTO @tblLGFinalWeightClaimDetail (
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
					,intItemRefId
					,dblUnitPriceInSupplierContract
					,dblClaimAmountInSupplierContract
					,dblToGross
					,dblToTare
					)
				SELECT 1 AS intConcurrencyId
					,@intNewWeightClaimId
					,strCondition
					,@intItemId
					,dblQuantity
					,dblFromNet
					,dblToNet
					,dblFranchiseWt
					,dblWeightLoss
					,dblClaimableWt
					,@intPartyEntityId
					,dblUnitPrice
					,@intCurrencyId
					,dblClaimAmount
					,@intPriceItemUOMId
					,dblAdditionalCost
					,ysnNoClaim
					,WCD.intContractDetailId
					,intBillId
					,intInvoiceId
					,dblFranchise
					,dblSeqPriceConversionFactoryWeightUOM
					,intWeightClaimDetailRefId
					,intItemRefId
					,@dblUnitPriceInSupplierContract
					,@dblClaimAmountInSupplierContract
					,dblToGross
					,dblToTare
				FROM @tblLGWeightClaimDetail WCD
				WHERE intWeightClaimDetailId = @intWeightClaimDetailId

				SELECT @intWeightClaimDetailId = min(intWeightClaimDetailId)
				FROM @tblLGWeightClaimDetail
				WHERE intWeightClaimDetailId > @intWeightClaimDetailId
			END

			DELETE
			FROM tblLGWeightClaimDetail
			WHERE intWeightClaimId = @intNewWeightClaimId

			INSERT INTO tblLGWeightClaimDetail (
				[intConcurrencyId]
				,[intWeightClaimId]
				,[strCondition]
				,[intItemId]
				,[dblQuantity]
				,[dblFromNet]
				,[dblToNet]
				,[dblFranchiseWt]
				,[dblWeightLoss]
				,[dblClaimableWt]
				,[intPartyEntityId]
				,[dblUnitPrice]
				,[intCurrencyId]
				,[dblClaimAmount]
				,[intPriceItemUOMId]
				,[dblAdditionalCost]
				,[ysnNoClaim]
				,[intContractDetailId]
				,[intBillId]
				,[intInvoiceId]
				,[dblFranchise]
				,[dblSeqPriceConversionFactoryWeightUOM]
				,[intWeightClaimDetailRefId]
				,dblToGross
				,dblToTare
				)
			SELECT [intConcurrencyId]
				,[intWeightClaimId]
				,[strCondition]
				,[intItemId]
				,[dblQuantity]
				,[dblFromNet]
				,[dblToNet]
				,[dblFranchiseWt]
				,[dblWeightLoss]
				,[dblClaimableWt]
				,(
					SELECT TOP 1 CH.intEntityId
					FROM tblCTContractDetail CD
					JOIN tblLGAllocationDetail AD ON AD.intSContractDetailId = CD.intContractDetailId
					JOIN tblCTContractDetail CD1 ON CD1.intContractDetailId = AD.intPContractDetailId
					JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD1.intContractHeaderId
					WHERE CD.intContractDetailRefId = IA.intContractDetailId
						AND CD.intBookId = @intBookId
						AND IsNULL(CD.intSubBookId, 0) = IsNULL(@intSubBookId, 0)
					) AS [intPartyEntityId]
				,dblUnitPriceInSupplierContract
				,[intCurrencyId]
				,ABS(Round([dblClaimableWt] * dblClaimAmountInSupplierContract, 2))
				,[intPriceItemUOMId]
				,[dblAdditionalCost]
				,[ysnNoClaim]
				,(
					SELECT TOP 1 AD.intPContractDetailId
					FROM tblCTContractDetail CD
					JOIN tblLGAllocationDetail AD ON AD.intSContractDetailId = CD.intContractDetailId
					WHERE CD.intContractDetailRefId = IA.intContractDetailId
						AND CD.intBookId = @intBookId
						AND IsNULL(CD.intSubBookId, 0) = IsNULL(@intSubBookId, 0)
					) AS intContractDetailId
				,[intBillId]
				,[intInvoiceId]
				,[dblFranchise]
				,[dblSeqPriceConversionFactoryWeightUOM]
				,[intWeightClaimDetailRefId]
				,dblToGross
				,dblToTare
			FROM @tblLGFinalWeightClaimDetail IA

			DELETE
			FROM @tblLGWeightClaimDetail

			EXEC sp_xml_removedocument @idoc

			UPDATE tblLGWeightClaimStage
			SET strFeedStatus = 'Processed'
			WHERE intWeightClaimStageId = @intWeightClaimStageId

			SELECT @intWeightClaimScreenId = intScreenId
			FROM tblSMScreen
			WHERE strNamespace = 'Logistics.view.WeightClaims'

			SELECT @intTransactionRefId = intTransactionId
			FROM tblSMTransaction
			WHERE intRecordId = @intNewWeightClaimId
				AND intScreenId = @intWeightClaimScreenId

			IF @intTransactionRefId IS NOT NULL
				AND @intTransactionId IS NOT NULL
			BEGIN
				BEGIN TRY
					EXECUTE dbo.uspSMInterCompanyUpdateMapping @currentTransactionId = @intTransactionRefId
						,@referenceTransactionId = @intTransactionId
						,@referenceCompanyId = @intCompanyId
				END TRY

				BEGIN CATCH
				END CATCH
			END

			INSERT INTO tblLGWeightClaimAcknowledgementStage (
				intWeightClaimId
				,intWeightClaimRefId
				,strMessage
				,intTransactionId
				,intCompanyId
				,intTransactionRefId
				,intCompanyRefId
				)
			SELECT @intWeightClaimId
				,@intNewWeightClaimId
				,'Success'
				,@intTransactionId
				,@intCompanyId
				,@intTransactionRefId
				,@intCompanyRefId

			---**********************************************
			---**********************************************
			---**********************************************
			--Outbound WeightClaim
			EXEC uspSMGetStartingNumber 114
				,@strReferenceNumber OUTPUT

			IF NOT EXISTS (
					SELECT *
					FROM tblLGWeightClaim
					WHERE intWeightClaimRefId = @intNewWeightClaimId
						AND intBookId = @intBookId
						AND IsNULL(intSubBookId, 0) = IsNULL(@intSubBookId, 0)
					)
			BEGIN
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
					,intBookId
					,intSubBookId
					,intPaymentMethodId
					,intWeightClaimRefId
					,intCompanyId
					)
				SELECT intConcurrencyId
					,@strReferenceNumber
					,dtmTransDate
					,intLoadId
					,strComments
					,dtmETAPOD
					,dtmLastWeighingDate
					,dtmActualWeighingDate
					,dtmClaimValidTill
					,2 AS intPurchaseSale
					,intBookId
					,intSubBookId
					,intPaymentMethodId
					,@intNewWeightClaimId
					,@intCurrentCompanyId
				FROM tblLGWeightClaim
				WHERE intWeightClaimId = @intNewWeightClaimId

				SELECT @intNewWeightClaimId2 = SCOPE_IDENTITY()

				EXEC uspSMAuditLog @keyValue = @intNewWeightClaimId2
					,@screenName = 'Logistics.view.WeightClaims'
					,@entityId = @intUserId
					,@actionType = 'Created'
					,@actionIcon = 'small-new-plus'
					,@changeDescription = @strDescription
					,@fromValue = ''
					,@toValue = @strReferenceNumber
			END
			ELSE
			BEGIN
				UPDATE WC
				SET intConcurrencyId = WC1.intConcurrencyId + 1
					--,strReferenceNumber = WC1.strReferenceNumber
					,dtmTransDate = WC1.dtmTransDate
					,intLoadId = WC1.intLoadId
					,strComments = WC1.strComments
					,dtmETAPOD = WC1.dtmETAPOD
					,dtmLastWeighingDate = WC1.dtmLastWeighingDate
					,dtmActualWeighingDate = WC1.dtmActualWeighingDate
					,dtmClaimValidTill = WC1.dtmClaimValidTill
					,intPurchaseSale = WC1.intPurchaseSale
					,intBookId = WC1.intBookId
					,intSubBookId = WC1.intSubBookId
					,intPaymentMethodId = WC1.intPaymentMethodId
				FROM tblLGWeightClaim WC
				JOIN tblLGWeightClaim WC1 ON WC.intWeightClaimRefId = WC1.intWeightClaimId
					AND WC.intBookId = @intBookId
					AND IsNULL(WC.intSubBookId, 0) = IsNULL(@intSubBookId, 0)
				WHERE WC1.intWeightClaimId = @intNewWeightClaimId

				SELECT @intNewWeightClaimId2 = intWeightClaimId
				FROM tblLGWeightClaim
				WHERE intWeightClaimRefId = @intNewWeightClaimId
					AND intBookId = @intBookId
					AND IsNULL(intSubBookId, 0) = IsNULL(@intSubBookId, 0)
			END

			DELETE
			FROM tblLGWeightClaimDetail
			WHERE intWeightClaimId = @intNewWeightClaimId2

			INSERT INTO tblLGWeightClaimDetail (
				[intConcurrencyId]
				,[intWeightClaimId]
				,[strCondition]
				,[intItemId]
				,[dblQuantity]
				,[dblFromNet]
				,[dblToNet]
				,[dblFranchiseWt]
				,[dblWeightLoss]
				,[dblClaimableWt]
				,[intPartyEntityId]
				,[dblUnitPrice]
				,[intCurrencyId]
				,[dblClaimAmount]
				,[intPriceItemUOMId]
				,[dblAdditionalCost]
				,[ysnNoClaim]
				,[intContractDetailId]
				,[intBillId]
				,[intInvoiceId]
				,[dblFranchise]
				,[dblSeqPriceConversionFactoryWeightUOM]
				,[intWeightClaimDetailRefId]
				,dblToGross
				,dblToTare
				)
			SELECT [intConcurrencyId]
				,@intNewWeightClaimId2
				,[strCondition]
				,[intItemId]
				,[dblQuantity]
				,[dblFromNet]
				,[dblToNet]
				,[dblFranchiseWt]
				,[dblWeightLoss]
				,[dblClaimableWt]
				,(
					SELECT TOP 1 CH.intEntityId
					FROM tblCTContractDetail CD
					JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
					WHERE CD.intContractDetailRefId = WCD.intContractDetailId
						AND CH.intBookId = @intBookId
						AND IsNULL(CH.intSubBookId, 0) = IsNULL(@intSubBookId, 0)
					) AS [intPartyEntityId]
				,[dblUnitPrice]
				,[intCurrencyId]
				,[dblClaimAmount]
				,[intPriceItemUOMId]
				,[dblAdditionalCost]
				,[ysnNoClaim]
				,(
					SELECT TOP 1 CD.intContractDetailId
					FROM tblCTContractDetail CD
					WHERE CD.intContractDetailRefId = WCD.intContractDetailId
						AND CD.intBookId = @intBookId
						AND IsNULL(CD.intSubBookId, 0) = IsNULL(@intSubBookId, 0)
					) AS intContractDetailId
				,[intBillId]
				,[intInvoiceId]
				,[dblFranchise]
				,[dblSeqPriceConversionFactoryWeightUOM]
				,[intWeightClaimDetailRefId]
				,dblToGross
				,dblToTare
			FROM @tblLGFinalWeightClaimDetail WCD

			IF @intTransactionCount = 0
				COMMIT TRANSACTION
		END TRY

		BEGIN CATCH
			SET @ErrMsg = ERROR_MESSAGE()

			IF @idoc <> 0
				EXEC sp_xml_removedocument @idoc

			IF XACT_STATE() != 0
				AND @intTransactionCount = 0
				ROLLBACK TRANSACTION

			UPDATE tblLGWeightClaimStage
			SET strFeedStatus = 'Failed'
				,strMessage = @ErrMsg
			WHERE intWeightClaimStageId = @intWeightClaimStageId
		END CATCH

		x:

		SELECT @intWeightClaimStageId = MIN(intWeightClaimStageId)
		FROM @tblLGWeightClaimStage
		WHERE intWeightClaimStageId > @intWeightClaimStageId
	END

	UPDATE S
	SET S.strFeedStatus = NULL
	FROM tblLGWeightClaimStage S
	JOIN @tblLGWeightClaimStage TS ON TS.intWeightClaimStageId = S.intWeightClaimStageId
	WHERE S.strFeedStatus = 'In-Progress'
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
