CREATE TABLE [dbo].[tblEMEntityLocationDefaultItem] (
    [intEntityLocationDefaultItemId]    INT IDENTITY (1, 1) NOT NULL,
    [intEntityLocationId]                   INT DEFAULT 0 NULL,
    
    [intItemId]                             INT DEFAULT 0 NULL,
    [intEstimatedUnits]						INT NULL,
	[intMonthstoUseForAvg]					INT NULL,
    [intOrdersToUseForAvg]					INT NULL,
	-- [strOrderToUseForAvg]					NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 

    [intConcurrencyId]                      INT DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblEMEntityLocationDefaultItem] PRIMARY KEY CLUSTERED ([intEntityLocationDefaultItemId] ASC),   
    CONSTRAINT [FK_tblEMEntityLocationDefaultItem_tblEMEntityLocation] FOREIGN KEY ([intEntityLocationId]) REFERENCES [dbo].[tblEMEntityLocation] ([intEntityLocationId]),    
	CONSTRAINT [FK_tblEMEntityLocationDefaultItem_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [dbo].[tblICItem] ([intItemId])
);
GO