CREATE VIEW vyuRKCurrencyContractSearch
AS
SELECT Top 100 percent convert(int,ROW_NUMBER() OVER (ORDER BY strStatus)) intRowNum,* FROM (
SELECT  cc.intCurrencyContractId,cc.strCurrencyContractNumber, cc.dtmContractDate,ct.strContractType,cb.strBankName,cc.dtmMaturityDate, 
		cc.strBankRef,rt.strCurrencyExchangeRateType,cc.dblContractAmount,
		cc.dblExchangeRate,	cc.dblMatchAmount, cc.dblSpotRate,	cc.strStatus, cc.ysnSwap
FROM tblRKCurrencyContract cc
JOIN tblCTContractType ct on ct.intContractTypeId=cc.intContractTypeId
JOIN tblCMBank cb on cb.intBankId=cc.intBankId
JOIN tblSMCurrencyExchangeRateType rt on rt.intCurrencyExchangeRateTypeId=cc.intCurrencyExchangeRateTypeId

UNION 

SELECT cc.intCurrencyContractId,cc.strCurrencyContractNumber,cs.dtmSwapMaturityDate dtmContractDate,ct.strContractType strContractType,cb.strBankName,cc.dtmMaturityDate, 
		cc.strBankRef,rt.strCurrencyExchangeRateType, cs.dblSwapContractAmount dblContractAmount,
		cs.dblSwapExchangeRate dblExchangeRate,	cs.dblSwapMatchAmount dblMatchAmount, cc.dblSpotRate, cc.strStatus,
		cc.ysnSwap	
FROM tblRKCurrencyContractSwapped cs
JOIN tblCTContractType ct on ct.intContractTypeId=cs.intSwapContractTypeId
JOIN tblRKCurrencyContract cc on cs.intCurrencyContractId=cc.intCurrencyContractId
JOIN tblCMBank cb on cb.intBankId=cc.intBankId
JOIN tblSMCurrencyExchangeRateType rt on rt.intCurrencyExchangeRateTypeId=cc.intCurrencyExchangeRateTypeId
JOIN tblCTContractType sct on sct.intContractTypeId=cc.intContractTypeId) t ORDER BY strCurrencyContractNumber,strContractType,dtmContractDate