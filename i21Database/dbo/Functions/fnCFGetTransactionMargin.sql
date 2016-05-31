CREATE FUNCTION [dbo].[fnCFGetTransactionMargin] (
	 @intTransactionId		INT = 0
	 ,@intItemId			INT = 0
	 ,@intLocationId		INT = 0
	 ,@dblNetPrice			NUMERIC(18,6) = 0.0
	 ,@dblGrossPrice		NUMERIC(18,6) = 0.0
	 ,@dblTransferCost		NUMERIC(18,6) = 0.0
	 ,@strTransactionType	NVARCHAR(MAX) = ''
)
RETURNS @returntable TABLE
(
	dblMargin NUMERIC(18,6)
	,dblCost NUMERIC(18,6)
)
AS
BEGIN 

DECLARE @dblMargin NUMERIC(18,6)

IF(@intTransactionId > 0)
BEGIN

	INSERT INTO @returntable
	SELECT
	dblMargin = (
	CASE cfTransaction.strTransactionType 
	WHEN 'Local/Network' 
		THEN 
			CASE cfTransaction.ysnPosted 
			WHEN 1 
			THEN cfTransNetPrice.dblCalculatedAmount - cfItem.dblAverageCost 
			ELSE cfTransNetPrice.dblCalculatedAmount - cfItem.dblLastCost
		END
	WHEN 'Extended Remote' 
	THEN cfTransGrossPrice.dblCalculatedAmount - cfTransaction.dblTransferCost 
	WHEN 'Remote' 
	THEN cfTransGrossPrice.dblCalculatedAmount - cfTransaction.dblTransferCost
	ELSE 0 
	END),
	dblCost = CASE cfTransaction.strTransactionType 
	WHEN 'Local/Network' 
		THEN 
			CASE cfTransaction.ysnPosted 
			WHEN 1 
			THEN cfItem.dblAverageCost 
			ELSE cfItem.dblLastCost
		END
	WHEN 'Extended Remote' 
	THEN cfTransaction.dblTransferCost 
	WHEN 'Remote' 
	THEN cfTransaction.dblTransferCost
	ELSE 0 
	END
	FROM tblCFTransaction AS cfTransaction INNER JOIN 
	(SELECT cfiItem.intItemId, cfiItem.strProductNumber, iciItem.strDescription, iciItem.intItemId AS intARItemId, iciItem.strItemNo, iciItemPricing.dblAverageCost, iciItemPricing.dblStandardCost, iciItemPricing.dblLastCost
	FROM  dbo.tblCFItem AS cfiItem LEFT OUTER JOIN
	dbo.tblCFSite AS cfiSite ON cfiSite.intSiteId = cfiItem.intSiteId LEFT OUTER JOIN
	dbo.tblICItem AS iciItem ON cfiItem.intARItemId = iciItem.intItemId LEFT OUTER JOIN
	dbo.tblICItemLocation AS iciItemLocation ON cfiItem.intARItemId = iciItemLocation.intItemId AND iciItemLocation.intLocationId = cfiSite.intARLocationId LEFT OUTER JOIN
	dbo.vyuICGetItemPricing AS iciItemPricing ON cfiItem.intARItemId = iciItemPricing.intItemId AND iciItemLocation.intLocationId = iciItemPricing.intLocationId AND 
	iciItemLocation.intItemLocationId = iciItemPricing.intItemLocationId) AS cfItem ON cfTransaction.intProductId = cfItem.intItemId  LEFT OUTER JOIN
	(SELECT        intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
	FROM     dbo.tblCFTransactionPrice AS tblCFTransactionPrice_2
	WHERE        (strTransactionPriceId = 'Gross Price')) AS cfTransGrossPrice ON cfTransaction.intTransactionId = cfTransGrossPrice.intTransactionId LEFT OUTER JOIN
	(SELECT        intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
	FROM            dbo.tblCFTransactionPrice AS tblCFTransactionPrice_1
	WHERE        (strTransactionPriceId = 'Net Price')) AS cfTransNetPrice ON cfTransaction.intTransactionId = cfTransNetPrice.intTransactionId
	WHERE cfTransaction.intTransactionId = @intTransactionId

END
ELSE
BEGIN
	
	INSERT INTO @returntable
	SELECT
	dblMargin = (
	CASE @strTransactionType 
	WHEN 'Local/Network' 
		THEN 
			@dblNetPrice - dblLastCost
	WHEN 'Extended Remote' 
	THEN @dblGrossPrice - @dblTransferCost 
	WHEN 'Remote' 
	THEN @dblGrossPrice - @dblTransferCost
	ELSE 0 
	END),
	dblCost = CASE @strTransactionType 
	WHEN 'Local/Network' 
		THEN dblLastCost
	WHEN 'Extended Remote' 
	THEN @dblTransferCost 
	WHEN 'Remote' 
	THEN @dblTransferCost
	ELSE 0 
	END
	FROM vyuICGetItemPricing 
	WHERE intItemId = @intItemId
	AND intLocationId = @intLocationId

END

RETURN


END


