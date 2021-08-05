CREATE TABLE [dbo].[tblEMEntityFarmDetail]
(	
    [intFarmDetailId]				INT				IDENTITY (1, 1) NOT NULL,
    [intFarmFieldId]				INT				NOT NULL,
    [strFieldNumber]				NVARCHAR (10)	COLLATE Latin1_General_CI_AS NULL,
    [strFieldDescription]			NVARCHAR (30)	COLLATE Latin1_General_CI_AS NULL,
    [strDefaultLocation]			NVARCHAR (3)	COLLATE Latin1_General_CI_AS NULL,
	[intCompanyLocationId]			INT NULL,
    [dblAcres]						NUMERIC(18, 6)	NULL,
    [strFSANumber]					NVARCHAR (10)	COLLATE Latin1_General_CI_AS NULL,
    [ysnObsolete]					BIT				NOT NULL DEFAULT ((0)),
    [dblLatitudeDegrees]			NUMERIC(18, 6)	NULL,
    [strLatitudeNS]					NVARCHAR (10)	COLLATE Latin1_General_CI_AS NULL,
    [dblLongitudeDegrees]			NUMERIC(18, 6)	NULL,
    [strLongitudeEW]				NVARCHAR (10)	COLLATE Latin1_General_CI_AS NULL,
    [strComments]					NVARCHAR (30)	COLLATE Latin1_General_CI_AS NULL,
    [strSplitNumber]				NVARCHAR (50)	COLLATE Latin1_General_CI_AS NULL,
    [strSplitType]					NVARCHAR (50)	COLLATE Latin1_General_CI_AS NULL,
    [strFieldMapFileName]			NVARCHAR (100)	COLLATE Latin1_General_CI_AS NULL,
    [strDirections]					NVARCHAR (30)	COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]				INT				NOT NULL,
    CONSTRAINT [PK_tblEMEntityFarmDetail] PRIMARY KEY CLUSTERED ([intFarmDetailId] ASC),
	CONSTRAINT [FK_tblEMEntityFarm_tblEMEntityFarm] FOREIGN KEY ([intFarmFieldId]) REFERENCES [dbo].tblEMEntityFarm ([intFarmFieldId]) ON DELETE CASCADE,
	CONSTRAINT [UK_tblEMEntityFarmDetail_strFieldNumber] UNIQUE NONCLUSTERED ([strFieldNumber] ASC,[intFarmFieldId] ASC)	

)
