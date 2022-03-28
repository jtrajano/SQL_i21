CREATE PROCEDURE uspCMUpdateEFTTable
(
    @intTransactionIds NVARCHAR(MAX), 
    @intBankAccountId INT,
    @strProcessType NVARCHAR(30)
)
AS
BEGIN
    DECLARE @tbl TABLE (

        intTransactionId INT,
        intBankAccountId INT,
        intEFTNoId INT,
        ysnGenerated BIT
    )
    DECLARE @intEFTNextNo INT
    DECLARE @intTransactionId INT

   
    ;WITH TransIds AS(
    SELECT  CAST(Item AS INT) intTransactionId FROM dbo.fnSplitString(@intTransactionId, ',')
    )
    INSERT INTO @tbl(intTransactionId,ysnGenerated)
    SELECT A.intTransactionId,0 FROM TransIds A LEFT JOIN
        tblCMEFTNumbers B ON B.intTransactionId = A.intTransactionId
        WHERE B.intTransactionId IS NULL

    

   
   IF EXISTS (SELECT 1 FROM tblCMEFTNumbers WHERE intBankAccountId =@intBankAccountId)
   BEGIN
      SELECT @intEFTNextNo = MAX(intEFTNextNo) FROM tblCMEFTNumber WHERE intBankAccountId = @intBankAccountId 
      SET @intEFTNextNo = @intEFTNextNo +1
   END
   ELSE
      SELECT @intEFTNextNo = intEFTNextNo FROM tblCMBankAccount WHERE intBankAccountId = @intBankAccountId



    WHILE EXISTS(SELECT 1 FROM @tbl WHERE ysnGenerated = 0)
    BEGIN

        SELECT TOP 1 @intTransactionId = intTransactionId FROM @tbl
        INSERT INTO tblCMEFTNumber (intTransactionId, intBankAccountId,intEFTNoId)
            SELECT intTransactionId , @intBankAccountId, @intEFTNextNo from @tbl WHERE  intTransactionId = @intTransactionId
        
        SELECT @intEFTNextNo = @intEFTNextNo +1

        UPDATE @tbl SET ysnGenerated = 1 WHERE intTransactionId = @intTransactionId

    END


    IF @strProcessType = 'ACH From Customer'
        UPDATE A
        SET strReferenceNo = CAST(intEFTNoId AS NVARCHAR(30))
        FROM
        tblCMUndepositedFund A JOIN @tbl B ON A.intUndepositedFundId = B.intTransactionId
        WHERE ISNULL(strReferenceNo,'') = ''
        AND ysnGenerated = 1
         
    ELSE

        UPDATE A SET strReferenceNo = CAST(B.intEFTNoId AS NVARCHAR(30)) FROM tblCMBankTransaction A JOIN  @tbl B ON A.intTransactionId = B.intTransactionId
        WHERE ysnGenerated = 1
   


END


