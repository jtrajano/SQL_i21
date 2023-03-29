CREATE PROCEDURE uspGLMergeClusterDetail
@Ids Id READONLY,
@AccountGroupClusterId INT,
@AccountGroupId INT
AS
MERGE INTO tblGLAccountGroupClusterDetail AS Destination
USING (
	SELECT intId intAccountId, @AccountGroupClusterId intAccountGroupClusterId,@AccountGroupId  intAccountGroupId
	FROM @Ids
)AS Source
ON 
Destination.intAccountId = Source.intAccountId AND
Destination.intAccountGroupClusterId = Source.intAccountGroupClusterId

WHEN MATCHED THEN
UPDATE  
SET Destination.intAccountGroupId = Source.intAccountGroupId,
intConcurrencyId = ISNULL(intConcurrencyId,0) + 1
WHEN NOT MATCHED BY TARGET THEN
INSERT  (
	intAccountId,
	intAccountGroupClusterId,
	intAccountGroupId,
	intConcurrencyId
)
VALUES(
	Source.intAccountId,
	Source.intAccountGroupClusterId,
	Source.intAccountGroupId,
	1

);