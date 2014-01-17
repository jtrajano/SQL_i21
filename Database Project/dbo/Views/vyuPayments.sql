CREATE VIEW [dbo].[vyuPayments]
AS 

SELECT 
	A.* ,
	B.strBankName,
	B.strBankAccountNo
	FROM tblAPPayment A
		LEFT JOIN tblCMBankAccount B
			ON A.intBankAccountId = B.intBankAccountID

