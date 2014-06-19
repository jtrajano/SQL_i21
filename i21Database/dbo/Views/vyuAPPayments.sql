CREATE VIEW [dbo].[vyuAPPayments]
AS 

SELECT 
	A.* ,
	C.strBankName,
	B.strBankAccountNo,
	D.strVendorId
	FROM tblAPPayment A
		LEFT JOIN tblCMBankAccount B
			ON A.intBankAccountId = B.intBankAccountId
		LEFT JOIN tblCMBank C
			ON B.intBankId = C.intBankId
		LEFT JOIN tblAPVendor D
			ON A.intVendorId = D.intEntityId