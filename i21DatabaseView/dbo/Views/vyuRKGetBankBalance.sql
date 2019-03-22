CREATE VIEW vyuRKGetBankBalance
AS
SELECT t.intCurExpBankBalanceId,
t.intConcurrencyId,
t.intCurrencyExposureId,
t.intBankId,
t.intBankAccountId,
t.dblAmount,
t.intCurrencyId,
t.intCompanyId,strBankName,dbo.fnAESDecryptASym(strBankAccountNo)strBankAccountNo,strCompanyName,c.strCurrency FROM 
tblRKCurExpBankBalance t
JOIN tblCMBank b on t.intBankId=b.intBankId
JOIN tblSMCurrency c on c.intCurrencyID = t.intCurrencyId
JOIN tblSMMultiCompany mc on mc.intMultiCompanyId=t.intCompanyId
LEFT JOIN tblCMBankAccount ba on t.intBankAccountId=ba.intBankAccountId
