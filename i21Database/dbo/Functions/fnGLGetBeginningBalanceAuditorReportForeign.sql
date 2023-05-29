CREATE FUNCTION [dbo].[fnGLGetBeginningBalanceAuditorReportForeign]   
(   
  @strAccountId NVARCHAR(100),  
  @dtmDate DATETIME,  
  @intCurrencyId INT
)  
RETURNS @tbl TABLE (  
  strAccountId NVARCHAR(100),  
  beginBalance NUMERIC (18,6),
  beginBalanceDebit NUMERIC (18,6),
  beginBalanceCredit NUMERIC (18,6),
  beginBalanceForeign NUMERIC (18,6),
  beginBalanceDebitForeign NUMERIC (18,6),
  beginBalanceCreditForeign NUMERIC (18,6)
)  
  
AS  
BEGIN  
 DECLARE @accountType NVARCHAR(30)  
 SELECT @accountType= B.strAccountType  FROM tblGLAccount A JOIN tblGLAccountGroup B on A.intAccountGroupId = B.intAccountGroupId WHERE  
 A.strAccountId = @strAccountId and B.strAccountType IN ('Expense','Revenue','Cost of Goods Sold')  
 IF @accountType IS NOT NULL  
   INSERT  @tbl  
   SELECT    
    strAccountId,
    SUM(dblDebit-dblCredit) beginBalance,
    SUM(dblDebit) beginBalanceDebit,
    SUM(dblCredit) beginBalanceCredit,
    SUM(dblDebitForeign-dblCreditForeign ) beginBalanceForeign,
    SUM(dblDebitForeign) beginBalanceDebitForeign,
    SUM(dblCreditForeign) beginBalanceCreditForeign
   FROM tblGLAccount A  
    LEFT JOIN tblGLAccountGroup B ON A.intAccountGroupId = B.intAccountGroupId  
    LEFT JOIN tblGLDetail C ON A.intAccountId = C.intAccountId  
    CROSS APPLY (SELECT dtmDateFrom,dtmDateTo from tblGLFiscalYear where @dtmDate >= dtmDateFrom AND @dtmDate <= dtmDateTo) D  
   WHERE strAccountId = @strAccountId and ( C.dtmDate >= D.dtmDateFrom and  C.dtmDate < @dtmDate) and strCode <> ''  and ysnIsUnposted = 0  
            AND intCurrencyId = @intCurrencyId  
   GROUP BY strAccountId  
 ELSE  
  INSERT  @tbl  
  SELECT    
    strAccountId, 
    SUM(dblDebit-dblCredit)beginBalance, 
    SUM(dblDebit) beginBalanceDebit,
    SUM(dblCredit) beginBalanceCredit,
    SUM(dblDebitForeign-dblCreditForeign)  beginBalanceForeign,
    SUM(dblDebitForeign) beginBalanceDebitForeign,
    SUM(dblCreditForeign) beginBalanceCreditForeign
  FROM tblGLAccount A  
   LEFT JOIN tblGLAccountGroup B ON A.intAccountGroupId = B.intAccountGroupId  
   LEFT JOIN tblGLDetail C ON A.intAccountId = C.intAccountId  
  WHERE strAccountId = @strAccountId and C.dtmDate < @dtmDate and strCode <> '' and ysnIsUnposted = 0  
        AND intCurrencyId = @intCurrencyId  
  GROUP BY strAccountId  
  RETURN  
END