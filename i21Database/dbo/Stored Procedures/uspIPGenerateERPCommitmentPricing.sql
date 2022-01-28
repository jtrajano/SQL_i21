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
	DECLARE @intCommitmentPricingStageId INT
		,@intCommitmentPricingId INT
		,@intActionId INT
		,@ysnPost BIT
		,@strPricingNumber NVARCHAR(50)
		,@strCustomerPrefix NVARCHAR(100)
		,@dtmDeliveryFrom DATETIME
		,@dtmDeliveryTo DATETIME
		,@strUnitMeasure NVARCHAR(50)
		,@strCurrency NVARCHAR(40)
		,@dtmPricingDate DATETIME
		,@strComment NVARCHAR(MAX)
		,@dblMarketArbitrage NUMERIC(18, 6)
		,@dblCalculatedArbitrage NUMERIC(18, 6)
		,@dblCalculatedFutures NUMERIC(18, 6)
		,@dblCalculatedFXPrice NUMERIC(18, 6)
		,@dblCalculatedRefPrice NUMERIC(18, 6)
		,@strERPRefNo NVARCHAR(100)
	DECLARE @intCommitmentPricingDetailStageId INT
		,@intDetailActionId INT
		,@intLineType INT
		,@strContractNo NVARCHAR(50)
		,@strCommodityOrderNo NVARCHAR(50)
		,@intSequenceNo INT
		,@strActualBlend NVARCHAR(50)
		,@strERPRecipeNo NVARCHAR(50)
		,@dblTotalCostPR NUMERIC(18, 6)
		,@strDetailRowState NVARCHAR(100)
	DECLARE @intPrevCommitmentPricingStageId INT
	DECLARE @tblMFCommitmentPricingStage TABLE (intCommitmentPricingStageId INT)
	DECLARE @tblMFCommitmentPricingDetailStage TABLE (intCommitmentPricingDetailStageId INT)
	DECLARE @tblOutput AS TABLE (
		intRowNo INT IDENTITY(1, 1)
		,intCommitmentPricingStageId INT
		,strRowState NVARCHAR(50)
		,strXML NVARCHAR(MAX)
		,strPricingNumber NVARCHAR(50)
		,strERPRefNo NVARCHAR(100)
		)

	IF NOT EXISTS (
			SELECT 1
			FROM tblMFCommitmentPricingStage
			WHERE intStatusId IS NULL
			)
	BEGIN
		RETURN
	END

	DELETE
	FROM @tblMFCommitmentPricingStage

	INSERT INTO @tblMFCommitmentPricingStage (intCommitmentPricingStageId)
	SELECT TOP 50 CPS.intCommitmentPricingStageId
	FROM tblMFCommitmentPricingStage CPS
	JOIN tblMFCommitmentPricing CP ON CP.intCommitmentPricingId = CPS.intCommitmentPricingId
		AND CPS.intStatusId IS NULL
	JOIN tblARCustomer C ON C.intEntityId = CP.intEntityId
		AND ISNULL(C.strLinkCustomerNumber, '') = @strCompanyLocation

	SELECT @intCommitmentPricingStageId = MIN(intCommitmentPricingStageId)
	FROM @tblMFCommitmentPricingStage

	IF @intCommitmentPricingStageId IS NULL
	BEGIN
		RETURN
	END

	WHILE @intCommitmentPricingStageId IS NOT NULL
	BEGIN
		SELECT @strRowState = NULL
			,@strUserName = NULL
			,@strError = ''
			,@intUserId = NULL

		SELECT @intActionId = NULL
			,@intCommitmentPricingId = NULL
			,@ysnPost = NULL
			,@strPricingNumber = NULL
			,@strCustomerPrefix = NULL
			,@dtmDeliveryFrom = NULL
			,@dtmDeliveryTo = NULL
			,@strUnitMeasure = NULL
			,@strCurrency = NULL
			,@dtmPricingDate = NULL
			,@strComment = NULL
			,@dblMarketArbitrage = NULL
			,@dblCalculatedArbitrage = NULL
			,@dblCalculatedFutures = NULL
			,@dblCalculatedFXPrice = NULL
			,@dblCalculatedRefPrice = NULL
			,@strERPRefNo = NULL

		SELECT @intCommitmentPricingDetailStageId = NULL
			,@strDetailXML = ''

		SELECT @intPrevCommitmentPricingStageId = NULL

		SELECT @intCommitmentPricingId = intCommitmentPricingId
			,@intUserId = intUserId
			,@ysnPost = ysnPost
		FROM tblMFCommitmentPricingStage
		WHERE intCommitmentPricingStageId = @intCommitmentPricingStageId

		IF @ysnPost = 1
		BEGIN
			SELECT @strRowState = 'Posted'
				,@intActionId = 1

			IF EXISTS (
					SELECT 1
					FROM tblMFCommitmentPricingStage
					WHERE intCommitmentPricingId = @intCommitmentPricingId
						AND intCommitmentPricingStageId < @intCommitmentPricingStageId
					)
			BEGIN
				SELECT @strRowState = 'Reposted'
					,@intActionId = 2
			END
		END
		ELSE
		BEGIN
			SELECT @strRowState = 'Unposted'
				,@intActionId = 3
		END

		SELECT @strUserName = US.strUserName
			,@strPricingNumber = CP.strPricingNumber
			,@strCustomerPrefix = E.strExternalERPId
			,@dtmDeliveryFrom = CP.dtmDeliveryFrom
			,@dtmDeliveryTo = CP.dtmDeliveryTo
			,@strUnitMeasure = UOM.strUnitMeasure
			,@strCurrency = CUR.strCurrency
			,@dtmPricingDate = CP.dtmDate
			,@strComment = CP.strComment
			,@dblMarketArbitrage = CONVERT(NUMERIC(18, 6), CP.dblMarketArbitrage)
			,@dblCalculatedArbitrage = CONVERT(NUMERIC(18, 6), CP.dblCalculatedArbitrage)
			,@dblCalculatedFutures = CONVERT(NUMERIC(18, 6), CP.dblCalculatedFutures)
			,@dblCalculatedFXPrice = CONVERT(NUMERIC(18, 6), CP.dblCalculatedFXPrice)
			,@dblCalculatedRefPrice = CONVERT(NUMERIC(18, 6), CP.dblCalculatedRefPrice)
			,@strERPRefNo = CP.strERPNo
		FROM dbo.tblMFCommitmentPricing CP
		JOIN dbo.tblSMUserSecurity US ON US.intEntityId = @intUserId
		JOIN dbo.tblEMEntity E ON E.intEntityId = CP.intEntityId
		JOIN dbo.tblARCustomer C ON C.intEntityId = E.intEntityId
		LEFT JOIN dbo.tblICUnitMeasure UOM ON UOM.intUnitMeasureId = CP.intUnitMeasureId
		LEFT JOIN dbo.tblSMCurrency CUR ON CUR.intCurrencyID = CP.intCurrencyId
		WHERE CP.intCommitmentPricingId = @intCommitmentPricingId

		IF ISNULL(@strCustomerPrefix, '') = ''
		BEGIN
			SELECT @strError = @strError + 'Customer Prefix cannot be blank. '
		END

		IF @dtmDeliveryFrom IS NULL
		BEGIN
			SELECT @strError = @strError + 'Delivery From cannot be blank. '
		END

		IF @dtmDeliveryTo IS NULL
		BEGIN
			SELECT @strError = @strError + 'Delivery To cannot be blank. '
		END

		IF ISNULL(@strUnitMeasure, '') = ''
		BEGIN
			SELECT @strError = @strError + 'UOM cannot be blank. '
		END

		IF ISNULL(@strCurrency, '') = ''
		BEGIN
			SELECT @strError = @strError + 'Currency cannot be blank. '
		END

		IF @dtmPricingDate IS NULL
		BEGIN
			SELECT @strError = @strError + 'Pricing Date cannot be blank. '
		END

		IF ISNULL(@dblCalculatedFutures, 0) = 0
		BEGIN
			SELECT @strError = @strError + 'Futures Price should be greater than 0. '
		END

		IF @strCompanyLocation = '10'
		BEGIN
			IF ISNULL(@dblCalculatedFXPrice, 0) = 0
			BEGIN
				SELECT @strError = @strError + 'FX Price should be greater than 0. '
			END
		END

		IF ISNULL(@dblCalculatedRefPrice, 0) = 0
		BEGIN
			SELECT @strError = @strError + 'Reference Price should be greater than 0. '
		END

		IF @strError <> ''
		BEGIN
			UPDATE tblMFCommitmentPricingStage
			SET strMessage = @strError
				,intStatusId = 1
			WHERE intCommitmentPricingStageId = @intCommitmentPricingStageId

			GOTO NextRec
		END

		-- If previous feed is waiting for acknowledgement then do not send the current feed
		IF EXISTS (
				SELECT TOP 1 1
				FROM tblMFCommitmentPricingStage CPS
				JOIN tblMFCommitmentPricing CP ON CP.intCommitmentPricingId = CPS.intCommitmentPricingId
					AND CP.intCommitmentPricingId = @intCommitmentPricingId
				JOIN tblARCustomer C ON C.intEntityId = CP.intEntityId
						AND ISNULL(C.strLinkCustomerNumber, '') = @strCompanyLocation
					AND CPS.intCommitmentPricingStageId < @intCommitmentPricingStageId
					AND CPS.intStatusId = 2
				ORDER BY CPS.intCommitmentPricingStageId DESC
				)
		BEGIN
			UPDATE tblMFCommitmentPricingStage
			SET strMessage = 'Previous feed is waiting for acknowledgement. '
			WHERE intCommitmentPricingStageId = @intCommitmentPricingStageId

			GOTO NextRec
		END

		IF @intActionId <> 1
		BEGIN
			IF ISNULL(@strERPRefNo, '') = ''
			BEGIN
				SELECT @strError = @strError + 'ERP Reference No. cannot be blank. '

				UPDATE tblMFCommitmentPricingStage
				SET strMessage = @strError
					,intStatusId = 1
				WHERE intCommitmentPricingStageId = @intCommitmentPricingStageId

				GOTO NextRec
			END
		END

		SELECT @strXML = ''

		SELECT @strXML += '<header id="' + LTRIM(@intCommitmentPricingStageId) + '">'

		SELECT @strXML += '<TrxSequenceNo>' + LTRIM(@intCommitmentPricingStageId) + '</TrxSequenceNo>'

		SELECT @strXML += '<CompanyLocation>' + LTRIM(@strCompanyLocation) + '</CompanyLocation>'

		SELECT @strXML += '<ActionId>' + LTRIM(@intActionId) + '</ActionId>'

		SELECT @strXML += '<CreatedDate>' + CONVERT(VARCHAR(33), GetDate(), 126) + '</CreatedDate>'

		SELECT @strXML += '<CreatedByUser>' + @strUserName + '</CreatedByUser>'

		SELECT @strXML += '<PricingNo>' + ISNULL(@strPricingNumber, '') + '</PricingNo>'

		SELECT @strXML += '<CustomerPrefix>' + ISNULL(@strCustomerPrefix, '') + '</CustomerPrefix>'

		SELECT @strXML += '<DeliveryFrom>' + ISNULL(CONVERT(VARCHAR, @dtmDeliveryFrom, 112), '') + '</DeliveryFrom>'

		SELECT @strXML += '<DeliveryTo>' + ISNULL(CONVERT(VARCHAR, @dtmDeliveryTo, 112), '') + '</DeliveryTo>'

		SELECT @strXML += '<UOM>' + ISNULL(@strUnitMeasure, '') + '</UOM>'

		SELECT @strXML += '<Currency>' + ISNULL(@strCurrency, '') + '</Currency>'

		SELECT @strXML += '<PricingDate>' + ISNULL(CONVERT(VARCHAR, @dtmPricingDate, 112), '') + '</PricingDate>'

		SELECT @strXML += '<Comments>' + dbo.fnEscapeXML(ISNULL(@strComment, '')) + '</Comments>'

		SELECT @strXML += '<MarketArb>' + LTRIM(ISNULL(@dblMarketArbitrage, 0)) + '</MarketArb>'

		SELECT @strXML += '<Arbitrage>' + LTRIM(ISNULL(@dblCalculatedArbitrage, 0)) + '</Arbitrage>'

		SELECT @strXML += '<FuturesPrice>' + LTRIM(ISNULL(@dblCalculatedFutures, 0)) + '</FuturesPrice>'

		SELECT @strXML += '<FXPrice>' + LTRIM(ISNULL(@dblCalculatedFXPrice, 0)) + '</FXPrice>'

		SELECT @strXML += '<RefPrice>' + LTRIM(ISNULL(@dblCalculatedRefPrice, 0)) + '</RefPrice>'

		SELECT @strXML += '<ERPRefNo>' + ISNULL(@strERPRefNo, '') + '</ERPRefNo>'

		DELETE
		FROM tblMFCommitmentPricingDetailStage
		WHERE intCommitmentPricingStageId = @intCommitmentPricingStageId

		INSERT INTO tblMFCommitmentPricingDetailStage (
			intCommitmentPricingStageId
			,intCommitmentPricingId
			,intActionId
			,intLineType
			,strContractNo
			,strCommodityOrderNo
			,intSequenceNo
			,strRowState
			)
		SELECT @intCommitmentPricingStageId
			,@intCommitmentPricingId
			,(
				CASE 
					WHEN CPS.intConcurrencyId = 1
						THEN 1
					ELSE 2
					END
				)
			,1
			,CH.strContractNumber
			,CD.strERPPONumber
			,CPS.intSequenceNo
			,(
				CASE 
					WHEN CPS.intConcurrencyId = 1
						THEN 'Added'
					ELSE 'Modified'
					END
				)
		FROM tblMFCommitmentPricingSales CPS
		JOIN tblCTContractDetail CD ON CD.intContractDetailId = CPS.intContractDetailId
		JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		WHERE CPS.intCommitmentPricingId = @intCommitmentPricingId

		INSERT INTO tblMFCommitmentPricingDetailStage (
			intCommitmentPricingStageId
			,intCommitmentPricingId
			,intActionId
			,intLineType
			,strActualBlend
			,strERPRecipeNo
			,dblTotalCostPR
			,strRowState
			)
		SELECT @intCommitmentPricingStageId
			,@intCommitmentPricingId
			,(
				CASE 
					WHEN CPR.intConcurrencyId = 1
						THEN 1
					ELSE 2
					END
				)
			,2
			,AI.strItemNo
			,AR.strERPRecipeNo
			,CPR.dblVirtualTotalCost
			,(
				CASE 
					WHEN CPR.intConcurrencyId = 1
						THEN 'Added'
					ELSE 'Modified'
					END
				)
		FROM tblMFCommitmentPricingRecipe CPR
		JOIN tblMFRecipe AR ON AR.intRecipeId = CPR.intActualRecipeId
		JOIN tblMFRecipeItem ARI ON ARI.intRecipeItemId = CPR.intActualRecipeItemId
			AND ARI.intRecipeItemTypeId = 2
		JOIN tblICItem AI ON AI.intItemId = ARI.intItemId
		WHERE CPR.intCommitmentPricingId = @intCommitmentPricingId

		-- Repost - Compare and add deleted records for both Sales Contract and Recipe
		IF @intActionId = 2 -- Repost
		BEGIN
			SELECT @intPrevCommitmentPricingStageId = MAX(intCommitmentPricingStageId)
			FROM tblMFCommitmentPricingStage
			WHERE intCommitmentPricingId = @intCommitmentPricingId
				AND intCommitmentPricingStageId < @intCommitmentPricingStageId
				AND ysnPost = 1

			--INSERT INTO tblMFCommitmentPricingDetailStage (
			--	intCommitmentPricingStageId
			--	,intCommitmentPricingId
			--	,intActionId
			--	,intLineType
			--	,strContractNo
			--	,strCommodityOrderNo
			--	,intSequenceNo
			--	,strRowState
			--	)
			--SELECT @intCommitmentPricingStageId
			--	,@intCommitmentPricingId
			--	,4
			--	,1
			--	,CPDS.strContractNo
			--	,CPDS.strCommodityOrderNo
			--	,CPDS.intSequenceNo
			--	,'Delete'
			--FROM tblMFCommitmentPricingDetailStage CPDS
			--WHERE CPDS.intCommitmentPricingStageId = @intPrevCommitmentPricingStageId
			--	AND CPDS.intLineType = 1
			--	AND NOT EXISTS (
			--		SELECT 1
			--		FROM tblMFCommitmentPricingSales CPS
			--		JOIN tblCTContractDetail CD ON CD.intContractDetailId = CPS.intContractDetailId
			--			AND CPS.intCommitmentPricingId = @intCommitmentPricingId
			--		JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
			--		WHERE CH.strContractNumber = CPDS.strContractNo
			--		)

			INSERT INTO tblMFCommitmentPricingDetailStage (
				intCommitmentPricingStageId
				,intCommitmentPricingId
				,intActionId
				,intLineType
				,strActualBlend
				,strERPRecipeNo
				,dblTotalCostPR
				,strRowState
				)
			SELECT @intCommitmentPricingStageId
				,@intCommitmentPricingId
				,4
				,2
				,CPDS.strActualBlend
				,CPDS.strERPRecipeNo
				,CPDS.dblTotalCostPR
				,'Delete'
			FROM tblMFCommitmentPricingDetailStage CPDS
			WHERE CPDS.intCommitmentPricingStageId = @intPrevCommitmentPricingStageId
				AND CPDS.intLineType = 2
				AND NOT EXISTS (
					SELECT 1
					FROM tblMFCommitmentPricingRecipe CPR
					JOIN tblMFRecipe AR ON AR.intRecipeId = CPR.intActualRecipeId
						AND CPR.intCommitmentPricingId = @intCommitmentPricingId
					JOIN tblMFRecipeItem ARI ON ARI.intRecipeItemId = CPR.intActualRecipeItemId
						AND ARI.intRecipeItemTypeId = 2
					JOIN tblICItem AI ON AI.intItemId = ARI.intItemId
					WHERE AI.strItemNo = CPDS.strActualBlend
					)
		END

		DELETE
		FROM @tblMFCommitmentPricingDetailStage

		INSERT INTO @tblMFCommitmentPricingDetailStage (intCommitmentPricingDetailStageId)
		SELECT CPDS.intCommitmentPricingDetailStageId
		FROM tblMFCommitmentPricingDetailStage CPDS
		WHERE CPDS.intCommitmentPricingStageId = @intCommitmentPricingStageId

		SELECT @intCommitmentPricingDetailStageId = MIN(intCommitmentPricingDetailStageId)
		FROM @tblMFCommitmentPricingDetailStage

		IF @intCommitmentPricingDetailStageId IS NULL
		BEGIN
			UPDATE tblMFCommitmentPricingStage
			SET strMessage = 'Pricing Detail not available. '
				,intStatusId = 1
			WHERE intCommitmentPricingStageId = @intCommitmentPricingStageId

			GOTO NextRec
		END

		WHILE @intCommitmentPricingDetailStageId IS NOT NULL
		BEGIN
			SELECT @strQuantityUOM = NULL
				,@strDefaultCurrency = NULL
				,@intCurrencyId = NULL
				,@intUnitMeasureId = NULL
				,@intItemId = NULL
				,@intItemUOMId = NULL

			SELECT @intDetailActionId = NULL
				,@intLineType = NULL
				,@strContractNo = NULL
				,@strCommodityOrderNo = NULL
				,@intSequenceNo = NULL
				,@strActualBlend = NULL
				,@strERPRecipeNo = NULL
				,@dblTotalCostPR = NULL
				,@strDetailRowState = NULL

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

			--SELECT @intUnitMeasureId = IUOM.intUnitMeasureId
			--	,@intItemUOMId = IUOM.intItemUOMId
			--FROM tblICUnitMeasure UOM
			--JOIN tblICItemUOM IUOM ON IUOM.intUnitMeasureId = UOM.intUnitMeasureId
			--	AND IUOM.intItemId = @intItemId
			--	AND UOM.strUnitMeasure = @strQuantityUOM
			--IF @intUnitMeasureId IS NULL
			--BEGIN
			--	SELECT TOP 1 @intItemUOMId = IUOM.intItemUOMId
			--		,@intUnitMeasureId = IUOM.intUnitMeasureId
			--		,@strQuantityUOM = UOM.strUnitMeasure
			--	FROM dbo.tblICItemUOM IUOM
			--	JOIN dbo.tblICUnitMeasure UOM ON UOM.intUnitMeasureId = IUOM.intUnitMeasureId
			--		AND IUOM.intItemId = @intItemId
			--		AND IUOM.ysnStockUnit = 1
			--END
			SELECT @intDetailActionId = CPDS.intActionId
				,@intLineType = CPDS.intLineType
				,@strContractNo = CPDS.strContractNo
				,@strCommodityOrderNo = CPDS.strCommodityOrderNo
				,@intSequenceNo = CPDS.intSequenceNo
				,@strActualBlend = CPDS.strActualBlend
				,@strERPRecipeNo = CPDS.strERPRecipeNo
				,@dblTotalCostPR = CONVERT(NUMERIC(18, 6), CPDS.dblTotalCostPR)
				,@strDetailRowState = CPDS.strRowState
			FROM tblMFCommitmentPricingDetailStage CPDS
			WHERE intCommitmentPricingDetailStageId = @intCommitmentPricingDetailStageId

			IF ISNULL(@intLineType, 0) = 1
			BEGIN
				IF ISNULL(@strContractNo, '') = ''
				BEGIN
					SELECT @strError = @strError + 'Sales Contract No cannot be blank. '
				END

				IF ISNULL(@strCommodityOrderNo, '') = ''
				BEGIN
					SELECT @strError = @strError + 'AX Commodity Order No cannot be blank. '
				END

				IF ISNULL(@intSequenceNo, 0) = 0
				BEGIN
					SELECT @strError = @strError + 'Sequence Number cannot be blank. '
				END
			END
			ELSE IF ISNULL(@intLineType, 0) = 2
			BEGIN
				IF ISNULL(@strActualBlend, '') = ''
				BEGIN
					SELECT @strError = @strError + 'Actual Blend Item No cannot be blank. '
				END

				IF ISNULL(@strERPRecipeNo, '') = ''
				BEGIN
					SELECT @strError = @strError + 'Actual Blend Item - ERP Recipe No cannot be blank. '
				END

				IF ISNULL(@dblTotalCostPR, 0) = 0
				BEGIN
					SELECT @strError = @strError + 'Total Cost - PR should be greater than 0. '
				END
			END
			ELSE
			BEGIN
				SELECT @strError = @strError + 'Invalid Line Type. '
			END

			IF @strError <> ''
			BEGIN
				UPDATE tblMFCommitmentPricingStage
				SET strMessage = @strError
					,intStatusId = 1
				WHERE intCommitmentPricingStageId = @intCommitmentPricingStageId

				GOTO NextRec
			END

			IF @intActionId = 1 -- Post
			BEGIN
				SELECT @intDetailActionId = 1
			END
			ELSE IF @intActionId = 3 -- UnPost
			BEGIN
				SELECT @intDetailActionId = 2
			END
			ELSE IF @intActionId = 2 -- Repost
			BEGIN
				IF @strDetailRowState = 'Delete'
					SELECT @intDetailActionId = 4
			END

			SELECT @strItemXML = ''

			SELECT @strItemXML += '<line id="' + LTRIM(@intCommitmentPricingDetailStageId) + '" parentId="' + LTRIM(@intCommitmentPricingStageId) + '">'

			SELECT @strItemXML += '<TrxSequenceNo>' + LTRIM(@intCommitmentPricingDetailStageId) + '</TrxSequenceNo>'

			SELECT @strItemXML += '<ActionId>' + LTRIM(@intDetailActionId) + '</ActionId>'

			SELECT @strItemXML += '<LineType>' + LTRIM(@intLineType) + '</LineType>'

			IF @intLineType = 1
			BEGIN
				SELECT @strItemXML += '<ContractNo>' + ISNULL(@strContractNo, '') + '</ContractNo>'

				SELECT @strItemXML += '<CommodityOrderNo>' + ISNULL(@strCommodityOrderNo, '') + '</CommodityOrderNo>'

				SELECT @strItemXML += '<SequenceNumber>' + LTRIM(ISNULL(@intSequenceNo, 0)) + '</SequenceNumber>'
			END
			ELSE IF @intLineType = 2
			BEGIN
				SELECT @strItemXML += '<ActualBlend>' + ISNULL(@strActualBlend, '') + '</ActualBlend>'

				SELECT @strItemXML += '<ERPRecipeNo>' + ISNULL(@strERPRecipeNo, '') + '</ERPRecipeNo>'

				SELECT @strItemXML += '<TotalCostPR>' + LTRIM(ISNULL(@dblTotalCostPR, 0)) + '</TotalCostPR>'
			END

			SELECT @strItemXML += '</line>'

			IF ISNULL(@strItemXML, '') = ''
			BEGIN
				UPDATE tblMFCommitmentPricingStage
				SET strMessage = 'Detail XML not available. '
					,intStatusId = 1
				WHERE intCommitmentPricingStageId = @intCommitmentPricingStageId

				GOTO NextRec
			END

			SELECT @strDetailXML = @strDetailXML + @strItemXML

			SELECT @intCommitmentPricingDetailStageId = MIN(intCommitmentPricingDetailStageId)
			FROM @tblMFCommitmentPricingDetailStage
			WHERE intCommitmentPricingDetailStageId > @intCommitmentPricingDetailStageId
		END

		SELECT @strFinalXML = @strFinalXML + @strXML + @strDetailXML + '</header>'

		IF @ysnUpdateFeedStatus = 1
		BEGIN
			UPDATE tblMFCommitmentPricingStage
			SET strMessage = NULL
				,intStatusId = 2
			WHERE intCommitmentPricingStageId = @intCommitmentPricingStageId
		END

		NextRec:

		SELECT @intCommitmentPricingStageId = MIN(intCommitmentPricingStageId)
		FROM @tblMFCommitmentPricingStage
		WHERE intCommitmentPricingStageId > @intCommitmentPricingStageId
	END

	IF @strFinalXML <> ''
	BEGIN
		SELECT @strFinalXML = '<root><data>' + @strFinalXML + '</data></root>'

		DELETE
		FROM @tblOutput

		INSERT INTO @tblOutput (
			intCommitmentPricingStageId
			,strRowState
			,strXML
			,strPricingNumber
			,strERPRefNo
			)
		VALUES (
			@intCommitmentPricingStageId
			,'CREATE'
			,@strFinalXML
			,ISNULL(@strPricingNumber, '')
			,ISNULL(@strERPRefNo, '')
			)
	END

	SELECT IsNULL(intCommitmentPricingStageId, '0') AS id
		,IsNULL(strXML, '') AS strXml
		,IsNULL(strPricingNumber, '') AS strInfo1
		,IsNULL(strERPRefNo, '') AS strInfo2
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
