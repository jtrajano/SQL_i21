--This is a Stub View for the original Integration View
CREATE VIEW [dbo].[vyuPROriginEmployeeTax]
AS
SELECT TOP 0
	intYear				= CAST(0 AS INT)
	,intQuarter			= CAST(0 AS INT)
	,strEmployeeNo		= CAST('' AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
	,strLastName		= CAST('' AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
	,strFirstName		= CAST('' AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
	,strMiddleName		= CAST('' AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
	,strType			= CAST('' AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
	,strTaxCode			= CAST('' AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
	,strCheckLiteral	= CAST('' AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
	,ysnCredit			= CAST(0 AS BIT)
	,dblTaxable			= CAST(0.000000 AS NUMERIC(18, 6))
	,dblWithheld		= CAST(0.000000 AS NUMERIC(18, 6))
	,dblTotalWages		= CAST(0.000000 AS NUMERIC(18, 6))
	,strUserId			= CAST('' AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
	,dtmUserRevision	= CAST(NULL AS DATETIME)
	,intIdentityKey		= CAST(-999 AS INT)