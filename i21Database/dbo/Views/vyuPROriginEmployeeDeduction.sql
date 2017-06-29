--This is a Stub View for the original Integration View
CREATE VIEW [dbo].[vyuPROriginEmployeeDeduction]
AS
SELECT TOP 0
	intYear				= CAST(0 AS INT)
	,intQuarter			= CAST(0 AS INT)
	,strEmployeeNo		= CAST('' AS NVARCHAR(200))
	,strDeductionCode	= CAST('' AS NVARCHAR(200))
	,strType			= CAST('' AS NVARCHAR(200))
	,strCheckLiteral	= CAST('' AS NVARCHAR(200))
	,dtmLastCheckDate	= CAST(NULL AS DATETIME)
	,dblAmountYTD		= CAST(0.000000 AS NUMERIC(18, 6))
	,dblTaxableToDate	= CAST(0.000000 AS NUMERIC(18, 6))
	,strUserId			= CAST('' AS NVARCHAR(200))
	,dtmUserRevision	= CAST(NULL AS DATETIME)