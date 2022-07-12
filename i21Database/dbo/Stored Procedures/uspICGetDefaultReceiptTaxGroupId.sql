﻿CREATE PROCEDURE [dbo].[uspICGetDefaultReceiptTaxGroupId]
	@intFreightTermId AS INT = NULL
	,@intLocationId AS INT = NULL
	,@intItemId AS INT = NULL 
	,@intEntityVendorId AS INT = NULL
	,@intEntityLocationId AS INT = NULL
	,@strFOB AS NVARCHAR(100) = NULL 
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
	FROM	(
				SELECT id = dbo.fnGetTaxGroupIdForVendor(
					@intEntityVendorId		-- @VendorId
					,@intLocationId			--,@CompanyLocationId
					,@intItemId				--,@ItemId
					,@intEntityLocationId	--,@VendorLocationId
					,@intFreightTermId		--,@FreightTermId
					,@strFOB				--,@FOB
				)			
			) taxHierarchy
			INNER JOIN tblSMTaxGroup taxGroup
				ON taxGroup.intTaxGroupId = taxHierarchy.id 
END
