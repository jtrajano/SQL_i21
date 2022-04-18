CREATE VIEW vyuRKGetBankDetail
AS
SELECT convert(int,row_number() OVER(ORDER BY b.intBankId)) intRowNum
	, b.intBankId
	, b.strBankName
	, ba.intBankAccountId
	, ba.strBankAccountNo 
FROM tblCMBank b
JOIN vyuCMBankAccount ba on b.intBankId=ba.intBankId 