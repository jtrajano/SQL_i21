CREATE TABLE [dbo].[tblCTMTMPoint]
(
	[intMTMPointId] [int] IDENTITY(1,1) NOT NULL,
	[strMTMPoint] NVARCHAR(150) COLLATE Latin1_General_CI_AS,
	[strDescription] NVARCHAR(150) COLLATE Latin1_General_CI_AS,
	[ysnActive] BIT NOT NULL default 1,
	[dtmCreatedDate] datetime not NULL,
	[dtmLastUpdatedDate] datetime NULL,
	[intCreatedById] int NOT null,
	[intUpdatedById] int null,
	[intConcurrencyId] INT NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblCTMTMPoint_intMTMPointId] PRIMARY KEY CLUSTERED ([intMTMPointId] ASC),
	CONSTRAINT [UK_tblCTMTMPoint_strMTMPoint] UNIQUE ([strMTMPoint])
)