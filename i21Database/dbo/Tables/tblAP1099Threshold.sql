﻿CREATE TABLE [dbo].[tblAP1099Threshold]
(
	[int1099ThresholdId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [dbl1099INT] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
    [dbl1099B] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
    [dbl1099MISCRent] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dbl1099MISCRoyalties] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
    [dbl1099MISCOtherIncome] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
    [dbl1099MISCFederalIncome] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
    [dbl1099MISCFishing] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
    [dbl1099MISCMedical] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dbl1099MISCNonemployee] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
    [dbl1099MISCSubstitute] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
    [dbl1099MISCDirecSales] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
    [dbl1099MISCCrop] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
    [dbl1099MISCExcessGolden] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
    [dbl1099MISCGrossProceeds] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[strContactName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strContactPhone] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strContactEmail] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT NOT NULL DEFAULT 0
)
