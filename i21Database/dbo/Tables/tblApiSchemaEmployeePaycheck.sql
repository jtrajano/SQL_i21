CREATE TABLE tblApiSchemaEmployeePaycheck(
     guiApiUniqueId UNIQUEIDENTIFIER NOT NULL							--Required
    ,intRowNumber INT													--Required
    ,intKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY						--Required
	,intOriginalPaycheckId INT
	,strPaycheckEarningId NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL 
	,strEntityNo NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL 
	,strRecordType NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL	--Required VALUES should be "PAYCHECK, TAX, DEDUCTION, EARNING" only
	,strRecordId NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL	--Required		
	,dblEarningHour FLOAT(50) NULL
	,dblAmount FLOAT(50) NULL
	,dblTotal FLOAT(50) NULL
	,dtmPayDate NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
	,dtmPayFrom NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
	,dtmPayTo NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
	,strAccountId NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
	,strExpenseAccountId NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
	,strBankAccountNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
	,strReferenceNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
)