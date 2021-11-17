ALTER VIEW vyuGLJournal
AS
SELECT 
    [intJournalId], 
    [dblExchangeRate], 
    [dtmDate], 
    [dtmDateEntered], 
    [dtmPosted], 
    [dtmReverseDate], 
    [intCompanyId], 
    GJ.[intConcurrencyId], 
    GJ.[intCurrencyId], 
    [strCurrency], 
    [intEntityId], 
    [intFiscalPeriodId], 
    GJ.[intFiscalYearId], 
    [intJournalIdToReverse], 
    [intUserId], 
    GJ.[strDescription], 
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
    [intCurrencyExchangeRateId],
    intLocationSegmentId,
    SG.strCode strLocationSegment
    FROM   [dbo].[tblGLJournal] AS GJ
    LEFT JOIN [dbo].[tblSMCurrency] AS SM ON GJ.[intCurrencyId] = SM.[intCurrencyID]
    LEFT JOIN [dbo].[tblGLFiscalYearPeriod] AS FP ON GJ.[intFiscalPeriodId] = FP.[intGLFiscalYearPeriodId]
    LEFT JOIN tblGLAccountSegment SG ON SG.intAccountSegmentId = GJ.intLocationSegmentId
    
    


	