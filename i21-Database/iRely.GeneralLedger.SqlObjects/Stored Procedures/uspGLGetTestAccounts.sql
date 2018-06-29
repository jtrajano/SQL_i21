CREATE PROCEDURE [dbo].[uspGLGetTestAccounts]
AS
declare @baseCurrency int
select top 1 @baseCurrency = intDefaultCurrencyId from tblSMCompanyPreference 

;with mul as
(

select top 2 a.intAccountId,dblRate, dtmValidFromDate from vyuGLExchangeRate a join vyuGLAccountDetail b on a.intAccountId = b.intAccountId
 group by a.intAccountId, intFromCurrencyId,intToCurrencyId,strAccountCategory, dblRate ,dtmValidFromDate
 having intToCurrencyId =3 and strAccountCategory = 'General'  
 order by dtmValidFromDate desc

)
select top 2 strAccountId, a.strCurrency,dblRate from vyuGLAccountDetail a join mul b 
on a.intAccountId = b.intAccountId 
join tblSMCurrency c on a.intCurrencyID  = c.intCurrencyID


select top 2 strAccountId from vyuGLAccountDetail where intCurrencyID = @baseCurrency and strAccountCategory = 'General'
select top 1 strCurrency basecurrency from tblSMCurrency where intCurrencyID = @baseCurrency