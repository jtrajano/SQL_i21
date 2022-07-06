CREATE TABLE tblCMBankValuationRule
(
    intBankValuationRuleId          INT IDENTITY(1,1) NOT NULL,
    strBankValuationRule            NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
    strDescription                  NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
    intConcurrencyId                INT NOT NULL
)