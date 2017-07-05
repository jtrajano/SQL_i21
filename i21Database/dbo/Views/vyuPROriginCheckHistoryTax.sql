--This is a Stub View for the original Integration View
CREATE VIEW [dbo].[vyuPROriginCheckHistoryTax]
AS
SELECT TOP 0
	strEmployeeNo		= CAST('' AS NVARCHAR(200))
	,strCode			= CAST('' AS NVARCHAR(200))
	,strCheckNumber		= CAST('' AS NVARCHAR(200))
	,strCheckType		= CAST('' AS NVARCHAR(200))
	,strDeductionCode	= CAST('' AS NVARCHAR(200))
	,strType			= CAST('' AS NVARCHAR(200))
	,strDepartment		= CAST('' AS NVARCHAR(200))
	,dblAmount			= CAST(0.000000 AS NUMERIC(18, 6))
	,ysnCredit			= CAST(0 AS BIT)
	,strPaidBy			= CAST('' AS NVARCHAR(200))
	,strCheckLiteral	= CAST('' AS NVARCHAR(200))
	,dblTaxable			= CAST(0.000000 AS NUMERIC(18, 6))
	,dblTotalWages		= CAST(0.000000 AS NUMERIC(18, 6))
	,strUserId			= CAST('' AS NVARCHAR(200))
	,dtmUserRevision	= CAST(NULL AS DATETIME)
	,intIdentityKey		= CAST(-999 AS INT)