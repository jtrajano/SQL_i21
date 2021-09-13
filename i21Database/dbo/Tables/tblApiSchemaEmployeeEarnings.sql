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

    ,strTaxID1 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,strTaxDescription1	NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL

    ,strTaxID2 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,strTaxDescription2	NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL

    ,strTaxID3 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,strTaxDescription3	NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL

    ,strTaxID4 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,strTaxDescription4	NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL

    ,strTaxID5 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,strTaxDescription5	NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL

    ,strTaxID6 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,strTaxDescription6	NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL

    ,ysnDefault NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
)

