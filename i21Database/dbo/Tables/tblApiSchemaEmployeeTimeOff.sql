--All other data are typed input
CREATE TABLE tblApiSchemaEmployeeTimeOff(
     guiApiUniqueId UNIQUEIDENTIFIER NOT NULL
    ,intRowNumber INT NULL
    ,intKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY
    ,intEntityNo NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL NOT NULL                                               --Required       
    ,strTimeOffId NVARCHAR(100) COLLATE Latin1_General_CI_AS  NOT NULL      --Required        
    ,strTimeOffDesc NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL     --Required  
    ,dtmEligibleDate NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,dblRate FLOAT(50) NULL
    ,dblPerPeriod FLOAT(50) NULL
    ,strPeriod NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,dblRateFactor FLOAT(50) NULL
    ,strAwardOn NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,dblMaxEarned FLOAT(50) NULL
    ,dblMaxCarryOver FLOAT(50) NULL
    ,dblMaxBalance FLOAT(50) NULL
    ,dtmLastAwardDate NVARCHAR(100) COLLATE Latin1_General_CI_AS  NULL
    ,dblHoursCarryOver FLOAT(50) NULL
    ,dblHoursAccrued FLOAT(50) NULL
    ,dblHoursEarned FLOAT(50) NULL
    ,dblHoursUsed FLOAT(50) NULL
    ,dblAdjustments FLOAT(50) NULL
)
								