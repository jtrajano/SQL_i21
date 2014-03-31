CREATE TABLE [dbo].[tblHDTicketProduct]
(
	[intTicketProductId] [int] IDENTITY(1,1) NOT NULL,
	[strProduct] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] [nvarchar](150) COLLATE Latin1_General_CI_AS NOT NULL,
	[intSort] [int] NULL,
	[intConcurrencyId] [int] NOT NULL,
 CONSTRAINT [PK_tblHDTicketProduct] PRIMARY KEY CLUSTERED 
(
	[intTicketProductId] ASC
)
)
