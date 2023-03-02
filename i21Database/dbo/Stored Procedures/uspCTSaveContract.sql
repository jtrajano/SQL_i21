﻿CREATE PROCEDURE [dbo].[uspCTSaveContract]
	
	@intContractHeaderId INT,
	@userId INT,
	@strXML	NVARCHAR(MAX),
	@strTFXML	NVARCHAR(MAX) = ''
	
AS

BEGIN TRY
	
	DECLARE	@ErrMsg						NVARCHAR(MAX),
			@intContractDetailId		INT,
			@dblCashPrice				NUMERIC(18,6),
			@intPricingTypeId			INT,
			@intLastModifiedById		INT,
			@ysnMultiplePriceFixation	BIT,
			@strContractNumber			NVARCHAR(100),
			@dblBasis					NUMERIC(18,6),
			@dblOriginalBasis			NUMERIC(18,6),
			@Action						NVARCHAR(100),
			@Condition					NVARCHAR(100),
			@idoc						INT,
			@intUniqueId				INT,
			@strRowState				NVARCHAR(100),
			@intNetWeightUOMId			INT,
			@dblNetWeight				NUMERIC(18,6),
			@intItemUOMId				INT,
			@intContractStatusId		INT,
			@intContractScreenId		INT,
			@ysnOnceApproved			BIT,
			@ysnFeedOnApproval			BIT,
			@intTransactionId			INT,
			@intApproverId				INT,
			@intCompanyLocationId		INT,
			@ysnSlice					BIT,
			@dblLotsFixed				NUMERIC(18,6),
			@dblNoOfLots				NUMERIC(18,6),
			@dblHeaderNoOfLots			NUMERIC(18,6),
			@intPriceFixationId			INT,
			@ysnPriceChanged			BIT,
			@dblCorrectNetWeight		NUMERIC(18,6),
			@dblFutures					NUMERIC(18,6),
			@ysnAutoEvaluateMonth		BIT,
			@intConcurrencyId			INT,
			@intNoOfDays				INT,
			@dtmPlannedAvalability		DATETIME,
			@intFutureMarketId			INT,
			@ysnBasisComponent			BIT,
			@intUnitMeasureId			INT,
			@intCurrencyId				INT,
			@intHeaderPricingTypeId		INT,
			@intProducerId				INT,
			@strCertificationName		NVARCHAR(MAX),
			@strCustomerContract		NVARCHAR(100),
			@intContractTypeId			INT,
			@strAddToPayableMessage		NVARCHAR(MAX),
			@ysnEnableLetterOfCredit    BIT = 0,
			@intLCApplicantId			INT,
            @strLCType					NVARCHAR(100),
            @strLCNumber				NVARCHAR(50),
			@intCostTermId				INT


	update pf1 set dblLotsFixed = isnull(pricing.dblPricedQty,0.00) / (cd.dblQuantity / isnull(cd.dblNoOfLots,1))
	from tblCTContractDetail cd
	join tblCTContractHeader ch on ch.intContractHeaderId = cd.intContractHeaderId
	join tblCTPriceFixation pf1 on pf1.intContractDetailId = cd.intContractDetailId
	cross apply (
		select dblPricedQty = sum(pfd.dblQuantity) from tblCTPriceFixation pf
		join tblCTPriceFixationDetail pfd on pfd.intPriceFixationId = pf.intPriceFixationId
		where pf.intContractDetailId = cd.intContractDetailId
	) pricing
	where cd.intContractHeaderId = @intContractHeaderId
	and cd.intPricingTypeId = 1
	and ch.intPricingTypeId in (2,3)
	and ch.ysnMultiplePriceFixation <> 1
	and cd.dblQuantity > isnull(pricing.dblPricedQty,0);

	update
		cd
	set
		cd.dblFutures = null
		,cd.dblCashPrice = null
		,cd.intPricingTypeId = ch.intPricingTypeId
		,cd.intPricingStatus = 1
		,cd.dblTotalCost = null
		,cd.ysnPriceChanged = 1
	from tblCTContractDetail cd
	join tblCTContractHeader ch on ch.intContractHeaderId = cd.intContractHeaderId
	cross apply (
		select dblPricedQty = sum(pfd.dblQuantity) from tblCTPriceFixation pf
		join tblCTPriceFixationDetail pfd on pfd.intPriceFixationId = pf.intPriceFixationId
		where pf.intContractDetailId = cd.intContractDetailId
	) pricing
	where cd.intContractHeaderId = @intContractHeaderId
	and cd.intPricingTypeId = 1
	and ch.intPricingTypeId = 2
	and ch.ysnMultiplePriceFixation <> 1
	and isnull(pricing.dblPricedQty,0) > 0
	and cd.dblQuantity > isnull(pricing.dblPricedQty,0)
	and ISNULL(cd.intSplitFromId,0) = 0;

	SELECT	@ysnMultiplePriceFixation	=	ysnMultiplePriceFixation,
			@strContractNumber			=	strContractNumber,
			@dblNoOfLots				=	dblNoOfLots,
			@dblFutures					=	dblFutures,
			@intHeaderPricingTypeId		=	intPricingTypeId,
			@intNoOfDays				=	ISNULL(PO.intNoOfDays,0),
			@intProducerId				=	intProducerId,
			@strCustomerContract		=	CH.strCustomerContract,
			@dblHeaderNoOfLots			=	CH.dblNoOfLots,
			@intContractTypeId			=	CH.intContractTypeId
	FROM	tblCTContractHeader CH WITH (UPDLOCK)
	LEFT JOIN tblCTPosition		PO ON PO.intPositionId = CH.intPositionId
	WHERE	intContractHeaderId		=	@intContractHeaderId

	DECLARE @CDTableUpdate AS TABLE (
		intContractDetailId INT
		, intPricingTypeId INT NULL
		, dblFutures NUMERIC(24, 10) NULL
		, dblCashPrice NUMERIC(24, 10) NULL
		, dblTotalCost NUMERIC(24, 10) NULL
		, intProducerId INT NULL
		, dblNetWeight NUMERIC(24, 10) NULL
		, dtmPlannedAvailabilityDate DATETIME NULL
		, intFutureMonthId INT NULL
		, dblOriginalQty NUMERIC(24, 10) NULL
		, ysnPriceChanged BIT NULL
		, dblOriginalBasis NUMERIC(24, 10) NULL
		, dblConvertedBasis NUMERIC(24, 10) NULL
		, dtmStartDate DATETIME NULL
		, intCurrencyId INT NULL
		, intItemUOMId INT NULL
		, intPriceItemUOMId INT NULL
		, dblQuantity NUMERIC(24, 10) NULL
		, dblBasis NUMERIC(24, 10) NULL
		, intBasisUOMId INT NULL
		, intBasisCurrencyId INT NULL
		, strCertifications NVARCHAR(MAX)
	)

	if (isnull(@strTFXML,'') <> '')
	begin
		exec uspCTProcessTFLogs
			@strXML = @strTFXML
			,@intUserId = @userId;
	end

	INSERT INTO @CDTableUpdate(intContractDetailId
		, intPricingTypeId
		, dblFutures
		, dblCashPrice
		, dblTotalCost
		, intProducerId
		, dblNetWeight
		, dtmPlannedAvailabilityDate
		, intFutureMonthId
		, dblOriginalQty
		, ysnPriceChanged
		, dblOriginalBasis
		, dblConvertedBasis
		, dtmStartDate
		, intCurrencyId
		, intItemUOMId
		, intPriceItemUOMId
		, dblQuantity
		, dblBasis
		, intBasisUOMId
		, intBasisCurrencyId
		, strCertifications)
	SELECT intContractDetailId
		, intPricingTypeId
		, dblFutures
		, dblCashPrice
		, dblTotalCost
		, intProducerId
		, dblNetWeight
		, dtmPlannedAvailabilityDate
		, intFutureMonthId
		, dblOriginalQty
		, ysnPriceChanged
		, dblOriginalBasis
		, dblConvertedBasis
		, dtmStartDate
		, intCurrencyId
		, intItemUOMId
		, intPriceItemUOMId
		, dblQuantity
		, dblBasis
		, intBasisUOMId
		, intBasisCurrencyId
		, strCertifications
	FROM tblCTContractDetail WHERE intContractHeaderId = @intContractHeaderId

	SELECT @ysnEnableLetterOfCredit = ysnEnableLetterOfCredit, @ysnFeedOnApproval	=	ysnFeedOnApproval, @ysnAutoEvaluateMonth = ysnAutoEvaluateMonth, @ysnBasisComponent = (CASE WHEN @intContractTypeId = 1 THEN ysnBasisComponentPurchase ELSE ysnBasisComponentSales END) FROM tblCTCompanyPreference

	SELECT	@intContractScreenId=	intScreenId FROM tblSMScreen WHERE strNamespace = 'ContractManagement.view.Contract'

	SELECT @intPriceFixationId = intPriceFixationId FROM tblCTPriceFixation WITH (UPDLOCK) WHERE intContractHeaderId = @intContractHeaderId

	SELECT  @ysnOnceApproved  =	ysnOnceApproved,
			@intTransactionId = intTransactionId 
	FROM	tblSMTransaction 
	WHERE	intRecordId = @intContractHeaderId 
	AND		intScreenId = @intContractScreenId

	SELECT	TOP 1
			@intApproverId	  =	intApproverId 
	FROM	tblSMApproval 
	WHERE	intTransactionId  =	@intTransactionId 
	AND		intScreenId = @intContractScreenId 
	AND		strStatus = 'Approved' 
	ORDER BY intApprovalId DESC

	IF ISNULL(@intPriceFixationId,0) = 0 AND @ysnMultiplePriceFixation = 1 AND @dblFutures IS NOT NULL AND @intHeaderPricingTypeId = 2
	BEGIN
		UPDATE @CDTableUpdate
		SET intPricingTypeId = 2
			, dblFutures = NULL
			, dblCashPrice = NULL
			, dblTotalCost = NULL
	END

	UPDATE @CDTableUpdate
	SET intProducerId = @intProducerId
	WHERE intProducerId IS NULL
		AND @intProducerId IS NOT NULL
	
	UPDATE CD
	SET dblTotalCost = ROUND(dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,CD.intPriceItemUOMId,CD.dblQuantity) * CD.dblCashPrice / CASE WHEN CY.ysnSubCurrency = 1 THEN 100 ELSE 1 END,6)
	FROM @CDTableUpdate CD
	JOIN tblSMCurrency CY ON CY.intCurrencyID = CD.intCurrencyId
	WHERE CD.intPricingTypeId IN (1, 6)

	SELECT	@ErrMsg = COALESCE(@ErrMsg, '') + '#' + LTRIM(CC.strItemNo)  + '@' + LTRIM(CD.intContractSeq) + '^' + CD.strItemUOM + '.' +CHAR(13) + CHAR(10) 
	FROM	vyuCTContractCostView	CC
	JOIN	vyuCTContractSequence	CD	ON CD.intContractDetailId	=	CC.intContractDetailId
	WHERE	NOT EXISTS(SELECT TOP 1 1 FROM tblICItemUOM WHERE intItemId = CC.intItemId AND intUnitMeasureId = CD.intUnitMeasureId)
	AND		CD.intContractHeaderId	=	@intContractHeaderId AND strCostMethod NOT IN ('Amount','Percentage')

	SELECT @ErrMsg = REPLACE(REPLACE(REPLACE(REPLACE(@ErrMsg, '#', 'Cost item '), '@', ' of sequence '), '^', ' is not configured for sequence UOM "'), '.', '". Configure the Cost Item to have the Sequence UOM and try again.')

	IF	@ErrMsg IS NOT NULL
		RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')

	------------------------

	SELECT @intContractDetailId		=	MIN(intContractDetailId) FROM tblCTContractDetail WHERE intContractHeaderId = @intContractHeaderId
	
	WHILE ISNULL(@intContractDetailId,0) > 0
	BEGIN

		if (isnull(@ysnMultiplePriceFixation,0) <> 1 AND @intHeaderPricingTypeId = 2)
		begin
			update cd
			set
				cd.intPricingTypeId = 2
				,cd.dblFutures = NULL
				,cd.dblCashPrice = NULL
				,cd.dblTotalCost = NULL
			from @CDTableUpdate cd
			left join (
				select pf.intContractDetailId, dblPricedQuantity = sum(fd.dblQuantity)
				from tblCTPriceFixation pf
				join tblCTPriceFixationDetail fd on fd.intPriceFixationId = pf.intPriceFixationId
				where pf.intContractDetailId = @intContractDetailId
				group by pf.intContractDetailId
			)p on p.intContractDetailId = cd.intContractDetailId
			where cd.intContractDetailId = @intContractDetailId
			and isnull(p.dblPricedQuantity,0) < cd.dblQuantity
			and isnull(p.dblPricedQuantity,0) > 0
		end

		SELECT	@intPricingTypeId	=	NULL,
				@dblCashPrice		=	NULL,
				@dblBasis			=	NULL,
				@dblOriginalBasis	=	NULL,
				@ysnSlice			=	NULL,
				@strLCNumber		=	null,
				@intCostTermId		=	NULL

		SELECT	@intPricingTypeId	=	intPricingTypeId,
				@dblCashPrice		=	dblCashPrice,
				@dblBasis			=	dblBasis,
				@dblOriginalBasis	=	dblOriginalBasis,
				@intLastModifiedById=	intLastModifiedById,
				@intNetWeightUOMId	=	intNetWeightUOMId,
				@dblNetWeight		=	dblNetWeight,
				@intItemUOMId		=	intItemUOMId,
				@intContractStatusId=	intContractStatusId,
				@intCompanyLocationId = intCompanyLocationId,
				@ysnSlice			=	ysnSlice,
				@dblNoOfLots		=	dblNoOfLots,
				@ysnPriceChanged	=	ysnPriceChanged,
				@intConcurrencyId	=	intConcurrencyId,
				@intFutureMarketId	=	intFutureMarketId,
				@intUnitMeasureId	=	intUnitMeasureId,
				@intCurrencyId		=	intCurrencyId,
				@strLCNumber		=	strLCNumber,
				@intLCApplicantId	=	intLCApplicantId,
				@strLCType			=	strLCType,
				@intCostTermId		=	intCostTermId

		FROM	tblCTContractDetail WITH (UPDLOCK)
		WHERE	intContractDetailId =	@intContractDetailId 

		if (@ysnEnableLetterOfCredit = 1 and @strLCNumber is null and @intLCApplicantId > 0 and isnull(@strLCType,'') <> '')
		begin
			exec uspSMGetStartingNumber
				@intStartingNumberId = 170,
				@strID = @strLCNumber OUTPUT,
				@intCompanyLocationId = default
		end

		
		IF EXISTS (SELECT TOP 1 1 FROM tblCTCompanyPreference where ysnEnablePackingWeightAdjustment = 0)
		BEGIN
			SELECT @dblCorrectNetWeight = dbo.fnCTConvertQtyToTargetItemUOM(intItemUOMId,intNetWeightUOMId,dblQuantity) FROM tblCTContractDetail WITH (UPDLOCK) WHERE intContractDetailId = @intContractDetailId

			IF ISNULL(@intNetWeightUOMId,0) > 0 AND (@dblNetWeight IS NULL OR @dblNetWeight <> @dblCorrectNetWeight)
			BEGIN
				UPDATE @CDTableUpdate SET dblNetWeight = @dblCorrectNetWeight where intContractDetailId = @intContractDetailId;
			END
		END

		IF @intConcurrencyId = 1 AND ISNULL(@ysnAutoEvaluateMonth,0) = 1 AND @intPricingTypeId IN (1,2,3,8) AND @ysnSlice = 1
		BEGIN
			--UPDATE @CDTableUpdate SET dtmPlannedAvailabilityDate = DATEADD(DAY,@intNoOfDays,dtmStartDate), @dtmPlannedAvalability = DATEADD(DAY,@intNoOfDays,dtmStartDate)
			
			DECLARE @FutureMonthId INT

			SELECT TOP 1 @FutureMonthId = intFutureMonthId FROM vyuCTFuturesMonth WHERE intFutureMarketId = @intFutureMarketId AND intYear >= CAST(SUBSTRING(LTRIM(YEAR(@dtmPlannedAvalability)),3,2) AS INT) AND intMonth >= MONTH(@dtmPlannedAvalability) AND ysnExpired <> 1 ORDER BY intYear ASC, intMonth ASC

			IF @FutureMonthId IS NULL
			BEGIN
				SELECT TOP 1 @FutureMonthId = intFutureMonthId FROM vyuCTFuturesMonth WHERE intFutureMarketId = @intFutureMarketId AND intYear >= CAST(SUBSTRING(LTRIM(YEAR(@dtmPlannedAvalability)),3,2) AS INT) + 1 AND intMonth > 0 AND ysnExpired <> 1 ORDER BY intYear ASC, intMonth ASC
			END

			UPDATE @CDTableUpdate SET intFutureMonthId = CASE WHEN ISNULL(@FutureMonthId, 0) > ISNULL(intFutureMonthId, 0) THEN @FutureMonthId ELSE intFutureMonthId END WHERE intContractDetailId = @intContractDetailId
		END

		IF @intConcurrencyId = 1
		BEGIN
			-- Newly created sequence - CT-5847
			EXEC uspICAddTransactionLinkOrigin @intTransactionId = @intContractHeaderId
				, @strTransactionNo = @strContractNumber
				, @strTransactionType = 'Contract'
				, @strModuleName = 'Contract Management'

			UPDATE @CDTableUpdate SET dblOriginalQty = dblQuantity WHERE intContractDetailId = @intContractDetailId

			-- RECALCULATE Cost Term
			IF (ISNULL(@intCostTermId, 0) <> 0)
			BEGIN
				DECLARE @intCommodityId INT
					, @intItemId INT
					, @intFromPortId INT
					, @intToPortId INT
					, @intFromTermId INT
					, @intToTermId INT
					, @dtmDate DATETIME
					, @intMarketZoneId INT
					, @intInvoiceCurrencyId INT
					, @intRateTypeId INT
					, @intSequenceCurrencyId INT
					, @intDefaultFreightId INT
					, @intDefaultInsuranceId INT
					, @intDetailPricingTypeId INT
					, @ysnEnableBudgetForBasisPricing BIT
					, @dblTotalBudget NUMERIC(18, 6)
					, @dblTotalCost NUMERIC(18, 6)
					, @ysnUseCostCurrencyToFunctionalCurrencyRateInContractCost bit

				DECLARE @CostItems AS TABLE (intCostItemId INT
					, strCostItem NVARCHAR(100)
					, intEntityId INT
					, strEntityName NVARCHAR(100)
					, intCurrencyId INT
					, strCurrency NVARCHAR(100)
					, intItemUOMId INT
					, strUnitMeasure NVARCHAR(100)
					, strCostMethod NVARCHAR(50)
					, dblRate NUMERIC(18, 6)
					, dblAmount NUMERIC(18, 6)
					, dblFX NUMERIC(18, 6))
				
				SELECT @intCommodityId = ch.intCommodityId
					, @intItemId = cd.intItemId
					, @intFromPortId = cd.intLoadingPortId
					, @intToPortId = cd.intDestinationPortId
					, @intFromTermId = ch.intFreightTermId
					, @intToTermId = cd.intCostTermId
					, @dtmDate = ch.dtmContractDate
					, @intMarketZoneId = cd.intMarketZoneId
					, @intInvoiceCurrencyId = cd.intInvoiceCurrencyId
					, @intRateTypeId = cd.intRateTypeId
					, @intSequenceCurrencyId = cd.intCurrencyId
					, @dblTotalBudget = dblTotalBudget
					, @dblTotalCost = dblTotalCost
					, @intDetailPricingTypeId = cd.intPricingTypeId
				FROM tblCTContractDetail cd
				JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
				where cd.intContractDetailId = @intContractDetailId

				SELECT @intDefaultFreightId = intDefaultFreightItemId
					, @intDefaultInsuranceId = intDefaultInsuranceItemId
					, @ysnEnableBudgetForBasisPricing = ysnEnableBudgetForBasisPricing
					, @ysnUseCostCurrencyToFunctionalCurrencyRateInContractCost = ysnUseCostCurrencyToFunctionalCurrencyRateInContractCost
				FROM tblCTCompanyPreference

				INSERT INTO @CostItems
				EXEC uspCTGetFreightTermCost
					@intContractTypeId = @intContractTypeId
					, @intCommodityId = @intCommodityId
					, @intItemId = @intItemId
					, @intFromPortId = @intFromPortId
					, @intToPortId = @intToPortId
					, @intFromTermId = @intFromTermId
					, @intToTermId = @intToTermId
					, @dtmDate = @dtmDate
					, @intMarketZoneId = @intMarketZoneId
					, @intInvoiceCurrencyId = @intInvoiceCurrencyId
					, @intRateTypeId = @intRateTypeId
					, @ysnWarningMessage = 0
					, @intSequenceCurrencyId = @intSequenceCurrencyId

				IF EXISTS (SELECT TOP 1 1 FROM @CostItems)
				BEGIN
					UPDATE tblCTContractCost
					SET intItemUOMId = tblUpdate.intItemUOMId
						, dblFX = ISNULL(tblUpdate.dblFX,0)
						, dblRate = ISNULL(tblUpdate.dblRate,0)						
					FROM (
						SELECT cc.intContractCostId
							, ci.intItemUOMId
							, dblFX = case when @ysnUseCostCurrencyToFunctionalCurrencyRateInContractCost = 1 then cc.dblFX else ci.dblFX end
							, dblRate = CASE WHEN cc.intItemId = @intDefaultInsuranceId THEN 
												CASE WHEN @intDetailPricingTypeId = 2 AND @ysnEnableBudgetForBasisPricing = 1 THEN @dblTotalBudget * ci.dblAmount
													ELSE CASE WHEN ci.dblAmount <> 0 THEN @dblTotalCost * ci.dblAmount ELSE cc.dblRate END END
											ELSE ci.dblRate END
							, dblRemainingPercent = 100
							, dtmAccrualDate = CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME)
						FROM tblCTContractCost cc
						JOIN @CostItems ci ON ci.intCostItemId = cc.intItemId
						WHERE intContractDetailId = @intContractDetailId
					) tblUpdate WHERE tblUpdate.intContractCostId = tblCTContractCost.intContractCostId

				END
			END
		END

		IF EXISTS(SELECT TOP 1 1 FROM tblCTPriceFixation WHERE intContractDetailId = @intContractDetailId)
		BEGIN
			declare
				@dblSlicedFutures numeric(18,6)
				,@dblSlicedCashPrice numeric(18,6);
			
			SELECT @dblLotsFixed =  round(dblLotsFixed,(case when @intHeaderPricingTypeId in (2,8) then 6 else 2 end)), @dblSlicedFutures = dblFinalPrice - dblOriginalBasis, @dblSlicedCashPrice = dblFinalPrice FROM tblCTPriceFixation WHERE intContractDetailId = @intContractDetailId;
			
			select @dblNoOfLots=round(@dblNoOfLots,5),@dblLotsFixed=round(@dblLotsFixed,5);

			IF @dblNoOfLots > @dblLotsFixed AND @intPricingTypeId = 1
			BEGIN
				UPDATE	@CDTableUpdate
				SET		dblFutures			=	dblFutures,
						dblCashPrice		=	dblCashPrice,
						dblTotalCost		=	dblTotalCost,
						intPricingTypeId	=	CASE WHEN @intHeaderPricingTypeId= 8 THEN 8 ELSE intPricingTypeId END
				WHERE	intContractDetailId	=	@intContractDetailId
			END

			IF @dblNoOfLots = @dblLotsFixed AND @intPricingTypeId = 2
			BEGIN
				UPDATE	@CDTableUpdate
				SET		dblFutures			=	@dblSlicedFutures,
						dblCashPrice		=	@dblSlicedCashPrice,
						dblTotalCost		=	(dblQuantity * @dblSlicedCashPrice),
						intPricingTypeId	=	CASE WHEN @intHeaderPricingTypeId= 8 THEN 8 ELSE 1 END
				WHERE	intContractDetailId	=	@intContractDetailId
			END

		END

		IF @ysnPriceChanged = 1
		BEGIN
			EXEC	uspCTSequencePriceChanged @intContractDetailId,null,'Sequence',0
			UPDATE @CDTableUpdate SET ysnPriceChanged = 0 WHERE intContractDetailId = @intContractDetailId
		END
		
		IF @intPricingTypeId IN (2,8) AND @dblOriginalBasis IS NULL
		BEGIN
			UPDATE @CDTableUpdate SET dblOriginalBasis = dblBasis WHERE intContractDetailId = @intContractDetailId
		END

		IF @dblOriginalBasis IS NOT NULL AND  @dblBasis <> @dblOriginalBasis
		BEGIN
			UPDATE @CDTableUpdate SET dblOriginalBasis = @dblBasis WHERE intContractDetailId = @intContractDetailId;

			--DISABLE TRIGGER trgCTContractDetail ON tblCTContractDetail;
			--EXEC uspCTUpdateSequenceBasis @intContractDetailId,@dblBasis;
			--ENABLE TRIGGER trgCTContractDetail ON tblCTContractDetail;
		END

		IF @intPricingTypeId IN (1,2,8)
		BEGIN
			UPDATE	CD 
			SET		CD.dblConvertedBasis = dbo.fnCTConvertQtyToTargetItemUOM(CD.intPriceItemUOMId,CD.intBasisUOMId,CD.dblBasis) / 
					CASE	WHEN	CD.intCurrencyId = CD.intBasisCurrencyId THEN 1 
							WHEN	ISNULL(CY.ysnSubCurrency,0) = 1 THEN 0.01 
							ELSE	100
					END
			FROM	@CDTableUpdate CD
			JOIN	tblSMCurrency		CY	ON	CD.intCurrencyId	=	CY.intCurrencyID
			WHERE	CD.intContractDetailId	=	@intContractDetailId 
		END
		ELSE
		BEGIN
			UPDATE	@CDTableUpdate 
			SET		dblConvertedBasis	=	NULL
			WHERE	intContractDetailId	=	@intContractDetailId 
		END

		IF EXISTS(SELECT TOP 1 1 FROM tblCTContractCertification WHERE intContractDetailId = @intContractDetailId)
		BEGIN 
			SELECT	@strCertificationName = NULL
			SELECT	@strCertificationName = COALESCE(@strCertificationName + ', ', '') + CAST(strCertificationName AS NVARCHAR(100))
			FROM	tblCTContractCertification	CF
			JOIN	tblICCertification			IC	ON	IC.intCertificationId	=	CF.intCertificationId
			WHERE	intContractDetailId = @intContractDetailId

			UPDATE	@CDTableUpdate SET	strCertifications = @strCertificationName WHERE	intContractDetailId	= @intContractDetailId 
		END
		ELSE
		BEGIN
			UPDATE	@CDTableUpdate SET	strCertifications	=	NULL WHERE	intContractDetailId	=	@intContractDetailId 
		END

		UPDATE tblCTContractDetail
		SET intPricingTypeId = CD.intPricingTypeId
			, dblFutures = CD.dblFutures
			, dblCashPrice = CD.dblCashPrice
			, dblTotalCost = CD.dblTotalCost
			, intProducerId = CD.intProducerId
			, dblNetWeight = CD.dblNetWeight
			, dtmPlannedAvailabilityDate = CD.dtmPlannedAvailabilityDate
			, intFutureMonthId = CD.intFutureMonthId
			, dblOriginalQty = CD.dblOriginalQty
			, ysnPriceChanged = CD.ysnPriceChanged
			, dblOriginalBasis = CD.dblOriginalBasis
			, dblConvertedBasis = CD.dblConvertedBasis
			, strLCNumber = @strLCNumber
			, ysnApplyDefaultTradeFinance = 0
		FROM @CDTableUpdate CD
		WHERE CD.intContractDetailId = tblCTContractDetail.intContractDetailId

		EXEC uspLGUpdateLoadItem @intContractDetailId
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblCTContractDetail WITH (NOLOCK) WHERE intParentDetailId = @intContractDetailId AND ysnSlice = 1 ) OR (@ysnSlice <> 1)
		BEGIN
			DECLARE @previousQty NUMERIC(18, 6)
				, @previousLocation INT
				, @curQty NUMERIC(18, 6)
				, @curLocation INT

			SELECT TOP 1 @previousQty = dblQuantity
				, @previousLocation = intCompanyLocationId
			FROM tblCTSequenceHistory WITH (UPDLOCK)
			WHERE intContractDetailId = @intContractDetailId
			ORDER BY dtmHistoryCreated DESC

			SELECT TOP 1 @curQty = dblQuantity
				, @curLocation = intCompanyLocationId
			FROM tblCTContractDetail WITH (UPDLOCK) WHERE intContractDetailId = @intContractDetailId
			
			IF (@previousQty != @curQty OR @previousLocation != @curLocation)
			BEGIN
				EXEC uspLGUpdateCompanyLocation @intContractDetailId;
				-- Update Shipping Intruction Quantity
				DISABLE TRIGGER trgCTContractDetail ON tblCTContractDetail;
				
				UPDATE T SET dblShippingInstructionQty = T.dblQuantity 
				FROM tblCTContractDetail T 
				WHERE intContractDetailId = @intContractDetailId
				AND dblShippingInstructionQty > 0;

				ENABLE TRIGGER trgCTContractDetail ON tblCTContractDetail;
			END
		END
		UPDATE tblQMSample SET intLocationId = @intCompanyLocationId WHERE intContractDetailId = @intContractDetailId

		if (@ysnMultiplePriceFixation = 1)
		begin
			declare @intPriceContractId int;

			select top 1 @intPriceContractId = intPriceContractId from tblCTPriceFixationMultiplePrice where intContractDetailId = @intContractDetailId;
			
			exec uspCTProcessPriceFixationMultiplePrice
				@intPriceContractId = @intPriceContractId
				,@intUserId = @intLastModifiedById

		end
		else
		begin
			EXEC uspCTSplitSequencePricing @intContractDetailId, @intLastModifiedById
		end

		IF	@intContractStatusId	=	1	AND
			@ysnOnceApproved		=	1	AND
			@ysnFeedOnApproval		=	1	AND
			NOT EXISTS (SELECT TOP 1 1 FROM tblCTApprovedContract WHERE intContractHeaderId = @intContractHeaderId)
		BEGIN
			EXEC uspCTContractApproved	@intContractHeaderId, @intApproverId, @intContractDetailId, 1, 1
		END

		IF	@ysnBasisComponent = 1
		BEGIN
			if (@dblBasis = 0 AND NOT EXISTS(SELECT TOP 1 1 FROM tblCTContractCost WHERE ysnBasis = 1 AND intContractDetailId = @intContractDetailId))
			BEGIN
				INSERT	INTO tblCTContractCost(intConcurrencyId,intContractDetailId,intItemId,strCostMethod,intCurrencyId,dblRate,intItemUOMId,ysnBasis, ysnAccrue)
				SELECT	1 AS intConcurrencyId,@intContractDetailId,IM.intItemId,'Per Unit',@intCurrencyId,0 AS dblRate, IU.intItemUOMId, 1 AS ysnBasis, 0 AS ysnAccrue
				FROM	tblICItem		IM
				JOIN	tblICItemUOM	IU ON IU.intItemId = IM.intItemId AND IU.intUnitMeasureId = @intUnitMeasureId
				WHERE	ysnBasisContract = 1
			END
			else if (isnull(@dblBasis,0) <> 0)
			begin
				declare @dblCostsDifferential numeric(18,6);
				select @dblCostsDifferential = sum(dblRate) from tblCTContractCost where intContractDetailId = @intContractDetailId and ysnBasis = 1;
				if (isnull(@dblCostsDifferential,0) <> isnull(@dblBasis,0))
				begin
					select @ErrMsg = 'The sum of Amount('+convert(nvarchar(20),isnull(@dblCostsDifferential,0.00))+') does not match with the sequence Basis('+convert(nvarchar(20),isnull(@dblBasis,0.00))+').';
					RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
				end
			end
		END;

		IF @intContractStatusId IN (3,6)
		BEGIN
			EXEC uspCTCancelOpenLoadSchedule @intContractDetailId
		END

		SELECT @dblLotsFixed = NULL,@intPriceFixationId = NULL
		SELECT @dblLotsFixed = dblLotsFixed,@intPriceFixationId = intPriceFixationId FROM tblCTPriceFixation WHERE intContractDetailId = @intContractDetailId

		IF @dblLotsFixed IS NOT NULL AND @dblNoOfLots IS NOT NULL AND @dblNoOfLots < @dblLotsFixed
		BEGIN
			UPDATE tblCTPriceFixation SET dblLotsFixed = @dblNoOfLots WHERE intContractDetailId = @intContractDetailId
			SET @dblLotsFixed = @dblNoOfLots
		END
		
		IF	@dblLotsFixed IS NOT NULL AND @dblNoOfLots IS NOT NULL AND @dblNoOfLots = @dblLotsFixed AND
			EXISTS(SELECT TOP 1 1 FROM tblCTContractDetail WITH (UPDLOCK) WHERE intContractDetailId = @intContractDetailId AND intPricingTypeId IN (2,8))
		BEGIN
			UPDATE	tblCTPriceFixation SET dblTotalLots = @dblNoOfLots WHERE intPriceFixationId = @intPriceFixationId
			EXEC	[uspCTPriceFixationSave] @intPriceFixationId, '', @intLastModifiedById
		END		
		
		-- ADD DERIVATIVES
		EXEC uspCTManageDerivatives @intContractDetailId

		SELECT @intContractDetailId = MIN(intContractDetailId) FROM tblCTContractDetail WITH (UPDLOCK) WHERE intContractHeaderId = @intContractHeaderId AND intContractDetailId > @intContractDetailId
	END

	IF ISNULL(@ysnMultiplePriceFixation,0) = 0
	BEGIN
		UPDATE	PF
		SET		PF.[dblTotalLots] = (SELECT SUM(dblNoOfLots) FROM tblCTContractDetail WITH (UPDLOCK) WHERE intContractDetailId = CD.intContractDetailId)-- OR ISNULL(intSplitFromId,0) = CD.intContractDetailId)
		FROM	tblCTPriceFixation	PF
		JOIN	tblCTContractDetail CD ON CD.intContractDetailId = PF.intContractDetailId
		WHERE	CD.intContractHeaderId = @intContractHeaderId

		UPDATE b SET dblNoOfLots = (b.dblQuantity / (c.dblQuantity/c.dblNoOfLots))
		FROM tblCTPriceFixation a
		INNER JOIN tblCTPriceFixationDetail b ON a.intPriceFixationId =  b.intPriceFixationId
		INNER JOIN tblCTContractDetail c ON a.intContractDetailId = c.intContractDetailId
		--INNER JOIN vyuRKMarketDetail d ON c.intFutureMarketId = d.intFutureMarketId
		WHERE a.intContractHeaderId = @intContractHeaderId
	END
	ELSE
	BEGIN
		SELECT @dblLotsFixed = dblLotsFixed,@intPriceFixationId = intPriceFixationId FROM tblCTPriceFixation WITH (UPDLOCK) WHERE intContractHeaderId = @intContractHeaderId
		IF	@dblLotsFixed IS NOT NULL AND @dblHeaderNoOfLots IS NOT NULL AND @dblHeaderNoOfLots = @dblLotsFixed AND
			EXISTS(SELECT TOP 1 1 FROM tblCTContractDetail WITH (UPDLOCK) WHERE intContractHeaderId = @intContractHeaderId AND intPricingTypeId = 2)
		BEGIN
			UPDATE tblCTPriceFixation SET dblTotalLots = @dblHeaderNoOfLots WHERE intPriceFixationId = @intPriceFixationId
			EXEC	[uspCTPriceFixationSave] @intPriceFixationId, '', @intLastModifiedById
		END
		ELSE IF @dblLotsFixed IS NOT NULL AND @dblHeaderNoOfLots IS NOT NULL AND @dblHeaderNoOfLots <> @dblLotsFixed AND
			EXISTS(SELECT TOP 1 1 FROM tblCTContractDetail WITH (UPDLOCK) WHERE intContractHeaderId = @intContractHeaderId AND intPricingTypeId IN(1,2))
		BEGIN
			UPDATE tblCTPriceFixation SET dblTotalLots = @dblHeaderNoOfLots WHERE intPriceFixationId = @intPriceFixationId
		END		
	END

	EXEC uspCTUpdateAdditionalCost @intContractHeaderId

	IF EXISTS(SELECT TOP 1 1 FROM tblCTContractImport WITH (UPDLOCK) WHERE strContractNumber = @strContractNumber AND ysnImported = 0)
	BEGIN
		UPDATE	tblCTContractImport
		SET		ysnImported = 1,
				intContractHeaderId = @intContractHeaderId
		WHERE	strContractNumber = @strContractNumber AND ysnImported = 0
	END

	--Slice
	EXEC uspQMSampleContractSlice @intContractHeaderId

	EXEC uspLGLoadContractSlice @intContractHeaderId
	UPDATE tblCTContractDetail SET ysnSlice = NULL WHERE intContractHeaderId = @intContractHeaderId

	--Update Signature Date
	IF EXISTS(SELECT TOP 1 1 FROM tblCTContractHeader WITH (UPDLOCK) WHERE intContractHeaderId = @intContractHeaderId AND ysnSigned = 1 AND dtmSigned IS NULL)
	BEGIN
		UPDATE tblCTContractHeader SET dtmSigned = DATEADD(d, 0, DATEDIFF(d, 0, GETDATE())) WHERE intContractHeaderId = @intContractHeaderId		
	END

	EXEC	uspCTCreateDetailHistory		@intContractHeaderId 	= @intContractHeaderId,
											@strSource 				= 'Contract',
											@strProcess 			= 'Save Contract',
											@intUserId				= @userId	
	EXEC	uspCTInterCompanyContract		@intContractHeaderId

	-- Add Payables if Create Other Cost Payable on Save Contract set to true
	IF EXISTS(SELECT TOP 1 1 FROM tblCTCompanyPreference WHERE ysnCreateOtherCostPayable = 1)
	BEGIN
		--EXEC uspCTManagePayable @intContractHeaderId, 'header', 0, @userId
		select top 1 @strAddToPayableMessage = strMessage from dbo.fnCTGetVoucherPayable(@intContractHeaderId, 'header', 1, 0);
		if (isnull(@strAddToPayableMessage,'') <> '')
		begin
			RAISERROR (@strAddToPayableMessage,18,1,'WITH NOWAIT')   
		end
		else
		begin
			EXEC uspCTManagePayable @intContractHeaderId, 'header', 0, @userId  
		end
	END

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
GO
