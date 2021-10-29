CREATE TABLE tblApiSchemaEmployeeEarnings(
    guiApiUniqueId UNIQUEIDENTIFIER NOT NULL
    ,intRowNumber INT NULL
    ,intKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY
    ,intEntityNo INT NOT NULL
    ,strEarningDesc NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,dblEarningAmount	FLOAT(50) NULL
    ,ysnEarningDefault NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,strPayGroup NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,strCalculationType	 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,strLinkedEarning NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,dblAmount	FLOAT(50) NULL
    ,dblDefaultHours	FLOAT(50) NULL
    ,strAccrueTimeOff NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,strDeductTimeOff NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,strTaxCalculation NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,strAccountID NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,ysnUseGLSplit NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,strTaxID NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,strTaxDescription	NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,strTaxType	NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,strTaxPaidBy NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,ysnDefault NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
)

