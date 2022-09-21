CREATE PROCEDURE [dbo].uspICDeleteTransactionLink(
	@TransactionLinks udtICTransactionLinks READONLY
)
AS
BEGIN

	-- Delete the specific transaction link. 
	DELETE d 
	FROM 
	(
		SELECT Links.intTransactionLinkId
		FROM 
			tblICTransactionLinks Links INNER JOIN @TransactionLinks Link
				ON Links.intSrcId = Link.intSrcId 
				AND Links.strSrcTransactionNo = Link.strSrcTransactionNo 
				AND Links.strSrcModuleName = Link.strSrcModuleName 
				AND Links.strSrcTransactionType = Link.strSrcTransactionType 	
				AND Links.intDestId = Link.intDestId 
				AND Links.strDestTransactionNo = Link.strDestTransactionNo 
				AND Links.strDestModuleName = Link.strDestModuleName 
				AND Links.strDestTransactionType = Link.strDestTransactionType
	) list 
	INNER JOIN tblICTransactionLinks d
		ON list.intTransactionLinkId = d.intTransactionLinkId			   

	-- Delete the source node
	DELETE d
	FROM (
			SELECT 
				SourceNodes.intTransactionNodeId
			FROM 
				tblICTransactionNodes SourceNodes INNER JOIN @TransactionLinks Link
					ON SourceNodes.intTransactionId = Link.intSrcId 
					AND SourceNodes.strTransactionNo = Link.strSrcTransactionNo 
					AND SourceNodes.strModuleName = Link.strSrcModuleName 
					AND SourceNodes.strTransactionType = Link.strSrcTransactionType
				OUTER APPLY (
					SELECT TOP 1 
						Links.intTransactionLinkId 
					FROM tblICTransactionLinks Links
					WHERE
						Links.intSrcId = Link.intSrcId 
						AND Links.strSrcTransactionNo = Link.strSrcTransactionNo 
						AND Links.strSrcModuleName = Link.strSrcModuleName 
						AND Links.strSrcTransactionType = Link.strSrcTransactionType 
				) Links 
			WHERE 
				Links.intTransactionLinkId IS NULL
		) list 
		INNER JOIN tblICTransactionNodes d
			ON list.intTransactionNodeId = d.intTransactionNodeId
	
	-- Delete the source node
	DELETE d
	FROM (
			SELECT 
				SourceNodes.intTransactionNodeId
			FROM 
				tblICTransactionNodes SourceNodes INNER JOIN @TransactionLinks Link
					ON SourceNodes.intTransactionId = Link.intSrcId 
					AND SourceNodes.strTransactionNo = Link.strSrcTransactionNo 
					AND SourceNodes.strModuleName = Link.strSrcModuleName 
					AND SourceNodes.strTransactionType = Link.strSrcTransactionType
				OUTER APPLY (
					SELECT TOP 1 
						Links.intTransactionLinkId 
					FROM tblICTransactionLinks Links
					WHERE
						Links.intDestId = Link.intSrcId 
						AND Links.strDestTransactionNo = Link.strSrcTransactionNo 
						AND Links.strDestModuleName = Link.strSrcModuleName 
						AND Links.strDestTransactionType = Link.strSrcTransactionType 
				) Links 
			WHERE 
				Links.intTransactionLinkId IS NULL
		) list 
		INNER JOIN tblICTransactionNodes d
			ON list.intTransactionNodeId = d.intTransactionNodeId

	-- Delete the destination node
	DELETE d
	FROM (
			SELECT  
				DestinationNode.intTransactionNodeId
			FROM 
				tblICTransactionNodes DestinationNode INNER JOIN @TransactionLinks Link
				ON DestinationNode.intTransactionId = Link.intDestId 
				AND DestinationNode.strTransactionNo = Link.strDestTransactionNo 
				AND DestinationNode.strModuleName = Link.strDestModuleName 
				AND DestinationNode.strTransactionType = Link.strDestTransactionType
			OUTER APPLY (			
				SELECT TOP 1 
					Links.intTransactionLinkId
				FROM tblICTransactionLinks Links
				WHERE 
					Links.intDestId = Link.intDestId 
					AND Links.strDestTransactionNo = Link.strDestTransactionNo 
					AND Links.strDestModuleName = Link.strDestModuleName 
					AND Links.strDestTransactionType = Link.strDestTransactionType
			) Links
			WHERE 
				Links.intTransactionLinkId IS NULL
		) list 		
		INNER JOIN tblICTransactionNodes d
			ON list.intTransactionNodeId = d.intTransactionNodeId

	-- Delete the destination node
	DELETE d
	FROM (
			SELECT  
				DestinationNode.intTransactionNodeId
			FROM 
				tblICTransactionNodes DestinationNode INNER JOIN @TransactionLinks Link
					ON DestinationNode.intTransactionId = Link.intDestId 
					AND DestinationNode.strTransactionNo = Link.strDestTransactionNo 
					AND DestinationNode.strModuleName = Link.strDestModuleName 
					AND DestinationNode.strTransactionType = Link.strDestTransactionType
				OUTER APPLY(
					SELECT TOP 1 
						Links.intTransactionLinkId
					FROM tblICTransactionLinks Links
					WHERE
						Links.intSrcId = Link.intDestId 
						AND Links.strSrcTransactionNo = Link.strDestTransactionNo 
						AND Links.strSrcModuleName = Link.strDestModuleName 
						AND Links.strSrcTransactionType = Link.strDestTransactionType 
				) Links
			WHERE 
				Links.intTransactionLinkId IS NULL
		) list 
		INNER JOIN tblICTransactionNodes d
			ON list.intTransactionNodeId = d.intTransactionNodeId

END
