CREATE FUNCTION [dbo].[fnGLGetBeginningBalanceAndUnitRETB] (
    @strAccountId NVARCHAR(100),
    @dtmDate DATETIME)
RETURNS @tbl TABLE (
  strAccountId     NVARCHAR(100),
  beginBalance     NUMERIC (18, 6),
  beginBalanceUnit NUMERIC(18, 6))
AS
  BEGIN
      WITH cte
           AS (SELECT @strAccountId                     AS strAccountId,
                      Sum(dblDebit - dblCredit)         AS beginbalance,
                      Sum(dblDebitUnit - dblCreditUnit) AS beginbalanceunit,
                      fiscal.dtmEndDate                 dtmDate,
                      ysnIsUnposted,
                      strCode
               FROM   tblGLAccount A
                      LEFT JOIN tblGLAccountGroup B
                             ON A.intAccountGroupId = B.intAccountGroupId
                      LEFT JOIN tblGLDetail C
                             ON A.intAccountId = C.intAccountId
                      CROSS apply (SELECT TOP 1 dtmStartDate,
                                                dtmEndDate,
                                                strPeriod
                                   FROM   tblGLFiscalYearPeriod
                                   WHERE  dtmDate BETWEEN dtmStartDate AND
                                                          dtmEndDate)
                                  fiscal
               WHERE  ( B.strAccountType IN ( 'Expense', 'Revenue' )
                       
                        AND ISNULL(strCode, '') <> '' )
               GROUP  BY fiscal.strPeriod,
                         B.strAccountType,
                         fiscal.dtmEndDate,
                         ysnIsUnposted,
                         strCode
               UNION
               SELECT strAccountId,
                      ( dblDebit - dblCredit )         AS beginbalance,
                      ( dblDebitUnit - dblCreditUnit ) AS beginbalanceunit,
                      dtmDate,
                      ysnIsUnposted,
                      strCode
               FROM   tblGLAccount A
                      LEFT JOIN tblGLDetail C
                             ON A.intAccountId = C.intAccountId
               WHERE  strAccountId = @strAccountId
                     )
      INSERT INTO @tbl
      SELECT strAccountId,
             SUM(beginbalance)     beginBalance,
             SUM(beginbalanceunit) beginBalanceUnit
      FROM   cte
      WHERE  dtmDate < @dtmDate
            AND ysnIsUnposted = 0
            AND ISNULL(strCode, '') <> ''
      GROUP  BY strAccountId

      RETURN
  END 