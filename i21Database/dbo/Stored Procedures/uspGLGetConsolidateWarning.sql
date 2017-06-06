CREATE PROCEDURE [dbo].[uspGLGetConsolidateWarning]
(
	@dtmDate DATETIME,
	@dbName NVARCHAR(50)
)

AS
DECLARE @strCommand NVARCHAR(MAX)
SET @strCommand ='
		DECLARE @ysnOpen BIT, @ysnWithUnpostedTrans BIT, @intFiscalYearId INT,@intFiscalPeriodId INT
		SELECT @ysnOpen = 0 , @ysnWithUnpostedTrans = 0
		use [consolidatingDb]
		SELECT TOP 1
		@ysnOpen= ysnOpen,
		@intFiscalYearId = intFiscalYearId,
		@intFiscalPeriodId = intGLFiscalYearPeriodId
		FROM dbo.tblGLFiscalYearPeriod
		WHERE ''[dtmDateConsolidate]'' 
		BETWEEN dtmStartDate and dtmEndDate
		exec dbo.uspGLGetAllUnpostedTransactionsByFiscal @intFiscalYearId,
		1,
		@intFiscalPeriodId,
		''All'' ,@ysnWithUnpostedTrans OUT
		SELECT @ysnOpen ysnOpen, @ysnWithUnpostedTrans ysnWithUnposted'
SELECT @strCommand = REPLACE ( REPLACE (@strCommand,'[dtmDateConsolidate]', @dtmDate), '[consolidatingDb]', @dbName)
EXEC sp_executesql @strCommand


