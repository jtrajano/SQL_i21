CREATE PROCEDURE [dbo].[uspAPGetVendorApprover]
	@intEntityId INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

-- ==================================================================
-- Begin Transaction
-- ==================================================================
DECLARE @VendorAprover INT

	SELECT DISTINCT @VendorAprover = C.strUserName FROM tblAPVendor A 
	INNER JOIN tblEntityToContact B ON A.intEntityVendorId = B.intEntityId 
    INNER JOIN tblEntityCredential C ON B.intEntityContactId = C.intEntityId WHERE A.intEntityVendorId = @intEntityId

PRINT  @VendorAprover
IF (@VendorAprover > 0) 
	BEGIN
		--HAS VENDOR APPROVER  
		SELECT DISTINCT C.strUserName FROM tblAPVendor A 
		INNER JOIN tblEntityToContact B ON A.intEntityVendorId = B.intEntityId 
		INNER JOIN tblEntityCredential C ON B.intEntityContactId = C.intEntityId WHERE A.intEntityVendorId = @intEntityId
	END
ELSE
	BEGIN
		--USE COMPANY PREFERENCE
		SELECT  F.strEmail FROM dbo.tblAPCompanyPreference A 
		INNER JOIN tblSMApprovalListUserSecurity B ON A.intApprovalListId = B.intApprovalListId
		INNER JOIN tblSMUserSecurity E ON E.intEntityUserSecurityId = B.intEntityUserSecurityId 
		INNER JOIN tblEntity F ON E.intEntityUserSecurityId = F.intEntityId
	END
-- ==================================================================
-- End Transaction
-- ==================================================================
END