CREATE TABLE [dbo].[tblCMMacReportXRef](
	[Type] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[Description_Contains] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[AccountNumber] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[Reference] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[CR_DR_Equals] [nvarchar](20) COLLATE Latin1_General_CI_AS NOT NULL,
	[GL_Primary] [nvarchar](20) COLLATE Latin1_General_CI_AS NOT NULL,
	[Bank_Acct] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[X_Ref_Field] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[X_Ref_Position] [int] NOT NULL,
	[X_Ref_Length] [tinyint] NOT NULL,
	[ReferenceNot] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO