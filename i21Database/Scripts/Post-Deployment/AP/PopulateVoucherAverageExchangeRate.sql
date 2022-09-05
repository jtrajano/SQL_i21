PRINT N'START: POPULATING VOUCHER AVERAGE EXCHANGE RATE'
--POPULATE EMPTY VOUCHER AVERAGE EXCHANGE RATE
UPDATE B
--SET B.dblAverageExchangeRate = CASE WHEN B.ysnOrigin = 1 THEN 1 ELSE (BD.dblTotalUSD / B.dblTotal) END
SET B.dblAverageExchangeRate = CASE WHEN B.ysnOrigin = 1 THEN 1 ELSE BD.dblAverageExchangeRate END
FROM tblAPBill B
OUTER APPLY (
	SELECT COUNT(*) intDetailCount, SUM((dblTotal + dblTax) * dblRate) / SUM((dblTotal + dblTax))  AS dblAverageExchangeRate
	--SUM((dblTotal + dblTax)) dblTotal, SUM((dblTotal + dblTax) * dblRate) dblTotalUSD
	FROM tblAPBillDetail
	WHERE intBillId = B.intBillId
	
) BD
WHERE B.dblTotal <> 0 AND BD.intDetailCount > 0

--POPULATE EMPTY VOUCHER AVERAGE EXCHANGE RATE (ARCHIVED)
UPDATE B
--SET B.dblAverageExchangeRate = CASE WHEN B.ysnOrigin = 1 THEN 1 ELSE (BD.dblTotalUSD / B.dblTotal) END
SET B.dblAverageExchangeRate = CASE WHEN B.ysnOrigin = 1 THEN 1 ELSE BD.dblAverageExchangeRate END
FROM tblAPBillArchive B
OUTER APPLY (
	SELECT COUNT(*) intDetailCount, SUM((dblTotal + dblTax) * dblRate) / SUM((dblTotal + dblTax))  AS dblAverageExchangeRate
	--SUM((dblTotal + dblTax)) dblTotal, SUM((dblTotal + dblTax) * dblRate) dblTotalUSD
	FROM tblAPBillDetailArchive
	WHERE intBillId = B.intBillId
	
) BD
WHERE B.dblTotal <> 0 AND BD.intDetailCount > 0

PRINT N'SUCCESS: POPULATING VOUCHER AVERAGE EXCHANGE RATE'