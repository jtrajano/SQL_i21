CREATE TABLE [dbo].[tblCMResponsibleParty](
	[intResponsiblePartyId] [int] IDENTITY(1,1) NOT NULL,
	[strContainText] [nvarchar](100)  COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
	[strTransferFrom] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
	[intBankAccountIdTo] [int] NOT NULL,
	[intConcurrencyId] int null,
 CONSTRAINT [PK_tblCMResponsibleParty] PRIMARY KEY CLUSTERED 
(
	[intResponsiblePartyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO