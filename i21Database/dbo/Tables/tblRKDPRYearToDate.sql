CREATE TABLE [dbo].[tblRKDPRYearToDate]
(
	[intDPRYearToDateId] INT IDENTITY NOT NULL , 
    [intDPRHeaderId] INT NOT NULL, 
	[intRowNumber] INT NULL,
    [strType] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [intEntityId] INT NULL,
    [intCommodityId] INT NULL,
    [strCommodityCode] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [strFieldName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [dblTotal] NUMERIC(24, 10) NULL,
	[intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblRKDPRYearToDate] PRIMARY KEY ([intDPRYearToDateId]), 
    CONSTRAINT [FK_tblRKDPRYearToDate_tblRKDPRHeader] FOREIGN KEY ([intDPRHeaderId]) REFERENCES [tblRKDPRHeader]([intDPRHeaderId]) ON DELETE CASCADE
)
GO

CREATE NONCLUSTERED INDEX [IX_tblRKDPRYearToDate_intDPRHeaderId]
	ON [dbo].[tblRKDPRYearToDate] ([intDPRHeaderId]);   
GO 