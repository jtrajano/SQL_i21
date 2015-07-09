﻿CREATE TABLE [dbo].[tblWHTask]
(
	[intTaskId] INT NOT NULL PRIMARY KEY, 
	[intConcurrencyId] INT NOT NULL,
    [strTaskNo] NVARCHAR(64) COLLATE Latin1_General_CI_AS NULL,
    [intTaskTypeId] INT NOT NULL, 
    [intTaskStateId] INT NOT NULL, 
    [intAssigneeId] INT NULL, 
    [intAddressId] INT NULL, 
    [intTaskPriorityId] INT NOT NULL, 
    [dtmReleaseDate] DATETIME NULL, 
    [intFromStorageLocationId] INT NULL, 
    [intToStorageLocationId] INT NULL, 
    [intOrderHeaderId] INT NULL, 
    [intFromContainerId] INT NULL, 
    [intToContainerId] INT NULL, 
    [intSKUId] INT NOT NULL, 
    [dblQty] NUMERIC(18, 6) NULL, 
    [strAssignerComment] NVARCHAR(2048) COLLATE Latin1_General_CI_AS NULL, 
    [strAssigneeComment] NVARCHAR(1024) COLLATE Latin1_General_CI_AS NULL, 
	[intCreatedUserId] INT NULL,
	[dtmCreated] DATETIME NULL DEFAULT GetDate(),
	[intLastModifiedUserId] INT NULL,
	[dtmLastModified] DATETIME NULL DEFAULT GetDate(),
	
	CONSTRAINT [FK_tblWHTask_tblWHTaskType_intTaskTypeId] FOREIGN KEY ([intTaskTypeId]) REFERENCES [tblWHTaskType]([intTaskTypeId]), 
	CONSTRAINT [FK_tblWHTask_tblWHTaskPriority_intTaskPriorityId] FOREIGN KEY ([intTaskPriorityId]) REFERENCES [tblWHTaskPriority]([intTaskPriorityId]), 
	CONSTRAINT [FK_tblWHTask_tblWHTaskState_intTaskStateId] FOREIGN KEY ([intTaskStateId]) REFERENCES [tblWHTaskState]([intTaskStateId]), 
	CONSTRAINT [FK_tblWHTask_tblWHSKU_intSKUId] FOREIGN KEY ([intSKUId]) REFERENCES [tblWHSKU]([intSKUId]), 
)
