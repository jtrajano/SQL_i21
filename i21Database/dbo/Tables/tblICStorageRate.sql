CREATE TABLE [dbo].[tblICStorageRate](
	[intStorageRateId] [int] IDENTITY(1,1) NOT NULL,
	[dtmStartDateUTC] [datetime] NULL,
	[dtmEndDateUTC] [datetime] NULL,
	[intStorageLocationId] [int] NULL,
	[intCompanyLocationId] [int] NULL,
	[intCommodityId] [int] NULL,
	[strPlanNo] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] [nvarchar](200) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT ((0)) ,
	strChargePeriod NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL DEFAULT (N'Daily') ,
	[intItemId] [int] NULL,
 	[ysnActive] BIT NOT NULL DEFAULT 1, 
	[intCurrencyId] [int] NOT NULL,
    CONSTRAINT [PK_tblICStorageRate] PRIMARY KEY CLUSTERED ([intStorageRateId] ASC)
) 
GO

