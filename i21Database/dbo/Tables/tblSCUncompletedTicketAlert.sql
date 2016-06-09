CREATE TABLE [dbo].[tblSCUncompletedTicketAlert]
(
    [intUncompletedTicketAlertId] INT NOT NULL IDENTITY, 
    [intEntityId] INT NOT NULL, 
    [intCompanyLocationId] INT NULL, 
    [intTicketUncompletedDaysAlert] INT NOT NULL, 
    [intConcurrencyId] INT NOT NULL 
    CONSTRAINT [PK_tblSCUncompletedTicketAlert] PRIMARY KEY ([intUncompletedTicketAlertId]),
)
