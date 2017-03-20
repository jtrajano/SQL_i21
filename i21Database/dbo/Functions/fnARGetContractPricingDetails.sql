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
	 dblPrice				NUMERIC(18,6)
	,strPricing				NVARCHAR(250)
	,intSubCurrencyId		INT
	,dblSubCurrencyRate		NUMERIC(18,6)
	,strSubCurrency			NVARCHAR(40)
	,intPriceUOMId			INT
	,strPriceUOM			NVARCHAR(50)
	,intContractHeaderId	INT
	,intContractDetailId	INT
	,strContractNumber		NVARCHAR(50)
	,intContractSeq			INT
	,dblAvailableQty        NUMERIC(18,6)
	,ysnUnlimitedQty        BIT
	,strPricingType			NVARCHAR(50)
	,intTermId				INT
)
AS
BEGIN

DECLARE	 @Price				NUMERIC(18,6)
		,@Pricing			NVARCHAR(250)
		,@ContractNumber	NVARCHAR(50)
		,@ContractSeq		INT
		,@AvailableQuantity	NUMERIC(18,6)
		,@UnlimitedQuantity	BIT
		,@PricingType		NVARCHAR(50)
		,@SubCurrencyRate	NUMERIC(18,6)
		,@SubCurrency		NVARCHAR(40)
		,@PriceUOM			NVARCHAR(50)
		,@termId			INT

	IF ISNULL(@ContractDetailId,0) <> 0 AND ISNULL(@ContractHeaderId,0) = 0
	BEGIN
		SELECT TOP 1 @ContractHeaderId = intContractHeaderId FROM vyuCTContractDetailView WHERE  intContractDetailId = @ContractDetailId
	END

	SET @TransactionDate = ISNULL(@TransactionDate,GETDATE())	
			
	SELECT TOP 1
		 @Price				= ARCC.[dblCashPrice]
		,@CurrencyId		= ARCC.[intSubCurrencyId]
		,@SubCurrencyRate	= ARCC.[dblSubCurrencyRate]
		,@SubCurrency		= ARCC.[strSubCurrency]
		,@ContractHeaderId	= ARCC.[intContractHeaderId]
		,@ContractDetailId	= ARCC.[intContractDetailId]
		,@ContractNumber	= ARCC.[strContractNumber]
		,@ContractSeq		= ARCC.[intContractSeq]
		,@AvailableQuantity = ARCC.[dblAvailableQty]
		,@UnlimitedQuantity = ARCC.[ysnUnlimitedQuantity]
		,@PricingType		= ARCC.[strPricingType]
		,@ItemUOMId			= ARCC.[intItemUOMId] 
		,@PriceUOM			= ARCC.[strUnitMeasure] 
		,@termId			= ARCC.[intTermId]
	FROM
		[vyuARCustomerContract] ARCC
	WHERE
		ARCC.[intEntityCustomerId] = @CustomerId
		AND ARCC.[intCompanyLocationId] = @LocationId
		AND (ARCC.[intItemUOMId] = @ItemUOMId OR @ItemUOMId IS NULL)
		AND ARCC.[intItemId] = @ItemId
		AND ((ISNULL(@OriginalQuantity,0.00) + ARCC.[dblAvailableQty] >= @Quantity) OR ARCC.[ysnUnlimitedQuantity] = 1 OR ISNULL(@AllowQtyToExceed,0) = 1)
		AND CAST(@TransactionDate AS DATE) BETWEEN CAST(dtmStartDate AS DATE) AND CAST(ISNULL(dtmEndDate,@TransactionDate) AS DATE)
		AND ARCC.[intContractHeaderId] = @ContractHeaderId
		AND ARCC.[intContractDetailId] = @ContractDetailId
		AND ((ISNULL(@OriginalQuantity,0.00) +ARCC.[dblAvailableQty] > 0) OR ARCC.[ysnUnlimitedQuantity] = 1)
		AND (dblBalance > 0 OR ysnUnlimitedQuantity = 1)
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
			,[strPricing]
			,[intSubCurrencyId]
			,[dblSubCurrencyRate]
			,[strSubCurrency]
			,[intPriceUOMId] 
			,[strPriceUOM]
			,[intContractHeaderId]
			,[intContractDetailId]
			,[strContractNumber]
			,[intContractSeq]
			,[dblAvailableQty]
			,[ysnUnlimitedQty]
			,[strPricingType]
			,[intTermId]
		)
		SELECT
			 [dblPrice]				= @Price
			,[strPricing]			= @Pricing
			,[intSubCurrencyId]		= @CurrencyId
			,[dblSubCurrencyRate]	= @SubCurrencyRate
			,[strSubCurrency]		= @SubCurrency
			,[intPriceUOMId]		= @ItemUOMId
			,[strPriceUOM]			= @PriceUOM
			,[intContractHeaderId]	= @ContractHeaderId
			,[intContractDetailId]	= @ContractDetailId
			,[strContractNumber]	= @ContractNumber
			,[intContractSeq]		= @ContractSeq
			,[dblAvailableQty]		= @AvailableQuantity
			,[ysnUnlimitedQty]		= @UnlimitedQuantity
			,[strPricingType]		= @PricingType
			,[intTermId]			= @termId

		RETURN
	END
	
	SET @ContractHeaderId	= NULL
	SET @ContractDetailId	= NULL
	SET @ContractNumber		= NULL
	SET @ContractSeq		= NULL
	SET @AvailableQuantity  = NULL
	SET @UnlimitedQuantity  = NULL
			
	SELECT TOP 1
		 @Price				= ARCC.[dblCashPrice]
		,@CurrencyId		= ARCC.[intSubCurrencyId]
		,@SubCurrencyRate	= ARCC.[dblSubCurrencyRate]
		,@SubCurrency		= ARCC.[strSubCurrency]
		,@ContractHeaderId	= ARCC.[intContractHeaderId]
		,@ContractDetailId	= ARCC.[intContractDetailId]
		,@ContractNumber	= ARCC.[strContractNumber]
		,@ContractSeq		= ARCC.[intContractSeq]
		,@AvailableQuantity = ARCC.[dblAvailableQty]
		,@UnlimitedQuantity = ARCC.[ysnUnlimitedQuantity]
		,@PricingType		= ARCC.[strPricingType]
		,@ItemUOMId			= ARCC.[intItemUOMId] 
		,@PriceUOM			= ARCC.[strUnitMeasure] 
		,@termId			= ARCC.[intTermId]
	FROM
		[vyuARCustomerContract] ARCC
	WHERE
		ARCC.[intEntityCustomerId] = @CustomerId
		AND ARCC.[intCompanyLocationId] = @LocationId
		AND (ARCC.[intItemUOMId] = @ItemUOMId OR @ItemUOMId IS NULL)
		AND ARCC.[intItemId] = @ItemId
		AND (((ARCC.[dblAvailableQty]) >= @Quantity) OR ARCC.[ysnUnlimitedQuantity] = 1 OR ISNULL(@AllowQtyToExceed,0) = 1)
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
			,[strPricing]
			,[intSubCurrencyId]
			,[dblSubCurrencyRate]
			,[strSubCurrency]
			,[intPriceUOMId] 
			,[strPriceUOM]
			,[intContractHeaderId]
			,[intContractDetailId]
			,[strContractNumber]
			,[intContractSeq]
			,[dblAvailableQty]
			,[ysnUnlimitedQty]
			,[strPricingType]
			,[intTermId]
		)
		SELECT
			 [dblPrice]				= @Price
			,[strPricing]			= @Pricing
			,[intSubCurrencyId]		= @CurrencyId
			,[dblSubCurrencyRate]	= @SubCurrencyRate
			,[strSubCurrency]		= @SubCurrency
			,[intPriceUOMId]		= @ItemUOMId
			,[strPriceUOM]			= @PriceUOM
			,[intContractHeaderId]	= @ContractHeaderId
			,[intContractDetailId]	= @ContractDetailId
			,[strContractNumber]	= @ContractNumber
			,[intContractSeq]		= @ContractSeq
			,[dblAvailableQty]		= @AvailableQuantity
			,[ysnUnlimitedQty]		= @UnlimitedQuantity
			,[strPricingType]		= @PricingType
			,[intTermId]			= @termId

		RETURN
	END		
	
	INSERT @returntable([dblPrice], [strPricing], [intContractHeaderId], [intContractDetailId], [strContractNumber], [intContractSeq], [dblAvailableQty], [ysnUnlimitedQty], [strPricingType], [intTermId])
	SELECT @Price, @Pricing, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @AvailableQuantity, @UnlimitedQuantity, @PricingType, @termId
	RETURN				
END
