CREATE FUNCTION [dbo].[fnGLGetBeginningBalanceOverrideFiscal] (
    @strAccountId NVARCHAR(100),
    @dtmDate DATETIME = NULL,
    @dtmOverrideFiscalEndDate DATETIME = NULL, -- end date should be a day after the last fiscal end date or have 23:59:59  time
    @ysnRE BIT = 0
    )
RETURNS @tbl TABLE (
  strAccountId     NVARCHAR(100),
  beginBalance     NUMERIC (18, 6),
  beginBalanceUnit NUMERIC(18, 6),
  strError NVARCHAR(100)
)
AS
  BEGIN
       DECLARE @strAccountType NVARCHAR(20)
       DECLARE @intAccountId INT
       SELECT TOP 1 @strAccountType = strAccountType, @intAccountId = intAccountId from vyuGLAccountDetail WHERE strAccountId = @strAccountId

       DECLARE @dtmOverrideFiscalStartDate DATETIME
             
       IF @dtmOverrideFiscalEndDate  IS NOT NULL
              SELECT @dtmOverrideFiscalStartDate = CAST ( DATEADD(YEAR, -1, @dtmOverrideFiscalEndDate) AS DATE)
              IF @dtmDate < @dtmOverrideFiscalStartDate
              BEGIN
                     INSERT INTO @tbl(strError) SELECT 'Date parameter should be later than ' + CONVERT( NVARCHAR(10), @dtmOverrideFiscalStartDate , 101)
                     RETURN
              END
       ELSE
       BEGIN
              SELECT TOP 1 @dtmOverrideFiscalStartDate = dtmDateFrom,@dtmOverrideFiscalEndDate = dtmDateTo 
              FROM tblGLFiscalYear where @dtmDate >= dtmDateFrom AND @dtmDate <= dtmDateTo
       END

       IF ( @ysnRE = 1)
       BEGIN
              ;WITH cte AS(
              SELECT 
                      dblDebit - dblCredit   dblBalance,
                      dblDebitUnit - dblCreditUnit dblBalanceUnit
              FROM   tblGLDetail C
              WHERE @intAccountId =C.intAccountId 
              AND dtmDate < @dtmDate
              AND ysnIsUnposted = 0
              AND ISNULL(strCode, '') <> ''
              UNION ALL
              SELECT 
                      dblDebit - dblCredit   dblBalance,
                      dblDebitUnit -dblCreditUnit dblBalanceUnit
              FROM   vyuGLDetail C
              WHERE 
              dtmDate < @dtmOverrideFiscalStartDate
              AND ysnIsUnposted = 0
              AND ISNULL(strCode, '') <> ''
              AND strAccountType IN ('Expense', 'Revenue')
              )
              INSERT INTO @tbl
              SELECT 
              @strAccountId                     AS strAccountId,
              Sum(dblBalance)         AS beginbalance,
              Sum(dblBalanceUnit) AS beginbalanceunit,
              NULL
              FROM cte

       END
       ELSE
       IF @strAccountType IN ('Expense', 'Revenue')
       BEGIN
             
             
              INSERT INTO @tbl
              SELECT @strAccountId                     AS strAccountId,
                      Sum(dblDebit - dblCredit)         AS beginbalance,
                      Sum(dblDebitUnit - dblCreditUnit) AS beginbalanceunit,
                      NULL
               FROM   tblGLDetail C
               WHERE @intAccountId =C.intAccountId 
               AND dtmDate BETWEEN @dtmOverrideFiscalStartDate AND @dtmDate
               AND ysnIsUnposted = 0
               AND ISNULL(strCode, '') <> ''
               GROUP BY 
               C.intAccountId
       END
       ELSE
       BEGIN
              INSERT INTO @tbl
              SELECT @strAccountId                     AS strAccountId,
                      Sum(dblDebit - dblCredit)         AS beginbalance,
                      Sum(dblDebitUnit - dblCreditUnit) AS beginbalanceunit,
                      NULL
               FROM   tblGLDetail C
               WHERE @intAccountId =C.intAccountId 
               AND dtmDate < @dtmDate
               AND ysnIsUnposted = 0
               AND ISNULL(strCode, '') <> ''
               GROUP BY C.intAccountId
       
       END


       
      RETURN
  END 