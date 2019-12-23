CREATE PROCEDURE [dbo].[uspIPWeightClaimProcessStgXML] @intCompanyId INT
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
		,@intWeightClaimId INT
		,@strWeightClaimXML NVARCHAR(MAX)
		,@strWeightClaimDetailXML NVARCHAR(MAX)
		--,@strReportAttributeValueXML NVARCHAR(MAX)
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
		--,@intCompanyId INT
		,@intLoadScreenId INT
		,@intTransactionRefId INT
		,@intCompanyRefId INT
		,@strDescription NVARCHAR(50)
		,@intWeightClaimScreenId INT
		--,@intNewInvPlngReportMasterID INT
		,@strPaymentMethod NVARCHAR(50)
		,@intPaymentMethodId INT

	SELECT @intWeightClaimStageId = MIN(intWeightClaimStageId)
	FROM tblLGWeightClaimStage
	WHERE ISNULL(strFeedStatus, '') = ''

	WHILE @intWeightClaimStageId > 0
	BEGIN
		SELECT @intWeightClaimId = NULL
			,@strWeightClaimXML = NULL
			,@strWeightClaimDetailXML = NULL
			,@strRowState = NULL
			,@intTransactionId = NULL
			,@intCompanyId = NULL

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

			IF @strRowState = 'Delete'
			BEGIN
				DELETE
				FROM tblLGWeightClaim
				WHERE intWeightClaimRefId = @intWeightClaimId

				GOTO x
			END

			------------------Header------------------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strWeightClaimXML

			SELECT @strBook = strBook
				,@strSubBook = strSubBook
				,@strPaymentMethod = strPaymentMethod
			FROM OPENXML(@idoc, 'vyuIPGetWeightClaims/vyuIPGetWeightClaim', 2) WITH (
					strBook NVARCHAR(50) Collate Latin1_General_CI_AS
					,strSubBook NVARCHAR(50) Collate Latin1_General_CI_AS
					,strPaymentMethod NVARCHAR(50) Collate Latin1_General_CI_AS
					) x

			IF @strBook IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblCTBook B
					WHERE B.strBook = @strBook
					)
			BEGIN
				SELECT @strErrorMessage = 'Book ' + @strBook + ' is not available.'

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			IF @strSubBook IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblCTSubBook SB
					WHERE SB.strSubBook = @strSubBook
					)
			BEGIN
				SELECT @strErrorMessage = 'Sub Book ' + @strSubBook + ' is not available.'

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			IF @strPaymentMethod IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblSMPaymentMethod PM
					WHERE PM.strPaymentMethod = @strPaymentMethod
					)
			BEGIN
				SELECT @strErrorMessage = 'Payment Method ' + @strPaymentMethod + ' is not available.'

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
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

			IF NOT EXISTS (
					SELECT *
					FROM tblLGWeightClaim
					WHERE intWeightClaimRefId = @intWeightClaimId
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
					,ysnPosted
					,dtmPosted
					,intCompanyId
					,intBookId
					,intSubBookId
					,intPaymentMethodId
					,intWeightClaimRefId
					)
				SELECT 1 intConcurrencyId
					,strReferenceNumber
					,dtmTransDate
					,(
						SELECT intLoadId
						FROM tblLGLoad
						WHERE intLoadRefId = x.intLoadId
						) AS intLoadId
					,strComments
					,dtmETAPOD
					,dtmLastWeighingDate
					,dtmActualWeighingDate
					,dtmClaimValidTill
					,intPurchaseSale
					,0 ysnPosted
					,NULL dtmPosted
					,@intCompanyId
					,@intBookId
					,@intSubBookId
					,@intPaymentMethodId
					,@intWeightClaimId
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
			END
			ELSE
			BEGIN
				UPDATE tblLGWeightClaim
				SET intConcurrencyId = tblLGWeightClaim.intConcurrencyId + 1
					,strReferenceNumber = x.strReferenceNumber
					,dtmTransDate = x.dtmTransDate
					,intLoadId = (
						SELECT intLoadId
						FROM tblLGLoad
						WHERE intLoadRefId = x.intLoadId
						)
					,strComments = x.strComments
					,dtmETAPOD = x.dtmETAPOD
					,dtmLastWeighingDate = x.dtmLastWeighingDate
					,dtmActualWeighingDate = x.dtmActualWeighingDate
					,dtmClaimValidTill = x.dtmClaimValidTill
					,intPurchaseSale = x.intPurchaseSale
					--,ysnPosted = x.ysnPosted
					--,dtmPosted = x.dtmPosted
					,intCompanyId = @intCompanyId
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
			END

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
				,strUnitMeasure NVARCHAR(50) collate Latin1_General_CI_AS
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
				--,strUnitMeasure
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
				,strUnitMeasure
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
				--,strUnitMeasure
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
				,strUnitMeasure
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
					,strUnitMeasure NVARCHAR(50) collate Latin1_General_CI_AS
					)

			DECLARE @intWeightClaimDetailId INT
				,@strItemNo NVARCHAR(50)
				,@strCurrency NVARCHAR(50)
				,@strPartyName NVARCHAR(100)
				,@strUnitMeasure NVARCHAR(50)
				,@strPriceUOM nvarchar(50)
				,@intItemId int
				,@intCurrencyId int
				,@intEntityId int
				,@intPriceItemUOMId int
				,@intPartyEntityId int

			SELECT @intWeightClaimDetailId = min(intWeightClaimDetailId)
			FROM @tblLGWeightClaimDetail

			WHILE @intWeightClaimDetailId IS NOT NULL
			BEGIN
				SELECT @strItemNo = NULL
					,@strCurrency = NULL
					,@strPartyName = NULL
					,@strPriceUOM = NULL

				SELECT @strItemNo = strItemNo
					,@strCurrency = strCurrency
					,@strPartyName = strPartyName
					--,@strPriceUOM = strPriceUOM
				FROM @tblLGWeightClaimDetail
				WHERE intWeightClaimDetailId = @intWeightClaimDetailId

				SELECT @intItemId = NULL

				SELECT @intItemId = intItemId
				FROM tblICItem
				WHERE strItemNo = @strItemNo

				IF @strItemNo IS NOT NULL
					AND @intItemId IS NULL
				BEGIN
					SELECT @strErrorMessage = 'Item ' + @strItemNo + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				SELECT @intCurrencyId = NULL

				SELECT @intCurrencyId = intCurrencyID
				FROM [tblSMCurrency]
				WHERE strCurrency = @strCurrency

				IF @strCurrency IS NOT NULL
					AND @intCurrencyId IS NULL
				BEGIN
					SELECT @strErrorMessage = 'Currency ' + @strCurrency + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				SELECT @intEntityId = NULL

				SELECT @intEntityId = E.intEntityId
				FROM tblEMEntity E
				JOIN tblEMEntityType ET ON ET.intEntityId=E.intEntityId 
				WHERE strName = @strPartyName
					AND ET.strType = 'Vendor'

				IF @strPartyName IS NOT NULL
					AND @intEntityId IS NULL
				BEGIN
					SELECT @strErrorMessage = 'Party Name ' + @strPartyName + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				SELECT @intUnitMeasureId = NULL

				SELECT @intUnitMeasureId = intUnitMeasureId
				FROM tblICUnitMeasure
				WHERE strUnitMeasure = @strPriceUOM

				IF @strPriceUOM IS NOT NULL
					AND @intUnitMeasureId IS NULL
				BEGIN
					SELECT @strErrorMessage = 'Price UOM ' + @strPriceUOM + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
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

					SELECT @strErrorMessage = 'Price UOM ' + @strPriceUOM + ' is not associated for the item ' + @strItemNo + '.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

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
					--,strUnitMeasure
					,dblAdditionalCost
					,ysnNoClaim
					,intContractDetailId
					,intBillId
					,intInvoiceId
					,dblFranchise
					,dblSeqPriceConversionFactoryWeightUOM
					,intWeightClaimDetailRefId
					,intItemRefId
					)
				SELECT intConcurrencyId
					,intWeightClaimId
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
					--,strUnitMeasure
					,dblAdditionalCost
					,ysnNoClaim
					,intContractDetailId
					,intBillId
					,intInvoiceId
					,dblFranchise
					,dblSeqPriceConversionFactoryWeightUOM
					,intWeightClaimDetailRefId
					,intItemRefId
				FROM @tblLGWeightClaimDetail
				WHERE intWeightClaimDetailId = @intWeightClaimDetailId

				SELECT @intWeightClaimDetailId = min(intWeightClaimDetailId)
				FROM @tblLGWeightClaimDetail
				WHERE intWeightClaimDetailId > @intWeightClaimDetailId
			END

			DELETE
			FROM tblLGWeightClaimDetail
			WHERE intWeightClaimId = @intWeightClaimId

			--	AND NOT EXISTS (
			--		SELECT *
			--		FROM @tblLGFinalWeightClaimDetail
			--		WHERE intWeightClaimId = @intWeightClaimId
			--		)
			--UPDATE IA1
			--SET [intConcurrencyId] = WCD.[intConcurrencyId]
			--	,[intWeightClaimId] = WCD.[intWeightClaimId]
			--	,[strCondition] = WCD.[strCondition]
			--	,[intItemId] = WCD.[intItemId]
			--	,[dblQuantity] = WCD.[dblQuantity]
			--	,[dblFromNet] = WCD.[dblFromNet]
			--	,[dblToNet] = WCD.[dblToNet]
			--	,[dblFranchiseWt] = WCD.[dblFranchiseWt]
			--	,[dblWeightLoss] = WCD.[dblWeightLoss]
			--	,[dblClaimableWt] = WCD.[dblClaimableWt]
			--	,[intPartyEntityId] = WCD.[intPartyEntityId]
			--	,[dblUnitPrice] = WCD.[dblUnitPrice]
			--	,[intCurrencyId] = WCD.[intCurrencyId]
			--	,[dblClaimAmount] = WCD.[dblClaimAmount]
			--	,[intPriceItemUOMId] = WCD.[intPriceItemUOMId]
			--	,[dblAdditionalCost] = WCD.[dblAdditionalCost]
			--	,[ysnNoClaim] = WCD.[ysnNoClaim]
			--	,[intContractDetailId] = WCD.[intContractDetailId]
			--	,[intBillId] = WCD.[intBillId]
			--	,[intInvoiceId] = WCD.[intInvoiceId]
			--	,[dblFranchise] = WCD.[dblFranchise]
			--	,[dblSeqPriceConversionFactoryWeightUOM] = WCD.[dblSeqPriceConversionFactoryWeightUOM]
			--	,[intWeightClaimDetailRefId] = WCD.[intWeightClaimDetailRefId]
			--FROM @tblLGFinalWeightClaimDetail WCD
			--JOIN tblLGWeightClaimDetail WCD1 ON WCD1.intWeightClaimId = WCD.intWeightClaimId
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
			FROM @tblLGFinalWeightClaimDetail IA

			--WHERE NOT EXISTS (
			--		SELECT *
			--		FROM tblLGWeightClaimDetail
			--		WHERE intWeightClaimId = @intWeightClaimId
			--		)
			DELETE
			FROM @tblLGWeightClaimDetail

			DELETE
			FROM @tblLGFinalWeightClaimDetail

			EXEC sp_xml_removedocument @idoc

			ext:

			UPDATE tblLGWeightClaimStage
			SET strFeedStatus = 'Processed'
			WHERE intWeightClaimStageId = @intWeightClaimStageId

			SELECT @intWeightClaimScreenId = intScreenId
			FROM tblSMScreen
			WHERE strNamespace = 'Manufacturing.view.WeightClaimAnalysisView'

			SELECT @intTransactionRefId = intTransactionId
			FROM tblSMTransaction
			WHERE intRecordId = @intWeightClaimId
				AND intScreenId = @intWeightClaimScreenId

			EXECUTE dbo.uspSMInterCompanyUpdateMapping @currentTransactionId = @intTransactionRefId
				,@referenceTransactionId = @intTransactionId
				,@referenceCompanyId = @intCompanyId

			INSERT INTO tblMFWeightClaimAcknowledgementStage (
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
		FROM tblLGWeightClaimStage
		WHERE intWeightClaimStageId > @intWeightClaimStageId
			AND ISNULL(strFeedStatus, '') = ''
	END
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

