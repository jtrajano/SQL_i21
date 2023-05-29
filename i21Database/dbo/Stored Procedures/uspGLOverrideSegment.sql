CREATE PROCEDURE dbo.uspGLOverrideSegment  
    @AccountIds Id READONLY,  
    @CompanySegmentId INT,  
    @intEntityId INT,
    @Guid UNIQUEIDENTIFIER OUT  
AS  
BEGIN  
  
    DECLARE @DateEntered DATETIME  
    SELECT  @Guid = NEWID(), @DateEntered = GETDATE()  
  
DELETE FROM tblGLOverrideSegment WHERE dtmDate < DATEADD(HOUR, -1, @DateEntered)  
  
INSERT INTO tblGLOverrideSegment(  
      intAccountIdFrom,  
        intAccountIdTo,  
        intCompanySegmentId,  
        guidId,  
        dtmDate,  
        strNewAccountId,  
        intConcurrencyId  
)   
SELECT    
intId ,  
T.intAccountId,  
@CompanySegmentId,  
@Guid,  
@DateEntered,  
O.strNewAccountId,  
1  
FROM @AccountIds A   
OUTER APPLY (  
    SELECT dbo.fnGLGetOverrideAccountBySegment(     
    intId,    
    NULL,  
    NULL,  
    @CompanySegmentId) strNewAccountId  
) O  
OUTER APPLY(  
  
    SELECT TOP 1 intAccountId FROM tblGLAccount WHERE strAccountId = O.strNewAccountId  
)T
  
IF EXISTS(SELECT 1 FROM tblGLOverrideSegment where  @Guid = guidId AND intAccountIdTo IS NULL)  
BEGIN
    DECLARE  @MissingAccounts GLMissingAccounts 
    INSERT INTO @MissingAccounts (strAccountId)
    SELECT strNewAccountId
        FROM   tblGLOverrideSegment
        WHERE   @Guid = guidId AND intAccountIdTo IS NULL
        GROUP  BY strNewAccountId     
    EXEC uspGLBuildMissingAccountsRevalueOverride @intEntityId,@MissingAccounts     
    SELECT  'Missing Account'  
END
ELSE  
 SELECT  'Success'  
  
  
END