CREATE TABLE [dbo].[tblLGRouteDirection]
(
	[intRouteDirectionId] INT NOT NULL IDENTITY(1, 1), 
    [intConcurrencyId] INT NOT NULL, 
	[intRouteId] INT NOT NULL, 	
	[intSequence] INT NULL, 	
	[strOrigin] [NVARCHAR](MAX) COLLATE Latin1_General_CI_AS NULL,
	[strDestination] [NVARCHAR](MAX) COLLATE Latin1_General_CI_AS NULL,
	[strDirection] [NVARCHAR](MAX) COLLATE Latin1_General_CI_AS NULL,
	[intSort] INT NULL, 
	
    CONSTRAINT [PK_tblLGRouteDirection] PRIMARY KEY ([intRouteDirectionId]),
    CONSTRAINT [FK_tblLGRouteDirection_tblLGRoute_intRouteId] FOREIGN KEY ([intRouteId]) REFERENCES [tblLGRoute]([intRouteId]) ON DELETE CASCADE
)
