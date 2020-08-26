CREATE VIEW [dbo].[vyuRKGetM2MPostPreview]

AS

SELECT pp.intM2MPostPreviewId
	, pp.intM2MHeaderId
	, pp.dtmDate
    , pp.strBatchId
	, pp.strReversalBatchId
    , pp.intAccountId
    , pp.strAccountId
    , pp.strAccountGroup
    , dblDebit = CASE WHEN header.ysnPosted = 1 THEN pp.dblCredit ELSE pp.dblDebit END
    , dblCredit = CASE WHEN header.ysnPosted = 1 THEN pp.dblDebit ELSE pp.dblCredit END
	, dblDebitForeign = CASE WHEN header.ysnPosted = 1 THEN pp.dblCreditForeign ELSE pp.dblDebitForeign END
    , dblCreditForeign = CASE WHEN header.ysnPosted = 1 THEN pp.dblDebitForeign ELSE pp.dblCreditForeign END
    , dblDebitUnit = CASE WHEN header.ysnPosted = 1 THEN pp.dblCreditUnit ELSE pp.dblDebitUnit END
    , dblCreditUnit = CASE WHEN header.ysnPosted = 1 THEN pp.dblDebitUnit ELSE pp.dblCreditUnit END
    , pp.strDescription
    , pp.strCode
    , pp.strReference
    , pp.intCurrencyId
    , pp.dblExchangeRate
    , pp.dtmDateEntered
    , pp.dtmTransactionDate
    , pp.strJournalLineDescription
	, pp.intJournalLineNo
    , pp.ysnIsUnposted
    , pp.intUserId
    , pp.intEntityId
    , pp.strTransactionId
    , pp.intTransactionId
    , pp.strTransactionType
    , pp.strTransactionForm
    , pp.strModuleName
	, pp.strRateType
    , pp.intConcurrencyId
	, pp.intSourceLocationId
	, pp.intSourceUOMId
	, pp.dblPrice
FROM tblRKM2MPostPreview pp
JOIN tblRKM2MHeader header ON header.intM2MHeaderId = pp.intM2MHeaderId