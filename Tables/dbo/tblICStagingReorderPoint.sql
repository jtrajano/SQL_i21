CREATE TABLE [dbo].[tblICStagingReorderPoint]
(
	  intStagingReorderPointId INT NOT NULL IDENTITY(1, 1)
	, intItemId INT NOT NULL
    , intItemLocationId INT NOT NULL
    , intLocationId INT NOT NULL
    , strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
    , strCategoryCode NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
    , strCommodityCode NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
    , strEntityVendor NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
    , strLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
    , dblLastCost NUMERIC(38, 20) NULL
    , dblReorderPoint NUMERIC(38, 20) NULL
    , dblSuggestedQty NUMERIC(38, 20) NULL
    , dblNearingReorderBy NUMERIC(38, 20) NULL
    , dblLeadTime NUMERIC(38, 20) NULL
    , dblMinOrder NUMERIC(38, 20) NULL,
	CONSTRAINT PK_tblICStagingReorderPoint_intStagingReorderPointId PRIMARY KEY(intStagingReorderPointId)
)