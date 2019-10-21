﻿CREATE VIEW [dbo].[vyuETBEExportTax]  
AS 
SELECT 
	 code = A.intTaxGroupId
	 ,name = strTaxGroup
	 ,header = '' COLLATE Latin1_General_CI_AS
	 ,category01 = (SELECT TOP 1 X.intTaxCodeId FROM (SELECT Z.intTaxCodeId ,Z.intTaxGroupId ,intRow = ROW_NUMBER() OVER (PARTITION BY intTaxGroupId ORDER BY intTaxGroupCodeId)
										FROM tblSMTaxGroupCode Z) X WHERE X.intTaxGroupId = A.intTaxGroupId AND X.intRow = 1)
	 ,category02 = (SELECT TOP 1 X.intTaxCodeId FROM (SELECT Z.intTaxCodeId ,Z.intTaxGroupId ,intRow = ROW_NUMBER() OVER (PARTITION BY intTaxGroupId ORDER BY intTaxGroupCodeId)
										FROM tblSMTaxGroupCode Z) X WHERE X.intTaxGroupId = A.intTaxGroupId AND X.intRow = 2)
	 ,category03 = (SELECT TOP 1 X.intTaxCodeId FROM (SELECT Z.intTaxCodeId ,Z.intTaxGroupId ,intRow = ROW_NUMBER() OVER (PARTITION BY intTaxGroupId ORDER BY intTaxGroupCodeId)
										FROM tblSMTaxGroupCode Z) X WHERE X.intTaxGroupId = A.intTaxGroupId AND X.intRow = 3)
	 ,category04 = (SELECT TOP 1 X.intTaxCodeId FROM (SELECT Z.intTaxCodeId ,Z.intTaxGroupId ,intRow = ROW_NUMBER() OVER (PARTITION BY intTaxGroupId ORDER BY intTaxGroupCodeId)
										FROM tblSMTaxGroupCode Z) X WHERE X.intTaxGroupId = A.intTaxGroupId AND X.intRow = 4)
	 ,category05 = (SELECT TOP 1 X.intTaxCodeId FROM (SELECT Z.intTaxCodeId ,Z.intTaxGroupId ,intRow = ROW_NUMBER() OVER (PARTITION BY intTaxGroupId ORDER BY intTaxGroupCodeId)
										FROM tblSMTaxGroupCode Z) X WHERE X.intTaxGroupId = A.intTaxGroupId AND X.intRow = 5)
	 ,category06 = (SELECT TOP 1 X.intTaxCodeId FROM (SELECT Z.intTaxCodeId ,Z.intTaxGroupId ,intRow = ROW_NUMBER() OVER (PARTITION BY intTaxGroupId ORDER BY intTaxGroupCodeId)
										FROM tblSMTaxGroupCode Z) X WHERE X.intTaxGroupId = A.intTaxGroupId AND X.intRow = 6)
	 ,category07 = (SELECT TOP 1 X.intTaxCodeId FROM (SELECT Z.intTaxCodeId ,Z.intTaxGroupId ,intRow = ROW_NUMBER() OVER (PARTITION BY intTaxGroupId ORDER BY intTaxGroupCodeId)
										FROM tblSMTaxGroupCode Z) X WHERE X.intTaxGroupId = A.intTaxGroupId AND X.intRow = 7)
	 ,category08 = (SELECT TOP 1 X.intTaxCodeId FROM (SELECT Z.intTaxCodeId ,Z.intTaxGroupId ,intRow = ROW_NUMBER() OVER (PARTITION BY intTaxGroupId ORDER BY intTaxGroupCodeId)
										FROM tblSMTaxGroupCode Z) X WHERE X.intTaxGroupId = A.intTaxGroupId AND X.intRow = 8)
	 ,category09 = (SELECT TOP 1 X.intTaxCodeId FROM (SELECT Z.intTaxCodeId ,Z.intTaxGroupId ,intRow = ROW_NUMBER() OVER (PARTITION BY intTaxGroupId ORDER BY intTaxGroupCodeId)
										FROM tblSMTaxGroupCode Z) X WHERE X.intTaxGroupId = A.intTaxGroupId AND X.intRow = 9)
	 ,category10 = (SELECT TOP 1 X.intTaxCodeId FROM (SELECT Z.intTaxCodeId ,Z.intTaxGroupId ,intRow = ROW_NUMBER() OVER (PARTITION BY intTaxGroupId ORDER BY intTaxGroupCodeId)
										FROM tblSMTaxGroupCode Z) X WHERE X.intTaxGroupId = A.intTaxGroupId AND X.intRow = 10)
	 ,category11 = (SELECT TOP 1 X.intTaxCodeId FROM (SELECT Z.intTaxCodeId ,Z.intTaxGroupId ,intRow = ROW_NUMBER() OVER (PARTITION BY intTaxGroupId ORDER BY intTaxGroupCodeId)
										FROM tblSMTaxGroupCode Z) X WHERE X.intTaxGroupId = A.intTaxGroupId AND X.intRow = 11)
	 ,category12 = (SELECT TOP 1 X.intTaxCodeId FROM (SELECT Z.intTaxCodeId ,Z.intTaxGroupId ,intRow = ROW_NUMBER() OVER (PARTITION BY intTaxGroupId ORDER BY intTaxGroupCodeId)
										FROM tblSMTaxGroupCode Z) X WHERE X.intTaxGroupId = A.intTaxGroupId AND X.intRow = 12)
	 ,category13 = (SELECT TOP 1 X.intTaxCodeId FROM (SELECT Z.intTaxCodeId ,Z.intTaxGroupId ,intRow = ROW_NUMBER() OVER (PARTITION BY intTaxGroupId ORDER BY intTaxGroupCodeId)
										FROM tblSMTaxGroupCode Z) X WHERE X.intTaxGroupId = A.intTaxGroupId AND X.intRow = 13)
	 ,category14 = (SELECT TOP 1 X.intTaxCodeId FROM (SELECT Z.intTaxCodeId ,Z.intTaxGroupId ,intRow = ROW_NUMBER() OVER (PARTITION BY intTaxGroupId ORDER BY intTaxGroupCodeId)
										FROM tblSMTaxGroupCode Z) X WHERE X.intTaxGroupId = A.intTaxGroupId AND X.intRow = 14)
	 ,category15 = (SELECT TOP 1 X.intTaxCodeId FROM (SELECT Z.intTaxCodeId ,Z.intTaxGroupId ,intRow = ROW_NUMBER() OVER (PARTITION BY intTaxGroupId ORDER BY intTaxGroupCodeId)
										FROM tblSMTaxGroupCode Z) X WHERE X.intTaxGroupId = A.intTaxGroupId AND X.intRow = 15)
	 ,category16 = (SELECT TOP 1 X.intTaxCodeId FROM (SELECT Z.intTaxCodeId ,Z.intTaxGroupId ,intRow = ROW_NUMBER() OVER (PARTITION BY intTaxGroupId ORDER BY intTaxGroupCodeId)
										FROM tblSMTaxGroupCode Z) X WHERE X.intTaxGroupId = A.intTaxGroupId AND X.intRow = 16)
	 ,category17 = (SELECT TOP 1 X.intTaxCodeId FROM (SELECT Z.intTaxCodeId ,Z.intTaxGroupId ,intRow = ROW_NUMBER() OVER (PARTITION BY intTaxGroupId ORDER BY intTaxGroupCodeId)
										FROM tblSMTaxGroupCode Z) X WHERE X.intTaxGroupId = A.intTaxGroupId AND X.intRow = 17)
	 ,category18 = (SELECT TOP 1 X.intTaxCodeId FROM (SELECT Z.intTaxCodeId ,Z.intTaxGroupId ,intRow = ROW_NUMBER() OVER (PARTITION BY intTaxGroupId ORDER BY intTaxGroupCodeId)
										FROM tblSMTaxGroupCode Z) X WHERE X.intTaxGroupId = A.intTaxGroupId AND X.intRow = 18)
	 ,category19 = (SELECT TOP 1 X.intTaxCodeId FROM (SELECT Z.intTaxCodeId ,Z.intTaxGroupId ,intRow = ROW_NUMBER() OVER (PARTITION BY intTaxGroupId ORDER BY intTaxGroupCodeId)
										FROM tblSMTaxGroupCode Z) X WHERE X.intTaxGroupId = A.intTaxGroupId AND X.intRow = 19)
	 ,category20 = (SELECT TOP 1 X.intTaxCodeId FROM (SELECT Z.intTaxCodeId ,Z.intTaxGroupId ,intRow = ROW_NUMBER() OVER (PARTITION BY intTaxGroupId ORDER BY intTaxGroupCodeId)
										FROM tblSMTaxGroupCode Z) X WHERE X.intTaxGroupId = A.intTaxGroupId AND X.intRow = 20)
	 ,category21 = (SELECT TOP 1 X.intTaxCodeId FROM (SELECT Z.intTaxCodeId ,Z.intTaxGroupId ,intRow = ROW_NUMBER() OVER (PARTITION BY intTaxGroupId ORDER BY intTaxGroupCodeId)
										FROM tblSMTaxGroupCode Z) X WHERE X.intTaxGroupId = A.intTaxGroupId AND X.intRow = 21)
	 ,category22 = (SELECT TOP 1 X.intTaxCodeId FROM (SELECT Z.intTaxCodeId ,Z.intTaxGroupId ,intRow = ROW_NUMBER() OVER (PARTITION BY intTaxGroupId ORDER BY intTaxGroupCodeId)
										FROM tblSMTaxGroupCode Z) X WHERE X.intTaxGroupId = A.intTaxGroupId AND X.intRow = 22)
	 ,category23 = (SELECT TOP 1 X.intTaxCodeId FROM (SELECT Z.intTaxCodeId ,Z.intTaxGroupId ,intRow = ROW_NUMBER() OVER (PARTITION BY intTaxGroupId ORDER BY intTaxGroupCodeId)
										FROM tblSMTaxGroupCode Z) X WHERE X.intTaxGroupId = A.intTaxGroupId AND X.intRow = 23)
	 ,category24 = (SELECT TOP 1 X.intTaxCodeId FROM (SELECT Z.intTaxCodeId ,Z.intTaxGroupId ,intRow = ROW_NUMBER() OVER (PARTITION BY intTaxGroupId ORDER BY intTaxGroupCodeId)
										FROM tblSMTaxGroupCode Z) X WHERE X.intTaxGroupId = A.intTaxGroupId AND X.intRow = 24)
	 ,category25 = (SELECT TOP 1 X.intTaxCodeId FROM (SELECT Z.intTaxCodeId ,Z.intTaxGroupId ,intRow = ROW_NUMBER() OVER (PARTITION BY intTaxGroupId ORDER BY intTaxGroupCodeId)
										FROM tblSMTaxGroupCode Z) X WHERE X.intTaxGroupId = A.intTaxGroupId AND X.intRow = 25)
	 ,category26 = (SELECT TOP 1 X.intTaxCodeId FROM (SELECT Z.intTaxCodeId ,Z.intTaxGroupId ,intRow = ROW_NUMBER() OVER (PARTITION BY intTaxGroupId ORDER BY intTaxGroupCodeId)
										FROM tblSMTaxGroupCode Z) X WHERE X.intTaxGroupId = A.intTaxGroupId AND X.intRow = 26)
	 ,category27 = (SELECT TOP 1 X.intTaxCodeId FROM (SELECT Z.intTaxCodeId ,Z.intTaxGroupId ,intRow = ROW_NUMBER() OVER (PARTITION BY intTaxGroupId ORDER BY intTaxGroupCodeId)
										FROM tblSMTaxGroupCode Z) X WHERE X.intTaxGroupId = A.intTaxGroupId AND X.intRow = 27)
	 ,category28 = (SELECT TOP 1 X.intTaxCodeId FROM (SELECT Z.intTaxCodeId ,Z.intTaxGroupId ,intRow = ROW_NUMBER() OVER (PARTITION BY intTaxGroupId ORDER BY intTaxGroupCodeId)
										FROM tblSMTaxGroupCode Z) X WHERE X.intTaxGroupId = A.intTaxGroupId AND X.intRow = 28)
	 ,category29 = (SELECT TOP 1 X.intTaxCodeId FROM (SELECT Z.intTaxCodeId ,Z.intTaxGroupId ,intRow = ROW_NUMBER() OVER (PARTITION BY intTaxGroupId ORDER BY intTaxGroupCodeId)
										FROM tblSMTaxGroupCode Z) X WHERE X.intTaxGroupId = A.intTaxGroupId AND X.intRow = 29)
	 ,category30 = (SELECT TOP 1 X.intTaxCodeId FROM (SELECT Z.intTaxCodeId ,Z.intTaxGroupId ,intRow = ROW_NUMBER() OVER (PARTITION BY intTaxGroupId ORDER BY intTaxGroupCodeId)
										FROM tblSMTaxGroupCode Z) X WHERE X.intTaxGroupId = A.intTaxGroupId AND X.intRow = 30)
FROM tblSMTaxGroup A

GO