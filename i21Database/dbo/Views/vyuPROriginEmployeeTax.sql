--This is a Stub View for the original Integration View
CREATE VIEW [dbo].[vyuPROriginEmployeeTax]
AS
SELECT TOP 0
	intYear				= CAST(0 AS INT)
	,intQuarter			= CAST(0 AS INT)
	,strEmployeeNo		= CAST('' AS NVARCHAR(200))
	,strType			= CAST('' AS NVARCHAR(200))
	,strTaxCode			= CAST('' AS NVARCHAR(200))
	,strCheckLiteral	= CAST('' AS NVARCHAR(200))
	,ysnCredit			= CAST(0 AS BIT)
	,dblTaxable			= CAST(0.000000 AS NUMERIC(18, 6))
	,dblWithheld		= CAST(0.000000 AS NUMERIC(18, 6))
	,dblTotalWages		= CAST(0.000000 AS NUMERIC(18, 6))
	,strUserId			= CAST('' AS NVARCHAR(200))
	,dtmUserRevision	= CAST(NULL AS DATETIME)