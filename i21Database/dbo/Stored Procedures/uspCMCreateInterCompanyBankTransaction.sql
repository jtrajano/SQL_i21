CREATE PROCEDURE uspCMCreateInterCompanyBankTransaction
@intTransactionid INT
AS

IF NOT EXISTS (SELECT 1 FROM tblCMBankTransaction WHERE ysnInterCompany =1 AND  intTransactionId = @intTransactionId)
    RETURN

DECLARE @intTransactionDetailId INT
DECLARE @strDatabase NVARCHAR(30)
DECLARE @sql NVARCHAR(MAX)
DECLARE @strRefreshScript NVARCHAR(MAX)
DECLARE @tbl TABLE (  intTransactionDetailId INT, strDatabase NVARCHAR(30), strRefreshScript NVARCHAR(max))


INSERT INTO @tbl ( intTransactionDetailId , strDatabase, strRefreshScript) 
SELECT  intTransactionDetailId , strDatabase ,strRefreshScript
FROM tblCMBankTransactionDetail BT 
JOIN tblGLAccount A on A.intAccountId = BT.intGLAccountId 
join tblGLAccountSegmentMapping S on A.intAccountId = S.intAccountId
join tblGLAccountSegment D on D.intAccountSegmentId = S.intAccountSegmentId
join tblGLAccountStructure C on C.intAccountStructureId = D.intAccountStructureId
join tblGLSubsidiaryCompany E on E.intCompanySegmentId =  D.intAccountSegmentId
WHERE intTransactionId =@intTransactionId AND intStructureType = 6
GROUP BY intTransactionDetailId , strDatabase,strRefreshScript

WHILE EXISTS( SELECT 1 FROM  @tbl)
BEGIN

SELECT TOP 1 @intTransactionDetailId = intTransactionDetailId, @strDatabase = strDatabase, @strRefreshScript =strRefreshScript FROM @tbl


IF ISNULL(@strRefreshScript,'') <> ''
    EXEC sp_executesql @strRefreshScript



SET @sql =
'
DECLARE @intTransactionId INT
DECLARE @strCurrencyTransaction NVARCHAR(10)


select top 1 @intTransactionId= intTransactionId  from tblCMBankTransactionDetail where intTransactionDetailId = @intTransactionDetailId
select @strCurrencyTransaction = strCurrency FROM vyuCMGetBankTransaction WHERE @intTransactionId = intTransactionId

IF NOT EXISTS(
    SELECT 1 FROM [Subsidiary].dbo.tblSMCurrency A WHERE @strCurrencyTransaction = strCurrency
      
)
BEGIN
 
    RAISERROR (''Currency %s is not existing in [Subsidiary] '', 16,1,@strCurrencyTransaction);  
	RETURN
END


