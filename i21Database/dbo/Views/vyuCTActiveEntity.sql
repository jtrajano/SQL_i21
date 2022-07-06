CREATE VIEW [dbo].[vyuCTActiveEntity]

AS

SELECT intEntityId
	, strEntityName
	, intEntityTypeId
	, strEntityType
FROM (
	SELECT e.intEntityId
		, strEntityName = e.strName
		, t.intEntityTypeId
		, strEntityType = t.strType
		, ysnActive = CASE WHEN t.strType IN ('Vendor', 'Shipping Line', 'Producer') THEN ISNULL(V.ysnPymtCtrlActive, 0)
						WHEN t.strType = 'Customer' THEN ISNULL(U.ysnActive, 0)
						WHEN t.strType = 'Salesperson' THEN ISNULL(P.ysnActive, 0)
						ELSE ISNULL(e.ysnActive, 0) END
	FROM tblEMEntity e
	JOIN tblEMEntityType t ON t.intEntityId = e.intEntityId
	LEFT JOIN tblAPVendor V ON V.intEntityId = e.intEntityId
	LEFT JOIN tblARCustomer U ON U.intEntityId = e.intEntityId
	LEFT JOIN tblARSalesperson P ON P.intEntityId = e.intEntityId
) tbl WHERE ISNULL(ysnActive, 0) = 1