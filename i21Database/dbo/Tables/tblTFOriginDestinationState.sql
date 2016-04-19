CREATE TABLE [dbo].[tblTFOriginDestinationState](
	[intOriginDestinationStateId] [int] IDENTITY(1,1) NOT NULL,
	[strOriginDestinationState] [nvarchar](10) NOT NULL,
	[intConcurrencyId] [int] NULL,
 CONSTRAINT [PK_tblTFOriginDestination] PRIMARY KEY CLUSTERED 
(
	[intOriginDestinationStateId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

