CREATE VIEW [dbo].[vyuAPGLByAccount]

AS

SELECT dtmTransactionDate, dtmDate, 
			case when E.strAccountType='Asset' then SUM(dblDebit)-SUM(dblCredit)
			when E.strAccountType='Liability' then SUM(dblCredit)-SUM(dblDebit)
			when E.strAccountType='Equity' then SUM(dblCredit)-SUM(dblDebit)
                        when E.strAccountType='Revenue' then SUM(dblCredit)-SUM(dblDebit)
                        when E.strAccountType='Expense' then SUM(dblDebit)-SUM(dblCredit)
                        when E.strAccountType='Sales' then SUM(dblCredit)-SUM(dblDebit)
                        when E.strAccountType='Cost of Goods Sold' then SUM(dblDebit)-SUM(dblCredit) else 0 end AS dblGLTotal,
			 intTransactionId, strTransactionId, C.intAccountId, C.ysnIsUnposted,
			 strAccountId
		FROM tblGLDetail C 
			INNER JOIN tblGLAccount D ON C.intAccountId = D.intAccountId
			INNER JOIN tblGLAccountGroup E ON D.intAccountGroupId = E.intAccountGroupId
		WHERE C.strCode = 'AP' AND ysnIsUnposted = 0
		GROUP BY dtmTransactionDate, dtmDate, intTransactionId, strTransactionId, C.intAccountId, C.ysnIsUnposted, strAccountType, strAccountId
