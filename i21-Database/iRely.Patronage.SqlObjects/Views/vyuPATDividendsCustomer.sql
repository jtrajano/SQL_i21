CREATE VIEW [dbo].[vyuPATDividendsCustomer]
	AS
SELECT	DC.intDividendCustomerId,
		D.intDividendId,
		D.strDividendNo,
		D.dtmProcessDate,
		D.intFiscalYearId,
		FY.strFiscalYear,
		DC.intCustomerId,
		E.strName,
		E.strEntityNo,
		ARC.strStockStatus,
		ARC.dtmLastActivityDate,
		TC.strTaxCode,
		DC.dblDividendAmount,
		DC.dblLessFWT,
		DC.dblCheckAmount,
		ysnVouchered = CAST(CASE WHEN DC.intBillId IS NOT NULL THEN  1 ELSE 0 END AS BIT),
		DC.intBillId,
		APB.strBillId,
		DC.intConcurrencyId
FROM tblPATDividendsCustomer DC
INNER JOIN tblPATDividends D
	ON D.intDividendId = DC.intDividendId
INNER JOIN tblGLFiscalYear FY
	ON FY.intFiscalYearId = D.intFiscalYearId
INNER JOIN tblEMEntity E
	ON E.intEntityId = DC.intCustomerId
INNER JOIN tblARCustomer ARC
	ON ARC.intEntityId = E.intEntityId
LEFT OUTER JOIN tblSMTaxCode TC
	ON TC.intTaxCodeId = ARC.intTaxCodeId
LEFT JOIN tblAPBill APB
	ON APB.intBillId = DC.intBillId
