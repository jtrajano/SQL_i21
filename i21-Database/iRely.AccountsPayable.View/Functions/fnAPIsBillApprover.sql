CREATE FUNCTION [dbo].[fnAPIsBillApprover]
(
	@billId INT,
	@entityId INT
)
RETURNS BIT
AS
BEGIN

	DECLARE @isApprover BIT = 0

	IF EXISTS(SELECT 1 FROM tblAPBill A INNER JOIN tblAPVendor B ON A.intEntityVendorId = B.[intEntityId]
						INNER JOIN tblSMApprovalListUserSecurity C ON B.intApprovalListId = C.intApprovalListId
						INNER JOIN tblSMUserSecurity D ON C.[intEntityUserSecurityId] = D.[intEntityId]
						WHERE A.intBillId = @billId AND D.[intEntityId] = @entityId)
	BEGIN
		SET @isApprover = 1;
	END

	RETURN @isApprover
END
