CREATE TABLE [dbo].[tblWHTruckOrder]
(
		[intTruckId] INT NOT NULL,
		[intOrderHeaderId] INT NOT NULL,
		[intSequenceNo] INT NULL DEFAULT 0,
		[intLastModifiedUserId] INT NULL,
		[dtmLastModified] DATETIME NULL DEFAULT GetDate(), 

    CONSTRAINT [PK_tblWHTruckOrder] PRIMARY KEY ([intOrderHeaderId], [intTruckId]),
	CONSTRAINT [FK_tblWHOrderHeader_tblWHTruckOrder_intOrderHeaderId] FOREIGN KEY ([intOrderHeaderId]) REFERENCES [tblWHOrderHeader]([intOrderHeaderId]), 
	CONSTRAINT [FK_tblWHTruck_tblWHTruckOrder_intTruckId] FOREIGN KEY ([intTruckId]) REFERENCES [tblWHTruck]([intTruckId]), 
)