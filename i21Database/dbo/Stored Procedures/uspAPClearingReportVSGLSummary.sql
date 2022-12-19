CREATE PROCEDURE uspAPClearingReportVSGLSummary
(
    @asOfDate DATETIME = NULL
)
AS
IF OBJECT_ID(N'dbo.tmpClearingReport') IS NOT NULL
DROP TABLE tmpClearingReport

--<filter>
--	<fieldname>strAccountId</fieldname>
--	<condition>Equal To</condition>
--	<from>2015-0-0</from>
--	<to>6/15/2021</to>
--	<join>And</join>
--	<begingroup>0</begingroup>
--	<endgroup>0</endgroup>
--	<datatype>String</datatype>
--</filter>

DECLARE @currentDate DATETIME = ISNULL(@asOfDate, GETDATE())
DECLARE @currentDateStr NVARCHAR(100) = (SELECT CONVERT(NVARCHAR, @currentDate, 101));
IF OBJECT_ID(N'tmpAPClearingBalance') IS NOT NULL DROP TABLE tmpAPClearingBalance
CREATE TABLE tmpAPClearingBalance(dblBalance DECIMAL(18,6))

-- Sample XML string structure:
DECLARE @xmlParam NVARCHAR(MAX)
SET @xmlParam = '
<xmlparam>
	<filters>
		<filter>
			<fieldname>dtmDate</fieldname>
			<condition>Between</condition>
			<from>1/1/1900</from>
			<to>'+ @currentDateStr +'</to>
			<join>And</join>
			<begingroup>0</begingroup>
			<endgroup>0</endgroup>
			<datatype>DateTime</datatype>
		</filter>
		
	</filters>
	<options />
</xmlparam>' 
    
DECLARE @query NVARCHAR(MAX),    
  @cteQuery NVARCHAR(MAX),    
  @oldQuery NVARCHAR(MAX),     
  @oldInnerQuery NVARCHAR(MAX),     
  @innerQuery NVARCHAR(MAX),     
  @innerQuery2 NVARCHAR(MAX),     
  @innerQueryFilter NVARCHAR(MAX) = '', --initialized so it would work with concatenation event without filtering provided     
  @filter NVARCHAR(MAX) = '';    
DECLARE @dateFrom DATETIME = NULL;    
DECLARE @dateTo DATETIME = NULL;    
DECLARE @dtmDateTo DATETIME = NULL;    
DECLARE @transactNumber NVARCHAR(100) = NULL;  
DECLARE @transactNumberTo NVARCHAR(100) = NULL;  
DECLARE @total NUMERIC(18,6),    
  @amountDue NUMERIC(18,6),     
  @amountPad NUMERIC(18,6);    
DECLARE @count INT = 0;    
DECLARE @fieldname NVARCHAR(50)    
DECLARE @condition NVARCHAR(20)         
DECLARE @id INT     
DECLARE @strBillId NVARCHAR(50)     
DECLARE @strAccountId NVARCHAR(50)     
DECLARE @strAccountIdTo NVARCHAR(50)   
DECLARE @location NVARCHAR(50)     
DECLARE @locationTo NVARCHAR(50)    
DECLARE @strVendorIdName NVARCHAR(150)     
DECLARE @strVendorId NVARCHAR(50)    
DECLARE @strReceiptNumber NVARCHAR(50)    
DECLARE @strTerm NVARCHAR(50)    
DECLARE @dtmDate DATETIME     
DECLARE @from NVARCHAR(50)    
DECLARE @to NVARCHAR(50)    
DECLARE @join NVARCHAR(10)    
DECLARE @begingroup NVARCHAR(50)    
DECLARE @endgroup NVARCHAR(50)    
DECLARE @datatype NVARCHAR(50)    
DECLARE @dateCondition NVARCHAR(50)  
DECLARE @filterCount INT = 0;  
    
 -- Sanitize the @xmlParam     
IF LTRIM(RTRIM(@xmlParam)) = ''     
BEGIN    
--SET @xmlParam = NULL     
--Add this so that XtraReports have fields to get    
 SELECT     
  0 AS intInventoryReceiptId,    
  NULL AS dtmReceiptDate,    
  NULL AS strReceiptNumber,    
  NULL AS strBillOfLading,    
  NULL AS strOrderNumber,    
  NULL AS dtmDate,    
  NULL AS dtmBillDate,    
  NULL AS dtmDueDate,    
  NULL AS strVendorId,    
  0 AS intEntityVendorId,    
  0 AS intBillId,    
  NULL AS strBillId,    
  NULL AS strVendorOrderNumber,    
  NULL AS strTerm,    
  NULL AS strCompanyAddress,    
  NULL AS strCompanyName,    
  NULL AS strAccountId,    
  NULL AS strVendorIdName,    
  NULL AS strAge,    
  0 AS intAccountId,    
  0 AS dblVoucherAmount,    
  0 AS dblTotal,    
  0 AS dblAmountPaid,    
  0 AS dblDiscount,    
  0 AS dblInterest,    
  0 AS dblAmountDue,    
  0 AS dblCurrent,    
  0 AS dbl1,    
  0 AS dbl30,    
  0 AS dbl60,    
  0 AS dbl90,    
  0 AS intAging,    
  0 AS dblQtyToReceive,    
  0 AS dblQtyVouchered,    
  0 AS dblQtyToVoucher,    
  0 AS dblAmountToVoucher,    
  0 AS dblChargeAmount,     
  NULL as dtmCurrentDate,    
  NULL AS strLocationName,  
  NULL AS dtmStartDate,  
  NULL AS dtmEndDate  
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
    
--CHECK IF DATE IS THE ONLY FILTER (FOR GL SUMMARY PURPOSE)  
SELECT @filterCount = COUNT(*) FROM @temp_xml_table WHERE [fieldname] != 'dtmDate' AND [condition] != 'Dummy';  
    
--select * from @temp_xml_table    
--CREATE date filter    
SELECT @dateFrom = [from], @dateTo = [to], @condition = condition FROM @temp_xml_table WHERE [fieldname] = 'dtmReceiptDate';    
SELECT @dtmDate = [from], @dtmDateTo = [to], @condition = condition, @dateCondition = condition FROM @temp_xml_table WHERE [fieldname] = 'dtmDate';    
SET @innerQuery2 = 'SELECT DISTINCT    
      intInventoryReceiptId    
      ,strBillId    
      ,intBillId    
      ,strVendorIdName    
      ,dblTotal    
      ,dblVoucherAmount    
      -- ,dblAmountDue    
      ,dblAmountPaid    
      ,dblDiscount    
      ,dblInterest    
      ,(CASE WHEN dblQtyToVoucher <= 0 THEN dtmReceiptDate ELSE dtmDate END) AS dtmDate    
      ,dtmBillDate     
      ,dtmDueDate    
      ,dtmReceiptDate    
      ,dblQtyToReceive    
      ,dblQtyVouchered    
      ,dblQtyToVoucher    
      ,dblAmountToVoucher    
      ,dblChargeAmount    
      ,strContainer    
      ,strVendorId    
      ,strOrderNumber    
      ,strTerm    
      ,strReceiptNumber    
      ,strBillOfLading    
      ,dblVoucherQty    
      ,dblReceiptQty    
      ,strLocationName    
      FROM dbo.[vyuAPClearablesOnly]'    
    
SET @oldInnerQuery = 'SELECT DISTINCT    
      intInventoryReceiptId    
      ,strBillId    
      ,intBillId    
      ,strVendorIdName    
      ,dblTotal    
      ,dblVoucherAmount    
      -- ,dblAmountDue    
      ,dblAmountPaid    
      ,dblDiscount    
      ,dblInterest    
      ,(CASE WHEN dblQtyToVoucher <= 0 THEN dtmReceiptDate ELSE dtmDate END) AS dtmDate    
      ,dtmBillDate     
      ,dtmDueDate    
      ,dtmReceiptDate    
      ,dblQtyToReceive    
      ,dblQtyVouchered    
      ,dblQtyToVoucher    
      ,dblAmountToVoucher    
      ,dblChargeAmount    
      ,strContainer    
      ,strVendorId    
      ,strOrderNumber    
      ,strTerm    
      ,strReceiptNumber    
      ,strBillOfLading    
      ,dblVoucherQty    
      ,dblReceiptQty    
      ,strLocationName    
      FROM dbo.vyuAPClearables'    
    
SET @innerQuery =     
    '    
    SELECT    
     dtmDate    
     ,strReceiptNumber    
     ,intInventoryReceiptId    
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
    ';    
    
IF @dateFrom IS NOT NULL    
BEGIN     
 IF @condition = 'Equal To'    
 BEGIN     
  SET @innerQueryFilter = @innerQueryFilter + ' WHERE DATEADD(dd, DATEDIFF(dd, 0,dtmReceiptDate), 0) = ''' + CONVERT(VARCHAR(10), @dateFrom, 110) + ''''    
 END    
    ELSE     
 BEGIN     
  SET @innerQueryFilter = @innerQueryFilter + ' WHERE DATEADD(dd, DATEDIFF(dd, 0,dtmReceiptDate), 0) BETWEEN ''' + CONVERT(VARCHAR(10), @dateFrom, 110) + ''' AND '''  + CONVERT(VARCHAR(10), @dateTo, 110) + ''''     
 END      
END    
    
DELETE FROM @temp_xml_table WHERE [fieldname] = 'dtmReceiptDate'    
    
IF @dtmDate IS NOT NULL    
BEGIN     
 IF @condition = 'Equal To'    
 BEGIN     
  SET @innerQueryFilter = @innerQueryFilter + CASE WHEN @dateFrom IS NOT NULL THEN ' AND DATEADD(dd, DATEDIFF(dd, 0,dtmDate), 0) = ''' + CONVERT(VARCHAR(10), @dtmDate, 110) + ''''     
  ELSE ' WHERE DATEADD(dd, DATEDIFF(dd, 0,dtmDate), 0) = ''' + CONVERT(VARCHAR(10), @dtmDate, 110) + '''' END     
 END    
    ELSE     
 BEGIN     
  SET @innerQueryFilter = @innerQueryFilter + CASE WHEN @dateFrom IS NOT NULL     
            THEN ' AND DATEADD(dd, DATEDIFF(dd, 0,dtmDate), 0) BETWEEN ''' + CONVERT(VARCHAR(10), @dtmDate, 110) + ''' AND '''  + CONVERT(VARCHAR(10), @dtmDateTo, 110) + ''''     
          ELSE ' WHERE DATEADD(dd, DATEDIFF(dd, 0,dtmDate), 0) BETWEEN ''' + CONVERT(VARCHAR(10), @dtmDate, 110) + ''' AND '''  + CONVERT(VARCHAR(10), @dtmDateTo, 110) + ''''     
          END    
 END      
 SET @dateFrom = CONVERT(VARCHAR(10), @dtmDate, 110)    
 SET @dateTo = @dtmDateTo;    
END    
ELSE    
BEGIN    
 SET @dateFrom = CONVERT(VARCHAR(10), '1/1/1900', 110)    
 SET @dateTo = GETDATE();    
END    
    
DELETE FROM @temp_xml_table WHERE [fieldname] = 'dtmDate'    
DELETE FROM @temp_xml_table  where [condition] = 'Dummy'  
  
SELECT @transactNumber = [from], @transactNumberTo = [to], @condition = condition FROM @temp_xml_table WHERE [fieldname] = 'strTransactionNumber';    
IF @transactNumber IS NOT NULL  
BEGIN  
  IF @condition = 'Equal To'    
  BEGIN     
    SET @innerQueryFilter = @innerQueryFilter + CASE WHEN NULLIF(@innerQueryFilter,'') IS NOT NULL THEN ' AND strTransactionNumber = ''' + @transactNumber + ''''     
    ELSE ' WHERE strTransactionNumber = ''' + @transactNumber + '''' END     
  END  
  ELSE  
  BEGIN  
    SET @innerQueryFilter = @innerQueryFilter + CASE WHEN NULLIF(@innerQueryFilter,'') IS NOT NULL     
            THEN ' AND strTransactionNumber BETWEEN ''' + @transactNumber + ''' AND '''  + @transactNumberTo + ''''     
          ELSE ' WHERE strTransactionNumber BETWEEN ''' + @transactNumber + ''' AND '''  + @transactNumberTo + ''''     
          END  
  END  
END  
DELETE FROM @temp_xml_table WHERE [fieldname] = 'strTransactionNumber'    
  
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
 SELECT @id = id,     
     @fieldname = [fieldname],     
     @condition = [condition],     
     @from = [from],     
     @to = [to],     
     @join = [join],     
     @datatype = [datatype]     
 FROM @temp_xml_table    
 SET @filter = @filter + ' ' + dbo.fnAPCreateFilter(@fieldname, @condition, @from, @to, @join, null, null, @datatype)    
     
 DELETE FROM @temp_xml_table WHERE id = @id    
     
 IF EXISTS(SELECT 1 FROM @temp_xml_table)    
 BEGIN    
      
  SET @filter = @filter + ' AND '    
 END    
END    
    
-- Gather the variables values from the xml table.    
 SELECT @strVendorId = [fieldname],     
     @from = [from],     
     @to = [to],     
     @join = [join],     
     @datatype = [datatype]     
 FROM @temp_xml_table WHERE [fieldname] = 'strVendorId';    
 IF @strVendorId IS NOT NULL    
 BEGIN    
  SET @filter = @filter + ' ' + dbo.fnAPCreateFilter(@strVendorId, @condition, @from, @to, @join, null, null, @datatype)          
 END    
        
 SELECT @strVendorIdName = [fieldname],     
     @from = [from],     
     @to = [to],     
     @join = [join],     
     @datatype = [datatype]     
 FROM @temp_xml_table WHERE [fieldname] = 'strVendorIdName';    
 IF @strVendorIdName IS NOT NULL    
 BEGIN    
  SET @filter = @filter + ' ' + dbo.fnAPCreateFilter(@strVendorIdName, @condition, @from, @to, @join, null, null, @datatype)          
 END    
      
   SELECT @strBillId = [fieldname],     
     @from = [from],     
     @to = [to],     
     @join = [join],     
     @datatype = [datatype]     
 FROM @temp_xml_table WHERE [fieldname] = 'strBillId';    
 IF @strBillId IS NOT NULL    
 BEGIN    
  SET @filter = @filter + ' ' + dbo.fnAPCreateFilter(@strBillId, @condition, @from, @to, @join, null, null, @datatype)          
 END      
    
  SELECT @strReceiptNumber = [fieldname],     
    @from = [from],     
     @to = [to],     
     @join = [join],     
     @datatype = [datatype]     
 FROM @temp_xml_table WHERE [fieldname] = 'strReceiptNumber';    
 IF @strReceiptNumber IS NOT NULL    
 BEGIN    
  SET @filter = @filter + ' ' + dbo.fnAPCreateFilter(@strReceiptNumber, @condition, @from, @to, @join, null, null, @datatype)          
 END      
    
 SELECT @strTerm = [fieldname],     
     @from = [from],     
     @to = [to],     
     @join = [join],     
     @datatype = [datatype]     
 FROM @temp_xml_table WHERE [fieldname] = 'strTerm';    
 IF @strTerm IS NOT NULL    
 BEGIN    
  SET @filter = @filter + ' ' + dbo.fnAPCreateFilter(@strTerm, @condition, @from, @to, @join, null, null, @datatype)          
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
    grainTransferClearing    
    AS    
    (    
  SELECT    
        dtmDate            ,strTransactionNumber    
        ,intEntityVendorId    
        ,intInventoryReceiptId    
        ,intInventoryReceiptItemId    
        ,intItemId    
        ,intTransferStorageId    
        ,strTransferStorageTicket    
        ,intTransferStorageReferenceId    
        ,dblTransferTotal    
        ,dblTransferQty    
        ,dblReceiptTotal    
        ,dblReceiptQty    
        ,intLocationId    
        ,strLocationName    
     FROM vyuGRTransferClearing    
     ' + @innerQueryFilter + '    
    ),    
    grainTransferChargeClearing    
    AS    
    (    
  SELECT    
        dtmDate    
        ,strTransactionNumber    
        ,intEntityVendorId    
        ,intInventoryReceiptId    
        ,intInventoryReceiptChargeId    
        ,intItemId    
        ,intTransferStorageId    
        ,strTransferStorageTicket    
        ,intTransferStorageReferenceId    
        ,dblTransferTotal    
        ,dblTransferQty    
        ,dblReceiptChargeTotal    
        ,dblReceiptChargeQty    
        ,intLocationId    
        ,strLocationName    
     FROM vyuGRTransferChargesClearing     
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
    grainTransferClearing  
    AS  
    (  
      SELECT    
        dtmDate    
        ,strTransactionNumber    
        ,intEntityVendorId    
        ,intInventoryReceiptId    
        ,intInventoryReceiptItemId    
        ,intItemId    
        ,intTransferStorageId    
        ,strTransferStorageTicket    
        ,intTransferStorageReferenceId    
        ,dblTransferTotal    
        ,dblTransferQty    
        ,dblReceiptTotal    
        ,dblReceiptQty    
        ,intLocationId    
        ,strLocationName    
     FROM vyuGRTransferClearing    
    ),  
    grainTransferChargeClearing  
    AS  
    (  
      SELECT    
        dtmDate    
        ,strTransactionNumber    
        ,intEntityVendorId    
        ,intInventoryReceiptId    
        ,intInventoryReceiptChargeId    
        ,intItemId    
        ,intTransferStorageId    
        ,strTransferStorageTicket    
        ,intTransferStorageReferenceId    
        ,dblTransferTotal    
        ,dblTransferQty    
        ,dblReceiptChargeTotal    
        ,dblReceiptChargeQty    
        ,intLocationId    
        ,strLocationName    
     FROM vyuGRTransferChargesClearing    
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
  
SET @query = @cteQuery + N'   
SELECT 
    SUM(dblAmountToVoucher) AS dblAmountToVoucher
FROM (
SELECT *  
  ,dtmStartDate = '''+ CASE WHEN @filterCount > 0 THEN '0' ELSE CONVERT(NVARCHAR(10), ISNULL(@dtmDate, '1/1/1900'), 101) END +'''  
  ,dtmEndDate = '''+ CASE WHEN @filterCount > 0 THEN '0' ELSE CONVERT(NVARCHAR(10), CASE WHEN @dateCondition = 'Equal To' THEN @dtmDate ELSE ISNULL(@dtmDateTo, GETDATE()) END, 101) END +'''  
 FROM (     
 SELECT    
  r.strReceiptNumber  
  ,r.dtmReceiptDate  
  ,ri.intInventoryReceiptItemId  
  ,NULL AS intInventoryReceiptChargeId  
  ,NULL AS intInventoryShipmentChargeId  
  ,NULL AS intLoadDetailId  
  ,NULL AS intCustomerStorageId  
  ,NULL AS intRefundCustomerId  
  ,r.strBillOfLading    
  ,'''' AS strOrderNumber    
  -- ,vouchersDate.strVoucherDate AS dtmBillDate    
  -- ,vouchers.strVoucherIds AS strBillId    
  -- ,vouchersTerm.strVoucherTerm AS strTerm    
  ,CASE WHEN DATEDIFF(dayofyear,r.dtmReceiptDate,GETDATE())<=0     
   THEN 0    
  ELSE ISNULL(DATEDIFF(dayofyear,r.dtmReceiptDate,GETDATE()),0) END AS intAging    
  ,dbo.fnTrim(ISNULL(vendor.strVendorId, entity.strEntityNo) + '' - '' + isnull(entity.strName,'''')) as strVendorIdName    
  ,tmpAPOpenClearing.strLocationName  
  ,tmpAPOpenClearing.dblReceiptQty AS dblQtyToReceive    
  ,tmpAPOpenClearing.dblVoucherQty AS dblQtyVouchered    
  ,tmpAPOpenClearing.dblReceiptTotal AS dblTotal    
  ,tmpAPOpenClearing.dblVoucherTotal AS dblVoucherAmount    
  ,tmpAPOpenClearing.dblClearingQty AS dblQtyToVoucher    
  ,tmpAPOpenClearing.dblReceiptTotal - tmpAPOpenClearing.dblVoucherTotal AS dblAmountToVoucher    
  ,GETDATE() as dtmCurrentDate    
  ,dbo.[fnAPFormatAddress](NULL, NULL, NULL, compSetup.strAddress, compSetup.strCity, compSetup.strState, compSetup.strZip, compSetup.strCountry, NULL) AS strCompanyAddress    
  ,compSetup.strCompanyName    
 FROM      
 (    
  SELECT    
   B.intEntityVendorId    
   ,B.intInventoryReceiptItemId  
   ,B.strTransactionNumber    
   ,SUM(B.dblReceiptTotal) AS dblReceiptTotal  
   ,SUM(B.dblReceiptQty) AS dblReceiptQty  
   ,SUM(B.dblVoucherTotal) AS dblVoucherTotal    
   ,SUM(B.dblVoucherQty) AS dblVoucherQty    
   ,SUM(B.dblReceiptQty)  -  SUM(B.dblVoucherQty) AS dblClearingQty   
   ,SUM(B.dblReceiptTotal) - SUM(B.dblVoucherTotal) AS dblClearingAmount   
   ,B.intLocationId    
   ,B.strLocationName  
  FROM forClearing B    
  GROUP BY     
   intEntityVendorId    
   ,intInventoryReceiptItemId  
   ,strTransactionNumber    
   ,intItemId    
   ,intLocationId    
   ,strLocationName  
  --HAVING (SUM(B.dblReceiptQty) - SUM(B.dblVoucherQty)) != 0 OR (SUM(B.dblReceiptTotal) - SUM(B.dblVoucherTotal)) != 0  
 ) tmpAPOpenClearing    
  -- ON A.intInventoryReceiptItemId = tmpAPOpenClearing.intInventoryReceiptItemId    
 INNER JOIN tblICInventoryReceiptItem ri    
  ON tmpAPOpenClearing.intInventoryReceiptItemId = ri.intInventoryReceiptItemId    
 INNER JOIN tblICInventoryReceipt r    
  ON r.intInventoryReceiptId = ri.intInventoryReceiptId    
 INNER JOIN (tblAPVendor vendor INNER JOIN tblEMEntity entity ON vendor.intEntityId = entity.intEntityId)    
  ON tmpAPOpenClearing.intEntityVendorId = vendor.intEntityId    
 CROSS APPLY tblSMCompanySetup compSetup   
 WHERE 1 = CASE WHEN (dblClearingQty) = 0 OR (dblClearingAmount) = 0 THEN 0 ELSE 1 END  
  UNION ALL    
 --CHARGES    
 SELECT    
  r.strReceiptNumber    
  ,r.dtmReceiptDate  
  ,NULL AS intInventoryReceiptItemId  
  ,rc.intInventoryReceiptChargeId  
  ,NULL AS intInventoryShipmentChargeId  
  ,NULL AS intLoadDetailId  
  ,NULL AS intCustomerStorageId  
  ,NULL AS intRefundCustomerId  
  ,r.strBillOfLading    
  ,'''' AS strOrderNumber    
  -- ,vouchersDate.strVoucherDate AS dtmBillDate    
  -- ,vouchers.strVoucherIds AS strBillId    
  -- ,vouchersTerm.strVoucherTerm AS strTerm    
  ,CASE WHEN DATEDIFF(dayofyear,r.dtmReceiptDate,GETDATE())<=0     
   THEN 0    
  ELSE ISNULL(DATEDIFF(dayofyear,r.dtmReceiptDate,GETDATE()),0) END AS intAging    
  ,dbo.fnTrim(ISNULL(vendor.strVendorId, entity.strEntityNo) + '' - '' + isnull(entity.strName,'''')) as strVendorIdName   
  ,tmpAPOpenClearing.strLocationName    
  ,tmpAPOpenClearing.dblReceiptChargeQty AS dblQtyToReceive    
  ,tmpAPOpenClearing.dblVoucherQty AS dblQtyVouchered    
  ,tmpAPOpenClearing.dblReceiptChargeTotal AS dblTotal    
  ,tmpAPOpenClearing.dblVoucherTotal AS dblVoucherAmount    
  ,tmpAPOpenClearing.dblClearingQty AS dblQtyToVoucher    
  ,tmpAPOpenClearing.dblReceiptChargeTotal - tmpAPOpenClearing.dblVoucherTotal AS dblAmountToVoucher    
  ,GETDATE() as dtmCurrentDate    
  ,dbo.[fnAPFormatAddress](NULL, NULL, NULL, compSetup.strAddress, compSetup.strCity, compSetup.strState, compSetup.strZip, compSetup.strCountry, NULL) AS strCompanyAddress    
  ,compSetup.strCompanyName    
 FROM      
 (    
  SELECT    
   B.intEntityVendorId    
   ,B.intInventoryReceiptChargeId  
   ,B.strTransactionNumber    
   ,SUM(B.dblReceiptChargeTotal) AS dblReceiptChargeTotal  
   ,SUM(B.dblReceiptChargeQty) AS dblReceiptChargeQty    
   ,SUM(B.dblVoucherTotal) AS dblVoucherTotal    
   ,SUM(B.dblVoucherQty) AS dblVoucherQty    
   ,SUM(B.dblReceiptChargeQty)  -  SUM(B.dblVoucherQty) AS dblClearingQty    
   ,SUM(B.dblReceiptChargeTotal) - SUM(B.dblVoucherTotal) AS dblClearingAmount  
   ,B.intLocationId    
   ,B.strLocationName  
  FROM chargesForClearing B    
  GROUP BY     
   intEntityVendorId    
   ,intInventoryReceiptChargeId  
   ,strTransactionNumber    
   ,intItemId    
   ,intLocationId    
   ,strLocationName  
  --  HAVING   
  --       (SUM(B.dblReceiptChargeQty) - SUM(B.dblVoucherQty)) != 0  
  --   OR  (SUM(B.dblReceiptChargeTotal) - SUM(B.dblVoucherTotal)) != 0  
 ) tmpAPOpenClearing    
 INNER JOIN tblICInventoryReceiptCharge rc    
  ON tmpAPOpenClearing.intInventoryReceiptChargeId = rc.intInventoryReceiptChargeId    
 INNER JOIN tblICInventoryReceipt r    
  ON r.intInventoryReceiptId = rc.intInventoryReceiptId    
 INNER JOIN (tblAPVendor vendor INNER JOIN tblEMEntity entity ON vendor.intEntityId = entity.intEntityId)    
  ON tmpAPOpenClearing.intEntityVendorId = vendor.intEntityId    
 CROSS APPLY tblSMCompanySetup compSetup    
 WHERE 1 = CASE WHEN (dblClearingQty) = 0 OR (dblClearingAmount) = 0 THEN 0 ELSE 1 END  
 UNION ALL    
 --SHIPMENT CHARGES    
 SELECT    
  r.strShipmentNumber   
  ,r.dtmShipDate   
  ,NULL AS intInventoryReceiptItemId  
  ,NULL AS intInventoryReceiptChargeId  
  ,rc.intInventoryShipmentChargeId  
  ,NULL AS intLoadDetailId  
  ,NULL AS intSettleStorageId  
  ,NULL AS intRefundCustomerId  
  ,r.strBOLNumber    
  ,'''' AS strOrderNumber    
  -- ,vouchersDate.strVoucherDate AS dtmBillDate    
  -- ,vouchers.strVoucherIds AS strBillId    
  -- ,vouchersTerm.strVoucherTerm AS strTerm    
  ,CASE WHEN DATEDIFF(dayofyear,r.dtmShipDate,GETDATE())<=0     
   THEN 0    
  ELSE ISNULL(DATEDIFF(dayofyear,r.dtmShipDate,GETDATE()),0) END AS intAging    
  ,dbo.fnTrim(ISNULL(vendor.strVendorId, entity.strEntityNo) + '' - '' + isnull(entity.strName,'''')) as strVendorIdName   
  ,tmpAPOpenClearing.strLocationName   
  ,tmpAPOpenClearing.dblReceiptChargeQty AS dblQtyToReceive    
  ,tmpAPOpenClearing.dblVoucherQty AS dblQtyVouchered    
  ,tmpAPOpenClearing.dblReceiptChargeTotal AS dblTotal    
  ,tmpAPOpenClearing.dblVoucherTotal AS dblVoucherAmount    
  ,tmpAPOpenClearing.dblClearingQty AS dblQtyToVoucher    
  ,tmpAPOpenClearing.dblReceiptChargeTotal - tmpAPOpenClearing.dblVoucherTotal AS dblAmountToVoucher    
  ,GETDATE() as dtmCurrentDate    
  ,dbo.[fnAPFormatAddress](NULL, NULL, NULL, compSetup.strAddress, compSetup.strCity, compSetup.strState, compSetup.strZip, compSetup.strCountry, NULL) AS strCompanyAddress    
  ,compSetup.strCompanyName    
 FROM      
 (    
  SELECT    
   B.intEntityVendorId    
   ,B.intInventoryShipmentChargeId  
   ,B.strTransactionNumber    
   ,SUM(B.dblReceiptChargeTotal) AS   dblReceiptChargeTotal  
   ,SUM(B.dblReceiptChargeQty) AS dblReceiptChargeQty  
   ,SUM(B.dblVoucherTotal) AS dblVoucherTotal    
   ,SUM(B.dblVoucherQty) AS dblVoucherQty    
   ,SUM(B.dblReceiptChargeQty)  -  SUM(B.dblVoucherQty) AS dblClearingQty    
   ,SUM(B.dblReceiptChargeTotal) - SUM(B.dblVoucherTotal) AS dblClearingAmount  
   ,B.intLocationId    
   ,B.strLocationName  
  FROM shipmentChargesForClearing B    
  GROUP BY     
   intEntityVendorId    
   ,intInventoryShipmentChargeId  
   ,strTransactionNumber    
   ,intItemId    
   ,intLocationId    
   ,strLocationName  
  --  HAVING   
    --EXCLUDE THOSE CHARGES WHICH VOUCHER QTY IS LESS THAN SHIPMENT CHARGE QTY  
    --AND VOUCHER TOTAL IS LESS THAN SHIPMENT CHARGE AMOUNT  
    --EITHER ONE OF THE RULE FAILS, MEANS IT IS FULLY VOUCHERED  
        -- (SUM(B.dblVoucherQty) < SUM(B.dblReceiptChargeQty) AND   
        --   SUM(B.dblVoucherTotal) < SUM(B.dblReceiptChargeTotal))  
  --   OR  (SUM(B.dblReceiptChargeTotal) - SUM(B.dblVoucherTotal)) != 0  
 ) tmpAPOpenClearing    
 INNER JOIN tblICInventoryShipmentCharge rc    
  ON tmpAPOpenClearing.intInventoryShipmentChargeId = rc.intInventoryShipmentChargeId    
 INNER JOIN tblICInventoryShipment r    
  ON r.intInventoryShipmentId = rc.intInventoryShipmentId    
 INNER JOIN (tblAPVendor vendor INNER JOIN tblEMEntity entity ON vendor.intEntityId = entity.intEntityId)    
  ON tmpAPOpenClearing.intEntityVendorId = vendor.intEntityId    
 CROSS APPLY tblSMCompanySetup compSetup    
  -- WHERE 1 = CASE WHEN (dblClearingQty) = 0 OR (dblClearingAmount) = 0 THEN 0 ELSE 1 END  
  --EXCLUDE THOSE CHARGES WHICH VOUCHER QTY IS LESS THAN SHIPMENT CHARGE QTY  
    --AND VOUCHER TOTAL IS LESS THAN SHIPMENT CHARGE AMOUNT  
    --EITHER ONE OF THE RULE FAILS, MEANS IT IS FULLY VOUCHERED  
  WHERE 1 = CASE WHEN (dblVoucherQty) < dblReceiptChargeQty  
                 AND (dblVoucherTotal) <  dblReceiptChargeTotal THEN 1 ELSE 0 END  
 UNION ALL  
 --LOAD TRANSACTION ITEM  
 SELECT    
  load.strLoadNumber    
  ,load.dtmPostedDate  
  ,NULL AS intInventoryReceiptItemId  
  ,NULL AS intInventoryReceiptChargeId  
  ,NULL AS intInventoryShipmentChargeId  
  ,loadDetail.intLoadDetailId  
  ,NULL AS intSettleStorageId  
  ,NULL AS intRefundCustomerId  
  ,NULL strBillOfLading    
  ,'''' AS strOrderNumber    
  -- ,vouchersDate.strVoucherDate AS dtmBillDate    
  -- ,vouchers.strVoucherIds AS strBillId    
  -- ,vouchersTerm.strVoucherTerm AS strTerm    
  ,CASE WHEN DATEDIFF(dayofyear,load.dtmPostedDate,GETDATE())<=0     
   THEN 0    
  ELSE ISNULL(DATEDIFF(dayofyear,load.dtmPostedDate,GETDATE()),0) END AS intAging    
  ,dbo.fnTrim(ISNULL(vendor.strVendorId, entity.strEntityNo) + '' - '' + isnull(entity.strName,'''')) as strVendorIdName   
  ,tmpAPOpenClearing.strLocationName   
  ,tmpAPOpenClearing.dblLoadDetailQty AS dblQtyToReceive    
  ,tmpAPOpenClearing.dblVoucherQty AS dblQtyVouchered    
  ,tmpAPOpenClearing.dblLoadDetailTotal AS dblTotal    
  ,tmpAPOpenClearing.dblVoucherTotal AS dblVoucherAmount    
  ,tmpAPOpenClearing.dblClearingQty AS dblQtyToVoucher    
  ,tmpAPOpenClearing.dblLoadDetailTotal - tmpAPOpenClearing.dblVoucherTotal AS dblAmountToVoucher    
  ,GETDATE() as dtmCurrentDate    
  ,dbo.[fnAPFormatAddress](NULL, NULL, NULL, compSetup.strAddress, compSetup.strCity, compSetup.strState, compSetup.strZip, compSetup.strCountry, NULL) AS strCompanyAddress    
  ,compSetup.strCompanyName    
 FROM      
 (    
  SELECT    
   B.intEntityVendorId    
   ,B.intLoadDetailId  
   ,B.strTransactionNumber    
   ,SUM(B.dblLoadDetailTotal) AS dblLoadDetailTotal  
   ,SUM(B.dblLoadDetailQty)  AS dblLoadDetailQty  
   ,SUM(B.dblVoucherTotal) AS dblVoucherTotal    
   ,SUM(B.dblVoucherQty) AS dblVoucherQty    
   ,SUM(B.dblLoadDetailQty)  -  SUM(B.dblVoucherQty) AS dblClearingQty    
   ,SUM(B.dblLoadDetailTotal) - SUM(B.dblVoucherTotal) AS dblClearingAmount  
   ,B.intLocationId    
   ,B.strLocationName  
  FROM loadForClearing B    
  GROUP BY     
   intEntityVendorId    
   ,intLoadDetailId  
   ,strTransactionNumber    
   ,intItemId    
   ,intLocationId    
   ,strLocationName  
  --  HAVING   
  --       (SUM(B.dblLoadDetailQty) - SUM(B.dblVoucherQty)) != 0  
  --   OR  (SUM(B.dblLoadDetailTotal) - SUM(B.dblVoucherTotal)) != 0  
 ) tmpAPOpenClearing    
 INNER JOIN tblLGLoadDetail loadDetail  
  ON tmpAPOpenClearing.intLoadDetailId = loadDetail.intLoadDetailId    
 INNER JOIN tblLGLoad load    
  ON load.intLoadId = loadDetail.intLoadId    
 INNER JOIN (tblAPVendor vendor INNER JOIN tblEMEntity entity ON vendor.intEntityId = entity.intEntityId)    
  ON tmpAPOpenClearing.intEntityVendorId = vendor.intEntityId    
 CROSS APPLY tblSMCompanySetup compSetup    
 WHERE 1 = CASE WHEN (dblClearingQty) = 0 OR (dblClearingAmount) = 0 THEN 0 ELSE 1 END  
 UNION ALL  
 --LOAD COST TRANSACTION ITEM  
 SELECT    
  load.strLoadNumber    
  ,load.dtmPostedDate  
  ,NULL AS intInventoryReceiptItemId  
  ,NULL AS intInventoryReceiptChargeId  
  ,NULL AS intInventoryShipmentChargeId  
  ,loadDetail.intLoadDetailId  
  ,NULL AS intSettleStorageId  
  ,NULL AS intRefundCustomerId  
  ,NULL strBillOfLading    
  ,'''' AS strOrderNumber    
  -- ,vouchersDate.strVoucherDate AS dtmBillDate    
  -- ,vouchers.strVoucherIds AS strBillId    
  -- ,vouchersTerm.strVoucherTerm AS strTerm    
  ,CASE WHEN DATEDIFF(dayofyear,load.dtmPostedDate,GETDATE())<=0     
   THEN 0    
  ELSE ISNULL(DATEDIFF(dayofyear,load.dtmPostedDate,GETDATE()),0) END AS intAging    
  ,dbo.fnTrim(ISNULL(vendor.strVendorId, entity.strEntityNo) + '' - '' + isnull(entity.strName,'''')) as strVendorIdName   
  ,tmpAPOpenClearing.strLocationName    
  ,tmpAPOpenClearing.dblLoadCostDetailQty AS dblQtyToReceive    
  ,tmpAPOpenClearing.dblVoucherQty AS dblQtyVouchered    
  ,tmpAPOpenClearing.dblLoadCostDetailTotal AS dblTotal    
  ,tmpAPOpenClearing.dblVoucherTotal AS dblVoucherAmount    
  ,tmpAPOpenClearing.dblClearingQty AS dblQtyToVoucher    
  ,tmpAPOpenClearing.dblLoadCostDetailTotal - tmpAPOpenClearing.dblVoucherTotal AS dblAmountToVoucher    
  ,GETDATE() as dtmCurrentDate    
  ,dbo.[fnAPFormatAddress](NULL, NULL, NULL, compSetup.strAddress, compSetup.strCity, compSetup.strState, compSetup.strZip, compSetup.strCountry, NULL) AS strCompanyAddress    
  ,compSetup.strCompanyName    
 FROM      
 (    
  SELECT    
   B.intEntityVendorId    
   ,B.intLoadDetailId  
   ,B.strTransactionNumber    
   ,SUM(B.dblLoadCostDetailTotal) AS   dblLoadCostDetailTotal  
   ,SUM(B.dblLoadCostDetailQty) AS dblLoadCostDetailQty    
   ,SUM(B.dblVoucherTotal) AS dblVoucherTotal    
   ,SUM(B.dblVoucherQty) AS dblVoucherQty    
   ,SUM(B.dblLoadCostDetailQty)  -  SUM(B.dblVoucherQty) AS dblClearingQty  
   ,SUM(B.dblLoadCostDetailTotal) - SUM(B.dblVoucherTotal)  AS dblClearingAmount  
   ,B.intLocationId    
   ,B.strLocationName  
  FROM loadCostForClearing B    
  GROUP BY     
   intEntityVendorId    
   ,intLoadDetailId  
   ,strTransactionNumber    
   ,intItemId    
   ,intLocationId    
   ,strLocationName  
  --  HAVING   
  --       (SUM(B.dblLoadCostDetailQty) - SUM(B.dblVoucherQty)) != 0  
  --   OR  (SUM(B.dblLoadCostDetailTotal) - SUM(B.dblVoucherTotal)) != 0  
 ) tmpAPOpenClearing    
 INNER JOIN tblLGLoadDetail loadDetail  
  ON tmpAPOpenClearing.intLoadDetailId = loadDetail.intLoadDetailId    
 INNER JOIN tblLGLoad load    
  ON load.intLoadId = loadDetail.intLoadId    
 INNER JOIN (tblAPVendor vendor INNER JOIN tblEMEntity entity ON vendor.intEntityId = entity.intEntityId)    
  ON tmpAPOpenClearing.intEntityVendorId = vendor.intEntityId    
 CROSS APPLY tblSMCompanySetup compSetup    
 WHERE 1 = CASE WHEN (dblClearingQty) = 0 OR (dblClearingAmount) = 0 THEN 0 ELSE 1 END  
--  OUTER APPLY    
--  (    
--   SELECT strVoucherIds =     
--     LTRIM(    
--      STUFF(    
--        (    
--         SELECT  '', '' + b.strBillId    
--         FROM loadCostForClearing a    
--         INNER JOIN tblAPBill b    
--          ON b.intBillId = a.intBillId    
--         WHERE a.intLoadDetailId = tmpAPOpenClearing.intLoadDetailId AND a.intItemId = tmpAPOpenClearing.intItemId  
--         GROUP BY b.strBillId    
--         FOR xml path('''')    
--        )    
--       , 1    
--       , 1    
--       , ''''    
--      )    
--     )    
--  ) vouchers    
--  OUTER APPLY    
--  (    
--   SELECT strVoucherDate =     
--     LTRIM(    
--      STUFF(    
--        (    
--         SELECT  '', '' + CONVERT(VARCHAR, b.dtmDate, 1)    
--         FROM loadCostForClearing a    
--         INNER JOIN tblAPBill b    
--          ON b.intBillId = a.intBillId    
--         WHERE a.intLoadDetailId = tmpAPOpenClearing.intLoadDetailId AND a.intItemId = tmpAPOpenClearing.intItemId  
--         GROUP BY b.dtmDate    
--         FOR xml path('''')    
--        )    
--       , 1    
--       , 1    
--       , ''''    
--      )    
--     )    
--  ) vouchersDate    
--  OUTER APPLY    
--  (    
--   SELECT strVoucherTerm =     
--     LTRIM(    
--      STUFF(    
--        (    
--         SELECT  '', '' + c.strTerm    
--         FROM loadCostForClearing a    
--         INNER JOIN tblAPBill b    
--          ON b.intBillId = a.intBillId    
--         INNER JOIN tblSMTerm c    
--          ON b.intTermsId = c.intTermID    
--         WHERE a.intLoadDetailId = tmpAPOpenClearing.intLoadDetailId AND a.intItemId = tmpAPOpenClearing.intItemId  
--         GROUP BY c.strTerm    
--         FOR xml path('''')    
--        )    
--       , 1    
--       , 1    
--       , ''''    
--      )    
--     )    
--  ) vouchersTerm    
  UNION ALL   
 --SETTLE STORAGE  
 SELECT    
  SS.strStorageTicket   
  ,CS.dtmDeliveryDate  
  ,NULL AS intInventoryReceiptItemId  
  ,NULL AS intInventoryReceiptChargeId  
  ,NULL AS intInventoryShipmentChargeId  
  ,NULL AS intLoadDetailId  
  ,SS.intSettleStorageId   
  ,NULL AS intRefundCustomerId  
  ,NULL strBillOfLading    
  ,'''' AS strOrderNumber    
  -- ,vouchersDate.strVoucherDate AS dtmBillDate    
  -- ,vouchers.strVoucherIds AS strBillId    
  -- ,vouchersTerm.strVoucherTerm AS strTerm    
  ,CASE WHEN DATEDIFF(dayofyear,CS.dtmDeliveryDate,GETDATE())<=0     
   THEN 0    
  ELSE ISNULL(DATEDIFF(dayofyear,CS.dtmDeliveryDate,GETDATE()),0) END AS intAging    
  ,dbo.fnTrim(ISNULL(vendor.strVendorId, entity.strEntityNo) + '' - '' + isnull(entity.strName,'''')) as strVendorIdName   
  ,tmpAPOpenClearing.strLocationName    
  ,tmpAPOpenClearing.dblSettleStorageQty AS dblQtyToReceive    
  ,tmpAPOpenClearing.dblVoucherQty AS dblQtyVouchered    
  ,tmpAPOpenClearing.dblSettleStorageAmount AS dblTotal    
  ,tmpAPOpenClearing.dblVoucherTotal AS dblVoucherAmount    
  ,tmpAPOpenClearing.dblClearingQty AS dblQtyToVoucher    
  ,tmpAPOpenClearing.dblSettleStorageAmount - tmpAPOpenClearing.dblVoucherTotal AS dblAmountToVoucher    
  ,GETDATE() as dtmCurrentDate    
  ,dbo.[fnAPFormatAddress](NULL, NULL, NULL, compSetup.strAddress, compSetup.strCity, compSetup.strState, compSetup.strZip, compSetup.strCountry, NULL) AS strCompanyAddress    
  ,compSetup.strCompanyName    
 FROM      
 (    
  SELECT    
   B.intEntityVendorId    
   ,B.intSettleStorageId  
   ,B.strTransactionNumber    
   ,SUM(B.dblSettleStorageAmount) AS   dblSettleStorageAmount  
   ,SUM(B.dblSettleStorageQty) AS dblSettleStorageQty    
   ,SUM(B.dblVoucherTotal) AS dblVoucherTotal    
   ,SUM(B.dblVoucherQty) AS dblVoucherQty    
   ,SUM(B.dblSettleStorageQty)  -  SUM(B.dblVoucherQty) AS dblClearingQty    
   ,SUM(B.dblSettleStorageAmount) - SUM(B.dblVoucherTotal) AS dblClearingAmount  
   ,B.intLocationId    
   ,B.strLocationName  
  FROM grainClearing B    
  GROUP BY     
   intEntityVendorId    
   ,intSettleStorageId  
   ,strTransactionNumber    
   ,intItemId    
   ,intLocationId    
   ,strLocationName  
  --  HAVING   
  --     (SUM(B.dblSettleStorageQty) - SUM(B.dblVoucherQty)) != 0  
  -- OR  (SUM(B.dblSettleStorageAmount) - SUM(B.dblVoucherTotal)) != 0  
 ) tmpAPOpenClearing    
INNER JOIN tblGRSettleStorage SS  
 ON tmpAPOpenClearing.intSettleStorageId = SS.intSettleStorageId  
  AND SS.intParentSettleStorageId IS NOT NULL  
 INNER JOIN (tblGRCustomerStorage CS INNER JOIN tblGRSettleStorageTicket SST   
           ON SST.intCustomerStorageId = CS.intCustomerStorageId)  
      ON SST.intSettleStorageId = SS.intSettleStorageId  
  INNER JOIN (tblAPVendor vendor INNER JOIN tblEMEntity entity ON vendor.intEntityId = entity.intEntityId)    
  ON tmpAPOpenClearing.intEntityVendorId = vendor.intEntityId    
 CROSS APPLY tblSMCompanySetup compSetup    
 WHERE 1 = CASE WHEN (dblClearingQty) = 0 OR (dblClearingAmount) = 0 THEN 0 ELSE 1 END   
--   UNION ALL --TRANSFER (original receipts that were transferred)  
--  SELECT    
--   receipt.strReceiptNumber  
--   ,receipt.dtmReceiptDate  
--   ,receiptItem.intInventoryReceiptItemId  
--   ,NULL AS intInventoryReceiptChargeId  
--   ,NULL AS intInventoryShipmentChargeId  
--   ,NULL AS intLoadDetailId  
--   ,NULL AS intSettleStorageId   
--   ,NULL AS intRefundCustomerId  
--   ,NULL strBillOfLading    
--   ,'''' AS strOrderNumber    
--   -- ,vouchersDate.strVoucherDate AS dtmBillDate    
--   -- ,vouchers.strVoucherIds AS strBillId    
--   -- ,vouchersTerm.strVoucherTerm AS strTerm    
--   ,CASE WHEN DATEDIFF(dayofyear,receipt.dtmReceiptDate,GETDATE())<=0     
--    THEN 0    
--   ELSE ISNULL(DATEDIFF(dayofyear,receipt.dtmReceiptDate,GETDATE()),0) END AS intAging    
--   ,dbo.fnTrim(ISNULL(vendor.strVendorId, entity.strEntityNo) + '' - '' + isnull(entity.strName,'''')) as strVendorIdName   
--   ,tmpAPOpenClearing.strLocationName    
--   ,tmpAPOpenClearing.dblReceiptQty AS dblQtyToReceive    
--   ,tmpAPOpenClearing.dblTransferQty AS dblQtyVouchered    
--   ,tmpAPOpenClearing.dblReceiptTotal AS dblTotal    
--   ,tmpAPOpenClearing.dblTransferTotal AS dblVoucherAmount    
--   ,tmpAPOpenClearing.dblClearingQty AS dblQtyToVoucher    
--   ,tmpAPOpenClearing.dblReceiptTotal - tmpAPOpenClearing.dblTransferTotal AS dblAmountToVoucher    
--   ,GETDATE() as dtmCurrentDate    
--   ,dbo.[fnAPFormatAddress](NULL, NULL, NULL, compSetup.strAddress, compSetup.strCity, compSetup.strState, compSetup.strZip, compSetup.strCountry, NULL) AS strCompanyAddress    
--   ,compSetup.strCompanyName    
--  FROM      
--  (    
--   SELECT    
--    B.intInventoryReceiptItemId  
--    ,B.strTransactionNumber    
--    ,SUM(B.dblTransferTotal) AS dblTransferTotal  
--    ,SUM(B.dblTransferQty) AS dblTransferQty    
--    ,SUM(B.dblReceiptTotal) AS dblReceiptTotal    
--    ,SUM(B.dblReceiptQty) AS dblReceiptQty    
--    ,SUM(B.dblReceiptQty) - SUM(B.dblTransferQty)  AS dblClearingQty    
--    ,SUM(B.dblReceiptTotal) - SUM(B.dblTransferTotal) AS dblClearingAmount  
--    ,B.intLocationId    
--    ,B.strLocationName  
--   FROM grainTransferClearing B    
--   GROUP BY     
--    intInventoryReceiptItemId  
--    ,strTransactionNumber    
--    ,intItemId    
--    ,intLocationId    
--    ,strLocationName  
--   --  HAVING   
--   --     (SUM(B.dblTransferQty) - SUM(B.dblReceiptQty)) != 0  
--   -- OR  (SUM(B.dblTransferTotal) - SUM(B.dblReceiptTotal)) != 0  
--  ) tmpAPOpenClearing    
-- INNER JOIN (tblICInventoryReceiptItem receiptItem INNER JOIN tblICInventoryReceipt receipt   
--             ON receipt.intInventoryReceiptId = receiptItem.intInventoryReceiptId)  
--   ON receiptItem.intInventoryReceiptItemId = tmpAPOpenClearing.intInventoryReceiptItemId AND receipt.strReceiptNumber = tmpAPOpenClearing.strTransactionNumber  
--   INNER JOIN (tblAPVendor vendor INNER JOIN tblEMEntity entity ON vendor.intEntityId = entity.intEntityId)    
--   ON receipt.intEntityVendorId = vendor.intEntityId    
--  CROSS APPLY tblSMCompanySetup compSetup    
--  WHERE 1 = CASE WHEN (dblClearingQty) = 0 OR (dblClearingAmount) = 0 THEN 0 ELSE 1 END   
--    UNION ALL --TRANSFER (transfer storages that were transferred)  
--  SELECT    
--   transferstorage.strTransferStorageTicket  
--   ,transferstorage.dtmTransferStorageDate  
--   ,transferreference.intTransferStorageReferenceId  
--   ,NULL AS intInventoryReceiptChargeId  
--   ,NULL AS intInventoryShipmentChargeId  
--   ,NULL AS intLoadDetailId  
--   ,NULL AS intSettleStorageId   
--   ,NULL AS intRefundCustomerId  
--   ,NULL strBillOfLading    
--   ,'''' AS strOrderNumber    
--   -- ,vouchersDate.strVoucherDate AS dtmBillDate    
--   -- ,vouchers.strVoucherIds AS strBillId    
--   -- ,vouchersTerm.strVoucherTerm AS strTerm    
--   ,CASE WHEN DATEDIFF(dayofyear,transferstorage.dtmTransferStorageDate,GETDATE())<=0     
--    THEN 0    
--   ELSE ISNULL(DATEDIFF(dayofyear,transferstorage.dtmTransferStorageDate,GETDATE()),0) END AS intAging    
--   ,dbo.fnTrim(ISNULL(vendor.strVendorId, entity.strEntityNo) + '' - '' + isnull(entity.strName,'''')) as strVendorIdName   
--   ,tmpAPOpenClearing.strLocationName    
--   ,tmpAPOpenClearing.dblReceiptQty AS dblQtyToReceive    
--   ,tmpAPOpenClearing.dblTransferQty AS dblQtyVouchered    
--   ,tmpAPOpenClearing.dblReceiptTotal AS dblTotal    
--   ,tmpAPOpenClearing.dblTransferTotal AS dblVoucherAmount    
--   ,tmpAPOpenClearing.dblClearingQty AS dblQtyToVoucher    
--   ,tmpAPOpenClearing.dblReceiptTotal - tmpAPOpenClearing.dblTransferTotal AS dblAmountToVoucher    
--   ,GETDATE() as dtmCurrentDate    
--   ,dbo.[fnAPFormatAddress](NULL, NULL, NULL, compSetup.strAddress, compSetup.strCity, compSetup.strState, compSetup.strZip, compSetup.strCountry, NULL) AS strCompanyAddress    
--   ,compSetup.strCompanyName    
--  FROM      
--  (    
--   SELECT    
--    B.intInventoryReceiptItemId  
--    ,B.strTransactionNumber    
--    ,SUM(B.dblTransferTotal) AS dblTransferTotal  
--    ,SUM(B.dblTransferQty) AS dblTransferQty    
--    ,SUM(B.dblReceiptTotal) AS dblReceiptTotal    
--    ,SUM(B.dblReceiptQty) AS dblReceiptQty    
--    ,SUM(B.dblReceiptQty) - SUM(B.dblTransferQty)  AS dblClearingQty    
--    ,SUM(B.dblReceiptTotal) - SUM(B.dblTransferTotal) AS dblClearingAmount  
--    ,B.intLocationId    
--    ,B.strLocationName  
--   FROM grainTransferClearing B  
--   GROUP BY     
--    intInventoryReceiptItemId  
--    ,strTransactionNumber    
--    ,intItemId    
--    ,intLocationId    
--    ,strLocationName  
--   --  HAVING   
--   --     (SUM(B.dblTransferQty) - SUM(B.dblReceiptQty)) != 0  
--   -- OR  (SUM(B.dblTransferTotal) - SUM(B.dblReceiptTotal)) != 0  
--  ) tmpAPOpenClearing    
-- INNER JOIN (  
--    tblGRTransferStorageReference transferreference  
--    INNER JOIN tblGRCustomerStorage cs  
--     ON cs.intCustomerStorageId = transferreference.intToCustomerStorageId  
--    INNER JOIN tblGRTransferStorage transferstorage  
--     ON transferstorage.intTransferStorageId = transferreference.intTransferStorageId  
--    )  
--  ON transferreference.intTransferStorageReferenceId = tmpAPOpenClearing.intInventoryReceiptItemId  
-- INNER JOIN (  
--    tblAPVendor vendor   
--    INNER JOIN tblEMEntity entity   
--     ON vendor.intEntityId = entity.intEntityId  
--    )  
--  ON cs.intEntityId = vendor.intEntityId    
--  CROSS APPLY tblSMCompanySetup compSetup    
--  WHERE 1 = CASE WHEN (dblClearingQty) = 0 OR (dblClearingAmount) = 0 THEN 0 ELSE 1 END   
--    UNION ALL --IR CHARGES THAT WERE TRANSFERRED  
--   SELECT    
--   r.strReceiptNumber   
--   ,r.dtmReceiptDate  
--   ,NULL AS intInventoryReceiptItemId  
--   ,rc.intInventoryReceiptChargeId  
--   ,NULL AS intInventoryShipmentChargeId  
--   ,NULL AS intLoadDetailId  
--   ,NULL AS intSettleStorageId   
--   ,NULL AS intRefundCustomerId  
--   ,NULL strBillOfLading    
--   ,'''' AS strOrderNumber    
--   -- ,vouchersDate.strVoucherDate AS dtmBillDate    
--   -- ,vouchers.strVoucherIds AS strBillId    
--   -- ,vouchersTerm.strVoucherTerm AS strTerm    
--   ,CASE WHEN DATEDIFF(dayofyear,r.dtmReceiptDate,GETDATE())<=0     
--    THEN 0    
--   ELSE ISNULL(DATEDIFF(dayofyear,r.dtmReceiptDate,GETDATE()),0) END AS intAging    
--   ,dbo.fnTrim(ISNULL(vendor.strVendorId, entity.strEntityNo) + '' - '' + isnull(entity.strName,'''')) as strVendorIdName   
--   ,tmpAPOpenClearing.strLocationName    
--   ,tmpAPOpenClearing.dblReceiptChargeQty AS dblQtyToReceive    
--   ,tmpAPOpenClearing.dblTransferQty AS dblQtyVouchered    
--   ,tmpAPOpenClearing.dblReceiptChargeTotal AS dblTotal    
--   ,tmpAPOpenClearing.dblTransferTotal AS dblVoucherAmount    
--   ,tmpAPOpenClearing.dblClearingQty AS dblQtyToVoucher    
--   ,tmpAPOpenClearing.dblReceiptChargeTotal - tmpAPOpenClearing.dblTransferTotal AS dblAmountToVoucher    
--   ,GETDATE() as dtmCurrentDate    
--   ,dbo.[fnAPFormatAddress](NULL, NULL, NULL, compSetup.strAddress, compSetup.strCity, compSetup.strState, compSetup.strZip, compSetup.strCountry, NULL) AS strCompanyAddress    
--   ,compSetup.strCompanyName    
--  FROM      
--  (    
--   SELECT    
--   B.intInventoryReceiptChargeId  
--    ,B.strTransactionNumber    
--    ,SUM(B.dblTransferTotal) AS dblTransferTotal  
--    ,SUM(B.dblTransferQty) AS dblTransferQty    
--    ,SUM(B.dblReceiptChargeTotal) AS dblReceiptChargeTotal    
--    ,SUM(B.dblReceiptChargeQty) AS dblReceiptChargeQty    
--    ,SUM(B.dblReceiptChargeQty) - SUM(B.dblTransferQty)  AS dblClearingQty    
--    ,SUM(B.dblReceiptChargeTotal) - SUM(B.dblTransferTotal) AS dblClearingAmount  
--    ,B.intLocationId    
--    ,B.strLocationName  
--   FROM grainTransferChargeClearing B    
--   GROUP BY     
--    intInventoryReceiptChargeId  
--    ,strTransactionNumber    
--    ,intItemId    
--    ,intLocationId    
--    ,strLocationName  
--   --  HAVING   
--   --     (SUM(B.dblTransferQty) - SUM(B.dblReceiptChargeQty)) != 0  
--   -- OR  (SUM(B.dblTransferTotal) - SUM(B.dblReceiptChargeTotal)) != 0  
--  ) tmpAPOpenClearing    
-- INNER JOIN tblICInventoryReceiptCharge rc    
--   ON tmpAPOpenClearing.intInventoryReceiptChargeId = rc.intInventoryReceiptChargeId    
--  INNER JOIN tblICInventoryReceipt r    
--   ON r.intInventoryReceiptId = rc.intInventoryReceiptId   
--   INNER JOIN (tblAPVendor vendor INNER JOIN tblEMEntity entity ON vendor.intEntityId = entity.intEntityId)    
--   ON r.intEntityVendorId = vendor.intEntityId    
--  CROSS APPLY tblSMCompanySetup compSetup    
-- WHERE 1 = CASE WHEN (dblClearingQty) = 0 OR (dblClearingAmount) = 0 THEN 0 ELSE 1 END  
--  AND tmpAPOpenClearing.strTransactionNumber NOT LIKE ''TRA%''  
-- UNION ALL --TRANSFER CHARGES  
--   SELECT    
--   r.strTransferStorageTicket   
--   ,r.dtmTransferStorageDate  
--   ,NULL AS intInventoryReceiptItemId  
--   ,rc.intTransferStorageReferenceId  
--   ,NULL AS intInventoryShipmentChargeId  
--   ,NULL AS intLoadDetailId  
--   ,NULL AS intSettleStorageId   
--   ,NULL AS intRefundCustomerId  
--   ,NULL strBillOfLading    
--   ,'''' AS strOrderNumber    
--   -- ,vouchersDate.strVoucherDate AS dtmBillDate    
--   -- ,vouchers.strVoucherIds AS strBillId    
--   -- ,vouchersTerm.strVoucherTerm AS strTerm    
--   ,CASE WHEN DATEDIFF(dayofyear,r.dtmTransferStorageDate,GETDATE())<=0     
--    THEN 0    
--   ELSE ISNULL(DATEDIFF(dayofyear,r.dtmTransferStorageDate,GETDATE()),0) END AS intAging    
--   ,dbo.fnTrim(ISNULL(vendor.strVendorId, entity.strEntityNo) + '' - '' + isnull(entity.strName,'''')) as strVendorIdName   
--   ,tmpAPOpenClearing.strLocationName    
--   ,tmpAPOpenClearing.dblReceiptChargeQty AS dblQtyToReceive    
--   ,tmpAPOpenClearing.dblTransferQty AS dblQtyVouchered    
--   ,tmpAPOpenClearing.dblReceiptChargeTotal AS dblTotal    
--   ,tmpAPOpenClearing.dblTransferTotal AS dblVoucherAmount    
--   ,tmpAPOpenClearing.dblClearingQty AS dblQtyToVoucher    
--   ,tmpAPOpenClearing.dblReceiptChargeTotal - tmpAPOpenClearing.dblTransferTotal AS dblAmountToVoucher    
--   ,GETDATE() as dtmCurrentDate    
--   ,dbo.[fnAPFormatAddress](NULL, NULL, NULL, compSetup.strAddress, compSetup.strCity, compSetup.strState, compSetup.strZip, compSetup.strCountry, NULL) AS strCompanyAddress    
--   ,compSetup.strCompanyName    
--  FROM      
--  (    
--   SELECT    
--   B.intInventoryReceiptChargeId  
--    ,B.strTransactionNumber    
--    ,SUM(B.dblTransferTotal) AS dblTransferTotal  
--    ,SUM(B.dblTransferQty) AS dblTransferQty    
--    ,SUM(B.dblReceiptChargeTotal) AS dblReceiptChargeTotal    
--    ,SUM(B.dblReceiptChargeQty) AS dblReceiptChargeQty    
--    ,SUM(B.dblReceiptChargeQty) - SUM(B.dblTransferQty)  AS dblClearingQty    
--    ,SUM(B.dblReceiptChargeTotal) - SUM(B.dblTransferTotal) AS dblClearingAmount  
--    ,B.intLocationId    
--    ,B.strLocationName  
--   FROM grainTransferChargeClearing B    
--   GROUP BY     
--    intInventoryReceiptChargeId  
--    ,strTransactionNumber    
--    ,intItemId    
--    ,intLocationId    
--    ,strLocationName  
--   --  HAVING   
--   --     (SUM(B.dblTransferQty) - SUM(B.dblReceiptChargeQty)) != 0  
--   -- OR  (SUM(B.dblTransferTotal) - SUM(B.dblReceiptChargeTotal)) != 0  
--  ) tmpAPOpenClearing    
-- INNER JOIN tblGRTransferStorageReference rc    
--   ON tmpAPOpenClearing.intInventoryReceiptChargeId = rc.intTransferStorageReferenceId  
--  INNER JOIN tblGRTransferStorage r    
--   ON r.intTransferStorageId = rc.intTransferStorageId    
--   INNER JOIN tblGRCustomerStorage CS  
--  ON CS.intCustomerStorageId = rc.intToCustomerStorageId  
--   INNER JOIN (tblAPVendor vendor INNER JOIN tblEMEntity entity ON vendor.intEntityId = entity.intEntityId)    
--   ON CS.intEntityId = vendor.intEntityId    
--  CROSS APPLY tblSMCompanySetup compSetup    
-- WHERE 1 = CASE WHEN (dblClearingQty) = 0 OR (dblClearingAmount) = 0 THEN 0 ELSE 1 END  
   UNION ALL   
 --PATRONAGE  
 SELECT    
  refund.strRefundNo  
  ,refund.dtmRefundDate  
  ,NULL AS intInventoryReceiptItemId  
  ,NULL AS intInventoryReceiptChargeId  
  ,NULL AS intInventoryShipmentChargeId  
  ,NULL AS intLoadDetailId  
  ,NULL AS intSettleStorageId   
  ,refundEntity.intRefundCustomerId  
  ,NULL strBillOfLading    
  ,'''' AS strOrderNumber    
  ,CASE WHEN DATEDIFF(dayofyear,refund.dtmRefundDate,GETDATE())<=0     
   THEN 0    
  ELSE ISNULL(DATEDIFF(dayofyear,dtmRefundDate,GETDATE()),0) END AS intAging    
  ,dbo.fnTrim(ISNULL(vendor.strVendorId, entity.strEntityNo) + '' - '' + isnull(entity.strName,'''')) as strVendorIdName   
  ,tmpAPOpenClearing.strLocationName    
  ,tmpAPOpenClearing.dblRefundQty AS dblQtyToReceive    
  ,tmpAPOpenClearing.dblVoucherQty AS dblQtyVouchered    
  ,tmpAPOpenClearing.dblRefundTotal AS dblTotal    
  ,tmpAPOpenClearing.dblVoucherTotal AS dblVoucherAmount    
  ,tmpAPOpenClearing.dblClearingQty AS dblQtyToVoucher    
  ,tmpAPOpenClearing.dblRefundTotal - tmpAPOpenClearing.dblVoucherTotal AS dblAmountToVoucher    
  ,GETDATE() as dtmCurrentDate    
  ,dbo.[fnAPFormatAddress](NULL, NULL, NULL, compSetup.strAddress, compSetup.strCity, compSetup.strState, compSetup.strZip, compSetup.strCountry, NULL) AS strCompanyAddress    
  ,compSetup.strCompanyName    
 FROM      
 (    
  SELECT    
   B.intEntityVendorId    
   ,B.intRefundCustomerId  
   ,B.strTransactionNumber    
   ,SUM(B.dblRefundTotal) AS   dblRefundTotal  
   ,SUM(B.dblRefundQty) AS dblRefundQty    
   ,SUM(B.dblVoucherTotal) AS dblVoucherTotal    
   ,SUM(B.dblVoucherQty) AS dblVoucherQty    
   ,SUM(B.dblRefundQty)  -  SUM(B.dblVoucherQty) AS dblClearingQty    
   ,SUM(B.dblRefundTotal) - SUM(B.dblVoucherTotal) AS dblClearingAmount  
   ,NULL intLocationId    
   ,NULL strLocationName  
  FROM patClearing B    
  GROUP BY     
   intEntityVendorId    
   ,intRefundCustomerId  
   ,strTransactionNumber    
  --  ,intItemId    
  --  ,intLocationId    
  --  ,strLocationName  
  --  HAVING   
  --     (SUM(B.dblSettleStorageQty) - SUM(B.dblVoucherQty)) != 0  
  -- OR  (SUM(B.dblSettleStorageAmount) - SUM(B.dblVoucherTotal)) != 0  
 ) tmpAPOpenClearing    
INNER JOIN (tblPATRefund refund INNER JOIN tblPATRefundCustomer refundEntity   
                        ON refund.intRefundId = refundEntity.intRefundId)  
                ON refundEntity.intRefundCustomerId = tmpAPOpenClearing.intRefundCustomerId  
  INNER JOIN (tblAPVendor vendor INNER JOIN tblEMEntity entity ON vendor.intEntityId = entity.intEntityId)    
  ON tmpAPOpenClearing.intEntityVendorId = vendor.intEntityId    
 CROSS APPLY tblSMCompanySetup compSetup    
 WHERE 1 = CASE WHEN (dblClearingQty) = 0 OR (dblClearingAmount) = 0 THEN 0 ELSE 1 END  
) MainQuery  
) tmp '    
    
--SET @query = REPLACE(@query, 'GETDATE()', '''' + CONVERT(VARCHAR(10), @dateTo, 110) + '''');    
    
IF NULLIF(@filter,'') IS NOT NULL  
BEGIN    
 SET @query = @query + ' WHERE ' + @filter    
END    
    
--PRINT @filter    
--PRINT @query   

INSERT INTO tmpAPClearingBalance
EXEC sp_executesql @query

IF OBJECT_ID(N'tmpAPClearingGLBalance') IS NOT NULL DROP TABLE tmpAPClearingGLBalance
CREATE TABLE tmpAPClearingGLBalance(dblBalance DECIMAL(18,6))

INSERT INTO tmpAPClearingGLBalance
SELECT 
  SUM(dblDebit - dblCredit) AS dblGLClearing 
FROM tblGLDetail A
INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
WHERE A.ysnIsUnposted = 0 AND B.intAccountCategoryId = 45
AND DATEADD(dd, DATEDIFF(dd, 0,dtmDate), 0) BETWEEN '1/1/1900' AND @currentDateStr

SELECT
  A.dblBalance AS dblReportBalance,
  B.dblBalance AS dblGLBalance,
  A.dblBalance + B.dblBalance AS dblDifference
FROM tmpAPClearingBalance A
CROSS APPLY tmpAPClearingGLBalance B