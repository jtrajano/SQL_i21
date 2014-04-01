CREATE TABLE [dbo].[tblHDVersion]
(
	[intVersionId] [int] IDENTITY(1,1) NOT NULL,
	[intTicketProductId] [int] NOT NULL,
	[strVersionNo] [nvarchar](max) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] [nvarchar](max) COLLATE Latin1_General_CI_AS NOT NULL,
	[dtmReleaseDate] [date] NULL,
	[ysnSupported] [bit] NULL,
	[dtmEOLDate] [date] NULL,
	[intConcurrencyId] [int] NOT NULL,
	CONSTRAINT [PK_tblHDVersion] PRIMARY KEY CLUSTERED ([intVersionId] ASC),
    CONSTRAINT [FK_Version_TicketProduct] FOREIGN KEY ([intTicketProductId]) REFERENCES [dbo].[tblHDTicketProduct] ([intTicketProductId]),
)
