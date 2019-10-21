CREATE TABLE [dbo].[tblCFDriverPinStaging](
	[intDriverPinStagingId] [int] IDENTITY(1,1)  NOT NULL,
	[strAccountNumber] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strDriverPinNumber] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strDriverDescription] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strComment] NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL,
    [ysnActive] BIT NULL, 
	[strGUID] NVARCHAR(50) NULL, 
    [intEntityId] INT NULL, 
    [intRecordNo] INT NULL, 
	[intConcurrencyId] INT CONSTRAINT [DF_tblCFDriverPinStaging_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFDriverPinStaging] PRIMARY KEY CLUSTERED (intDriverPinStagingId ASC),
 );
GO

