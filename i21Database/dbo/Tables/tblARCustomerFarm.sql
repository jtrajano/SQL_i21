CREATE TABLE [dbo].[tblARCustomerFarm] (
    [intFarmFieldId]      INT            IDENTITY (1, 1) NOT NULL,
    [intEntityId]         INT            NOT NULL,
    [strFarmId]           NVARCHAR (10)  COLLATE Latin1_General_CI_AS NULL,
    [strFarmDescription]  NVARCHAR (30)  COLLATE Latin1_General_CI_AS NULL,
    [strFieldId]          NVARCHAR (10)  COLLATE Latin1_General_CI_AS NULL,
    [strFieldDescription] NVARCHAR (30)  COLLATE Latin1_General_CI_AS NULL,
    [strDefaultLocation]  NVARCHAR (3)   COLLATE Latin1_General_CI_AS NULL,
    [strAcres]            NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strFSANumber]        NVARCHAR (10)  COLLATE Latin1_General_CI_AS NULL,
    [ysnObsolete]         BIT            NOT NULL DEFAULT ((0)),
    [strLatitudeDegrees]  NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strLatitudeNS]       NVARCHAR (10)  COLLATE Latin1_General_CI_AS NULL,
    [strLongitudeDegrees] NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strLongitudeEW]      NVARCHAR (10)  COLLATE Latin1_General_CI_AS NULL,
    [strComments]         NVARCHAR (30)  COLLATE Latin1_General_CI_AS NULL,
    [strSplitNumber]      NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strSplitType]        NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strFieldMapFileName] NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strDirections]       NVARCHAR (30)  COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]    INT            NOT NULL,
    CONSTRAINT [PK_tblARCustomerFarm] PRIMARY KEY CLUSTERED ([intFarmFieldId] ASC)
);

