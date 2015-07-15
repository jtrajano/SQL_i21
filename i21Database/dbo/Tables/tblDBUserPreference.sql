﻿CREATE TABLE [dbo].[tblDBUserPreference]
(
	[intUserPreferenceId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intUserSecurityId] INT NULL,
    [ysnAutoPanelWidth] BIT NULL DEFAULT ((1)), 
    [ysnAutoRefresh] BIT NULL DEFAULT ((0)), 
    [intAutoRefreshMinute] INT NULL DEFAULT ((1)), 
    [ysnColumnFiltering] BIT NULL DEFAULT ((0)), 
    [ysnColumnMoving] BIT NULL DEFAULT ((1)), 
    [ysnColumnResizing] BIT NULL DEFAULT ((1)), 
    [ysnColumnSorting] BIT NULL DEFAULT ((1)), 
    [intColumns] INT NULL DEFAULT ((0)), 
    [intColumnWidth1] INT NULL DEFAULT ((0)), 
    [intColumnWidth2] INT NULL DEFAULT ((0)), 
    [intColumnWidth3] INT NULL DEFAULT ((0)), 
    [intColumnWidth4] INT NULL DEFAULT ((0)), 
    [intDefaultTabId] INT NULL DEFAULT ((0)), 
    [ysnExportAll] BIT NULL DEFAULT ((1)), 
    [ysnPrintAll] BIT NULL DEFAULT ((1)), 
    [ysnRefreshTab] BIT NULL DEFAULT ((0)), 
    [ysnSaveGridLayout] BIT NULL DEFAULT ((1)), 
    [intConcurrencyId] INT NULL DEFAULT ((1))
)
