PRINT N'START: POPULATING VOUCHER AVERAGE EXCHANGE RATE'
--POPULATE EMPTY VOUCHER AVERAGE EXCHANGE RATE
UPDATE B
--SET B.dblAverageExchangeRate = CASE WHEN B.ysnOrigin = 1 THEN 1 ELSE (BD.dblTotalUSD / B.dblTotal) END
SET B.dblAverageExchangeRate = CASE WHEN B.ysnOrigin = 1 OR B.dblTotal = 0 THEN 1 ELSE ISNULL(BD.dblAverageExchangeRate,1) END
FROM tblAPBill B
LEFT JOIN (
	SELECT 
		intBillId,
		SUM((ISNULL(NULLIF(dblTotal,0),1) + dblTax) * dblRate) / SUM((ISNULL(NULLIF(dblTotal,0),1) + dblTax)) AS dblAverageExchangeRate
	FROM tblAPBillDetail dtl
	GROUP BY dtl.intBillId
	HAVING SUM((ISNULL(NULLIF(dblTotal,0),1))) > 0
) BD ON B.intBillId = BD.intBillId

UPDATE B
--SET B.dblAverageExchangeRate = CASE WHEN B.ysnOrigin = 1 THEN 1 ELSE (BD.dblTotalUSD / B.dblTotal) END
SET B.dblAverageExchangeRate = CASE WHEN B.ysnOrigin = 1 OR B.dblTotal = 0 THEN 1 ELSE ISNULL(BD.dblAverageExchangeRate,1) END
FROM tblAPBillArchive B
LEFT JOIN (
	SELECT 
		intBillId,
		SUM((ISNULL(NULLIF(dblTotal,0),1) + dblTax) * dblRate) / SUM((ISNULL(NULLIF(dblTotal,0),1) + dblTax)) AS dblAverageExchangeRate
	FROM tblAPBillDetailArchive dtl
	GROUP BY dtl.intBillId
	HAVING SUM((ISNULL(NULLIF(dblTotal,0),1))) > 0
) BD ON B.intBillId = BD.intBillId
PRINT N'SUCCESS: POPULATING VOUCHER AVERAGE EXCHANGE RATE'