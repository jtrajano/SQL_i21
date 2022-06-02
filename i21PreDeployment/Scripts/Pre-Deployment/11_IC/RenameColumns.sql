﻿
-- Rename tblICItem.intHazmatMessage to tblICItem.intHazmatTag
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblICItem]') AND type in (N'U')) 
BEGIN 
    IF	NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intHazmatTag' AND OBJECT_ID = OBJECT_ID(N'tblICItem')) 
		AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intHazmatMessage' AND OBJECT_ID = OBJECT_ID(N'tblICItem'))
    BEGIN
        EXEC sp_rename 'tblICItem.intHazmatMessage', 'intHazmatTag' , 'COLUMN'
    END
END 
GO

-- Rename tblICInventoryReceipt.strInternalComments to tblICItem.strRemarks
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblICInventoryReceipt]') AND type in (N'U')) 
BEGIN 
    IF	NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strRemarks' AND OBJECT_ID = OBJECT_ID(N'tblICInventoryReceipt')) 
		AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strInternalComments' AND OBJECT_ID = OBJECT_ID(N'tblICInventoryReceipt'))
    BEGIN
        EXEC sp_rename 'tblICInventoryReceipt.strInternalComments', 'strRemarks' , 'COLUMN'
    END
END 
GO

-- Rename tblICItemUOM.ysnStockUOM to tblICItemUOM.ysnSubUnit
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblICItemUOM]') AND type in (N'U')) 
BEGIN 
    IF	NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'ysnSubUnit' AND OBJECT_ID = OBJECT_ID(N'tblICItemUOM')) 
		AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'ysnStockUOM' AND OBJECT_ID = OBJECT_ID(N'tblICItemUOM'))
    BEGIN
        EXEC sp_rename 'tblICItemUOM.ysnStockUOM', 'ysnSubUnit' , 'COLUMN'
    END
END 
GO

-- Rename tblICCommodityUnitMeasure.ysnStockUOM to tblICCommodityUnitMeasure.ysnSubUnit
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblICCommodityUnitMeasure]') AND type in (N'U')) 
BEGIN 
    IF	NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'ysnSubUnit' AND OBJECT_ID = OBJECT_ID(N'tblICCommodityUnitMeasure')) 
		AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'ysnStockUOM' AND OBJECT_ID = OBJECT_ID(N'tblICCommodityUnitMeasure'))
    BEGIN
        EXEC sp_rename 'tblICCommodityUnitMeasure.ysnStockUOM', 'ysnSubUnit' , 'COLUMN'
    END
END 
GO
