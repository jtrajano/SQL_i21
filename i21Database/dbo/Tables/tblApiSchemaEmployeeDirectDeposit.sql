CREATE TABLE tblApiSchemaEmployeeDirectDeposit(
    guiApiUniqueId UNIQUEIDENTIFIER NOT NULL
    ,intRowNumber INT NULL
    ,intKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY
    ,intEntityNo NVARCHAR(100) NOT NULL                                               --Required
    ,strBankName NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,strAccountNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,strAccountType NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL        --Values are Checking and Savings only
    ,strClassification NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL     --Values are Personal and Corporate only
    ,dtmEffectiveDate	NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL	
    ,ysnPreNoteSent BIT  NULL        --values should be "Y" and "N" only
    ,strDistributionType NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL	--Values are Fixed Amount,Percent and Remainder only
    ,dblAmount	FLOAT(50) NULL
    ,intOrder	INT NULL
    ,ysnActive	BIT  NULL	        --values should be "Y" and "N" only
    
)