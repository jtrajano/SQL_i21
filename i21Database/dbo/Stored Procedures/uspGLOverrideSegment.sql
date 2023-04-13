CREATE PROCEDURE dbo.uspGLOverrideSegment
    @AccountIds Id READONLY,
    @CompanySegmentId INT,
    @Guid UNIQUEIDENTIFIER OUT
AS
BEGIN

    DECLARE @DateEntered DATETIME
    SELECT @Guid = NEWID(), @DateEntered = GETDATE()

DELETE FROM tblGLOverrideSegment WHERE dtmDate < DATEADD(HOUR, -1, @DateEntered)

INSERT INTO tblGLOverrideSegment(
      intAccountIdFrom,
        intAccountIdTo,
        intCompanySegmentId,
        guidId,
        dtmDate,
        intConcurrencyId
) 
 
SELECT  
intId ,
T.intAccountId,
@CompanySegmentId,
@Guid,
@DateEntered,
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

  
    

END