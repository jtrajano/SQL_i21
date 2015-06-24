﻿CREATE TABLE [dbo].[tblWHSKUStatus]
(
		[intSKUStatusId]	INT	NOT NULL IDENTITY,
		[intConcurrencyId] INT NOT NULL,
		[strInternalCode]	NVARCHAR(32) COLLATE Latin1_General_CI_AS NOT NULL, 
		[strSKUStatus]	NVARCHAR(32) COLLATE Latin1_General_CI_AS NOT NULL, 
		[ysnDefault]	BIT DEFAULT 0,
		[ysnLocked]	BIT DEFAULT 1,

		CONSTRAINT [PK_tblWHSKUStatus_intSKUStatusId] PRIMARY KEY ([intSKUStatusId])

)
