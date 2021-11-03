CREATE TABLE tblApiSchemaEmployeeDeduction(
     guiApiUniqueId UNIQUEIDENTIFIER NOT NULL
    ,intRowNumber INT NULL
    ,intKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY
    ,intEntityNo NVARCHAR(100) NOT NULL                                                   --Required
    ,strDeductionId NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,strDeductionDesc NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,dblDeductionRate FLOAT(50) NULL
    ,ysnDefault BIT  NULL                --Values should be "Y" and "N" only
    ,strCategory NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,strPaidBy NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,dblRateCalc FLOAT(50) NULL
    ,strRateCalcType NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL           --Values should be "Fixed Amount", "Percent", "Hourly Amount" and "Hourly Percent" only
    ,dblDeductFrom FLOAT(50) NULL
    ,strDeductFromType NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL         --Values should be "Net Pay" and "Gross Pay" only
    ,dblAnnualLimit	 FLOAT(50) NULL
    ,dtmBeginDate DATETIME NULL
    ,dtmEndDate	DATETIME NULL
    ,strAccountId NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,ysnAccountGLSplit BIT  NULL         --Values should be "Y" and "N" only
    ,strExpenseAccountId NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,ysnExpenseGLSplit BIT  NULL         --Values should be "Y" and "N" only
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