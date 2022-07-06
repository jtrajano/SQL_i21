CREATE TABLE [dbo].[tblSTGenerateVendorRebateHistory]
(
	[intGenerateVendorRebateHistoryId] [int] IDENTITY(1,1) NOT NULL,
	[intVendorId] [int] NOT NULL,
	[dtmBeginningDate] [datetime] NULL,
	[dtmEndingDate] [datetime] NULL,
	[strFileFormat] [nvarchar](20) COLLATE Latin1_General_CI_AS NULL,
	[strProtocol] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strHost] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strUsername] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strPassword] [nvarchar](20) COLLATE Latin1_General_CI_AS NULL,
	[intPortNo] [int] NULL,
	[ysnResubmit] [bit] NULL,
	[ysnSuccess] [bit] NULL,
	[strMessage] [nvarchar](MAX) COLLATE Latin1_General_CI_AS NULL,
	[dtmDateCreated] [datetime] NULL, 
	[intCreatedByUserId] [int] NULL
)
