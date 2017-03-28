CREATE PROCEDURE [dbo].[uspICGetDefaultReceiptTaxGroupId]
	@intFreightTermId AS INT = NULL
	,@intLocationId AS INT = NULL
	,@intEntityVendorId AS INT = NULL
	,@intEntityLocationId AS INT = NULL
	,@intTaxGroupId INT OUTPUT
	,@strTaxGroup NVARCHAR(50) OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN
	DECLARE @strFobPoint AS NVARCHAR(50)

	-- Get the Fob Point of the Freight Terms
	SELECT	@strFobPoint = FreightTerms.strFobPoint
	FROM	tblSMFreightTerms FreightTerms
	WHERE	FreightTerms.intFreightTermId = @intFreightTermId

	-- Get intTaxGroupId from Company Location for FOB destination
	IF RTRIM(LTRIM(LOWER(@strFobPoint))) = 'destination'
	BEGIN
		SELECT @intTaxGroupId = CompanyLocation.intTaxGroupId
				,@strTaxGroup = SMTaxGroup.strTaxGroup
		FROM	tblSMCompanyLocation CompanyLocation LEFT JOIN tblSMTaxGroup SMTaxGroup 
					ON CompanyLocation.intTaxGroupId = SMTaxGroup.intTaxGroupId
		WHERE	CompanyLocation.intCompanyLocationId = @intLocationId
	END

	-- Assign intTaxGroupId based on Hierarchy
	IF @intTaxGroupId IS NULL
	BEGIN
		-- Get intTaxGroupId from Vendor Special Pricing
		BEGIN			
			SELECT	@intTaxGroupId = Vendor.intTaxGroupId
			       ,@strTaxGroup = SMTaxGroup.strTaxGroup
			FROM	tblAPVendorSpecialTax Vendor LEFT JOIN tblSMTaxGroup SMTaxGroup 
						ON Vendor.intTaxGroupId = SMTaxGroup.intTaxGroupId
			WHERE	Vendor.intEntityVendorId = @intEntityVendorId
		END

		-- Get intTaxGroupId from Company Location
		IF @intTaxGroupId IS NULL
		BEGIN
			SELECT @intTaxGroupId = CompanyLocation.intTaxGroupId
				    ,@strTaxGroup = SMTaxGroup.strTaxGroup
			FROM	tblSMCompanyLocation CompanyLocation LEFT JOIN tblSMTaxGroup SMTaxGroup 
						ON CompanyLocation.intTaxGroupId = SMTaxGroup.intTaxGroupId
			WHERE CompanyLocation.intCompanyLocationId = @intLocationId
		END

		IF @intTaxGroupId IS NULL
		BEGIN
			SELECT	@intTaxGroupId = EntityLocation.intTaxGroupId
				    ,@strTaxGroup = SMTaxGroup.strTaxGroup
			FROM	tblEMEntityLocation EntityLocation LEFT JOIN tblSMTaxGroup SMTaxGroup 
						ON EntityLocation.intTaxGroupId = SMTaxGroup.intTaxGroupId
			WHERE	EntityLocation.intEntityId = @intEntityVendorId 
					AND EntityLocation.intEntityLocationId = @intEntityLocationId 
		END
	END
END
