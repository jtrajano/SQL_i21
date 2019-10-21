CREATE PROC uspRKM2MGLDetailPreview
	@intM2MInquiryId INT

AS

BEGIN
	DECLARE @ysnPosted BIT
	
	SELECT @ysnPosted = ISNULL(ysnPost, 0) FROM tblRKM2MInquiry WHERE intM2MInquiryId = @intM2MInquiryId
	SELECT CONVERT(INT, ROW_NUMBER() OVER (ORDER BY strAccountId ASC)) intRowNum
		, strAccountId
		, strDescription
		, strTransactionType
		, dblDebit = CASE WHEN @ysnPosted = 1 THEN dblCredit ELSE dblDebit END
		, dblCredit = CASE WHEN @ysnPosted = 1 THEN dblDebit ELSE dblCredit END
		, dblDebitUnit = CASE WHEN @ysnPosted = 1 THEN dblCreditUnit ELSE dblDebitUnit END
		, dblCreditUnit = CASE WHEN @ysnPosted = 1 THEN dblDebitUnit ELSE dblCreditUnit END
		, dblExchangeRate
		, strTransactionId,intM2MInquiryId
	FROM tblRKM2MPostRecap
	WHERE intM2MInquiryId = @intM2MInquiryId order by strTransactionId,strTransactionType
END