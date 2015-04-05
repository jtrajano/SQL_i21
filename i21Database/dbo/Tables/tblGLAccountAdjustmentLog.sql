CREATE TABLE [dbo].[tblGLAccountAdjustmentLog]
(
	[intAccountAdjustmentId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intPrimaryKey] INT NULL, 
    [strTable] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strColumn] NCHAR(20)  COLLATE Latin1_General_CI_AS NULL, 
    [strAction] NCHAR(10) COLLATE Latin1_General_CI_AS  NULL, 
    [dtmAction] DATETIME NULL, 
    [strOriginalValue] NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL, 
    [strNewValue] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intEntityId] INT NULL, 
    [intConcurrencyId] INT NULL, 
    [strName] NVARCHAR(50) NULL
    
)
