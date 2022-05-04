
CREATE TABLE [dbo].[tblCMResponsiblePartyOption](
	[intOptionId] [int] IDENTITY(1,1) NOT NULL,
	[strOptionName] [nvarchar](100)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strAction] nvarchar(30) COLLATE Latin1_General_CI_AS NOT NULL DEFAULT('Raise Error'),
	[intConcurrencyId] INT NOT NULL DEFAULT(1),
 CONSTRAINT [PK_tblCMResponsiblePartyOption] PRIMARY KEY CLUSTERED 
(
	[intOptionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO