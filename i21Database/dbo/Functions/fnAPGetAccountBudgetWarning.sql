CREATE FUNCTION [dbo].[fnAPGetAccountBudgetWarning]
(
	@dtmDate DATETIME,
	@strAccountId NVARCHAR(40),
	@dblTotal DECIMAL(18, 6)
)
RETURNS NVARCHAR(255)
AS
BEGIN
	DECLARE @warningMessage NVARCHAR(255) = '';

	DECLARE @fiscalYearId INT
	DECLARE @startDate DATETIME
	DECLARE @endDate DATETIME
	SELECT @fiscalYearId = intFiscalYearId, @startDate = dtmStartDate, @endDate = dtmEndDate
	FROM tblGLFiscalYearPeriod
	WHERE @dtmDate BETWEEN dtmStartDate AND dtmEndDate

	DECLARE @budgetCode INT
	SELECT TOP 1 @budgetCode = intBudgetCode FROM tblAPCompanyPreference

	DECLARE @budgetFirstYearId INT
	SELECT @budgetFirstYearId = intFiscalYearId FROM tblFRBudgetCode WHERE intBudgetCode = @budgetCode

	IF @fiscalYearId = @budgetFirstYearId
	BEGIN
		DECLARE @month INT
		SELECT @month = MONTH(@dtmDate)

		DECLARE @balance DECIMAL(18, 6)
		SELECT @balance = beginBalance FROM fnGLGetBeginningBalanceAndUnitTB(@strAccountId, @dtmDate, -1)
		SET @balance = @balance + @dblTotal
		
		DECLARE @budget DECIMAL(18, 6)

		IF @month = 1
		BEGIN
			SELECT @budget = B.dblBudget1
			FROM tblFRBudget B
			INNER JOIN vyuGLAccountDetail AD ON AD.intAccountId = B.intAccountId
			WHERE B.intBudgetCode = @budgetCode AND AD.strAccountId = @strAccountId

			IF @balance > @budget
			BEGIN
				SET @warningMessage =  'Account No. ' + @strAccountId + ' will exceed the budget of January.';
			END
		END
		
		IF @month = 2
		BEGIN
			SELECT @budget = (B.dblBudget1 + B.dblBudget2)
			FROM tblFRBudget B
			INNER JOIN vyuGLAccountDetail AD ON AD.intAccountId = B.intAccountId
			WHERE B.intBudgetCode = @budgetCode AND AD.strAccountId = @strAccountId

			IF @balance > @budget
			BEGIN
				SET @warningMessage =  'Account No. ' + @strAccountId + ' will exceed the budget of February.';
			END
		END
		
		IF @month = 3
		BEGIN
			SELECT @budget = (B.dblBudget1 + B.dblBudget2 + B.dblBudget3)
			FROM tblFRBudget B
			INNER JOIN vyuGLAccountDetail AD ON AD.intAccountId = B.intAccountId
			WHERE B.intBudgetCode = @budgetCode AND AD.strAccountId = @strAccountId

			IF @balance > @budget
			BEGIN
				SET @warningMessage =  'Account No. ' + @strAccountId + ' will exceed the budget of March.';
			END
		END
		
		IF @month = 4
		BEGIN
			SELECT @budget = (B.dblBudget1 + B.dblBudget2 + B.dblBudget3 + B.dblBudget4)
			FROM tblFRBudget B
			INNER JOIN vyuGLAccountDetail AD ON AD.intAccountId = B.intAccountId
			WHERE B.intBudgetCode = @budgetCode AND AD.strAccountId = @strAccountId

			IF @balance > @budget
			BEGIN
				SET @warningMessage =  'Account No. ' + @strAccountId + ' will exceed the budget of April.';
			END
		END
		
		IF @month = 5
		BEGIN
			SELECT @budget = (B.dblBudget1 + B.dblBudget2 + B.dblBudget3 + B.dblBudget4 + B.dblBudget5)
			FROM tblFRBudget B
			INNER JOIN vyuGLAccountDetail AD ON AD.intAccountId = B.intAccountId
			WHERE B.intBudgetCode = @budgetCode AND AD.strAccountId = @strAccountId

			IF @balance > @budget
			BEGIN
				SET @warningMessage =  'Account No. ' + @strAccountId + ' will exceed the budget of May.';
			END
		END
		
		IF @month = 6
		BEGIN
			SELECT @budget = (B.dblBudget1 + B.dblBudget2 + B.dblBudget3 + B.dblBudget4 + B.dblBudget5 + B.dblBudget6)
			FROM tblFRBudget B
			INNER JOIN vyuGLAccountDetail AD ON AD.intAccountId = B.intAccountId
			WHERE B.intBudgetCode = @budgetCode AND AD.strAccountId = @strAccountId

			IF @balance > @budget
			BEGIN
				SET @warningMessage =  'Account No. ' + @strAccountId + ' will exceed the budget of June.';
			END
		END
		
		IF @month = 7
		BEGIN
			SELECT @budget = (B.dblBudget1 + B.dblBudget2 + B.dblBudget3 + B.dblBudget4 + B.dblBudget5 + B.dblBudget6 + B.dblBudget7)
			FROM tblFRBudget B
			INNER JOIN vyuGLAccountDetail AD ON AD.intAccountId = B.intAccountId
			WHERE B.intBudgetCode = @budgetCode AND AD.strAccountId = @strAccountId

			IF @balance > @budget
			BEGIN
				SET @warningMessage =  'Account No. ' + @strAccountId + ' will exceed the budget of July.';
			END
		END
		
		IF @month = 8
		BEGIN
			SELECT @budget = (B.dblBudget1 + B.dblBudget2 + B.dblBudget3 + B.dblBudget4 + B.dblBudget5 + B.dblBudget6 + B.dblBudget7 + B.dblBudget8)
			FROM tblFRBudget B
			INNER JOIN vyuGLAccountDetail AD ON AD.intAccountId = B.intAccountId
			WHERE B.intBudgetCode = @budgetCode AND AD.strAccountId = @strAccountId

			IF @balance > @budget
			BEGIN
				SET @warningMessage =  'Account No. ' + @strAccountId + ' will exceed the budget of August.';
			END
		END
		
		IF @month = 9
		BEGIN
			SELECT @budget = (B.dblBudget1 + B.dblBudget2 + B.dblBudget3 + B.dblBudget4 + B.dblBudget5 + B.dblBudget6 + B.dblBudget7 + B.dblBudget8 + B.dblBudget9)
			FROM tblFRBudget B
			INNER JOIN vyuGLAccountDetail AD ON AD.intAccountId = B.intAccountId
			WHERE B.intBudgetCode = @budgetCode AND AD.strAccountId = @strAccountId

			IF @balance > @budget
			BEGIN
				SET @warningMessage =  'Account No. ' + @strAccountId + ' will exceed the budget of September.';
			END
		END
		
		IF @month = 10
		BEGIN
			SELECT @budget = (B.dblBudget1 + B.dblBudget2 + B.dblBudget3 + B.dblBudget4 + B.dblBudget5 + B.dblBudget6 + B.dblBudget7 + B.dblBudget8 + B.dblBudget9 + B.dblBudget10)
			FROM tblFRBudget B
			INNER JOIN vyuGLAccountDetail AD ON AD.intAccountId = B.intAccountId
			WHERE B.intBudgetCode = @budgetCode AND AD.strAccountId = @strAccountId

			IF @balance > @budget
			BEGIN
				SET @warningMessage =  'Account No. ' + @strAccountId + ' will exceed the budget of October.';
			END
		END
		
		IF @month = 11
		BEGIN
			SELECT @budget = (B.dblBudget1 + B.dblBudget2 + B.dblBudget3 + B.dblBudget4 + B.dblBudget5 + B.dblBudget6 + B.dblBudget7 + B.dblBudget8 + B.dblBudget9 + B.dblBudget10 + B.dblBudget11)
			FROM tblFRBudget B
			INNER JOIN vyuGLAccountDetail AD ON AD.intAccountId = B.intAccountId
			WHERE B.intBudgetCode = @budgetCode AND AD.strAccountId = @strAccountId

			IF @balance > @budget
			BEGIN
				SET @warningMessage =  'Account No. ' + @strAccountId + ' will exceed the budget of November.';
			END
		END
		
		IF @month = 12
		BEGIN
			SELECT @budget = (B.dblBudget1 + B.dblBudget2 + B.dblBudget3 + B.dblBudget4 + B.dblBudget5 + B.dblBudget6 + B.dblBudget7 + B.dblBudget8 + B.dblBudget9 + B.dblBudget10 + B.dblBudget11 + B.dblBudget12)
			FROM tblFRBudget B
			INNER JOIN vyuGLAccountDetail AD ON AD.intAccountId = B.intAccountId
			WHERE B.intBudgetCode = @budgetCode AND AD.strAccountId = @strAccountId

			IF @balance > @budget
			BEGIN
				SET @warningMessage =  'Account No. ' + @strAccountId + ' will exceed the budget of December.';
			END
		END
	END

	RETURN @warningMessage;
END