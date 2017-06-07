CREATE FUNCTION [dbo].[fnARGetLocationItemVendorDetailsForPricing]
(
	 @ItemId				INT
	,@CustomerId			INT	
	,@LocationId			INT
	,@ItemUOMId				INT
	,@VendorId				INT
	,@ShipToLocationId      INT
	,@VendorLocationId		INT
)
RETURNS @returntable TABLE
(
	 intItemVendorId				INT
	,intItemLocationId				INT
	,intItemCategoryId				INT
	,strItemCategory				NVARCHAR(100)
	,dblUOMQuantity					NUMERIC(18,6)
	,intCustomerShipToLocationId	INT
	,intVendorShipFromLocationId	INT
)
AS
BEGIN

	IF ISNULL(@ItemUOMId,0) = 0
		SELECT TOP 1 @ItemUOMId = intItemUOMId FROM tblICItemUOM WHERE intItemId = @ItemId AND ysnStockUnit = 1
	
	DECLARE @ItemVendorId		INT
			,@ItemLocationId	INT
			,@ItemCategoryId	INT
			,@ItemCategory		NVARCHAR(100)
			,@UOMQuantity		NUMERIC(18,6)
			,@CustomerShipToLocationId	INT
			,@VendorShipFromLocationId	INT

	SELECT TOP 1 
		 @ItemVendorId		= ISNULL(@VendorId, VI.intVendorId)
		,@ItemLocationId	= intItemLocationId
		,@ItemCategoryId	= I.intCategoryId
		,@ItemCategory		= UPPER(LTRIM(RTRIM(ISNULL(C.strCategoryCode,''))))
		,@UOMQuantity		= UOM.dblUnitQty
	FROM
		tblICItem I
	INNER JOIN
		vyuICGetItemStock VI
			ON I.intItemId = VI.intItemId
	LEFT OUTER JOIN
		tblICCategory C
			ON I.intCategoryId = C.intCategoryId
	LEFT OUTER JOIN
		tblICItemUOM UOM
			ON I.intItemId = UOM.intItemId
	WHERE
		I.intItemId = @ItemId
		AND (VI.intLocationId = @LocationId OR @LocationId IS NULL)
		AND (UOM.intItemUOMId = @ItemUOMId OR @ItemUOMId IS NULL)
		
	IF ISNULL(@UOMQuantity,0) = 0 
		SELECT TOP 1 @UOMQuantity = dblUnitQty FROM tblICItemUOM WHERE intItemId = @ItemId AND ysnStockUnit = 1 AND intItemUOMId = @ItemUOMId
		
	SELECT
		@CustomerShipToLocationId = ISNULL(@ShipToLocationId, ShipToLocation.intEntityLocationId)
	FROM 
		tblARCustomer Customer
		--LEFT OUTER JOIN
		--	(	SELECT
		--			intEntityLocationId
		--			,intEntityId 
		--			,strCountry
		--			,strState
		--			,strCity
		--		FROM tblEMEntityLocation
		--		WHERE ysnDefaultLocation = 1
		--	) EntityLocation 
		--	ON Customer.intEntityCustomerId = EntityLocation.intEntityId
	LEFT OUTER JOIN 
		[tblEMEntityLocation] ShipToLocation 
			ON Customer.intShipToId = ShipToLocation.intEntityLocationId
	WHERE 
		Customer.[intEntityId] = @CustomerId
		
	SELECT
		@VendorShipFromLocationId = ISNULL(@VendorLocationId,ISNULL(ShipFromLocation.intEntityLocationId, EntityLocation.intEntityLocationId))
	FROM 
		tblAPVendor Vendor
		LEFT OUTER JOIN
			(	SELECT
					intEntityLocationId
					,intEntityId 
					,strCountry
					,strState
					,strCity
				FROM [tblEMEntityLocation]
				WHERE ysnDefaultLocation = 1
			) EntityLocation 
			ON Vendor.[intEntityId] = EntityLocation.intEntityId
	LEFT OUTER JOIN 
		[tblEMEntityLocation] ShipFromLocation 
			ON Vendor.intShipFromId = ShipFromLocation.intEntityLocationId
	WHERE 
		Vendor.[intEntityId] = @ItemVendorId						
			
	
	INSERT @returntable
	SELECT @ItemVendorId, @ItemLocationId, @ItemCategoryId, @ItemCategory, @UOMQuantity,@CustomerShipToLocationId, @VendorShipFromLocationId
	RETURN				
END
