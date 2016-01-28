CREATE PROCEDURE [dbo].[uspPOGetNextApproverEmail]
	@poId INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF;

DECLARE @poIdParam INT = @poId;

WITH approverEmails (
	strEmail
	,strAlternateEmailApprover
)
AS
(
	SELECT
		B3.strEmail
		,C3.strEmail AS strAlternateEmailApprover
	FROM tblPOApprover A
	INNER JOIN (tblEntity B INNER JOIN tblEntityToContact B2 ON B.intEntityId = B2.intEntityId AND B2.ysnDefaultContact = 1
						INNER JOIN tblEntity B3 ON B2.intEntityContactId = B3.intEntityId)
		ON A.intApproverId = B.intEntityId
	LEFT JOIN (tblEntity C INNER JOIN tblEntityToContact C2 ON C.intEntityId = C2.intEntityId  AND C2.ysnDefaultContact = 1
						INNER JOIN tblEntity C3 ON C2.intEntityContactId = C3.intEntityId)
			ON A.intAlternateApproverId = C.intEntityId
	WHERE A.intPurchaseId = @poIdParam
	AND A.ysnApproved = 0
	AND EXISTS
	(
		SELECT
			TOP 1 intApproverLevel
		FROM tblAPVoucherApprover D
		WHERE D.ysnApproved = 0
		AND D.intApproverLevel = A.intApproverLevel
		ORDER BY D.intApproverLevel
	) 
)

SELECT * FROM (
	SELECT strEmail FROM approverEmails
	UNION ALL
	SELECT strAlternateEmailApprover FROM approverEmails
) ApproverEmails
WHERE strEmail IS NOT NULL