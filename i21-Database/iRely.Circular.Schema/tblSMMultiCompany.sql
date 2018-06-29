CREATE TABLE [dbo].[tblSMMultiCompany]
(
	[intMultiCompanyId]			INT NOT NULL PRIMARY KEY IDENTITY, 
    [strCompanyName]			NVARCHAR (150)	COLLATE Latin1_General_CI_AS NULL,
	[strCompanyCode]			NVARCHAR (10)	COLLATE Latin1_General_CI_AS NULL,
	[strDatabaseName]			NVARCHAR (50)	COLLATE Latin1_General_CI_AS NULL,
	[strServer]					NVARCHAR (50)	COLLATE Latin1_General_CI_AS NULL,
	[strAuthentication]			NVARCHAR (30)	COLLATE Latin1_General_CI_AS NULL, 
	[strUserName]				NVARCHAR (30)	COLLATE Latin1_General_CI_AS NULL, 
	[strPassword]				NVARCHAR (30)	COLLATE Latin1_General_CI_AS NULL, 
	[strType]					NVARCHAR (20)	COLLATE Latin1_General_CI_AS NULL, 
	[intMultiCompanyParentId]	INT NULL,
	[intRange]				    INT NULL	 DEFAULT 0,
	[ysnStatus]					BIT NULL     DEFAULT 0,
	[ysnInit]					BIT NULL     DEFAULT 0,
    [intConcurrencyId]			INT NOT NULL DEFAULT 1
   
)
