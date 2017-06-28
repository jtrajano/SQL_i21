﻿--This is a Stub View for the original Integration View
CREATE VIEW [dbo].[vyuPROriginEmployee]
AS
SELECT TOP 0
	strEmployeeNo			= CAST('' AS NVARCHAR(100))
	,strLastName			= CAST('' AS NVARCHAR(100))
	,strFirstName			= CAST('' AS NVARCHAR(100))
	,strMiddleName			= CAST('' AS NVARCHAR(100))
	,strAddress				= CAST('' AS NVARCHAR(100))
	,strAddress2			= CAST('' AS NVARCHAR(100))
	,strCity				= CAST('' AS NVARCHAR(100))
	,strState				= CAST('' AS NVARCHAR(100))
	,strZip					= CAST('' AS NVARCHAR(100))
	,strWorkState			= CAST('' AS NVARCHAR(100))
	,strSSN					= CAST('' AS NVARCHAR(100))
	,strPhone				= CAST('' AS NVARCHAR(100))
	,dblPayRate				= CAST(0.000000 AS NUMERIC(18, 6))
	,strDepartment			= CAST('' AS NVARCHAR(100))
	,strEmploymentType		= CAST('' AS NVARCHAR(100))
	,strStatus				= CAST('' AS NVARCHAR(100))
	,strPayType				= CAST('' AS NVARCHAR(100))
	,strPayCycle			= CAST('' AS NVARCHAR(100))
	,dtmLastCheckDate		= CAST(NULL AS DATETIME)
	,dblStandardHours		= CAST(0.000000 AS NUMERIC(18, 6))
	,ysnVacAwardCalculated	= CAST(0 AS BIT)
	,strVacAwardAnnivOrYtd	= CAST('' AS NVARCHAR(100))
	,strVacMethod			= CAST('' AS NVARCHAR(100))
	,dblAccrual				= CAST(0.000000 AS NUMERIC(18, 6))
	,dblCurrentAccrual		= CAST(0.000000 AS NUMERIC(18, 6))
	,dtmVacationEligDate	= CAST(NULL AS DATETIME)
	,ysnVacAwarded			= CAST(0 AS BIT)
	,dtmVacationAwardDate	= CAST(NULL AS DATETIME)
	,dblVacationCarried		= CAST(0.000000 AS NUMERIC(18, 6))
	,dblVacationEarned		= CAST(0.000000 AS NUMERIC(18, 6))
	,dblVacHrsPd			= CAST(0.000000 AS NUMERIC(18, 6))
	,strSicAwardAnnivorYtd	= CAST('' AS NVARCHAR(100))
	,ysnSicAwardCalculated	= CAST(0 AS BIT)
	,strJobTitle			= CAST('' AS NVARCHAR(100))
	,strEEOC				= CAST('' AS NVARCHAR(100))
	,strEthnicity			= CAST('' AS NVARCHAR(100))
	,strGender				= CAST('' AS NVARCHAR(100))
	,strMaritalStatus		= CAST('' AS NVARCHAR(100))
	,dtmBirthDate			= CAST(NULL AS DATETIME)
	,dtmTermDate			= CAST(NULL AS DATETIME)
	,strTermCode			= CAST('' AS NVARCHAR(100))
	,dtmOriginalHireDate	= CAST(NULL AS DATETIME)
	,dtmLastHireDate		= CAST(NULL AS DATETIME)
	,dtmReviewDate			= CAST(NULL AS DATETIME)
	,dtmNextReviewDate		= CAST(NULL AS DATETIME)
	,dtmInsuranceDate		= CAST(NULL AS DATETIME)