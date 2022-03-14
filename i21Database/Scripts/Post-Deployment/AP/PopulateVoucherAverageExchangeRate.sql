PRINT N'START: POPULATING VOUCHER AVERAGE EXCHANGE RATE'
--POPULATE EMPTY VOUCHER AVERAGE EXCHANGE RATE
UPDATE B
SET B.dblAverageExchangeRate = (BD.dblTotalUSD / B.dblTotal)
FROM tblAPBill B
OUTER APPLY (
	SELECT COUNT(*) intDetailCount, SUM((dblTotal + dblTax)) dblTotal, SUM((dblTotal + dblTax) * dblRate) dblTotalUSD
	FROM tblAPBillDetail
	WHERE intBillId = B.intBillId
	
) BD
WHERE B.dblAverageExchangeRate IS NULL AND B.dblTotal <> 0 AND BD.intDetailCount > 0

PRINT N'SUCCESS: POPULATING VOUCHER AVERAGE EXCHANGE RATE'