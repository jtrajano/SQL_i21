CREATE PROCEDURE [dbo].[uspApiPostAdjustmentTransaction] (
    @strTransactionId NVARCHAR(40),
    @ysnPost BIT,
    @ysnRecap BIT = 0,
    @intEntityUserSecurityId INT = NULL,
    @strBatchId NVARCHAR(40) = NULL OUTPUT
)
AS

IF (@ysnRecap = 1)
BEGIN
    EXEC dbo.uspICPostInventoryAdjustment @ysnPost, @ysnRecap, @strTransactionId, @intEntityUserSecurityId, @strBatchId OUTPUT
    SELECT
        r.intGLDetailId
        , r.dtmDate
        , r.strBatchId
        , r.intAccountId
        , r.strAccountId
        , r.strAccountGroup
        , r.dblDebit
        , r.dblCredit
        , r.dblDebitForeign
        , r.dblCreditForeign
        , r.dblDebitUnit
        , r.dblCreditUnit
        , r.strDescription
        , r.strCode
        , r.strReference
        , r.intCurrencyId
        , c.strCurrency
        , r.intCurrencyExchangeRateTypeId
        , r.dblExchangeRate
        , r.dtmDateEntered
        , r.dtmTransactionDate
        , r.strJournalLineDescription
        , r.intJournalLineNo
        , r.ysnIsUnposted
        , r.intUserId
        , r.intEntityId
        , r.strTransactionId
        , r.intTransactionId
        , r.strTransactionType
        , r.strTransactionForm
        , r.strModuleName
        , r.strRateType
        , r.intConcurrencyId
    FROM tblGLPostRecap r
    LEFT JOIN tblSMCurrency c ON c.intCurrencyID = r.intCurrencyId
    WHERE r.strBatchId = @strBatchId
        AND r.strTransactionId = @strTransactionId
END
ELSE
BEGIN
    EXEC dbo.uspICPostInventoryAdjustment @ysnPost, @ysnRecap, @strTransactionId, @intEntityUserSecurityId, @strBatchId OUTPUT
    SELECT
        r.intGLDetailId
        , r.dtmDate
        , r.strBatchId
        , r.intAccountId
        , a.strAccountId
        , g.strAccountGroup
        , r.dblDebit
        , r.dblCredit
        , r.dblDebitForeign
        , r.dblCreditForeign
        , r.dblDebitUnit
        , r.dblCreditUnit
        , r.strDescription
        , r.strCode
        , r.strReference
        , r.intCurrencyId
        , c.strCurrency
        , r.intCurrencyExchangeRateTypeId
        , r.dblExchangeRate
        , r.dtmDateEntered
        , r.dtmTransactionDate
        , r.strJournalLineDescription
        , r.intJournalLineNo
        , r.ysnIsUnposted
        , r.intUserId
        , r.intEntityId
        , r.strTransactionId
        , r.intTransactionId
        , r.strTransactionType
        , r.strTransactionForm
        , r.strModuleName
        , NULL strRateType
        , r.intConcurrencyId
    FROM tblGLDetail r
    LEFT JOIN tblSMCurrency c ON c.intCurrencyID = r.intCurrencyId
    LEFT JOIN tblGLAccount a ON a.intAccountId = r.intAccountId
    LEFT JOIN tblGLAccountGroup g ON g.intAccountGroupId = a.intAccountGroupId
    WHERE r.strBatchId = @strBatchId
        AND r.strTransactionId = @strTransactionId
END
