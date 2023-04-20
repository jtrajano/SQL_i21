CREATE PROCEDURE [dbo].[uspGLGetBeginningBalanceOverrideFiscal] (
    @dtmDate DATETIME = NULL,
    @dtmOverrideFiscalEndDate DATETIME = NULL, -- end date should be a day after the last fiscal end date or have 23:59:59  time
    @strAccountWhere NVARCHAR(MAX),
    @strType NVARCHAR(10)
    )
AS
  BEGIN
       DECLARE @intAccountId INT
       DECLARE @whereParam NVARCHAR(MAX)= 'SELECT intAccountId,strAccountId vyuGLAccountDetail where ' + @strAccountWhere
       DECLARE @tblAccount TABLE ( intAccountId INT, strAccountId NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL  )
       INSERT INTO @tblAccount EXEC(@whereParam)
       DECLARE @dtmOverrideFiscalStartDate DATETIME
             
       IF @dtmOverrideFiscalEndDate  IS NOT NULL
              SELECT @dtmOverrideFiscalStartDate = CAST ( DATEADD(YEAR, -1, @dtmOverrideFiscalEndDate) AS DATE)
              IF @dtmDate < @dtmOverrideFiscalStartDate
              BEGIN
                     DECLARE @error NVARCHAR(500) = 'Date parameter should be later than ' + CONVERT( NVARCHAR(10), @dtmOverrideFiscalStartDate , 101)
                     RAISERROR ( @error, 11,1)
                     RETURN
              END
       ELSE
       BEGIN
              SELECT TOP 1 @dtmOverrideFiscalStartDate = dtmDateFrom,@dtmOverrideFiscalEndDate = dtmDateTo 
              FROM tblGLFiscalYear where @dtmDate >= dtmDateFrom AND @dtmDate <= dtmDateTo
       END

       IF ( @strType= 'RE')-- get balance before fiscal start date
       BEGIN
              ;WITH cte AS(
              SELECT 
                     strAccountId,
                     ISNULL(dblDebit,0) dblDebit,
                     ISNULL(dblCredit,0) dblCredit,
                     ISNULL(dblDebitForeign,0) dblDebitForeign,
                     ISNULL(dblCreditForeign,0) dblCreditForeign,          
                     ISNULL(dblDebitUnit,0) dblDebitUnit,
                     ISNULL(dblCreditUnit,0) dblCreditUnit
              FROM   tblGLDetail C JOIN @tblAccount A ON A.intAccountId = C.intAccountId
              AND dtmDate < @dtmDate
              AND ysnIsUnposted = 0
              AND ISNULL(strCode, '') <> ''
              UNION ALL
              SELECT 
                     strAccountId,
                     ISNULL(dblDebit,0) dblDebit,
                     ISNULL(dblCredit,0) dblCredit,
                     ISNULL(dblDebitForeign,0) dblDebitForeign,
                     ISNULL(dblCreditForeign,0) dblCreditForeign,
                     ISNULL(dblDebitUnit,0) dblDebitUnit,
                     ISNULL(dblCreditUnit,0) dblCreditUnit
              FROM   vyuGLDetail C 
              WHERE 
              dtmDate < @dtmOverrideFiscalStartDate
              AND ysnIsUnposted = 0
              AND ISNULL(strCode, '') <> ''
              AND strAccountType IN ('Expense', 'Revenue')
              )
              SELECT strAccountId,
                    SUM(dblDebit) beginBalanceDebit,
                    SUM(dblCredit) beginBalanceCredit,
                    SUM(dblDebitForeign) beginBalanceDebitForeign,
                    SUM(dblCreditForeign) beginBalanceCreditForeign,
                    SUM(dblDebitUnit) beginBalanceDebitUnit,
                    SUM(dblCreditUnit) beginBalanceCreditUnit,
                    Sum(dblDebit - dblCredit) beginBalance,
                    Sum(dblDebitForeign - dblCreditForeign) beginBalanceForeign,
                    Sum(dblDebitUnit- dblCreditUnit ) beginBalanceUnit
              FROM cte
              GROUP BY strAccountId
       END

       ELSE
       IF ( @strType= 'CY')-- get balance before fiscal start date
       BEGIN          
              SELECT  strAccountId,
                    SUM(dblDebit) beginBalanceDebit,
                    SUM(dblCredit) beginBalanceCredit,
                    SUM(dblDebitForeign) beginBalanceDebitForeign,
                    SUM(dblCreditForeign) beginBalanceCreditForeign,
                    SUM(dblDebitUnit) beginBalanceDebitUnit,
                    SUM(dblCreditUnit) beginBalanceCreditUnit,
                    Sum(dblDebit - dblCredit) beginBalance,
                    Sum(dblDebitForeign - dblCreditForeign) beginBalanceForeign,
                    Sum(dblDebitUnit- dblCreditUnit ) beginBalanceUnit
               FROM   tblGLDetail C JOIN @tblAccount A ON A.intAccountId = C.intAccountId
               AND dtmDate BETWEEN @dtmOverrideFiscalStartDate AND @dtmDate
               AND ysnIsUnposted = 0
               AND ISNULL(strCode, '') <> ''
               GROUP BY 
               C.intAccountId, strAccountId
       END
       ELSE
       BEGIN
                SELECT  strAccountId,
                    SUM(dblDebit) beginBalanceDebit,
                    SUM(dblCredit) beginBalanceCredit,
                    SUM(dblDebitForeign) beginBalanceDebitForeign,
                    SUM(dblCreditForeign) beginBalanceCreditForeign,
                    SUM(dblDebitUnit) beginBalanceDebitUnit,
                    SUM(dblCreditUnit) beginBalanceCreditUnit,
                    Sum(dblDebit - dblCredit) beginBalance,
                    Sum(dblDebitForeign - dblCreditForeign) beginBalanceForeign,
                    Sum(dblDebitUnit- dblCreditUnit ) beginBalanceUnit
               FROM   tblGLDetail C JOIN @tblAccount A ON A.intAccountId = C.intAccountId
               AND dtmDate < @dtmDate
               AND ysnIsUnposted = 0
               AND ISNULL(strCode, '') <> ''
               GROUP BY C.intAccountId,strAccountId
       END
 END 