CREATE PROCEDURE [dbo].[uspAPRptOpenClearingSummary]
	@xmlParam NVARCHAR(MAX) = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @query NVARCHAR(MAX), 
		@oldQuery NVARCHAR(MAX),
		@cteQuery NVARCHAR(MAX),
	    @innerQuery NVARCHAR(MAX), 
		@innerQueryFilter NVARCHAR(MAX) = '',
		@filter NVARCHAR(MAX) = '';
DECLARE @dateFrom DATETIME = NULL;
DECLARE @dateTo DATETIME = NULL;
DECLARE @total NUMERIC(18,6), 
		@amountDue NUMERIC(18,6), 
		@amountPad NUMERIC(18,6);
DECLARE @count INT = 0;
DECLARE @fieldname NVARCHAR(50)
DECLARE @condition NVARCHAR(20)     
DECLARE @id INT 
DECLARE @from NVARCHAR(50)
DECLARE @to NVARCHAR(50)
DECLARE @join NVARCHAR(10)
DECLARE @begingroup NVARCHAR(50)
DECLARE @endgroup NVARCHAR(50)
DECLARE @datatype NVARCHAR(50)
DECLARE @strAccountId NVARCHAR(50)  
DECLARE @strAccountIdTo NVARCHAR(50)  

	-- Sanitize the @xmlParam 
IF LTRIM(RTRIM(@xmlParam)) = '' 
BEGIN
--SET @xmlParam = NULL 
--Add this so that XtraReports have fields to get
	SELECT 
		NULL AS dtmDate,
		NULL AS strVendorId,
		0 AS intEntityVendorId,
		NULL AS strCompanyName,
		NULL AS strCompanyAddress,
		NULL AS strVendorIdName,
		0 AS dbl1,
		0 AS dbl30,
		0 AS dbl60,
		0 AS dbl90,
    0 AS dblTotal,
		NULL as dtmCurrentDate
END

DECLARE @xmlDocumentId AS INT;
-- Create a table variable to hold the XML data. 		
DECLARE @temp_xml_table TABLE (
	id INT IDENTITY(1,1)
	,[fieldname] NVARCHAR(50)
	,condition NVARCHAR(20)      
	,[from] NVARCHAR(50)
	,[to] NVARCHAR(50)
	,[join] NVARCHAR(10)
	,[begingroup] NVARCHAR(50)
	,[endgroup] NVARCHAR(50)
	,[datatype] NVARCHAR(50)
)
-- Prepare the XML 
EXEC sp_xml_preparedocument @xmlDocumentId output, @xmlParam

-- Insert the XML to the xml table. 		
INSERT INTO @temp_xml_table
SELECT *
FROM OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2)
WITH (
	[fieldname] nvarchar(50)
	, condition nvarchar(20)
	, [from] nvarchar(50)
	, [to] nvarchar(50)
	, [join] nvarchar(10)
	, [begingroup] nvarchar(50)
	, [endgroup] nvarchar(50)
	, [datatype] nvarchar(50)
)

--select * from @temp_xml_table
--CREATE date filter
SELECT @dateFrom = [from], @dateTo = [to],@condition = condition FROM @temp_xml_table WHERE [fieldname] = 'dtmDate';
SET @innerQuery = 
		'SELECT 
			intInventoryReceiptId
			,intBillId
			,strVendorIdName
			,dblTotal
			,dblAmountDue
			,dblVoucherAmount
			,dblDiscount
			,dblInterest
			,dtmDate
			,dtmDueDate
			,strContainer
			,dblVoucherQty
			,dblReceiptQty
		FROM dbo.vyuAPClearables'

IF @dateFrom IS NOT NULL
BEGIN	
	IF @condition = 'Equal To'
	BEGIN 
		SET @innerQueryFilter = @innerQueryFilter + ' WHERE DATEADD(dd, DATEDIFF(dd, 0,dtmDate), 0) = ''' + CONVERT(VARCHAR(10), @dateFrom, 110) + ''''
	END
    ELSE 
	BEGIN 
		SET @innerQueryFilter = @innerQueryFilter + ' WHERE DATEADD(dd, DATEDIFF(dd, 0,dtmDate), 0) BETWEEN ''' + CONVERT(VARCHAR(10), @dateFrom, 110) + ''' AND '''  + CONVERT(VARCHAR(10), @dateTo, 110) + ''''	
	END  
END
ELSE
BEGIN
	SET @dateFrom = CONVERT(VARCHAR(10), '1/1/1900', 110)
	SET @dateTo = GETDATE();
END
DELETE FROM @temp_xml_table WHERE [fieldname] = 'dtmDate'
DELETE FROM @temp_xml_table  where [condition] = 'Dummy'

SELECT @strAccountId = [from], @strAccountIdTo = [to], @condition = condition FROM @temp_xml_table WHERE [fieldname] = 'strAccountId';  
IF @strAccountId IS NOT NULL
BEGIN
  DECLARE @intAccountId NVARCHAR(20);
  DECLARE @intAccountIdTo NVARCHAR(20);
  SELECT @intAccountId = CAST(intAccountId AS NVARCHAR) FROM tblGLAccount WHERE strAccountId = @strAccountId;
  SELECT @intAccountIdTo = CAST(intAccountId AS NVARCHAR) FROM tblGLAccount WHERE strAccountId = @strAccountIdTo;
  IF @condition = 'Equal To'  
  BEGIN   
    SET @innerQueryFilter = @innerQueryFilter + CASE WHEN NULLIF(@innerQueryFilter,'') IS NOT NULL THEN ' AND intAccountId = ' + @intAccountId + ''   
    ELSE ' WHERE intAccountId = ' + @intAccountId + '' END   
  END
  ELSE
  BEGIN
    SET @innerQueryFilter = @innerQueryFilter + CASE WHEN NULLIF(@innerQueryFilter,'') IS NOT NULL   
            THEN ' AND intAccountId BETWEEN ' + @intAccountId + ' AND '  + @intAccountIdTo + ''   
          ELSE ' WHERE intAccountId BETWEEN ' + @intAccountId + ' AND '  + @intAccountIdTo + ''   
          END
  END
END
DELETE FROM @temp_xml_table WHERE [fieldname] = 'strAccountId'  

WHILE EXISTS(SELECT 1 FROM @temp_xml_table)
BEGIN
	SELECT @id = id, @fieldname = [fieldname], @condition = [condition], @from = [from], @to = [to], @join = [join], @datatype = [datatype] FROM @temp_xml_table
	SET @filter = @filter + ' ' + dbo.fnAPCreateFilter(@fieldname, @condition, @from, @to, @join, null, null, @datatype)
	DELETE FROM @temp_xml_table WHERE id = @id
	IF EXISTS(SELECT 1 FROM @temp_xml_table)
	BEGIN
		SET @filter = @filter + ' AND '
	END
END

IF NULLIF(@innerQueryFilter,'') IS NOT NULL  
BEGIN  
SET @cteQuery = N';WITH forClearing  
    AS  
    (  
     SELECT  
      dtmDate  
      ,intEntityVendorId  
      ,strTransactionNumber  
      ,intInventoryReceiptId  
      ,intInventoryReceiptItemId  
      ,intItemId  
      ,intBillId  
      ,strBillId  
      ,intBillDetailId  
      ,dblVoucherTotal  
      ,dblVoucherQty  
      ,dblReceiptTotal  
      ,dblReceiptQty  
      ,intLocationId  
      ,strLocationName  
     FROM vyuAPReceiptClearing  
     ' + @innerQueryFilter + '  
    ),  
    chargesForClearing  
    AS  
    (  
     SELECT  
      dtmDate  
      ,intEntityVendorId  
      ,strTransactionNumber  
      ,intInventoryReceiptId  
      ,intInventoryReceiptChargeId  
      ,intItemId  
      ,intBillId  
      ,strBillId  
      ,intBillDetailId  
      ,dblVoucherTotal  
      ,dblVoucherQty  
      ,dblReceiptChargeTotal  
      ,dblReceiptChargeQty  
      ,intLocationId  
      ,strLocationName  
     FROM vyuAPReceiptChargeClearing  
     ' + @innerQueryFilter + '  
    ),  
    shipmentChargesForClearing  
    AS  
    (  
     SELECT  
      dtmDate  
      ,intEntityVendorId  
      ,strTransactionNumber  
      ,intInventoryShipmentId  
      ,intInventoryShipmentChargeId  
      ,intItemId  
      ,intBillId  
      ,strBillId  
      ,intBillDetailId  
      ,dblVoucherTotal  
      ,dblVoucherQty  
      ,dblReceiptChargeTotal  
      ,dblReceiptChargeQty  
      ,intLocationId  
      ,strLocationName  
     FROM vyuAPShipmentChargeClearing  
     ' + @innerQueryFilter + '  
    ),  
    loadForClearing  
    AS  
    (  
	SELECT  
      dtmDate  
      ,intEntityVendorId  
      ,strTransactionNumber  
      ,intLoadId  
      ,intLoadDetailId  
      ,intItemId  
      ,intBillId  
      ,strBillId  
      ,intBillDetailId  
      ,dblVoucherTotal  
      ,dblVoucherQty  
      ,dblLoadDetailTotal  
      ,dblLoadDetailQty  
      ,intLocationId  
      ,strLocationName  
     FROM vyuAPLoadClearing  
     ' + @innerQueryFilter + '  
    ),  
    loadCostForClearing  
    AS  
    (  
	SELECT  
      dtmDate  
      ,intEntityVendorId  
      ,strTransactionNumber  
      ,intLoadId  
      ,intLoadDetailId  
      ,intItemId  
      ,intBillId  
      ,strBillId  
      ,intBillDetailId  
      ,dblVoucherTotal  
      ,dblVoucherQty  
      ,dblLoadCostDetailTotal  
      ,dblLoadCostDetailQty  
      ,intLocationId  
      ,strLocationName  
     FROM vyuAPLoadCostClearing  
     ' + @innerQueryFilter + '  
    ),  
    grainClearing  
    AS  
    (  
	SELECT  
      dtmDate  
      ,intEntityVendorId  
      ,strTransactionNumber  
      ,intSettleStorageId  
      ,intCustomerStorageId  
      ,intItemId  
      ,intBillId  
      ,strBillId  
      ,intBillDetailId  
      ,dblVoucherTotal  
      ,dblVoucherQty  
      ,dblSettleStorageAmount  
      ,dblSettleStorageQty  
      ,intLocationId  
      ,strLocationName  
     FROM vyuAPGrainClearing  
     ' + @innerQueryFilter + '  
    ),  
    patClearing  
    AS  
    (  
	SELECT  
      dtmDate  
      ,intEntityVendorId  
      ,strTransactionNumber  
      ,intRefundId  
      ,intRefundCustomerId  
      ,intItemId  
      ,intBillId  
      ,strBillId  
      ,intBillDetailId  
      ,dblVoucherTotal  
      ,dblVoucherQty  
      ,dblRefundTotal  
      ,dblRefundQty  
      ,intLocationId  
      ,strLocationName  
     FROM vyuAPPatClearing  
     ' + @innerQueryFilter + '  
    )';  
END  
ELSE  
BEGIN  
 SET @cteQuery = N';WITH forClearing  
    AS  
    (  
     SELECT  
      dtmDate  
      ,strTransactionNumber  
      ,intEntityVendorId  
      ,intInventoryReceiptId  
      ,intInventoryReceiptItemId  
      ,intItemId  
      ,intBillId  
      ,strBillId  
      ,intBillDetailId  
      ,dblVoucherTotal  
      ,dblVoucherQty  
      ,dblReceiptTotal  
      ,dblReceiptQty  
      ,intLocationId  
      ,strLocationName  
     FROM vyuAPReceiptClearing  
    ),  
    chargesForClearing  
    AS  
    (  
     SELECT  
      dtmDate  
      ,strTransactionNumber  
      ,intEntityVendorId  
      ,intInventoryReceiptId  
      ,intInventoryReceiptChargeId  
      ,intItemId  
      ,intBillId  
      ,strBillId  
      ,intBillDetailId  
      ,dblVoucherTotal  
      ,dblVoucherQty  
      ,dblReceiptChargeTotal  
      ,dblReceiptChargeQty  
      ,intLocationId  
      ,strLocationName  
     FROM vyuAPReceiptChargeClearing  
    ),  
    shipmentChargesForClearing  
    AS  
    (  
     SELECT  
      dtmDate  
      ,intEntityVendorId  
      ,strTransactionNumber  
      ,intInventoryShipmentId  
      ,intInventoryShipmentChargeId  
      ,intItemId  
      ,intBillId  
      ,strBillId  
      ,intBillDetailId  
      ,dblVoucherTotal  
      ,dblVoucherQty  
      ,dblReceiptChargeTotal  
      ,dblReceiptChargeQty  
      ,intLocationId  
      ,strLocationName  
     FROM vyuAPShipmentChargeClearing  
    ),  
    loadForClearing  
    AS  
    (  
     SELECT  
      dtmDate  
      ,intEntityVendorId  
      ,strTransactionNumber  
      ,intLoadId  
      ,intLoadDetailId  
      ,intItemId  
      ,intBillId  
      ,strBillId  
      ,intBillDetailId  
      ,dblVoucherTotal  
      ,dblVoucherQty  
      ,dblLoadDetailTotal  
      ,dblLoadDetailQty  
      ,intLocationId  
      ,strLocationName  
     FROM vyuAPLoadClearing   
    ),  
    loadCostForClearing  
    AS  
    (  
     SELECT  
      dtmDate  
      ,intEntityVendorId  
      ,strTransactionNumber  
      ,intLoadId  
      ,intLoadDetailId  
      ,intItemId  
      ,intBillId  
      ,strBillId  
      ,intBillDetailId  
      ,dblVoucherTotal  
      ,dblVoucherQty  
      ,dblLoadCostDetailTotal  
      ,dblLoadCostDetailQty  
      ,intLocationId  
      ,strLocationName  
     FROM vyuAPLoadCostClearing   
    ),
    grainClearing
    AS
    (
      SELECT  
      dtmDate  
      ,intEntityVendorId  
      ,strTransactionNumber  
      ,intSettleStorageId  
      ,intCustomerStorageId  
      ,intItemId  
      ,intBillId  
      ,strBillId  
      ,intBillDetailId  
      ,dblVoucherTotal  
      ,dblVoucherQty  
      ,dblSettleStorageAmount  
      ,dblSettleStorageQty  
      ,intLocationId  
      ,strLocationName  
     FROM vyuAPGrainClearing  
    ),
    patClearing
    AS
    (
      SELECT  
      dtmDate  
      ,intEntityVendorId  
      ,strTransactionNumber  
      ,intRefundId  
      ,intRefundCustomerId  
      ,intItemId  
      ,intBillId  
      ,strBillId  
      ,intBillDetailId  
      ,dblVoucherTotal  
      ,dblVoucherQty  
      ,dblRefundTotal  
      ,dblRefundQty  
      ,intLocationId  
      ,strLocationName  
     FROM vyuAPPatClearing 
    )';  
END 

SET @oldQuery = '
	SELECT * FROM (
	SELECT 
		 strVendorIdName
		,(SELECT TOP 1strCompanyName FROM dbo.tblSMCompanySetup) AS strCompanyName
		,(SELECT TOP 1 dbo.[fnAPFormatAddress](NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL) FROM tblSMCompanySetup) as strCompanyAddress
		,SUM(dblCurrent) dblCurrent
		,SUM(dbl1) dbl1
		,SUM(dbl30) dbl30
		,SUM(dbl60) dbl60
		,SUM(dbl90) dbl90
		,SUM(dblTotal) as dblTotal
		,SUM(dblVoucherAmount) dblVoucherAmount
		,SUM(dblAmountDue) as dblAmountDue
		,SUM(dblClearingQty) dblClearingQty
		,GETDATE() as dtmCurrentDate
	FROM (
		SELECT 
		--IR.strVendorId
		--,IR.intInventoryReceiptId
		--,IR.intBillId
		--,IR.strBillId
		--,IR.dtmDate
		tmpAgingSummaryTotal.strContainer
		,ISNULL(tmpAgingSummaryTotal.strVendorIdName,'''') as strVendorIdName 
		,tmpAgingSummaryTotal.dblTotal
		,tmpAgingSummaryTotal.dblVoucherAmount
		,ISNULL(tmpAPOpenClearing.dblClearingAmount,0) as dblAmountDue
		,tmpAgingSummaryTotal.dblClearingQty
		,CASE WHEN tmpAPOpenClearing.dblClearingAmount>=0 
			THEN 0 
			ELSE tmpAPOpenClearing.dblClearingAmount 
		 END AS dblUnappliedAmount
		,CASE WHEN DATEDIFF(dayofyear,r.dtmReceiptDate,GETDATE())<=0 
			THEN 0
			ELSE DATEDIFF(dayofyear,r.dtmReceiptDate,GETDATE()) 
		 END AS intAging
		,CASE WHEN DATEDIFF(dayofyear,r.dtmReceiptDate,GETDATE())<=0 
			THEN tmpAPOpenClearing.dblClearingAmount 
			ELSE 0 
		 END AS dblCurrent,
		 CASE WHEN DATEDIFF(dayofyear,r.dtmReceiptDate,GETDATE())>0 AND DATEDIFF(dayofyear,r.dtmReceiptDate,GETDATE())<=30 
		 	THEN tmpAPOpenClearing.dblClearingAmount 
			ELSE 0 
		 END AS dbl1, 
		 CASE WHEN DATEDIFF(dayofyear,r.dtmReceiptDate,GETDATE())>30 AND DATEDIFF(dayofyear,r.dtmReceiptDate,GETDATE())<=60
		 	THEN tmpAPOpenClearing.dblClearingAmount 
			ELSE 0 
		 END AS dbl30, 
		 CASE WHEN DATEDIFF(dayofyear,r.dtmReceiptDate,GETDATE())>60 AND DATEDIFF(dayofyear,r.dtmReceiptDate,GETDATE())<=90 
		 	THEN tmpAPOpenClearing.dblClearingAmount 
			ELSE 0 
		 END AS dbl60,
		 CASE WHEN DATEDIFF(dayofyear,r.dtmReceiptDate,GETDATE())>90  
			THEN tmpAPOpenClearing.dblClearingAmount ELSE 0 
		 END AS dbl90
		,CASE WHEN DATEDIFF(dayofyear,r.dtmReceiptDate,GETDATE())<=0 THEN ''Current''
				WHEN DATEDIFF(dayofyear,r.dtmReceiptDate,GETDATE())>0 AND DATEDIFF(dayofyear,r.dtmReceiptDate,GETDATE())<=30 THEN ''01 - 30 Days''
				WHEN DATEDIFF(dayofyear,r.dtmReceiptDate,GETDATE())>30 AND DATEDIFF(dayofyear,r.dtmReceiptDate,GETDATE())<=60 THEN ''31 - 60 Days''
				WHEN DATEDIFF(dayofyear,r.dtmReceiptDate,GETDATE())>60 AND DATEDIFF(dayofyear,r.dtmReceiptDate,GETDATE())<=90 THEN ''61 - 90 Days''
				WHEN DATEDIFF(dayofyear,r.dtmReceiptDate,GETDATE())>90 THEN ''Over 90'' 
				ELSE ''Current'' END AS strAge
		FROM  
		(
			SELECT 
		     tmpAPClearables.intInventoryReceiptId
			,strVendorIdName
			,strContainer
			,tmpAPClearables.intBillId
			,SUM(tmpAPClearables.dblTotal) AS dblTotal
			,SUM(tmpAPClearables.dblVoucherAmount) AS dblVoucherAmount
			,SUM(tmpAPClearables.dblAmountDue) AS dblAmountDue,
			(SUM(tmpAPClearables.dblReceiptQty)  -  SUM(tmpAPClearables.dblVoucherQty)) AS dblClearingQty
			FROM (' 
					+ @innerQuery +
				') tmpAPClearables
			GROUP BY intInventoryReceiptId, intBillId , strVendorIdName,strContainer
		) AS tmpAgingSummaryTotal
		LEFT JOIN dbo.tblAPBill A
			ON A.intBillId = tmpAgingSummaryTotal.intBillId
		WHERE tmpAgingSummaryTotal.dblClearingQty != 0
) SubQuery
	GROUP BY 
		--strVendorId
		strVendorIdName
		
	) MainQuery
