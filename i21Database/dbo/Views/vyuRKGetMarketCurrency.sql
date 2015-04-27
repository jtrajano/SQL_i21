CREATE VIEW [dbo].[vyuRKGetMarketCurrency]
AS  
SELECT intFutureMarketId,mm.intCurrencyID,mm.strCurrency from tblRKFutureMarket f
JOIN tblSMCurrency mm on f.intCurrencyId=mm.intCurrencyID
