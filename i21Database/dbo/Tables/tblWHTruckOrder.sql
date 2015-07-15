CREATE TABLE [dbo].[tblWHTruckOrder]
(
		[intTruckId] INT NOT NULL,
		[intOrderHeaderId] INT NOT NULL,
		[intSequenceNo] INT NULL DEFAULT 0,
		[intLastModifiedUserId] INT NULL,
		[dtmLastModified] DATETIME NULL DEFAULT GetDate(),
)