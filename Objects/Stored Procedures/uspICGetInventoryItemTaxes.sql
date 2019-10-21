/*  This is a wrapper function to uspSMGetItemTaxes.
	uspSMGetItemTaxes is now expecting @UOMId as the primary key of tblICItemUOM instead of the primary key of tblICUnitMeasure.
	To make less code change, just use this wrapper so the @UOMId that will be passed by the consuming SQL calls 
	will still use the primary key of the tblICUnitMeasure.
*/
CREATE PROCEDURE [dbo].[uspICGetInventoryItemTaxes]
	 @ItemId					INT				= NULL
	,@LocationId				INT
	,@TransactionDate			DATETIME
	,@TransactionType			NVARCHAR(20) -- Purchase/Sale
	,@EntityId					INT				= NULL
	,@TaxGroupId				INT				= NULL
	,@BillShipToLocationId		INT				= NULL
	,@IncludeExemptedCodes		BIT				= NULL
	,@SiteId					INT				= NULL
	,@FreightTermId				INT				= NULL
	,@CardId					INT				= NULL
	,@VehicleId					INT				= NULL
	,@DisregardExemptionSetup	BIT				= 0
	,@CFSiteId					INT				= NULL
	,@IsDeliver					BIT				= NULL
	,@UOMId						INT				= NULL
AS

DECLARE @intItemUOMId INT

SELECT @intItemUOMId = im.intItemUOMId
FROM tblICItemUOM im
	INNER JOIN tblICUnitMeasure um ON um.intUnitMeasureId = im.intUnitMeasureId
WHERE um.intUnitMeasureId = @UOMId AND im.intItemId = @ItemId

RETURN EXEC dbo.uspSMGetItemTaxes
	 @ItemId					= @ItemId						
	,@LocationId				= @LocationId				
	,@TransactionDate			= @TransactionDate			
	,@TransactionType			= @TransactionType			
	,@EntityId					= @EntityId					
	,@TaxGroupId				= @TaxGroupId				
	,@BillShipToLocationId		= @BillShipToLocationId		
	,@IncludeExemptedCodes		= @IncludeExemptedCodes		
	,@SiteId					= @SiteId					
	,@FreightTermId				= @FreightTermId				
	,@CardId					= @CardId					
	,@VehicleId					= @VehicleId					
	,@DisregardExemptionSetup	= @DisregardExemptionSetup	
	,@CFSiteId					= @CFSiteId					
	,@IsDeliver					= @IsDeliver					
	,@UOMId						= @intItemUOMId