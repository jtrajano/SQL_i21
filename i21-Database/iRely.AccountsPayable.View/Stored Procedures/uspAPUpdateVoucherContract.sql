CREATE PROCEDURE [dbo].[uspAPUpdateVoucherContract]
	@billId INT
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

	IF (SELECT ysnPosted FROM tblAPBill WHERE intBillId = @billId) = 1
	BEGIN
		RAISERROR('Voucher was already posted.', 16, 1);
	END

	UPDATE A
		SET A.dblCost = CASE WHEN A.intContractDetailId > 0 THEN 
							(CASE WHEN C.intPricingTypeId = 7 THEN ISNULL(IndexPrice.dblIndexPrice,0) ELSE C.dblCashPrice END)
						ELSE A.dblCost END
		,A.dblContractCost = CASE WHEN A.intContractDetailId > 0 THEN
							 (CASE WHEN C.intPricingTypeId = 7 THEN ISNULL(IndexPrice.dblIndexPrice,0) ELSE C.dblCashPrice END)
						ELSE 0 END
		,A.dblQtyContract = CASE WHEN A.intContractDetailId > 0 THEN C.dblBalance ELSE 0 END
	FROM tblAPBillDetail A
	INNER JOIN tblAPBill B ON A.intBillId = B.intBillId
	INNER JOIN tblCTContractDetail C ON A.intContractDetailId = A.intContractDetailId
	CROSS APPLY (
		SELECT E.strRackPriceToUse FROM tblTRCompanyPreference E
	) CompanyPref
	LEFT JOIN tblTRSupplyPoint D ON B.intEntityVendorId = D.intEntityVendorId AND B.intShipFromId = D.intEntityLocationId
	OUTER APPLY (
		SELECT TOP 1 (CASE
					WHEN CompanyPref.strRackPriceToUse = 'Vendor'
					THEN RP.dblVendorRack
					WHEN CompanyPref.strRackPriceToUse = 'Jobber'
					THEN RP.dblJobberRack
					END) + ISNULL(C.dblAdjustment,0) AS dblIndexPrice
	   FROM vyuTRGetRackPriceDetail RP 	   
	   WHERE RP.intSupplyPointId = D.intSupplyPointId 
	     AND RP.intItemId = A.intItemId
	     AND RP.dtmEffectiveDateTime <= B.dtmDate
       ORDER BY RP.dtmEffectiveDateTime DESC
	) IndexPrice
	WHERE A.intBillId = @billId

	INSERT INTO @voucherIds
	SELECT @billId
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
	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH