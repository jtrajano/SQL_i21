CREATE TABLE [dbo].[tblTMClock] (
    [intConcurrencyId]          INT             DEFAULT 1 NOT NULL,
    [intClockID]                INT             IDENTITY (1, 1) NOT NULL,
    [strClockNumber]            NVARCHAR (50)   COLLATE Latin1_General_CI_AS CONSTRAINT [DEF_tblTMClock_strClockNumber] DEFAULT ('') NOT NULL,
    [dtmSummerChangeDate]       DATETIME        DEFAULT 0 NULL,
    [dtmWinterChangeDate]       DATETIME        DEFAULT 0 NULL,
    [strDeliveryTicketPrinter]  NVARCHAR (50)   COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [strDeliveryTicketNumber]   NVARCHAR (10)   COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [strDeliveryTicketFormat]   NVARCHAR (50)   COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [strReadingEntryMethod]     NVARCHAR (50)   COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [intBaseTemperature]        INT             DEFAULT 0 NULL,
    [dblAccumulatedWinterClose] NUMERIC (18, 6) DEFAULT 0 NULL,
    [dblJanuaryDailyAverage]    NUMERIC (18, 6) DEFAULT 0 NULL,
    [dblFebruaryDailyAverage]   NUMERIC (18, 6) DEFAULT 0 NULL,
    [dblMarchDailyAverage]      NUMERIC (18, 6) DEFAULT 0 NULL,
    [dblAprilDailyAverage]      NUMERIC (18, 6) DEFAULT 0 NULL,
    [dblMayDailyAverage]        NUMERIC (18, 6) DEFAULT 0 NULL,
    [dblJuneDailyAverage]       NUMERIC (18, 6) DEFAULT 0 NULL,
    [dblJulyDailyAverage]       NUMERIC (18, 6) DEFAULT 0 NULL,
    [dblAugustDailyAverage]     NUMERIC (18, 6) DEFAULT 0 NULL,
    [dblSeptemberDailyAverage]  NUMERIC (18, 6) DEFAULT 0 NULL,
    [dblOctoberDailyAverage]    NUMERIC (18, 6) DEFAULT 0 NULL,
    [dblNovemberDailyAverage]   NUMERIC (18, 6) DEFAULT 0 NULL,
    [dblDecemberDailyAverage]   NUMERIC (18, 6) DEFAULT 0 NULL,
    [strAddress]                NVARCHAR (50)   COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [strZipCode]                NVARCHAR (50)   COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [strCity]                   NVARCHAR (50)   COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [strCountry]                NVARCHAR (50)   COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
    [strCurrentSeason]          NVARCHAR (6)    COLLATE Latin1_General_CI_AS DEFAULT (N'Winter') NOT NULL,
    [strState]                  NVARCHAR (50)   COLLATE Latin1_General_CI_AS DEFAULT ((0)) NULL,
    CONSTRAINT [PK_tblTMClock] PRIMARY KEY CLUSTERED ([intClockID] ASC)
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMClock',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMClock',
    @level2type = N'COLUMN',
    @level2name = N'intClockID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Clock Location No',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMClock',
    @level2type = N'COLUMN',
    @level2name = N'strClockNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Summer Change Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMClock',
    @level2type = N'COLUMN',
    @level2name = N'dtmSummerChangeDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Winter Change Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMClock',
    @level2type = N'COLUMN',
    @level2name = N'dtmWinterChangeDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Delivery Ticket Printer',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMClock',
    @level2type = N'COLUMN',
    @level2name = N'strDeliveryTicketPrinter'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Delivery Ticket No',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMClock',
    @level2type = N'COLUMN',
    @level2name = N'strDeliveryTicketNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Delivery Ticket Format',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMClock',
    @level2type = N'COLUMN',
    @level2name = N'strDeliveryTicketFormat'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Readings Method',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMClock',
    @level2type = N'COLUMN',
    @level2name = N'strReadingEntryMethod'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Base Temperature',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMClock',
    @level2type = N'COLUMN',
    @level2name = N'intBaseTemperature'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Accum DD Winter Close',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMClock',
    @level2type = N'COLUMN',
    @level2name = N'dblAccumulatedWinterClose'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Jan',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMClock',
    @level2type = N'COLUMN',
    @level2name = N'dblJanuaryDailyAverage'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Feb',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMClock',
    @level2type = N'COLUMN',
    @level2name = N'dblFebruaryDailyAverage'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Mar',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMClock',
    @level2type = N'COLUMN',
    @level2name = N'dblMarchDailyAverage'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Apr',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMClock',
    @level2type = N'COLUMN',
    @level2name = N'dblAprilDailyAverage'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'May',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMClock',
    @level2type = N'COLUMN',
    @level2name = N'dblMayDailyAverage'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Jun',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMClock',
    @level2type = N'COLUMN',
    @level2name = N'dblJuneDailyAverage'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Jul',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMClock',
    @level2type = N'COLUMN',
    @level2name = N'dblJulyDailyAverage'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Aug',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMClock',
    @level2type = N'COLUMN',
    @level2name = N'dblAugustDailyAverage'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sep',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMClock',
    @level2type = N'COLUMN',
    @level2name = N'dblSeptemberDailyAverage'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Oct',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMClock',
    @level2type = N'COLUMN',
    @level2name = N'dblOctoberDailyAverage'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Nov',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMClock',
    @level2type = N'COLUMN',
    @level2name = N'dblNovemberDailyAverage'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Dec',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMClock',
    @level2type = N'COLUMN',
    @level2name = N'dblDecemberDailyAverage'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Address',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMClock',
    @level2type = N'COLUMN',
    @level2name = N'strAddress'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Zip/Postal Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMClock',
    @level2type = N'COLUMN',
    @level2name = N'strZipCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'City',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMClock',
    @level2type = N'COLUMN',
    @level2name = N'strCity'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Country',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMClock',
    @level2type = N'COLUMN',
    @level2name = N'strCountry'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Current Season',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMClock',
    @level2type = N'COLUMN',
    @level2name = N'strCurrentSeason'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'State/Province',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMClock',
    @level2type = N'COLUMN',
    @level2name = N'strState'