CREATE FUNCTION [dbo].[fnAPGetNextVoucherApprover]
(
	@voucherId INT
)
RETURNS @returntable TABLE
(
	intApproverId INT
)
WITH SCHEMABINDING
AS
BEGIN

	DECLARE @nextApproverLevel INT;

	SELECT 
		TOP 1 @nextApproverLevel = intApproverLevel 
	FROM dbo.tblAPVoucherApprover B
	WHERE B.ysnApproved = 0 AND B.dtmDateApproved IS NULL AND B.intVoucherId = @voucherId
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
		FROM dbo.tblAPVoucherApprover A
		WHERE A.intVoucherId = @voucherId
		AND A.ysnApproved = 0 AND A.dtmDateApproved IS NULL
		AND A.intApproverLevel = @nextApproverLevel
	)

	INSERT @returntable
	SELECT intApproverId FROM approvers
	UNION ALL
	SELECT intAlternateApproverId FROM approvers WHERE intAlternateApproverId IS NOT NULL
	
	RETURN;
END
