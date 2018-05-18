CREATE FUNCTION [dbo].[fnARGetContractPricingDetails]
(
	 @ItemId				INT
	,@CustomerId			INT	
	,@LocationId			INT
	,@ItemUOMId				INT
	,@CurrencyId			INT
	,@TransactionDate		DATETIME
	,@Quantity				NUMERIC(18,6)
	,@ContractHeaderId		INT
	,@ContractDetailId		INT
	,@OriginalQuantity		NUMERIC(18,6)
	,@AllowQtyToExceed		BIT
)
RETURNS @returntable TABLE
(
	 dblPrice							NUMERIC(18,6)
	,dblUnitPrice						NUMERIC(18,6)
	,strPricing							NVARCHAR(250)
	,intCurrencyExchangeRateTypeId		INT
    ,strCurrencyExchangeRateType		NVARCHAR(20)
    ,dblCurrencyExchangeRate			NUMERIC(18,6)
	,intSubCurrencyId					INT
	,dblSubCurrencyRate					NUMERIC(18,6)
	,strSubCurrency						NVARCHAR(40)
	,intContractHeaderId				INT
	,intContractDetailId				INT
	,strContractNumber					NVARCHAR(50)
	,intContractSeq						INT
	,intContractUOMId					INT
	,strContractUOM						NVARCHAR(50)
	,intPriceUOMId						INT
	,strPriceUOM						NVARCHAR(50)
	,dblPriceUOMQuantity				NUMERIC(18,6)
	,dblQuantity						NUMERIC(18,6)
	,dblAvailableQty					NUMERIC(18,6)
	,ysnUnlimitedQty					BIT
	,strPricingType						NVARCHAR(50)
	,intTermId							INT
	,ysnMaxPrice						BIT
	,intCompanyLocationPricingLevelId	INT NULL
)
AS
BEGIN

