CREATE TABLE [dbo].[tblSCUncompletedTicketAlert]
(
    [intUncompletedTicketAlertId] INT NOT NULL IDENTITY, 
    [intEntityId] INT NOT NULL, 
    [intCompanyLocationId] INT NULL, 
    [intTicketUncompletedDaysAlert] INT NOT NULL, 
    [intCompanyPreferenceId] INT NOT NULL, 
    [intConcurrencyId] INT NOT NULL 
    CONSTRAINT [PK_tblSCUncompletedTicketAlert] PRIMARY KEY ([intUncompletedTicketAlertId]),
    CONSTRAINT [FK_tblSCUncompletedTicketAlert_tblGRCompanyPreference_intCompanyPreferenceId] FOREIGN KEY ([intCompanyPreferenceId]) REFERENCES [tblGRCompanyPreference]([intCompanyPreferenceId]) 
)
