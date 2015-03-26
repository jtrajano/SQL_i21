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
			@Quantity				DECIMAL(12,4),
			@Futures				DECIMAL(12,4),
			@Basis					DECIMAL(12,4),
			@FutureMarketId			INT,
			@FuturesMonth			NVARCHAR(50),
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
			@Quantity				=	dblQuantity,
			@Futures				=	dblFutures,
			@Basis					=	dblBasis,
			@FutureMarketId			=	intFutureMarketId,
			@FuturesMonth			=	strFuturesMonth,
			@ContractOptHeaderId	=	intContractOptHeaderId
			
	FROM	OPENXML(@idoc, 'root',2)
	WITH
	(
			intContractDetailId		INT,
			intConcurrencyId		INT,
			dtmStartDate			DATETIME,
			dtmEndDate				DATETIME,
			dblQuantity				DECIMAL(12,4),
			dblFutures				DECIMAL(12,4),
			dblBasis				DECIMAL(12,4),
			intFutureMarketId		INT,
			strFuturesMonth			NVARCHAR(50),
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
	
	IF	(ISNULL(@Futures,0) > 0 AND ISNULL(@Basis,0) > 0)
		SET @intPricingType = 1
	ELSE IF	(@Futures IS NULL)
		SET @intPricingType = 2
	ELSE IF	(@Basis IS NULL)
		SET @intPricingType = 3

	IF	@CurrentQty <> @Quantity
	BEGIN
		INSERT	INTO tblCTContractDetail
		(
				intConcurrencyId,	intContractHeaderId,	intContractSeq,			intCompanyLocationId,
				dtmStartDate,		intItemId,				dtmEndDate,				intFreightTermId,
				intShipViaId,		dblQuantity,			intUnitMeasureId,		intPricingType,
				dblFutures,			dblBasis,				intFutureMarketId,		strFuturesMonth,
				dblCashPrice,		intCurrencyId,			dblRate,				strCurrencyReference,
				intMarketZoneId,	intDiscountType,		intDiscountId,			intContractOptHeaderId,
				strBuyerSeller,		intBillTo,				intFreightRateId,		strFobBasis,
				intGrade,			strRemark,				dblOriginalQty,			dblBalance,
				dblIntransitQty,	dblScheduleQty
		)
		SELECT 
				1,					intContractHeaderId,	@ContractSeq,			intCompanyLocationId,
				dtmStartDate,		intItemId,				dtmEndDate,				intFreightTermId,
				intShipViaId,		@CurrentQty-@Quantity,	intUnitMeasureId,		intPricingType,
				dblFutures,			dblBasis,				intFutureMarketId,		strFuturesMonth,
				dblCashPrice,		intCurrencyId,			dblRate,				strCurrencyReference,
				intMarketZoneId,	intDiscountType,		intDiscountId,			intContractOptHeaderId,
				strBuyerSeller,		intBillTo,				intFreightRateId,		strFobBasis,
				intGrade,			strRemark,				dblOriginalQty,			dblBalance,
				dblIntransitQty,	dblScheduleQty
		FROM	tblCTContractDetail 
		WHERE	intContractDetailId = @ContractDetailId
		
		SELECT	@NewContractDetailId = SCOPE_IDENTITY()
		
		INSERT INTO tblCTContractCost
		(
				intConcurrencyId,	intContractDetailId,	intCostTypeId,			intVendorId,	
				intCostMethod,		dblRate,				intUnitMeasureId,		intCurrencyId,	
				ysnAccrue,			ysnMTM,					ysnPrice
		)
		SELECT 
				1,					@NewContractDetailId,	intCostTypeId,			intVendorId,	
				intCostMethod,		dblRate,				intUnitMeasureId,		intCurrencyId,	
				ysnAccrue,			ysnMTM,					ysnPrice				
		FROM	tblCTContractCost 
		WHERE	intContractDetailId = @ContractDetailId
		
		INSERT INTO tblCTContractOption
		(
				intConcurrencyId,	intContractDetailId,	intBuySell,				intPutCall,		dblStrike,
				dblPremium,			dblServiceFee,			dtmExpiration,			dblTargetPrice,	intPremFee
		)
		SELECT 
				intConcurrencyId,	@NewContractDetailId,	intBuySell,				intPutCall,		dblStrike,
				dblPremium,			dblServiceFee,			dtmExpiration,			dblTargetPrice,	intPremFee				
		FROM	tblCTContractOption 
		WHERE	intContractDetailId = @ContractDetailId
		
		UPDATE	tblCTContractDetail
		SET		dblQuantity				=	@Quantity,
				dblFutures				=	@Futures,
				dblBasis				=	@Basis,
				dblCashPrice			=	@Futures + @Basis,
				intFutureMarketId		=	@FutureMarketId	,
				strFuturesMonth			=	@FuturesMonth	,
				intContractOptHeaderId	=	@ContractOptHeaderId,
				intConcurrencyId		=	intConcurrencyId + 1,
				intPricingType			=	@intPricingType	
		WHERE	intContractDetailId		=	@ContractDetailId
		
	END
	ELSE
	BEGIN
		UPDATE	tblCTContractDetail
		SET		dblFutures				=	@Futures,
				dblBasis				=	@Basis,
				dblCashPrice			=	@Futures + @Basis,
				intFutureMarketId		=	@FutureMarketId	,
				strFuturesMonth			=	@FuturesMonth	,
				intContractOptHeaderId	=	@ContractOptHeaderId,
				intConcurrencyId		=	intConcurrencyId + 1,
				intPricingType			=	@intPricingType	
		WHERE	intContractDetailId		=	@ContractDetailId
	END
	
END TRY      
BEGIN CATCH       
 SET @ErrMsg = ERROR_MESSAGE()      
 IF @idoc <> 0 EXEC sp_xml_removedocument @idoc      
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')      
END CATCH
