CREATE PROC uspRKM2MGLDetailPreview 
	 @intM2MInquiryId INT
AS

DECLARE @ysnPosted bit
select @ysnPosted = isnull(ysnPost,0) from tblRKM2MInquiry where intM2MInquiryId=@intM2MInquiryId
SELECT CONVERT(INT, ROW_NUMBER() OVER (			ORDER BY strAccountId ASC
			)) intRowNum
	,strAccountId
	,strDescription
	,strTransactionType
	,case when @ysnPosted= 1 then dblCredit else dblDebit end dblDebit
	,case when @ysnPosted= 1 then dblDebit else dblCredit end dblCredit
	,case when @ysnPosted= 1 then dblCreditUnit else dblDebitUnit end dblDebitUnit
	,case when @ysnPosted= 1 then dblDebitUnit else dblCreditUnit end dblCreditUnit
	,dblExchangeRate
	,strTransactionId,intM2MInquiryId
FROM tblRKM2MPostRecap
WHERE intM2MInquiryId = @intM2MInquiryId order by strTransactionId,strTransactionType