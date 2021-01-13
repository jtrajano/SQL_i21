--VENDOR
UPDATE E
SET E.str1099Form = '1099-NEC',
	E.str1099Type = 'Nonemployee Compensation'
FROM tblEMEntity E
WHERE E.str1099Form = '1099-MISC' AND E.str1099Type = 'Nonemployee Compensation'


--VOUCHERS
UPDATE BD
SET BD.int1099Form = 7,
	BD.int1099Category = 8
FROM tblAPBillDetail BD
INNER JOIN tblAPBill B ON B.intBillId = BD.intBillId
OUTER APPLY (
	SELECT Y.strFiscalYear
	FROM tblGLFiscalYearPeriod YP
	INNER JOIN tblGLFiscalYear Y ON Y.intFiscalYearId = YP.intFiscalYearId
	WHERE B.dtmDate BETWEEN YP.dtmStartDate AND YP.dtmEndDate OR B.dtmDate = YP.dtmStartDate OR B.dtmDate = YP.dtmEndDate
) FP
WHERE CONVERT(INT, strFiscalYear) >= 2020 AND BD.int1099Form = 1 AND BD.int1099Category = 8