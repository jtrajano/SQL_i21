/*
	Usage
	1. Create taxes for voucher detail.
	2. If there are changes made on voucher detail (except on purchase detail and IR Receipt), use this to recreate the taxes.
*/
CREATE PROCEDURE [dbo].[uspAPUpdateVoucherDetailTax]
	@billDetailIds AS Id READONLY
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @transCount INT = @@TRANCOUNT;
DECLARE @voucherIds AS Id;

IF @transCount = 0 BEGIN TRANSACTION

	IF (SELECT TOP 1 ysnPosted FROM tblAPBill A INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId 
				WHERE intBillDetailId IN (SELECT intId FROM @billDetailIds)) = 1
	BEGIN
		RAISERROR('Voucher was already posted.', 16, 1);
	END

	--DELETE EXISTING TAXES
	DELETE A
		FROM tblAPBillDetailTax A
	WHERE intBillDetailId IN (SELECT intId FROM @billDetailIds)
	
	DECLARE @ParamTable AS TABLE
		(intItemId					INT
		,intVendorId				INT
		,dtmTransactionDate			DATETIME
		,dblItemCost				NUMERIC(38,20)
		,dblQuantity				NUMERIC(38,20)
		,intTaxGroupId				INT
		,intCompanyLocationId		INT
		,intVendorLocationId		INT
		,ysnIncludeExemptedCodes	BIT
		,intFreightTermId			INT
		,ysnExcludeCheckOff			BIT
		,intBillDetailId			INT
		,intItemUOMId				INT)
		
	INSERT INTO @ParamTable
		(intItemId
		,intVendorId
		,dtmTransactionDate
		,dblItemCost
		,dblQuantity
		,intTaxGroupId
		,intCompanyLocationId
		,intVendorLocationId
		,ysnIncludeExemptedCodes
		,intFreightTermId
		,ysnExcludeCheckOff
		,intBillDetailId
		,intItemUOMId)
	SELECT
		 intItemId					= B.intItemId
		,intVendorId				= CASE WHEN A.intShipFromEntityId != A.intEntityVendorId THEN A.intShipFromEntityId ELSE A.intEntityVendorId END
		,dtmTransactionDate			= A.dtmDate
		,dblItemCost				= B.dblCost
		,dblQuantity				= CASE WHEN B.intWeightUOMId > 0 AND B.dblNetWeight > 0
										THEN B.dblNetWeight
										ELSE B.dblQtyReceived END
									-- CASE WHEN B.intWeightUOMId > 0 
										-- 	THEN dbo.fnCalculateQtyBetweenUOM(B.intWeightUOMId, ISNULL(NULLIF(B.intCostUOMId,0), B.intUnitOfMeasureId), B.dblNetWeight) 
										-- 	ELSE (CASE WHEN B.intCostUOMId > 0 THEN dbo.fnCalculateQtyBetweenUOM(B.intUnitOfMeasureId, B.intCostUOMId, B.dblQtyReceived) ELSE B.dblQtyReceived END)
										-- END
		,intTaxGroupId				= B.intTaxGroupId
		,intCompanyLocationId		= A.intShipToId
		,intVendorLocationId		= A.intShipFromId
		,ysnIncludeExemptedCodes	= 1
		,intFreightTermId           = ISNULL(B.intFreightTermId,
												CASE WHEN A.intShipFromEntityId != A.intEntityVendorId THEN EL_entity.intFreightTermId ELSE EL.intFreightTermId END)
		,ysnExcludeCheckOff			= 0
		,intBillDetailId			= B.intBillDetailId
		,intItemUOMId				= CASE WHEN B.intWeightUOMId > 0 AND B.dblNetWeight > 0
										THEN B.intWeightUOMId
										ELSE B.intUnitOfMeasureId END
	FROM tblAPBill A
	INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
	INNER JOIN tblEMEntityLocation EL ON EL.intEntityLocationId = A.intShipFromId --GET THE FREIGHT TERM FROM ENTITY LOCATION
	INNER JOIN @billDetailIds C ON B.intBillDetailId = C.intId		
	LEFT JOIN tblEMEntityLocation EL_entity ON EL_entity.intEntityLocationId = A.intShipFromEntityId

	INSERT INTO tblAPBillDetailTax(
		[intBillDetailId]		, 
		--[intTaxGroupMasterId]	, 
		[intTaxGroupId]			, 
		[intTaxCodeId]			, 
		[intTaxClassId]			, 
		[strTaxableByOtherTaxes], 
		[strCalculationMethod]	, 
		[dblRate]				, 
		[intAccountId]			, 
		[dblTax]				, 
		[dblAdjustedTax]		, 
		[ysnTaxAdjusted]		, 
		[ysnSeparateOnBill]		, 
		[ysnCheckOffTax]
	)
	SELECT
		[intBillDetailId]		=	A.intBillDetailId, 
		--[intTaxGroupMasterId]	=	NULL, 
		[intTaxGroupId]			=	Taxes.intTaxGroupId, 
		[intTaxCodeId]			=	Taxes.intTaxCodeId, 
		[intTaxClassId]			=	Taxes.intTaxClassId, 
		[strTaxableByOtherTaxes]=	Taxes.strTaxableByOtherTaxes, 
		[strCalculationMethod]	=	Taxes.strCalculationMethod, 
		[dblRate]				=	Taxes.dblRate, 
		[intAccountId]			=	Taxes.intTaxAccountId, 
		[dblTax]				=	ISNULL(Taxes.dblTax,0), 
		[dblAdjustedTax]		=	ISNULL(Taxes.dblAdjustedTax,0), 
		[ysnTaxAdjusted]		=	Taxes.ysnTaxAdjusted, 
		[ysnSeparateOnBill]		=	Taxes.ysnSeparateOnInvoice, 
		[ysnCheckOffTax]		=	Taxes.ysnCheckoffTax
	FROM @ParamTable A	
	CROSS APPLY fnGetItemTaxComputationForVendor
		(intItemId
		,intVendorId
		,dtmTransactionDate
		,dblItemCost
		,dblQuantity
		,intTaxGroupId
		,intCompanyLocationId
		,intVendorLocationId
		,ysnIncludeExemptedCodes
		,0 --@IncludeInvalidCodes
		,intFreightTermId
		,ysnExcludeCheckOff
		,intItemUOMId
		,NULL
		,NULL
		,NULL) Taxes
	WHERE Taxes.dblTax IS NOT NULL

	UPDATE A
		SET A.dblTax = TaxAmount.dblTax
						-- CASE WHEN D.intInventoryReceiptChargeId IS NOT NULL AND D.intInventoryReceiptChargeId > 0 AND D.ysnPrice = 1
						-- 		THEN TaxAmount.dblTax * -1 
						-- 	ELSE TaxAmount.dblTax
						-- END
			,A.intTaxGroupId = TaxAmount.intTaxGroupId
	FROM tblAPBillDetail A
	INNER JOIN @billDetailIds B ON A.intBillDetailId = B.intId
	CROSS APPLY (
		SELECT 
			SUM(CASE WHEN B.ysnTaxAdjusted = 1 THEN B.dblAdjustedTax ELSE B.dblTax END) dblTax
			,B.intTaxGroupId
		FROM tblAPBillDetailTax B WHERE B.intBillDetailId = A.intBillDetailId
		GROUP BY B.intTaxGroupId
	) TaxAmount
	LEFT JOIN tblICInventoryReceiptCharge D ON A.intInventoryReceiptChargeId = D.intInventoryReceiptChargeId
	WHERE TaxAmount.dblTax IS NOT NULL

	UPDATE A
		SET A.dblTax = TaxAmount.dblTax
	FROM tblAPBill A
	INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
	INNER JOIN @billDetailIds C ON B.intBillDetailId = C.intId
	CROSS APPLY (
		SELECT 
			SUM(dblTax) AS dblTax, SUM(dblTotal) dblTotal 
		FROM tblAPBillDetail WHERE intBillId = A.intBillId
	) TaxAmount
	WHERE TaxAmount.dblTax IS NOT NULL

	INSERT INTO @voucherIds
	SELECT DISTINCT
		A.intBillId 
	FROM tblAPBill A 
	INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId 
	INNER JOIN @billDetailIds C ON B.intBillDetailId = C.intId
	EXEC uspAPUpdateVoucherTotal @voucherIds

IF @transCount = 0 COMMIT TRANSACTION

END TRY
BEGIN CATCH
	DECLARE @ErrorSeverity INT,
			@ErrorNumber   INT,
			@ErrorMessage nvarchar(4000),
			@ErrorState INT,
			@ErrorLine  INT,
			@ErrorProc nvarchar(200);
	-- Grab error information from SQL functions
	SET @ErrorSeverity = ERROR_SEVERITY()
	SET @ErrorNumber   = ERROR_NUMBER()
	SET @ErrorMessage  = ERROR_MESSAGE()
	SET @ErrorState    = ERROR_STATE()
	SET @ErrorLine     = ERROR_LINE()
	IF @transCount = 0 AND XACT_STATE() <> 0 ROLLBACK TRANSACTION
	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH