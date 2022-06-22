﻿CREATE PROCEDURE [dbo].[uspICGetTaxGroupIdOnInventoryReceipt]
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
			CROSS APPLY (
				SELECT id = dbo.fnGetTaxGroupIdForVendor(
					ISNULL(r.intShipFromEntityId, r.intEntityVendorId) -- @VendorId
					,r.intLocationId	--,@CompanyLocationId
					,NULL				--,@ItemId
					,r.intShipFromId	--,@VendorLocationId
					,r.intFreightTermId --,@FreightTermId
					,default			--,@FOB
				)			
			) taxHierarchy
			INNER JOIN tblSMTaxGroup taxGroup
				ON taxGroup.intTaxGroupId = taxHierarchy.id 
	WHERE	r.intInventoryReceiptId = @ReceiptId
END
