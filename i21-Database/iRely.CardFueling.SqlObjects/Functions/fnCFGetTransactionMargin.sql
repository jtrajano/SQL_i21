

CREATE FUNCTION [dbo].[fnCFGetTransactionMargin] (
	 @intTransactionId		INT = 0
	 ,@intItemId			INT = 0
	 ,@intLocationId		INT = 0
	 ,@dblNetPrice			NUMERIC(18,6) = 0.0
	 ,@dblGrossPrice		NUMERIC(18,6) = 0.0
	 ,@dblTotalCalcTax		NUMERIC(18,6) = 0.0
	 ,@dblTotalOrigTax		NUMERIC(18,6) = 0.0
	 ,@dblQuantity			NUMERIC(18,6) = 0.0
	 ,@dblTransferCost		NUMERIC(18,6) = 0.0
	 ,@strTransactionType	NVARCHAR(MAX) = ''
	 ,@strPriceBasis		NVARCHAR(MAX) = ''
)
RETURNS @returntable TABLE
(
	 dblMargin			NUMERIC(18,6)
	,dblInventoryCost	NUMERIC(18,6)
	,dblTransferCost	NUMERIC(18,6)
)
AS
BEGIN 

DECLARE @dblMargin NUMERIC(18,6)


IF(@intTransactionId > 0)
BEGIN
	
	DECLARE @strExistingTransactionType NVARCHAR(MAX)
	DECLARE @strExistingTransactionPosted BIT


	SELECT TOP 1
	 @strExistingTransactionType = strTransactionType
	,@strExistingTransactionPosted = ysnPosted
	,@strPriceBasis = strPriceBasis
	FROM tblCFTransaction 
	WHERE intTransactionId = @intTransactionId


	IF (@strExistingTransactionType = 'Local/Network')
	--AND  @strPriceBasis != 'Transfer Cost')
	BEGIN
		IF (@strExistingTransactionPosted = 1)
		BEGIN
			INSERT INTO @returntable
			SELECT 
			dblMargin = ISNULL(cfTransaction.dblCalculatedNetPrice,0) - ISNULL(arSalesAnalysisReport.dblUnitCost,0),
			dblInventoryCost = ISNULL(arSalesAnalysisReport.dblUnitCost ,0),
			dblTransferCost = ISNULL(cfTransaction.dblTransferCost,0)
			FROM tblCFTransaction AS cfTransaction
			INNER JOIN tblARInvoice AS arInvoice
			ON cfTransaction.intInvoiceId = arInvoice.intInvoiceId
			INNER JOIN vyuARSalesAnalysisReport AS arSalesAnalysisReport
			ON arInvoice.intInvoiceId = arSalesAnalysisReport.intTransactionId 
			--LEFT OUTER JOIN
			--(SELECT        intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
			--FROM     dbo.tblCFTransactionPrice AS tblCFTransactionPrice_2
			--WHERE        (strTransactionPriceId = 'Gross Price')) AS cfTransGrossPrice ON cfTransaction.intTransactionId = cfTransGrossPrice.intTransactionId LEFT OUTER JOIN
			--(SELECT        intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
			--FROM            dbo.tblCFTransactionPrice AS tblCFTransactionPrice_1
			--WHERE        (strTransactionPriceId = 'Net Price')) AS cfTransNetPrice ON cfTransaction.intTransactionId = cfTransNetPrice.intTransactionId
			--WHERE cfTransaction.intTransactionId = @intTransactionId
		END
		ELSE
		BEGIN
			INSERT INTO @returntable
			SELECT 
			dblMargin = ISNULL(cfTransaction.dblCalculatedNetPrice,0) - ISNULL(cfItem.dblAverageCost,0),
			dblInventoryCost = ISNULL(cfItem.dblAverageCost,0),
			dblTransferCost = ISNULL(cfTransaction.dblTransferCost,0)
			FROM tblCFTransaction AS cfTransaction INNER JOIN 
			(SELECT cfiItem.intItemId, cfiItem.strProductNumber, iciItem.strDescription, iciItem.intItemId AS intARItemId, iciItem.strItemNo, iciItemPricing.dblAverageCost, iciItemPricing.dblStandardCost, iciItemPricing.dblLastCost
			FROM  dbo.tblCFItem AS cfiItem LEFT OUTER JOIN
			dbo.tblCFSite AS cfiSite ON cfiSite.intSiteId = cfiItem.intSiteId LEFT OUTER JOIN
			dbo.tblICItem AS iciItem ON cfiItem.intARItemId = iciItem.intItemId LEFT OUTER JOIN
			dbo.tblICItemLocation AS iciItemLocation ON cfiItem.intARItemId = iciItemLocation.intItemId AND iciItemLocation.intLocationId = cfiSite.intARLocationId LEFT OUTER JOIN
			dbo.vyuICGetItemPricing AS iciItemPricing ON cfiItem.intARItemId = iciItemPricing.intItemId AND iciItemLocation.intLocationId = iciItemPricing.intLocationId AND 
			iciItemLocation.intItemLocationId = iciItemPricing.intItemLocationId) AS cfItem ON cfTransaction.intProductId = cfItem.intItemId  --LEFT OUTER JOIN
			--(SELECT        intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
			--FROM     dbo.tblCFTransactionPrice AS tblCFTransactionPrice_2
			--WHERE        (strTransactionPriceId = 'Gross Price')) AS cfTransGrossPrice ON cfTransaction.intTransactionId = cfTransGrossPrice.intTransactionId LEFT OUTER JOIN
			--(SELECT        intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
			--FROM            dbo.tblCFTransactionPrice AS tblCFTransactionPrice_1
			--WHERE        (strTransactionPriceId = 'Net Price')) AS cfTransNetPrice ON cfTransaction.intTransactionId = cfTransNetPrice.intTransactionId
			--WHERE cfTransaction.intTransactionId = @intTransactionId
		END

	END
	ELSE
	BEGIN
		INSERT INTO @returntable
		SELECT
		dblMargin = (ISNULL(cfTransaction.dblCalculatedGrossPrice,0) - ISNULL(cfTransaction.dblTransferCost,0)) +
			((ISNULL(cfTotalTax.dblTaxOriginalAmount,0)/ISNULL(cfTransaction.dblQuantity,0) - ISNULL(cfTotalTax.dblTaxCalculatedAmount,0)/ISNULL(cfTransaction.dblQuantity,0))),
		dblTransferCost = ISNULL(cfTransaction.dblTransferCost,0) ,
		dblInventoryCost = 0
		FROM tblCFTransaction AS cfTransaction LEFT OUTER JOIN
		--(SELECT        intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
		--FROM     dbo.tblCFTransactionPrice AS tblCFTransactionPrice_2
		--WHERE        (strTransactionPriceId = 'Gross Price')) AS cfTransGrossPrice ON cfTransaction.intTransactionId = cfTransGrossPrice.intTransactionId LEFT OUTER JOIN
		--(SELECT        intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
		--FROM            dbo.tblCFTransactionPrice AS tblCFTransactionPrice_1
		--WHERE        (strTransactionPriceId = 'Net Price')) AS cfTransNetPrice ON cfTransaction.intTransactionId = cfTransNetPrice.intTransactionId
		--LEFT OUTER JOIN 
		(SELECT intTransactionId ,SUM(dblTaxCalculatedAmount) AS dblTaxCalculatedAmount ,SUM(dblTaxOriginalAmount) AS dblTaxOriginalAmount  FROM tblCFTransactionTax group by intTransactionId) AS cfTotalTax ON cfTotalTax.intTransactionId = cfTransaction.intTransactionId
		WHERE cfTransaction.intTransactionId = @intTransactionId
	END

	

