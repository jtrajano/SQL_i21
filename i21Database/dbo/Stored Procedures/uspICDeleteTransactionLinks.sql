CREATE PROCEDURE [dbo].uspICDeleteTransactionLinks(@TransactionLinks udtICTransactionLinks READONLY)
AS
BEGIN

DELETE TL FROM tblICTransactionLinks TL 
INNER JOIN @TransactionLinks L
ON L.intSrcId = TL.intSrcId AND 
L.strSrcTransactionNo = TL.strSrcTransactionNo AND
L.strSrcModuleName = TL.strSrcModuleName AND 
L.strSrcTransactionType = TL.strSrcTransactionType AND 
L.intDestId = TL.intDestId AND 
L.strDestTransactionNo = TL.strDestTransactionNo AND 
L.strDestModuleName = TL.strDestModuleName AND 
L.strDestTransactionType = TL.strDestTransactionType


END

GO