CREATE PROCEDURE [dbo].[uspCTDoPrice]
	@XML varchar(max)
AS
BEGIN TRY

	DECLARE @ErrMsg					NVARCHAR(MAX),
			@idoc					INT,
			@ContractDetailId		INT,
			@ConcurrencyId			INT,
			@StartDate				DATETIME,
			@EndDate				DATETIME,
			@dblQtyToPrice			DECIMAL(12,4),
			@Futures				DECIMAL(12,4),
			@Basis					DECIMAL(12,4),
			@FutureMarketId			INT,
			@intFutureMonthId		INT,
			@ContractOptHeaderId	INT,
			@CurrentQty				DECIMAL(12,4),
			@ContractSeq			INT,
	        @NewContractDetailId	INT, 
	        @intPricingType			INT
			          
	EXEC sp_xml_preparedocument @idoc OUTPUT, @XML 
	
	SELECT	
			@ContractDetailId		=	intContractDetailId,
			@ConcurrencyId			=	intConcurrencyId,
			@StartDate				=	dtmStartDate,
			@EndDate				=	dtmEndDate,
			@dblQtyToPrice			=	dblQtyToPrice,
			@Futures				=	dblFutures,
			@Basis					=	dblBasis,
			@FutureMarketId			=	intFutureMarketId,
			@intFutureMonthId		=	intFutureMonthId,
			@ContractOptHeaderId	=	intContractOptHeaderId
			
	FROM	OPENXML(@idoc, 'root',2)
	WITH
	(
			intContractDetailId		INT,
			intConcurrencyId		INT,
			dtmStartDate			DATETIME,
			dtmEndDate				DATETIME,
			dblQtyToPrice			DECIMAL(12,4),
			dblFutures				DECIMAL(12,4),
			dblBasis				DECIMAL(12,4),
			intFutureMarketId		INT,
			intFutureMonthId		INT,
			intContractOptHeaderId	INT
	)  
	  
	IF NOT EXISTS(SELECT * FROM tblCTContractDetail WHERE intContractDetailId = @ContractDetailId)
	BEGIN
		RAISERROR('This sequence has been deleted by other user.',16,1)
	END
	IF (SELECT intConcurrencyId FROM tblCTContractDetail WHERE intContractDetailId = @ContractDetailId) <> @ConcurrencyId
	BEGIN
		RAISERROR('This sequence has been modified by other user.',16,1)
	END
	
	SELECT @CurrentQty = dblQuantity FROM tblCTContractDetail WHERE intContractDetailId = @ContractDetailId 
	
	SELECT	@ContractSeq = MAX(intContractSeq) + 1 
	FROM	tblCTContractDetail 
	WHERE	intContractHeaderId = 
			(	
				SELECT intContractHeaderId 
				FROM tblCTContractDetail 
				WHERE intContractDetailId = @ContractDetailId
			)
	
	IF	@Futures IS NOT NULL AND @Basis IS NOT NULL
		SET @intPricingType = 1
	ELSE IF	(@Futures IS NULL)
		SET @intPricingType = 2
	ELSE IF	(@Basis IS NULL)
		SET @intPricingType = 3

	IF	@CurrentQty <> @dblQtyToPrice
	BEGIN
		INSERT	INTO tblCTContractDetail
		(
				intConcurrencyId,		intContractHeaderId,	intContractSeq,			intCompanyLocationId,
				dtmStartDate,			intItemId,				dtmEndDate,				intFreightTermId,
				intShipViaId,			dblQuantity,			intUnitMeasureId,		intPricingTypeId,
				dblFutures,				dblBasis,				intFutureMarketId,		intFutureMonthId,
				dblCashPrice,			intCurrencyId,			dblRate,				
				intMarketZoneId,		intDiscountTypeId,		intDiscountId,			intContractOptHeaderId,
				strBuyerSeller,			intBillTo,				intFreightRateId,		strFobBasis,
				intRailGradeId,			strRemark,				dblOriginalQty,			dblBalance,
				dblIntransitQty,		dblScheduleQty,						intLoadingPortId,
				intDestinationPortId,	strShippingTerm,		intShippingLineId,		strVessel,
				intDestinationCityId,	intShipperId
		)
		SELECT 
				1,						intContractHeaderId,	@ContractSeq,			intCompanyLocationId,
				dtmStartDate,			intItemId,				dtmEndDate,				intFreightTermId,
				intShipViaId,			@CurrentQty-@dblQtyToPrice,	intUnitMeasureId,		intPricingTypeId,
				dblFutures,				dblBasis,				intFutureMarketId,		intFutureMonthId,
				dblCashPrice,			intCurrencyId,			dblRate,				
				intMarketZoneId,		intDiscountTypeId,		intDiscountId,			intContractOptHeaderId,
				strBuyerSeller,			intBillTo,				intFreightRateId,		strFobBasis,
				intRailGradeId,			strRemark,				dblOriginalQty,			dblBalance,
				dblIntransitQty,		dblScheduleQty,						intLoadingPortId,
				intDestinationPortId,	strShippingTerm,		intShippingLineId,		strVessel,
				intDestinationCityId,	intShipperId

		FROM	tblCTContractDetail 
		WHERE	intContractDetailId = @ContractDetailId
		
		SELECT	@NewContractDetailId = SCOPE_IDENTITY()
		
		INSERT INTO tblCTContractCost
		(
				intConcurrencyId,	intContractDetailId,	intItemId,			intVendorId,	
				strCostMethod,		dblRate,				intItemUOMId,			
				ysnAccrue,			ysnMTM,					ysnPrice
		)
		SELECT 
				1,					@NewContractDetailId,	intItemId,			intVendorId,	
				strCostMethod,		dblRate,				intItemUOMId,			
				ysnAccrue,			ysnMTM,					ysnPrice				
		FROM	tblCTContractCost 
		WHERE	intContractDetailId = @ContractDetailId
		
		INSERT INTO tblCTContractOption
		(
				intConcurrencyId,	intContractDetailId,	intBuySellId,			intPutCallId,	dblStrike,
				dblPremium,			dblServiceFee,			dtmExpiration,			dblTargetPrice,	intPremFeeId
		)
		SELECT 
				intConcurrencyId,	@NewContractDetailId,	intBuySellId,			intPutCallId,	dblStrike,
				dblPremium,			dblServiceFee,			dtmExpiration,			dblTargetPrice,	intPremFeeId				
		FROM	tblCTContractOption 
		WHERE	intContractDetailId = @ContractDetailId
		
		UPDATE	tblCTContractDetail
		SET		dblQuantity				=	@dblQtyToPrice,
				dblFutures				=	@Futures,
				dblBasis				=	@Basis,
				dblCashPrice			=	@Futures + @Basis,
				intFutureMarketId		=	@FutureMarketId	,
				intFutureMonthId		=	@intFutureMonthId	,
				intContractOptHeaderId	=	@ContractOptHeaderId,
				intConcurrencyId		=	intConcurrencyId + 1,
				intPricingTypeId		=	@intPricingType	,
				dtmStartDate			=	@StartDate,
				dtmEndDate				=	@EndDate
		WHERE	intContractDetailId		=	@ContractDetailId
		
	END
	ELSE
	BEGIN
		UPDATE	tblCTContractDetail
		SET		dblFutures				=	@Futures,
				dblBasis				=	@Basis,
				dblCashPrice			=	@Futures + @Basis,
				intFutureMarketId		=	@FutureMarketId	,
				intFutureMonthId		=	@intFutureMonthId,
				intContractOptHeaderId	=	@ContractOptHeaderId,
				intConcurrencyId		=	intConcurrencyId + 1,
				intPricingTypeId		=	@intPricingType		,
				dtmStartDate			=	@StartDate,
				dtmEndDate				=	@EndDate
		WHERE	intContractDetailId		=	@ContractDetailId
	END
	
END TRY      
BEGIN CATCH       
	SET @ErrMsg = ERROR_MESSAGE()      
	IF @idoc <> 0 EXEC sp_xml_removedocument @idoc      
	RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')      
END CATCH
