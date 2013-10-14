
GO
/****** Object:  UserDefinedFunction [dbo].[fn_getBeginBalanceUnit]    Script Date: 09/03/2013 08:56:00 ******/
IF OBJECT_ID(N'dbo.fn_getBeginBalanceUnit', N'FN') IS NOT NULL
BEGIN
	DROP FUNCTION fn_getBeginBalanceUnit
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_getBeginBalanceUnit](@strAccountID nvarchar(50),@dtmDate datetime)
RETURNS decimal(18,6)
AS
BEGIN

	DECLARE @beginBalanceUnit decimal(18,6)
	SELECT @beginBalanceUnit = SUM( 
				CASE	WHEN B.strAccountType in ('Asset', 'Expense','Cost of Goods Sold') THEN dblDebit - dblCredit
						ELSE dblCredit - dblDebit
				END)  
		
	FROM tblGLAccount A
		LEFT JOIN tblGLAccountGroup B ON A.intAccountGroupID = B.intAccountGroupID
		LEFT JOIN tblGLDetail C ON A.intAccountID = C.intAccountID
	WHERE strAccountID = @strAccountID and dtmDate < @dtmDate 
	GROUP BY strAccountID

	RETURN @beginBalanceUnit
END
GO

/****** Object:  UserDefinedFunction [dbo].[fn_getBeginBalance]    Script Date: 09/03/2013 08:56:00 ******/
IF OBJECT_ID(N'dbo.fn_getBeginBalance', N'FN') IS NOT NULL
BEGIN
	DROP FUNCTION fn_getBeginBalance
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_getBeginBalance](@strAccountID nvarchar(50),@dtmDate datetime)
RETURNS decimal(18,6)
AS
BEGIN

	DECLARE @beginBalance decimal (18,6)
	SELECT @beginBalance = SUM( 
				CASE	WHEN B.strAccountType in ('Asset', 'Expense','Cost of Goods Sold') THEN dblDebit - dblCredit
						ELSE dblCredit - dblDebit
				END)  
		
	FROM tblGLAccount A
		LEFT JOIN tblGLAccountGroup B ON A.intAccountGroupID = B.intAccountGroupID
		LEFT JOIN tblGLDetail C ON A.intAccountID = C.intAccountID
	WHERE strAccountID = @strAccountID and dtmDate < @dtmDate 
	GROUP BY strAccountID

	RETURN @beginBalance
END
GO
