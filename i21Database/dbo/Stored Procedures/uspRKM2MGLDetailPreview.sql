CREATE PROC uspRKM2MGLDetailPreview
	 @intM2MInquiryId INT
AS
SELECT CONVERT(INT, ROW_NUMBER() OVER (
			ORDER BY strAccountId ASC
			)) intRowNum
	,strAccountId
	,strDescription
	,strTransactionType
	,dblDebit
	,dblCredit
	,dblDebitUnit
	,dblCreditUnit
	,dblExchangeRate
	,strTransactionId,intM2MInquiryId
FROM tblRKM2MPostRecap
WHERE intM2MInquiryId = @intM2MInquiryId order by strTransactionId,strTransactionType