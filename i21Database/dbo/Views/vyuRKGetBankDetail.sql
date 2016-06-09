CREATE VIEW vyuRKGetBankDetail
AS
SELECT convert(int,row_number() OVER(ORDER BY b.intBankId)) intRowNum, b.intBankId,b.strBankName,ba.intBankAccountId,ba.strBankAccountNo from tblCMBank b
JOIN tblCMBankAccount ba on b.intBankId=ba.intBankId