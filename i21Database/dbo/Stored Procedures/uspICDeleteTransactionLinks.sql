CREATE PROCEDURE [dbo].uspICDeleteTransactionLinks(@intReceiptId INT, @strReceiptNumber NVARCHAR(50))
AS
BEGIN

    DELETE tblICTransactionLinks 
    FROM tblICTransactionLinks
    WHERE (intDestId = @intReceiptId AND strDestTransactionNo = @strReceiptNumber) OR 
    (intSrcId = @intReceiptId AND strSrcTransactionNo = @strReceiptNumber)

    DELETE tblICTransactionNodes
    FROM tblICTransactionNodes 
    WHERE intTransactionId = @intReceiptId 
    AND strTransactionNo = @strReceiptNumber

END

GO