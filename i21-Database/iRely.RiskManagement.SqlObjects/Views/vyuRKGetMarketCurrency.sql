CREATE VIEW [dbo].[vyuRKGetMarketCurrency]
AS  
SELECT intFutureMarketId,mm.intCurrencyID,mm.strCurrency from tblRKFutureMarket f
JOIN tblSMCurrency mm on f.intCurrencyId=mm.intCurrencyID 
UNION
SELECT intFutureMarketId,intMainCurrencyId,(Select C1.strCurrency from tblSMCurrency C1 Where C1.intCurrencyID= mm.intMainCurrencyId) from tblRKFutureMarket f
JOIN tblSMCurrency mm on f.intCurrencyId=mm.intCurrencyID and ysnSubCurrency =1