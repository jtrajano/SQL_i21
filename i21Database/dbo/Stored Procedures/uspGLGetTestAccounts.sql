CREATE PROCEDURE [dbo].[uspGLGetTestAccounts]
AS
declare @baseCurrency int
select top 1 @baseCurrency = intDefaultCurrencyId from tblSMCompanyPreference 

;with mul as
(
select top 2 a.intAccountId, count(1)cnt from vyuGLExchangeRate a join vyuGLAccountDetail b on a.intAccountId = b.intAccountId
 group by a.intAccountId, intFromCurrencyId,intToCurrencyId,strAccountCategory 
 having intToCurrencyId =@baseCurrency and strAccountCategory = 'General'  order by cnt
)
select top 2 strAccountId, a.strCurrency from vyuGLAccountDetail a join mul b 
on a.intAccountId = b.intAccountId 
join tblSMCurrency c on a.intCurrencyID  = c.intCurrencyID


select top 2 strAccountId from vyuGLAccountDetail where intCurrencyID = @baseCurrency and strAccountCategory = 'General'