CREATE PROCEDURE dbo.uspIPGenerateERPVoucher (
	@strCompanyLocation NVARCHAR(6) = NULL
	,@ysnUpdateFeedStatus BIT = 1
	)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
		,@strRowState NVARCHAR(50)
		,@strUserName NVARCHAR(50)
		,@strError NVARCHAR(MAX) = ''
		,@strFinalXML NVARCHAR(MAX) = ''
		,@strXML NVARCHAR(MAX) = ''
		,@strItemXML NVARCHAR(MAX) = ''
		,@strDetailXML NVARCHAR(MAX) = ''
		,@intUserId INT
	DECLARE @strQuantityUOM NVARCHAR(50)
		,@strDefaultCurrency NVARCHAR(40)
		,@intCurrencyId INT
		,@intUnitMeasureId INT
		,@intItemId INT
		,@intItemUOMId INT
	DECLARE @intBillPreStageId INT
		,@intBillId INT
		,@intActionId INT
		,@intTransactionType INT
		,@intOrgTransactionType INT
		,@strBillId NVARCHAR(50)
		,@dtmDate DATETIME
		,@strVendorAccountNum NVARCHAR(50)
		,@strBook NVARCHAR(50)
		,@strInvoiceNo NVARCHAR(50)
		,@dtmInvoiceDate DATETIME
		,@strTermCode NVARCHAR(50)
		,@dtmDueDate DATETIME
		,@strReference NVARCHAR(200)
		,@strCurrency NVARCHAR(40)
		,@dblDiscount NUMERIC(18, 6)
		,@dblTax NUMERIC(18, 6)
		,@dblTotal NUMERIC(18, 6)
		,@strRemarks NVARCHAR(200)
		,@strERPVoucherNo NVARCHAR(50)
	DECLARE @intBillDetailId INT
		,@strContractNumber NVARCHAR(50)
		,@strSequenceNo NVARCHAR(3)
		,@strERPPONumber NVARCHAR(100)
		,@strERPItemNumber NVARCHAR(100)
		,@strWorkOrderNo NVARCHAR(50)
		,@strERPOrderNo NVARCHAR(50)
		,@strERPServicePONumber NVARCHAR(50)
		,@strERPServicePOLineNo NVARCHAR(50)
		,@strItemNo NVARCHAR(50)
		,@strMapItemNo NVARCHAR(50)
		,@dblDetailQuantity NUMERIC(18, 6)
		,@strDetailCurrency NVARCHAR(40)
		,@dblDetailCost NUMERIC(18, 6)
		,@dblDetailDiscount NUMERIC(18, 6)
		,@dblDetailTotal NUMERIC(18, 6)
		,@dblDetailTax NUMERIC(18, 6)
		,@dblDetailTotalwithTax NUMERIC(18, 6)
		,@intContractDetailId INT
		,@strType NVARCHAR(50)
		,@strReceiptNumber NVARCHAR(50)
		,@intWeightAdjItemId int
		,@dblCostAdjustment NUMERIC(18, 6)
		,@intNoOfItem INT
		,@intLocationId int
	DECLARE @tblAPBillPreStage TABLE (intBillPreStageId INT)
	DECLARE @tblAPBillDetail TABLE (intBillDetailId INT)
	DECLARE @tblOutput AS TABLE (
		intRowNo INT IDENTITY(1, 1)
		,intBillId INT
		,strRowState NVARCHAR(50)
		,strXML NVARCHAR(MAX)
		,strBillId NVARCHAR(50)
		,strERPVoucherNo NVARCHAR(50)
		)

	IF NOT EXISTS (
			SELECT 1
			FROM tblAPBillPreStage
			WHERE intStatusId IS NULL
			)
	BEGIN
		RETURN
	END

	DELETE
	FROM @tblAPBillPreStage

	INSERT INTO @tblAPBillPreStage (intBillPreStageId)
	SELECT TOP 50 BPS.intBillPreStageId
	FROM tblAPBillPreStage BPS
	JOIN tblAPBill B ON B.intBillId = BPS.intBillId
		AND B.intTransactionType IN (
			1
			,3
			,11
			)
	JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = B.intStoreLocationId
		AND CL.strLotOrigin = @strCompanyLocation
	WHERE BPS.intStatusId IS NULL

	SELECT @intBillPreStageId = MIN(intBillPreStageId)
	FROM @tblAPBillPreStage

	IF @intBillPreStageId IS NULL
	BEGIN
		RETURN
	END

	SELECT @intWeightAdjItemId = intWeightAdjItemId
	FROM tblIPCompanyPreference

	IF @intWeightAdjItemId IS NULL
	BEGIN
		SELECT @intWeightAdjItemId = 0
	END

	WHILE @intBillPreStageId IS NOT NULL
	BEGIN
		SELECT @strRowState = NULL
			,@strUserName = NULL
			,@strError = ''
			,@intUserId = NULL

		SELECT @intActionId = NULL
			,@intTransactionType = NULL
			,@intOrgTransactionType = NULL
			,@strBillId = NULL
			,@dtmDate = NULL
			,@strVendorAccountNum = NULL
			,@strBook = NULL
			,@strInvoiceNo = NULL
			,@dtmInvoiceDate = NULL
			,@strTermCode = NULL
			,@dtmDueDate = NULL
			,@strReference = NULL
			,@strCurrency = NULL
			,@dblDiscount = NULL
			,@dblTax = NULL
			,@dblTotal = NULL
			,@strRemarks = NULL
			,@strERPVoucherNo = NULL
			,@intLocationId=NULL

		SELECT @intBillDetailId = NULL
			,@strDetailXML = ''

		SELECT @intBillId = intBillId
			,@strRowState = strRowState
			,@intUserId = intUserId
		FROM tblAPBillPreStage
		WHERE intBillPreStageId = @intBillPreStageId

		IF @strRowState = 'Posted'
		BEGIN
			SELECT @intActionId = 1

			IF EXISTS (
					SELECT 1
					FROM tblAPBillPreStage
					WHERE intBillId = @intBillId
						AND intBillPreStageId < @intBillPreStageId
						AND strERPVoucherNo IS NOT NULL
					)
				SELECT @intActionId = 2
		END
		ELSE IF @strRowState = 'Unposted'
		BEGIN
			SELECT @intActionId = 3
		END

		SELECT @strUserName = US.strUserName
			,@intOrgTransactionType = A.intTransactionType
			,@intTransactionType = (
				CASE A.intTransactionType
					WHEN 1
						THEN 1
					WHEN 3
						THEN 2
					WHEN 11
						THEN 3
					END
				)
			,@strBillId = A.strBillId
			,@dtmDate = A.dtmDate
			,@strVendorAccountNum = V.strVendorAccountNum
			,@strBook = B.strBook
			,@strInvoiceNo = A.strVendorOrderNumber
			,@dtmInvoiceDate = A.dtmBillDate
			,@strTermCode = T.strTermCode
			,@dtmDueDate = A.dtmDueDate
			,@strReference = A.strReference
			,@strCurrency = C.strCurrency
			,@dblDiscount = CONVERT(NUMERIC(18, 6), A.dblDiscount)
			,@dblTax = CONVERT(NUMERIC(18, 6), A.dblTax)
			,@dblTotal = CONVERT(NUMERIC(18, 6), A.dblTotal)
			,@strRemarks = A.strRemarks
			,@intLocationId=A.intStoreLocationId 
		FROM dbo.tblAPBill A
		JOIN dbo.tblSMUserSecurity US ON US.intEntityId = ISNULL(@intUserId, A.intEntityId)
		LEFT JOIN dbo.tblAPVendor V ON V.intEntityId = A.intEntityVendorId
		LEFT JOIN dbo.tblCTBook B ON B.intBookId = A.intBookId
		LEFT JOIN dbo.tblSMTerm T ON T.intTermID = A.intTermsId
		LEFT JOIN dbo.tblSMCurrency C ON C.intCurrencyID = A.intCurrencyId
		WHERE A.intBillId = @intBillId

		IF ISNULL(@intTransactionType, 0) = 0
		BEGIN
			SELECT @strError = @strError + 'Invalid Voucher Type. '
		END

		IF ISNULL(@strVendorAccountNum, '') = ''
		BEGIN
			SELECT @strError = @strError + 'Vendor Account Number cannot be blank. '
		END

		IF ISNULL(@strBook, '') = ''
		BEGIN
			SELECT @strError = @strError + 'Book cannot be blank. '
		END

		IF ISNULL(@strInvoiceNo, '') = ''
		BEGIN
			--SELECT @strError = @strError + 'Invoice No. cannot be blank. '
			SELECT @strInvoiceNo = @strBillId
		END

		IF @dtmInvoiceDate IS NULL
		BEGIN
			SELECT @strError = @strError + 'Invoice Date cannot be blank. '
		END

		IF ISNULL(@strTermCode, '') = ''
		BEGIN
			SELECT @strError = @strError + 'Terms cannot be blank. '
		END

		IF @dtmDueDate IS NULL
		BEGIN
			SELECT @strError = @strError + 'Due Date cannot be blank. '
		END

		IF ISNULL(@strCurrency, '') = ''
		BEGIN
			SELECT @strError = @strError + 'Currency cannot be blank. '
		END

		IF ISNULL(@dblTotal, 0) = 0
		BEGIN
			SELECT @strError = @strError + 'Voucher Total should be greater than 0. '
		END

		IF @strError <> ''
		BEGIN
			UPDATE tblAPBillPreStage
			SET strMessage = @strError
				,intStatusId = 1
			WHERE intBillPreStageId = @intBillPreStageId

			GOTO NextRec
		END

		-- If previous feed is waiting for acknowledgement then do not send the current feed
		IF EXISTS (
				SELECT TOP 1 1
				FROM tblAPBillPreStage BPS
				JOIN tblAPBill B ON B.intBillId = BPS.intBillId
					AND B.intBillId = @intBillId
					AND BPS.intBillPreStageId < @intBillPreStageId
					AND BPS.intStatusId = 2
				ORDER BY BPS.intBillPreStageId DESC
				)
		BEGIN
			UPDATE tblAPBillPreStage
			SET strMessage = 'Previous feed is waiting for acknowledgement. '
			WHERE intBillPreStageId = @intBillPreStageId

			GOTO NextRec
		END

		IF @intActionId <> 1
		BEGIN
			SELECT @strERPVoucherNo = strERPVoucherNo
			FROM dbo.tblAPBillPreStage
			WHERE intBillId = @intBillId
				AND intBillPreStageId < @intBillPreStageId

			IF ISNULL(@strERPVoucherNo, '') = ''
			BEGIN
				SELECT @strError = @strError + 'ERP Voucher No. cannot be blank. '
				
				UPDATE tblAPBillPreStage
				SET strMessage = @strError
					,intStatusId = 1
				WHERE intBillPreStageId = @intBillPreStageId

				GOTO NextRec
			END
		END

		SELECT @strXML = ''

		SELECT @strXML += '<header id="' + LTRIM(@intBillPreStageId) + '">'

		SELECT @strXML += '<TrxSequenceNo>' + LTRIM(@intBillPreStageId) + '</TrxSequenceNo>'

		SELECT @strXML += '<CompanyLocation>' + LTRIM(@strCompanyLocation) + '</CompanyLocation>'

		SELECT @strXML += '<ActionId>' + LTRIM(@intActionId) + '</ActionId>'

		SELECT @strXML += '<CreatedDate>' + CONVERT(VARCHAR(33), GetDate(), 126) + '</CreatedDate>'

		SELECT @strXML += '<CreatedByUser>' + @strUserName + '</CreatedByUser>'

		SELECT @strXML += '<VoucherTypeId>' + LTRIM(@intTransactionType) + '</VoucherTypeId>'

		SELECT @strXML += '<VoucherNo>' + ISNULL(@strBillId, '') + '</VoucherNo>'

		SELECT @strXML += '<VoucherDate>' + ISNULL(CONVERT(VARCHAR, @dtmDate, 112), '') + '</VoucherDate>'

		SELECT @strXML += '<VendorAccountNo>' + ISNULL(@strVendorAccountNum, '') + '</VendorAccountNo>'

		SELECT @strXML += '<Book>' + ISNULL(@strBook, '') + '</Book>'

		SELECT @strXML += '<InvoiceNo>' + ISNULL(@strInvoiceNo, '') + '</InvoiceNo>'

		SELECT @strXML += '<InvoiceDate>' + ISNULL(CONVERT(VARCHAR, @dtmInvoiceDate, 112), '') + '</InvoiceDate>'

		SELECT @strXML += '<TermCode>' + ISNULL(@strTermCode, '') + '</TermCode>'

		SELECT @strXML += '<DueDate>' + ISNULL(CONVERT(VARCHAR, @dtmDueDate, 112), '') + '</DueDate>'

		SELECT @strXML += '<ReferenceNo>' + ISNULL(@strReference, '') + '</ReferenceNo>'

		SELECT @strXML += '<Currency>' + ISNULL(@strCurrency, '') + '</Currency>'

		SELECT @strXML += '<TotalDiscount>' + LTRIM(ISNULL(@dblDiscount, 0)) + '</TotalDiscount>'

		SELECT @strXML += '<TotalTax>' + LTRIM(ISNULL(@dblTax, 0)) + '</TotalTax>'

		SELECT @strXML += '<VoucherTotal>' + LTRIM(ISNULL(@dblTotal, 0)) + '</VoucherTotal>'

		SELECT @strXML += '<Remarks>' + ISNULL(@strRemarks, '') + '</Remarks>'

		SELECT @strXML += '<ERPVoucherNo>' + ISNULL(@strERPVoucherNo, '') + '</ERPVoucherNo>'

		DELETE
		FROM @tblAPBillDetail

		INSERT INTO @tblAPBillDetail (intBillDetailId)
		SELECT BD.intBillDetailId
		FROM tblAPBillDetail BD
		WHERE BD.intBillId = @intBillId
		AND intItemId <> @intWeightAdjItemId


		SELECT @intBillDetailId = MIN(intBillDetailId)
		FROM @tblAPBillDetail

		WHILE @intBillDetailId IS NOT NULL
		BEGIN
			SELECT @strQuantityUOM = NULL
				,@strDefaultCurrency = NULL
				,@intCurrencyId = NULL
				,@intUnitMeasureId = NULL
				,@intItemId = NULL
				,@intItemUOMId = NULL

			SELECT @strContractNumber = NULL
				,@strSequenceNo = NULL
				,@strERPPONumber = NULL
				,@strERPItemNumber = NULL
				,@strWorkOrderNo = NULL
				,@strERPOrderNo = NULL
				,@strERPServicePONumber = NULL
				,@strERPServicePOLineNo = NULL
				,@strItemNo = NULL
				,@strMapItemNo = NULL
				,@dblDetailQuantity = NULL
				,@strDetailCurrency = NULL
				,@dblDetailCost = NULL
				,@dblDetailDiscount = NULL
				,@dblDetailTotal = NULL
				,@dblDetailTax = NULL
				,@dblDetailTotalwithTax = NULL
				,@intContractDetailId = NULL
				,@strType = NULL
				,@strReceiptNumber = NULL

			SELECT @intItemId = BD.intItemId
			FROM dbo.tblAPBillDetail BD
			WHERE BD.intBillDetailId = @intBillDetailId

			SELECT @strQuantityUOM = strQuantityUOM
				,@strDefaultCurrency = strDefaultCurrency
			FROM tblIPCompanyPreference

			SELECT @intCurrencyId = intCurrencyID
			FROM tblSMCurrency
			WHERE strCurrency = @strDefaultCurrency

			IF @intCurrencyId IS NULL
			BEGIN
				SELECT TOP 1 @intCurrencyId = intCurrencyID
					,@strDefaultCurrency = strCurrency
				FROM tblSMCurrency
				WHERE strCurrency LIKE '%USD%'
			END

			SELECT @intUnitMeasureId = IUOM.intUnitMeasureId
				,@intItemUOMId = IUOM.intItemUOMId
			FROM tblICUnitMeasure UOM
			JOIN tblICItemUOM IUOM ON IUOM.intUnitMeasureId = UOM.intUnitMeasureId
				AND IUOM.intItemId = @intItemId
				AND UOM.strUnitMeasure = @strQuantityUOM

			IF @intUnitMeasureId IS NULL
			BEGIN
				SELECT TOP 1 @intItemUOMId = IUOM.intItemUOMId
					,@intUnitMeasureId = IUOM.intUnitMeasureId
					,@strQuantityUOM = UOM.strUnitMeasure
				FROM dbo.tblICItemUOM IUOM
				JOIN dbo.tblICUnitMeasure UOM ON UOM.intUnitMeasureId = IUOM.intUnitMeasureId
					AND IUOM.intItemId = @intItemId
					AND IUOM.ysnStockUnit = 1
			END

			SELECT @strContractNumber = CH.strContractNumber
				,@strSequenceNo = LTRIM(CD.intContractSeq)
				,@strERPPONumber = CD.strERPPONumber
				,@strERPItemNumber = CD.strERPItemNumber
				,@strItemNo = I.strItemNo
				,@dblDetailQuantity = CONVERT(NUMERIC(18, 6), ISNULL(dbo.fnCTConvertQtyToTargetItemUOM(BD.intWeightUOMId, @intItemUOMId, BD.dblNetWeight), 0))
				,@strDetailCurrency = C.strCurrency
				,@dblDetailCost = (
					CASE 
						WHEN I.strType = 'Other Charge'
							THEN CONVERT(NUMERIC(18, 6), ISNULL(BD.dblCost, 0))
						ELSE CONVERT(NUMERIC(18, 6), ISNULL(dbo.fnCTConvertQtyToTargetItemUOM(BD.intCostUOMId, @intItemUOMId, BD.dblCost), 0))
						END
					)
				,@dblDetailDiscount = CONVERT(NUMERIC(18, 6), BD.dblDiscount)
				,@dblDetailTotal = CONVERT(NUMERIC(18, 6), BD.dblTotal)
				,@dblDetailTax = CONVERT(NUMERIC(18, 6), BD.dblTax)
				,@intContractDetailId = BD.intContractDetailId
				,@strType = I.strType
			FROM tblAPBillDetail BD
			JOIN tblICItem I ON I.intItemId = BD.intItemId
			JOIN dbo.tblSMCurrency C ON C.intCurrencyID = BD.intCurrencyId
			LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = BD.intContractHeaderId
			LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = BD.intContractDetailId
			WHERE BD.intBillDetailId = @intBillDetailId

			IF EXISTS (
				SELECT *
				FROM tblAPBillDetail
				WHERE intBillId = @intBillId
					AND intItemId = @intWeightAdjItemId
			)
			BEGIN
				SELECT @dblCostAdjustment = NULL

				SELECT @dblCostAdjustment = dblCost*dblQtyReceived 
				FROM tblAPBillDetail
				WHERE intBillId = @intBillId
					AND intItemId = @intWeightAdjItemId

				SELECT @intNoOfItem = NULL

				SELECT @intNoOfItem = Count(*)
				FROM tblAPBillDetail
				WHERE intBillId = @intBillId
					AND intInventoryReceiptItemId IS NOT NULL

				IF @intNoOfItem IS NULL
					SELECT @intNoOfItem = 1

				SELECT @dblDetailTotal = @dblDetailTotal + (@dblCostAdjustment / @intNoOfItem)

				SELECT @dblDetailQuantity = @dblDetailTotal / @dblDetailCost
			END


			SELECT @dblDetailTotalwithTax = @dblDetailTotal + @dblDetailTax

			IF @intTransactionType = 3 -- Claim
			BEGIN
				SELECT @strReceiptNumber = R.strReceiptNumber
				FROM tblAPBillDetail BD
				JOIN tblLGWeightClaimDetail WCD ON WCD.intWeightClaimDetailId = BD.intWeightClaimDetailId
					AND BD.intContractDetailId IS NOT NULL
					AND BD.intBillDetailId = @intBillDetailId
				JOIN tblICInventoryReceiptItem RI ON RI.intContainerId = WCD.intLoadContainerId
				JOIN tblICInventoryReceipt R ON RI.intInventoryReceiptId = R.intInventoryReceiptId
			END
			ELSE
			BEGIN
				SELECT @strReceiptNumber = R.strReceiptNumber
				FROM tblAPBillDetail BD
				JOIN tblICInventoryReceiptItem RI ON RI.intInventoryReceiptItemId = BD.intInventoryReceiptItemId
					AND BD.intContractDetailId IS NOT NULL
					AND BD.intBillDetailId = @intBillDetailId
				JOIN tblICInventoryReceipt R ON R.intInventoryReceiptId = RI.intInventoryReceiptId
			END

			IF ISNULL(@strType, '') = 'Other Charge'
				AND @intContractDetailId IS NULL
			BEGIN
				SELECT TOP 1 @intContractDetailId = BD.intContractDetailId
				FROM tblAPBillDetail BD
				WHERE BD.intBillId = @intBillId
					AND BD.intContractDetailId IS NOT NULL

				IF @intContractDetailId IS NOT NULL
				BEGIN
					SELECT @strContractNumber = CH.strContractNumber
						,@strSequenceNo = LTRIM(CD.intContractSeq)
						,@strERPPONumber = CD.strERPPONumber
						,@strERPItemNumber = CD.strERPItemNumber
					FROM tblCTContractDetail CD
					JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
					WHERE CD.intContractDetailId = @intContractDetailId
				END
			END

			SELECT TOP 1 @strWorkOrderNo = W.strWorkOrderNo
				,@strERPOrderNo = W.strERPOrderNo
				,@strERPServicePONumber = W.strERPServicePONumber
				,@strERPServicePOLineNo = WMD.strERPServicePOLineNo
			FROM tblAPBillDetail BD
			JOIN tblMFWorkOrderWarehouseRateMatrixDetail WMD ON WMD.intBillId = BD.intBillId
				AND WMD.intBillId = @intBillId
			JOIN tblMFWorkOrder W ON W.intWorkOrderId = WMD.intWorkOrderId
			JOIN tblLGWarehouseRateMatrixDetail MD ON MD.intWarehouseRateMatrixDetailId = WMD.intWarehouseRateMatrixDetailId
			--AND MD.intItemId = BD.intItemId
			WHERE BD.intBillDetailId = @intBillDetailId

			IF @intOrgTransactionType <> 1 and ISNULL(@strType, '') <> 'Other Charge'
			BEGIN
				SELECT TOP 1 @strMapItemNo = I.strItemNo
				FROM tblIPBillItem BI
				JOIN tblICItem I ON I.intItemId = BI.intItemId
				WHERE BI.intTransactionType = @intOrgTransactionType
				AND BI.intLocationId =@intLocationId 

				IF ISNULL(@strMapItemNo, '') <> ''
					SELECT @strItemNo = @strMapItemNo
			END
			
			IF ISNULL(@strItemNo, '') = ''
			BEGIN
				SELECT @strError = @strError + 'Item No cannot be blank. '
			END

			IF ISNULL(@strType, '') <> 'Other Charge'
			BEGIN
				IF ISNULL(@dblDetailQuantity, 0) = 0
				BEGIN
					SELECT @strError = @strError + 'Detail - Quantity should be greater than 0. '
				END
			END

			IF ISNULL(@strDetailCurrency, '') = ''
			BEGIN
				SELECT @strError = @strError + 'Detail - Currency cannot be blank. '
			END

			IF ISNULL(@dblDetailCost, 0) = 0
			BEGIN
				SELECT @strError = @strError + 'Detail - Cost should be greater than 0. '
			END

			IF ISNULL(@dblDetailTotal, 0) = 0
			BEGIN
				SELECT @strError = @strError + 'Detail - Total should be greater than 0. '
			END

			IF ISNULL(@dblDetailTotalwithTax, 0) = 0
			BEGIN
				SELECT @strError = @strError + 'Detail - Total with Tax should be greater than 0. '
			END

			IF @strError <> ''
			BEGIN
				UPDATE tblAPBillPreStage
				SET strMessage = @strError
					,intStatusId = 1
				WHERE intBillPreStageId = @intBillPreStageId

				GOTO NextRec
			END

			SELECT @strItemXML = ''

			SELECT @strItemXML += '<line id="' + LTRIM(@intBillDetailId) + '" parentId="' + LTRIM(@intBillPreStageId) + '">'

			SELECT @strItemXML += '<TrxSequenceNo>' + LTRIM(@intBillDetailId) + '</TrxSequenceNo>'

			SELECT @strItemXML += '<ContractNo>' + ISNULL(@strContractNumber, '') + '</ContractNo>'

			SELECT @strItemXML += '<SequenceNo>' + ISNULL(@strSequenceNo, '') + '</SequenceNo>'

			SELECT @strItemXML += '<ERPPONumber>' + ISNULL(@strERPPONumber, '') + '</ERPPONumber>'

			SELECT @strItemXML += '<ERPPOlineNo>' + ISNULL(@strERPItemNumber, '') + '</ERPPOlineNo>'

			SELECT @strItemXML += '<WorkOrderNo>' + ISNULL(@strWorkOrderNo, '') + '</WorkOrderNo>'

			SELECT @strItemXML += '<ERPShopOrderNo>' + ISNULL(@strERPOrderNo, '') + '</ERPShopOrderNo>'

			SELECT @strItemXML += '<ERPServicePONumber>' + ISNULL(@strERPServicePONumber, '') + '</ERPServicePONumber>'

			SELECT @strItemXML += '<ERPServicePOlineNo>' + ISNULL(@strERPServicePOLineNo, '') + '</ERPServicePOlineNo>'

			SELECT @strItemXML += '<ItemNo>' + ISNULL(@strItemNo, '') + '</ItemNo>'

			SELECT @strItemXML += '<Quantity>' + LTRIM(ISNULL(@dblDetailQuantity, 0)) + '</Quantity>'

			SELECT @strItemXML += '<QuantityUOM>' + ISNULL(@strQuantityUOM, '') + '</QuantityUOM>'

			SELECT @strItemXML += '<Currency>' + ISNULL(@strDetailCurrency, '') + '</Currency>'

			SELECT @strItemXML += '<Cost>' + LTRIM(ISNULL(@dblDetailCost, 0)) + '</Cost>'

			SELECT @strItemXML += '<CostUOM>' + ISNULL(@strQuantityUOM, '') + '</CostUOM>'

			SELECT @strItemXML += '<DiscountPerc>' + LTRIM(ISNULL(@dblDetailDiscount, 0)) + '</DiscountPerc>'

			SELECT @strItemXML += '<SubTotal>' + LTRIM(ISNULL(@dblDetailTotal, 0)) + '</SubTotal>'

			SELECT @strItemXML += '<Tax>' + LTRIM(ISNULL(@dblDetailTax, 0)) + '</Tax>'

			SELECT @strItemXML += '<lineTotal>' + LTRIM(ISNULL(@dblDetailTotalwithTax, 0)) + '</lineTotal>'

			SELECT @strItemXML += '<ReceiptNo>' + ISNULL(@strReceiptNumber, '') + '</ReceiptNo>'

			SELECT @strItemXML += '</line>'

			IF ISNULL(@strItemXML, '') = ''
			BEGIN
				UPDATE tblAPBillPreStage
				SET strMessage = 'Detail XML not available. '
					,intStatusId = 1
				WHERE intBillPreStageId = @intBillPreStageId

				GOTO NextRec
			END

			SELECT @strDetailXML = @strDetailXML + @strItemXML

			SELECT @intBillDetailId = MIN(intBillDetailId)
			FROM @tblAPBillDetail
			WHERE intBillDetailId > @intBillDetailId
		END

		SELECT @strFinalXML = @strFinalXML + @strXML + @strDetailXML + '</header>'

		IF @ysnUpdateFeedStatus = 1
		BEGIN
			UPDATE tblAPBillPreStage
			SET strMessage = NULL
				,intStatusId = 2
			WHERE intBillPreStageId = @intBillPreStageId
		END

		NextRec:

		SELECT @intBillPreStageId = MIN(intBillPreStageId)
		FROM @tblAPBillPreStage
		WHERE intBillPreStageId > @intBillPreStageId
	END

	IF @strFinalXML <> ''
	BEGIN
		SELECT @strFinalXML = '<root><data>' + @strFinalXML + '</data></root>'

		DELETE
		FROM @tblOutput

		INSERT INTO @tblOutput (
			intBillId
			,strRowState
			,strXML
			,strBillId
			,strERPVoucherNo
			)
		VALUES (
			@intBillId
			,'CREATE'
			,@strFinalXML
			,ISNULL(@strBillId, '')
			,ISNULL(@strERPVoucherNo, '')
			)
	END

	SELECT IsNULL(intBillId, '0') AS id
		,IsNULL(strXML, '') AS strXml
		,IsNULL(strBillId, '') AS strInfo1
		,IsNULL(strERPVoucherNo, '') AS strInfo2
		,'' AS strOnFailureCallbackSql
	FROM @tblOutput
	ORDER BY intRowNo
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
