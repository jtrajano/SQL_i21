CREATE VIEW [dbo].[vyuAPClearingDiscrepancy]
AS

SELECT ISNULL(AP.intTransactionId, GL.intTransactionId) intTransactionId,
	   ISNULL(AP.strTransactionId, GL.strTransactionId) strTransactionId,
	   GL.dtmTransactionDate,
	   ISNULL(E.strName, 'Unknown') strVendorName,
	   ISNULL(AP.dtmDate, GL.dtmDate) dtmDate,
	   ISNULL(GL.dblAmount, 0) dblGLAmount,
	   ISNULL(AP.dblAmount, 0) dblAPAmount,
	   (ISNULL(GL.dblAmount, 0) - ISNULL(AP.dblAmount, 0)) dblDifference,
	   ISNULL(E2.strName, 'Unknown') strUserName
FROM (
	SELECT intTransactionId, strTransactionId, MIN(dtmDate) dtmDate, SUM(ROUND(dblAmount, 2)) dblAmount
	FROM tblAPClearing
	WHERE intOffsetId IS NULL
	GROUP BY intTransactionId, strTransactionId
	UNION ALL
	SELECT intOffsetId, strOffsetId, MAX(dtmDate) dtmDate, (SUM(ROUND(dblAmount, 2)) * -1) dblAmount
	FROM tblAPClearing
	WHERE intOffsetId IS NOT NULL
	GROUP BY intOffsetId, strOffsetId
) AP
FULL OUTER JOIN (
	SELECT D.intTransactionId, D.strTransactionId, MIN(D.dtmTransactionDate) dtmTransactionDate, MIN(D.dtmDate) dtmDate, MIN(D.intEntityId) intEntityId, MIN(D.intSourceEntityId) intSourceEntityId, MIN(D.intUserId) intUserId,
		   (SUM(ROUND(D.dblCredit, 2) - ROUND(D.dblDebit, 2)) * CASE WHEN D.strTransactionForm IN ('Bill') THEN -1 ELSE 1 END) dblAmount
	FROM tblGLDetail D
	INNER JOIN vyuGLAccountDetail AD ON AD.intAccountId = D.intAccountId
	WHERE D.ysnIsUnposted = 0 AND AD.intAccountCategoryId = 45
	GROUP BY D.intTransactionId, D.strTransactionId, D.strTransactionForm
) GL ON GL.intTransactionId = AP.intTransactionId AND GL.strTransactionId = AP.strTransactionId
LEFT JOIN tblEMEntity E ON E.intEntityId = ISNULL(GL.intSourceEntityId, GL.intEntityId)
LEFT JOIN tblEMEntity E2 ON E2.intEntityId = GL.intUserId
WHERE ISNULL(AP.dblAmount, 0) <> ISNULL(GL.dblAmount, 0)