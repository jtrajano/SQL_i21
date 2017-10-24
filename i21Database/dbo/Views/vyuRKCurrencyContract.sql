CREATE VIEW [dbo].[vyuRKCurrencyContract]
AS
SELECT
A.*,
B.strBankName,
C.strContractType,
D.strCurrencyExchangeRateType
from tblRKCurrencyContract A
LEFT JOIN tblCMBank B ON A.intBankId = B.intBankId
LEFT JOIN tblCTContractType C ON C.intContractTypeId = A.intContractTypeId
LEFT JOIN tblSMCurrencyExchangeRateType D ON D.intCurrencyExchangeRateTypeId = A.intCurrencyExchangeRateTypeId