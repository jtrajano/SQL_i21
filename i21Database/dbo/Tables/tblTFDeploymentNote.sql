CREATE TABLE [dbo].[tblTFDeploymentNote](
	[intDeploymentNoteId] [int] IDENTITY(1,1) NOT NULL,
	[strMessage] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strSourceTable] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intRecordId] [nvarchar](30) COLLATE Latin1_General_CI_AS NOT NULL,
	[strKeyId] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intTaxAuthorityId] [int] NULL,
	[strReleaseNumber] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[dtmDateReleaseInstalled] [datetime] NOT NULL,
	[intConcurrencyId] [int] NULL,
 CONSTRAINT [PK_tblTFDeploymentNote] PRIMARY KEY CLUSTERED 
(
	[intDeploymentNoteId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[tblTFDeploymentNote] ADD  CONSTRAINT [DF_tblTFDeploymentNote_intConcurrencyId]  DEFAULT ((1)) FOR [intConcurrencyId]
GO
