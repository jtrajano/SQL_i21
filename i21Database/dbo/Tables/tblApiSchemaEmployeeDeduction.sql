CREATE TABLE tblApiSchemaEmployeeDeduction(
     guiApiUniqueId UNIQUEIDENTIFIER NOT NULL
    ,intRowNumber INT NULL
    ,intKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY
    ,intEntityNo INT NULL
    ,strDeductionId NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,strDeductionDesc NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,dblDeductionRate FLOAT(50) NULL
    ,ysnDefault NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,strCategory NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,strPaidBy NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,dblRateCalc FLOAT(50) NULL
    ,strRateCalcType NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,dblDeductFrom FLOAT(50) NULL
    ,strDeductFromType NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,dblAnnualLimit	 FLOAT(50) NULL
    ,dtmBeginDate DATETIME NULL
    ,dtmEndDate	DATETIME NULL
    ,strAccountId NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,ysnAccountGLSplit NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,strExpenseAccountId NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,ysnExpenseGLSplit NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,strDeductionTaxId1	NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,strDeductionTaxDesc1 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,strDeductionTaxId2 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,strDeductionTaxDesc2 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,strDeductionTaxId3 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,strDeductionTaxDesc3 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,strDeductionTaxId4 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,strDeductionTaxDesc4 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,strDeductionTaxId5 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,strDeductionTaxDesc5 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,strDeductionTaxId6 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,strDeductionTaxDesc6 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,strDeductionTaxId7 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,strDeductionTaxDesc7 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
)