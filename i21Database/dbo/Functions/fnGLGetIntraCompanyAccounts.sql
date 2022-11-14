CREATE FUNCTION [dbo].[fnGLGetIntraCompanyAccounts]
(
)
RETURNS @tblAccounts TABLE
(
	intAccountId INT NULL,
	strAccountId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL,
	strAccountType NVARCHAR(60) COLLATE Latin1_General_CI_AS,
	intTransactionCompanySegmentId INT,
	intInterCompanySegmentId INT
)
AS
BEGIN
	-- Contruct Accounts
	INSERT INTO @tblAccounts([strAccountId], [strAccountType],[intTransactionCompanySegmentId], [intInterCompanySegmentId])
	SELECT DISTINCT -- Inter Company Due From
		dbo.fnGLBuildIntraCompanyAccount(IntraCompany.strDueFromSegment, IntraCompany.strInterCompanySegment) COLLATE Latin1_General_CI_AS,
		'Inter Company Due From',
		IntraCompany.intTransactionCompanySegmentId,
		IntraCompany.intInterCompanySegmentId
	FROM vyuGLIntraCompanyAccountSegment IntraCompany
	UNION ALL
	SELECT DISTINCT -- Inter Company Due To
		dbo.fnGLBuildIntraCompanyAccount(IntraCompany.strDueToSegment, IntraCompany.strInterCompanySegment) COLLATE Latin1_General_CI_AS,
		'Inter Company Due To',
		IntraCompany.intTransactionCompanySegmentId,
		IntraCompany.intInterCompanySegmentId
	FROM vyuGLIntraCompanyAccountSegment IntraCompany

	-- Update Account Id and check if exists
	UPDATE A
		SET intAccountId = B.intAccountId
	FROM @tblAccounts A
	LEFT JOIN tblGLAccount B
		ON A.strAccountId = B.strAccountId

	RETURN
END
