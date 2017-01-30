CREATE TABLE [dbo].[tblRKStgBlendDemand]
(
       [intStgBlendDemandId] INT NOT NULL IDENTITY,
       [intConcurrencyId] INT NOT NULL,  
       [intItemId] int NOT NULL,
       [strItemName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,   
       [intSubLocationId] int NOT NULL,
       [strSubLocation] NVARCHAR(50) COLLATE Latin1_General_CI_AS  NOT NULL,
       [dblQuantity] numeric(38,20) NOT NULL,
	   [dblTotalDemand] numeric(38,20), 
       [intUOMId] int NOT NULL,
       [strUOM] NVARCHAR(50)  COLLATE Latin1_General_CI_AS  NOT NULL, 
	   [intYear] INT,
	   [intWeek] INT,
       [strPeriod] NVARCHAR(20) COLLATE Latin1_General_CI_AS  NOT NULL, -- '2016 7'      

       CONSTRAINT [PK_tblRKStgBlendDemand_intStgBlendDemandId] PRIMARY KEY ([intStgBlendDemandId])
)
