CREATE PROCEDURE [dbo].uspICAddTransactionLinks(@TransactionLinks udtICTransactionLinks READONLY)
AS
BEGIN

DECLARE @GraphId UNIQUEIDENTIFIER = NEWID()
DECLARE @LinkDate DATE = GETUTCDATE()

INSERT INTO tblICTransactionLinks(
	guiTransactionGraphId, dtmLinkUtcDate, strOperation,
	intSrcId, strSrcTransactionNo, strSrcModuleName, strSrcTransactionType,
	intDestId, strDestTransactionNo, strDestModuleName, strDestTransactionType)
SELECT COALESCE(related.guiTransactionGraphId, @GraphId), @LinkDate, link.strOperation,
	link.intSrcId, link.strSrcTransactionNo, link.strSrcModuleName, link.strSrcTransactionType,
	link.intDestId, link.strDestTransactionNo, link.strDestModuleName, link.strDestTransactionType
FROM @TransactionLinks link
OUTER APPLY (
	SELECT TOP 1 nodes.guiTransactionGraphId
	FROM tblICTransactionNodes nodes
	WHERE nodes.strTransactionNo = link.strSrcTransactionNo
) related
WHERE NOT EXISTS(
	SELECT TOP 1 1 FROM tblICTransactionLinks
	WHERE (strSrcTransactionNo = link.strSrcTransactionNo AND strSrcTransactionNo = link.strDestTransactionNo) OR
		(strDestTransactionNo = link.strSrcTransactionNo AND strDestTransactionNo = link.strDestTransactionNo)
)

;WITH CTE 
AS (
	SELECT	RN = ROW_NUMBER() OVER (PARTITION BY strSrcTransactionNo, strDestTransactionNo ORDER BY strSrcTransactionNo)
	FROM	tblICTransactionLinks 
)
DELETE FROM CTE WHERE RN > 1;

INSERT INTO tblICTransactionNodes (guiTransactionGraphId, intTransactionId, strTransactionNo, strTransactionType, strModuleName)
SELECT DISTINCT COALESCE(related.guiTransactionGraphId, @GraphId), intSrcId, strSrcTransactionNo, strSrcTransactionType, strSrcModuleName
FROM @TransactionLinks l
OUTER APPLY (
	SELECT TOP 1 nodes.guiTransactionGraphId
	FROM tblICTransactionNodes nodes
	WHERE nodes.strTransactionNo = l.strSrcTransactionNo
) related
WHERE NOT EXISTS(SELECT TOP 1 1 FROM tblICTransactionNodes WHERE strTransactionNo = l.strSrcTransactionNo)

UNION

SELECT DISTINCT COALESCE(related.guiTransactionGraphId, @GraphId), intDestId, strDestTransactionNo, strDestTransactionType, strDestModuleName
FROM @TransactionLinks l
OUTER APPLY (
	SELECT TOP 1 nodes.guiTransactionGraphId
	FROM tblICTransactionNodes nodes
	WHERE nodes.strTransactionNo = l.strSrcTransactionNo
) related
WHERE NOT EXISTS(SELECT TOP 1 1 FROM tblICTransactionNodes WHERE strTransactionNo = l.strDestTransactionNo)

END

GO