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
    SELECT  CAST(Item AS INT) intTransactionId FROM dbo.fnSplitString(@intTransactionIds, ',')
    )
	INSERT INTO @tbl(intTransactionId,ysnGenerated)
    SELECT A.intTransactionId,0 FROM TransIds A LEFT JOIN
        tblCMEFTNumbers B ON B.intTransactionId = A.intTransactionId
        AND B.strProcessType = @strProcessType
        WHERE B.intTransactionId IS NULL or ISNULL(B.intEFTNoId,0) = 0

	
   
   IF EXISTS (SELECT 1 FROM tblCMEFTNumbers WHERE intBankAccountId =@intBankAccountId)
   BEGIN
      SELECT @intEFTNextNo = MAX(intEFTNoId) FROM tblCMEFTNumbers WHERE intBankAccountId = @intBankAccountId 
	  SELECT @intEFTNextNo = ISNULL(@intEFTNextNo,0) +1
	  PRINT('JEFF')
   END
   ELSE
	SELECT @intEFTNextNo = intEFTNextNo FROM tblCMBankAccount WHERE intBankAccountId = @intBankAccountId

  

  SELECT @intEFTNextNo = ISNULL(@intEFTNextNo,0) 
  IF @intEFTNextNo = 0  SET @intEFTNextNo = 1





    WHILE EXISTS(SELECT 1 FROM @tbl WHERE ysnGenerated = 0)
    BEGIN

        SELECT TOP 1 @intTransactionId = intTransactionId FROM @tbl
        INSERT INTO tblCMEFTNumbers (intTransactionId, intBankAccountId,intEFTNoId, strProcessType)
            SELECT intTransactionId , @intBankAccountId, @intEFTNextNo, @strProcessType from @tbl WHERE  intTransactionId = @intTransactionId
        
       

        UPDATE @tbl SET ysnGenerated = 1, intEFTNoId = @intEFTNextNo WHERE intTransactionId = @intTransactionId

         SELECT @intEFTNextNo = @intEFTNextNo +1

         UPDATE tblCMBankAccount SET intEFTNextNo = @intEFTNextNo WHERE intBankAccountId = @intBankAccountId

    END
	

    IF @strProcessType = 'ACH From Customer'
        UPDATE A
        SET strReferenceNo = CAST(intEFTNoId AS NVARCHAR(30))
        FROM
        tblCMUndepositedFund A JOIN @tbl B ON A.intUndepositedFundId = B.intTransactionId
        WHERE ISNULL(strReferenceNo,'') = ''
        AND B.ysnGenerated = 1
         
    ELSE

        UPDATE A SET strReferenceNo = CAST(B.intEFTNoId AS NVARCHAR(30)) FROM tblCMBankTransaction A JOIN  @tbl B ON A.intTransactionId = B.intTransactionId
        WHERE B.ysnGenerated = 1
   


END


