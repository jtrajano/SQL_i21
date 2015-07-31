CREATE VIEW vyuMFGetPackType
AS
SELECT P.strPackName
	,P.strDescription
FROM tblMFPackType P
JOIN dbo.tblICItem I ON P.intPackTypeId = I.intPackTypeId