END
ELSE
BEGIN
	
	INSERT INTO @returntable
	SELECT

	dblMargin = (

	CASE @strTransactionType 

		WHEN 'Local/Network' 
		THEN ISNULL(@dblNetPrice,0) - ISNULL(dblAverageCost,0)

		WHEN 'Extended Remote' 
		THEN (ISNULL(@dblGrossPrice,0) - ISNULL(@dblTransferCost,0)) + ((ISNULL(@dblTotalOrigTax,0) / ISNULL(@dblQuantity,0)) - (ISNULL(@dblTotalCalcTax,0) / ISNULL(@dblQuantity,0)))

		WHEN 'Remote' 
		THEN (ISNULL(@dblGrossPrice,0) - ISNULL(@dblTransferCost,0)) + ((ISNULL(@dblTotalOrigTax,0) / ISNULL(@dblQuantity,0)) - (ISNULL(@dblTotalCalcTax,0) / ISNULL(@dblQuantity,0)))

		WHEN 'Foreign Sale' 
		THEN (ISNULL(@dblGrossPrice,0) - ISNULL(@dblTransferCost,0)) + ((ISNULL(@dblTotalOrigTax,0) / ISNULL(@dblQuantity,0)) - (ISNULL(@dblTotalCalcTax,0) / ISNULL(@dblQuantity,0)))

		ELSE 0 
	END),
	dblInventoryCost = dblAverageCost,
	dblTransferCost = @dblTransferCost
	FROM vyuICGetItemPricing 
	WHERE intItemId = @intItemId
	AND intLocationId = @intLocationId

END

RETURN


END