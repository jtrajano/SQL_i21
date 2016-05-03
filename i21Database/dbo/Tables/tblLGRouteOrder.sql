CREATE TABLE [dbo].[tblLGRouteOrder]
(
	[intRouteOrderId] INT NOT NULL IDENTITY(1, 1), 
    [intConcurrencyId] INT NOT NULL, 
	[intRouteId] INT NOT NULL, 
	[intDispatchID] INT NULL,
	[intLoadDetailId] INT NULL,
	[intSequence] INT NULL,
	[dblFromLatitude] NUMERIC(18, 6) NULL,
	[dblFromLongitude] NUMERIC(18, 6) NULL,
	[strFromAddress] [NVARCHAR](MAX) COLLATE Latin1_General_CI_AS NULL,
	[strFromCity] [NVARCHAR](MAX) COLLATE Latin1_General_CI_AS NULL,
	[strFromState] [NVARCHAR](MAX) COLLATE Latin1_General_CI_AS NULL,
	[strFromZipCode] [NVARCHAR](MAX) COLLATE Latin1_General_CI_AS NULL,
	[strFromCountry] [NVARCHAR](MAX) COLLATE Latin1_General_CI_AS NULL,
	[dblToLatitude] NUMERIC(18, 6) NULL,
	[dblToLongitude] NUMERIC(18, 6) NULL,
	[strToAddress] [NVARCHAR](MAX) COLLATE Latin1_General_CI_AS NULL,
	[strToCity] [NVARCHAR](MAX) COLLATE Latin1_General_CI_AS NULL,
	[strToState] [NVARCHAR](MAX) COLLATE Latin1_General_CI_AS NULL,
	[strToZipCode] [NVARCHAR](MAX) COLLATE Latin1_General_CI_AS NULL,
	[strToCountry] [NVARCHAR](MAX) COLLATE Latin1_General_CI_AS NULL,

    CONSTRAINT [PK_tblLGRouteOrder] PRIMARY KEY ([intRouteOrderId]),
    CONSTRAINT [FK_tblLGRouteOrder_tblLGRoute_intRouteId] FOREIGN KEY ([intRouteId]) REFERENCES [tblLGRoute]([intRouteId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblLGRouteOrder_tblLGLoadDetail_intLoadDetailId] FOREIGN KEY ([intLoadDetailId]) REFERENCES [tblLGLoadDetail]([intLoadDetailId])
)
