CREATE PROCEDURE [dbo].[uspAPCreateBillFromShipmentCharge]
	@shipmentId INT,
	@shipmentChargeId INT,
	@userId	INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @generatedBillId INT;
DECLARE @generatedBillRecordId NVARCHAR(50);
DECLARE @APAccount INT;
DECLARE @userLocation INT;
DECLARE @vendorId AS INT;

CREATE TABLE #tmpShipmentId (
	[intInventoryShipmentId] [INT] PRIMARY KEY,
	UNIQUE ([intInventoryShipmentId])
);

CREATE TABLE #tmpShipmentBillId (
	[intBillId] [INT] PRIMARY KEY,
	[intInventoryShipmentId] INT,
    [intEntityVendorId] INT,
    [intCurrencyId] INT
	UNIQUE ([intBillId])
);

CREATE TABLE #tmpCreatedBillDetail (
	[intBillDetailId] [INT]
	UNIQUE ([intBillDetailId])
);

--BEGIN TRANSACTION
INSERT INTO #tmpShipmentId(intInventoryShipmentId) SELECT [intID] FROM [dbo].fnGetRowsFromDelimitedValues(@shipmentId)

IF OBJECT_ID('tempdb..#tmpShipmentData') IS NOT NULL DROP TABLE #tmpShipmentData

SELECT SCB.* INTO #tmpShipmentData 
-- FROM vyuAPShipmentChargesForBilling SCB
FROM vyuAPShipmentChargesForBilling SCB
INNER JOIN #tmpShipmentId SI ON SCB.intInventoryShipmentId = SI.intInventoryShipmentId

SET @userLocation = (SELECT intCompanyLocationId FROM tblSMUserSecurity WHERE intEntityId = @userId);

--Get the company location of the user to get the default ap account else get from preference
SET @APAccount = (SELECT intAPAccount FROM tblSMCompanyLocation WHERE intCompanyLocationId = @userLocation)

--removed first the constraint
ALTER TABLE tblAPBill
	DROP CONSTRAINT [UK_dbo.tblAPBill_strBillId]

SELECT @vendorId = intEntityVendorId
FROM #tmpShipmentData WHERE intInventoryShipmentId = @shipmentId

