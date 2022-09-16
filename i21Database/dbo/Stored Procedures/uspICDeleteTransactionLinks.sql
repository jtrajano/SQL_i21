CREATE PROCEDURE [dbo].uspICDeleteTransactionLinks(
    @intTransactionId INT, 
    @strTransactionNo NVARCHAR(50),
    @strTransactionType NVARCHAR(100),
    @strModuleName NVARCHAR(100)
    )
AS
BEGIN

    DELETE tblICTransactionLinks 
    FROM tblICTransactionLinks
    WHERE 
    (
        intDestId = @intTransactionId 
        AND strDestTransactionNo = @strTransactionNo 
        AND strDestTransactionType = @strTransactionType 
        AND strDestModuleName = @strModuleName
    ) 

	DELETE tblICTransactionLinks 
    FROM tblICTransactionLinks
    WHERE 
    (
        intSrcId = @intTransactionId 
        AND strSrcTransactionNo = @strTransactionNo 
        AND strSrcTransactionType = @strTransactionType 
        AND strSrcModuleName = @strModuleName
    )

    DELETE tblICTransactionNodes
    FROM tblICTransactionNodes 
    WHERE 
		intTransactionId = @intTransactionId 
		AND strTransactionNo = @strTransactionNo 
		AND strTransactionType = @strTransactionType 
		AND strModuleName = @strModuleName

END

GO