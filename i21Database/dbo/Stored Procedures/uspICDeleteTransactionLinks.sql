CREATE PROCEDURE [dbo].uspICDeleteTransactionLinks(@intReceiptId INT READONLY, @strReceiptNumber NVARCHAR(50) READONLY)
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