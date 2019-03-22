CREATE VIEW vyuMFItemOwner
AS
SELECT O.intItemOwnerId
	,O.intItemId
	,I.strItemNo
	,O.intOwnerId
	,E.strEntityNo AS strOwnerNo
	,E.strEntityNo + ' - ' + E.strName AS strDisplayOwner
	,E.strName
FROM tblICItemOwner O
JOIN tblEMEntity E ON E.intEntityId = O.intOwnerId
JOIN tblICItem I ON I.intItemId = O.intItemId
