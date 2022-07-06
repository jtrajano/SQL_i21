CREATE VIEW vyuMFGetExternalGroupItem
AS
SELECT DISTINCT I.strExternalGroup
FROM tblICItem I
WHERE ISNULL(I.strExternalGroup, '') <> ''
