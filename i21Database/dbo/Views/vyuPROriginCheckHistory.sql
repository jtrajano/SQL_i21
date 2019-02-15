﻿--This is a Stub View for the original Integration View
CREATE VIEW [dbo].[vyuPROriginCheckHistory]
AS
SELECT TOP 0
	strCode				= CAST('' AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
	,strCheckNumber		= CAST('' AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
	,strCheckType		= CAST('' AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
	,strEmployeeNo		= CAST('' AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
	,strLastName		= CAST('' AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
	,strFirstName		= CAST('' AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
	,strMiddleName		= CAST('' AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
	,dtmCheckDate		= CAST(NULL AS DATETIME)
	,intQuarter			= CAST(0 AS INT)
	,dtmPeriodDate		= CAST(NULL AS DATETIME)
	,strBankCode		= CAST('' AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
	,strAccountNo		= CAST('' AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
	,dblGrossPay		= CAST(0.000000 AS NUMERIC(18, 6))
	,dblDeductions		= CAST(0.000000 AS NUMERIC(18, 6))
	,dblTaxes			= CAST(0.000000 AS NUMERIC(18, 6))
	,dblNetPay			= CAST(0.000000 AS NUMERIC(18, 6))
	,dblFedTaxable		= CAST(0.000000 AS NUMERIC(18, 6))
	,dblSSWage			= CAST(0.000000 AS NUMERIC(18, 6))
	,dblMedicareWage	= CAST(0.000000 AS NUMERIC(18, 6))
	,dblFUITaxable		= CAST(0.000000 AS NUMERIC(18, 6))
	,dblSUITaxable		= CAST(0.000000 AS NUMERIC(18, 6))
	,dblStateTaxable	= CAST(0.000000 AS NUMERIC(18, 6))
	,dblCityTaxable		= CAST(0.000000 AS NUMERIC(18, 6))
	,dblCountyTaxable	= CAST(0.000000 AS NUMERIC(18, 6))
	,dblSchoolTaxable	= CAST(0.000000 AS NUMERIC(18, 6))
	,strDepartment		= CAST(0.000000 AS NUMERIC(18, 6))
	,ysnPrenoteSent		= CAST(0 AS BIT) 
	,strUserId			= CAST('' AS NVARCHAR(200)) COLLATE Latin1_General_CI_AS 
	,dtmUserRevision	= CAST(NULL AS DATETIME)
	,intIdentityKey		= CAST(-999 AS INT)