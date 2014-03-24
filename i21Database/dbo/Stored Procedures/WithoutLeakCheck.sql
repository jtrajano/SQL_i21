
-- =============================================
-- Author:		iRely Reports Team (Smith Wilson G. de Jesus)
-- Create date: March 12, 2013
-- Description:	Without Leak Check
-- =============================================
CREATE PROCEDURE [dbo].[WithoutLeakCheck](
	@xmlParam NVARCHAR(MAX)=null   )
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
--set @xmlparam = '<filterinfo>
--<parameter>
--<fieldname>CustomerStatus</fieldname>
--<condition>Equal To</condition>
--<from>Inactive</from>
--<to></to>
--<join>and</join>
--<begingroup />
--<endgroup />
--<datatype>string</datatype>
--</parameter>
--</filterinfo>'
	
	
	SET NOCOUNT ON;
	IF (ISNULL(@xmlParam,'') = '')
	begin 
	select '' AS xmlParam
		  ,'' AS agcus_first_name
		  ,'' AS agcus_last_name
		  ,'' AS CustomerName
		  ,'' AS CustomerStatus
		  ,Getdate() AS dtmDate
		  ,0 AS intSiteID
		  ,0 AS intSiteNumber
		  ,0 AS intTankSize
		  ,0 AS intTotalTanks
		  ,'' AS SiteStatus
		  ,'' AS strLocation
		  ,'' AS strOwnership
		  ,'' AS strSerialNumber
		  ,'' AS strTankType
		  ,'' AS vwcus_key
		  ,0 AS ysnHasLeakCheck
	return;
	end
	
	DECLARE @idoc int
			,@CustomerActive nvarchar(2)
			,@FromCustomerStat nvarchar(50)
			,@FromSiteStatus nvarchar(50)
			,@SiteActive int
			,@FromTankOwnership nvarchar(50)
			,@FromDate nvarchar(50)
			,@ToDate nvarchar(50)
			,@FromLocation nvarchar(50)
			,@ToLocation nvarchar(50)
			,@Query nvarchar(max)
			,@WhereClause1 nvarchar(500) = ''
			,@WhereClause2 nvarchar(500) = ''
			
			exec sp_xml_preparedocument @idoc output, @xmlParam
			
			DECLARE @temp_params table ([fieldname] nvarchar(50)
					, condition nvarchar(20)      
					, [from] nvarchar(50)
					, [to] nvarchar(50)
					, [join] nvarchar(10)
					, [begingroup] nvarchar(50)
					, [endgroup] nvarchar(50)
					, [datatype] nvarchar(50))
            
      insert into @temp_params
      select *
      from openxml(@idoc, 'xmlparam/filters/filter',2)
      with ([fieldname] nvarchar(50)
            , condition nvarchar(20)
            , [from] nvarchar(50)
            , [to] nvarchar(50)
            , [join] nvarchar(10)
            , [begingroup] nvarchar(50)
            , [endgroup] nvarchar(50)
            , [datatype] nvarchar(50))

	--Location
	SELECT @FromLocation = [from]
		  ,@ToLocation = [to]
	FROM @temp_params where [fieldname] = 'strLocation'
	
	--Date
	SELECT @FromDate = [from]
		  ,@ToDate = [to]
	FROM @temp_params where [fieldname] = 'dtmDate'
	
	--Customer Status
	SELECT @FromCustomerStat = [from]
		  ,@CustomerActive = (CASE [from] WHEN 'Active' THEN 'Y'
				WHEN 'Inactive' THEN  'N' END) 
	FROM @temp_params where [fieldname] = 'CustomerStatus'
	
	--Site Status
	SELECT @FromSiteStatus = [from]
		  ,@SiteActive = (CASE [from] WHEN 'Active' THEN 1
				WHEN 'Inactive' THEN  0 END) 
	FROM @temp_params where [fieldname] = 'SiteStatus'
	
	--Tank Ownership
	SELECT @FromTankOwnership = [from]
	FROM @temp_params where [fieldname] = 'strOwnership'
	
	--For intTotalTanks subquery WHERE CLAUSE
	IF (ISNULL(@FromSiteStatus,'') != '')
	BEGIN SET @WhereClause1 = ' AND Z.ysnActive = ' + Cast(@SiteActive as nvarchar(2))  END
	IF (ISNULL(@FromCustomerStat,'') != '')
	BEGIN SET @WhereClause1 = @WhereClause1 + ' AND X.vwcus_active_yn = ''' + @CustomerActive + '''' END
	IF (ISNULL(@FromTankOwnership,'') != '')
	BEGIN SET @WhereClause1 = @WhereClause1 + ' AND V.strOwnership = ''' + @FromTankOwnership + '''' END
	
	--For Main Query WHERE CLAUSE
	IF (ISNULL(@FromLocation,'') != '')
	BEGIN SET @WhereClause2 = 'AND strLocation BETWEEN ''' + @FromLocation + ''' AND ''' + @ToLocation + '''' END
	IF (ISNULL(@FromSiteStatus,'') != '')
	BEGIN SET @WhereClause2 = @WhereClause2 + ' AND SiteStatus = ''' + @FromSiteStatus + ''''   END
	IF (ISNULL(@FromCustomerStat,'') != '')
	BEGIN SET @WhereClause2 = @WhereClause2 + ' AND CustomerStatus = ''' + @FromCustomerStat + ''''   END
	IF (ISNULL(@FromTankOwnership,'') != '')
	BEGIN SET @WhereClause2 = @WhereClause2 + ' AND strOwnership = ''' + @FromTankOwnership + '''' END
	
	--select * from @temp_params
Set @Query = '
SELECT 
 * 
FROM
(
	SELECT 
	  C.strLocation
	, B.vwcus_key
	, rtrim(ltrim(B.vwcus_last_name)) as agcus_last_name
	, rtrim(ltrim(B.vwcus_first_name)) as agcus_first_name
	,(Case WHEN B.vwcus_first_name IS NULL OR B.vwcus_first_name = ''''  THEN
		RTRIM(B.vwcus_last_name)
		ELSE
		RTRIM(B.vwcus_last_name) + '', '' + RTRIM(B.vwcus_first_name)
	 END) as CustomerName
	, C.intSiteID
	, C.intSiteNumber
	, E.strSerialNumber
	, E.intTankSize
	, E.strOwnership
	,(Select Top 1 tt.strTankType From tblTMTankType tt Where tt.intTankTypeId = E.intTankTypeId) AS [strTankType]
	, (Case C.ysnActive
		When 1 then
			''Active''
		When 0 then
			''Inactive''
		End) as SiteStatus
	, (Case B.vwcus_active_yn
		When ''Y'' then
			''Active''
		When ''N'' then
			''Inactive''
		End) as CustomerStatus
	,(CASE WHEN (EXISTS(SELECT TOP 1 1 FROM tblTMEvent WHERE tblTMEvent.intSiteID = C.intSiteID AND tblTMEvent.intEventTypeID = 4))
					THEN 1 ELSE 0 END)as ysnHasLeakCheck
	,(SELECT Top 1 dtmDate FROM tblTMEvent WHERE tblTMEvent.intSiteID = C.intSiteID AND tblTMEvent.intEventTypeID = 4 order by dtmDate Desc)as dtmDate
	,intTotalTanks = (Select COUNT(Z.strLocation)
						FROM tblTMSite Z
						INNER JOIN tblTMCustomer Y ON Z.intCustomerID = Y.intCustomerID
						INNER JOIN vwcusmst X on Y.intCustomerNumber = X.A4GLIdentity
						INNER JOIN tblTMSiteDevice W ON Z.intSiteID =W.intSiteID
						INNER JOIN tblTMDevice V ON W.intDeviceID = V.intDeviceID 
						INNER JOIN tblTMDeviceType U ON ISNULL(V.intDeviceTypeID,0) = ISNULL(U.intDeviceTypeID,-1)
						WHERE
						V.ysnAppliance = 0
						AND V.intInventoryStatusTypeID = 2 
						AND U.strDeviceType = ''Tank'' 
						AND Z.strLocation = C.strLocation
						' + ISNULL(@WhereClause1,'') + '
						)
	FROM tblTMSite C
	INNER JOIN tblTMCustomer A ON C.intCustomerID = A.intCustomerID
	INNER JOIN vwcusmst B on A.intCustomerNumber = B.A4GLIdentity
	INNER JOIN tblTMSiteDevice D ON C.intSiteID =D.intSiteID
	INNER JOIN tblTMDevice E ON D.intDeviceID = E.intDeviceID 
	INNER JOIN tblTMDeviceType G ON ISNULL(E.intDeviceTypeID,0) = ISNULL(G.intDeviceTypeID,-1) 
	WHERE
	E.ysnAppliance = 0
	and E.intInventoryStatusTypeID = 2 
	AND G.strDeviceType = ''Tank''
) Z
where	ysnHasLeakCheck = 0 '
	
		
	--Append Where Clause to main query
	IF(ISNULL(@WhereClause2,'') != '')
	BEGIN Set @Query = @Query + @WhereClause2 END
	
	EXEC(@Query)
	
	
END