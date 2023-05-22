CREATE VIEW [dbo].[vyuRKGetAllocatedContractsPostPreview]

AS

SELECT pp.intAllocatedContractsPostRecapId
	, pp.intAllocatedContractsGainOrLossHeaderId
	, pp.dtmPostDate
    , pp.strBatchId
	, pp.strReversalBatchId
    , pp.intAccountId
    , pp.strAccountId
    --, pp.strAccountGroup
    , dblDebit = CASE WHEN header.ysnPosted = 1 THEN pp.dblCredit ELSE pp.dblDebit END
    , dblCredit = CASE WHEN header.ysnPosted = 1 THEN pp.dblDebit ELSE pp.dblCredit END
	, dblDebitForeign = CASE WHEN header.ysnPosted = 1 THEN pp.dblCreditForeign ELSE pp.dblDebitForeign END
    , dblCreditForeign = CASE WHEN header.ysnPosted = 1 THEN pp.dblDebitForeign ELSE pp.dblCreditForeign END
    , dblDebitUnit = CASE WHEN header.ysnPosted = 1 THEN pp.dblCreditUnit ELSE pp.dblDebitUnit END
    , dblCreditUnit = CASE WHEN header.ysnPosted = 1 THEN pp.dblDebitUnit ELSE pp.dblCreditUnit END
    , strDescription = strAccountDescription
    , pp.strCode
    , pp.strReference
    , pp.intCurrencyId
    , pp.dblExchangeRate
    , pp.dtmDateEntered
    , pp.dtmTransactionDate
    --, pp.strJournalLineDescription
	--, pp.intJournalLineNo
    , pp.ysnIsUnposted
    , pp.intUserId
    , pp.intEntityId
    , pp.strTransactionId
    , pp.intTransactionId
    , pp.strTransactionType
    , pp.strTransactionForm
    , pp.strModuleName
	--, pp.strRateType
    , pp.intConcurrencyId
	, pp.intSourceLocationId
	, pp.intSourceUOMId
	--, pp.dblPrice
FROM tblRKAllocatedContractsPostRecap pp
JOIN tblRKAllocatedContractsGainOrLossHeader header ON header.intAllocatedContractsGainOrLossHeaderId = pp.intAllocatedContractsGainOrLossHeaderId