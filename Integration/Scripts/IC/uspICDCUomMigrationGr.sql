SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


Create PROCEDURE [dbo].[uspICDCUomMigrationGr]

AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

--RUN THIS AFTER UOM MIGRATION FOR AG IS DONE. THIS SCRIPT MAY FAIL IF AG CONVERSION HAS ALREADY IMPORTED THESE UOMS

----======================================STEP 1 ==============================
--import unit of measures from commodity setup. Commodity and Ag do not have a UOM master. 
--Commodity does not have a UOM for conversion. It is assumed to be lb. So insert an lb uom in i21
insert into tblICUnitMeasure (strUnitMeasure, strSymbol, strUnitType, intConcurrencyId)
values ('lb', 'lb', 'Weight',1)

--import units of mesaure from the commodity setup. USe distinct to get unit uoms
insert into tblICUnitMeasure (strUnitMeasure, strSymbol, strUnitType, intConcurrencyId)
select distinct gacom_un_desc, gacom_un_desc, case gacom_un_desc when 'BU' then 'Volume' End, 1 from gacommst
