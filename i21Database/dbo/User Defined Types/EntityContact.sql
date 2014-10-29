CREATE TYPE [dbo].[EntityContact] AS TABLE
(
	EntityId int NOT NULL,
	[ContactNumber] NVARCHAR (15)   COLLATE Latin1_General_CI_AS NOT NULL DEFAULT '',
    [Title]         NVARCHAR (35)  COLLATE Latin1_General_CI_AS NULL,
    [Department]    NVARCHAR (30)  COLLATE Latin1_General_CI_AS NULL,
    [Mobile]        NVARCHAR (25)  COLLATE Latin1_General_CI_AS NULL,
    [Phone]         NVARCHAR (25)  COLLATE Latin1_General_CI_AS NULL,
    [Phone2]        NVARCHAR (25)  COLLATE Latin1_General_CI_AS NULL,
    [Email2]        NVARCHAR (75)  COLLATE Latin1_General_CI_AS NULL,
    [Fax]           NVARCHAR (25)  COLLATE Latin1_General_CI_AS NULL,
    [Notes]         NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [ContactMethod] NVARCHAR (20)  COLLATE Latin1_General_CI_AS NULL,
    [Timezone]      NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL
)
