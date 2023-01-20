
CREATE PROCEDURE uspCMRemoveRelatedTransactions
@strParentTransactionId NVARCHAR(30),
@intParentTransactionId INT = 0
AS
DECLARE @intTransactionIDFee INT, @strTransactionIDFee NVARCHAR(30),@BANK_FEE AS INT = 27
SELECT TOP 1 @intTransactionIDFee = F.intTransactionId, @strTransactionIDFee= F.strTransactionId FROM tblCMBankTransaction F 
WHERE F.strTransactionId = @strParentTransactionId + '-F'
AND	F.intBankTransactionTypeId = @BANK_FEE

IF @intTransactionIDFee IS NOT NULL
BEGIN
    UPDATE tblCMBankTransaction SET ysnPosted = 0 WHERE intTransactionId = @intTransactionIDFee--UNPOST FIRST BEFORE DELETE
    DELETE FROM tblCMBankTransaction  WHERE intTransactionId = @intTransactionIDFee
    DELETE FROM tblGLDetail WHERE strTransactionId = @strTransactionIDFee
END
IF @intParentTransactionId > 0
    DELETE FROM tblCMBankTransactionAdjustment WHERE intTransactionId = @intParentTransactionId OR intRelatedId = @intParentTransactionId