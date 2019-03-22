CREATE VIEW vyuRKGetMoneyMarket
AS
SELECT t.intCurExpMoneyMarketId,
t.intConcurrencyId,
t.intCurrencyExposureId,
t.intBankId,
t.dblAmount,
t.intCurrencyId,
t.intCompanyId,strBankName,strCompanyName FROM 
tblRKCurExpMoneyMarket t
JOIN tblCMBank b on t.intBankId=b.intBankId
JOIN tblSMCurrency c on c.intCurrencyID = t.intCurrencyId
JOIN tblSMMultiCompany mc on mc.intMultiCompanyId=t.intCompanyId