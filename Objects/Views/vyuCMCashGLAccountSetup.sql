CREATE VIEW [dbo].[vyuCMCashGLAccountSetup]
AS 

SELECT 
* 
FROM vyuGLAccountDetail
WHERE 
strAccountCategory = 'Cash Account' 
AND intAccountId NOT IN (select distinct intAccountId from tblGLDetail where intAccountId not in (select intGLAccountId from tblCMBankAccount))