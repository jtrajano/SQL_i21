CREATE PROC uspRKCurExpBankBalance

AS

SELECT  convert(int,ROW_NUMBER() OVER(order by strCompanyName)) as intRowNum,
SM.strCompanyName
,strBankName
,strBankAccountNo
,SMC.strCurrency
,strGLAccountId
,GL.strAccountType
,Balance.Value as dblBankBalance
,1 as intConcurrencyId
FROM vyuCMBankAccount CM
OUTER APPLY (select [dbo].[fnGetBankBalance] (intBankAccountId, getdate()) Value ) Balance
OUTER APPLY (select top 1 strCompanyName from tblSMCompanySetup)SM
LEFT JOIN tblSMCurrency SMC on SMC.intCurrencyID =  CM.intCurrencyId
LEFT join vyuGLAccountDetail GL on CM.strGLAccountId = GL.strAccountId
where GL.strAccountType='Asset'