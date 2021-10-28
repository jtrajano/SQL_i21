CREATE PROCEDURE [dbo].[uspIPProcessERPVoucher]
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
		,@intTransactionCount INT
		,@strLocationName NVARCHAR(50)
		,@strUnitMeasure NVARCHAR(50)
		,@strBook NVARCHAR(50)
		,@strCreatedBy NVARCHAR(50)
		,@strErrorMessage NVARCHAR(MAX)
		,@intUnitMeasureId INT
		,@intUserId INT
		,@intBookId INT
		,@intLocationId INT
		,@intTransactionId INT
		,@dtmInvoiceDate DATETIME
		,@strInvoiceNumber NVARCHAR(50)
		,@strCurrency NVARCHAR(50)
		,@strComments NVARCHAR(50)
		,@intEntityId INT
		,@strItemNo NVARCHAR(50)
		,@strWeightUnitMeasure NVARCHAR(50)
		,@intItemId INT
		,@intItemUOMId INT
		,@intWeightUnitMeasureId INT
		,@intWeightItemUOMId INT
		,@intContractDetailId INT
		,@intContractHeaderId INT
		,@intInvoiceDetailId INT
		,@voucherNonInvDetails VoucherPayable
		--,@type INT
		,@strDocType NVARCHAR(50) = 'AP Voucher'
		,@intBillInvoiceId INT
		,@intVoucherScreenId INT
		,@intBillId INT
		,@intLoadId INT
		,@strOrderUnitMeasure NVARCHAR(50)
		,@intOrderUnitMeasureId INT
		,@intOrderItemUOMId INT
		,@intItemLocationId INT
		,@intAccountId INT
		,@intWeightClaimId INT
		,@intCurrencyId INT
		,@ysnSubCurrency BIT
		,@strSubCurrency NVARCHAR(50)
		,@strVendorAccountNo NVARCHAR(50)
		,@intBillStageId INT
		,@strVendorName NVARCHAR(50)
		,@ysnInvoiceCredit BIT
		,@strInvoiceNo NVARCHAR(50)
		,@strPaymentTerms NVARCHAR(50)
		,@dtmDueDate DATETIME
		,@strWeightTerms NVARCHAR(50)
		,@strBooks NVARCHAR(50)
		,@strVoucherNumber NVARCHAR(50)
		,@strINCOTerms NVARCHAR(50)
		,@strRemarks NVARCHAR(200)
		,@dblTotalDiscount NUMERIC(18, 6)
		,@dblTotalTax NUMERIC(18, 6)
		,@dblVoucherTotal NUMERIC(18, 6)
		,@strLIBORrate NVARCHAR(50)
		,@dblFinanceChargeAmount NUMERIC(18, 6)
		,@strSalesOrderReference NVARCHAR(50)
		,@dblFreightCharges NUMERIC(18, 6)
		,@strBLNumber NVARCHAR(100)
		,@dblMiscCharges NUMERIC(18, 6)
		,@strMiscChargesDescription NVARCHAR(100)
		,@intStatusId INT
		,@intScreenId INT
		,@strBillId NVARCHAR(50)
		,@isPresent INT = 0
		,@newAttachmentId INT
		,@message NVARCHAR(1000)
		,@dblTotalCost NUMERIC(18, 6)
		,@dblTotal NUMERIC(18, 6)
		,@config AS ApprovalConfigurationType
		,@strFileName NVARCHAR(50)
		,@strVendorInvoiceFilePath NVARCHAR(500)
		,@intFinancingCostItemId INT
		,@intFreightCostItemId INT
		,@intMiscItemId INT
		,@intTermID INT
		,@intInventoryReceiptId INT
		,@intInventoryReceiptItemId INT
		,@dblSubTotal INT
		,@dblLiborAmount NUMERIC(18, 6)
		,@strLiborCheck NVARCHAR(50)
		,@dblLiborMax NUMERIC(18, 6)
		,@strLiborMaxCheck NVARCHAR(50)
		,@intContractEntityId INT
		,@intWeightId INT
		,@ysnPayablesOnShippedWeights BIT
		,@intLoadDetailId INT
		,@dblRMVoucherTotal NUMERIC(18, 6)
		,@strLiborMsg NVARCHAR(MAX)
		,@ysnMailReq BIT
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
		,intLoadId INT
		,intLoadDetailId INT
		,strOrderUnitMeasure NVARCHAR(50)
		,intAccountId INT
		,strCurrency NVARCHAR(50)
		,intInventoryReceiptId INT
		,intInventoryReceiptItemId INT
		)
	DECLARE @tblIPFinalInvoiceDetail TABLE (
		intFinalInvoiceDetailId INT identity(1, 1)
		,intItemId INT
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
		,intLoadId INT
		,intLoadDetailId INT
		,intOrderItemUOMId INT
		,intAccountId INT
		,intCurrencyId INT
		,ysnSubCurrency INT
		,intInventoryReceiptItemId INT
		)
	DECLARE @tblIPBillStage TABLE (intBillStageId INT)

	INSERT INTO @tblIPBillStage (intBillStageId)
	SELECT intBillStageId
	FROM tblIPBillStage
	WHERE intStatusId IS NULL

	SELECT @intBillStageId = MIN(intBillStageId)
	FROM @tblIPBillStage

	IF @intBillStageId IS NULL
	BEGIN
		RETURN
	END

	SELECT @strVendorInvoiceFilePath = strVendorInvoiceFilePath
		,@intFinancingCostItemId = intFinancingCostItemId
		,@intFreightCostItemId = intFreightCostItemId
		,@intMiscItemId = intMiscItemId
	FROM tblIPCompanyPreference

	SELECT @intScreenId = intScreenId
	FROM tblSMScreen
	WHERE strNamespace = 'AccountsPayable.view.Bill'

	UPDATE S
	SET S.intStatusId = - 1
	FROM tblIPBillStage S
	JOIN @tblIPBillStage TS ON TS.intBillStageId = S.intBillStageId

	WHILE @intBillStageId > 0
	BEGIN
		BEGIN TRY
			SELECT @intTransactionCount = @@TRANCOUNT

			IF @intTransactionCount = 0
				BEGIN TRANSACTION

			SELECT @strVendorAccountNo = NULL
				,@strVendorName = NULL
				,@ysnInvoiceCredit = NULL
				,@strInvoiceNo = NULL
				,@dtmInvoiceDate = NULL
				,@strPaymentTerms = NULL
				,@dtmDueDate = NULL
				,@strCurrency = NULL
				,@strWeightTerms = NULL
				,@strINCOTerms = NULL
				,@strRemarks = NULL
				,@dblTotalDiscount = NULL
				,@dblTotalTax = NULL
				,@dblVoucherTotal = NULL
				,@strLIBORrate = NULL
				,@dblFinanceChargeAmount = NULL
				,@strSalesOrderReference = NULL
				,@dblFreightCharges = NULL
				,@strBLNumber = NULL
				,@dblMiscCharges = NULL
				,@strMiscChargesDescription = NULL
				,@strFileName = NULL
				,@strErrorMessage = NULL
				,@dblRMVoucherTotal = 0
				,@strLiborMsg = NULL
				,@ysnMailReq = NULL

			SELECT @strVendorAccountNo = strVendorAccountNo
				,@strVendorName = strVendorName
				,@ysnInvoiceCredit = ysnInvoiceCredit
				,@strInvoiceNo = strInvoiceNo
				,@dtmInvoiceDate = dtmInvoiceDate
				,@strPaymentTerms = strPaymentTerms
				,@dtmDueDate = dtmDueDate
				,@strCurrency = strCurrency
				,@strWeightTerms = strWeightTerms
				,@strINCOTerms = strINCOTerms
				,@strRemarks = strRemarks
				,@dblTotalDiscount = dblTotalDiscount
				,@dblTotalTax = dblTotalTax
				,@dblVoucherTotal = dblVoucherTotal
				,@strLIBORrate = strLIBORrate
				,@dblFinanceChargeAmount = dblFinanceChargeAmount
				,@strSalesOrderReference = strSalesOrderReference
				,@dblFreightCharges = dblFreightCharges
				,@strBLNumber = strBLNumber
				,@dblMiscCharges = dblMiscCharges
				,@strMiscChargesDescription = strMiscChargesDescription
				,@strFileName = strFileName
			FROM tblIPBillStage
			WHERE intBillStageId = @intBillStageId

			SELECT @dblRMVoucherTotal = @dblVoucherTotal - IsNULL(@dblFinanceChargeAmount, 0) - IsNULL(@dblMiscCharges, 0) - IsNULL(@dblFreightCharges, 0)

			SELECT @intTermID = NULL

			SELECT @intTermID = intTermID
			FROM tblSMTerm
			WHERE strTerm = @strPaymentTerms

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

			SELECT @intCurrencyId = NULL

			SELECT @intCurrencyId = intCurrencyID
			FROM tblSMCurrency
			WHERE strCurrency = @strCurrency

			SELECT @strLiborCheck = dbo.[fnIPGetSAPIDOCTagValue]('Voucher', 'Libor Check')

			IF @strLIBORrate IS NOT NULL
				AND @strLIBORrate <> ''
				AND @dblFinanceChargeAmount > 0
				AND @strLiborCheck = '1'
			BEGIN
				SELECT @strLIBORrate = Replace(@strLIBORrate, '%', '')

				IF ISNUMERIC(@strLIBORrate) = 1
				BEGIN
					SELECT @dblLiborAmount = NULL

					SELECT @dblLiborAmount = ((1.75 + @strLIBORrate) * 90 / 300) * (@dblVoucherTotal - @dblFinanceChargeAmount) / 100

					IF @dblLiborAmount <> @dblFinanceChargeAmount
					BEGIN
						SELECT @strLiborMsg = 'Incorrect financial charges ' + ltrim(@dblFinanceChargeAmount)

						SELECT @ysnMailReq = 1
					END
				END
				ELSE
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Unable to process libor rate  ' + @strLIBORrate
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Unable to process libor rate ' + @strLIBORrate
					END
				END
			END

			SELECT @strLiborMaxCheck = dbo.[fnIPGetSAPIDOCTagValue]('Voucher', 'Libor Max Check')

			IF @strLIBORrate IS NOT NULL
				AND @strLIBORrate <> ''
				AND @dblFinanceChargeAmount > 0
				AND @strLiborMaxCheck = '1'
			BEGIN
				SELECT @dblLiborMax = dbo.[fnIPGetSAPIDOCTagValue]('Voucher', 'Libor Max')

				IF @dblFinanceChargeAmount > @dblLiborMax
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Financial charge ' + ltrim(@dblFinanceChargeAmount) + ' is more than maximum charge configured in the system.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Financial charge ' + ltrim(@dblFinanceChargeAmount) + ' is more than maximum charge configured in the system.'
					END
				END
			END

			SELECT @intEntityId = intEntityId
			FROM tblAPVendor
			WHERE strVendorAccountNum = @strVendorAccountNo

			IF @intEntityId IS NULL
			BEGIN
				IF @strErrorMessage <> ''
				BEGIN
					SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Vendor is not available for the vendor account number ' + ltrim(@strVendorAccountNo)
				END
				ELSE
				BEGIN
					SELECT @strErrorMessage = 'Vendor is not available for the vendor account number ' + ltrim(@strVendorAccountNo)
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

			IF EXISTS (
					SELECT *
					FROM tblAPBill
					WHERE strVendorOrderNumber = @strInvoiceNo
						AND intEntityId = @intEntityId
					)
			BEGIN
				UPDATE tblIPBillStage
				SET intStatusId = 2
					,strMessage = @strInvoiceNo + ' is already processed in i21.'
				WHERE intBillStageId = @intBillStageId

				GOTO ext
			END

			SELECT @intUserId = CE.intEntityId
			FROM tblEMEntity CE
			JOIN tblEMEntityType ET1 ON ET1.intEntityId = CE.intEntityId
			WHERE ET1.strType = 'User'
				AND CE.strName = @strCreatedBy

			--AND CE.strEntityNo <> ''
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

			---******************************** Item Detail ********************************************
			SELECT @strErrorMessage = ''

			DELETE
			FROM @tblIPInvoiceDetail

			DELETE
			FROM @tblIPFinalInvoiceDetail

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
				--,intInvoiceId
				,intLoadId
				,intLoadDetailId
				,strOrderUnitMeasure
				,strCurrency
				,intInventoryReceiptId
				,intInventoryReceiptItemId
				)
			SELECT strItemNo
				,intContractHeaderId
				,intContractDetailId
				,dblQuantity
				,dblQuantity
				,strQuantityUOM
				,dblUnitRate
				,dblAmount
				,dblNetWeight
				,dblNetWeight
				,strWeightUOM
				--,intInvoiceId
				,intLoadId
				,intLoadDetailId
				,strQuantityUOM
				,strUnitRateCurrency
				,intInventoryReceiptId
				,intInventoryReceiptItemId
			FROM tblIPBillDetailStage
			WHERE intBillStageId = @intBillStageId
				AND intSeqNo = 1

			SELECT @intInvoiceDetailId = min(intInvoiceDetailId)
			FROM @tblIPInvoiceDetail

			WHILE @intInvoiceDetailId IS NOT NULL
			BEGIN
				SELECT @strItemNo = NULL
					,@strUnitMeasure = NULL
					,@strWeightUnitMeasure = NULL
					,@strErrorMessage = ''
					,@strOrderUnitMeasure = NULL
					,@intItemLocationId = NULL
					,@intAccountId = NULL
					,@strSubCurrency = NULL
					,@dblTotalCost = 0
					,@dblTotal = 0
					,@intContractHeaderId = NULL
					,@intContractDetailId = NULL
					,@intInventoryReceiptId = NULL
					,@intInventoryReceiptItemId = NULL
					,@intLoadDetailId = NULL

				SELECT @strItemNo = strItemNo
					,@strUnitMeasure = strUnitMeasure
					,@strWeightUnitMeasure = strWeightUnitMeasure
					,@strOrderUnitMeasure = strOrderUnitMeasure
					,@strSubCurrency = strCurrency
					,@dblTotal = dblTotal
					,@intContractHeaderId = intContractHeaderId
					,@intContractDetailId = intContractDetailId
					,@intInventoryReceiptId = intInventoryReceiptId
					,@intInventoryReceiptItemId = intInventoryReceiptItemId
					,@intLoadDetailId = intLoadDetailId
				FROM @tblIPInvoiceDetail
				WHERE intInvoiceDetailId = @intInvoiceDetailId

				IF @intContractHeaderId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Contract Number cannot be blank.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Contract Number cannot be blank.'
					END
				END

				IF @intContractDetailId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Contract Sequence cannot be blank.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Contract Sequence cannot be blank.'
					END
				END

				SELECT @intContractEntityId = NULL
					,@intWeightId = NULL
					,@ysnPayablesOnShippedWeights = NULL

				SELECT @intContractEntityId = intEntityId
					,@intWeightId = intWeightId
				FROM tblCTContractHeader
				WHERE intContractHeaderId = @intContractHeaderId

				SELECT @ysnPayablesOnShippedWeights = ysnPayablesOnShippedWeights
				FROM tblCTWeightGrade
				WHERE intWeightGradeId = @intWeightId

				IF @intContractEntityId <> @intEntityId
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Vendor is invalid.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Vendor is invalid.'
					END
				END

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

				SELECT @intOrderUnitMeasureId = NULL

				SELECT @intOrderUnitMeasureId = intUnitMeasureId
				FROM tblICUnitMeasure
				WHERE strUnitMeasure = @strOrderUnitMeasure

				IF @strOrderUnitMeasure IS NOT NULL
					AND @intOrderUnitMeasureId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Order Unit Measure ' + @strWeightUnitMeasure + ' is not available.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Order Unit Measure ' + @strWeightUnitMeasure + ' is not available.'
					END
				END

				SELECT @intOrderItemUOMId = NULL

				SELECT @intOrderItemUOMId = intItemUOMId
				FROM tblICItemUOM
				WHERE intItemId = @intItemId
					AND intUnitMeasureId = @intOrderUnitMeasureId

				IF @strOrderUnitMeasure IS NOT NULL
					AND @intOrderItemUOMId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Order Unit Measure ' + @strUnitMeasure + ' is not associated for the item ' + @strItemNo + '.'
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Order Unit Measure ' + @strUnitMeasure + ' is not associated for the item ' + @strItemNo + '.'
					END
				END

				SELECT @intLocationId = intCompanyLocationId
				FROM tblCTContractDetail
				WHERE intContractDetailId = @intContractDetailId

				IF @intLocationId IS NULL
					SELECT @intLocationId = intCompanyLocationId
					FROM tblSMCompanyLocation

				SELECT @intItemLocationId = intItemLocationId
				FROM tblICItemLocation
				WHERE intItemId = @intItemId
					AND intLocationId = @intLocationId

				SELECT @intAccountId = [dbo].[fnGetItemGLAccount](@intItemId, @intItemLocationId, 'AP Clearing')

				IF @intAccountId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'AP Clearing is not configured for the item ' + @strItemNo
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'AP Clearing is not configured for the item ' + @strItemNo
					END
				END

				IF @intInventoryReceiptItemId IS NULL
				BEGIN
					IF @strErrorMessage <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Unable to find the inventory receipt entry for the invoice no ' + @strInvoiceNo
					END
					ELSE
					BEGIN
						SELECT @strErrorMessage = 'Unable to find the inventory receipt entry for the invoice no ' + @strInvoiceNo
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

				SELECT @ysnSubCurrency = NULL

				SELECT @ysnSubCurrency = ysnSubCurrency
				FROM tblSMCurrency
				WHERE strCurrency = @strSubCurrency

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
					,intLoadId
					,intLoadDetailId
					,intOrderItemUOMId
					,intAccountId
					,intCurrencyId
					,ysnSubCurrency
					,intInventoryReceiptItemId
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
					,intLoadId
					,intLoadDetailId
					,@intOrderItemUOMId
					,@intAccountId
					,@intCurrencyId
					,@ysnSubCurrency
					,@intInventoryReceiptItemId
				FROM @tblIPInvoiceDetail
				WHERE intInvoiceDetailId = @intInvoiceDetailId

				SELECT @intInvoiceDetailId = min(intInvoiceDetailId)
				FROM @tblIPInvoiceDetail
				WHERE intInvoiceDetailId > @intInvoiceDetailId
			END

			DELETE
			FROM @voucherNonInvDetails

			INSERT INTO @voucherNonInvDetails (
				intEntityVendorId
				,intTransactionType
				,intShipToId
				,intItemId
				,intContractHeaderId
				,intContractDetailId
				,dblOrderQty
				,intOrderUOMId
				,dblQuantityToBill
				,intQtyToBillUOMId
				,dblCost
				,dblNetWeight
				,dblWeight
				,intWeightUOMId
				,strVendorOrderNumber
				,dtmVoucherDate
				,intBillId
				,ysnStage
				,intLoadShipmentId
				,intLoadShipmentDetailId
				,intLineNo
				,intAccountId
				,intCurrencyId
				,ysnSubCurrency
				,dtmDueDate
				,intTermId
				,intCostCurrencyId
				,intInventoryReceiptItemId
				,intLocationId
				)
			SELECT @intEntityId
				,1
				,@intLocationId
				,intItemId
				,intContractHeaderId
				,intContractDetailId
				,dblQtyOrdered
				,intOrderItemUOMId
				,dblQtyShipped
				,intUnitMeasureId
				,dblPrice
				,dblShipmentNetWt
				,dblItemWeight
				,intWeightUnitMeasureId
				,@strInvoiceNo
				,@dtmInvoiceDate
				,@intBillId
				,0
				,intLoadId
				,intLoadDetailId
				,intFinalInvoiceDetailId
				,intAccountId
				,intCurrencyId
				,ysnSubCurrency
				,@dtmDueDate
				,@intTermID
				,intCurrencyId
				,intInventoryReceiptItemId
				,@intLocationId
			FROM @tblIPFinalInvoiceDetail FID

			IF @dblFinanceChargeAmount > 0
			BEGIN
				INSERT INTO @voucherNonInvDetails (
					intEntityVendorId
					,intTransactionType
					,intShipToId
					,intItemId
					,intContractHeaderId
					,intContractDetailId
					,dblOrderQty
					,intOrderUOMId
					,dblQuantityToBill
					,intQtyToBillUOMId
					,dblCost
					,dblNetWeight
					,dblWeight
					,intWeightUOMId
					,strVendorOrderNumber
					,dtmVoucherDate
					,intBillId
					,ysnStage
					,intLoadShipmentId
					,intLoadShipmentDetailId
					,intLineNo
					,intAccountId
					,intCurrencyId
					,ysnSubCurrency
					,dtmDueDate
					,intTermId
					,intCostCurrencyId
					,intLocationId
					)
				SELECT @intEntityId
					,1
					,@intLocationId
					,@intFinancingCostItemId
					,NULL AS intContractHeaderId
					,NULL AS intContractDetailId
					,1 AS dblQtyOrdered
					,NULL AS intOrderItemUOMId
					,1 AS dblQtyShipped
					,NULL AS intUnitMeasureId
					,@dblFinanceChargeAmount AS dblPrice
					,0 AS dblShipmentNetWt
					,0 AS dblItemWeight
					,NULL AS intWeightUnitMeasureId
					,@strInvoiceNo
					,@dtmInvoiceDate
					,@intBillId
					,0
					,NULL AS intLoadId
					,NULL AS intLoadDetailId
					,NULL AS intFinalInvoiceDetailId
					,intAccountId
					,intCurrencyId
					,ysnSubCurrency
					,@dtmDueDate
					,@intTermID
					,intCurrencyId
					,@intLocationId
				FROM @tblIPFinalInvoiceDetail FID
			END

			IF @dblFreightCharges > 0
			BEGIN
				INSERT INTO @voucherNonInvDetails (
					intEntityVendorId
					,intTransactionType
					,intShipToId
					,intItemId
					,intContractHeaderId
					,intContractDetailId
					,dblOrderQty
					,intOrderUOMId
					,dblQuantityToBill
					,intQtyToBillUOMId
					,dblCost
					,dblNetWeight
					,dblWeight
					,intWeightUOMId
					,strVendorOrderNumber
					,dtmVoucherDate
					,intBillId
					,ysnStage
					,intLoadShipmentId
					,intLoadShipmentDetailId
					,intLineNo
					,intAccountId
					,intCurrencyId
					,ysnSubCurrency
					,dtmDueDate
					,intTermId
					,intCostCurrencyId
					,intLocationId
					)
				SELECT @intEntityId
					,1
					,@intLocationId
					,@intFreightCostItemId
					,NULL AS intContractHeaderId
					,NULL AS intContractDetailId
					,1 AS dblQtyOrdered
					,NULL AS intOrderItemUOMId
					,1 AS dblQtyShipped
					,NULL AS intUnitMeasureId
					,@dblFreightCharges AS dblPrice
					,0 AS dblShipmentNetWt
					,0 AS dblItemWeight
					,NULL AS intWeightUnitMeasureId
					,@strInvoiceNo
					,@dtmInvoiceDate
					,@intBillId
					,0
					,NULL AS intLoadId
					,NULL AS intLoadDetailId
					,NULL AS intFinalInvoiceDetailId
					,intAccountId
					,intCurrencyId
					,ysnSubCurrency
					,@dtmDueDate
					,@intTermID
					,intCurrencyId
					,@intLocationId
				FROM @tblIPFinalInvoiceDetail FID
			END

			IF @dblMiscCharges > 0
			BEGIN
				INSERT INTO @voucherNonInvDetails (
					intEntityVendorId
					,intTransactionType
					,intShipToId
					,intItemId
					,intContractHeaderId
					,intContractDetailId
					,dblOrderQty
					,intOrderUOMId
					,dblQuantityToBill
					,intQtyToBillUOMId
					,dblCost
					,dblNetWeight
					,dblWeight
					,intWeightUOMId
					,strVendorOrderNumber
					,dtmVoucherDate
					,intBillId
					,ysnStage
					,intLoadShipmentId
					,intLoadShipmentDetailId
					,intLineNo
					,intAccountId
					,intCurrencyId
					,ysnSubCurrency
					,dtmDueDate
					,intTermId
					,intCostCurrencyId
					,intLocationId
					)
				SELECT @intEntityId
					,1
					,@intLocationId
					,@intMiscItemId
					,NULL AS intContractHeaderId
					,NULL AS intContractDetailId
					,1 AS dblQtyOrdered
					,NULL AS intOrderItemUOMId
					,1 AS dblQtyShipped
					,NULL AS intUnitMeasureId
					,@dblMiscCharges AS dblPrice
					,0 AS dblShipmentNetWt
					,0 AS dblItemWeight
					,NULL AS intWeightUnitMeasureId
					,@strInvoiceNo
					,@dtmInvoiceDate
					,@intBillId
					,0
					,NULL AS intLoadId
					,NULL AS intLoadDetailId
					,NULL AS intFinalInvoiceDetailId
					,intAccountId
					,intCurrencyId
					,ysnSubCurrency
					,@dtmDueDate
					,@intTermID
					,intCurrencyId
					,@intLocationId
				FROM @tblIPFinalInvoiceDetail FID
			END

			EXEC uspAPCreateVoucher @voucherPayables = @voucherNonInvDetails
				,@userId = @intUserId
				,@throwError = 1
				,@createdVouchersId = @intBillInvoiceId OUT

			SELECT @strBillId = NULL

			SELECT @strBillId = strBillId
			FROM tblAPBill
			WHERE intBillId = @intBillInvoiceId

			SELECT @intContractHeaderId = intContractHeaderId
			FROM @tblIPFinalInvoiceDetail

			SELECT @intBookId = intBookId
			FROM tblCTContractHeader
			WHERE intContractHeaderId = @intContractHeaderId

			UPDATE tblAPBill
			SET intBookId = @intBookId
				,intEntityId = @intEntityId
				,intTransactionType = 1
				,dtmDueDate = IsNULL(@dtmDueDate, dtmDueDate)
				,intTermsId = IsNULL(@intTermID, intTermsId)
			WHERE intBillId = @intBillInvoiceId

			UPDATE tblAPBillDetail
			SET dblTotal = dblCost
			WHERE intBillId = @intBillInvoiceId
				AND intItemId IN (
					IsNULL(@intMiscItemId, 0)
					,IsNULL(@intFinancingCostItemId, 0)
					,IsNULL(@intFreightCostItemId, 0)
					)

			--UPDATE HEADER TOTAL
			UPDATE A
			SET A.dblTotal = CAST((DetailTotal.dblTotal + DetailTotal.dblTotalTax) AS DECIMAL(18, 2))
				,A.dblTotalController = CAST((DetailTotal.dblTotal + DetailTotal.dblTotalTax) AS DECIMAL(18, 2))
				,A.dblSubtotal = CAST((DetailTotal.dblTotal) AS DECIMAL(18, 2))
				,A.dblAmountDue = CAST((DetailTotal.dblTotal + DetailTotal.dblTotalTax) - A.dblPayment AS DECIMAL(18, 2))
				,A.dblTax = DetailTotal.dblTotalTax
			FROM tblAPBill A
			CROSS APPLY (
				SELECT SUM(dblTax) dblTotalTax
					,SUM(dblTotal) dblTotal
				FROM tblAPBillDetail C
				WHERE C.intBillId = A.intBillId
				) DetailTotal
			WHERE A.intBillId = @intBillInvoiceId

			IF IsNULL(@ysnPayablesOnShippedWeights, 0) = 1
			BEGIN
				SELECT @dblSubTotal = NULL

				SELECT @dblSubTotal = dblAmount
				FROM tblLGLoadDetail
				WHERE intLoadDetailId = @intLoadDetailId
			END
			ELSE
			BEGIN
				SELECT @dblSubTotal = NULL

				SELECT @dblSubTotal = dblSubTotal
				FROM tblICInventoryReceipt
				WHERE intInventoryReceiptId = @intInventoryReceiptId
			END

			IF ABS(IsNULL(@dblSubTotal, 0) - @dblRMVoucherTotal) < 1
			BEGIN
				EXEC uspSMSubmitTransaction @type = 'AccountsPayable.view.Voucher'
					,@recordId = @intBillInvoiceId
					,@transactionNo = @strBillId
					,@transactionEntityId = @intEntityId
					,@currentUserEntityId = @intUserId
					,@amount = 0
					,@approverConfiguration = @config
			END
			ELSE
			BEGIN
				SELECT @intTransactionId = NULL

				SELECT @intVoucherScreenId = intScreenId
				FROM tblSMScreen
				WHERE strNamespace = 'AccountsPayable.view.Voucher'

				SELECT @intTransactionId = intTransactionId
				FROM tblSMTransaction
				WHERE intScreenId = @intVoucherScreenId
					AND intRecordId = @intBillInvoiceId

				UPDATE tblSMTransaction
				SET strApprovalStatus = 'Waiting for Submit'
					,strTransactionNo = @strBillId
					,intEntityId = @intEntityId
					,intConcurrencyId = intConcurrencyId + 1
				WHERE intTransactionId = @intTransactionId

				INSERT INTO tblSMApproval (
					dtmDate
					,dblAmount
					,dtmDueDate
					,intSubmittedById
					,strStatus
					,ysnCurrent
					,intScreenId
					,ysnVisible
					,intOrder
					,intTransactionId
					)
				SELECT GETUTCDATE()
					,0
					,Convert(DATETIME, Convert(CHAR, GETDATE(), 101))
					,@intUserId
					,'Waiting for Submit'
					,1
					,@intVoucherScreenId
					,1
					,1
					,@intTransactionId
			END

			ext:

			UPDATE tblIPBillStage
			SET intStatusId = 1
				,intBillId = @intBillInvoiceId
				,strVoucherNumber = @strBillId
				,ysnMailReq = @ysnMailReq
				,strMessage = CASE 
					WHEN @ysnMailReq = 1
						THEN @strLiborMsg
					ELSE NULL
					END
			WHERE intBillStageId = @intBillStageId
				AND intStatusId = - 1

			IF @intTransactionCount = 0
				COMMIT TRANSACTION
		END TRY

		BEGIN CATCH
			SET @ErrMsg = ERROR_MESSAGE()

			IF XACT_STATE() != 0
				AND @intTransactionCount = 0
				ROLLBACK TRANSACTION

			UPDATE tblIPBillStage
			SET intStatusId = 2
				,strMessage = @ErrMsg
				,ysnMailReq = 1
			WHERE intBillStageId = @intBillStageId
				AND intStatusId = - 1
		END CATCH

		SELECT @intBillStageId = MIN(intBillStageId)
		FROM @tblIPBillStage
		WHERE intBillStageId > @intBillStageId
	END

	UPDATE S
	SET intStatusId = NULL
	FROM tblIPBillStage S
	JOIN @tblIPBillStage TS ON TS.intBillStageId = S.intBillStageId
	WHERE S.intStatusId = - 1
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
