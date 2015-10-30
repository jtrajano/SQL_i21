CREATE PROCEDURE [dbo].[uspAPGetVendorContact]
	@intEntityId INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

-- ==================================================================
-- Begin Transaction
-- ==================================================================
DECLARE @VendorContact INT

	SELECT DISTINCT @VendorContact = COUNT(*) FROM tblAPVendor A 
	INNER JOIN tblEntityToContact D ON A.intEntityVendorId = D.intEntityId
	INNER JOIN tblSMApprovalListUserSecurity B ON A.intApprovalListId = B.intApprovalListId 
	INNER JOIN tblSMUserSecurity E ON E.intEntityUserSecurityId = B.intEntityUserSecurityId 
	INNER JOIN tblEntity F ON E.intEntityUserSecurityId = F.intEntityId WHERE A.intEntityVendorId = @intEntityId

PRINT  @VendorContact
IF (@VendorContact > 0) 
	BEGIN
		--HAS VENDOR CONTACT  
		SELECT DISTINCT F.strEmail FROM tblAPVendor A 
		INNER JOIN tblEntityToContact D ON A.intEntityVendorId = D.intEntityId
		INNER JOIN tblSMApprovalListUserSecurity B ON A.intApprovalListId = B.intApprovalListId 
		INNER JOIN tblSMUserSecurity E ON E.intEntityUserSecurityId = B.intEntityUserSecurityId 
		INNER JOIN tblEntity F ON E.intEntityUserSecurityId = F.intEntityId WHERE A.intEntityVendorId = @intEntityId
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