CREATE PROCEDURE [dbo].[uspICAddItemPricingForCStore]
	@intItemId AS INT
	,@intItemLocationId AS INT
	,@dblStandardCost AS NUMERIC(18, 6) = 0 
	,@dblLastCost AS NUMERIC(18, 6) = 0 
	,@dblSalePrice AS NUMERIC(18, 6) = 0 
	,@dtmEffectiveDate AS DATETIME = NULL 
	,@intEntityUserSecurityId AS INT 
	,@intItemPricingId AS INT = NULL OUTPUT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

DECLARE @intDataSourceId_CStore AS TINYINT = 1

-- Get the item uom id. 
SELECT 
	@intItemPricingId = intItemPricingId 
FROM 
	tblICItemPricing
WHERE 
	intItemId = @intItemId 
	AND intItemLocationId = @intItemLocationId

-- If NULL, item uom does not exists. It is safe to create a new item record. 
IF @intItemPricingId IS NULL 
BEGIN 
	INSERT INTO tblICItemPricing(
		intItemId
		,intItemLocationId 
		,dblSalePrice 
		,strPricingMethod 
		,dblLastCost 
		,dblStandardCost 
		,dblAverageCost 
		,intConcurrencyId 
		,dtmDateCreated 
		,intCreatedByUserId 
		,intDataSourceId 
	)
	SELECT
		intItemId = @intItemId
		,intItemLocationId = @intItemLocationId
		,dblSalePrice = @dblSalePrice
		,strPricingMethod = 'None'
		,dblLastCost = @dblLastCost
		,dblStandardCost = @dblStandardCost
		,dblAverageCost = 0
		,intConcurrencyId = 1
		,dtmDateCreated = GETDATE()
		,intCreatedByUserId = @intEntityUserSecurityId
		,intDataSourceId = @intDataSourceId_CStore

	SELECT @intItemPricingId = SCOPE_IDENTITY()

	-- Create an audit log. 
	IF @intItemPricingId IS NOT NULL
	AND @intItemId IS NOT NULL 
	BEGIN 
		EXEC dbo.uspSMAuditLog 
			@keyValue = @intItemId
			,@screenName = 'Inventory.view.Item'
			,@entityId = @intEntityUserSecurityId
			,@actionType = 'Updated'
			,@changeDescription = 'C-Store created an Item Pricing.'
			,@fromValue = NULL 
			,@toValue = @intItemPricingId 
	END
END

IF @dblStandardCost IS NOT NULL AND @dtmEffectiveDate IS NOT NULL
BEGIN 

	DECLARE @intEffectiveItemCostId  INT = NULL

	INSERT INTO tblICEffectiveItemCost(
		intItemId
		,intItemLocationId 
		,dblCost 
		,dtmEffectiveCostDate 
		,intConcurrencyId 
		,dtmDateCreated 
		,intCreatedByUserId 
	)
	SELECT
		intItemId = @intItemId
		,intItemLocationId = @intItemLocationId
		,dblCost 			  = @dblStandardCost
		,dtmEffectiveCostDate = @dtmEffectiveDate
		,intConcurrencyId 	  = 1
		,dtmDateCreated 	  = GETDATE()
		,intCreatedByUserId   = @intEntityUserSecurityId

	SELECT @intEffectiveItemCostId = SCOPE_IDENTITY();

	-- Create an audit log. 
	IF @intEffectiveItemCostId IS NOT NULL
	AND @intItemId IS NOT NULL 
	BEGIN 
		EXEC dbo.uspSMAuditLog 
			@keyValue = @intItemId
			,@screenName = 'Inventory.view.Item'
			,@entityId = @intEntityUserSecurityId
			,@actionType = 'Updated'
			,@changeDescription = 'C-Store created an Item Cost Pricing with Effective Date.'
			,@fromValue = NULL 
			,@toValue = @intEffectiveItemCostId 
	END
END


IF @dblSalePrice IS NOT NULL AND @dtmEffectiveDate IS NOT NULL
BEGIN 

	DECLARE @intEffectiveItemPriceId  INT = NULL

	INSERT INTO tblICEffectiveItemPrice(
		intItemId
		,intItemLocationId 
		,dblRetailPrice 
		,dtmEffectiveRetailPriceDate 
		,intConcurrencyId 
		,dtmDateCreated 
		,intCreatedByUserId 
	)
	SELECT
		intItemId						= @intItemId
		,intItemLocationId				= @intItemLocationId
		,dblRetailPrice 				= @dblSalePrice
		,dtmEffectiveRetailPriceDate	= @dtmEffectiveDate
		,intConcurrencyId 				= 1
		,dtmDateCreated 				= GETDATE()
		,intCreatedByUserId				= @intEntityUserSecurityId

	SELECT @intEffectiveItemPriceId = SCOPE_IDENTITY();


	-- Create an audit log. 
	IF @intEffectiveItemPriceId IS NOT NULL
	AND @intItemId IS NOT NULL 
	BEGIN 
		EXEC dbo.uspSMAuditLog 
			@keyValue = @intItemId
			,@screenName = 'Inventory.view.Item'
			,@entityId = @intEntityUserSecurityId
			,@actionType = 'Updated'
			,@changeDescription = 'C-Store created an Item Price Pricing with Effective Date.'
			,@fromValue = NULL 
			,@toValue = @intEffectiveItemPriceId 
	END
END