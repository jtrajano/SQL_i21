CREATE PROCEDURE [dbo].[uspAPGetVendorApprover]
	@intEntityId INT = NULL
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- ==================================================================
-- Begin Transaction
-- ==================================================================
DECLARE @VendorAprover INT

SELECT DISTINCT @VendorAprover = C.strUserName FROM tblAPVendor A 
INNER JOIN [tblEMEntityToContact] B ON A.[intEntityId] = B.intEntityId 
INNER JOIN [tblEMEntityCredential] C ON B.intEntityContactId = C.intEntityId WHERE A.[intEntityId] = @intEntityId

IF (@VendorAprover > 0) 
	BEGIN
		--HAS VENDOR APPROVER  
		SELECT DISTINCT C.strUserName FROM tblAPVendor A 
		INNER JOIN [tblEMEntityToContact] B ON A.[intEntityId] = B.intEntityId 
		INNER JOIN [tblEMEntityCredential] C ON B.intEntityContactId = C.intEntityId WHERE A.[intEntityId] = @intEntityId
	END
ELSE
	BEGIN
		--USE COMPANY PREFERENCE
		SELECT  F.strEmail FROM dbo.tblAPCompanyPreference A 
		INNER JOIN tblSMApprovalListUserSecurity B ON A.intApprovalListId = B.intApprovalListId
		INNER JOIN tblSMUserSecurity E ON E.intEntityUserSecurityId = B.intEntityUserSecurityId 
		INNER JOIN tblEMEntity F ON E.intEntityUserSecurityId = F.intEntityId
	END


-- ==================================================================
-- End Transaction
-- ==================================================================
END