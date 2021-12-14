CREATE TABLE [dbo].[tblMBILLongTruckHeader](
	[intLongTruckHeaderId] [int] IDENTITY(1,1) NOT NULL,
	[intLoadId] [int] NOT NULL,
	[intShiftId] [int] NULL,
	[intDriverId] [int] NULL,
	[intTruckId] [int] NULL,
	[strType] [nvarchar](100) NULL,
	[intConcurrencyId] [int] NULL,
 CONSTRAINT [PK_tblMBILLongTruckHeader] PRIMARY KEY CLUSTERED 
(
	[intLongTruckHeaderId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


