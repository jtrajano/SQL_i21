CREATE PROCEDURE [dbo].[uspICGetTaxGroupIdOnInventoryReceipt]
	@ReceiptId INT
	,@intTaxGroupId INT OUTPUT
	,@strTaxGroup NVARCHAR(50) OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN
	DECLARE @FOB_Point NVARCHAR(50)		

	SELECT @FOB_Point = FreightTerms.strFobPoint
	FROM tblICInventoryReceipt Receipt 
		 LEFT JOIN tblSMFreightTerms FreightTerms ON FreightTerms.intFreightTermId = Receipt.intFreightTermId
	WHERE Receipt.intInventoryReceiptId = @ReceiptId

	-- Get intTaxGroupId from Company Location for FOB destination
	IF LTRIM(LOWER(@FOB_Point)) = 'destination'
		BEGIN
			SELECT @intTaxGroupId = CompanyLocation.intTaxGroupId
				   ,@strTaxGroup = SMTaxGroup.strTaxGroup
			FROM tblICInventoryReceipt Receipt 
				 LEFT JOIN tblSMCompanyLocation CompanyLocation ON CompanyLocation.intCompanyLocationId = Receipt.intLocationId
				 LEFT JOIN tblSMTaxGroup SMTaxGroup ON CompanyLocation.intTaxGroupId = SMTaxGroup.intTaxGroupId
			WHERE Receipt.intInventoryReceiptId = @ReceiptId
		END

	-- Assign intTaxGroupId based on Hierarchy
	IF @intTaxGroupId IS NULL
	BEGIN
		BEGIN
			-- Get intTaxGroupId from Vendor Special Pricing
			SELECT @intTaxGroupId = Vendor.intTaxGroupId
			       ,@strTaxGroup = SMTaxGroup.strTaxGroup
			FROM tblICInventoryReceipt Receipt 
				 LEFT JOIN tblAPVendorSpecialTax Vendor ON Vendor.intEntityVendorId = Receipt.intEntityVendorId
				 LEFT JOIN tblSMTaxGroup SMTaxGroup ON Vendor.intTaxGroupId = SMTaxGroup.intTaxGroupId
			WHERE Receipt.intInventoryReceiptId = @ReceiptId 
		END

		-- Get intTaxGroupId from Company Location
		IF @intTaxGroupId IS NULL
			BEGIN
				SELECT @intTaxGroupId = CompanyLocation.intTaxGroupId
				       ,@strTaxGroup = SMTaxGroup.strTaxGroup
				FROM tblICInventoryReceipt Receipt 
					LEFT JOIN tblSMCompanyLocation CompanyLocation ON CompanyLocation.intCompanyLocationId = Receipt.intLocationId
					LEFT JOIN tblSMTaxGroup SMTaxGroup ON CompanyLocation.intTaxGroupId = SMTaxGroup.intTaxGroupId
				WHERE Receipt.intInventoryReceiptId = @ReceiptId
			END

		IF @intTaxGroupId IS NULL
			BEGIN
				SELECT @intTaxGroupId = EntityLocation.intTaxGroupId
				       ,@strTaxGroup = SMTaxGroup.strTaxGroup
				FROM tblICInventoryReceipt Receipt 
					 LEFT JOIN tblEMEntityLocation EntityLocation ON EntityLocation.intEntityId = Receipt.intEntityVendorId AND EntityLocation.intEntityLocationId = Receipt.intShipFromId
					LEFT JOIN tblSMTaxGroup SMTaxGroup ON EntityLocation.intTaxGroupId = SMTaxGroup.intTaxGroupId
				WHERE Receipt.intInventoryReceiptId = @ReceiptId
			END
	END
END
