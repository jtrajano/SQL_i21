CREATE TABLE [dbo].[tblGRStorageStatement]
(
	[intStorageStatementId] INT NOT NULL  IDENTITY,
    [strFormNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[dtmIssueDate] DATE NULL,
	[strLicenceNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strItemNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intCustomerStorageId] INT NULL,
	[dtmDeliveryDate] DATETIME NULL,
	[strGrade] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strDryingItem] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[dblGradeReading] DECIMAL(24, 10) NULL,
	[dblDryTonnes] DECIMAL(24, 10) NULL,
	[strStorageType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[dblCharges] DECIMAL(24, 10) NULL,
	[dtmTerminationOfReceipt] DATETIME NULL,	
    CONSTRAINT [PK_tblGRStorageStatement_intStorageStatementId] PRIMARY KEY ([intStorageStatementId])
)
