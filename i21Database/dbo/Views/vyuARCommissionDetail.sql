CREATE VIEW [dbo].[vyuARCommissionDetail]
AS
SELECT strComDetailEntityName	= E.strName
	 , intComDetailEntityId		= CD.intEntityId
	 , dblLineItemAmount		= CD.dblAmount
	 , C.*
FROM vyuARCommission C
	INNER JOIN tblARCommissionDetail CD ON C.intCommissionId = CD.intCommissionId
	LEFT JOIN tblEMEntity E ON CD.intEntityId = E.intEntityId
WHERE C.ysnConditional = 0 OR (C.ysnConditional = 1 AND C.ysnApproved = 1)
