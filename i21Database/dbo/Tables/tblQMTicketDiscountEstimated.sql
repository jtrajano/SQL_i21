CREATE TABLE [dbo].[tblQMTicketDiscountEstimated]
(
	[intTicketDiscountEstimatedId] INT NOT NULL IDENTITY,
    [intTicketDiscountEstimatedSourceId] INT NOT NULL, 
	[dblGradeReading] DECIMAL(24, 10) NULL,     
    
    [intTicketId] INT NULL,     
	[intConcurrencyId] INT NULL, 


	CONSTRAINT [PK_tblQMTicketDiscountEstimated_intTicketDiscountId] PRIMARY KEY ([intTicketDiscountEstimatedId]),
	CONSTRAINT [UK_tblQMTicketDiscountEstimated_intTicketId_intTicketFileId_strSourceType_intDiscountScheduleCodeId] UNIQUE ([intTicketId], [intTicketDiscountEstimatedSourceId]),
	CONSTRAINT [FK_tblQMTicketDiscountEstimated_tblSCTicket_intTicketId] FOREIGN KEY ([intTicketId]) REFERENCES [tblSCTicket]([intTicketId]),
	CONSTRAINT [FK_tblQMTicketDiscountEstimated_tblQMTicketDiscountSource] FOREIGN KEY ([intTicketDiscountEstimatedSourceId]) REFERENCES [tblQMTicketDiscountEstimatedSource]([intTicketDiscountEstimatedSourceId]),
	
)
GO

CREATE NONCLUSTERED INDEX [IX_tblQMTicketDiscountEstimated_intTicketId_K5_] ON [dbo].[tblQMTicketDiscountEstimated]
(
	[intTicketId] ASC,	
	[intTicketDiscountEstimatedId] ASC
)
INCLUDE([dblGradeReading])
GO 



