CREATE TABLE [dbo].[tblMBILLongTruckLoad](
	[intLongTruckLoadId] [int] IDENTITY(1,1) NOT NULL,
	[intLoadId] [int] NULL,
	[intLoadDetailId] [int] NULL,
	[intShiftId] [int] NULL,
	[strBOL] [nvarchar](100) NULL,
	[strPONumber] [nvarchar](100) NULL,
	[strRackNumber] [nvarchar](100) NULL,
	[strTemperature] [nvarchar](50) NULL,
	[intItemId] [int] NULL,
	[intSupplierId] [int] NULL,
	[intTerminalId] [int] NULL,
	[intLocationId] [int] NULL,
	[dblTotalPlanned] [decimal](18, 6) NULL,
	[dblTotalGross] [decimal](18, 6) NULL,
	[dblTotalNet] [decimal](18, 6) NULL,
	[dtmStartTime] [datetime] NULL,
	[dtmEndTime] [datetime] NULL,
	[strNote] [nvarchar](200) NULL,
	[intCompanyLocationId] [int] NULL,
	[intCustomerId] [int] NULL,
	[intCustomerLocationId] [int] NULL,
	[strTank] [nvarchar](50) NULL,
	[dblVolumeDelivered] [decimal](18, 6) NULL,
	[dblStickVolume] [decimal](18, 6) NULL,
	[dblWaterInches] [decimal](18, 6) NULL,
	[dblStickHeight] [decimal](18, 6) NULL,
	[dtmDateDelivered] [datetime] NULL,
	[ysnSignature] [bit] NULL,
	[strStatus] [nvarchar](50) NULL,
	[intConcurrencyId] [int] NULL,
	[intStickStartReading] [int] NULL,
	[intStickEndReading] [int] NULL,
	[intTruckId] [int] NULL,
	[strLongTruckNumber] [nvarchar](100) NULL,
 CONSTRAINT [PK_tblMBILLongTruckLoad] PRIMARY KEY CLUSTERED 
(
	[intLongTruckLoadId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


