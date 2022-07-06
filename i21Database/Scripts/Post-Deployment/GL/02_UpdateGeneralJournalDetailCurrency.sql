GO

PRINT 'Start updating General Journal Details Currency and Currency Exchange Rate Type'
GO

DECLARE @intDefaultCurrencyId INT, @intDefaultRateTypeId INT
SELECT TOP 1 @intDefaultCurrencyId = intDefaultCurrencyId FROM tblSMCompanyPreference
SELECT TOP 1 @intDefaultRateTypeId = intGeneralJournalRateTypeId FROM tblSMMultiCurrency

IF (@intDefaultCurrencyId IS NOT NULL)
    UPDATE tblGLJournalDetail
    SET intCurrencyId = @intDefaultCurrencyId
    WHERE intCurrencyId IS NULL

IF (@intDefaultRateTypeId IS NOT NULL)
    UPDATE tblGLJournalDetail
    SET
        intCurrencyExchangeRateTypeId = @intDefaultRateTypeId,
        dblDebitRate = 1,
        dblCreditRate = 1,
        dblDebitForeign = CASE WHEN (ISNULL(dblDebitForeign, 0) = 0) AND ISNULL(dblDebit, 0) > 0 THEN dblDebit ELSE 0 END,
        dblCreditForeign = CASE WHEN (ISNULL(dblCreditForeign, 0) = 0) AND ISNULL(dblCredit, 0) > 0 THEN dblCredit ELSE 0 END
    WHERE intCurrencyExchangeRateTypeId IS NULL AND intCurrencyId = @intDefaultCurrencyId
GO

DECLARE @intCurrencyId INT
SELECT TOP 1 @intCurrencyId = intDefaultCurrencyId FROM tblSMCompanyPreference

IF (@intCurrencyId IS NOT NULL)
    UPDATE tblGLJournalDetail
    SET
        dblDebitForeign = ISNULL(dblDebit, 0),
        dblCreditForeign = ISNULL(dblCredit, 0)
    WHERE
        (dblDebit > 0 OR dblCredit > 0) AND 
        (dblDebitRate = 1 OR dblCreditRate = 1) AND
        (ISNULL(dblDebitForeign, 0) = 0 OR ISNULL(dblCreditForeign, 0) = 0) AND
        intCurrencyId = @intCurrencyId
GO

PRINT 'Finish updating General Journal Details Currency and Currency Exchange Rate Type'
GO