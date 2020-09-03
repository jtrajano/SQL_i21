CREATE PROCEDURE [dbo].[uspCTProcessContractDetail]

	@contractDetails AS ContractDetail READONLY

AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

	---------------------------------------------------------------------------------------------------
	--------------------------  U P D A T E  C O N T R A C T  D E T A I L S  --------------------------
	---------------------------------------------------------------------------------------------------

	MERGE tblCTContractDetail _target
		USING @contractDetails _source
	ON (_source.intContractDetailId = _target.intContractDetailId)
	WHEN MATCHED
		THEN UPDATE SET 
		_target.intSplitFromId			=	_source.intSplitFromId
		,_target.intParentDetailId		=	_source.intParentDetailId
		,_target.ysnSlice				=	_source.ysnSlice
		,_target.intConcurrencyId		=	_source.intConcurrencyId
		,_target.intContractHeaderId	=	_source.intContractHeaderId
		,_target.intContractStatusId	=	_source.intContractStatusId
		,_target.strFinancialStatus		=	_source.strFinancialStatus
		,_target.intContractSeq			=	_source.intContractSeq
		,_target.intCompanyLocationId	=	_source.intCompanyLocationId
		,_target.intShipToId			=	_source.intShipToId
		,_target.dtmStartDate			=	_source.dtmStartDate
		,_target.dtmEndDate				=	_source.dtmEndDate
		,_target.intFreightTermId		=	_source.intFreightTermId
		,_target.intShipViaId			=	_source.intShipViaId
		,_target.intItemContractId		=	_source.intItemContractId
		,_target.intItemBundleId		=	_source.intItemBundleId
		,_target.intItemId				=	_source.intItemId
		,_target.strItemSpecification	=	_source.strItemSpecification
		,_target.intCategoryId			=	_source.intCategoryId
		,_target.dblQuantity			=	_source.dblQuantity
		,_target.intItemUOMId			=	_source.intItemUOMId
		,_target.dblOriginalQty			=	_source.dblOriginalQty
		,_target.dblBalance				=	_source.dblBalance
		,_target.dblIntransitQty		=	_source.dblIntransitQty
		,_target.dblScheduleQty			=	_source.dblScheduleQty
		,_target.dblBalanceLoad			=	_source.dblBalanceLoad
		,_target.dblScheduleLoad		=	_source.dblScheduleLoad
		,_target.dblShippingInstructionQty	=	_source.dblShippingInstructionQty
		,_target.dblNetWeight			=	_source.dblNetWeight
		,_target.intNetWeightUOMId		=	_source.intNetWeightUOMId
		,_target.intUnitMeasureId		=	_source.intUnitMeasureId
		,_target.intCategoryUOMId		=	_source.intCategoryUOMId
		,_target.intNoOfLoad			=	_source.intNoOfLoad
		,_target.dblQuantityPerLoad		=	_source.dblQuantityPerLoad
		,_target.intIndexId				=	_source.intIndexId
		,_target.dblAdjustment			=	_source.dblAdjustment
		,_target.intAdjItemUOMId		=	_source.intAdjItemUOMId
		,_target.intPricingTypeId		=	_source.intPricingTypeId
		,_target.intFutureMarketId		=	_source.intFutureMarketId
		,_target.intFutureMonthId		=	_source.intFutureMonthId
		,_target.dblFutures				=	_source.dblFutures
		,_target.dblBasis				=	_source.dblBasis
		,_target.dblOriginalBasis		=	_source.dblOriginalBasis
		,_target.dblConvertedBasis		=	_source.dblConvertedBasis
		,_target.intBasisCurrencyId		=	_source.intBasisCurrencyId
		,_target.intBasisUOMId			=	_source.intBasisUOMId
		,_target.dblFreightBasisBase		=	_source.dblFreightBasisBase
		,_target.intFreightBasisBaseUOMId	=	_source.intFreightBasisBaseUOMId
		,_target.dblFreightBasis			=	_source.dblFreightBasis
		,_target.intFreightBasisUOMId	=	_source.intFreightBasisUOMId
		,_target.dblRatio				=	_source.dblRatio
		,_target.dblCashPrice			=	_source.dblCashPrice
		,_target.dblTotalCost			=	_source.dblTotalCost
		,_target.intCurrencyId			=	_source.intCurrencyId
		,_target.intPriceItemUOMId		=	_source.intPriceItemUOMId
		,_target.dblNoOfLots			=	_source.dblNoOfLots
		,_target.dtmLCDate				=	_source.dtmLCDate
		,_target.dtmLastPricingDate		=	_source.dtmLastPricingDate
		,_target.dblConvertedPrice		=	_source.dblConvertedPrice
		,_target.intConvPriceCurrencyId	=	_source.intConvPriceCurrencyId
		,_target.intConvPriceUOMId		=	_source.intConvPriceUOMId
		,_target.intMarketZoneId		=	_source.intMarketZoneId
		,_target.intDiscountTypeId		=	_source.intDiscountTypeId
		,_target.intDiscountId			=	_source.intDiscountId
		,_target.intDiscountScheduleId	=	_source.intDiscountScheduleId
		,_target.intDiscountScheduleCodeId	=	_source.intDiscountScheduleCodeId
		,_target.intStorageScheduleRuleId	=	_source.intStorageScheduleRuleId
		,_target.intContractOptHeaderId	=	_source.intContractOptHeaderId
		,_target.strBuyerSeller			=	_source.strBuyerSeller
		,_target.intBillTo				=	_source.intBillTo
		,_target.intFreightRateId		=	_source.intFreightRateId
		,_target.strFobBasis			=	_source.strFobBasis
		,_target.intRailGradeId			=	_source.intRailGradeId
		,_target.strRailRemark			=	_source.strRailRemark
		,_target.strLoadingPointType	=	_source.strLoadingPointType
		,_target.intLoadingPortId		=	_source.intLoadingPortId
		,_target.strDestinationPointType	=	_source.strDestinationPointType
		,_target.intDestinationPortId	=	_source.intDestinationPortId
		,_target.strShippingTerm			=	_source.strShippingTerm
		,_target.intShippingLineId		=	_source.intShippingLineId
		,_target.strVessel				=	_source.strVessel
		,_target.intDestinationCityId	=	_source.intDestinationCityId
		,_target.intShipperId			=	_source.intShipperId
		,_target.strRemark				=	_source.strRemark
		,_target.intSubLocationId		=	_source.intSubLocationId
		,_target.intStorageLocationId	=	_source.intStorageLocationId
		,_target.intPurchasingGroupId	=	_source.intPurchasingGroupId
		,_target.intFarmFieldId			=	_source.intFarmFieldId
		,_target.intSplitId				=	_source.intSplitId
		,_target.strGrade				=	_source.strGrade
		,_target.strGarden				=	_source.strGarden
		,_target.strVendorLotID			=	_source.strVendorLotID
		,_target.strInvoiceNo			=	_source.strInvoiceNo
		,_target.strReference			=	_source.strReference
		,_target.strERPPONumber			=	_source.strERPPONumber
		,_target.strERPItemNumber		=	_source.strERPItemNumber
		,_target.strERPBatchNumber		=	_source.strERPBatchNumber
		,_target.intUnitsPerLayer		=	_source.intUnitsPerLayer
		,_target.intLayersPerPallet		=	_source.intLayersPerPallet
		,_target.dtmEventStartDate		=	_source.dtmEventStartDate
		,_target.dtmPlannedAvailabilityDate	=	_source.dtmPlannedAvailabilityDate
		,_target.dtmUpdatedAvailabilityDate	=	_source.dtmUpdatedAvailabilityDate
		,_target.dtmM2MDate				=	_source.dtmM2MDate
		,_target.intBookId				=	_source.intBookId
		,_target.intSubBookId			=	_source.intSubBookId
		,_target.intContainerTypeId		=	_source.intContainerTypeId
		,_target.intNumberOfContainers	=	_source.intNumberOfContainers
		,_target.intInvoiceCurrencyId	=	_source.intInvoiceCurrencyId
		,_target.dtmFXValidFrom			=	_source.dtmFXValidFrom
		,_target.dtmFXValidTo			=	_source.dtmFXValidTo
		,_target.dblRate				=	_source.dblRate
		,_target.dblFXPrice				=	_source.dblFXPrice
		,_target.ysnUseFXPrice			=	_source.ysnUseFXPrice
		,_target.intFXPriceUOMId		=	_source.intFXPriceUOMId
		,_target.strFXRemarks			=	_source.strFXRemarks
		,_target.dblAssumedFX			=	_source.dblAssumedFX
		,_target.strFixationBy			=	_source.strFixationBy
		,_target.strPackingDescription	=	_source.strPackingDescription
		,_target.dblYield				=	_source.dblYield
		,_target.intCurrencyExchangeRateId	=	_source.intCurrencyExchangeRateId
		,_target.intRateTypeId			=	_source.intRateTypeId
		,_target.intCreatedById			=	_source.intCreatedById
		,_target.dtmCreated				=	_source.dtmCreated
		,_target.intLastModifiedById	=	_source.intLastModifiedById
		,_target.dtmLastModified		=	_source.dtmLastModified
		,_target.ysnInvoice				=	_source.ysnInvoice
		,_target.ysnProvisionalInvoice	=	_source.ysnProvisionalInvoice
		,_target.ysnQuantityFinal		=	_source.ysnQuantityFinal
		,_target.intProducerId			=	_source.intProducerId
		,_target.ysnClaimsToProducer	=	_source.ysnClaimsToProducer
		,_target.ysnRiskToProducer		=	_source.ysnRiskToProducer
		,_target.ysnBackToBack			=	_source.ysnBackToBack
		,_target.dblAllocatedQty		=	_source.dblAllocatedQty
		,_target.dblReservedQty			=	_source.dblReservedQty
		,_target.dblAllocationAdjQty	=	_source.dblAllocationAdjQty
		,_target.dblInvoicedQty			=	_source.dblInvoicedQty
		,_target.ysnPriceChanged		=	_source.ysnPriceChanged
		,_target.intContractDetailRefId	=	_source.intContractDetailRefId
		,_target.ysnStockSale			=	_source.ysnStockSale
		,_target.strCertifications		=	_source.strCertifications
		,_target.ysnSplit				=	_source.ysnSplit
		,_target.ysnProvisionalPNL		=	_source.ysnProvisionalPNL
		,_target.ysnFinalPNL			=	_source.ysnFinalPNL
		,_target.dtmProvisionalPNL		=	_source.dtmProvisionalPNL
		,_target.dtmFinalPNL			=	_source.dtmFinalPNL
		,_target.intPricingStatus		=	_source.intPricingStatus
		,_target.dtmStartDateUTC		=	_source.dtmStartDateUTC;


	---------------------------------------------------------------------------------------------------
	------- UPDATE CONTRACT DETAIL'S PRICING STATUS  --------------------------------------------------
	---------------------------------------------------------------------------------------------------
	------- UPDATE PRICE FIXATION DETAIL'S NUMBER QTY APPLIED & PRICED AND LOAD APPLIED & PRICED ------
	---------------------------------------------------------------------------------------------------

	DECLARE @_cdActiveContractDetailId		INT = 0,
			@_cdPricingTypeId				INT = 0,
			@_cdSequenceQuantity			NUMERIC(18,6) = 0.00,
			@_cdPricingStatus				INT = 0,
			@_cdPricedQuantity				NUMERIC(18,6) = 0.00,
			@_cdActiveId					INT = 0,
			@_cdCommulativeAppliedAndPrice	NUMERIC(18,6) = 0,
			@_cdActivelAppliedQuantity		NUMERIC(18,6),
			@_cdRemainingAppliedQuantity	NUMERIC(18,6) = 0,
			@_cdLoad						BIT,
			@ErrMsg							NVARCHAR(MAX);

	SELECT @_cdActiveContractDetailId = intContractDetailId, @_cdPricingTypeId = intPricingTypeId, @_cdSequenceQuantity = dblQuantity FROM @contractDetails

	IF (@_cdPricingTypeId = 1)
	BEGIN
		SET @_cdPricingStatus = 2
	END
	ELSE
	BEGIN
		SELECT @_cdPricedQuantity = ISNULL(SUM(pfd.dblQuantity),0.00) FROM tblCTPriceFixation pf, tblCTPriceFixationDetail pfd WHERE pf.intContractDetailId = @_cdActiveContractDetailId AND pfd.intPriceFixationId = pf.intPriceFixationId
		
		IF (@_cdPricedQuantity = 0)
		BEGIN
			SET @_cdPricingStatus = 0
		END
		ELSE
		BEGIN
			IF (@_cdSequenceQuantity > @_cdPricedQuantity)
			BEGIN
				SET @_cdPricingStatus = 1
			END
			ELSE
			BEGIN
				SET @_cdPricingStatus = 2
			END
		END
	END

	UPDATE tblCTContractDetail SET intPricingStatus = @_cdPricingStatus WHERE intContractDetailId = @_cdActiveContractDetailId

	DECLARE @Pricing TABLE 
	(
		intId							INT
		,intContractHeaderId			INT
		,ysnLoad						BIT
		,intContractDetailId			INT
		,dblSequenceQuantity			NUMERIC(18,6)
		,dblBalance						NUMERIC(18,6)
		,dblAppliedQuantity				NUMERIC(18,6)
		,intNoOfLoad					INT NULL
		,dblBalanceLoad					NUMERIC(18,6)
		,dblAppliedLoad					NUMERIC(18,6)
		,intPriceFixationId				INT
		,intPriceFixationDetailId		INT
		,intPricingNumber				INT
		,intNumber						INT
		,dblPricedQuantity				NUMERIC(18,6)
		,dblQuantityAppliedAndPriced	NUMERIC(18,6)
		,dblLoadPriced					NUMERIC(18,6)
		,dblLoadAppliedAndPriced		NUMERIC(18,6)
		,dblCorrectAppliedAndPriced		NUMERIC(18,6) NULL
	)

	INSERT INTO @Pricing
	SELECT
		intId = convert(INT,ROW_NUMBER() OVER (ORDER BY pfd.intPriceFixationDetailId))
		,ch.intContractHeaderId
		,ch.ysnLoad
		,cd.intContractDetailId
		,dblSequenceQuantity = cd.dblQuantity
		,cd.dblBalance
		,dblAppliedQuantity = cd.dblQuantity - cd.dblBalance
		,cd.intNoOfLoad
		,cd.dblBalanceLoad
		,dblAppliedLoad = cd.intNoOfLoad - cd.dblBalanceLoad
		,pf.intPriceFixationId
		,pfd.intPriceFixationDetailId
		,intPricingNumber = ROW_NUMBER() OVER (PARTITION BY pf.intPriceFixationId ORDER BY pfd.intPriceFixationDetailId)
		,pfd.intNumber
		,dblPricedQuantity = ISNULL(invoiced.dblQtyShipped, pfd.dblQuantity)
		,pfd.dblQuantityAppliedAndPriced
		,pfd.dblLoadPriced
		,pfd.dblLoadAppliedAndPriced
		,dblCorrectAppliedAndPriced = NULL
	FROM tblCTPriceFixation pf
	JOIN tblCTPriceFixationDetail pfd ON pfd.intPriceFixationId = pf.intPriceFixationId
	JOIN tblCTContractDetail cd ON cd.intContractDetailId = pf.intContractDetailId
	JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
	LEFT JOIN 
	(
		SELECT 
			ar.intPriceFixationDetailId, dblQtyShipped = SUM(di.dblQtyShipped)
		FROM
			tblCTPriceFixationDetailAPAR ar
			JOIN tblARInvoiceDetail di ON di.intInvoiceDetailId = ar.intInvoiceDetailId
		GROUP BY
			ar.intPriceFixationDetailId
	) invoiced ON invoiced.intPriceFixationDetailId = pfd.intPriceFixationDetailId
	WHERE pf.intContractDetailId = @_cdActiveContractDetailId
	ORDER BY pfd.intPriceFixationDetailId

	SELECT @_cdActiveId = MIN(intId) FROM @Pricing
	WHILE (@_cdActiveId IS NOT NULL)
	BEGIN
		SELECT
			@_cdActivelAppliedQuantity = (CASE WHEN ysnLoad = 1 THEN dblAppliedLoad ELSE dblAppliedQuantity END)
			,@_cdPricedQuantity = (CASE WHEN ysnLoad = 1 THEN dblLoadPriced ELSE dblPricedQuantity END)
			,@_cdLoad = ISNULL(ysnLoad,0)
		FROM
			@Pricing
		WHERE
			intId = @_cdActiveId

		SET @_cdCommulativeAppliedAndPrice += @_cdPricedQuantity
		IF (@_cdRemainingAppliedQuantity = 0)
		BEGIN
			SET @_cdRemainingAppliedQuantity = @_cdActivelAppliedQuantity
		END

		IF (@_cdCommulativeAppliedAndPrice < @_cdActivelAppliedQuantity)
		BEGIN
			UPDATE @Pricing
			SET dblCorrectAppliedAndPriced = @_cdPricedQuantity
			WHERE intId = @_cdActiveId

			SET @_cdRemainingAppliedQuantity -= @_cdPricedQuantity
		END
		ELSE
		BEGIN
			UPDATE @Pricing
			SET dblCorrectAppliedAndPriced = @_cdRemainingAppliedQuantity
			WHERE intId = @_cdActiveId

			SET @_cdRemainingAppliedQuantity -= @_cdRemainingAppliedQuantity
		END

		SELECT @_cdActiveId = MIN(intId) FROM @Pricing WHERE intId > @_cdActiveId
	END

	UPDATE
		b
	SET
		b.intNumber = (CASE WHEN b.intNumber <> a.intPricingNumber THEN a.intPricingNumber ELSE b.intNumber END)
		,b.dblQuantityAppliedAndPriced = (CASE WHEN b.dblQuantityAppliedAndPriced <> a.dblCorrectAppliedAndPriced THEN a.dblCorrectAppliedAndPriced ELSE b.dblQuantityAppliedAndPriced END)
		,b.dblLoadAppliedAndPriced = (CASE WHEN @_cdLoad = 1 THEN a.dblCorrectAppliedAndPriced ELSE NULL END)
	FROM
		@Pricing a
		,tblCTPriceFixationDetail b
	WHERE
		(
			a.intNumber <> a.intPricingNumber
			OR a.dblCorrectAppliedAndPriced <> 
			(
				CASE
				WHEN a.ysnLoad = 1
				THEN a.dblLoadAppliedAndPriced
				ELSE a.dblQuantityAppliedAndPriced
				END
			)
		)
		AND b.intPriceFixationDetailId = a.intPriceFixationDetailId	

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT') 

END CATCH