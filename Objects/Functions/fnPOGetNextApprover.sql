CREATE FUNCTION [dbo].[fnPOGetNextApprover]
(
	@poId INT
)
RETURNS @returntable TABLE
(
	intApproverId INT
)
AS
BEGIN
	DECLARE @nextApproverLevel INT;

	SELECT 
		TOP 1 @nextApproverLevel = intApproverLevel 
	FROM dbo.tblPOApprover B
	WHERE B.ysnApproved = 0 AND B.dtmDateApproved IS NULL AND B.intPurchaseId = @poId
	GROUP BY B.intApproverLevel
	ORDER BY B.intApproverLevel;

	WITH approvers (
		intApproverId
		,intAlternateApproverId
	)
	AS
	(
		SELECT
			A.intApproverId
			,A.intAlternateApproverId
		FROM dbo.tblPOApprover A
		WHERE A.intPurchaseId = @poId
		AND A.ysnApproved = 0 AND A.dtmDateApproved IS NULL
		AND A.intApproverLevel = @nextApproverLevel
	)

	INSERT @returntable
	SELECT intApproverId FROM approvers
	UNION ALL
	SELECT intAlternateApproverId FROM approvers WHERE intAlternateApproverId IS NOT NULL
	
	RETURN;
END
