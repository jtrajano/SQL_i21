CREATE TABLE [dbo].[tblApiSchemaCommodityContract] (
      [guiApiUniqueId] UNIQUEIDENTIFIER NULL
    , [intRowNumber] INT NULL

    , intKey INT IDENTITY(1, 1) PRIMARY KEY NOT NULL
    --- The rest of the fields that are specific to the schema
    , strLocationName NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
    , strContractType NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
    , strEntityNo NVARCHAR(200) COLLATE Latin1_General_CI_AS NOT NULL
    , dtmContractDate DATETIME NOT NULL
    , dblQuantity NUMERIC(38, 20) NOT NULL
    , strQuantityUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
    , strItem NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
    , intSequence INT NULL
    , strCommodity NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
    , strContractNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
    , strSalesperson NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
    , intCropYear INT NULL
    , intPosition INT NULL
    , strContractStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
    , dtmStartDate DATETIME NULL
    , dtmEndDate DATETIME NULL
    , strPricingType NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
    , strMarketName NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
    , strMonth NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
    , intYear INT NULL
    , dblFutures NUMERIC(38, 20) NULL
    , dblBasis NUMERIC(38, 20) NULL
    , dblCashPrice NUMERIC(18, 16) NULL
    , strCurrency NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
    , strPriceUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
    , strRemark NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
    , dtmM2MDate DATETIME NULL
);