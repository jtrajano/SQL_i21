CREATE FUNCTION [dbo].[fnARGetContractPricingDetails]
(
	 @ItemId				INT
	,@CustomerId			INT	
	,@LocationId			INT
	,@ItemUOMId				INT
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
	,intContractHeaderId	INT
	,intContractDetailId	INT
	,strContractNumber		NVARCHAR(50)
	,intContractSeq			INT
	,dblAvailableQty        NUMERIC(18,6)
	,ysnUnlimitedQty        BIT
	,strPricingType			NVARCHAR(50)
)
AS
BEGIN

DECLARE	 @Price		NUMERIC(18,6)
		,@Pricing	NVARCHAR(250)
		,@ContractNumber		NVARCHAR(50)
		,@ContractSeq			INT
		,@AvailableQuantity		NUMERIC(18,6)
		,@UnlimitedQuantity     BIT
		,@PricingType			NVARCHAR(50)

	IF ISNULL(@ContractDetailId,0) <> 0 AND ISNULL(@ContractHeaderId,0) = 0
	BEGIN
		SELECT TOP 1 @ContractHeaderId = intContractHeaderId FROM vyuCTContractDetailView WHERE  intContractDetailId = @ContractDetailId
	END

	SET @TransactionDate = ISNULL(@TransactionDate,GETDATE())	
			
	SELECT TOP 1
		 @Price				= [dbo].[fnCalculateQtyBetweenUOM]([intItemUOMId],[intPriceItemUOMId],1) * [dbo].[fnConvertToBaseCurrency]([intSeqCurrencyId], dblCashPrice)
		,@ContractHeaderId	= intContractHeaderId
		,@ContractDetailId	= intContractDetailId
		,@ContractNumber	= strContractNumber
		,@ContractSeq		= intContractSeq
		,@AvailableQuantity = dblAvailableQty
		,@UnlimitedQuantity = ysnUnlimitedQuantity	
		,@PricingType		= strPricingType	
	FROM
		vyuCTContractDetailView
	WHERE
		intEntityId = @CustomerId
		AND intCompanyLocationId = @LocationId
		AND (intItemUOMId = @ItemUOMId OR @ItemUOMId IS NULL)
		AND intItemId = @ItemId
		AND ((ISNULL(@OriginalQuantity,0.00) + dblAvailableQty >= @Quantity) OR ysnUnlimitedQuantity = 1 OR ISNULL(@AllowQtyToExceed,0) = 1)
		AND CAST(@TransactionDate AS DATE) BETWEEN CAST(dtmStartDate AS DATE) AND CAST(ISNULL(dtmEndDate,@TransactionDate) AS DATE)
		AND intContractHeaderId = @ContractHeaderId
		AND intContractDetailId = @ContractDetailId
		AND ((ISNULL(@OriginalQuantity,0.00) + dblAvailableQty > 0) OR ysnUnlimitedQuantity = 1)
		AND (dblBalance > 0 OR ysnUnlimitedQuantity = 1)
		AND strContractStatus NOT IN ('Cancelled', 'Unconfirmed', 'Complete')
		AND strPricingType NOT IN ('Unit','Index')
	ORDER BY
		 dtmStartDate
		,intContractSeq
		
	IF(@Price IS NOT NULL)
	BEGIN
		SET @Pricing = 'Contracts - Customer Pricing'
		INSERT @returntable
		SELECT @Price, @Pricing, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @AvailableQuantity, @UnlimitedQuantity, @PricingType
		RETURN
	END
	
	SET @ContractHeaderId	= NULL
	SET @ContractDetailId	= NULL
	SET @ContractNumber		= NULL
	SET @ContractSeq		= NULL
	SET @AvailableQuantity  = NULL
	SET @UnlimitedQuantity  = NULL
			
	SELECT TOP 1
		 @Price				= [dbo].[fnCalculateQtyBetweenUOM]([intItemUOMId],[intPriceItemUOMId],1) * [dbo].[fnConvertToBaseCurrency]([intSeqCurrencyId], dblCashPrice)
		,@ContractHeaderId	= intContractHeaderId
		,@ContractDetailId	= intContractDetailId
		,@ContractNumber	= strContractNumber
		,@ContractSeq		= intContractSeq
		,@AvailableQuantity = dblAvailableQty
		,@UnlimitedQuantity = ysnUnlimitedQuantity		
		,@PricingType		= strPricingType	
	FROM
		vyuCTContractDetailView
	WHERE
		intEntityId = @CustomerId
		AND intCompanyLocationId = @LocationId
		AND (intItemUOMId = @ItemUOMId OR @ItemUOMId IS NULL)
		AND intItemId = @ItemId
		AND (((dblAvailableQty) >= @Quantity) OR ysnUnlimitedQuantity = 1 OR ISNULL(@AllowQtyToExceed,0) = 1)
		AND CAST(@TransactionDate AS DATE) BETWEEN CAST(dtmStartDate AS DATE) AND CAST(ISNULL(dtmEndDate,@TransactionDate) AS DATE)
		AND (((dblAvailableQty) > 0) OR ysnUnlimitedQuantity = 1)
		AND (dblBalance > 0 OR ysnUnlimitedQuantity = 1)
		AND strContractStatus NOT IN ('Cancelled', 'Unconfirmed', 'Complete')
		AND strPricingType NOT IN ('Unit','Index')
	ORDER BY
		 dtmStartDate
		,intContractSeq
		
	IF(@Price IS NOT NULL)
	BEGIN
		SET @Pricing = 'Contracts - Customer Pricing'
		INSERT @returntable
		SELECT @Price, @Pricing, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @AvailableQuantity, @UnlimitedQuantity, @PricingType
		RETURN
	END		
	
	INSERT @returntable
	SELECT @Price, @Pricing, @ContractHeaderId, @ContractDetailId, @ContractNumber, @ContractSeq, @AvailableQuantity, @UnlimitedQuantity, @PricingType
	RETURN				
END