DECLARE	 @Price							NUMERIC(18,6)
		,@UnitPrice						NUMERIC(18,6)
		,@Pricing						NVARCHAR(250)
		,@ContractNumber				NVARCHAR(50)
		,@ContractSeq					INT
		,@AvailableQuantity				NUMERIC(18,6)
		,@PriceUOMQuantity				NUMERIC(18,6)
		,@UnlimitedQuantity				BIT
		,@PricingType					NVARCHAR(50)
		,@CurrencyExchangeRateTypeId	INT
        ,@CurrencyExchangeRateType		NVARCHAR(20)
        ,@CurrencyExchangeRate			NUMERIC(18,6)
		,@SubCurrencyRate				NUMERIC(18,6)
		,@SubCurrency					NVARCHAR(40)
		,@ContractUOMId					INT
		,@ContractUOM					NVARCHAR(50)
		,@PriceUOMId					INT
		,@PriceUOM						NVARCHAR(50)
		,@termId						INT
		,@LimitContractLocation			BIT = 0
		,@IsMaxPrice					BIT = 0
		,@ContractPricingLevelId		INT = NULL
		,@ZeroDecimal					NUMERIC(18,6) = 0.000000

	SET @LimitContractLocation = ISNULL((SELECT TOP 1 ysnLimitCTByLocation FROM dbo.tblCTCompanyPreference), 0)

	IF ISNULL(@ContractDetailId,0) <> 0 AND ISNULL(@ContractHeaderId,0) = 0
	BEGIN
		SELECT TOP 1 @ContractHeaderId = intContractHeaderId FROM vyuCTContractDetailView WHERE  intContractDetailId = @ContractDetailId
	END

	SET @TransactionDate = ISNULL(@TransactionDate,GETDATE())	
			
	SELECT TOP 1
		 @Price							= ARCC.[dblCashPrice]
		,@UnitPrice						= ARCC.[dblUnitPrice]
		,@CurrencyId					= ARCC.[intSubCurrencyId]
		,@SubCurrencyRate				= ARCC.[dblSubCurrencyRate]
		,@SubCurrency					= ARCC.[strSubCurrency]
		,@ContractHeaderId				= ARCC.[intContractHeaderId]
		,@ContractDetailId				= ARCC.[intContractDetailId]
		,@ContractNumber				= ARCC.[strContractNumber]
		,@ContractSeq					= ARCC.[intContractSeq]
		,@PriceUOMQuantity				= ARCC.[dblPriceUOMQuantity]
		,@AvailableQuantity				= ARCC.[dblAvailableQty]
		,@UnlimitedQuantity				= ARCC.[ysnUnlimitedQuantity]
		,@PricingType					= ARCC.[strPricingType]
		,@ContractUOMId					= ISNULL(ARCC.[intItemUOMId], ARCC.[intPriceItemUOMId])
		,@ContractUOM					= ISNULL(ARCC.[strUnitMeasure], ARCC.[strPriceUnitMeasure])
		,@PriceUOMId					= ISNULL(ARCC.[intPriceItemUOMId], ARCC.[intItemUOMId])
		,@PriceUOM						= ISNULL(ARCC.[strPriceUnitMeasure], ARCC.[strUnitMeasure])
		,@termId						= ARCC.[intTermId]
		,@IsMaxPrice					= ARCC.[ysnMaxPrice]
		,@ContractPricingLevelId		= ARCC.[intCompanyLocationPricingLevelId]
		,@CurrencyExchangeRateTypeId	= ARCC.intCurrencyExchangeRateTypeId
        ,@CurrencyExchangeRateType		= ARCC.strCurrencyExchangeRateType
        ,@CurrencyExchangeRate			= ARCC.dblCurrencyExchangeRate
	FROM
		[vyuCTCustomerContract] ARCC
	WHERE
		ARCC.[intEntityCustomerId] = @CustomerId
		AND (@LimitContractLocation = 0 OR ARCC.[intCompanyLocationId] = @LocationId)
		AND (ARCC.[intItemUOMId] = @ItemUOMId OR ARCC.[intPriceItemUOMId] = @ItemUOMId OR @ItemUOMId IS NULL)
		AND ARCC.[intItemId] = @ItemId
		AND (
				(ISNULL([dbo].[fnCalculateQtyBetweenUOM](ISNULL(@ItemUOMId, ARCC.[intItemUOMId]), ISNULL(ARCC.[intOrderUOMId], ARCC.[intItemUOMId]), @OriginalQuantity),ISNULL(@OriginalQuantity, @ZeroDecimal)) + ARCC.[dblAvailableQty]) >= ISNULL([dbo].[fnCalculateQtyBetweenUOM](ISNULL(@ItemUOMId, ARCC.[intItemUOMId]), ISNULL(ARCC.[intOrderUOMId], ARCC.[intItemUOMId]), @Quantity),ISNULL(@Quantity, @ZeroDecimal))
				OR ARCC.[ysnUnlimitedQuantity] = 1 
				OR ISNULL(@AllowQtyToExceed,0) = 1
			)
		AND CAST(@TransactionDate AS DATE) BETWEEN CAST(dtmStartDate AS DATE) AND CAST(ISNULL(dtmEndDate,@TransactionDate) AS DATE)
		AND ARCC.[intContractHeaderId] = @ContractHeaderId
		AND ARCC.[intContractDetailId] = @ContractDetailId
		AND ((ISNULL(@OriginalQuantity, @ZeroDecimal) + ARCC.[dblAvailableQty] > @ZeroDecimal) OR ARCC.[ysnUnlimitedQuantity] = 1)
		AND (dblBalance > @ZeroDecimal OR ysnUnlimitedQuantity = 1)
		AND ARCC.[strContractStatus] NOT IN ('Cancelled', 'Unconfirmed', 'Complete')
		AND ARCC.[strPricingType] NOT IN ('Unit','Index')
		AND (ISNULL(@CurrencyId, 0) = 0 OR ARCC.[intCurrencyId] = @CurrencyId OR ARCC.[intSubCurrencyId] = @CurrencyId)
	ORDER BY
		 ARCC.[dtmStartDate]
		,ARCC.[intContractSeq]
		
	IF(@Price IS NOT NULL)
	BEGIN
		SET @Pricing = 'Contracts'
		INSERT @returntable(
			 [dblPrice]
			,[dblUnitPrice]
			,[strPricing]
			,[intCurrencyExchangeRateTypeId]
            ,[strCurrencyExchangeRateType]
            ,[dblCurrencyExchangeRate]
			,[intSubCurrencyId]
			,[dblSubCurrencyRate]
			,[strSubCurrency]
			,[intContractUOMId] 
			,[strContractUOM]
			,[intPriceUOMId] 
			,[strPriceUOM]
			,[intContractHeaderId]
			,[intContractDetailId]
			,[strContractNumber]
			,[intContractSeq]
			,[dblPriceUOMQuantity]
			,[dblQuantity]
			,[dblAvailableQty]
			,[ysnUnlimitedQty]
			,[strPricingType]
			,[intTermId]
			,[ysnMaxPrice]
			,[intCompanyLocationPricingLevelId]
		)
		SELECT
			 [dblPrice]							= @Price
			,[dblUnitPrice]						= @UnitPrice
			,[strPricing]						= @Pricing
			,[intCurrencyExchangeRateTypeId]	= @CurrencyExchangeRateTypeId
            ,[strCurrencyExchangeRateType]		= @CurrencyExchangeRateType
            ,[dblCurrencyExchangeRate]			= @CurrencyExchangeRate
			,[intSubCurrencyId]					= @CurrencyId
			,[dblSubCurrencyRate]				= @SubCurrencyRate
			,[strSubCurrency]					= @SubCurrency
			,[intContractUOMId]					= @ContractUOMId
			,[strContractUOM]					= @ContractUOM
			,[intPriceUOMId]					= @PriceUOMId
			,[strPriceUOM]						= @PriceUOM
			,[intContractHeaderId]				= @ContractHeaderId
			,[intContractDetailId]				= @ContractDetailId
			,[strContractNumber]				= @ContractNumber
			,[intContractSeq]					= @ContractSeq
			,[dblPriceUOMQuantity]				= @PriceUOMQuantity
			,[dblQuantity]						= @Quantity
			,[dblAvailableQty]					= @AvailableQuantity
			,[ysnUnlimitedQty]					= @UnlimitedQuantity
			,[strPricingType]					= @PricingType
			,[intTermId]						= @termId
			,[ysnMaxPrice]						= @IsMaxPrice
			,[intCompanyLocationPricingLevelId] = @ContractPricingLevelId

		RETURN
	END
	
	SET @ContractHeaderId	= NULL
	SET @ContractDetailId	= NULL
	SET @ContractNumber		= NULL
	SET @ContractSeq		= NULL
	SET @AvailableQuantity  = NULL
	SET @UnlimitedQuantity  = NULL
	SET @IsMaxPrice			= 0
	SET @ContractPricingLevelId = NULL
			
	SELECT TOP 1
		 @Price							= ARCC.[dblCashPrice]
		,@UnitPrice						= ARCC.[dblUnitPrice]
		,@CurrencyId					= ARCC.[intSubCurrencyId]
		,@SubCurrencyRate				= ARCC.[dblSubCurrencyRate]
		,@SubCurrency					= ARCC.[strSubCurrency]
		,@ContractHeaderId				= ARCC.[intContractHeaderId]
		,@ContractDetailId				= ARCC.[intContractDetailId]
		,@ContractNumber				= ARCC.[strContractNumber]
		,@ContractSeq					= ARCC.[intContractSeq]
		,@PriceUOMQuantity				= CASE WHEN ISNULL(@Quantity, @ZeroDecimal) = @ZeroDecimal
											THEN ISNULL(ARCC.[dblPriceUOMQuantity], ISNULL(ARCC.[dblAvailableQty], @ZeroDecimal))
											ELSE ISNULL(ARCC.[dblPriceUOMQuantity], ISNULL(@Quantity, @ZeroDecimal))
											END		
		,@AvailableQuantity				= ARCC.[dblAvailableQty]
		,@UnlimitedQuantity				= ARCC.[ysnUnlimitedQuantity]
		,@PricingType					= ARCC.[strPricingType]
		,@ContractUOMId					= ISNULL(ARCC.[intItemUOMId], ARCC.[intPriceItemUOMId])
		,@ContractUOM					= ISNULL(ARCC.[strUnitMeasure], ARCC.[strPriceUnitMeasure])
		,@PriceUOMId					= ISNULL(ARCC.[intPriceItemUOMId], ARCC.[intItemUOMId])
		,@PriceUOM						= ISNULL(ARCC.[strPriceUnitMeasure], ARCC.[strUnitMeasure])
		,@termId						= ARCC.[intTermId]
		,@IsMaxPrice					= ARCC.[ysnMaxPrice]
		,@ContractPricingLevelId		= ARCC.[intCompanyLocationPricingLevelId]
		,@CurrencyExchangeRateTypeId	= ARCC.intCurrencyExchangeRateTypeId
        ,@CurrencyExchangeRateType		= ARCC.strCurrencyExchangeRateType
        ,@CurrencyExchangeRate			= ARCC.dblCurrencyExchangeRate
	FROM
		[vyuCTCustomerContract] ARCC
	WHERE
		ARCC.[intEntityCustomerId] = @CustomerId
		AND (@LimitContractLocation = 0 OR ARCC.[intCompanyLocationId] = @LocationId)
		AND (ARCC.[intItemUOMId] = @ItemUOMId OR ARCC.[intPriceItemUOMId] = @ItemUOMId OR @ItemUOMId IS NULL)
		AND ARCC.[intItemId] = @ItemId
		AND (((ARCC.[dblAvailableQty]) >= ISNULL([dbo].[fnCalculateQtyBetweenUOM](ISNULL(ARCC.[intPriceItemUOMId], ARCC.[intItemUOMId]), ARCC.[intItemUOMId], @Quantity),ISNULL(@Quantity, @ZeroDecimal))) OR ARCC.[ysnUnlimitedQuantity] = 1 OR ISNULL(@AllowQtyToExceed,0) = 1)
		AND CAST(@TransactionDate AS DATE) BETWEEN CAST(ARCC.[dtmStartDate] AS DATE) AND CAST(ISNULL(ARCC.[dtmEndDate], @TransactionDate) AS DATE)
		AND (((ARCC.[dblAvailableQty]) > 0) OR ARCC.[ysnUnlimitedQuantity] = 1)
		AND (ARCC.[dblBalance] > 0 OR ARCC.[ysnUnlimitedQuantity] = 1)
		AND ARCC.[strContractStatus] NOT IN ('Cancelled', 'Unconfirmed', 'Complete')
		AND ARCC.[strPricingType] NOT IN ('Unit','Index')
		AND (ISNULL(@CurrencyId, 0) = 0 OR ARCC.[intCurrencyId] = @CurrencyId OR ARCC.[intSubCurrencyId] = @CurrencyId)
	ORDER BY
		 dtmStartDate
		,intContractSeq
		
	IF(@Price IS NOT NULL)
	BEGIN
		SET @Pricing = 'Contracts'
		INSERT @returntable(
			 [dblPrice]
			,[dblUnitPrice]
			,[strPricing]
			,[intCurrencyExchangeRateTypeId]
            ,[strCurrencyExchangeRateType]
            ,[dblCurrencyExchangeRate]
			,[intSubCurrencyId]
			,[dblSubCurrencyRate]
			,[strSubCurrency]
			,[intContractUOMId] 
			,[strContractUOM]
			,[intPriceUOMId] 
			,[strPriceUOM]
			,[intContractHeaderId]
			,[intContractDetailId]
			,[strContractNumber]
			,[intContractSeq]
			,[dblPriceUOMQuantity]
			,[dblQuantity]
			,[dblAvailableQty]
			,[ysnUnlimitedQty]
			,[strPricingType]
			,[intTermId]
			,[ysnMaxPrice]
			,[intCompanyLocationPricingLevelId]
		)
		SELECT
			 [dblPrice]							= @Price
			,[dblUnitPrice]						= @UnitPrice
			,[strPricing]						= @Pricing
			,[intCurrencyExchangeRateTypeId]	= @CurrencyExchangeRateTypeId
            ,[strCurrencyExchangeRateType]		= @CurrencyExchangeRateType
            ,[dblCurrencyExchangeRate]			= @CurrencyExchangeRate
			,[intSubCurrencyId]					= @CurrencyId
			,[dblSubCurrencyRate]				= @SubCurrencyRate
			,[strSubCurrency]					= @SubCurrency
			,[intContractUOMId]					= @ContractUOMId
			,[strContractUOM]					= @ContractUOM
			,[intPriceUOMId]					= @PriceUOMId
			,[strPriceUOM]						= @PriceUOM
			,[intContractHeaderId]				= @ContractHeaderId
			,[intContractDetailId]				= @ContractDetailId
			,[strContractNumber]				= @ContractNumber
			,[intContractSeq]					= @ContractSeq
			,[dblPriceUOMQuantity]				= @PriceUOMQuantity
			,[dblQuantity]						= @Quantity
			,[dblAvailableQty]					= @AvailableQuantity
			,[ysnUnlimitedQty]					= @UnlimitedQuantity
			,[strPricingType]					= @PricingType
			,[intTermId]						= @termId
			,[ysnMaxPrice]						= @IsMaxPrice
			,[intCompanyLocationPricingLevelId] = @ContractPricingLevelId

		RETURN
	END
	
	INSERT @returntable(
			 [dblPrice]
			,[dblUnitPrice]
			,[strPricing]
			,[intCurrencyExchangeRateTypeId]
            ,[strCurrencyExchangeRateType]
            ,[dblCurrencyExchangeRate]
			,[intSubCurrencyId]
			,[dblSubCurrencyRate]
			,[strSubCurrency]
			,[intContractUOMId] 
			,[strContractUOM]
			,[intPriceUOMId] 
			,[strPriceUOM]
			,[intContractHeaderId]
			,[intContractDetailId]
			,[strContractNumber]
			,[intContractSeq]
			,[dblPriceUOMQuantity]
			,[dblQuantity]
			,[dblAvailableQty]
			,[ysnUnlimitedQty]
			,[strPricingType]
			,[intTermId]
			,[ysnMaxPrice]
			,[intCompanyLocationPricingLevelId]
		)
		SELECT
			 [dblPrice]							= @Price
			,[dblUnitPrice]						= @Price
			,[strPricing]						= @Pricing
			,[intCurrencyExchangeRateTypeId]	= @CurrencyExchangeRateTypeId
            ,[strCurrencyExchangeRateType]		= @CurrencyExchangeRateType
            ,[dblCurrencyExchangeRate]			= @CurrencyExchangeRate
			,[intSubCurrencyId]					= @CurrencyId
			,[dblSubCurrencyRate]				= @SubCurrencyRate
			,[strSubCurrency]					= @SubCurrency
			,[intContractUOMId]					= @ContractUOMId
			,[strContractUOM]					= @ContractUOM
			,[intPriceUOMId]					= @PriceUOMId
			,[strPriceUOM]						= @PriceUOM
			,[intContractHeaderId]				= @ContractHeaderId
			,[intContractDetailId]				= @ContractDetailId
			,[strContractNumber]				= @ContractNumber
			,[intContractSeq]					= @ContractSeq
			,[dblPriceUOMQuantity]				= @PriceUOMQuantity
			,[dblQuantity]						= @Quantity
			,[dblAvailableQty]					= @AvailableQuantity
			,[ysnUnlimitedQty]					= @UnlimitedQuantity
			,[strPricingType]					= @PricingType
			,[intTermId]						= @termId
			,[ysnMaxPrice]						= @IsMaxPrice
			,[intCompanyLocationPricingLevelId] = @ContractPricingLevelId
	RETURN				
END
