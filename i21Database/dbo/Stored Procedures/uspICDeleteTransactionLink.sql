CREATE PROCEDURE [dbo].uspICDeleteTransactionLink(@TransactionLinks udtICTransactionLinks READONLY)
AS
BEGIN

DELETE Links
FROM tblICTransactionLinks Links
INNER JOIN @TransactionLinks Link
ON 
Links.intSrcId = Link.intSrcId 
AND 
Links.strSrcTransactionNo = Link.strSrcTransactionNo 
AND 
Links.strSrcModuleName = Link.strSrcModuleName 
AND 
Links.strSrcTransactionType = Link.strSrcTransactionType 
AND
Links.intDestId = Link.intDestId 
AND 
Links.strDestTransactionNo = Link.strDestTransactionNo 
AND 
Links.strDestModuleName = Link.strDestModuleName 
AND 
Links.strDestTransactionType = Link.strDestTransactionType



DELETE SourceNodes
FROM tblICTransactionNodes SourceNodes
INNER JOIN @TransactionLinks Link
ON 
SourceNodes.intTransactionId = Link.intSrcId 
AND 
SourceNodes.strTransactionNo = Link.strSrcTransactionNo 
AND 
SourceNodes.strModuleName = Link.strSrcModuleName 
AND 
SourceNodes.strTransactionType = Link.strSrcTransactionType
LEFT JOIN tblICTransactionLinks Links
ON 
(
Links.intSrcId = Link.intSrcId 
AND 
Links.strSrcTransactionNo = Link.strSrcTransactionNo 
AND 
Links.strSrcModuleName = Link.strSrcModuleName 
AND 
Links.strSrcTransactionType = Link.strSrcTransactionType 
)
OR
(
Links.intDestId = Link.intSrcId 
AND 
Links.strDestTransactionNo = Link.strSrcTransactionNo 
AND 
Links.strDestModuleName = Link.strSrcModuleName 
AND 
Links.strDestTransactionType = Link.strSrcTransactionType
)
WHERE 
Links.intTransactionLinkId IS NULL


DELETE DestinationNode
FROM tblICTransactionNodes DestinationNode
INNER JOIN @TransactionLinks Link
ON 
DestinationNode.intTransactionId = Link.intDestId 
AND 
DestinationNode.strTransactionNo = Link.strDestTransactionNo 
AND 
DestinationNode.strModuleName = Link.strDestModuleName 
AND 
DestinationNode.strTransactionType = Link.strDestTransactionType
LEFT JOIN tblICTransactionLinks Links
ON 
(
Links.intDestId = Link.intDestId 
AND 
Links.strDestTransactionNo = Link.strDestTransactionNo 
AND 
Links.strDestModuleName = Link.strDestModuleName 
AND 
Links.strDestTransactionType = Link.strDestTransactionType
)
OR
(
Links.intSrcId = Link.intDestId 
AND 
Links.strSrcTransactionNo = Link.strDestTransactionNo 
AND 
Links.strSrcModuleName = Link.strDestModuleName 
AND 
Links.strSrcTransactionType = Link.strDestTransactionType 
)
WHERE 
Links.intTransactionLinkId IS NULL

END

GO