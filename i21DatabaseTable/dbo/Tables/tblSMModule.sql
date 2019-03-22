CREATE TABLE [dbo].[tblSMModule]
(
	[intModuleId]			INT												NOT NULL	PRIMARY KEY IDENTITY, 
    [strApplicationName]	NVARCHAR(30)	COLLATE Latin1_General_CI_AS	NOT NULL, 
    [strModule]				NVARCHAR(30)	COLLATE Latin1_General_CI_AS	NOT NULL, 
	[strAppCode]			NVARCHAR(5)		COLLATE Latin1_General_CI_AS	NOT NULL	DEFAULT '', 
	[ysnSupported]			BIT												NOT NULL	DEFAULT 1, 
	[ysnCustomerModule]		BIT												NOT NULL	DEFAULT 0, 
	[intSort]				INT												NOT NULL,
    [strVersionStart]		NVARCHAR(50)	COLLATE Latin1_General_CI_AS	NOT NULL	DEFAULT '', 
    [strVersionEnd]			NVARCHAR(50)	COLLATE Latin1_General_CI_AS	NOT NULL	DEFAULT '', 
	[strPrefix]				NVARCHAR(30)	COLLATE Latin1_General_CI_AS	NOT NULL	DEFAULT '',
    [intConcurrencyId]		INT												NOT NULL	DEFAULT 1, 
    CONSTRAINT [AK_tblSMModule_strApplicationName_strModule] UNIQUE ([strApplicationName], [strModule])
)
