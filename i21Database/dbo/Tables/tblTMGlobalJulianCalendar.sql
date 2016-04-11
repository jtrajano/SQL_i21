CREATE TABLE [dbo].[tblTMGlobalJulianCalendar](
	[intGlobalJulianCalendarId] [int] IDENTITY(1,1) NOT NULL,
	[strDescription] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intJanuary] [int] NOT NULL CONSTRAINT [DF_tblTMGlobalJulianCalendar_intJanuary]  DEFAULT ((30)),
	[intFebruary] [int] NOT NULL CONSTRAINT [DF_tblTMGlobalJulianCalendar_intFebruary]  DEFAULT ((30)),
	[intMarch] [int] NOT NULL CONSTRAINT [DF_tblTMGlobalJulianCalendar_intMarch]  DEFAULT ((30)),
	[intApril] [int] NOT NULL CONSTRAINT [DF_tblTMGlobalJulianCalendar_intApril]  DEFAULT ((30)),
	[intMay] [int] NOT NULL CONSTRAINT [DF_tblTMGlobalJulianCalendar_intMay]  DEFAULT ((30)),
	[intJune] [int] NOT NULL CONSTRAINT [DF_tblTMGlobalJulianCalendar_intJune]  DEFAULT ((30)),
	[intJuly] [int] NOT NULL CONSTRAINT [DF_tblTMGlobalJulianCalendar_intJuly]  DEFAULT ((30)),
	[intAugust] [int] NOT NULL CONSTRAINT [DF_tblTMGlobalJulianCalendar_intAugust]  DEFAULT ((30)),
	[intSeptember] [int] NOT NULL CONSTRAINT [DF_tblTMGlobalJulianCalendar_intSeptember]  DEFAULT ((30)),
	[intOctober] [int] NOT NULL CONSTRAINT [DF_tblTMGlobalJulianCalendar_intOctober]  DEFAULT ((30)),
	[intNovember] [int] NOT NULL CONSTRAINT [DF_tblTMGlobalJulianCalendar_intNovember]  DEFAULT ((30)),
	[intDecember] [int] NOT NULL CONSTRAINT [DF_tblTMGlobalJulianCalendar_intDecember]  DEFAULT ((30)),
	[intConcurrencyId] [int] NOT NULL CONSTRAINT [DF_tblTMGlobalJulianCalendar_intConcurrencyId]  DEFAULT ((1)),
	[ysnDefault] [bit] NOT NULL CONSTRAINT [DF_tblTMGlobalJulianCalendar_ysnDefault]  DEFAULT ((0)), 
    CONSTRAINT [PK_tblTMGlobalJulianCalendar] PRIMARY KEY ([intGlobalJulianCalendarId])
) ON [PRIMARY]

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMGlobalJulianCalendar',
    @level2type = N'COLUMN',
    @level2name = N'intGlobalJulianCalendarId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMGlobalJulianCalendar',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'