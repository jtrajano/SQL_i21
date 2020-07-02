CREATE PROCEDURE uspRKMatchDerivativesGLDetailPreview
	@intMatchFuturesPSHeaderId INT

AS

BEGIN
	DECLARE @ysnPosted BIT
	
	SELECT @ysnPosted = ISNULL(ysnPosted, 0) FROM tblRKMatchFuturesPSHeader WHERE intMatchFuturesPSHeaderId = @intMatchFuturesPSHeaderId

	IF (@ysnPosted = 0)
	BEGIN
		EXEC uspRKMatchDerivativesPostRecap @intMatchFuturesPSHeaderId, 1
	END
	
	SELECT CONVERT(INT, ROW_NUMBER() OVER (ORDER BY intMatchDerivativesPostRecapId ASC)) intRowNum
		, intAccountId
		, strAccountId
		, strAccountDescription
		, strTransactionType
		, dblDebit = CASE WHEN @ysnPosted = 1 THEN dblCredit ELSE dblDebit END
		, dblCredit = CASE WHEN @ysnPosted = 1 THEN dblDebit ELSE dblCredit END
		, dblDebitUnit = CASE WHEN @ysnPosted = 1 THEN dblCreditUnit ELSE dblDebitUnit END
		, dblCreditUnit = CASE WHEN @ysnPosted = 1 THEN dblDebitUnit ELSE dblCreditUnit END
		, dblExchangeRate
		, strTransactionId
		, intTransactionId
	FROM tblRKMatchDerivativesPostRecap
	WHERE intTransactionId = @intMatchFuturesPSHeaderId
END