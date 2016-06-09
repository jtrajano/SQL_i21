--THIS WILL FIXED THOSE BILL WITH NULL CURRENCY ID
BEGIN TRY
BEGIN TRANSACTION #updateBillDetailCurrencies
SAVE TRANSACTION #updateBillDetailCurrencies
IF(EXISTS(SELECT 1 FROM tblAPBillDetail WHERE intCurrencyId IS NULL))
BEGIN
	UPDATE A
		SET A.intCurrencyId = CASE WHEN A.ysnSubCurrency > 0 THEN ISNULL(SubCurrency.intCurrencyID,0)
										 ELSE ISNULL(B.intCurrencyId,0) 
							 END 
	FROM dbo.tblAPBillDetail A
	INNER JOIN dbo.tblAPBill B ON A.intBillId = B.intBillId
	LEFT JOIN tblSMCurrency SubCurrency ON SubCurrency.intMainCurrencyId = B.intCurrencyId 
	WHERE A.intCurrencyId IS NULL
END
IF @@TRANCOUNT > 0
BEGIN
COMMIT TRANSACTION #updateBillDetailCurrencies
END
END TRY
BEGIN CATCH
ROLLBACK TRANSACTION #updateBillDetailCurrencies
END CATCH