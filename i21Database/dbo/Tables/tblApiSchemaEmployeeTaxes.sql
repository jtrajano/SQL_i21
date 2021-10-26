CREATE TABLE tblApiSchemaEmployeeTaxes(
    guiApiUniqueId UNIQUEIDENTIFIER NOT NULL,
    intRowNumber INT NULL,
    intKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    intEntityNo INT NOT NULL,                                                   --Required. Employee Entity ID
    strTaxId NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
    strTaxDescription NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,         --Description of the Tax
    strCalculationType NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
    strPaidBy NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
    ysnDefault BIT  NULL,                --Default Values should be "Y" and "N" only
    strFilingStatus NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,           --Default Values should be Single and Married
    strState NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,                  --Default Values should be state names only
    strCountry NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
    dblAmount FLOAT(50) NULL,
    dblExtraWithholding FLOAT(50) NULL,
    dblLimit FLOAT(50) NULL,
    dblFederalAllowance FLOAT(50) NULL,
    strSupplimentalCalc NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,       --Default Values should be Flat Rate and Normal Rate Only
    strLiabilityAccount NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,
    ysnLiabilityGlSplit BIT  NULL,       --Default Values should be "Y" and "N" only
    strExpenseAccount NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL,         --Default Values should be "Y" and "N" only
    ysnExpenseAccountGlSplit BIT NULL,  --Default Values should be "Y" and "N" only
    ysn2020W4 BIT NULL,                 --Default Values should be "Y" and "N" only
    ysnStep2c BIT NULL,                 --Default Values should be "Y" and "N" only
    dblClaimDependents FLOAT(50) NULL,
    dblotherIncome FLOAT(50) NULL,
    ysnResident BIT NULL,               --Default Values should be "Y" and "N" only
    intDependents INT NULL,
    dblPercentGross FLOAT(50) NULL,
    strAccountId NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL, 
)