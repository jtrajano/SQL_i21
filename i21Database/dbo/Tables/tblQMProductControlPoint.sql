﻿CREATE TABLE [dbo].[tblQMProductControlPoint]
(
	[intProductControlPointId] INT NOT NULL IDENTITY, 
	[intConcurrencyId] INT NULL CONSTRAINT [DF_tblQMProductControlPoint_intConcurrencyId] DEFAULT 0, 
	[intProductId] INT NOT NULL, 
	[intControlPointId] INT NOT NULL, 

	[intCreatedUserId] [int] NULL,
	[dtmCreated] [datetime] NULL CONSTRAINT [DF_tblQMProductControlPoint_dtmCreated] DEFAULT GetDate(),
	[intLastModifiedUserId] [int] NULL,
	[dtmLastModified] [datetime] NULL CONSTRAINT [DF_tblQMProductControlPoint_dtmLastModified] DEFAULT GetDate(),
		
	CONSTRAINT [PK_tblQMProductControlPoint] PRIMARY KEY ([intProductControlPointId]), 
	CONSTRAINT [AK_tblQMProductControlPoint_intProductId_intControlPointId] UNIQUE ([intProductId],[intControlPointId]), 
	CONSTRAINT [FK_tblQMProductControlPoint_tblQMProduct] FOREIGN KEY ([intProductId]) REFERENCES [tblQMProduct]([intProductId]) ON DELETE CASCADE, 
	CONSTRAINT [FK_tblQMProductControlPoint_tblQMControlPoint] FOREIGN KEY ([intControlPointId]) REFERENCES [tblQMControlPoint]([intControlPointId]) 
)