/*
## Overview
The list of lots rejected. 

## Source Code:
*/
	CREATE TABLE [dbo].[tblICLotRejected]
	(
		[intId] INT NOT NULL IDENTITY, 		
		[intLotId] INT NOT NULL,		        
        [intRejectedByEntityId] INT,
		CONSTRAINT [PK_tblICLotRejected] PRIMARY KEY CLUSTERED ([intId] ASC),
		CONSTRAINT [FK_tblICLotRejected_tblEMEntity] FOREIGN KEY ([intRejectedByEntityId]) REFERENCES [tblEMEntity]([intEntityId])  
	)
	GO

	CREATE NONCLUSTERED INDEX [IX_tblICLotRejected_intLotId]
		ON [dbo].[tblICLotRejected](intLotId ASC);
	GO 

	CREATE NONCLUSTERED INDEX [IX_tblICLotRejected_intRejectedByEntityId]
		ON [dbo].[tblICLotRejected](intRejectedByEntityId ASC);
	GO 
