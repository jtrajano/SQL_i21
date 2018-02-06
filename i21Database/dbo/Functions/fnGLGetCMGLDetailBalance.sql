CREATE FUNCTION fnGLGetCMGLDetailBalance
(
	@dtmDate DATETIME,
	@intAccountId INT
)
RETURNS NUMERIC(18,6)
AS
BEGIN
RETURN 
(
	SELECT ISNULL(sum(dblDebit - dblCredit),0) FROM
	tblGLDetail GL
	WHERE ysnIsUnposted = 0
	AND dtmDate<= @dtmDate
	AND intAccountId = @intAccountId
)
END
