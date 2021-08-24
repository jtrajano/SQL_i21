CREATE PROCEDURE [dbo].uspICDeleteTransactionLinks(
    @intReceiptId INT, 
    @strReceiptNumber NVARCHAR(50),
    @strTransactionType NVARCHAR(100),
    @strModuleName NVARCHAR(100)
    )
AS
BEGIN

    DELETE tblICTransactionLinks 
    FROM tblICTransactionLinks
    WHERE 
    (
        intDestId = @intReceiptId AND 
        strDestTransactionNo = @strReceiptNumber AND
        strDestTransactionType = @strTransactionType AND
        strDestModuleName = @strModuleName
    ) 
    OR 
    (
        intSrcId = @intReceiptId AND 
        strSrcTransactionNo = @strReceiptNumber AND
        strSrcTransactionType = @strTransactionType AND
        strSrcModuleName = @strModuleName
    )

    DELETE tblICTransactionNodes
    FROM tblICTransactionNodes 
    WHERE 
    intTransactionId = @intReceiptId AND
    strTransactionNo = @strReceiptNumber AND
    strTransactionType = @strTransactionType AND
    strModuleName = @strModuleName

END

GO