CREATE TABLE [dbo].[tblRKStgBlendDemand]
(
       [intStgBlendDemandId] INT NOT NULL IDENTITY,
       [intConcurrencyId] INT NULL,  
       [intItemId] int NULL,
       [strItemName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,   
       [intSubLocationId] int NULL,
       [strSubLocation] NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
       [dblQuantity] numeric(38,20) NULL,
	   [dblTotalDemand] numeric(38,20), 
       [intUOMId] int NULL,
       [strUOM] NVARCHAR(50)  COLLATE Latin1_General_CI_AS  NULL, 
	   [intYear] INT,
	   [intWeek] INT,
       [strPeriod] NVARCHAR(20) COLLATE Latin1_General_CI_AS  NULL,
	   [dtmNeedDate] DATE NULL,
       [dtmImportDate] DATE NULL DEFAULT GETDATE(), 
    CONSTRAINT [PK_tblRKStgBlendDemand_intStgBlendDemandId] PRIMARY KEY ([intStgBlendDemandId])
)
