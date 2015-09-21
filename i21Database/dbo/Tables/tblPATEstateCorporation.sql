CREATE TABLE [dbo].[tblPATEstateCorporation]
(
	[intCorporateCustomerId] INT NOT NULL , 
    [intRefundType] INT NOT NULL, 
    [strCorporateCustomerId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [dblOwnerPercentage] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
    [dtmPaidDate] DATETIME NULL, 
    [dblPaidAmount] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
    [strPaidCheckNo] CHAR(8) COLLATE Latin1_General_CI_AS  NULL, 
    [dtmBirthDate] DATETIME NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1, 
    PRIMARY KEY ([intCorporateCustomerId], [intRefundType])
)
