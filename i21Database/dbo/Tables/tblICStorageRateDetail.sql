CREATE TABLE [dbo].[tblICStorageRateDetail](
	[intStorageRateDetailId] [int] IDENTITY(1,1) NOT NULL,
	[intStorageRateId] INT NOT NULL,
	[dblNoOfDays] NUMERIC(18, 6) NOT NULL DEFAULT ((0)),
	[strRateType] NVARCHAR(20) NULL,
	[dblRate] NUMERIC(18, 6) NOT NULL DEFAULT ((0)),
	[intCommodityUnitMeasureId] [int] NULL ,
	[intConcurrencyId] [int] NOT NULL DEFAULT ((0)) ,
    CONSTRAINT [PK_tblICStorageRateDetail] PRIMARY KEY CLUSTERED ([intStorageRateDetailId] ASC), 
    CONSTRAINT [FK_tblICStorageRateDetail_tblICStorageRate] FOREIGN KEY ([intStorageRateId]) REFERENCES [tblICStorageRate]([intStorageRateId]) ON UPDATE CASCADE ON DELETE CASCADE
) 
GO

