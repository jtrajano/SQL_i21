CREATE TABLE [dbo].[tblWMContainer]
	(	
		[intContainerId] INT NOT NULL IDENTITY, 
		[intConcurrencyId] INT NOT NULL,
		[strContainerNo]	NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
		[intContainerTypeId]	INT NOT NULL,
		[intStorageLocationId]	INT NOT NULL,
		[dblTareWeight]	NUMERIC(18,6) NULL,
		[intCreatedUserId] [int] NULL,
		[dtmCreated] [datetime] NULL DEFAULT GetDate(),
		[intLastModifiedUserId] [int] NULL,
		[dtmLastModified] [datetime] NULL DEFAULT GetDate(),

		CONSTRAINT [PK_tblWMContainer_intContainerId] PRIMARY KEY ([intContainerId]), 
		CONSTRAINT [FK_tblWMContainer_tblICStorageLocation_intStorageLocationId] FOREIGN KEY ([intStorageLocationId]) REFERENCES [tblICStorageLocation]([intStorageLocationId]), 
		CONSTRAINT [FK_tblWMContainer_tblWMContainerType_intContainerTypeId] FOREIGN KEY ([intContainerTypeId]) REFERENCES [tblWMContainerType]([intContainerTypeId]),
)
