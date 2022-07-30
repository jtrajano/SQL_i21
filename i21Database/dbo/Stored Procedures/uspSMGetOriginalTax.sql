CREATE PROCEDURE [dbo].[uspSMGetOriginalTax]
	 @ItemId						INT			= NULL
	,@LocationId					INT			= NULL
	,@TransactionType				NVARCHAR(20)='Purchase'
	,@EntityId						INT			= NULL
	,@ShipLocationId				INT			= NULL
	,@SiteId						INT			= NULL
	,@FreightTermId					INT			= NULL
	,@OriginalTaxGroupId			INT			= 0		OUTPUT
AS

BEGIN
	IF (@TransactionType = 'Sale')
	BEGIN
		SELECT @OriginalTaxGroupId = ISNULL([dbo].[fnGetTaxGroupIdForCustomer](@EntityId, @LocationId, @ItemId, @BillShipToLocationId, @SiteId, @FreightTermId, NULL), 0)
	END
	ELSE
	BEGIN
		SELECT @OriginalTaxGroupId = ISNULL([dbo].[fnGetTaxGroupIdForVendor](@EntityId, @LocationId, @ItemId, @BillShipToLocationId, @FreightTermId, NULL), 0)
	END

	RETURN @OriginalTaxGroupId
END