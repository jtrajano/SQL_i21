﻿CREATE PROCEDURE [dbo].[uspPOGetCreatorEmail]
	@poId INT
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
	DISTINCT ISNULL(VendorContactCreated.strEmail, UserCreated.strEmail) AS strEmail
FROM tblPOPurchase A 
OUTER APPLY (
	SELECT 
		F.strEmail
	FROM tblAPVendor C
	INNER JOIN (tblEntityToContact D INNER JOIN tblEntity E ON D.intEntityContactId = E.intEntityId)
	 ON C.intEntityVendorId = D.intEntityId
	INNER JOIN tblEntity F ON F.intEntityId = D.intEntityContactId
	WHERE C.intEntityVendorId = A.intEntityVendorId
	AND A.intEntityId = E.intEntityId
) VendorContactCreated
OUTER APPLY (
	SELECT 
		B3.strEmail
	FROM tblEntity B
	INNER JOIN tblEntityToContact B2 ON B.intEntityId = B2.intEntityId
	INNER JOIN tblEntity B3 ON B3.intEntityId = B2.intEntityContactId
	WHERE B.intEntityId = A.intEntityId
) UserCreated
WHERE A.intPurchaseId = @poId
-- ==================================================================
-- End Transaction
-- ==================================================================
END