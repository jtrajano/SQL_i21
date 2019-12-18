CREATE FUNCTION [dbo].[fnARGetItemContractPricingDetails]
(
	  @intItemId				INT
	, @intCustomerId			INT	
	, @intLocationId			INT
	, @intItemUOMId				INT
	, @intCurrencyId			INT
	, @dtmTransactionDate		DATETIME
	, @dblQuantity				NUMERIC(18,6)
	, @intItemContractHeaderId	INT
	, @intItemContractDetailId	INT
	, @dblOriginalQuantity		NUMERIC(18,6)
)
RETURNS @returntable TABLE (
	  dblPrice					NUMERIC(18,6)
	, strPricing				NVARCHAR(250)
	, intItemContractHeaderId	INT
	, intItemContractDetailId	INT
	, strItemContractNumber		NVARCHAR(50)
	, intItemContractSeq		INT
	, intItemContractUOMId		INT
	, strItemContractUOM		NVARCHAR(50)
	, dblQuantity				NUMERIC(18,6)
	, dblAvailableQty			NUMERIC(18,6)
	, intTermId					INT
)
AS
BEGIN

DECLARE @dblPrice				NUMERIC(18,6)
	  , @strPricing				NVARCHAR(250)
	  , @strItemContractNumber	NVARCHAR(50)
	  , @intItemContractSeq		INT
	  , @dblAvailableQuantity	NUMERIC(18,6)
	  , @strPricingType			NVARCHAR(50)
	  , @intItemContractUOMId	INT
	  , @strItemContractUOM		NVARCHAR(50)
	  , @intTermId				INT
	  , @dblZeroDecimal			NUMERIC(18,6) = 0.000000
	  , @ysnLimitLocation		BIT = 0

SET @dtmTransactionDate = ISNULL(@dtmTransactionDate, GETDATE())	
SELECT TOP 1 @ysnLimitLocation = ISNULL(ysnLimitCTByLocation, 0) FROM tblCTCompanyPreference

IF ISNULL(@intItemContractDetailId,0) <> 0 AND ISNULL(@intItemContractHeaderId,0) = 0
	BEGIN
		SELECT TOP 1 @intItemContractHeaderId = intItemContractHeaderId 
		FROM tblCTItemContractDetail 
		WHERE intItemContractDetailId = @intItemContractDetailId
	END	
			
SELECT TOP 1 @dblPrice					= ICS.dblPrice
		   , @intItemContractHeaderId	= ICS.intItemContractHeaderId
		   , @intItemContractDetailId	= ICS.intItemContractDetailId
		   , @strItemContractNumber		= ICS.strItemContractNumber
		   , @intItemContractSeq		= ICS.intItemContractSeq
		   , @dblAvailableQuantity		= ICS.dblAvailable
		   , @intItemContractUOMId		= ICS.intItemUOMId
		   , @strItemContractUOM		= ICS.strUnitMeasure
		   , @intTermId					= ICS.intTermId
FROM vyuARItemContractSequenceSearch ICS
WHERE ICS.intEntityCustomerId = @intCustomerId
	AND ICS.intItemContractHeaderId = @intItemContractHeaderId
	AND ICS.intItemContractDetailId = @intItemContractDetailId
	AND ICS.intItemId = @intItemId
	AND (ISNULL(@ysnLimitLocation, 0) = 0 OR ICS.intCompanyLocationId = @intLocationId)
	AND (ISNULL(@intItemUOMId, 0) = 0 OR ICS.[intItemUOMId] = @intItemUOMId)		
	AND (ISNULL(@dblOriginalQuantity, @dblZeroDecimal) + ICS.dblAvailable > @dblZeroDecimal)
	AND ISNULL(ICS.dblBalance, 0) > @dblZeroDecimal
	AND ICS.dtmContractDate <= CAST(@dtmTransactionDate AS DATE)
	AND ICS.dtmDeliveryDate <= CAST(@dtmTransactionDate AS DATE)
	AND ICS.dtmExpirationDate >= CAST(@dtmTransactionDate AS DATE)
	AND (ISNULL(@intCurrencyId, 0) = 0 OR ICS.intCurrencyId = @intCurrencyId)
ORDER BY ICS.dtmContractDate
       , ICS.intItemContractSeq
		
IF(@dblPrice IS NOT NULL)
	SET @strPricing = 'Item Contracts'
	
INSERT @returntable(
	  [dblPrice]
	, [strPricing]
	, [intItemContractUOMId] 
	, [strItemContractUOM]
	, [intItemContractHeaderId]
	, [intItemContractDetailId]
	, [strItemContractNumber]
	, [intItemContractSeq]
	, [dblQuantity]
	, [dblAvailableQty]
	, [intTermId]
)
SELECT [dblPrice]				= @dblPrice
	, [strPricing]				= @strPricing
	, [intItemContractUOMId]	= @intItemContractUOMId
	, [strItemContractUOM]		= @strItemContractUOM
	, [intItemContractHeaderId]	= @intItemContractHeaderId
	, [intItemContractDetailId]	= @intItemContractDetailId
	, [strItemContractNumber]	= @strItemContractNumber
	, [intItemContractSeq]		= @intItemContractSeq
	, [dblQuantity]				= @dblQuantity
	, [dblAvailableQty]			= @dblAvailableQuantity
	, [intTermId]				= @intTermId
		
RETURN

END