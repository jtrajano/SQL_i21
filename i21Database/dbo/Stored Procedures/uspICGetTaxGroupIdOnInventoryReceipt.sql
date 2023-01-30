CREATE PROCEDURE [dbo].[uspICGetTaxGroupIdOnInventoryReceipt]
	@ReceiptId INT
	,@intTaxGroupId INT OUTPUT
	,@strTaxGroup NVARCHAR(50) OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

BEGIN
	SELECT	TOP 1
			@intTaxGroupId = taxGroup.intTaxGroupId
			,@strTaxGroup = taxGroup.strTaxGroup
	FROM	tblICInventoryReceipt r 
			LEFT JOIN tblSMCompanyLocation taxPointCompanyLocation
				ON taxPointCompanyLocation.intCompanyLocationId = r.intTaxLocationId
				AND r.strTaxPoint = 'Destination'

			LEFT JOIN tblEMEntityLocation taxPointEntityLocation
				ON taxPointEntityLocation.intEntityLocationId = r.intTaxLocationId
				AND r.strTaxPoint = 'Origin'

			CROSS APPLY (
				SELECT id = dbo.fnGetTaxGroupIdForVendor(
					ISNULL(r.intShipFromEntityId, r.intEntityVendorId) -- @VendorId
					,ISNULL(taxPointCompanyLocation.intCompanyLocationId, r.intLocationId)	--,@CompanyLocationId
					,NULL				--,@ItemId
					,ISNULL(taxPointEntityLocation.intEntityLocationId, r.intShipFromId)	--,@VendorLocationId
					,r.intFreightTermId --,@FreightTermId
					,r.strTaxPoint	--,@FOB
				)			
			) taxHierarchy
			INNER JOIN tblSMTaxGroup taxGroup
				ON taxGroup.intTaxGroupId = taxHierarchy.id 
	WHERE	r.intInventoryReceiptId = @ReceiptId
END
