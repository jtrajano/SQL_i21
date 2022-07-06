CREATE PROCEDURE [dbo].[uspICAddItemUOMForCStore]
	@intUnitMeasureId AS INT 
	,@intItemId AS INT 
	,@strLongUPCCode NVARCHAR(50) = NULL
	,@ysnStockUnit AS BIT = 1
	,@intEntityUserSecurityId AS INT 
	,@intItemUOMId AS INT = NULL OUTPUT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

DECLARE @intDataSourceId_CStore AS TINYINT = 1

-- Get the item uom id. 
SELECT 
	@intItemUOMId = intItemUOMId 
FROM 
	tblICItemUOM 
WHERE 
	intItemId = @intItemId 
	AND intUnitMeasureId = @intUnitMeasureId	

-- If NULL, item uom does not exists. It is safe to create a new item record. 
IF @intItemUOMId IS NULL 
AND NOT EXISTS (SELECT TOP 1 1 FROM tblICItemUOM WHERE intItemId = @intItemId AND ysnStockUnit = 1) 
BEGIN 
	INSERT INTO tblICItemUOM(
		intItemId
		,intUnitMeasureId
		,dblUnitQty
		,strUpcCode
		,strLongUPCCode
		,ysnStockUnit
		,ysnAllowPurchase
		,ysnAllowSale
		,intSort
		,intConcurrencyId
		,dtmDateCreated
		,intCreatedByUserId
		,intDataSourceId
	)
	SELECT 
		intItemId = @intItemId
		,intUnitMeasureId = @intUnitMeasureId
		,dblUnitQty = 1
		,strUpcCode = CASE WHEN dbo.fnUPCAtoUPCE(@strLongUPCCode) = '' THEN NULL ELSE dbo.fnUPCAtoUPCE(@strLongUPCCode) END
		,strLongUPCCode = @strLongUPCCode
		,ysnStockUnit = @ysnStockUnit
		,ysnAllowPurchase = 1
		,ysnAllowSale = 1
		,intSort = 1
		,intConcurrencyId = 1
		,dtmDateCreated = GETDATE()
		,intCreatedByUserId = @intEntityUserSecurityId
		,intDataSourceId = @intDataSourceId_CStore

	SELECT @intItemUOMId = SCOPE_IDENTITY()

	-- Create an audit log. 
	IF @intItemUOMId IS NOT NULL
	AND @intItemId IS NOT NULL 
	BEGIN 
		EXEC dbo.uspSMAuditLog 
			@keyValue = @intItemId
			,@screenName = 'Inventory.view.Item'
			,@entityId = @intEntityUserSecurityId
			,@actionType = 'Updated'
			,@changeDescription = 'C-Store created an Item UOM.'
			,@fromValue = NULL 
			,@toValue = @intItemUOMId 
	END
END 