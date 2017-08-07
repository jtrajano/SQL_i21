﻿CREATE PROCEDURE [dbo].[uspGLGetConsolidateWarnings]
(@dtmDate DATETIME,
@strCompanyName nvarchar(100),
@resultId  INT OUT
)

AS


DECLARE @ysnOpen BIT, @ysnUnpostedTrans BIT, 
	@intFiscalYearId INT,@intFiscalPeriodId INT,
	@dtmStartDate DATETIME,	@dtmEndDate DATETIME

SELECT @ysnOpen = 0 , @ysnUnpostedTrans = 0

SELECT TOP 1
@ysnOpen=  ysnOpen,
@intFiscalYearId = intFiscalYearId,
@intFiscalPeriodId = intGLFiscalYearPeriodId
FROM dbo.tblGLFiscalYearPeriod
WHERE @dtmDate
BETWEEN dtmStartDate and dtmEndDate


IF @intFiscalYearId IS NULL
BEGIN
	INSERT INTO tblGLConsolidateResult ([ysnFiscalOpen] , [ysnUnpostedTrans],[strResult], strCompanyName)
	SELECT  0 , 0, ' Fiscal Period not existing in subsidiary company.', @strCompanyName
	SELECT @resultId = SCOPE_IDENTITY()
	RETURN
END



exec dbo.uspGLGetAllUnpostedTransactionsByFiscal @intFiscalYearId,
1,
@intFiscalPeriodId,
'GL' ,@ysnUnpostedTrans OUT
	
IF @ysnOpen = 1 or @ysnUnpostedTrans = 1 
BEGIN
	
	DECLARE @strResult NVARCHAR(1000)
	IF @ysnOpen =1 and @ysnUnpostedTrans = 0 SET @strResult = 'Fiscal Period is still open in the subsidiary company.'
	IF @ysnOpen =0 and @ysnUnpostedTrans = 1 SET @strResult = 'Fiscal Period have unposted transactions in the subsidiary company.'
	IF @ysnOpen =1 and @ysnUnpostedTrans = 1 SET @strResult = 'Fiscal Period is still open and have unposted transactions in the subsidiary company.'
	
	SELECT @ysnOpen = CASE WHEN @ysnOpen = 1 THEN 0 ELSE 1 END
	SELECT @ysnUnpostedTrans = CASE WHEN @ysnUnpostedTrans = 1 THEN 0 ELSE 1 END
	
	INSERT INTO tblGLConsolidateResult ([ysnFiscalOpen] , [ysnUnpostedTrans],[strResult], strCompanyName)
	SELECT @ysnOpen ysnFiscalOpen, @ysnUnpostedTrans ysnUnpostedTrans, @strResult, @strCompanyName

	
	SELECT @resultId = SCOPE_IDENTITY()
	
END