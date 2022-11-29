CREATE TABLE [dbo].[tblSCSnapShotTicket](
	intSnapShotTicketId INT NOT NULL IDENTITY,
	[intTicketId] INT NOT NULL , 
	
    [dblGrossWeight] DECIMAL(13, 3) NULL, 
    [dblGrossWeight1] DECIMAL(13, 3) NULL, 
    [dblGrossWeight2] DECIMAL(13, 3) NULL, 

    [dblTareWeight] DECIMAL(13, 3) NULL, 
    [dblTareWeight1] DECIMAL(13, 3) NULL, 
    [dblTareWeight2] DECIMAL(13, 3) NULL, 

	[dblGrossUnits] NUMERIC(38, 20) NULL, 
	[dblShrink] NUMERIC(38, 20) NULL,
    [dblNetUnits] NUMERIC(38, 20) NULL, 


	[strItemUOM] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] INT NOT NULL DEFAULT(1),
	CONSTRAINT [PK_tblSCSnapShotTicket_intSnapShotTicketId] PRIMARY KEY ([intSnapShotTicketId]),	

)