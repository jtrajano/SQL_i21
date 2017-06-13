CREATE PROCEDURE [dbo].[uspGLGetConsolidateWarning]
(
	@dtmDate DATETIME,
	@dbName NVARCHAR(50)
)

AS
DECLARE @strCommand NVARCHAR(MAX)
SET @strCommand ='
		DECLARE @ysnOpen BIT, @ysnUnpostedTrans BIT, @intFiscalYearId INT,@intFiscalPeriodId INT
		SELECT @ysnOpen = 0 , @ysnUnpostedTrans = 0
     	use [consolidatingDb]
		SELECT TOP 1
		@ysnOpen=  ysnOpen,
		@intFiscalYearId = intFiscalYearId,
		@intFiscalPeriodId = intGLFiscalYearPeriodId
		FROM dbo.tblGLFiscalYearPeriod
		WHERE ''[dtmDateConsolidate]''
		BETWEEN dtmStartDate and dtmEndDate
		exec dbo.uspGLGetAllUnpostedTransactionsByFiscal @intFiscalYearId,
		1,
		@intFiscalPeriodId,
		''GL'' ,@ysnUnpostedTrans OUT
		SELECT @ysnOpen ysnFiscalOpen, @ysnUnpostedTrans ysnUnpostedTrans'
SELECT @strCommand = REPLACE ( REPLACE (@strCommand,'[dtmDateConsolidate]', @dtmDate), '[consolidatingDb]', @dbName)
EXEC sp_executesql @strCommand


