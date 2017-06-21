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
	SELECT	TOP 1
			@intTaxGroupId = taxGroup.intTaxGroupId
			,@strTaxGroup = taxGroup.strTaxGroup
	FROM	(
				SELECT id = dbo.fnGetTaxGroupIdForVendor(
					@intEntityVendorId		-- @VendorId
					,@intLocationId			--,@CompanyLocationId
					,NULL					--,@ItemId
					,@intEntityLocationId	--,@VendorLocationId
					,@intFreightTermId		--,@FreightTermId
				)			
			) taxHierarchy
			INNER JOIN tblSMTaxGroup taxGroup
				ON taxGroup.intTaxGroupId = taxHierarchy.id 
END
