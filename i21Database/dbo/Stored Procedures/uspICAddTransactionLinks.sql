CREATE PROCEDURE [dbo].uspICAddTransactionLinks(@TransactionLinks udtICTransactionLinks READONLY)
AS
BEGIN

IF (dbo.fnSMCheckIfLicensed('Transaction Traceability') = 1)
BEGIN

DECLARE @GraphId UNIQUEIDENTIFIER = NEWID()
DECLARE @LinkDate DATE = GETUTCDATE()


;MERGE INTO tblICTransactionLinks AS TARGET
USING (
	SELECT
		COALESCE(related.guiTransactionGraphId, @GraphId) AS guiTransactionGraphId, 
		@LinkDate AS dtmLinkUtcDate, 
		link.strOperation AS strOperation,
		link.intSrcId AS intSrcId, 
		link.strSrcTransactionNo AS strSrcTransactionNo, 
		link.strSrcModuleName AS strSrcModuleName, 
		link.strSrcTransactionType AS strSrcTransactionType,
		link.intDestId AS intDestId, 
		link.strDestTransactionNo AS strDestTransactionNo, 
		link.strDestModuleName AS strDestModuleName, 
		link.strDestTransactionType AS strDestTransactionType,
		ROW_NUMBER() OVER(PARTITION BY link.intDestId, link.strDestTransactionNo, link.strDestModuleName, link.strDestTransactionType ORDER BY link.strOperation) AS RowNumber
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
) AS SOURCE 
ON 
(
	TARGET.intDestId = SOURCE.intDestId 
	AND 
	TARGET.strDestTransactionNo = SOURCE.strDestTransactionNo 
	AND 
	TARGET.strDestModuleName = SOURCE.strDestModuleName 
	AND 
	TARGET.strDestTransactionType = SOURCE.strDestTransactionType
	AND
	TARGET.intSrcId IS NULL
	AND 
	SOURCE.RowNumber = 1
)
WHEN MATCHED THEN
UPDATE SET 
	TARGET.intSrcId = SOURCE.intSrcId, 
	TARGET.strSrcTransactionNo = SOURCE.strSrcTransactionNo, 
	TARGET.strSrcModuleName = SOURCE.strSrcModuleName,
	TARGET.strSrcTransactionType = SOURCE.strSrcTransactionType
WHEN NOT MATCHED THEN
	INSERT
	(
		guiTransactionGraphId, dtmLinkUtcDate, strOperation,
		intSrcId, strSrcTransactionNo, strSrcModuleName, strSrcTransactionType,
		intDestId, strDestTransactionNo, strDestModuleName, strDestTransactionType
	)
	VALUES 
	(
		SOURCE.guiTransactionGraphId, SOURCE.dtmLinkUtcDate, SOURCE.strOperation,
		SOURCE.intSrcId, SOURCE.strSrcTransactionNo, SOURCE.strSrcModuleName, SOURCE.strSrcTransactionType,
		SOURCE.intDestId, SOURCE.strDestTransactionNo, SOURCE.strDestModuleName, SOURCE.strDestTransactionType
	);

;WITH CTE 
AS (
	SELECT	RN = ROW_NUMBER() OVER (PARTITION BY strSrcTransactionNo, strDestTransactionNo ORDER BY strSrcTransactionNo)
	FROM	tblICTransactionLinks 
)
DELETE FROM CTE WHERE RN > 1;

INSERT INTO tblICTransactionNodes (
	guiTransactionGraphId
	, intTransactionId
	, strTransactionNo
	, strTransactionType
	, strModuleName
)
SELECT DISTINCT 
	COALESCE(related.guiTransactionGraphId, @GraphId)
	, intSrcId
	, strSrcTransactionNo
	, strSrcTransactionType
	, strSrcModuleName
FROM @TransactionLinks l
OUTER APPLY (
	SELECT TOP 1 nodes.guiTransactionGraphId
	FROM tblICTransactionNodes nodes
	WHERE nodes.strTransactionNo = l.strSrcTransactionNo
) related
WHERE 
	NOT EXISTS(SELECT TOP 1 1 FROM tblICTransactionNodes WHERE strTransactionNo = l.strSrcTransactionNo)
	AND intSrcId IS NOT NULL 

INSERT INTO tblICTransactionNodes (
	guiTransactionGraphId
	, intTransactionId
	, strTransactionNo
	, strTransactionType
	, strModuleName
)
SELECT DISTINCT 
	COALESCE(related.guiTransactionGraphId, @GraphId)
	, intDestId
	, strDestTransactionNo
	, strDestTransactionType
	, strDestModuleName
FROM @TransactionLinks l
OUTER APPLY (
	SELECT TOP 1 nodes.guiTransactionGraphId
	FROM tblICTransactionNodes nodes
	WHERE nodes.strTransactionNo = l.strSrcTransactionNo
) related
WHERE 
	NOT EXISTS(SELECT TOP 1 1 FROM tblICTransactionNodes WHERE strTransactionNo = l.strDestTransactionNo)
	AND intDestId IS NOT NULL 

END

END

GO