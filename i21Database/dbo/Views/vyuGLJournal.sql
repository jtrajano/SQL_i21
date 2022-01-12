CREATE VIEW vyuGLJournal
AS
SELECT 
    [intJournalId], 
    [dblExchangeRate], 
    [dtmDate], 
    [dtmDateEntered], 
    [dtmPosted], 
    [dtmReverseDate], 
    [intCompanyId], 
    Extent1.[intConcurrencyId], 
    Extent1.[intCurrencyId], 
    [strCurrency], 
    [intEntityId], 
    [intFiscalPeriodId], 
    Extent1.[intFiscalYearId], 
    [intJournalIdToReverse], 
    [intUserId], 
    Extent1.[strDescription], 
    [strJournalId], 
    [strSourceId], 
    [strSourceType], 
    [strReverseLink], 
    [strTransactionType], 
    [ysnRecurringTemplate], 
    [ysnPosted], 
    [strJournalType], 
    [ysnReversed], 
    [ysnOpen], 
    [strPeriod] strFiscalPeriodName, 
    [dtmStartDate] dtmFiscalPeriodStart, 
    [dtmEndDate] dtmFiscalPeriodEnd, 
    [intCurrencyExchangeRateId]
    FROM   [dbo].[tblGLJournal] AS [Extent1]
    LEFT JOIN [dbo].[tblSMCurrency] AS [Extent2] ON [Extent1].[intCurrencyId] = [Extent2].[intCurrencyID]
    LEFT JOIN [dbo].[tblGLFiscalYearPeriod] AS [Extent3] ON [Extent1].[intFiscalPeriodId] = [Extent3].[intGLFiscalYearPeriodId]
    
    
    


	