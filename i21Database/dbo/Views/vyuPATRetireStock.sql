CREATE VIEW [dbo].[vyuPATRetireStock]
	AS
SELECT  RetireStk.intRetireStockId,
		RetireStk.strRetireNo,
		RetireStk.dtmRetireDate,
		RetireStk.intCustomerStockId,
		CS.intCustomerPatronId,
		C.strEntityNo,
		C.strName,
		CS.intStockId,
		PC.strStockName,
		CS.strCertificateNo,
		CS.strStockStatus,
		CS.strActivityStatus,
		RetireStk.dblSharesNo,
		RetireStk.dblFaceValue,
		RetireStk.dblParValue,
		RetireStk.ysnPosted,
		RetireStk.intBillId,
		APB.strBillId,
		strCheckNumber = APPAY.strPaymentInfo,
		dtmCheckDate = APPAY.dtmDatePaid,
		dblCheckAmount = APPAY.dblPayment,
		RetireStk.intConcurrencyId

FROM tblPATRetireStock RetireStk
INNER JOIN tblPATCustomerStock CS
	ON CS.intCustomerStockId = RetireStk.intCustomerStockId
INNER JOIN tblEMEntity C
	ON C.intEntityId = CS.intCustomerPatronId
INNER JOIN tblPATStockClassification PC
	ON PC.intStockId = CS.intStockId
LEFT OUTER JOIN tblAPBill APB
	ON APB.intBillId = RetireStk.intBillId
LEFT OUTER JOIN (SELECT A.strPaymentInfo, B.intBillId, A.dtmDatePaid, B.dblPayment FROM tblAPPayment A INNER JOIN tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId) APPAY
		ON APPAY.intBillId = RetireStk.intBillId