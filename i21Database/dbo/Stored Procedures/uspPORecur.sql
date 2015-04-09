CREATE PROCEDURE [dbo].[uspPORecur]
	@poId INT,
	@poDate DATETIME,
	@userId INT,
	@newPoId NVARCHAR(50) OUTPUT
AS
BEGIN

	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @InsertedData TABLE (intPOId INT, intType INT)

	--removed first the constraint
	ALTER TABLE tblPOPurchase
		DROP CONSTRAINT [UK_dbo.tblPOPurchase_strPurchaseOrderNumber]

	INSERT INTO tblPOPurchase(
		[intPurchaseId], 
		[intEntityVendorId], 
		[intAccountId], 
		[intFreightTermId], 
		[intCurrencyId], 
		[intOrderById], 
		[intApprovedById], 
		[intShipViaId], 
		[intShipFromId], 
		[intShipToId], 
		[intLocationId], 
		[intStoreId], 
		[intEntityId],
		[intTermsId],
		[intTransactionType],
		[dblTotal],
		[dblSubtotal],
		[dblShipping],
		[dblTax],
		[dblExchangeRate],
		[intOrderStatusId], 
		[strPurchaseOrderNumber], 
		[strVendorOrderNumber], 
		[strAdditionalInfo], 
		[strShipToAttention], 
		[strShipToAddress], 
		[strShipToCity], 
		[strShipToState], 
		[strShipToZipCode], 
		[strShipToCountry], 
		[strShipToPhone],
		[strShipFromAttention], 
		[strShipFromAddress], 
		[strShipFromCity], 
		[strShipFromState], 
		[strShipFromZipCode], 
		[strShipFromCountry], 
		[strShipFromPhone], 
		[strReference], 
		[dtmDate], 
		[dtmExpectedDate],
		[ysnPrepaid],
		[intConcurrencyId], 
		[dtmDateCreated]
	)

END