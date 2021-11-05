CREATE TABLE tblApiSchemaEmployeeEarnings(
    guiApiUniqueId UNIQUEIDENTIFIER NOT NULL                                    --Required
    ,intRowNumber INT NULL
    ,intKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY                              --Required
    ,intEntityNo NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL NOT NULL                                                   --Required
    ,strEarningDesc NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,dblEarningAmount	FLOAT(50) NULL
    ,ysnEarningDefault BIT  NULL         --values should be "Y" and "N" only
    ,strPayGroup NVARCHAR(100) COLLATE Latin1_General_CI_AS  NOT NULL           --Required. values should be Holiday,BI 2,MO 2,WK 2,TE 2,Semi-Monthly,Time Entry, Weekly,Commissions,Monthly0,Bi-Weekly
    ,strCalculationType	 NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL       --Calculation Type values should be Shift Differential,Fixed Amount,Hourly Rate,Overtime,Rate Factor,Fringe Benefit,Reimbursement and Tip
    ,strLinkedEarning NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL          --values should be REG,SAL,OTV,VAC,SICK,PERSONAL,BONUS,COMM,TEST,Holiday
    ,dblAmount	FLOAT(50) NULL
    ,dblDefaultHours	FLOAT(50) NULL
    ,strAccrueTimeOff NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL          --values should be VAC (Hour),VAC (Year),Personal,SICK,VAC (YR END)
    ,strDeductTimeOff NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL          --values should be VAC (Hour),VAC (Year),Personal,SICK,VAC (YR END)
    ,strTaxCalculation NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,strAccountID NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,ysnUseGLSplit BIT  NULL             --values should be "Y" and "N" only

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

    ,ysnDefault BIT  NULL                --values should be "Y" and "N" only
)

