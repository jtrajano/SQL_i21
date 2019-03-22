CREATE PROCEDURE [dbo].[uspGLGetBudget]
(
	@budgetCode INT,
	@intFiscalYearId INT,
	@dtmDateFrom DATETIME ='1900-01-01',
	@dtmDateTo DATETIME ='2100-01-01',
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
	DECLARE @strBudgetFieldName NVARCHAR(500) =''
	DECLARE @sql NVARCHAR(max)
	DECLARE @ParamDefinition NVARCHAR(500)

	SELECT @dtmPeriod1 = dtmStartDate from tblGLFiscalYearPeriod where @dtmDateFrom >= dtmStartDate and @dtmDateFrom <= dtmEndDate and intFiscalYearId = @intFiscalYearId
	SELECT @dtmPeriod2 = dtmStartDate from tblGLFiscalYearPeriod where @dtmDateTo >= dtmStartDate and @dtmDateTo <= dtmEndDate and intFiscalYearId = @intFiscalYearId

	IF @dtmPeriod2 IS NULL RETURN -1 

	IF NOT EXISTS
	(
		SELECT  TOP 1 1 FROM vyuGLAccountFiscalBudget
		WHERE intBudgetCode = @budgetCode	AND intFiscalYearId = @intFiscalYearId AND intAccountId = @intAccountId
	)
	RETURN -1 

	--SET @periodOrder1 = 1
	
	

	DECLARE @incomeType BIT = 0
	SELECT @incomeType = 1 FROM vyuGLAccountDetail A
	WHERE intAccountId = @intAccountId AND strAccountType IN ('Revenue','Expense')

	IF  EXISTS(SELECT TOP 1 1 FROM vyuGLAccountDetail where intAccountId = @intAccountId and strAccountType in('Revenue', 'Expense'))-- @incomeType =1
	BEGIN
		--FOR INCOME STATEMENT
		SELECT @periodOrder1 = COUNT(1) FROM tblGLFiscalYearPeriod WHERE dtmStartDate <= @dtmPeriod1 and intFiscalYearId = @intFiscalYearId	
		SELECT @periodOrder2 = COUNT(1) FROM tblGLFiscalYearPeriod WHERE dtmStartDate <= @dtmPeriod2 and intFiscalYearId = @intFiscalYearId
	END
	ELSE
	BEGIN
		-- FOR BALANCE SHEET ACCOUNTS THE BUDGET SHOULD ALWAYS BE THE SUM OF THE TOTAL BUDGET FOR THE YEAR (YTD) NO MATTER WHAT IS THE SELECTED DATE
		SET @periodOrder1 = 1
		SELECT @periodOrder2 = COUNT(1) FROM tblGLFiscalYearPeriod WHERE  dtmStartDate <= @dtmPeriod2 and intFiscalYearId = @intFiscalYearId
	END
	
	

	--COMPUTE THE BUDGET
	WHILE @periodOrder1 <= @periodOrder2
	BEGIN
		SET @strBudgetFieldName += 'dblBudget' + CONVERT(VARCHAR(2),@periodOrder1) + ','
		SET @periodOrder1+=1
	END
	SELECT @strBudgetFieldName=  LEFT(@strBudgetFieldName ,LEN(@strBudgetFieldName)-1)
		
	SET @ParamDefinition = N'@intAccountId INT,@intFiscalYearId INT, @budgetCode INT,  @budgetOut DECIMAL(18,6) OUTPUT'
	SET @sql =
	'SELECT @budgetOut =SUM(budgets)
	FROM 
	   (
	   SELECT ' + @strBudgetFieldName + ' FROM vyuGLAccountFiscalBudget WHERE intBudgetCode = @budgetCode	
	   AND intFiscalYearId = @intFiscalYearId AND intAccountId = @intAccountId
	   ) p
	UNPIVOT
	   (budgets FOR Budgets IN 
		  ('+ @strBudgetFieldName +')
	)AS unpvt;'
	EXEC sp_executesql @sql,@ParamDefinition,@intAccountId = @intAccountId, @intFiscalYearId = @intFiscalYearId, @budgetCode = @budgetCode, @budgetOut = @budget OUTPUT;
END