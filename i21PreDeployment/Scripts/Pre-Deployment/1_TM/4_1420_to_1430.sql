
PRINT N'BEGIN Update of data in tblSMSite'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMSite]') AND type in (N'U')) 
BEGIN
	IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblWinterDailyUse' AND OBJECT_ID = OBJECT_ID(N'tblTMSite')) 
    BEGIN
        UPDATE tblTMSite
		SET dblWinterDailyUse = 0.0
		WHERE dblWinterDailyUse IS NULL
    END

	IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'dblSummerDailyUse' AND OBJECT_ID = OBJECT_ID(N'tblTMSite')) 
    BEGIN
        UPDATE tblTMSite
		SET dblSummerDailyUse = 0.0
		WHERE dblSummerDailyUse IS NULL
    END
END
GO
PRINT N'END Update of data in tblSMSite'
GO


PRINT N'BEGIN Update of data in tblTMRoute check duplicates'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMRoute]') AND type in (N'U') 
   AND EXISTS(SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strRouteId' AND OBJECT_ID = OBJECT_ID(N'tblTMRoute'))
   AND EXISTS(SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intRouteId' AND OBJECT_ID = OBJECT_ID(N'tblTMRoute'))
   ) 
BEGIN
	SELECT intRouteId
		   ,strRouteId
		   ,rownumber = ROW_NUMBER() OVER (PARTITION BY strRouteId ORDER BY intRouteId,strRouteId ASC)
	INTO #tmpRouteTable
	FROM tblTMRoute

	UPDATE tblTMRoute
	SET tblTMRoute.strRouteId = A.strRouteId + '_' + CAST(A.rownumber AS NVARCHAR(5))
	FROM #tmpRouteTable A
	WHERE tblTMRoute.intRouteId = A.intRouteId AND  A.rownumber > 1

	DROP TABLE #tmpRouteTable
END
PRINT N'END Update of data in tblTMRoute check duplicates'
GO


PRINT N'BEGIN Update of data in tblTMFillMethod check duplicates'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMFillMethod]') AND type in (N'U') 
   AND EXISTS(SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strFillMethod' AND OBJECT_ID = OBJECT_ID(N'tblTMFillMethod'))
   AND EXISTS(SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intFillMethodId' AND OBJECT_ID = OBJECT_ID(N'tblTMFillMethod'))
   ) 
BEGIN
	SELECT intFillMethodId
		   ,strFillMethod
		   ,rownumber = ROW_NUMBER() OVER (PARTITION BY strFillMethod ORDER BY ysnDefault DESC,intFillMethodId ASC)
	INTO #tmpFillMethodTable
	FROM tblTMFillMethod

	UPDATE tblTMFillMethod
	SET tblTMFillMethod.strFillMethod = A.strFillMethod + '_' + CAST(A.rownumber AS NVARCHAR(5))
	FROM #tmpFillMethodTable A
	WHERE tblTMFillMethod.intFillMethodId = A.intFillMethodId AND  A.rownumber > 1

	DROP TABLE #tmpFillMethodTable
END
PRINT N'END Update of data in tblTMFillMethod check duplicates'
GO



PRINT N'BEGIN Update of data in tblTMHoldReason check duplicates'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMHoldReason]') AND type in (N'U') 
   AND EXISTS(SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strHoldReason' AND OBJECT_ID = OBJECT_ID(N'tblTMHoldReason'))
   AND EXISTS(SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intHoldReasonID' AND OBJECT_ID = OBJECT_ID(N'tblTMHoldReason'))
   ) 
BEGIN
	SELECT intHoldReasonID
		   ,strHoldReason
		   ,rownumber = ROW_NUMBER() OVER (PARTITION BY strHoldReason ORDER BY intHoldReasonID ASC)
	INTO #tmpFillMethodTable
	FROM tblTMHoldReason

	UPDATE tblTMHoldReason
	SET tblTMHoldReason.strHoldReason = A.strHoldReason + '_' + CAST(A.rownumber AS NVARCHAR(5))
	FROM #tmpFillMethodTable A
	WHERE tblTMHoldReason.intHoldReasonID = A.intHoldReasonID AND  A.rownumber > 1

	DROP TABLE #tmpFillMethodTable
END
PRINT N'END Update of data in tblTMHoldReason check duplicates'
GO


PRINT N'BEGIN Update of data in tblTMTankTownship check duplicates'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMTankTownship]') AND type in (N'U') 
   AND EXISTS(SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strTankTownship' AND OBJECT_ID = OBJECT_ID(N'tblTMTankTownship'))
   AND EXISTS(SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intTankTownshipId' AND OBJECT_ID = OBJECT_ID(N'tblTMTankTownship'))
   ) 
BEGIN
	SELECT intTankTownshipId
		   ,strTankTownship
		   ,rownumber = ROW_NUMBER() OVER (PARTITION BY strTankTownship ORDER BY intTankTownshipId ASC)
	INTO #tmpFillMethodTable
	FROM tblTMTankTownship

	UPDATE tblTMTankTownship
	SET tblTMTankTownship.strTankTownship = A.strTankTownship + '_' +  CAST(A.rownumber AS NVARCHAR(5))
	FROM #tmpFillMethodTable A
	WHERE tblTMTankTownship.intTankTownshipId = A.intTankTownshipId AND  A.rownumber > 1

	DROP TABLE #tmpFillMethodTable
END
PRINT N'END Update of data in tblTMTankTownship check duplicates'
GO


PRINT N'BEGIN Update of data in tblTMWorkCloseReason check duplicates'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMWorkCloseReason]') AND type in (N'U') 
   AND EXISTS(SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strCloseReason' AND OBJECT_ID = OBJECT_ID(N'tblTMWorkCloseReason'))
   AND EXISTS(SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intCloseReasonID' AND OBJECT_ID = OBJECT_ID(N'tblTMWorkCloseReason'))
   ) 
BEGIN
	SELECT intCloseReasonID
		   ,strCloseReason
		   ,rownumber = ROW_NUMBER() OVER (PARTITION BY strCloseReason ORDER BY ysnDefault DESC,intCloseReasonID ASC)
	INTO #tmpFillMethodTable
	FROM tblTMWorkCloseReason

	UPDATE tblTMWorkCloseReason
	SET tblTMWorkCloseReason.strCloseReason = A.strCloseReason + '_' +  CAST(A.rownumber AS NVARCHAR(5))
	FROM #tmpFillMethodTable A
	WHERE tblTMWorkCloseReason.intCloseReasonID = A.intCloseReasonID AND  A.rownumber > 1

	DROP TABLE #tmpFillMethodTable
END
PRINT N'END Update of data in tblTMWorkCloseReason check duplicates'
GO


PRINT N'BEGIN Update of data in tblTMWorkStatusType check duplicates'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMWorkStatusType]') AND type in (N'U') 
   AND EXISTS(SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strWorkStatus' AND OBJECT_ID = OBJECT_ID(N'tblTMWorkStatusType'))
   AND EXISTS(SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intWorkStatusID' AND OBJECT_ID = OBJECT_ID(N'tblTMWorkStatusType'))
   ) 
BEGIN
	SELECT intWorkStatusID
		   ,strWorkStatus
		   ,rownumber = ROW_NUMBER() OVER (PARTITION BY strWorkStatus ORDER BY ysnDefault DESC,intWorkStatusID ASC)
	INTO #tmpFillMethodTable
	FROM tblTMWorkStatusType

	UPDATE tblTMWorkStatusType
	SET tblTMWorkStatusType.strWorkStatus = A.strWorkStatus + '_' +  CAST(A.rownumber AS NVARCHAR(5))
	FROM #tmpFillMethodTable A
	WHERE tblTMWorkStatusType.intWorkStatusID = A.intWorkStatusID AND  A.rownumber > 1

	DROP TABLE #tmpFillMethodTable
END
PRINT N'END Update of data in tblTMWorkStatusType check duplicates'
GO

PRINT N'BEGIN Update of data in tblTMWorkToDoItem check duplicates'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMWorkToDoItem]') AND type in (N'U') 
   AND EXISTS(SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strToDoItem' AND OBJECT_ID = OBJECT_ID(N'tblTMWorkToDoItem'))
   AND EXISTS(SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intToDoItemID' AND OBJECT_ID = OBJECT_ID(N'tblTMWorkToDoItem'))
   ) 
BEGIN
	SELECT intToDoItemID
		   ,strToDoItem
		   ,rownumber = ROW_NUMBER() OVER (PARTITION BY strToDoItem ORDER BY ysnDefault DESC,intToDoItemID ASC)
	INTO #tmpFillMethodTable
	FROM tblTMWorkToDoItem

	UPDATE tblTMWorkToDoItem
	SET tblTMWorkToDoItem.strToDoItem = A.strToDoItem + '_' +  CAST(A.rownumber AS NVARCHAR(5))
	FROM #tmpFillMethodTable A
	WHERE tblTMWorkToDoItem.intToDoItemID = A.intToDoItemID AND  A.rownumber > 1

	DROP TABLE #tmpFillMethodTable
END
PRINT N'END Update of data in tblTMWorkToDoItem check duplicates'
GO


