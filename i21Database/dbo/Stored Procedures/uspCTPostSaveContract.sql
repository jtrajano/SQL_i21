CREATE PROCEDURE [dbo].[uspCTPostSaveContract]
	
	@xmlContractDetails 	NVARCHAR(MAX),
	@xmlReassigns			NVARCHAR(MAX)
	
AS

BEGIN TRY

	DECLARE	@ErrMsg			NVARCHAR(MAX),
			@idoc			INT,
			@intUniqueId	INT
	
	----------------------------------------------------------------------------------------------------
	----------  U P D A T E  C O N T R A C T  A N D  P R I C E  F I X A T I O N  D E T A I L  ----------
	--------------------------  S A V E  /  V A L I D A T E  C O N T R A C T  --------------------------
	----------------------------------------------------------------------------------------------------
	IF @xmlContractDetails <> ''
	BEGIN
	
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlContractDetails

		IF OBJECT_ID('tempdb..#ContractDetails') IS NOT NULL  	
			DROP TABLE #ContractDetails

		SELECT  ROW_NUMBER() OVER(ORDER BY contractDetailId) intUniqueId,* 
		INTO	#ContractDetails
		FROM	OPENXML(@idoc,'contractDetails/contractDetail',2)          
		WITH	(contractDetailId INT,contractHeaderId INT,userId INT)

		DECLARE @contractDetails AS ContractDetail,
				@_cdContractDetailIds AS Id

		INSERT INTO @contractDetails
		SELECT * 
		FROM dbo.fnCTGetContractDetail(@_cdContractDetailIds)

		EXEC uspCTProcessContractDetail @contractDetails

		------------------------------------
		----- Save / Validate Contract -----
		------------------------------------
		DECLARE	@_chContractHeaderId		INT,
				@_chUserId					INT

		IF OBJECT_ID('tempdb..#ContractHeaders') IS NOT NULL
			DROP TABLE #ContractHeaders

		SELECT	ROW_NUMBER() OVER(ORDER BY contractHeaderId) intUniqueId, *
		INTO	#ContractHeaders
		FROM	(SELECT DISTINCT contractHeaderId, userId FROM #ContractDetails) tbl
		
		SELECT @intUniqueId = MIN(intUniqueId) FROM #ContractHeaders

		WHILE ISNULL(@intUniqueId,0) > 0
		BEGIN

			SELECT	@_chContractHeaderId	=	contractHeaderId,
					@_chUserId				=	userId
			FROM	#ContractHeaders 
			WHERE	intUniqueId = @intUniqueId

			DECLARE	@_chContractDetailId		INT,
					@_chCashPrice				NUMERIC(18,6),
					@_chPricingTypeId			INT,
					@_chLastModifiedById		INT,
					@_chMultiplePriceFixation	BIT,
					@_chContractNumber			NVARCHAR(100),
					@_chBasis					NUMERIC(18,6),
					@_chOriginalBasis			NUMERIC(18,6),
					@_chNetWeightUOMId			INT,
					@_chNetWeight				NUMERIC(18,6),
					@_chItemUOMId				INT,
					@_chContractStatusId		INT,
					@_chContractScreenId		INT,
					@_chOnceApproved			BIT,
					@_chFeedOnApproval			BIT,
					@_chTransactionId			INT,
					@_chApproverId				INT,
					@_chCompanyLocationId		INT,
					@_chSlice					BIT,
					@_chLotsFixed				NUMERIC(18,6),
					@_chNoOfLots				NUMERIC(18,6),
					@_chHeaderNoOfLots			NUMERIC(18,6),
					@_chPriceFixationId			INT,
					@_chPriceChanged			BIT,
					@_chCorrectNetWeight		NUMERIC(18,6),
					@_chFutures					NUMERIC(18,6),
					@_chAutoEvaluateMonth		BIT,
					@_chConcurrencyId			INT,
					@_chNoOfDays				INT,
					@_chPlannedAvalability		DATETIME,
					@_chFutureMarketId			INT,
					@_chBasisComponent			BIT,
					@_chUnitMeasureId			INT,
					@_chCurrencyId				INT,
					@_chHeaderPricingTypeId		INT,
					@_chProducerId				INT,
					@_chCertificationName		NVARCHAR(MAX),
					@_chCustomerContract		NVARCHAR(100),
					@_chContractTypeId			INT,
					@_chAddToPayableMessage		NVARCHAR(MAX)

			SELECT	@_chMultiplePriceFixation	=	ysnMultiplePriceFixation,
					@_chContractNumber			=	strContractNumber,
					@_chNoOfLots				=	dblNoOfLots,
					@_chFutures					=	dblFutures,
					@_chHeaderPricingTypeId		=	intPricingTypeId,
					@_chNoOfDays				=	ISNULL(PO.intNoOfDays,0),
					@_chProducerId				=	intProducerId,
					@_chCustomerContract		=	CH.strCustomerContract,
					@_chHeaderNoOfLots			=	CH.dblNoOfLots,
					@_chContractTypeId			=	CH.intContractTypeId
			FROM	tblCTContractHeader CH
			LEFT JOIN tblCTPosition		PO ON PO.intPositionId = CH.intPositionId
			WHERE	intContractHeaderId		=	@_chContractHeaderId

			SELECT @_chFeedOnApproval	=	ysnFeedOnApproval, @_chAutoEvaluateMonth = ysnAutoEvaluateMonth, @_chBasisComponent = (CASE WHEN @_chContractTypeId = 1 THEN ysnBasisComponentPurchase ELSE ysnBasisComponentSales END) FROM tblCTCompanyPreference

			SELECT	@_chContractScreenId=	intScreenId FROM tblSMScreen WHERE strNamespace = 'ContractManagement.view.Contract'

			SELECT @_chPriceFixationId = intPriceFixationId FROM tblCTPriceFixation WHERE intContractHeaderId = @_chContractHeaderId

			SELECT  @_chOnceApproved  =	ysnOnceApproved,
					@_chTransactionId = intTransactionId 
			FROM	tblSMTransaction 
			WHERE	intRecordId = @_chContractHeaderId 
			AND		intScreenId = @_chContractScreenId

			SELECT	TOP 1
					@_chApproverId	  =	intApproverId 
			FROM	tblSMApproval 
			WHERE	intTransactionId  =	@_chTransactionId 
			AND		intScreenId = @_chContractScreenId 
			AND		strStatus = 'Approved' 
			ORDER BY intApprovalId DESC

			--Correct if UOM are wrong

			UPDATE	CD 
			SET		CD.intPriceItemUOMId	=	CU.intItemUOMId
			from	vyuCTContractSequence	CD
			JOIN	tblICItemUOM			IU	ON	IU.intItemUOMId			=	CD.intPriceItemUOMId
			JOIN	tblICUnitMeasure		UM	ON	UM.strUnitMeasure		=	strPriceUOM
			JOIN	tblICItemUOM			CU	ON	CU.intItemId			=	CD.intItemId 
											AND CU.intUnitMeasureId			=	UM.intUnitMeasureId
			WHERE	IU.intItemId			<>	CD.intItemId	
			AND		CD.intContractHeaderId	=	@_chContractHeaderId

			UPDATE	CD 
			SET		CD.intItemUOMId			=	CU.intItemUOMId
			from	vyuCTContractSequence	CD
			JOIN	tblICItemUOM			IU	ON	IU.intItemUOMId			=	CD.intItemUOMId
			JOIN	tblICUnitMeasure		UM	ON	UM.strUnitMeasure		=	strItemUOM
			JOIN	tblICItemUOM			CU	ON	CU.intItemId			=	CD.intItemId 
											AND CU.intUnitMeasureId			=	UM.intUnitMeasureId
			WHERE	IU.intItemId			<>	CD.intItemId	
			AND		CD.intContractHeaderId	=	@_chContractHeaderId

			UPDATE	CD 
			SET		CD.intNetWeightUOMId	=	CU.intItemUOMId
			from	vyuCTContractSequence	CD
			JOIN	tblICItemUOM			IU	ON	IU.intItemUOMId			=	CD.intNetWeightUOMId
			JOIN	tblICUnitMeasure		UM	ON	UM.strUnitMeasure		=	strNetWeightUOM
			JOIN	tblICItemUOM			CU	ON	CU.intItemId			=	CD.intItemId 
												AND CU.intUnitMeasureId		=	UM.intUnitMeasureId
			WHERE	IU.intItemId			<>	CD.intItemId	
			AND		CD.intContractHeaderId	=	@_chContractHeaderId

			UPDATE	CD 
			SET		CD.intBasisUOMId		=	CU.intItemUOMId
			FROM	tblCTContractDetail CD
			JOIN	tblICItemUOM		IU		ON	IU.intItemUOMId			=	CD.intBasisUOMId
			JOIN	tblICUnitMeasure	BU		ON	BU.intUnitMeasureId		=	IU.intUnitMeasureId
			JOIN	tblICUnitMeasure	UM		ON	UM.strUnitMeasure		=	BU.strUnitMeasure
			JOIN	tblICItemUOM		CU		ON	CU.intItemId			=	CD.intItemId 
												AND CU.intUnitMeasureId		=	UM.intUnitMeasureId
			WHERE	IU.intItemId			<>	CD.intItemId
			AND		CD.intContractHeaderId	=	@_chContractHeaderId

			--End Correct if UOM are wrong

			--Other safety Checks--

			IF ISNULL(@_chPriceFixationId,0) = 0 AND @_chMultiplePriceFixation = 1 AND @_chFutures IS NOT NULL AND @_chHeaderPricingTypeId = 2
			BEGIN
				UPDATE tblCTContractHeader SET dblFutures = NULL  WHERE intContractHeaderId = @_chContractHeaderId

				UPDATE	CD 
				SET		CD.intPricingTypeId	=	2,
						CD.dblFutures		=	NULL,
						CD.dblCashPrice		=	NULL,
						CD.dblTotalCost		=	NULL
				FROM	tblCTContractDetail		CD
				WHERE	CD.intContractHeaderId	=	@_chContractHeaderId
			END

			UPDATE	CD 
			SET		CD.intProducerId	=	@_chProducerId
			FROM	tblCTContractDetail	CD
			WHERE	CD.intContractHeaderId	=	@_chContractHeaderId
			AND		CD.intProducerId	IS NULL
			AND		@_chProducerId		IS NOT NULL

			UPDATE	CD 
			SET		dblTotalCost = ROUND(dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,CD.intPriceItemUOMId,CD.dblQuantity) * CD.dblCashPrice / CASE WHEN CY.ysnSubCurrency = 1 THEN 100 ELSE 1 END,6)
			FROM	tblCTContractDetail CD
			JOIN	tblSMCurrency		CY	ON CY.intCurrencyID = CD.intCurrencyId
			WHERE	CD.intPricingTypeId	IN (1,6)
			AND		intContractHeaderId =	@_chContractHeaderId

			SELECT	@ErrMsg = COALESCE(@ErrMsg, '') + '#' + LTRIM(CC.strItemNo)  + '@' + LTRIM(CD.intContractSeq) + '^' + CD.strItemUOM + '.' +CHAR(13) + CHAR(10) 
			FROM	vyuCTContractCostView	CC
			JOIN	vyuCTContractSequence	CD	ON CD.intContractDetailId	=	CC.intContractDetailId
			WHERE	NOT EXISTS(SELECT * FROM tblICItemUOM WHERE intItemId = CC.intItemId AND intUnitMeasureId = CD.intUnitMeasureId)
			AND		CD.intContractHeaderId	=	@_chContractHeaderId AND strCostMethod NOT IN ('Amount','Percentage')

			SELECT @ErrMsg = REPLACE(REPLACE(REPLACE(REPLACE(@ErrMsg, '#', 'Cost item '), '@', ' of sequence '), '^', ' is not configured for sequence UOM "'), '.', '". Configure the Cost Item to have the Sequence UOM and try again.')

			IF	@ErrMsg IS NOT NULL
				RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')

			------------------------

			SELECT @_chContractDetailId		=	MIN(intContractDetailId) FROM tblCTContractDetail WHERE intContractHeaderId = @_chContractHeaderId

			WHILE ISNULL(@_chContractDetailId,0) > 0
			BEGIN
				SELECT	@_chPricingTypeId	=	NULL,
						@_chCashPrice		=	NULL,
						@_chBasis			=	NULL,
						@_chOriginalBasis	=	NULL,
						@_chSlice			=	NULL

				SELECT	@_chPricingTypeId	=	intPricingTypeId,
						@_chCashPrice		=	dblCashPrice,
						@_chBasis			=	dblBasis,
						@_chOriginalBasis	=	dblOriginalBasis,
						@_chLastModifiedById=	intLastModifiedById,
						@_chNetWeightUOMId	=	intNetWeightUOMId,
						@_chNetWeight		=	dblNetWeight,
						@_chItemUOMId		=	intItemUOMId,
						@_chContractStatusId=	intContractStatusId,
						@_chCompanyLocationId = intCompanyLocationId,
						@_chSlice			=	ysnSlice,
						@_chNoOfLots		=	dblNoOfLots,
						@_chPriceChanged	=	ysnPriceChanged,
						@_chConcurrencyId	=	intConcurrencyId,
						@_chFutureMarketId	=	intFutureMarketId,
						@_chUnitMeasureId	=	intUnitMeasureId,
						@_chCurrencyId		=	intCurrencyId

				FROM	tblCTContractDetail 
				WHERE	intContractDetailId =	@_chContractDetailId 
				
				SELECT @_chCorrectNetWeight = dbo.fnCTConvertQtyToTargetItemUOM(intItemUOMId,intNetWeightUOMId,dblQuantity) FROM tblCTContractDetail WHERE intContractDetailId = @_chContractDetailId

				IF ISNULL(@_chNetWeightUOMId,0) > 0 AND (@_chNetWeight IS NULL OR @_chNetWeight <> @_chCorrectNetWeight)
				BEGIN
					UPDATE tblCTContractDetail SET dblNetWeight = @_chCorrectNetWeight WHERE intContractDetailId = @_chContractDetailId
				END

				IF @_chConcurrencyId = 1 AND ISNULL(@_chAutoEvaluateMonth,0) = 1 AND @_chPricingTypeId IN (1,2,3,8) AND @_chSlice = 1
				BEGIN
					UPDATE tblCTContractDetail SET dtmPlannedAvailabilityDate = DATEADD(DAY,@_chNoOfDays,dtmStartDate), @_chPlannedAvalability = DATEADD(DAY,@_chNoOfDays,dtmStartDate)  WHERE intContractDetailId = @_chContractDetailId
					
					DECLARE @FutureMonthId INT

					SELECT TOP 1 @FutureMonthId = intFutureMonthId FROM vyuCTFuturesMonth WHERE intFutureMarketId = @_chFutureMarketId AND intYear >= CAST(SUBSTRING(LTRIM(YEAR(@_chPlannedAvalability)),3,2) AS INT) AND intMonth >= MONTH(@_chPlannedAvalability) AND ysnExpired <> 1 ORDER BY intYear ASC, intMonth ASC

					IF @FutureMonthId IS NULL
					BEGIN
						SELECT TOP 1 @FutureMonthId = intFutureMonthId FROM vyuCTFuturesMonth WHERE intFutureMarketId = @_chFutureMarketId AND intYear >= CAST(SUBSTRING(LTRIM(YEAR(@_chPlannedAvalability)),3,2) AS INT) + 1 AND intMonth > 0 AND ysnExpired <> 1 ORDER BY intYear ASC, intMonth ASC
					END

					UPDATE tblCTContractDetail SET intFutureMonthId = ISNULL(@FutureMonthId,intFutureMonthId) WHERE intContractDetailId = @_chContractDetailId
				END

				IF @_chConcurrencyId = 1
				BEGIN
					UPDATE tblCTContractDetail SET dblOriginalQty = dblQuantity WHERE intContractDetailId = @_chContractDetailId
				END

				IF EXISTS(SELECT * FROM tblCTPriceFixation WHERE intContractDetailId = @_chContractDetailId)
				BEGIN
					SELECT @_chLotsFixed =  dblLotsFixed	FROM tblCTPriceFixation WHERE intContractDetailId = @_chContractDetailId
					IF @_chNoOfLots > @_chLotsFixed AND @_chPricingTypeId = 1
					BEGIN
						UPDATE	tblCTContractDetail
						SET		dblFutures			=	NULL,
								dblCashPrice		=	NULL,
								dblTotalCost		=	NULL,
								intPricingTypeId	=	CASE WHEN @_chHeaderPricingTypeId= 8 THEN 8 ELSE 2 END
						WHERE	intContractDetailId	=	@_chContractDetailId
					END

				END

				IF @_chPriceChanged = 1
				BEGIN
					EXEC	uspCTSequencePriceChanged @_chContractDetailId,null,'Sequence',0
					UPDATE tblCTContractDetail SET ysnPriceChanged = 0 WHERE intContractDetailId = @_chContractDetailId
				END
				
				IF @_chPricingTypeId IN (2,8) AND @_chOriginalBasis IS NULL
				BEGIN
					UPDATE tblCTContractDetail SET dblOriginalBasis = dblBasis WHERE intContractDetailId = @_chContractDetailId
				END

				IF @_chOriginalBasis IS NOT NULL AND  @_chBasis <> @_chOriginalBasis
				BEGIN
					EXEC uspCTUpdateSequenceBasis @_chContractDetailId,@_chBasis
				END

				IF @_chPricingTypeId IN (1,2,8)
				BEGIN
					UPDATE	CD 
					SET		CD.dblConvertedBasis = dbo.fnCTConvertQtyToTargetItemUOM(CD.intPriceItemUOMId,CD.intBasisUOMId,CD.dblBasis) / 
							CASE	WHEN	CD.intCurrencyId = CD.intBasisCurrencyId THEN 1 
									WHEN	ISNULL(CY.ysnSubCurrency,0) = 1 THEN 0.01 
									ELSE	100
							END
					FROM	tblCTContractDetail CD
					JOIN	tblSMCurrency		CY	ON	CD.intCurrencyId	=	CY.intCurrencyID
					WHERE	CD.intContractDetailId	=	@_chContractDetailId 
				END
				ELSE
				BEGIN
					UPDATE	tblCTContractDetail 
					SET		dblConvertedBasis	=	NULL
					WHERE	intContractDetailId	=	@_chContractDetailId 
				END

				EXEC uspLGUpdateLoadItem @_chContractDetailId
				IF NOT EXISTS(SELECT 1 FROM tblCTContractDetail WITH (NOLOCK) WHERE intParentDetailId = @_chContractDetailId AND ysnSlice = 1 ) OR (@_chSlice <> 1)
				BEGIN
					DECLARE @previousQty NUMERIC(18, 6)
						, @previousLocation INT
						, @curQty NUMERIC(18, 6)
						, @curLocation INT

					SELECT TOP 1 @previousQty = dblQuantity
						, @previousLocation = intCompanyLocationId
					FROM tblCTSequenceHistory
					WHERE intContractDetailId = @_chContractDetailId
					ORDER BY dtmHistoryCreated DESC

					SELECT TOP 1 @curQty = dblQuantity
						, @curLocation = intCompanyLocationId
					FROM tblCTContractDetail WITH (NOLOCK) WHERE intContractDetailId = @_chContractDetailId
					
					IF (@previousQty != @curQty OR @previousLocation != @curLocation)
					BEGIN
						EXEC uspLGUpdateCompanyLocation @_chContractDetailId
						-- Update Shipping Intruction Quantity
						UPDATE T SET dblShippingInstructionQty = T.dblQuantity 
						FROM tblCTContractDetail T 
						WHERE intContractDetailId = @_chContractDetailId
						AND dblShippingInstructionQty > 0
					END
				END
				UPDATE tblQMSample SET intLocationId = @_chCompanyLocationId WHERE intContractDetailId = @_chContractDetailId

				EXEC uspCTSplitSequencePricing @_chContractDetailId, @_chLastModifiedById

				IF	@_chContractStatusId	=	1	AND
					@_chOnceApproved		=	1	AND
					@_chFeedOnApproval		=	1	AND
					NOT EXISTS (SELECT * from tblCTApprovedContract WHERE intContractHeaderId = @_chContractHeaderId)
				BEGIN
					EXEC uspCTContractApproved	@_chContractHeaderId, @_chApproverId, @_chContractDetailId, 1
				END

				IF	@_chBasisComponent = 1 AND @_chBasis = 0 AND
					NOT EXISTS(SELECT * FROM tblCTContractCost WHERE ysnBasis = 1 AND intContractDetailId = @_chContractDetailId) -- ADD missing Basis components
				BEGIN
					INSERT	INTO tblCTContractCost(intConcurrencyId,intContractDetailId,intItemId,strCostMethod,intCurrencyId,dblRate,intItemUOMId,ysnBasis)
					SELECT	1 AS intConcurrencyId,@_chContractDetailId,IM.intItemId,'Per Unit',@_chCurrencyId,0 AS dblRate, IU.intItemUOMId, 1 AS ysnBasis
					FROM	tblICItem		IM
					JOIN	tblICItemUOM	IU ON IU.intItemId = IM.intItemId AND IU.intUnitMeasureId = @_chUnitMeasureId
					WHERE	ysnBasisContract = 1
				END

				IF EXISTS(SELECT TOP 1 1 FROM tblCTContractCertification WHERE intContractDetailId = @_chContractDetailId)
				BEGIN 
					SELECT	@_chCertificationName = NULL
					SELECT	@_chCertificationName = COALESCE(@_chCertificationName + ', ', '') + CAST(strCertificationName AS NVARCHAR(100))
					FROM	tblCTContractCertification	CF
					JOIN	tblICCertification			IC	ON	IC.intCertificationId	=	CF.intCertificationId
					WHERE	intContractDetailId = @_chContractDetailId

					UPDATE	tblCTContractDetail SET	strCertifications = @_chCertificationName WHERE	intContractDetailId	= @_chContractDetailId 
				END
				ELSE
				BEGIN
					UPDATE	tblCTContractDetail SET	strCertifications	=	NULL WHERE	intContractDetailId	=	@_chContractDetailId 
				END

				IF @_chContractStatusId IN (3,6)
				BEGIN
					EXEC uspCTCancelOpenLoadSchedule @_chContractDetailId
				END

				SELECT @_chLotsFixed = NULL,@_chPriceFixationId = NULL
				SELECT @_chLotsFixed = dblLotsFixed,@_chPriceFixationId = intPriceFixationId FROM tblCTPriceFixation WHERE intContractDetailId = @_chContractDetailId

				IF @_chLotsFixed IS NOT NULL AND @_chNoOfLots IS NOT NULL AND @_chNoOfLots < @_chLotsFixed
				BEGIN
					UPDATE tblCTPriceFixation SET dblLotsFixed = @_chNoOfLots WHERE intContractDetailId = @_chContractDetailId
					SET @_chLotsFixed = @_chNoOfLots
				END
				
				IF	@_chLotsFixed IS NOT NULL AND @_chNoOfLots IS NOT NULL AND @_chNoOfLots = @_chLotsFixed AND
					EXISTS(SELECT * FROM tblCTContractDetail WHERE intContractDetailId = @_chContractDetailId AND intPricingTypeId IN (2,8))
				BEGIN
					UPDATE	tblCTPriceFixation SET dblTotalLots = @_chNoOfLots WHERE intPriceFixationId = @_chPriceFixationId
					EXEC	[uspCTPriceFixationSave] @_chPriceFixationId, '', @_chLastModifiedById, 1
				END		
				
				-- ADD DERIVATIVES
				EXEC uspCTManageDerivatives @_chContractDetailId

				SELECT @_chContractDetailId = MIN(intContractDetailId) FROM tblCTContractDetail WHERE intContractHeaderId = @_chContractHeaderId AND intContractDetailId > @_chContractDetailId
			END

			IF ISNULL(@_chMultiplePriceFixation,0) = 0
			BEGIN
				UPDATE	PF
				SET		PF.[dblTotalLots] = (SELECT SUM(dblNoOfLots) FROM tblCTContractDetail WHERE intContractDetailId = CD.intContractDetailId)-- OR ISNULL(intSplitFromId,0) = CD.intContractDetailId)
				FROM	tblCTPriceFixation	PF
				JOIN	tblCTContractDetail CD ON CD.intContractDetailId = PF.intContractDetailId
				WHERE	CD.intContractHeaderId = @_chContractHeaderId

				UPDATE b SET dblNoOfLots = (b.dblQuantity / d.dblContractSize)
				FROM tblCTPriceFixation a
				INNER JOIN tblCTPriceFixationDetail b ON a.intPriceFixationId =  b.intPriceFixationId
				INNER JOIN tblCTContractDetail c ON a.intContractDetailId = c.intContractDetailId
				INNER JOIN vyuRKMarketDetail d ON c.intFutureMarketId = d.intFutureMarketId
				WHERE a.intContractHeaderId = @_chContractHeaderId
			END
			ELSE
			BEGIN
				SELECT @_chLotsFixed = dblLotsFixed,@_chPriceFixationId = intPriceFixationId FROM tblCTPriceFixation WHERE intContractHeaderId = @_chContractHeaderId
				IF	@_chLotsFixed IS NOT NULL AND @_chHeaderNoOfLots IS NOT NULL AND @_chHeaderNoOfLots = @_chLotsFixed AND
					EXISTS(SELECT * FROM tblCTContractDetail WHERE intContractHeaderId = @_chContractHeaderId AND intPricingTypeId = 2)
				BEGIN
					UPDATE tblCTPriceFixation SET dblTotalLots = @_chHeaderNoOfLots WHERE intPriceFixationId = @_chPriceFixationId
					EXEC	[uspCTPriceFixationSave] @_chPriceFixationId, '', @_chLastModifiedById, 1
				END
				ELSE IF @_chLotsFixed IS NOT NULL AND @_chHeaderNoOfLots IS NOT NULL AND @_chHeaderNoOfLots <> @_chLotsFixed AND
					EXISTS(SELECT * FROM tblCTContractDetail WHERE intContractHeaderId = @_chContractHeaderId AND intPricingTypeId = 1)
				BEGIN
					UPDATE tblCTPriceFixation SET dblTotalLots = @_chHeaderNoOfLots WHERE intPriceFixationId = @_chPriceFixationId
				END		
			END

			EXEC uspCTUpdateAdditionalCost @_chContractHeaderId

			IF EXISTS(SELECT * FROM tblCTContractImport WHERE strContractNumber = @_chContractNumber AND ysnImported = 0)
			BEGIN
				UPDATE	tblCTContractImport
				SET		ysnImported = 1,
						intContractHeaderId = @_chContractHeaderId
				WHERE	strContractNumber = @_chContractNumber AND ysnImported = 0
			END

			--Slice
			--EXEC uspQMSampleContractSlice @_chContractHeaderId --Please do not uncomment this one. This is related to jira CT-4391
			EXEC uspLGLoadContractSlice @_chContractHeaderId
			UPDATE tblCTContractDetail SET ysnSlice = NULL WHERE intContractHeaderId = @_chContractHeaderId

			--Update Signature Date
			IF EXISTS(SELECT * FROM tblCTContractHeader WHERE intContractHeaderId = @_chContractHeaderId AND ysnSigned = 1 AND dtmSigned IS NULL)
			BEGIN
				UPDATE tblCTContractHeader SET dtmSigned = DATEADD(d, 0, DATEDIFF(d, 0, GETDATE())) WHERE intContractHeaderId = @_chContractHeaderId		
			END

			EXEC	uspCTCreateDetailHistory		@intContractHeaderId 	= @_chContractHeaderId,
													@strSource 				= 'Contract',
													@strProcess 			= 'Save Contract',
													@intUserId				= @_chUserId	
			EXEC	uspCTInterCompanyContract		@_chContractHeaderId

			-- Add Payables if Create Other Cost Payable on Save Contract set to true
			IF EXISTS(SELECT TOP 1 1 FROM tblCTCompanyPreference WHERE ysnCreateOtherCostPayable = 1)
			BEGIN
				--EXEC uspCTManagePayable @_chContractHeaderId, 'header', 0, @_chUserId
				select top 1 @_chAddToPayableMessage = strMessage from dbo.fnCTGetVoucherPayable(@_chContractHeaderId, 'header', 1, 0);
				if (isnull(@_chAddToPayableMessage,'') <> '')
				begin
					RAISERROR (@_chAddToPayableMessage,18,1,'WITH NOWAIT')   
				end
				else
				begin
					EXEC uspCTManagePayable @_chContractHeaderId, 'header', 0, @_chUserId  
				end
			END

			-----------------------  Validate Contract  -----------------------
			DECLARE @_vcContractDetailId		INT,
					@_vcAllocatedQty			NUMERIC(18,6),
					@_vcQuantity				NUMERIC(18,6),
					@_vcRequireProducerQty		BIT,
					@_vcProducerQuantity		NUMERIC(18,6),
					@_vcContractSeq				INT

			SELECT @_vcContractDetailId		=	MIN(intContractDetailId) FROM tblCTContractDetail WHERE intContractHeaderId = @_chContractHeaderId
			SELECT @_vcRequireProducerQty	=	ysnRequireProducerQty FROM tblCTCompanyPreference

			WHILE ISNULL(@_vcContractDetailId,0) > 0
			BEGIN

				SELECT	@_vcAllocatedQty	=	dblAllocatedQty,
						@_vcQuantity		=	dblQuantity,
						@_vcContractSeq		=	intContractSeq
				FROM	tblCTContractDetail 
				WHERE	intContractDetailId =	@_vcContractDetailId 
			
				IF	@_vcAllocatedQty > @_vcQuantity
				BEGIN
					SET @ErrMsg = 'Cannot update sequence quantity below '+LTRIM(@_vcAllocatedQty)+' as it is used in Allocation.'
					RAISERROR(@ErrMsg,16,1) 
				END

				IF	@_vcRequireProducerQty	=	1
				BEGIN
					SELECT @_vcProducerQuantity	=	SUM(ISNULL(dblQuantity,0))	FROM	tblCTContractCertification WHERE intContractDetailId = @_vcContractDetailId
					IF	@_vcProducerQuantity > @_vcQuantity
					BEGIN
						SET @ErrMsg = 'Sum of producer''s quantity('+dbo.fnRemoveTrailingZeroes(@_vcProducerQuantity)+') is greater than sequence '+LTRIM(@_vcContractSeq)+' quantity('+dbo.fnRemoveTrailingZeroes(@_vcQuantity)+').'
						RAISERROR(@ErrMsg,16,1) 
					END
				END

				SELECT @_vcContractDetailId = MIN(intContractDetailId) FROM tblCTContractDetail WHERE intContractHeaderId = @_chContractHeaderId AND intContractDetailId > @_vcContractDetailId
			END

			SELECT @intUniqueId = MIN(intUniqueId) FROM #ContractHeaders WHERE intUniqueId > @intUniqueId

		END

	END

	----------------------------------------------------------------------------------------------------
	--------------------------------  R E A S S I G N  C O N T R A C T  --------------------------------
	----------------------------------------------------------------------------------------------------
	IF @xmlReassigns <> ''
	BEGIN

		DECLARE @_rReassignId			INT,
				@_rContractTypeId		INT,
				@_rEntityId				INT,
				@_rDonorId				INT,
				@_rRecipientId			INT,
				@_rCreatedById			INT,
				@_rCreated				DATETIME,
				@_rUnallocatedQty		NUMERIC,
				@_rAllocationUOMId		INT,
				@_rAllocationUOM		NVARCHAR,
				@_rUnpricedLots			NUMERIC,
				@_rUnhedgedLots			NUMERIC,
				@_rConcurrencyId		INT,
				@_rContractType			NVARCHAR,
				@_rEntityName			NVARCHAR,
				@_rDonorContract		NVARCHAR,
				@_rRecipientContract	NVARCHAR

		EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlReassigns

		IF OBJECT_ID('tempdb..#Reassigns') IS NOT NULL
			DROP TABLE #Reassigns

		SELECT  ROW_NUMBER() OVER(ORDER BY intReassignId) intUniqueId,*
		INTO	#Reassigns
		FROM	OPENXML(@idoc,'reassigns/reassign',2)
		WITH	
		(
			intReassignId			INT,
			intContractTypeId		INT,
			intEntityId				INT,
			intDonorId				INT,
			intRecipientId			INT,
			intCreatedById			INT,
			dtmCreated				DATETIME,
			dblUnallocatedQty		NUMERIC(18,6),
			intAllocationUOMId		INT,
			strAllocationUOM		NVARCHAR,
			dblUnpricedLots			NUMERIC(18,6),
			dblUnhedgedLots			NUMERIC(18,6),
			intConcurrencyId		INT,
			strContractType			NVARCHAR,
			strEntityName			NVARCHAR,
			strDonorContract		NVARCHAR,
			strRecipientContract	NVARCHAR
		)

		SELECT @intUniqueId = MIN(intUniqueId) FROM #Reassigns

		WHILE ISNULL(@intUniqueId,0) > 0
		BEGIN

			SELECT	@_rContractTypeId		=	intContractTypeId,
					@_rEntityId				=   intEntityId,
					@_rDonorId				=   intDonorId,
					@_rRecipientId			=   intRecipientId,
					@_rCreatedById			=   intCreatedById,
					@_rCreated				=   dtmCreated,
					@_rUnallocatedQty		=   dblUnallocatedQty,
					@_rAllocationUOMId		=   intAllocationUOMId,
					@_rAllocationUOM		=   strAllocationUOM,
					@_rUnpricedLots			=   dblUnpricedLots,
					@_rUnhedgedLots			=   dblUnhedgedLots,
					@_rConcurrencyId		=   intConcurrencyId,
					@_rContractType			=   strContractType,
					@_rEntityName			=   strEntityName,
					@_rDonorContract		=   strDonorContract,
					@_rRecipientContract	=   strRecipientContract

			FROM	#Reassigns
			WHERE	intUniqueId = @intUniqueId

			INSERT INTO tblCTReassign 
			(
				intContractTypeId,
				intEntityId,
				intDonorId,
				intRecipientId,
				intCreatedById,
				dtmCreated,
				dblUnallocatedQty,
				intAllocationUOMId,
				strAllocationUOM,
				dblUnpricedLots,
				dblUnhedgedLots,
				intConcurrencyId,
				strContractType,
				strEntityName,
				strDonorContract,
				strRecipientContract
			)
			SELECT @_rContractTypeId,
				@_rEntityId,	
				@_rDonorId,
				@_rRecipientId,
				@_rCreatedById,
				@_rCreated,
				@_rUnallocatedQty,
				@_rAllocationUOMId,
				@_rAllocationUOM,
				@_rUnpricedLots,
				@_rUnhedgedLots,
				@_rConcurrencyId,
				@_rContractType,
				@_rEntityName,	
				@_rDonorContract,
				@_rRecipientContract

			SET @_rReassignId = SCOPE_IDENTITY()

			EXEC uspCTReassignSave @_rReassignId, @_rCreatedById

			SELECT @intUniqueId = MIN(intUniqueId) FROM #Reassigns WHERE intUniqueId > @intUniqueId

		END
	
	END


END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH