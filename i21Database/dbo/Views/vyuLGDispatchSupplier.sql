CREATE VIEW [dbo].[vyuLGDispatchSupplier]
AS
SELECT E.intEntityId
	,strEntityName = E.strName
	,strEntityNo
	,ysnTransportTerminal = ISNULL(ysnTransportTerminal, 0)
FROM tblEMEntity E 
INNER JOIN tblAPVendor V ON V.intEntityId = E.intEntityId

GO