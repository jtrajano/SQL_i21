CREATE TABLE [dbo].[tblSCTicketSpotUsed]
(
	[intTicketSpotUsedId] INT NOT NULL IDENTITY, 
    [intTicketId] INT NULL, 
    [intEntityId] INT NULL, 
    [dblQty] NUMERIC(38, 20) NULL,
    [dblUnitFuture] NUMERIC(18,6) NULL,
    [dblUnitBasis] NUMERIC(18,6) NULL,
	CONSTRAINT [PK_tblSCTicketSpotUsed_intTicketSpotUsedId] PRIMARY KEY ([intTicketSpotUsedId]) 
)
