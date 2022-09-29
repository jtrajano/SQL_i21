GO
DECLARE @tblPeriod table (intFiscalPeriodId int, dtmStartDate DATETIME, dtmEndDate datetime)
DECLARE @intFiscalPeriodId int, @dtmStartDate DATETIME, @dtmEndDate DATETIME
INSERT INTO  @tblPeriod (intFiscalPeriodId , dtmStartDate, dtmEndDate )
SELECT intGLFiscalYearPeriodId, dtmStartDate, dtmEndDate FROM tblGLFiscalYearPeriod 
WHILE EXISTS(SELECT 1 FROM @tblPeriod)
BEGIN
	SELECT TOP 1 @intFiscalPeriodId = intFiscalPeriodId,@dtmStartDate =dtmStartDate,@dtmEndDate =dtmEndDate  FROM @tblPeriod ORDER BY dtmStartDate DESC
	WHILE EXISTS(SELECT 1 FROM tblGLDetail WHERE  dtmDate BETWEEN @dtmStartDate AND @dtmEndDate AND ysnIsUnposted = 0 AND intFiscalPeriodId is null)
	BEGIN
		;WITH cte AS(
			SELECT TOP 1000 intGLDetailId FROM tblGLDetail  WHERE dtmDate BETWEEN @dtmStartDate AND @dtmEndDate AND ysnIsUnposted = 0 AND intFiscalPeriodId IS NULL
		)

		UPDATE a SET intFiscalPeriodId = @intFiscalPeriodId FROM  tblGLDetail  a JOIN cte b on a.intGLDetailId = b.intGLDetailId
	END
	DELETE FROM @tblPeriod WHERE intFiscalPeriodId = @intFiscalPeriodId
END
GO
