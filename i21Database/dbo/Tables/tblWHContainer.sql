CREATE TABLE [dbo].[tblWHContainer]
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

		CONSTRAINT [UQ_tblWHContainer_strContainerNo] UNIQUE ([strContainerNo]),
		CONSTRAINT [PK_tblWHContainer_intContainerId] PRIMARY KEY ([intContainerId]), 
		CONSTRAINT [FK_tblWHContainer_tblICStorageLocation_intStorageLocationId] FOREIGN KEY ([intStorageLocationId]) REFERENCES [tblICStorageLocation]([intStorageLocationId]), 
		CONSTRAINT [FK_tblWHContainer_tblWHContainerType_intContainerTypeId] FOREIGN KEY ([intContainerTypeId]) REFERENCES [tblWHContainerType]([intContainerTypeId]),
)
