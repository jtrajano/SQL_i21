CREATE TABLE [dbo].[tblHDTicketForImport]
(
	[intTicketForImportId] [int] IDENTITY(1,1) NOT NULL,
	[strSubject] [nvarchar](MAX) COLLATE Latin1_General_CI_AS NOT NULL,
	[strCustomerNumber] [nvarchar](15) COLLATE Latin1_General_CI_AS NULL,
	[strProduct] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strVersion] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strModule] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] [nvarchar](MAX) COLLATE Latin1_General_CI_AS NOT NULL,
	[strResolution] [nvarchar](MAX) COLLATE Latin1_General_CI_AS NOT NULL,
	[strComments] [nvarchar](MAX) COLLATE Latin1_General_CI_AS NOT NULL,
	[strPriority] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strType] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strStatus] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[dtmCreated] [datetime] NOT NULL default getdate(),
	[ysnImported] BIT NOT NULL DEFAULT convert(bit,0), 
    CONSTRAINT [PK_tblHDTicketForImport_intTicketForImportId] PRIMARY KEY CLUSTERED ([intTicketForImportId] ASC)
)

/*
	,@Subject nvarchar(100)
	,@CustomerNumber nvarchar(100)
	,@Product nvarchar(100)
	,@Version nvarchar(100)
	,@Module nvarchar(100)
	,@Description nvarchar(max) = null
	,@Resolution nvarchar(max) = null
	,@Comments nvarchar(max) = null
	,@Priority nvarchar(100) = null
	,@Type nvarchar(100) = null
	,@Status nvarchar(100) = null
*/