'

SET @query = @cteQuery + N'  
SELECT 
	TOP 100 PERCENT MainQuery.*
	,GETDATE() as dtmCurrentDate  
	,dbo.[fnAPFormatAddress](NULL, NULL, NULL, compSetup.strAddress, compSetup.strCity, compSetup.strState, compSetup.strZip, compSetup.strCountry, NULL) AS strCompanyAddress  
	,compSetup.strCompanyName  
FROM (
SELECT 
	SUM(resultData.dbl1) AS dbl1
	,SUM(resultData.dbl30) AS dbl30
	,SUM(resultData.dbl60) AS dbl60
	,SUM(resultData.dbl90) AS dbl90
  ,SUM(resultData.dbl1 + resultData.dbl30 + resultData.dbl60 + resultData.dbl90) AS dblTotal
	,dbo.fnTrim(ISNULL(vendor.strVendorId, entity.strEntityNo) + '' - '' + isnull(entity.strName,'''')) as strVendorIdName 
FROM (   
 SELECT  
 	tmpAPOpenClearing.intEntityVendorId
  	-- ,CASE WHEN DATEDIFF(dayofyear,r.dtmReceiptDate,GETDATE())<=0   
   	-- 	THEN 0  
  	-- ELSE ISNULL(DATEDIFF(dayofyear,r.dtmReceiptDate,GETDATE()),0) END AS intAging  
	,CASE WHEN DATEDIFF(dayofyear,r.dtmReceiptDate,GETDATE())>=0 AND DATEDIFF(dayofyear,r.dtmReceiptDate,GETDATE())<=30 
		THEN SUM(tmpAPOpenClearing.dblClearingAmount)
		ELSE 0 
	END AS dbl1, 
	CASE WHEN DATEDIFF(dayofyear,r.dtmReceiptDate,GETDATE())>30 AND DATEDIFF(dayofyear,r.dtmReceiptDate,GETDATE())<=60
		THEN SUM(tmpAPOpenClearing.dblClearingAmount)
		ELSE 0 
	END AS dbl30, 
	CASE WHEN DATEDIFF(dayofyear,r.dtmReceiptDate,GETDATE())>60 AND DATEDIFF(dayofyear,r.dtmReceiptDate,GETDATE())<=90 
		THEN SUM(tmpAPOpenClearing.dblClearingAmount)
		ELSE 0 
	END AS dbl60,
	CASE WHEN DATEDIFF(dayofyear,r.dtmReceiptDate,GETDATE())>90  
		THEN SUM(tmpAPOpenClearing.dblClearingAmount) ELSE 0 
	END AS dbl90
	-- ,CASE WHEN DATEDIFF(dayofyear,r.dtmReceiptDate,GETDATE())<=0 THEN ''Current''
	-- 		WHEN DATEDIFF(dayofyear,r.dtmReceiptDate,GETDATE())>0 AND DATEDIFF(dayofyear,r.dtmReceiptDate,GETDATE())<=30 THEN ''01 - 30 Days''
	-- 		WHEN DATEDIFF(dayofyear,r.dtmReceiptDate,GETDATE())>30 AND DATEDIFF(dayofyear,r.dtmReceiptDate,GETDATE())<=60 THEN ''31 - 60 Days''
	-- 		WHEN DATEDIFF(dayofyear,r.dtmReceiptDate,GETDATE())>60 AND DATEDIFF(dayofyear,r.dtmReceiptDate,GETDATE())<=90 THEN ''61 - 90 Days''
	-- 		WHEN DATEDIFF(dayofyear,r.dtmReceiptDate,GETDATE())>90 THEN ''Over 90'' 
	-- 		ELSE ''Current'' END AS strAge
FROM    
 (  
  SELECT  
   B.intEntityVendorId  
   ,B.intInventoryReceiptItemId
   ,SUM(B.dblReceiptQty)  -  SUM(B.dblVoucherQty) AS dblClearingQty  
   ,SUM(B.dblReceiptTotal)  -  SUM(B.dblVoucherTotal) AS dblClearingAmount  
  FROM forClearing B  
  GROUP BY   
   intEntityVendorId  
   ,intInventoryReceiptItemId
 ) tmpAPOpenClearing  
  -- ON A.intInventoryReceiptItemId = tmpAPOpenClearing.intInventoryReceiptItemId  
 INNER JOIN tblICInventoryReceiptItem ri  
  ON tmpAPOpenClearing.intInventoryReceiptItemId = ri.intInventoryReceiptItemId  
 INNER JOIN tblICInventoryReceipt r  
  ON r.intInventoryReceiptId = ri.intInventoryReceiptId  
  WHERE (tmpAPOpenClearing.dblClearingQty != 0 OR tmpAPOpenClearing.dblClearingAmount != 0 )
 GROUP BY r.dtmReceiptDate, tmpAPOpenClearing.intEntityVendorId
 UNION ALL  
 --CHARGES  
 SELECT  
	tmpAPOpenClearing.intEntityVendorId,
   CASE WHEN DATEDIFF(dayofyear,r.dtmReceiptDate,GETDATE())>=0 AND DATEDIFF(dayofyear,r.dtmReceiptDate,GETDATE())<=30 
		THEN SUM(tmpAPOpenClearing.dblClearingAmount)
		ELSE 0 
	END AS dbl1, 
	CASE WHEN DATEDIFF(dayofyear,r.dtmReceiptDate,GETDATE())>30 AND DATEDIFF(dayofyear,r.dtmReceiptDate,GETDATE())<=60
		THEN SUM(tmpAPOpenClearing.dblClearingAmount) 
		ELSE 0 
	END AS dbl30, 
	CASE WHEN DATEDIFF(dayofyear,r.dtmReceiptDate,GETDATE())>60 AND DATEDIFF(dayofyear,r.dtmReceiptDate,GETDATE())<=90 
		THEN SUM(tmpAPOpenClearing.dblClearingAmount) 
		ELSE 0 
	END AS dbl60,
	CASE WHEN DATEDIFF(dayofyear,r.dtmReceiptDate,GETDATE())>90  
		THEN SUM(tmpAPOpenClearing.dblClearingAmount) ELSE 0 
	END AS dbl90
		-- ,CASE WHEN DATEDIFF(dayofyear,r.dtmReceiptDate,GETDATE())<=0 THEN ''Current''
		-- 		WHEN DATEDIFF(dayofyear,r.dtmReceiptDate,GETDATE())>0 AND DATEDIFF(dayofyear,r.dtmReceiptDate,GETDATE())<=30 THEN ''01 - 30 Days''
		-- 		WHEN DATEDIFF(dayofyear,r.dtmReceiptDate,GETDATE())>30 AND DATEDIFF(dayofyear,r.dtmReceiptDate,GETDATE())<=60 THEN ''31 - 60 Days''
		-- 		WHEN DATEDIFF(dayofyear,r.dtmReceiptDate,GETDATE())>60 AND DATEDIFF(dayofyear,r.dtmReceiptDate,GETDATE())<=90 THEN ''61 - 90 Days''
		-- 		WHEN DATEDIFF(dayofyear,r.dtmReceiptDate,GETDATE())>90 THEN ''Over 90'' 
		-- 		ELSE ''Current'' END AS strAge
 FROM    
 (  
  SELECT  
   B.intEntityVendorId  
   ,B.intInventoryReceiptChargeId
   ,SUM(B.dblReceiptChargeQty)  -  SUM(B.dblVoucherQty) AS dblClearingQty  
   ,SUM(B.dblReceiptChargeTotal)  -  SUM(B.dblVoucherTotal) AS dblClearingAmount  
  FROM chargesForClearing B  
  GROUP BY   
   intEntityVendorId  
   ,intInventoryReceiptChargeId
 ) tmpAPOpenClearing  
 INNER JOIN tblICInventoryReceiptCharge rc  
  ON tmpAPOpenClearing.intInventoryReceiptChargeId = rc.intInventoryReceiptChargeId  
 INNER JOIN tblICInventoryReceipt r  
  ON r.intInventoryReceiptId = rc.intInventoryReceiptId  
  WHERE (tmpAPOpenClearing.dblClearingQty != 0  OR tmpAPOpenClearing.dblClearingAmount != 0)  
  GROUP BY r.dtmReceiptDate, tmpAPOpenClearing.intEntityVendorId
 UNION ALL  
 --SHIPMENT CHARGES  
 SELECT  
  tmpAPOpenClearing.intEntityVendorId 
  ,	CASE WHEN DATEDIFF(dayofyear,r.dtmShipDate,GETDATE())>=0 AND DATEDIFF(dayofyear,r.dtmShipDate,GETDATE())<=30 
		THEN SUM(tmpAPOpenClearing.dblClearingAmount) 
		ELSE 0 
	END AS dbl1, 
	CASE WHEN DATEDIFF(dayofyear,r.dtmShipDate,GETDATE())>30 AND DATEDIFF(dayofyear,r.dtmShipDate,GETDATE())<=60
		THEN SUM(tmpAPOpenClearing.dblClearingAmount)
		ELSE 0 
	END AS dbl30, 
	CASE WHEN DATEDIFF(dayofyear,r.dtmShipDate,GETDATE())>60 AND DATEDIFF(dayofyear,r.dtmShipDate,GETDATE())<=90 
		THEN SUM(tmpAPOpenClearing.dblClearingAmount) 
		ELSE 0 
	END AS dbl60,
	CASE WHEN DATEDIFF(dayofyear,r.dtmShipDate,GETDATE())>90  
		THEN SUM(tmpAPOpenClearing.dblClearingAmount) ELSE 0 
	END AS dbl90
 FROM    
 (  
  SELECT  
   B.intEntityVendorId  
   ,B.intInventoryShipmentChargeId
   ,SUM(B.dblReceiptChargeQty)  -  SUM(B.dblVoucherQty) AS dblClearingQty  
   ,SUM(B.dblReceiptChargeTotal)  -  SUM(B.dblVoucherTotal) AS dblClearingAmount   
  FROM shipmentChargesForClearing B  
  GROUP BY   
   intEntityVendorId  
   ,intInventoryShipmentChargeId
 ) tmpAPOpenClearing  
 INNER JOIN tblICInventoryShipmentCharge rc  
  ON tmpAPOpenClearing.intInventoryShipmentChargeId = rc.intInventoryShipmentChargeId  
 INNER JOIN tblICInventoryShipment r  
  ON r.intInventoryShipmentId = rc.intInventoryShipmentId  
  WHERE (tmpAPOpenClearing.dblClearingQty != 0  OR tmpAPOpenClearing.dblClearingAmount != 0)  
  GROUP BY r.dtmShipDate, tmpAPOpenClearing.intEntityVendorId
 UNION ALL
 --LOAD TRANSACTION ITEM
 SELECT 
 	tmpAPOpenClearing.intEntityVendorId 
  ,	CASE WHEN DATEDIFF(dayofyear,load.dtmPostedDate,GETDATE())>=0 AND DATEDIFF(dayofyear,load.dtmPostedDate,GETDATE())<=30 
		THEN SUM(tmpAPOpenClearing.dblClearingAmount) 
		ELSE 0 
	END AS dbl1, 
	CASE WHEN DATEDIFF(dayofyear,load.dtmPostedDate,GETDATE())>30 AND DATEDIFF(dayofyear,load.dtmPostedDate,GETDATE())<=60
		THEN SUM(tmpAPOpenClearing.dblClearingAmount)
		ELSE 0 
	END AS dbl30, 
	CASE WHEN DATEDIFF(dayofyear,load.dtmPostedDate,GETDATE())>60 AND DATEDIFF(dayofyear,load.dtmPostedDate,GETDATE())<=90 
		THEN SUM(tmpAPOpenClearing.dblClearingAmount)
		ELSE 0 
	END AS dbl60,
	CASE WHEN DATEDIFF(dayofyear,load.dtmPostedDate,GETDATE())>90  
		THEN SUM(tmpAPOpenClearing.dblClearingAmount) ELSE 0 
	END AS dbl90
 FROM    
 (  
  SELECT  
   B.intEntityVendorId  
   ,B.intLoadDetailId
   ,SUM(B.dblLoadDetailQty)  -  SUM(B.dblVoucherQty) AS dblClearingQty  
   ,SUM(B.dblLoadDetailTotal)  -  SUM(B.dblVoucherTotal) AS dblClearingAmount  
  FROM loadForClearing B  
  GROUP BY   
   intEntityVendorId  
   ,intLoadDetailId
 ) tmpAPOpenClearing  
 INNER JOIN tblLGLoadDetail loadDetail
  ON tmpAPOpenClearing.intLoadDetailId = loadDetail.intLoadDetailId  
 INNER JOIN tblLGLoad load  
  ON load.intLoadId = loadDetail.intLoadId  
 WHERE (tmpAPOpenClearing.dblClearingQty != 0 OR tmpAPOpenClearing.dblClearingAmount != 0  )
 GROUP BY load.dtmPostedDate, tmpAPOpenClearing.intEntityVendorId
 UNION ALL
 --LOAD COST TRANSACTION ITEM
 SELECT  
  	tmpAPOpenClearing.intEntityVendorId ,
	CASE WHEN DATEDIFF(dayofyear,load.dtmPostedDate,GETDATE())>=0 AND DATEDIFF(dayofyear,load.dtmPostedDate,GETDATE())<=30 
		THEN SUM(tmpAPOpenClearing.dblClearingAmount)
	ELSE 0 
	END AS dbl1, 
	CASE WHEN DATEDIFF(dayofyear,load.dtmPostedDate,GETDATE())>30 AND DATEDIFF(dayofyear,load.dtmPostedDate,GETDATE())<=60
		THEN SUM(tmpAPOpenClearing.dblClearingAmount) 
	ELSE 0 
	END AS dbl30, 
	CASE WHEN DATEDIFF(dayofyear,load.dtmPostedDate,GETDATE())>60 AND DATEDIFF(dayofyear,load.dtmPostedDate,GETDATE())<=90 
		THEN SUM(tmpAPOpenClearing.dblClearingAmount) 
	ELSE 0 
	END AS dbl60,
	CASE WHEN DATEDIFF(dayofyear,load.dtmPostedDate,GETDATE())>90  
		THEN SUM(tmpAPOpenClearing.dblClearingAmount) ELSE 0 
	END AS dbl90
 FROM    
 (  
  SELECT  
   B.intEntityVendorId  
   ,B.intLoadDetailId
   ,SUM(B.dblLoadCostDetailQty)  -  SUM(B.dblVoucherQty) AS dblClearingQty  
   ,SUM(B.dblLoadCostDetailTotal)  -  SUM(B.dblVoucherTotal) AS dblClearingAmount  
  FROM loadCostForClearing B  
  GROUP BY   
   intEntityVendorId  
   ,intLoadDetailId
 ) tmpAPOpenClearing  
 INNER JOIN tblLGLoadDetail loadDetail
  ON tmpAPOpenClearing.intLoadDetailId = loadDetail.intLoadDetailId  
 INNER JOIN tblLGLoad load  
  ON load.intLoadId = loadDetail.intLoadId  
 WHERE (tmpAPOpenClearing.dblClearingQty != 0 OR tmpAPOpenClearing.dblClearingAmount != 0  )
 GROUP BY load.dtmPostedDate, tmpAPOpenClearing.intEntityVendorId
  UNION ALL 
 --SETTLE STORAGE
 SELECT  
 tmpAPOpenClearing.intEntityVendorId
  ,	CASE WHEN DATEDIFF(dayofyear,CS.dtmDeliveryDate,GETDATE())>=0 AND DATEDIFF(dayofyear,CS.dtmDeliveryDate,GETDATE())<=30 
		THEN SUM(tmpAPOpenClearing.dblClearingAmount)
		ELSE 0 
	END AS dbl1, 
	CASE WHEN DATEDIFF(dayofyear,CS.dtmDeliveryDate,GETDATE())>30 AND DATEDIFF(dayofyear,CS.dtmDeliveryDate,GETDATE())<=60
		THEN SUM(tmpAPOpenClearing.dblClearingAmount) 
		ELSE 0 
	END AS dbl30, 
	CASE WHEN DATEDIFF(dayofyear,CS.dtmDeliveryDate,GETDATE())>60 AND DATEDIFF(dayofyear,CS.dtmDeliveryDate,GETDATE())<=90 
		THEN SUM(tmpAPOpenClearing.dblClearingAmount) 
		ELSE 0 
	END AS dbl60,
	CASE WHEN DATEDIFF(dayofyear,CS.dtmDeliveryDate,GETDATE())>90  
		THEN SUM(tmpAPOpenClearing.dblClearingAmount) ELSE 0 
	END AS dbl90
 FROM    
 (  
  SELECT  
   B.intEntityVendorId  
   ,B.intSettleStorageId
   ,SUM(B.dblSettleStorageQty)  -  SUM(B.dblVoucherQty) AS dblClearingQty  
   ,SUM(B.dblSettleStorageAmount)  -  SUM(B.dblVoucherTotal) AS dblClearingAmount  
  FROM grainClearing B  
  GROUP BY   
   intEntityVendorId  
   ,intSettleStorageId
 ) tmpAPOpenClearing  
INNER JOIN tblGRSettleStorage SS
	ON tmpAPOpenClearing.intSettleStorageId = SS.intSettleStorageId
		AND SS.intParentSettleStorageId IS NOT NULL
 INNER JOIN (tblGRCustomerStorage CS INNER JOIN tblGRSettleStorageTicket SST 
	          ON SST.intCustomerStorageId = CS.intCustomerStorageId)
      ON SST.intSettleStorageId = SS.intSettleStorageId
 WHERE (tmpAPOpenClearing.dblClearingQty != 0  OR tmpAPOpenClearing.dblClearingAmount != 0  )
 GROUP BY CS.dtmDeliveryDate, tmpAPOpenClearing.intEntityVendorId
 UNION ALL 
 --PATRONAGE
 SELECT  
 tmpAPOpenClearing.intEntityVendorId
  ,	CASE WHEN DATEDIFF(dayofyear,refund.dtmRefundDate,GETDATE())>=0 AND DATEDIFF(dayofyear,refund.dtmRefundDate,GETDATE())<=30 
		THEN SUM(tmpAPOpenClearing.dblClearingAmount)
		ELSE 0 
	END AS dbl1, 
	CASE WHEN DATEDIFF(dayofyear,refund.dtmRefundDate,GETDATE())>30 AND DATEDIFF(dayofyear,refund.dtmRefundDate,GETDATE())<=60
		THEN SUM(tmpAPOpenClearing.dblClearingAmount) 
		ELSE 0 
	END AS dbl30, 
	CASE WHEN DATEDIFF(dayofyear,refund.dtmRefundDate,GETDATE())>60 AND DATEDIFF(dayofyear,refund.dtmRefundDate,GETDATE())<=90 
		THEN SUM(tmpAPOpenClearing.dblClearingAmount) 
		ELSE 0 
	END AS dbl60,
	CASE WHEN DATEDIFF(dayofyear,refund.dtmRefundDate,GETDATE())>90  
		THEN SUM(tmpAPOpenClearing.dblClearingAmount) ELSE 0 
	END AS dbl90
 FROM    
 (  
  SELECT  
   B.intEntityVendorId  
   ,B.intRefundCustomerId
   ,SUM(B.dblRefundQty)  -  SUM(B.dblVoucherQty) AS dblClearingQty  
   ,SUM(B.dblRefundTotal)  -  SUM(B.dblVoucherTotal) AS dblClearingAmount  
  FROM patClearing B  
  GROUP BY   
   intEntityVendorId  
   ,intRefundCustomerId
 ) tmpAPOpenClearing  
INNER JOIN (tblPATRefund refund INNER JOIN tblPATRefundCustomer refundEntity 
                        ON refund.intRefundId = refundEntity.intRefundId)
                ON refundEntity.intRefundCustomerId = tmpAPOpenClearing.intRefundCustomerId
 WHERE (tmpAPOpenClearing.dblClearingQty != 0  OR tmpAPOpenClearing.dblClearingAmount != 0  )
 GROUP BY refund.dtmRefundDate, tmpAPOpenClearing.intEntityVendorId  
) resultData 
INNER JOIN (tblAPVendor vendor INNER JOIN tblEMEntity entity ON vendor.intEntityId = entity.intEntityId)  
  ON resultData.intEntityVendorId = vendor.intEntityId  
  GROUP BY resultData.intEntityVendorId, vendor.strVendorId, entity.strName, entity.strEntityNo
 ) MainQuery
 CROSS APPLY tblSMCompanySetup compSetup  '  
  

--SET @query = REPLACE(@query, 'GETDATE()', '''' + CONVERT(VARCHAR(10), @dateTo, 110) + '''');

IF NULLIF(@filter,'') IS NOT NULL
BEGIN
	SET @query = @query + ' WHERE ' + @filter
END

--PRINT @filter
--PRINT @query

EXEC sp_executesql @query