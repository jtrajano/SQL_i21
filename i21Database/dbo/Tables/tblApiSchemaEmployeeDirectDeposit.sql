CREATE TABLE tblApiSchemaEmployeeDirectDeposit(
    guiApiUniqueId UNIQUEIDENTIFIER NOT NULL
    ,intRowNumber INT NULL
    ,intKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY
    ,intEntityNo INT NOT NULL
    ,strBankName NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,strAccountNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,strAccountType NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,strClassification NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,dtmEffectiveDate	NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL	
    ,ysnPreNoteSent NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,strDistributionType NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL	
    ,dblAmount	FLOAT(50) NULL
    ,intOrder	INT NULL
    ,ysnActive	NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL	
    
)