CREATE PROCEDURE [dbo].[uspICAddItemLocationForCStore]
	@intLocationId AS INT 
	,@intItemId AS INT 
	,@ysnTaxFlag1 AS BIT = NULL 
	,@ysnTaxFlag2 AS BIT = NULL 
	,@ysnTaxFlag3 AS BIT = NULL 
	,@ysnTaxFlag4 AS BIT = NULL 
	,@ysnApplyBlueLaw1 AS BIT = NULL 
	,@ysnApplyBlueLaw2 AS BIT = NULL 
	,@intProductCodeId AS INT = NULL 
	,@intFamilyId AS INT = NULL 
	,@intClassId AS INT = NULL
	,@ysnFoodStampable AS BIT = NULL 
	,@ysnReturnable AS BIT = NULL 
	,@ysnSaleable AS BIT = NULL 
	,@ysnPrePriced AS BIT = NULL 
	,@ysnIdRequiredLiquor AS BIT = NULL 
	,@ysnIdRequiredCigarette AS BIT = NULL 
	,@intMinimumAge AS INT = NULL 
	,@intVendorId AS INT = NULL 
	,@intEntityUserSecurityId AS INT 
	,@intItemLocationId AS INT = NULL OUTPUT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

DECLARE @intDataSourceId_CStore AS TINYINT = 1

DECLARE @AVG AS INT = 1
		,@FIFO AS INT = 2
		,@LIFO AS INT = 3
		,@LOT AS INT = 4
		,@ACTUAL AS INT = 5
		,@CATEGORY AS INT = 6

		,@ALLOW_NEGATIVE_STOCK_YES AS INT = 1
		,@ALLOW_NEGATIVE_STOCK_NO AS INT = 3

		,@ALLOW_ZERO_COST_NO AS INT = 1
		,@ALLOW_ZERO_COST_YES AS INT = 2

		,@COST_ADJUSTMENT_TYPE_DETAILED AS INT = 1
		,@COST_ADJUSTMENT_TYPE_SUMMARIZED AS INT = 1



-- Get the item location id. 
SELECT 
	@intItemLocationId = intItemLocationId
FROM 
	tblICItemLocation 
WHERE 
	intItemId = @intItemId 
	AND intLocationId = @intLocationId 	

-- If NULL, item location does not exists. It is safe to create a new item record. 
IF @intItemLocationId IS NULL 
BEGIN 
	INSERT INTO tblICItemLocation (
		intItemId 
		,intLocationId 
		,intVendorId 
		,intCostingMethod 
		,intAllowNegativeInventory 
		,intFamilyId 
		,intClassId 
		,intProductCodeId 
		,ysnTaxFlag1 
		,ysnTaxFlag2 
		,ysnTaxFlag3 
		,ysnTaxFlag4 
		,ysnSaleable 
		,ysnFoodStampable 
		,ysnReturnable 
		,ysnPrePriced 
		,ysnIdRequiredLiquor 
		,ysnIdRequiredCigarette 
		,intMinimumAge 
		,ysnApplyBlueLaw1 
		,ysnApplyBlueLaw2 
		,intAllowZeroCostTypeId 
		,intCostAdjustmentType 
		,intConcurrencyId 
		,dtmDateCreated 
		,intCreatedByUserId 
		,intDataSourceId
	)
	SELECT 
		intItemId = @intItemId
		,intLocationId = @intLocationId
		,intVendorId = @intVendorId
		,intCostingMethod = @AVG
		,intAllowNegativeInventory = @ALLOW_NEGATIVE_STOCK_NO
		,intFamilyId = @intFamilyId
		,intClassId = @intClassId
		,intProductCodeId = @intProductCodeId
		,ysnTaxFlag1 = @ysnTaxFlag1
		,ysnTaxFlag2 = @ysnTaxFlag2
		,ysnTaxFlag3 = @ysnTaxFlag3
		,ysnTaxFlag4 = @ysnTaxFlag4
		,ysnSaleable = @ysnSaleable
		,ysnFoodStampable = @ysnFoodStampable
		,ysnReturnable = @ysnReturnable
		,ysnPrePriced = @ysnPrePriced
		,ysnIdRequiredLiquor = @ysnIdRequiredLiquor
		,ysnIdRequiredCigarette = @ysnIdRequiredCigarette
		,intMinimumAge = @intMinimumAge
		,ysnApplyBlueLaw1 = @ysnApplyBlueLaw1
		,ysnApplyBlueLaw2 = @ysnApplyBlueLaw2
		,intAllowZeroCostTypeId = @ALLOW_ZERO_COST_NO
		,intCostAdjustmentType = @COST_ADJUSTMENT_TYPE_SUMMARIZED
		,intConcurrencyId = 1
		,dtmDateCreated = GETDATE()
		,intCreatedByUserId = @intEntityUserSecurityId
		,intDataSourceId = @intDataSourceId_CStore

	SELECT @intItemLocationId = SCOPE_IDENTITY()

	-- Create an audit log. 
	IF @intItemLocationId IS NOT NULL
	AND @intItemId IS NOT NULL 
	BEGIN 
		EXEC dbo.uspSMAuditLog 
			@keyValue = @intItemLocationId
			,@screenName = 'Inventory.view.ItemLocation'
			,@entityId = @intEntityUserSecurityId
			,@actionType = 'Created'
			,@changeDescription = 'C-Store created an Item Location.'
			,@fromValue = NULL 
			,@toValue = NULL  
	END
END 