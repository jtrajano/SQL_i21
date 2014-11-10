CREATE TABLE [dbo].[tblNRNoteDescription]
(	
	[intDescriptionId] [int] IDENTITY(1,1) NOT NULL,
	[strDescriptionName] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescriptionComment] [nvarchar](255) COLLATE Latin1_General_CI_AS NULL,
	[intCreatedUserId] [int] NULL,
	[dtmCreated] [datetime] NULL,
	[intLastModifiedUserId] [int] NULL,
	[dtmLastModified] [datetime] NULL,
	[intConcurrencyId] [int] NOT NULL,
 CONSTRAINT [PK_tblNRNoteDescription_intDescriptionId] PRIMARY KEY CLUSTERED 
(
	[intDescriptionId] ASC
) ON [PRIMARY]

) ON [PRIMARY]
