CREATE PROCEDURE [dbo].[uspGLGetBudget]
(
	@budgetCode INT,
	@intFiscalYearId INT,
	@dtmDateFrom DATETIME,
	@dtmDateTo DATETIME,
	@intAccountId INT,
	@budget DECIMAL (18,6) OUT

)
AS
SET @budget = 0
IF EXISTS (SELECT TOP 1 1  FROM tblFRBudget WHERE intAccountId = @intAccountId AND intBudgetCode = @budgetCode)
BEGIN
	DECLARE @dtmPeriod1 DATE
	DECLARE @dtmPeriod2 DATE
	DECLARE @periodOrder1 int
	DECLARE @periodOrder2 int
	DECLARE @strBudgetFieldName NVARCHAR(300) =''
	DECLARE @sql NVARCHAR(500)
	DECLARE @ParamDefinition NVARCHAR(500)

	SELECT @dtmPeriod1 = dtmStartDate from tblGLFiscalYearPeriod where @dtmDateFrom >= dtmStartDate and @dtmDateFrom <= dtmEndDate and intFiscalYearId = @intFiscalYearId
	SELECT @dtmPeriod2 = dtmStartDate from tblGLFiscalYearPeriod where @dtmDateTo >= dtmStartDate and @dtmDateTo <= dtmEndDate and intFiscalYearId = @intFiscalYearId
	
	IF @dtmPeriod1 IS NOT NULL
		SELECT @periodOrder1 =  COUNT(1) FROM tblGLFiscalYearPeriod WHERE dtmStartDate <= @dtmPeriod1 and intFiscalYearId = @intFiscalYearId
	ELSE
		SET @periodOrder1 = 1

	IF @dtmPeriod2 IS NOT NULL
		SELECT @periodOrder2 = COUNT(1) FROM tblGLFiscalYearPeriod WHERE dtmStartDate <= @dtmPeriod2 and intFiscalYearId = @intFiscalYearId
	ELSE
		SET @periodOrder2 = 13
	
	--COMPUTE THE BUDGET
	WHILE @periodOrder1 <= @periodOrder2
	BEGIN
		SET @strBudgetFieldName += 'dblBudget' + CONVERT(VARCHAR(2),@periodOrder1) + ','
		SET @periodOrder1+=1
	END
	SELECT @strBudgetFieldName=  LEFT(@strBudgetFieldName ,LEN(@strBudgetFieldName)-1)
		
	SET @ParamDefinition = N'@intAccountId INT, @budgetCode INT,  @budgetOut DECIMAL(18,6) OUTPUT'
	SET @sql =
	'SELECT @budgetOut =SUM(budgets)
	FROM 
	   (SELECT '+ @strBudgetFieldName +
	   ' FROM tblFRBudget WHERE intAccountId = @intAccountId and intBudgetCode = @budgetCode) p
	UNPIVOT
	   (budgets FOR Budgets IN 
		  ('+ @strBudgetFieldName +')
	)AS unpvt;'
	
	EXEC sp_executesql @sql,@ParamDefinition,@intAccountId = @intAccountId, @budgetCode = @budgetCode, @budgetOut = @budget OUTPUT;

END