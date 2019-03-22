CREATE TABLE [dbo].[tblSMCalendarEntity] (
	[intCalendarEntityId] [int] IDENTITY(1,1) NOT NULL,
	[intCalendarId] [int] NOT NULL,
	[intEntityId] [int] NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
    CONSTRAINT [PK_tblSMCalendarEntity] PRIMARY KEY CLUSTERED ([intCalendarEntityId] ASC)
);