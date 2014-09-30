CREATE TABLE [dbo].[tblHDVersion]
(
	[intVersionId] [int] IDENTITY(1,1) NOT NULL,
	[intTicketProductId] [int] NOT NULL,
	[strVersionNo] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] [nvarchar](150) COLLATE Latin1_General_CI_AS NOT NULL,
	[dtmReleaseDate] [date] NULL,
	[ysnSupported] [bit] NULL,
	[dtmEOLDate] [date] NULL,
	[intSort] [int] NULL,
	[intConcurrencyId] [int] NOT NULL,
	CONSTRAINT [PK_tblHDVersion] PRIMARY KEY CLUSTERED ([intVersionId] ASC),
	CONSTRAINT [UNQ_tblHDVersion] UNIQUE ([intTicketProductId],[strVersionNo]),
    CONSTRAINT [FK_Version_TicketProduct] FOREIGN KEY ([intTicketProductId]) REFERENCES [dbo].[tblHDTicketProduct] ([intTicketProductId]) on delete cascade
)
