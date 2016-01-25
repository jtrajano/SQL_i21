CREATE PROCEDURE [dbo].[uspAPGetVendorContact]
	@voucherId INT
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
SELECT 
	DISTINCT ISNULL(B2.strEmail, C.strEmail) AS strEmail
FROM tblAPBill A 
INNER JOIN tblAPVendor B ON A.intEntityVendorId = B.intEntityVendorId
LEFT JOIN (tblEntityToContact B1 INNER JOIN tblEntity B2 ON B1.intEntityContactId = B2.intEntityId)
	 ON A.intEntityVendorId = B1.intEntityId AND B1.intEntityContactId = A.intEntityId
LEFT JOIN tblEntity C ON A.intEntityId = C.intEntityId
WHERE A.intBillId = @voucherId
-- ==================================================================
-- End Transaction
-- ==================================================================
END