  CREATE TABLE  tblSMInterCompany
  (
	[intInterCompanyId] INT IDENTITY(1,1),
	[strCompanyName] nvarchar(max),
	[strServerName] nvarchar(max),
	[strDatabaseName] nvarchar(max),
	[strUserName] nvarchar(max),
	[strPassword] nvarchar(max),
	[ysnIsPasswordEncrypted] BIT DEFAULT 0 NOT NULL,
	[intConcurrencyId] int default(0),
	constraint [PK_dbo.tblSMInterCompany] PRIMARY KEY CLUSTERED ([intInterCompanyId] ASC)
  )