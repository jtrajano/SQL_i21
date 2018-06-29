CREATE TABLE [dbo].[tblSCUncompletedTicketAlert]
(
    [intUncompletedTicketAlertId] INT NOT NULL IDENTITY, 
    [intEntityId] INT NOT NULL, 
    [intCompanyLocationId] INT NULL, 
    [intTicketUncompletedDaysAlert] INT NOT NULL, 
    [intConcurrencyId] INT NOT NULL 
    CONSTRAINT [PK_tblSCUncompletedTicketAlert] PRIMARY KEY ([intUncompletedTicketAlertId]),
	CONSTRAINT [FK_tblSCUncompletedTicketAlert_tblEMEntity_intEntityId] FOREIGN KEY (intEntityId) REFERENCES [tblEMEntity](intEntityId),
	CONSTRAINT [FK_tblSCUncompletedTicketAlert_tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY (intCompanyLocationId) REFERENCES [tblSMCompanyLocation](intCompanyLocationId)
)
