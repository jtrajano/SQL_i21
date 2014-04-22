CREATE VIEW [dbo].[vyuPayments]
AS 

SELECT 
	A.* ,
	C.strBankName,
	B.strBankAccountNo
	FROM tblAPPayment A
		LEFT JOIN tblCMBankAccount B
			ON A.intBankAccountId = B.intBankAccountId
		LEFT JOIN tblCMBank C
			ON B.intBankId = C.intBankId