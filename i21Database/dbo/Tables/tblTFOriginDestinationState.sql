﻿CREATE TABLE [dbo].[tblTFOriginDestinationState](
	[intOriginDestinationStateId] [int] IDENTITY(1,1) NOT NULL,
	[strOriginDestinationState] [nvarchar](10) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] [int] NULL,
 CONSTRAINT [PK_tblTFOriginDestination] PRIMARY KEY CLUSTERED 
(
	[intOriginDestinationStateId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[tblTFOriginDestinationState] ADD  CONSTRAINT [DF_tblTFOriginDestinationState_intConcurrencyId]  DEFAULT ((1)) FOR [intConcurrencyId]
GO

