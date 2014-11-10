CREATE TABLE [dbo].[tblNRNote]
(
	[intNoteId] [int] IDENTITY(1,1) NOT NULL,
	[strNoteNumber] [nvarchar](10) COLLATE Latin1_General_CI_AS NOT NULL,
	[strCustomerNumber] [nvarchar](10) COLLATE Latin1_General_CI_AS NOT NULL,
	[strNoteType] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intDescriptionId] [int] NOT NULL,
	[dblCreditLimit] [numeric](18, 6) NOT NULL,
	[dtmMaturityDate] [datetime] NOT NULL,
	[dblInterestRate] [numeric](18, 6) NOT NULL,
	[dblNotePrincipal] [numeric](18, 6) NULL,
	[ysnWriteOff] [bit] NULL,
	[dtmWriteOffDate] [datetime] NULL,
	[intCreatedUserId] [int] NULL,
	[dtmCreated] [datetime] NULL,
	[intLastModifiedUserId] [int] NULL,
	[dtmLastModified] [datetime] NULL,
	[intConcurrencyId] [int] NULL,
 CONSTRAINT [PK_tblNRNote_intNoteId] PRIMARY KEY CLUSTERED 
(
	[intNoteId] ASC
) ON [PRIMARY],
CONSTRAINT [FK_tblNRNote_tblNRNoteDescription_intDescriptionId] FOREIGN KEY([intDescriptionId])
REFERENCES [tblNRNoteDescription] ([intDescriptionId])
) ON [PRIMARY]