--insert data in tblBill and tblBillDetail
SET @generatedBillId = (SELECT intBillId FROM #tmpShipmentBillId WHERE intEntityVendorId = @vendorId)

--CREATE HEADER RECORD IF NOT YET EXISTS FOR THE VENDOR OR PRODUCER
IF @generatedBillId IS NULL
BEGIN

	EXEC uspSMGetStartingNumber 9, @generatedBillRecordId OUT
	--process the inventory receipt/inventory return to voucher/debit memo. 
	INSERT INTO tblAPBill(
		[intEntityVendorId],
		--[strVendorOrderNumber], 
		[intTermsId], 
		--[intShipViaId],
		[intShipFromId],
		[intShipFromEntityId],
		[intShipToId],
		[dtmDate], 
		[dtmDateCreated], 
		[dtmBillDate],
		[dtmDueDate], 
		[intCurrencyId],
		[intAccountId], 
		[strBillId],
		[strReference], 
		[dblTotal], 
		[dblAmountDue],
		[intEntityId],
		[ysnPosted],
		[ysnPaid],
		[intTransactionType],
		[dblDiscount],
		[dblWithheld],
		[intStoreLocationId],
		[intPayToAddressId],
		[intSubCurrencyCents],
		[ysnPrepayHasPayment],
		[dbl1099],
		[dblSubtotal],
		[dblTax],
		[dblPayment],
		[dblInterest],
		[ysnApproved],
		[ysnForApproval],
		[ysnOrigin],
		[ysnDiscountOverride],
		[ysnForApprovalSubmitted],
		[ysnOldPrepayment]

		
	)
	OUTPUT inserted.intBillId, @shipmentId, @vendorId, inserted.intCurrencyId INTO #tmpShipmentBillId(intBillId, intInventoryShipmentId, intEntityVendorId, intCurrencyId)
	SELECT
		[intEntityVendorId]			=	@vendorId,
		--[strVendorOrderNumber] 		=	NULL, --user defined if selected record is from shipment
		[intTermsId] 				=	(SELECT intTermsId FROM vyuAPVendorDefault WHERE intEntityId = @vendorId),
		--[intShipViaId]				=	NULL,
		[intShipFromId]				=	NULLIF(Terms.intEntityLocationId,0),
		[intShipFromEntityId]		=	NULLIF(Terms.intEntityLocationId,0),
		[intShipToId]				=	A.intLocationId,
		[dtmDate] 					=	GETDATE(),
		[dtmDateCreated] 			=	GETDATE(),
		[dtmBillDate] 				=	GETDATE(),
		[dtmDueDate] 				=	GETDATE(),
		[intCurrencyId]				=	ISNULL(A.intCurrencyId,CAST((SELECT strValue FROM tblSMPreferences WHERE strPreference = 'defaultCurrency') AS INT)),
		[intAccountId] 				=	@APAccount,
		[strBillId]					=	@generatedBillRecordId,
		[strReference] 				=	A.strBillOfLading,
		[dblTotal] 					=	A.dblAmount,
		[dblAmountDue]				=	0,
		[intEntityId]				=	@userId,
		[ysnPosted]					=	CAST(0 AS BIT),
		[ysnPaid]					=	CAST(0 AS BIT),
		[intTransactionType]		=	1,
		[dblDiscount]				=	0,
		[dblWithheld]				=	0,
		[intStoreLocationId]		=	A.intLocationId,
		[intPayToAddressId]			=	ISNULL(NULLIF(Terms.intBillToId, 0),Terms.intEntityLocationId),
		[intSubCurrencyCents]		=	ISNULL(A.intSubCurrencyCents,1),
		[ysnPrepayHasPayment]		=	0,
		[dbl1099]					=	0,
		[dblSubtotal]				=	A.dblAmount,
		[dblTax] 					=	0,
		[dblPayment]				=	0,
		[dblInterest]				=	0,
		[ysnApproved]				=	CAST(0 AS BIT),
		[ysnForApproval]			=	CAST(0 AS BIT),
		[ysnOrigin]					=	CAST(0 AS BIT),
		[ysnDiscountOverride]		=	CAST(0 AS BIT),
		[ysnForApprovalSubmitted]	=	CAST(0 AS BIT),
		[ysnOldPrepayment]			=	CAST(0 AS BIT)
	FROM #tmpShipmentData A
	OUTER APPLY 
	(
		SELECT 
			C.intTermsId, B.intBillToId, C.intEntityLocationId
		FROM tblAPVendor B INNER JOIN tblEMEntityLocation C ON B.intEntityId = C.intEntityId AND C.ysnDefaultLocation = 1
		WHERE B.intEntityId = @vendorId
	) Terms
	WHERE A.intInventoryShipmentId = @shipmentId 
		--AND A.ysnPosted = 1

	SET @generatedBillId = SCOPE_IDENTITY()

	INSERT INTO tblAPBillDetail(
		[intBillId],
		[intItemId],
		[strMiscDescription],		
		[strComment],
		[intAccountId],
		[intUnitOfMeasureId],
		[intCostUOMId],	
		[intContractHeaderId],
		[intContractDetailId],
		[dblTotal],
		[dblQtyOrdered],
		[dblQtyReceived],
		[dblDiscount],
		[dblCost],
		[dblLandedCost],
		[dblTax],
		[dblActual],
		[dblDifference],
		[dblPrepayPercentage],
		[dblWeightUnitQty],
		[dblCostUnitQty],
		[dblUnitQty],
		[dblNetWeight],
		[dblVolume],
		[dblNetShippedWeight],
		[dblWeightLoss],
		[dblFranchiseWeight],
		[dblClaimAmount],
		[dbl1099],
		[int1099Form],
		[int1099Category],
		[ysn1099Printed],
		[ysnRestricted],
		[ysnSubCurrency],
		[intLineNo],
		[intInventoryShipmentChargeId],
		[intCurrencyId],
		[strBillOfLading],
		[dblQtyContract],
		[dblContractCost],
		[dblRate]
	)
	SELECT
		[intBillId]						=	@generatedBillId,
		[intItemId]						=	A.intItemId,
		[strMiscDescription]			=	A.strMiscDescription,		
		[strComment]					=	NULL,
		[intAccountId]					=	A.intAccountId,
		[intUnitOfMeasureId]			=	A.intCostUnitMeasureId,
		[intCostUOMId]					=	A.intCostUnitMeasureId,	
		[intContractHeaderId]			=	A.intContractDetailId,
		[intContractDetailId]			=	A.intContractDetailId,
		[dblTotal]						=	CAST((A.dblQuantityToBill * A.dblUnitCost) AS DECIMAL(18,2)),
		[dblQtyOrdered]					=	A.dblQuantityToBill,
		[dblQtyReceived]				=	A.dblQuantityToBill,
		[dblDiscount]					=	0,
		[dblCost]						=	A.dblUnitCost,
		[dblLandedCost]					=	0,
		[dblTax]						=	0,
		[dblActual]						=	0,
		[dblDifference]					=	0,
		[dblPrepayPercentage]			=	0,
		[dblWeightUnitQty]				=	1,
		[dblCostUnitQty]				=	1,
		[dblUnitQty]					=	1,
		[dblNetWeight]					=	0,
		[dblVolume]						=	0,
		[dblNetShippedWeight]			=	0,
		[dblWeightLoss]					=	0,
		[dblFranchiseWeight]			=	0,
		[dblClaimAmount]				=	0,
		[dbl1099]						=	0,
		[int1099Form]					=	0,
		[int1099Category]				=	0,
		[ysn1099Printed]				=	CAST(0 AS BIT),
		[ysnRestricted]					=	CAST(0 AS BIT),
		[ysnSubCurrency]				=	A.ysnSubCurrency,
		[intLineNo]						=	A.intLineNo,
		[intInventoryShipmentChargeId]	=	@shipmentChargeId,
		[intCurrencyId]					=	A.intCurrencyId,
		[strBillOfLading]				=	A.strBillOfLading,
		[dblQtyContract]				=	0,
		[dblContractCost]				=	0,
		[dblRate]						=	ISNULL(A.dblForexRate,1)
	FROM #tmpShipmentData A
	WHERE A.intInventoryShipmentChargeId = @shipmentChargeId

END
        
ALTER TABLE tblAPBill
	ADD CONSTRAINT [UK_dbo.tblAPBill_strBillId] UNIQUE (strBillId);

SELECT * FROM #tmpShipmentBillId

Post_Exit:
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpShipmentData')) DROP TABLE #tmpShipmentData

GO