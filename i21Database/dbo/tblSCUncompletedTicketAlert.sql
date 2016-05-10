CREATE TABLE [dbo].[tblSCUncompletedTicketAlert]
(
    [intUncompletedTicketAlertId] INT NOT NULL , 
    [intEntityId] INT NULL, 
    [intCompanyLocationId] INT NULL, 
    [intTicketUncompletedDaysAlert] INT NULL, 
    [intCompanyPreferenceId] INT NOT NULL, 
    CONSTRAINT [PK_tblSCUncompletedTicketAlert] PRIMARY KEY ([intUncompletedTicketAlertId]),
    CONSTRAINT [FK_tblSCUncompletedTicketAlert_tblGRCompanyPreference_intCompanyPreferenceId] FOREIGN KEY ([intCompanyPreferenceId]) REFERENCES [tblGRCompanyPreference]([intCompanyPreferenceId]) 
)
