CREATE VIEW [dbo].[vyuCMBankTransaction]
AS 

SELECT * FROM tblCMBankTransaction
WHERE dbo.fnIsDepositEntry(strLink) = 0 
