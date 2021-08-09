CREATE PROCEDURE [dbo].uspICGetTransactionsLedger (@identifier NVARCHAR(100))
AS

DECLARE @Columns TABLE (strColumn NVARCHAR(200))
DECLARE @Query NVARCHAR(MAX) = ''

INSERT INTO @Columns
SELECT DISTINCT a.strAccountId
FROM tblGLDetail gl
INNER JOIN tblGLAccount a ON a.intAccountId = gl.intAccountId
INNER JOIN tblICTransactionNodes n ON n.strTransactionNo = gl.strTransactionId
INNER JOIN tblICStagingTransactionNode tn ON tn.strTransactionNo = n.strTransactionNo
	AND tn.strTransactionType = n.strTransactionType
WHERE tn.guiIdentifier = @identifier
	AND gl.ysnIsUnposted = 0

IF NOT EXISTS(SELECT * FROM @Columns)
BEGIN
	DELETE FROM tblICStagingTransactionNode WHERE guiIdentifier = @identifier
	RETURN
END

DECLARE @Select NVARCHAR(MAX) = ''
DECLARE @TopSelect NVARCHAR(MAX) = ''

SELECT @Select += 
	'CASE WHEN a.strAccountId = ''' + c.strColumn + ''' THEN SUM(gl.dblDebit) ELSE 0 END AS ' + QUOTENAME(c.strColumn + '_Dr') + ',' +
	'CASE WHEN a.strAccountId = ''' + c.strColumn + ''' THEN SUM(gl.dblCredit) ELSE 0 END AS ' + QUOTENAME(c.strColumn + '_Cr') + ','
FROM @Columns c
SET @Select = LEFT(@Select, LEN(@Select) - 1)

SELECT @TopSelect +=
	'SUM(' + QUOTENAME(c.strColumn + '_Dr') + ')' + QUOTENAME(c.strColumn + '_Dr') +
	',' +
	'SUM(' + QUOTENAME(c.strColumn + '_Cr') + ')' + QUOTENAME(c.strColumn + '_Cr') + ',' 
FROM @Columns c
SET @TopSelect = LEFT(@TopSelect, LEN(@TopSelect) - 1)

SET @Query ='
SELECT 
	  t.guiTransactionGraphId
	, t.intTransactionId
	, t.strTransactionId
	, t.strTransactionForm
	, ' + @TopSelect + '
	, t.intTransactionNodeId
FROM (
	SELECT
		  n.guiTransactionGraphId
		, gl.intTransactionId
		, gl.strTransactionId
		, gl.strTransactionForm
		, n.intTransactionNodeId
		, ' + @Select + '
	FROM tblGLDetail gl
	INNER JOIN tblGLAccount a ON a.intAccountId = gl.intAccountId
	INNER JOIN tblICTransactionNodes n ON n.strTransactionNo = gl.strTransactionId
	INNER JOIN tblICStagingTransactionNode tn ON tn.strTransactionNo = n.strTransactionNo
		AND tn.strTransactionType = n.strTransactionType
	WHERE tn.guiIdentifier = ''' + @identifier + '''
		AND gl.ysnIsUnposted = 0
	GROUP BY n.guiTransactionGraphId, gl.intTransactionId, gl.strTransactionId, gl.strTransactionForm, a.strAccountId, n.intTransactionNodeId
) t
GROUP BY 
	  t.guiTransactionGraphId
	, t.intTransactionId
	, t.strTransactionId
	, t.strTransactionForm
	, t.intTransactionNodeId
ORDER BY t.intTransactionNodeId
';

EXECUTE sp_executesql @Query;

DELETE FROM tblICStagingTransactionNode WHERE guiIdentifier = @identifier

GO