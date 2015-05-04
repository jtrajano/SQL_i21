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

	DECLARE @InsertedData TABLE (intPOId INT)
	DECLARE @poRecordId NVARCHAR(50)

	--removed first the constraint
	ALTER TABLE tblPOPurchase
		DROP CONSTRAINT [UK_dbo.tblPOPurchase_strPurchaseOrderNumber]

	INSERT INTO tblPOPurchase(
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
		[dtmDateCreated]
	)
	OUTPUT inserted.intPurchaseId INTO @InsertedData
	SELECT
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
		1, 
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
		@poDate, 
		@poDate,
		[ysnPrepaid],
		GETDATE()
	FROM tblPOPurchase
	WHERE intPurchaseId = @poId

	INSERT INTO tblPOPurchaseDetail(
		[intPurchaseId], 
		[intItemId], 
		[intUnitOfMeasureId], 
		[intAccountId], 
		[intStorageLocationId],
		[intSubLocationId],
		[intLocationId],
		[intTaxId],
		[dblQtyOrdered], 
		[dblQtyContract], 
		[dblQtyReceived], 
		[dblVolume], 
		[dblWeight], 
		[dblDiscount], 
		[dblCost], 
		[dblTotal], 
		[strMiscDescription], 
		[strPONumber], 
		[dtmExpectedDate],
		[intLineNo]
	)
	SELECT
		[intPurchaseId], 
		[intItemId], 
		[intUnitOfMeasureId], 
		[intAccountId], 
		[intStorageLocationId],
		[intSubLocationId],
		[intLocationId],
		[intTaxId],
		[dblQtyOrdered], 
		[dblQtyContract], 
		0, 
		[dblVolume], 
		[dblWeight], 
		[dblDiscount], 
		[dblCost], 
		[dblTotal], 
		[strMiscDescription], 
		[strPONumber], 
		[dtmExpectedDate],
		[intLineNo]
	FROM tblPOPurchaseDetail
	WHERE intPurchaseId = @poId

	EXEC uspSMGetStartingNumber 22, @poRecordId OUT

	UPDATE A
		SET A.strPurchaseOrderNumber = @poRecordId
	FROM tblPOPurchase A
	WHERE A.intPurchaseId IN (SELECT intPOId FROM @InsertedData)

	SET @newPoId = @poRecordId;

	ALTER TABLE tblPOPurchase
	ADD CONSTRAINT [UK_dbo.tblPOPurchase_strPurchaseOrderNumber] UNIQUE (strPurchaseOrderNumber);

END