IF OBJECT_ID(''tempdb..##tmpCMBT'') IS NOT NULL DROP TABLE ##tmpCMBT

SELECT 
        intBankTransactionTypeId
        --,intBankAccountId
  
        ,dblExchangeRate
       --, intCurrencyExchangeRateTypeId
        ,dtmDate
        ,strPayee
        ,strAddress
        ,strZipCode
        ,strCity
        ,strState
        ,strCountry
        ,dblAmount
        ,dblShortAmount
        ,intShortGLAccountId
        ,strAmountInWords
        , strMemo
        ,strReferenceNo
        ,strSourceSystem
        ,intEntityId
        ,intCreatedUserId
        -- ,intCompanyLocationId
        ,dtmCreated
        ,intLastModifiedUserId
        ,dtmLastModified

 INTO ##tmpCMBT FROM vyuCMGetBankTransaction WHERE @intTransactionId = intTransactionId

IF OBJECT_ID(''tempdb..##tmpCMBTD'') IS NOT NULL DROP TABLE ##tmpCMBTD

SELECT 
    dtmDate
    ,strAccountId --intGLAccountId
    ,intGLAccountId
    ,strDescription
    ,dblDebit
    ,dblCredit
    ,dblDebitForeign
    ,dblCreditForeign
    ,intEntityId
    ,intCreatedUserId
    ,dtmCreated
    ,intLastModifiedUserId
    ,dtmLastModified
    ,dblExchangeRate
    ,intCurrencyId
    ,intCurrencyExchangeRateTypeId
    ,strCurrencyExchangeRateType
INTO  ##tmpCMBTD
FROM tblCMBankTransactionDetail A

OUTER APPLY (
    SELECT TOP 1  strAccountId FROM tblGLAccount WHERE intAccountId = A.intGLAccountId

)B

OUTER APPLY (
    SELECT TOP 1  strCurrencyExchangeRateType FROM tblSMCurrencyExchangeRateType WHERE intCurrencyExchangeRateTypeId = A.intCurrencyExchangeRateTypeId

)D

WHERE  
 @intTransactionDetailId = intTransactionDetailId


UPDATE A SET intCurrencyId = B.intCurrencyID
FROM
##tmpCMBTD A 
outer apply(
    SELECT top 1  intCurrencyID from	[Subsidiary].dbo.tblSMCurrency B  
    where strCurrency=@strCurrencyTransaction
)B




IF NOT EXISTS(
    SELECT 1 FROM [Subsidiary].dbo.tblGLAccount A  JOIN  ##tmpCMBTD B
        ON A.strAccountId COLLATE Latin1_General_CI_AS = B.strAccountId COLLATE Latin1_General_CI_AS
     
)
BEGIN
    DECLARE @strAccountId NVARCHAR(10)
     SELECT top 1 @strAccountId = B.strAccountId FROM  ##tmpCMBTD B
       

    RAISERROR (''Account Id %s is not existing in [Subsidiary] '', 16,1,@strAccountId);  
    RETURN

END
ELSE
BEGIN
    UPDATE A SET intGLAccountId = B.intAccountId
    FROM
    ##tmpCMBTD A JOIN [Subsidiary].dbo.tblGLAccount B 
      ON A.strAccountId COLLATE Latin1_General_CI_AS = B.strAccountId COLLATE Latin1_General_CI_AS

END



IF  EXISTS(
    SELECT 1 FROM [Subsidiary].dbo.tblSMCurrencyExchangeRateType A RIGHT JOIN  ##tmpCMBTD B
        ON A.strCurrencyExchangeRateType COLLATE Latin1_General_CI_AS = B.strCurrencyExchangeRateType COLLATE Latin1_General_CI_AS
        WHERE isnull(B.strCurrencyExchangeRateType ,'''') <> ''''
        AND A.strCurrencyExchangeRateType IS NULL
)
BEGIN
    DECLARE @strCurrencyExchangeRateType NVARCHAR(10)
     SELECT top 1 @strCurrencyExchangeRateType = B.strCurrencyExchangeRateType FROM  [Subsidiary].dbo.tblSMCurrencyExchangeRateType A RIGHT JOIN  ##tmpCMBTD B
        ON A.strCurrencyExchangeRateType COLLATE Latin1_General_CI_AS = B.strCurrencyExchangeRateType COLLATE Latin1_General_CI_AS
        WHERE isnull(B.strCurrencyExchangeRateType ,'''') <> ''''
        AND A.strCurrencyExchangeRateType IS NULL

    RAISERROR (''Currency Exchange Rate Type Id %s is not existing in [Subsidiary] '', 16,1,@strCurrencyExchangeRateType);  
    RETURN

END
ELSE
BEGIN
    UPDATE A SET intCurrencyExchangeRateTypeId = B.intCurrencyExchangeRateTypeId
    FROM
    ##tmpCMBTD A JOIN [Subsidiary].dbo.tblSMCurrencyExchangeRateType B 
      ON A.strCurrencyExchangeRateType COLLATE Latin1_General_CI_AS = B.strCurrencyExchangeRateType COLLATE Latin1_General_CI_AS

END

DECLARE @intBankAccountId INT

SELECT  TOP 1 @intBankAccountId = intBankAccountId FROM [Subsidiary].dbo.vyuCMBankAccount WHERE strCurrency = @strCurrencyTransaction


DECLARE @dblAmount DECIMAL(18,6) 

SELECT  @dblAmount = ( dblCredit - dblDebit ) from ##tmpCMBTD

DECLARE  @newTransId NVARCHAR(30)
DECLARE   @intStartingNumber INT
SELECT @intStartingNumber = CASE WHEN @dblAmount > 0 THEN 11 ELSE  10 END
EXEC [Subsidiary].dbo.uspSMGetStartingNumber @intStartingNumber, @newTransId OUT

INSERT INTO [Subsidiary].dbo.tblCMBankTransaction (
	strTransactionId
	  ,intBankTransactionTypeId
	  ,intBankAccountId
        ,dblExchangeRate
        ,dtmDate
        ,strPayee
        ,strAddress
        ,strZipCode
        ,strCity
        ,strState
        ,strCountry
        ,dblAmount
        ,dblShortAmount
        ,intShortGLAccountId
        , strMemo
        ,strReferenceNo
        ,strSourceSystem
        ,intEntityId
        ,intCreatedUserId
        -- ,intCompanyLocationId
        ,dtmCreated
        ,intLastModifiedUserId
        ,dtmLastModified
		,strAmountInWords
)
select
		@newTransId
		,case when @dblAmount > 0 then 2 else 1 end
        ,@intBankAccountId
        ,dblExchangeRate
        ,dtmDate
        ,strPayee
        ,strAddress
        ,strZipCode
        ,strCity
        ,strState
        ,strCountry
        ,@dblAmount * -1
        ,dblShortAmount
        ,intShortGLAccountId
        , strMemo
        ,strReferenceNo
        ,strSourceSystem
        ,intEntityId
        ,intCreatedUserId
        -- ,intCompanyLocationId
        ,dtmCreated
        ,intLastModifiedUserId
        ,dtmLastModified
		,dbo.fnConvertNumberToWord(dblAmount * -1)
from ##tmpCMBT

DECLARE @newintTransId INT

SELECT @newintTransId= SCOPE_IDENTITY()

UPDATE tblCMBankTransactionDetail set strRefreshScript =
REPLACE (''DELETE FROM [Subsidiary].dbo.tblCMBankTransaction WHERE intTransactionId = @newintTransId'',''@newintTransId'',@newintTransId)
WHERE intTransactionDetailId = @intTransactionDetailId


INSERT INTO [Subsidiary].dbo.tblCMBankTransactionDetail(
	intTransactionId
	,dtmDate
    ,intGLAccountId
    ,strDescription
    ,dblDebit
    ,dblCredit
    ,dblDebitForeign
    ,dblCreditForeign
    ,intEntityId
    ,intCreatedUserId
    ,dtmCreated
    ,intLastModifiedUserId
    ,dtmLastModified
    ,dblExchangeRate
    ,intCurrencyId
    ,intCurrencyExchangeRateTypeId
)
SELECT 
	@newintTransId
	,dtmDate
    ,intGLAccountId
    ,strDescription
    ,dblCredit
    ,dblDebit
	,dblCreditForeign
    ,dblDebitForeign
    ,intEntityId
    ,intCreatedUserId
    ,dtmCreated
    ,intLastModifiedUserId
    ,dtmLastModified
    ,dblExchangeRate
    ,intCurrencyId
    ,intCurrencyExchangeRateTypeId
FROM  ##tmpCMBTD
'

SELECT @sql = REPLACE (@sql,'[Subsidiary]', @strDatabase )
SELECT @sql = REPLACE (@sql,'@intTransactionDetailId', CAST ( @intTransactionDetailId AS NVARCHAR(10) ))

EXEC sp_executesql @sql

DELETE FROM @tbl where @intTransactionDetailId = intTransactionDetailId

END


