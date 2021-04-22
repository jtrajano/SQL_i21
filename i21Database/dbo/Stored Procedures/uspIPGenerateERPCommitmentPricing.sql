CREATE PROCEDURE dbo.uspIPGenerateERPCommitmentPricing (
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
	DECLARE @intCommitmentPricingId INT
	
	DECLARE @intBillPreStageId INT
		,@intBillId INT
		,@intActionId INT
		,@intTransactionType INT
		,@strBillId NVARCHAR(50)

	DECLARE @intBillDetailId INT

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

	WHILE @intBillPreStageId IS NOT NULL
	BEGIN
		SELECT @strRowState = NULL
			,@strUserName = NULL
			,@strError = ''
			,@intUserId = NULL

		SELECT @intActionId = NULL
			,@intTransactionType = NULL
			,@strBillId = NULL


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
					)
				SELECT @intActionId = 2
		END
		ELSE IF @strRowState = 'Unposted'
		BEGIN
			SELECT @intActionId = 3
		END

		SELECT CP.strPricingNumber
			,E.strExternalERPId
			,CP.dtmDeliveryFrom
			,CP.dtmDeliveryTo
			,UOM.strUnitMeasure
			,CUR.strCurrency
			,CP.dtmDate
			,CP.strComment
			,CP.dblMarketArbitrage
			,CP.dblCalculatedArbitrage
			,CP.dblCalculatedFutures
			,CP.dblCalculatedFXPrice
			,CP.dblCalculatedRefPrice
			,CP.strERPNo
		FROM dbo.tblMFCommitmentPricing CP
		JOIN tblEMEntity E ON E.intEntityId = CP.intEntityId
		JOIN tblARCustomer C ON C.intEntityId = E.intEntityId
		JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = CP.intUnitMeasureId
		JOIN dbo.tblSMCurrency CUR ON CUR.intCurrencyID = CP.intCurrencyId
		WHERE CP.intCommitmentPricingId = @intCommitmentPricingId

		SELECT (CASE WHEN CPS.intConcurrencyId = 1 THEN 1 ELSE 2 END)
			,1
			,CH.strContractNumber
			,CD.strERPPONumber
			,CPS.intSequenceNo
		FROM tblMFCommitmentPricingSales CPS
		JOIN tblCTContractDetail CD ON CD.intContractDetailId = CPS.intContractDetailId
		JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		WHERE CPS.intCommitmentPricingId = @intCommitmentPricingId

		SELECT (CASE WHEN CPR.intConcurrencyId = 1 THEN 1 ELSE 2 END)
			,2
			,AI.strItemNo
			,AR.strERPRecipeNo
			,CPR.dblVirtualTotalCost
		FROM tblMFCommitmentPricingRecipe CPR
		JOIN tblMFRecipe AR ON AR.intRecipeId = CPR.intActualRecipeId
		JOIN tblMFRecipeItem ARI ON ARI.intRecipeItemId = CPR.intActualRecipeItemId
			AND ARI.intRecipeItemTypeId = 2
		JOIN tblICItem AI ON AI.intItemId = ARI.intItemId
		WHERE CPR.intCommitmentPricingId = @intCommitmentPricingId

		--IF @dtmDueDate IS NULL
		--BEGIN
		--	SELECT @strError = @strError + 'Due Date cannot be blank. '
		--END

		--IF ISNULL(@dblTotal, 0) = 0
		--BEGIN
		--	SELECT @strError = @strError + 'Voucher Total should be greater than 0. '
		--END

		--IF ISNULL(@strRemarks, '') = ''
		--BEGIN
		--	SELECT @strError = @strError + 'Remarks cannot be blank. '
		--END

		IF @strError <> ''
		BEGIN
			UPDATE tblAPBillPreStage
			SET strMessage = @strError
				,intStatusId = 1
			WHERE intBillPreStageId = @intBillPreStageId

			GOTO NextRec
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


		--IF @intActionId <> 1
		--	SELECT @strXML += '<ERPVoucherNo>' + ISNULL(@strERPVoucherNo, '') + '</ERPVoucherNo>'

		DELETE
		FROM @tblAPBillDetail

		INSERT INTO @tblAPBillDetail (intBillDetailId)
		SELECT BD.intBillDetailId
		FROM tblAPBillDetail BD
		WHERE BD.intBillId = @intBillId

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

			--SELECT @strContractNumber = NULL


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

			--SELECT @strContractNumber = CH.strContractNumber
			--	,@strSequenceNo = LTRIM(CD.intContractSeq)
			--	,@strERPPONumber = CD.strERPPONumber
			--	,@strERPItemNumber = CD.strERPItemNumber
			--	,@strItemNo = I.strItemNo
			--	,@dblDetailQuantity = CONVERT(NUMERIC(18, 6), ISNULL(dbo.fnCTConvertQtyToTargetItemUOM(BD.intUnitOfMeasureId, @intItemUOMId, BD.dblQtyReceived), 0))
			--	,@strDetailCurrency = C.strCurrency
			--	,@dblDetailCost = CONVERT(NUMERIC(18, 6), ISNULL(dbo.fnCTConvertQtyToTargetItemUOM(BD.intCostUOMId, @intItemUOMId, BD.dblCost), 0))
			--	,@dblDetailDiscount = CONVERT(NUMERIC(18, 6), BD.dblDiscount)
			--	,@dblDetailTotal = CONVERT(NUMERIC(18, 6), BD.dblTotal)
			--	,@dblDetailTax = CONVERT(NUMERIC(18, 6), BD.dblTax)
			--FROM tblAPBillDetail BD
			--JOIN tblICItem I ON I.intItemId = BD.intItemId
			--JOIN dbo.tblSMCurrency C ON C.intCurrencyID = BD.intCurrencyId
			--LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = BD.intContractHeaderId
			--LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = BD.intContractDetailId
			--WHERE BD.intBillDetailId = @intBillDetailId

			--SELECT @dblDetailTotalwithTax = @dblDetailTotal + @dblDetailTax

			--SELECT TOP 1 @strWorkOrderNo = W.strWorkOrderNo
			--	,@strERPOrderNo = W.strERPOrderNo
			--	,@strERPServicePONumber = W.strERPServicePONumber
			--	,@strERPServicePOLineNo = WMD.strERPServicePOLineNo
			--FROM tblAPBillDetail BD
			--JOIN tblMFWorkOrderWarehouseRateMatrixDetail WMD ON WMD.intBillId = BD.intBillId
			--	AND WMD.intBillId = @intBillId
			--JOIN tblMFWorkOrder W ON W.intWorkOrderId = WMD.intWorkOrderId
			--JOIN tblLGWarehouseRateMatrixDetail MD ON MD.intWarehouseRateMatrixDetailId = WMD.intWarehouseRateMatrixDetailId
			--WHERE BD.intBillDetailId = @intBillDetailId


			--IF ISNULL(@dblDetailTotalwithTax, 0) = 0
			--BEGIN
			--	SELECT @strError = @strError + 'Detail - Total with Tax should be greater than 0. '
			--END

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

			--SELECT @strItemXML += '<ContractNo>' + ISNULL(@strContractNumber, '') + '</ContractNo>'

		

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
			,''--,ISNULL(@strERPVoucherNo, '')
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
