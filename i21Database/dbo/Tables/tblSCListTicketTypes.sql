CREATE TABLE [dbo].[tblSCListTicketTypes]
(
    [intTicketTypeId] [int] IDENTITY(1,1) NOT NULL,
    [intTicketType] [int] NOT NULL,
    [strTicketType] [varchar](40) COLLATE Latin1_General_CI_AS NULL,
    [strInOutIndicator] [varchar](5) COLLATE Latin1_General_CI_AS NULL,
    [ysnActive] bit NOT NULL,
    [intConcurrencyId] [int] NULL, 
    CONSTRAINT [PK_tblSCListTicketTypes] PRIMARY KEY ([intTicketTypeId]), 
)
GO



CREATE NONCLUSTERED INDEX [IX_tblSCListTicketTypes_ticket_view] ON [dbo].[tblAPPaymentDetail] 
(
	[intTicketTypeId] ASC,
	[strInOutIndicator] ASC
)
WITH (SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]


GO