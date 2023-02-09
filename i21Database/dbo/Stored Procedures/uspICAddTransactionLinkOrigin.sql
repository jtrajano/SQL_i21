CREATE PROCEDURE [dbo].uspICAddTransactionLinkOrigin(
	@intTransactionId INT, 
    @strTransactionNo NVARCHAR(50),
    @strTransactionType NVARCHAR(100),
    @strModuleName NVARCHAR(100)
)
AS
BEGIN

DECLARE @GraphId UNIQUEIDENTIFIER = NEWID()
DECLARE @LinkDate DATE = GETUTCDATE()

INSERT INTO tblICTransactionNodes
(
	guiTransactionGraphId,
	intTransactionId,
	strTransactionNo,
	strTransactionType,
	strModuleName
)
SELECT 
	@GraphId,
	TransactionOrigin.intDestId, 
	TransactionOrigin.strDestTransactionNo, 
	TransactionOrigin.strDestTransactionType,
	TransactionOrigin.strDestModuleName
FROM (
	SELECT
		@intTransactionId AS intDestId, 
		@strTransactionNo COLLATE Latin1_General_CI_AS AS strDestTransactionNo, 
		@strTransactionType COLLATE Latin1_General_CI_AS AS strDestTransactionType,
		@strModuleName COLLATE Latin1_General_CI_AS AS strDestModuleName
	) AS TransactionOrigin LEFT JOIN tblICTransactionNodes Nodes
		ON TransactionOrigin.intDestId = Nodes.intTransactionId
		AND TransactionOrigin.strDestTransactionNo = Nodes.strTransactionNo
		AND TransactionOrigin.strDestTransactionType = Nodes.strTransactionType
		AND TransactionOrigin.strDestModuleName = Nodes.strModuleName
WHERE
	Nodes.intTransactionId IS NULL
	AND TransactionOrigin.intDestId IS NOT NULL 


INSERT INTO tblICTransactionLinks(
	guiTransactionGraphId, dtmLinkUtcDate, strOperation,
	intDestId, strDestTransactionNo, strDestModuleName, strDestTransactionType)
SELECT 
	COALESCE(related.guiTransactionGraphId, TransactionOrigin.guiTransactionGraphId),
	@LinkDate, 
	'Create',
	intDestId, 
	strDestTransactionNo, 
	strDestModuleName, 
	strDestTransactionType
FROM (
	SELECT 
		@GraphId AS guiTransactionGraphId, 
		@intTransactionId AS intDestId, 
		@strTransactionNo COLLATE Latin1_General_CI_AS AS strDestTransactionNo, 
		@strModuleName COLLATE Latin1_General_CI_AS AS strDestModuleName, 
		@strTransactionType COLLATE Latin1_General_CI_AS AS strDestTransactionType
	) AS TransactionOrigin
	OUTER APPLY (
		SELECT TOP 1 nodes.guiTransactionGraphId
		FROM tblICTransactionNodes nodes
		WHERE nodes.strTransactionNo = TransactionOrigin.strDestTransactionNo
	) related
WHERE 
	NOT EXISTS(
		SELECT TOP 1 1 FROM tblICTransactionLinks
		WHERE intSrcId IS NULL AND
		(
			intDestId = @intTransactionId 
			AND 
			strDestTransactionNo = @strTransactionNo COLLATE Latin1_General_CI_AS
			AND 
			strDestTransactionType = @strTransactionType COLLATE Latin1_General_CI_AS
			AND
			strDestModuleName = @strModuleName COLLATE Latin1_General_CI_AS
		)
	)

END

GO