﻿CREATE PROCEDURE [dbo].[uspARInvoiceProcessStgXML]
	--@intToCompanyId INT
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
		,@strRowState NVARCHAR(50)
		,@intTransactionCount INT
		,@strLocationName NVARCHAR(50)
		,@strUnitMeasure NVARCHAR(50)
		,@strBook NVARCHAR(50)
		,@strSubBook NVARCHAR(50)
		,@strCreatedBy NVARCHAR(50)
		,@strErrorMessage NVARCHAR(MAX)
		,@intUnitMeasureId INT
		,@intUserId INT
		,@intBookId INT
		,@intSubBookId INT
		,@idoc INT
		,@intInvoiceStageId INT
		,@intLocationId INT
		,@intTransactionId INT
		,@intCompanyId INT
		,@intTransactionRefId INT
		,@intCompanyRefId INT
		,@strHeaderXML NVARCHAR(MAX)
		,@strDetailXML NVARCHAR(MAX)
		,@strTransactionType NVARCHAR(50)
		,@dtmInvoiceDate DATETIME
		,@strInvoiceNumber NVARCHAR(50)
		,@strCurrency NVARCHAR(50)
		,@strComments NVARCHAR(50)
		,@intInvoiceId INT
		,@intEntityId INT
		,@strItemNo NVARCHAR(50)
		,@strWeightUnitMeasure NVARCHAR(50)
		,@intItemId INT
		,@intItemUOMId INT
		,@intWeightUnitMeasureId INT
		,@intWeightItemUOMId INT
		,@intContractDetailRefId INT
		,@intContractDetailId INT
		,@intContractHeaderId INT
		,@intInvoiceDetailId INT
		,@voucherNonInvDetails VoucherPayable
		,@type INT
		,@strDocType NVARCHAR(50) = 'AP Voucher'
		,@intBillInvoiceId INT
		,@intVoucherScreenId INT
		,@intBillId INT
	DECLARE @tblIPInvoiceDetail TABLE (
		intInvoiceDetailId INT identity(1, 1)
		,strItemNo NVARCHAR(50)
		,intContractHeaderId INT
		,intContractDetailId INT
		,dblQtyOrdered NUMERIC(18, 6)
		,dblQtyShipped NUMERIC(18, 6)
		,strUnitMeasure NVARCHAR(50)
		,dblPrice NUMERIC(18, 6)
		,dblTotal NUMERIC(18, 6)
		,dblShipmentNetWt NUMERIC(18, 6)
		,dblItemWeight NUMERIC(18, 6)
		,strWeightUnitMeasure NVARCHAR(50)
		,intInvoiceId INT
		)
	DECLARE @tblIPFinalInvoiceDetail TABLE (
		intItemId INT
		,intContractHeaderId INT
		,intContractDetailId INT
		,dblQtyOrdered NUMERIC(18, 6)
		,dblQtyShipped NUMERIC(18, 6)
		,intUnitMeasureId INT
		,dblPrice NUMERIC(18, 6)
		,dblTotal NUMERIC(18, 6)
		,dblShipmentNetWt NUMERIC(18, 6)
		,dblItemWeight NUMERIC(18, 6)
		,intWeightUnitMeasureId INT
		,intInvoiceId INT
		)

	SELECT @intInvoiceStageId = MIN(intInvoiceStageId)
	FROM tblARInvoiceStage
	WHERE ISNULL(strFeedStatus, '') = ''

	WHILE @intInvoiceStageId > 0
	BEGIN
		SELECT @strHeaderXML = NULL
			,@strDetailXML = NULL
			,@strRowState = NULL
			,@intTransactionId = NULL
			,@intCompanyId = NULL
			,@strErrorMessage = ''
			,@intEntityId = NULL

		SELECT @strHeaderXML = strHeaderXML
			,@strDetailXML = strDetailXML
			,@strRowState = strRowState
			,@intTransactionId = intTransactionId
			,@intCompanyId = intCompanyId
			,@intEntityId = intEntityId
		FROM tblARInvoiceStage
		WHERE intInvoiceStageId = @intInvoiceStageId

		BEGIN TRY
			SELECT @intTransactionCount = @@TRANCOUNT

			IF @intTransactionCount = 0
				BEGIN TRANSACTION

			------------------Header------------------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strHeaderXML

			SELECT @strTransactionType = NULL
				,@strBook = NULL
				,@strSubBook = NULL
				,@dtmInvoiceDate = NULL
				,@strLocationName = NULL
				,@strInvoiceNumber = NULL
				,@strCurrency = NULL
				,@strComments = NULL
				,@intInvoiceId = NULL
				,@strCreatedBy = NULL

			SELECT @strTransactionType = strTransactionType
				,@strBook = strBook
				,@strSubBook = strSubBook
				,@dtmInvoiceDate = dtmInvoiceDate
				,@strLocationName = strLocationName
				,@strInvoiceNumber = strInvoiceNumber
				,@strCurrency = strCurrency
				,@strComments = strComments
				,@intInvoiceId = intInvoiceId
				,@strCreatedBy = strCreatedBy
			FROM OPENXML(@idoc, 'vyuIPGetInvoices/vyuIPGetInvoice', 2) WITH (
					strTransactionType NVARCHAR(50)
					,strBook NVARCHAR(50)
					,strSubBook NVARCHAR(50)
					,dtmInvoiceDate DATETIME
					,strLocationName NVARCHAR(50)
					,strInvoiceNumber NVARCHAR(50)
					,strCurrency NVARCHAR(50)
					,strComments NVARCHAR(50)
					,intInvoiceId INT
					,strCreatedBy NVARCHAR(50)
					) x

			IF @strCurrency IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblSMCurrency
					WHERE strCurrency = @strCurrency
					)
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

			IF @strLocationName IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblSMCompanyLocation CL
					WHERE CL.strLocationName = @strLocationName
					)
			BEGIN
				IF @strErrorMessage <> ''
				BEGIN
					SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Location Name ' + @strLocationName + ' is not available.'
				END
				ELSE
				BEGIN
					SELECT @strErrorMessage = 'Location Name ' + @strLocationName + ' is not available.'
				END
			END

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

			SELECT @intBookId = NULL

			SELECT @intSubBookId = NULL

			SELECT @intBookId = intBookId
			FROM tblCTBook
			WHERE strBook = @strBook

			SELECT @intSubBookId = intSubBookId
			FROM tblCTSubBook SB
			WHERE strSubBook = @strSubBook
				AND intBookId = @intBookId

			IF @strErrorMessage <> ''
			BEGIN
				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			IF @strRowState = 'Delete'
			BEGIN
				DELETE
				FROM tblAPBill
				WHERE intInvoiceRefId = @intInvoiceId
					AND intBookId = @intBookId
					AND IsNULL(intSubBookId, 0) = IsNULL(@intSubBookId, 0)

				GOTO ext
			END

			SELECT @intLocationId = NULL

			SELECT @intLocationId = intCompanyLocationId
			FROM tblSMCompanyLocation
			WHERE strLocationName = @strLocationName

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

			EXEC sp_xml_removedocument @idoc

			---******************************** Item Substitute ********************************************
			SELECT @strErrorMessage = ''

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strDetailXML
			
			Delete from @tblIPInvoiceDetail
			Delete from @tblIPFinalInvoiceDetail
			INSERT INTO @tblIPInvoiceDetail (
				strItemNo
				,intContractHeaderId
				,intContractDetailId
				,dblQtyOrdered
				,dblQtyShipped
				,strUnitMeasure
				,dblPrice
				,dblTotal
				,dblShipmentNetWt
				,dblItemWeight
				,strWeightUnitMeasure
				,intInvoiceId
				)
			SELECT strItemNo
				,intContractHeaderId
				,intContractDetailId
				,dblQtyOrdered
				,dblQtyShipped
				,strUnitMeasure
				,dblPrice
				,dblTotal
				,dblShipmentNetWt
				,dblItemWeight
				,strWeightUnitMeasure
				,intInvoiceId
			FROM OPENXML(@idoc, 'vyuIPGetInvoiceDetails/vyuIPGetInvoiceDetail', 2) WITH (
					strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
					,intContractHeaderId INT
					,intContractDetailId INT
					,dblQtyOrdered NUMERIC(18, 6)
					,dblQtyShipped NUMERIC(18, 6)
					,strUnitMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS
					,dblPrice NUMERIC(18, 6)
					,dblTotal NUMERIC(18, 6)
					,dblShipmentNetWt NUMERIC(18, 6)
					,dblItemWeight NUMERIC(18, 6)
					,strWeightUnitMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS
					,intInvoiceId INT
					)

			SELECT @intInvoiceDetailId = min(intInvoiceDetailId)
			FROM @tblIPInvoiceDetail

			WHILE @intInvoiceDetailId IS NOT NULL
			BEGIN
				SELECT @strItemNo = NULL
					,@strUnitMeasure = NULL
					,@strWeightUnitMeasure = NULL
					,@intContractDetailRefId = NULL
					,@strErrorMessage = ''

				SELECT @strItemNo = strItemNo
					,@strUnitMeasure = strUnitMeasure
					,@strWeightUnitMeasure = strWeightUnitMeasure
					,@intContractDetailRefId = intContractDetailId
				FROM @tblIPInvoiceDetail
				WHERE intInvoiceDetailId = @intInvoiceDetailId

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

				SELECT @intUnitMeasureId = NULL

				SELECT @intUnitMeasureId = intUnitMeasureId
				FROM tblICUnitMeasure
				WHERE strUnitMeasure = @strUnitMeasure

				IF @strUnitMeasure IS NOT NULL
					AND @intUnitMeasureId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Unit Measure ' + @strUnitMeasure + ' is not available.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Unit Measure ' + @strUnitMeasure + ' is not available.'
					END
				END

				SELECT @intItemUOMId = NULL

				SELECT @intItemUOMId = intItemUOMId
				FROM tblICItemUOM
				WHERE intItemId = @intItemId
					AND intUnitMeasureId = @intUnitMeasureId

				IF @strUnitMeasure IS NOT NULL
					AND @intItemUOMId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Unit Measure ' + @strUnitMeasure + ' is not associated for the item ' + @strItemNo + '.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Unit Measure ' + @strUnitMeasure + ' is not associated for the item ' + @strItemNo + '.'
					END
				END

				SELECT @intWeightUnitMeasureId = NULL

				SELECT @intWeightUnitMeasureId = intUnitMeasureId
				FROM tblICUnitMeasure
				WHERE strUnitMeasure = @strWeightUnitMeasure

				IF @strWeightUnitMeasure IS NOT NULL
					AND @intWeightUnitMeasureId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Weight Unit Measure ' + @strWeightUnitMeasure + ' is not available.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Weight Unit Measure ' + @strWeightUnitMeasure + ' is not available.'
					END
				END

				SELECT @intWeightItemUOMId = NULL

				SELECT @intWeightItemUOMId = intItemUOMId
				FROM tblICItemUOM
				WHERE intItemId = @intItemId
					AND intUnitMeasureId = @intWeightUnitMeasureId

				IF @strUnitMeasure IS NOT NULL
					AND @intItemUOMId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Weight Unit Measure ' + @strUnitMeasure + ' is not associated for the item ' + @strItemNo + '.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Weight Unit Measure ' + @strUnitMeasure + ' is not associated for the item ' + @strItemNo + '.'
					END
				END

				SELECT @intContractDetailId = NULL
					,@intContractHeaderId = NULL

				SELECT @intContractDetailId = intContractDetailId
					,@intContractHeaderId = intContractHeaderId
				FROM tblCTContractDetail
				WHERE intContractDetailRefId = @intContractDetailRefId

				IF @intContractDetailId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Contract is not available.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Contract is not available.'
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

				INSERT INTO @tblIPFinalInvoiceDetail (
					intItemId
					,intContractHeaderId
					,intContractDetailId
					,dblQtyOrdered
					,dblQtyShipped
					,intUnitMeasureId
					,dblPrice
					,dblTotal
					,dblShipmentNetWt
					,dblItemWeight
					,intWeightUnitMeasureId
					,intInvoiceId
					)
				SELECT @intItemId
					,@intContractHeaderId
					,@intContractDetailId
					,dblQtyOrdered
					,dblQtyShipped
					,@intItemUOMId
					,dblPrice
					,dblTotal
					,dblShipmentNetWt
					,dblItemWeight
					,@intWeightItemUOMId
					,intInvoiceId
				FROM @tblIPInvoiceDetail
				WHERE intInvoiceDetailId = @intInvoiceDetailId

				SELECT @intInvoiceDetailId = min(intInvoiceDetailId)
				FROM @tblIPInvoiceDetail
				WHERE intInvoiceDetailId > @intInvoiceDetailId
			END

			SELECT @intBillId = intBillId
			FROM tblAPBill
			WHERE intInvoiceRefId = @intInvoiceId

			SELECT @type = CASE 
					WHEN @strTransactionType = 'Invoice'
						THEN 1
					ELSE 3
					END
			Delete from @voucherNonInvDetails
			INSERT INTO @voucherNonInvDetails (
				intEntityVendorId
				,intTransactionType
				,intShipToId
				--,intEntityId
				,intItemId
				,intContractHeaderId
				,intContractDetailId
				,dblOrderQty
				,intOrderUOMId
				,dblQuantityToBill
				,intQtyToBillUOMId
				,dblCost
				--,dblTotal
				,dblNetWeight
				,dblWeight
				,intWeightUOMId
				,strVendorOrderNumber
				,intBillId
				,ysnStage
				)
			SELECT @intEntityId
				,1
				,@intLocationId
				--,@intUserId
				,intItemId
				,intContractHeaderId
				,intContractDetailId
				,dblQtyOrdered
				,intUnitMeasureId
				,dblQtyShipped
				,intUnitMeasureId
				,dblPrice
				--,dblTotal
				,dblShipmentNetWt
				,dblItemWeight
				,intWeightUnitMeasureId
				,@strInvoiceNumber
				,@intBillId,0
			FROM @tblIPFinalInvoiceDetail

			EXEC uspAPCreateVoucher @voucherPayables = @voucherNonInvDetails
				,@userId = @intUserId
				,@throwError = 1
				,@createdVouchersId = @intBillInvoiceId OUT

			UPDATE tblAPBill
			SET intBookId = @intBookId
				,intSubBookId = @intSubBookId
				,intEntityId = @intEntityId
				,intInvoiceRefId = @intInvoiceId
				,intTransactionType =CASE 
					WHEN @strTransactionType = 'Invoice'
						THEN 1
					ELSE 3
					END
			WHERE intBillId = @intBillInvoiceId

			--UPDATE tblAPBillDetail
			--SET dblQtyOrdered = 0
			--	,intLocationId = @intCompanyLocationId
			--	,strMiscDescription = @strMiscComment
			--WHERE intBillId = @intBillInvoiceId
			ext:

			EXEC sp_xml_removedocument @idoc

			UPDATE tblARInvoiceStage
			SET strFeedStatus = 'Processed'
			WHERE intInvoiceStageId = @intInvoiceStageId

			SELECT @intVoucherScreenId = intScreenId
			FROM tblSMScreen
			WHERE strNamespace = 'AccountsPayable.view.Voucher'

			SELECT @intTransactionRefId = intTransactionId
			FROM tblSMTransaction
			WHERE intRecordId = @intBillInvoiceId
				AND intScreenId = @intVoucherScreenId

			--EXECUTE dbo.uspSMInterCompanyUpdateMapping @currentTransactionId = @intTransactionRefId
			--	,@referenceTransactionId = @intTransactionId
			--	,@referenceCompanyId = @intCompanyId
			--INSERT INTO tblMFDemandAcknowledgementStage (
			--	intInvPlngReportMasterId
			--	,strInvPlngReportName
			--	,intInvPlngReportMasterRefId
			--	,strMessage
			--	,intTransactionId
			--	,intCompanyId
			--	,intTransactionRefId
			--	,intCompanyRefId
			--	)
			--SELECT @intNewInvPlngReportMasterID
			--	,@strInvPlngReportName
			--	,@intInvPlngReportMasterID
			--	,'Success'
			--	,@intTransactionId
			--	,@intCompanyId
			--	,@intTransactionRefId
			--	,@intCompanyRefId
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

			UPDATE tblARInvoiceStage
			SET strFeedStatus = 'Failed'
				,strMessage = @ErrMsg
			WHERE intInvoiceStageId = @intInvoiceStageId
		END CATCH

		SELECT @intInvoiceStageId = MIN(intInvoiceStageId)
		FROM tblARInvoiceStage
		WHERE intInvoiceStageId > @intInvoiceStageId
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
