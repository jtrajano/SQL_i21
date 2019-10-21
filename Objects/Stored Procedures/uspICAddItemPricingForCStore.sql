CREATE PROCEDURE [dbo].[uspICAddItemPricingForCStore]
	@intItemId AS INT
	,@intItemLocationId AS INT
	,@dblStandardCost AS NUMERIC(18, 6) = 0 
	,@dblLastCost AS NUMERIC(18, 6) = 0 
	,@dblSalePrice AS NUMERIC(18, 6) = 0 
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