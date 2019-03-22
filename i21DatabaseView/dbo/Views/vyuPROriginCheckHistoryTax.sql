﻿--This is a Stub View for the original Integration View
CREATE VIEW [dbo].[vyuPROriginCheckHistoryTax]
AS
SELECT TOP 0
	strEmployeeNo		= CAST('' AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
	,strLastName		= CAST('' AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
	,strFirstName		= CAST('' AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
	,strMiddleName		= CAST('' AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
	,strCode			= CAST('' AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
	,strCheckNumber		= CAST('' AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
	,strCheckType		= CAST('' AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
	,strDeductionCode	= CAST('' AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
	,strType			= CAST('' AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
	,strDepartment		= CAST('' AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
	,dblAmount			= CAST(0.000000 AS NUMERIC(18, 6))
	,ysnCredit			= CAST(0 AS BIT)
	,strPaidBy			= CAST('' AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
	,strCheckLiteral	= CAST('' AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
	,dblTaxable			= CAST(0.000000 AS NUMERIC(18, 6))
	,dblTotalWages		= CAST(0.000000 AS NUMERIC(18, 6))
	,strUserId			= CAST('' AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
	,dtmUserRevision	= CAST(NULL AS DATETIME)
	,intIdentityKey		= CAST(-999 AS INT)